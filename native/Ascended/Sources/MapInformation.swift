import SwiftUI
import UIKit

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
struct InformationTopic: Identifiable {
    let id, title, symbol: String
    let items: [String]
    var preview: String { items.first ?? "" }
    var illustrations: [FactMatch] {
        var seen = Set<String>()
        return items.filter { VisualFacts.isInventory($0) }.flatMap { VisualFacts.matches($0) }
            .filter { seen.insert($0.id).inserted }
    }
}

struct InformationTopicCard: View {
    let topic: InformationTopic
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                if let match = topic.illustrations.first {
                    FactPicture(fact: match.fact).frame(width: 54, height: 48)
                } else {
                    Image(systemName: topic.symbol).font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(.cyan).frame(width: 54, height: 48)
                }
                Spacer()
                Image(systemName: "chevron.right").font(.caption.bold()).foregroundStyle(.secondary)
            }
            Text(topic.title).font(.title3.bold()).foregroundStyle(.primary)
            Text(topic.preview).font(.subheadline).foregroundStyle(.secondary).lineLimit(3)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("\(topic.items.count) " + (topic.items.count == 1 ? "entry" : "entries"))
                .font(.caption.weight(.medium)).foregroundStyle(.cyan)
        }.frame(maxWidth: .infinity, minHeight: 180, alignment: .topLeading).cardStyle()
            .contentShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct InformationTopicDetail: View {
    let topic: InformationTopic
    var mapID: String? = nil
    @Environment(\.arkMap) private var selectedMap
    private var map: ArkMap { mapID.flatMap(ArkMap.init(rawValue:)) ?? selectedMap }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                HStack(spacing: 16) {
                    MapBadge(id: map.expansionID, width: 112, height: 72)
                    VStack(alignment: .leading, spacing: 6) {
                        Text(map.name).font(.caption.bold()).foregroundStyle(.cyan)
                        Text(topic.title).font(.largeTitle.bold())
                    }
                }
                ForEach(Array(topic.items.enumerated()), id: \.offset) { index, text in
                    VStack(alignment: .leading, spacing: 14) {
                        Text(String(format: "%02d", index + 1)).font(.caption.bold()).foregroundStyle(.cyan)
                        VisualBrief(text: text)
                    }.frame(maxWidth: .infinity, alignment: .leading).cardStyle()
                }
            }.padding(24).frame(maxWidth: 1000).frame(maxWidth: .infinity)
        }.navigationTitle(topic.title).navigationBarTitleDisplayMode(.inline)
            .background(Color(red: 0.025, green: 0.045, blue: 0.065))
            .accessibilityIdentifier("information-detail-" + topic.id)
    }
}

struct MapInformationScreen: View {
    @Environment(\.arkMap) private var map
    let openMap: () -> Void
    let openDinos: () -> Void
    let openBosses: () -> Void
    @State private var search = ""
    private var sections: [InformationTopic] {
        (map.information?.sections ?? []).map { section in
            let labels: [String: (String, String)] = [
                "identity": ("Map identity", "globe.americas.fill"), "geography": ("Landscape & biomes", "mountain.2.fill"),
                "resources": ("Resources & logistics", "hammer.fill"), "creatures": ("Creatures & availability", "pawprint.fill"),
                "caves": ("Artifacts & cave routes", "diamond.fill"), "bosses": ("Boss progression", "shield.lefthalf.filled"),
                "notes": ("Explorer Notes & Dossiers", "book.closed.fill"), "base": ("Choosing a base", "house.fill"),
                "phases": ("Suggested progression", "flag.checkered"), "settings": ("Single Player settings", "slider.horizontal.3"),
                "coordinates": ("Reading coordinates", "location.fill")]
            let label = labels[section.id] ?? (section.title, "info.circle.fill")
            return InformationTopic(id: section.id, title: label.0, symbol: label.1, items: section.items)
        }.filter { search.isEmpty || ($0.title + " " + $0.items.joined(separator: " ")).localizedStandardContains(search) }
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                ZStack(alignment: .bottomLeading) {
                    GeometryReader { proxy in
                        Image(map.imageAsset).resizable().scaledToFill().frame(width: proxy.size.width, height: proxy.size.height).clipped()
                    }
                    LinearGradient(colors: [.black.opacity(0.1), .black.opacity(0.95)], startPoint: .top, endPoint: .bottom)
                    VStack(alignment: .leading, spacing: 12) {
                        Text(map == .genesisOcean ? "GENESIS PART 1 · OCEAN BIOME" : "MAP OVERVIEW").font(.caption.bold()).foregroundStyle(.cyan)
                        HStack(spacing: 16) {
                            MapBadge(id: map.expansionID, width: 112, height: 72)
                            Text(map.name).font(.system(size: 42, weight: .bold, design: .rounded)).accessibilityIdentifier("mapInformationTitle")
                        }
                        Text(map.summary).font(.callout).foregroundStyle(.white.opacity(0.85)).fixedSize(horizontal: false, vertical: true)
                    }.padding(24)
                }.frame(height: 310).clipShape(RoundedRectangle(cornerRadius: 24))
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 14) {
                    metric("\((try? map.creatures.get().creatures.count) ?? 0)", "Creature entries", "pawprint.fill")
                    metric("\(map.exploration?.artifacts.count ?? 0)", "Artifact entries", "diamond.fill")
                    metric(map == .ragnarok ? "5" : "\(map.bosses.isEmpty ? (map.expansion?.bosses.count ?? 0) : map.bosses.count)", "Boss entries", "shield.lefthalf.filled")
                }
                if map == .genesisOcean {
                    Text("Ocean is a biome within Genesis Part 1. The goals, preparation, and boss progression below describe the full Genesis map.")
                        .font(.callout).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
                }
                HStack(spacing: 12) {
                    Button(action: openMap) { Label("Open map", systemImage: "map.fill") }.accessibilityIdentifier("openRagnarokMap")
                    Button(action: openDinos) { Label("Creatures", systemImage: "pawprint.fill") }.accessibilityIdentifier("openDinos")
                    Button(action: openBosses) { Label("Boss campaign", systemImage: "shield.lefthalf.filled") }.accessibilityIdentifier("openBosses")
                }.buttonStyle(.bordered)
                if let record = map.expansion { ExpansionProfile(record: record, search: search) }
                if !sections.isEmpty {
                    Text("Field guide").font(.title2.bold())
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 270), spacing: 16)], alignment: .leading, spacing: 16) {
                        ForEach(sections) { topic in
                            NavigationLink { InformationTopicDetail(topic: topic) } label: { InformationTopicCard(topic: topic) }
                                .buttonStyle(.plain).accessibilityIdentifier("information-" + topic.id)
                        }
                    }
                }
                if let info = map.information, !info.resources.isEmpty,
                   search.isEmpty || "resources".localizedStandardContains(search) || info.resources.contains(where: { $0.name.localizedStandardContains(search) }) {
                    let topic = InformationTopic(id: "resource-index", title: "Resource index", symbol: "shippingbox.fill", items: info.resources.map(\.name))
                    NavigationLink { InformationTopicDetail(topic: topic) } label: { InformationTopicCard(topic: topic) }.buttonStyle(.plain)
                }
            }.padding(24).frame(maxWidth: 1100).frame(maxWidth: .infinity)
        }.searchable(text: $search, prompt: "Search information on " + map.name)
            .background(Color(red: 0.025, green: 0.045, blue: 0.065))
    }
    private func metric(_ value: String, _ label: String, _ symbol: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: symbol).font(.title2).foregroundStyle(.cyan)
            VStack(alignment: .leading, spacing: 5) { Text(value).font(.title.bold()); Text(label).font(.caption).foregroundStyle(.secondary) }
            Spacer(minLength: 0)
        }.cardStyle()
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
                if let image = UIImage(named: map.imageAsset), let pixels = image.cgImage {
                    Text("Bundled terrain image: \(pixels.width) × \(pixels.height) pixels.")
                }
                Text("Terrain and markers use the selected map's atlas dataset. Marker placement follows the atlas coordinate plane; this is not independent calibration against your in-game GPS. Route images are labeled; illustrations are not cave-entrance photographs.")
                if map == .island { Text("The Island's atlas, in-game mini-map, and waypoint coordinates may not align exactly. Artifact coordinates follow the atlas layer; cave entrances follow the identified Ascended guides. Compare terrain and route notes when finding an entrance; exact agreement with your save's GPS has not been verified.") }
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
