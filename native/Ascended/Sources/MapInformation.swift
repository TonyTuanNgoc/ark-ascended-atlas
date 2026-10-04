import SwiftUI

struct MapInformation: Decodable {
    let subtitle: String
    let reviewedAt: String
    let sections: [InformationSection]
    let resources: [ResourceRecord]
    let sources: [SourceRecord]
}
struct InformationSection: Decodable, Identifiable {
    let id: String; let title: String; let items: [String]
}
struct ResourceRecord: Decodable, Identifiable {
    let name: String; let nodes: Int
    var id: String { name }
}
struct SourceRecord: Decodable, Identifiable {
    let title: String; let url: String
    var id: String { url }
}
struct MapInformationScreen: View {
    @Environment(\.arkMap) private var map
    let openMap: () -> Void
    let openDinos: () -> Void
    let openBosses: () -> Void
    @State private var search = ""
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                ZStack(alignment: .bottomLeading) {
                    GeometryReader { proxy in
                        Image(map.imageAsset).resizable().scaledToFill().frame(width: proxy.size.width, height: proxy.size.height).clipped()
                    }
                    LinearGradient(colors: [.clear, .black.opacity(0.95)], startPoint: .top, endPoint: .bottom)
                    VStack(alignment: .leading, spacing: 10) {
                        HStack { MapBadge(id: map.expansionID); Text(map.name).font(.system(size: 46, weight: .bold, design: .rounded)).accessibilityIdentifier("mapInformationTitle") }
                    }.padding(24)
                }.frame(height: 310).clipShape(RoundedRectangle(cornerRadius: 22))
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 14) {
                    metric("\((try? map.creatures.get().creatures.count) ?? 0)", "Dino")
                    metric("\(map.exploration?.artifacts.count ?? 0)", "Artifact")
                    metric(map == .ragnarok ? "5" : "\(map.bosses.isEmpty ? (map.expansion?.bosses.count ?? 0) : map.bosses.count)", "Boss")
                }
                HStack {
                    Button(action: openMap) { Label("Open map", systemImage: "map.fill") }.labelStyle(.iconOnly).accessibilityLabel("Open map").accessibilityIdentifier("openRagnarokMap")
                    Button(action: openDinos) { Label("Dino", systemImage: "pawprint.fill") }.labelStyle(.iconOnly).accessibilityLabel("Dino").accessibilityIdentifier("openDinos")
                    Button(action: openBosses) { Label("Boss", systemImage: "shield.lefthalf.filled") }.labelStyle(.iconOnly).accessibilityLabel("Boss").accessibilityIdentifier("openBosses")
                }.buttonStyle(.bordered)
                if map.information != nil, let record = map.expansion {
                    DisclosureGroup("Information & goals") { ExpansionProfile(record: record) }.cardStyle()
                }
                if let info = map.information {
                    ForEach(info.sections.filter { search.isEmpty || $0.title.localizedStandardContains(search) || $0.items.contains { $0.localizedStandardContains(search) } }) { section in
                        DisclosureGroup {
                            ForEach(section.items, id: \.self) { VisualBrief(text: $0).padding(.vertical, 5) }
                        } label: { Text(section.title).font(.headline) }.cardStyle().accessibilityIdentifier("information-" + section.id)
                    }
                    if search.isEmpty || "resources".localizedStandardContains(search) {
                        DisclosureGroup("Resources") {
                            ForEach(info.resources) { resource in VisualBrief(text: resource.name) }
                        }.cardStyle()
                    }
                } else {
                    if let record = map.expansion { DisclosureGroup("Information & goals") { ExpansionProfile(record: record) }.cardStyle() }
                }
            }.padding(24).frame(maxWidth: 1100).frame(maxWidth: .infinity)
        }.searchable(text: $search, prompt: "Search information on " + map.name)
            .background(Color(red: 0.025, green: 0.045, blue: 0.065))
    }
    private func metric(_ value: String, _ label: String) -> some View {
        VStack(alignment: .leading, spacing: 6) { Text(value).font(.title.bold()).foregroundStyle(.cyan); Text(label).font(.caption).foregroundStyle(.secondary) }.frame(maxWidth: .infinity, alignment: .leading).cardStyle()
    }
}
struct SourcesScreen: View {
    @Environment(\.arkMap) private var map
    var body: some View {
        List {
            Section(map.name + " · data sources") {
                ForEach(map.information?.sources ?? []) { source in
                    if let url = URL(string: source.url) { Link(source.title, destination: url) }
                }
            }
            Section("Imagery & coordinates") {
                Link("Map " + map.name + " Ascended · Wikily", destination: URL(string: map.mapURL)!)
                Text("The 8192 × 8192 terrain uses original zoom-5 tiles; zoom 6 was unavailable in the checked source. Creatures, artifacts and terminals use the selected map dataset. Route images are labeled; illustration images are not presented as cave-entrance photographs.")
                if map == .island { Text("The Island uses different coordinate systems for the mini-map (press M once) and waypoints (press M twice). Artifact coordinates follow the Wikily layer; cave entrances follow Ascended guides. Use the terrain and route notes to identify locations.") }
            }
            Section("Dino & Boss") {
                if case .success(let catalogue) = map.creatures {
                    Text("\(catalogue.spawnRegistryEntries) map registry entries + \(catalogue.wikiSupplementEntries) Wiki supplement entries. Variants are counted separately; event and mod creatures are not automatically treated as regular spawns.")
                    Text("\(catalogue.creatures.filter(\.detailAvailable).count) profiles have species details; the remaining profiles state that details are unavailable. Map catalogs and species stats come from sources, rather than measurements of your Single Player save.")
                }
                Text("Single Player settings, difficulty, mods and game version can change the experience. Some Wiki data refers to Evolved; use the identified Ascended tables and read notes when sources conflict.")
            }
            Section("Personal app") {
                Text("Ascended 0.5.1 (6) · " + map.name)
                Text("Logos and artwork belong to Studio Wildcard and the credited sources. This personal companion stores data and notes offline on iPad. Reference links require a connection. Notes, checklists and progress are saved separately for each map; deleting the app removes local data.")
            }
        }
    }
}
