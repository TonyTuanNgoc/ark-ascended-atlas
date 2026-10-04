import SwiftUI

struct ExpansionCatalog: Decodable {
    let checkedAt: String
    let maps: [ExpansionMap]
    let dlcs: [ExpansionDLC]
    static let shared = (try? ArkMap.load(ExpansionCatalog.self, name: "expansion-catalog")) ?? ExpansionCatalog(checkedAt: "", maps: [], dlcs: [])
}
struct ExpansionMap: Decodable, Identifiable {
    let id, name, group, status, purchase, storeURL, summary, storyRole: String
    let order: Int
    let included: Bool
    let biomes, signatureCreatures, goals, bosses, preparation, dlcIDs, sourceURLs: [String]
}
struct ExpansionDLC: Decodable, Identifiable {
    let id, name, kind, purchase, storeURL, summary: String
    let appliesTo, includedIn, sourceURLs: [String]
    let requiredForStory: Bool
}
struct ExpansionProfile: View {
    let record: ExpansionMap
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Label(record.included ? "Included in ASA" : "Requires DLC", systemImage: record.included ? "checkmark.seal.fill" : "cart.fill").foregroundStyle(record.included ? .cyan : .orange)
            Text(record.purchase).font(.callout)
            Text(record.storyRole).foregroundStyle(.secondary)
            brief("Goals", items: record.goals)
            brief("Preparation", items: record.preparation)
            brief("Boss", items: record.bosses)
            brief("Terrain", items: record.biomes)
            brief("Signature creatures", items: record.signatureCreatures)
            ForEach(ExpansionCatalog.shared.dlcs.filter { record.dlcIDs.contains($0.id) }) { dlc in
                VStack(alignment: .leading, spacing: 5) {
                    Text(dlc.name).font(.headline)
                    Text(dlc.summary).font(.caption)
                    Text(dlc.purchase).font(.caption).foregroundStyle(.secondary)
                    if let url = URL(string: dlc.storeURL) { Link("Steam", destination: url) }
                }
            }
            if let url = URL(string: record.storeURL) { Link(destination: url) { Label("Steam", systemImage: "cart") }.buttonStyle(.bordered) }
        }.accessibilityIdentifier("expansion-profile-" + record.id)
    }
    private func brief(_ title: String, items: [String]) -> some View {
        Group {
            if !items.isEmpty { DisclosureGroup { ForEach(items, id: \.self) { VisualBrief(text: $0).padding(.vertical, 5) } } label: { Text(title).font(.headline) } }
        }
    }
}
struct ExpansionCatalogScreen: View {
    let chooseMap: (ArkMap) -> Void
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ForEach(["story", "extra", "upcoming"], id: \.self) { group in
                    DisclosureGroup {
                        ForEach(ExpansionCatalog.shared.maps.filter { $0.group == group }.sorted { $0.order < $1.order }) { record in
                            DisclosureGroup {
                                if record.status == "available", let map = ArkMap(rawValue: record.id) {
                                    Button { chooseMap(map) } label: { Label("Choose map", systemImage: "map.fill") }.buttonStyle(.borderedProminent)
                                }
                                ExpansionProfile(record: record)
                            } label: {
                                HStack {
                                    MapBadge(id: record.id)
                                    Text(record.name).font(.headline)
                                    Spacer()
                                    Text(record.status == "available" ? (record.included ? "Included in ASA" : "DLC") : record.status == "upcoming" ? "Upcoming" : "Unconfirmed").font(.caption).foregroundStyle(.secondary)
                                }
                            }.padding(.vertical, 8)
                        }
                    } label: { Text(group == "story" ? "Story Maps" : group == "extra" ? "Exploration Maps" : "Unavailable Maps").font(.headline) }.cardStyle()
                }
                DisclosureGroup {
                    ForEach(ExpansionCatalog.shared.dlcs) { dlc in
                        DisclosureGroup {
                            Text(dlc.summary).padding(.vertical, 8)
                            Text(dlc.purchase).foregroundStyle(.secondary)
                            if let url = URL(string: dlc.storeURL) { Link("Steam", destination: url).buttonStyle(.bordered) }
                        } label: { Text(dlc.name).font(.headline) }.padding(.vertical, 8)
                    }
                } label: { Text("Additional paid content").font(.headline) }.cardStyle()
            }.padding(24).frame(maxWidth: 1100).frame(maxWidth: .infinity)
        }
    }
}
