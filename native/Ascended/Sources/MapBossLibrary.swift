import SwiftUI
import UIKit

struct MapBoss: Decodable, Identifiable {
    let id: String; let name: String; let kind: String; let imageAsset: String
    let summary: String; let location: String; let artifactIDs: [String]; let entranceID: String?
    let levels: [Int]; let elements: [Int]; let tribute: [BossTribute]
    let rewardsNote: String; let strategy: [String]; let kit: [String]; let sourceURL: String
}
struct BossTribute: Decodable, Identifiable {
    let name: String; let quantities: [Int]
    var id: String { name }
}
struct MapBossPortrait: View {
    let boss: MapBoss
    var body: some View {
        if UIImage(named: boss.imageAsset) != nil { CreatureCutout(asset: boss.imageAsset) }
        else { Image(systemName: "shield.lefthalf.filled").resizable().scaledToFit().foregroundStyle(.cyan).padding(20) }
    }
}
struct MapBossLibrary: View {
    @Environment(\.arkMap) private var map
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Text("Boss · " + map.name).font(.largeTitle.bold())
                if map == .island {
                    Text("3 separate guardians + Overseer through Tek Cave").font(.headline).foregroundStyle(.cyan)
                    Text("Single Player: Broodmother at the Green Obelisk, Megapithecus at the Blue Obelisk, Dragon at the Red Obelisk; reach Overseer through Tek Cave.").foregroundStyle(.secondary)
                } else if map == .center {
                    Text("2 guardians in one The Center Arena encounter").font(.headline).foregroundStyle(.cyan)
                    Text("Broodmother Lysrix and Megapithecus are summoned together. This map does not include Dragon, Overseer or The Island ascension.").foregroundStyle(.secondary)
                } else if let campaign = map.campaign {
                    VisualBrief(text: campaign.summary).foregroundStyle(.secondary)
                }
                if map.bosses.isEmpty {
                    Text("Detailed ASA tribute and difficulty tables have not been verified for this map yet.").foregroundStyle(.secondary)
                }
                ForEach(map.bosses) { boss in
                    NavigationLink(value: GuideDestination.boss(boss.id)) {
                        HStack(spacing: 18) {
                            MapBossPortrait(boss: boss).frame(width: 110, height: 90)
                            VStack(alignment: .leading, spacing: 7) { Text(boss.name).font(.title3.bold()); Text(boss.kind).font(.subheadline).foregroundStyle(.secondary) }
                            Spacer(); Image(systemName: "chevron.right")
                        }.cardStyle().contentShape(Rectangle())
                    }.buttonStyle(.plain).accessibilityIdentifier("boss-" + boss.id)
                }
            }.padding(24).frame(maxWidth: 1100).frame(maxWidth: .infinity)
        }
    }
}
struct MapBossDetail: View {
    let boss: MapBoss
    @Environment(\.arkMap) private var map
    @State private var difficulty = 0
    private let names = ["Gamma", "Beta", "Alpha"]
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Text(boss.name).font(.largeTitle.bold())
                Text(map.name + " · " + boss.kind).foregroundStyle(.cyan)
                MapBossPortrait(boss: boss).frame(height: 210).frame(maxWidth: .infinity)
                NavigationLink(value: GuideDestination.army(boss.id)) { Label("Creature army, levels & preparation stats", systemImage: "pawprint.fill") }.accessibilityIdentifier("bossArmy")
                VisualBrief(text: boss.summary).cardStyle()
                VStack(alignment: .leading, spacing: 14) {
                    Text("Location & approach").font(.title2.bold()); VisualBrief(text: boss.location)
                    if let id = boss.entranceID { NavigationLink(value: GuideDestination.map(id)) { Label("Show approach on map", systemImage: "map") } }
                    if map == .center { ForEach(map.exploration?.obelisks ?? []) { point in
                        NavigationLink(value: GuideDestination.map(point.id)) { HStack { Text(point.label); GPSBadge(coordinates: point.coordinates); Image(systemName: "map") } }
                    } }
                }.cardStyle()
                VStack(alignment: .leading, spacing: 14) {
                    Text("Requirements · " + names[difficulty]).font(.title2.bold())
                    Picker("Difficulty", selection: $difficulty) { ForEach(0..<3) { Text(names[$0]).tag($0) } }.pickerStyle(.segmented).accessibilityIdentifier("bossDifficulty")
                    Label(String(boss.levels[difficulty]), systemImage: "arrow.up.circle.fill").font(.headline).foregroundStyle(.cyan)
                    if !boss.elements.isEmpty { FactGrid(matches: VisualFacts.matches(String(boss.elements[difficulty]) + " Element")).font(.headline).foregroundStyle(.cyan) }
                    VisualBrief(text: boss.rewardsNote).font(.subheadline).foregroundStyle(.secondary)
                    ForEach(boss.artifactIDs, id: \.self) { id in
                        if let artifact = map.exploration?.artifacts.first(where: { $0.id == id }) {
                            NavigationLink(value: GuideDestination.artifact(id)) {
                                HStack { Image(artifact.imageAsset).resizable().scaledToFit().frame(width: 42, height: 42); Text(artifact.name); Spacer(); Text("×1") }.contentShape(Rectangle())
                            }.buttonStyle(.plain).accessibilityIdentifier("boss-artifact-" + id)
                        }
                    }
                    ForEach(boss.tribute.filter { $0.quantities[difficulty] > 0 }) { item in VisualBrief(text: "\(item.quantities[difficulty]) " + item.name) }
                    if difficulty == 0 && !boss.artifactIDs.isEmpty && !boss.tribute.contains(where: { ($0.quantities.first ?? 0) > 0 }) { Text("Gamma: no additional apex tribute is required beyond the artifact set.").font(.caption) }
                }.cardStyle()
                VStack(alignment: .leading, spacing: 14) { Text("Strategy & limits").font(.title2.bold()); ForEach(boss.strategy, id: \.self) { VisualBrief(text: $0) } }.cardStyle()
                GuideChecklist(title: "Before entering the arena", items: boss.kit, key: boss.id)
            }.padding(24).frame(maxWidth: 1000).frame(maxWidth: .infinity)
        }.navigationTitle(boss.name).navigationBarTitleDisplayMode(.inline)
    }
}
