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
    var search = ""
    private var topics: [InformationTopic] {
        [InformationTopic(id: "goals", title: "Goals", symbol: "flag.checkered", items: record.goals),
         InformationTopic(id: "preparation", title: "Preparation", symbol: "backpack.fill", items: record.preparation),
         InformationTopic(id: "boss", title: "Boss encounters", symbol: "shield.lefthalf.filled", items: record.bosses),
         InformationTopic(id: "terrain", title: "Terrain & biomes", symbol: "mountain.2.fill", items: record.biomes),
         InformationTopic(id: "signature-creatures", title: "Signature creatures", symbol: "pawprint.fill", items: record.signatureCreatures)]
            .filter { !$0.items.isEmpty && (search.isEmpty || ($0.title + " " + $0.items.joined(separator: " ")).localizedStandardContains(search)) }
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            if search.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Your journey").font(.title2.bold())
                    Text(record.storyRole).font(.callout).fixedSize(horizontal: false, vertical: true)
                    Label(record.included ? "Included in ASA" : "Requires DLC", systemImage: record.included ? "checkmark.seal.fill" : "cart.fill").font(.caption.bold()).foregroundStyle(record.included ? .cyan : .orange)
                    Text(record.purchase).font(.caption).foregroundStyle(.secondary)
                }.frame(maxWidth: .infinity, alignment: .leading).cardStyle()
            }
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 270), spacing: 16)], alignment: .leading, spacing: 16) {
                ForEach(topics) { topic in
                    NavigationLink { InformationTopicDetail(topic: topic, mapID: record.id) } label: { InformationTopicCard(topic: topic) }
                        .buttonStyle(.plain).accessibilityIdentifier("expansion-" + topic.id)
                }
            }
            if search.isEmpty {
                let dlcs = ExpansionCatalog.shared.dlcs.filter { record.dlcIDs.contains($0.id) }
                if !dlcs.isEmpty {
                    NavigationLink {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 20) {
                                ForEach(dlcs) { dlc in
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text(dlc.name).font(.title2.bold())
                                        Text(dlc.summary).fixedSize(horizontal: false, vertical: true)
                                        Text(dlc.purchase).font(.callout).foregroundStyle(.secondary)
                                        if let url = URL(string: dlc.storeURL) { Link("View on Steam", destination: url).buttonStyle(.bordered) }
                                    }.frame(maxWidth: .infinity, alignment: .leading).cardStyle()
                                }
                            }.padding(24).frame(maxWidth: 1000).frame(maxWidth: .infinity)
                        }.navigationTitle("Related content")
                    } label: {
                        InformationTopicCard(topic: InformationTopic(id: "related-content", title: "Related content", symbol: "square.stack.3d.up.fill", items: dlcs.map(\.summary)))
                    }.buttonStyle(.plain)
                }
            }
        }.accessibilityIdentifier("expansion-profile-" + record.id)
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
