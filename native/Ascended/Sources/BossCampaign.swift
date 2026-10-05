import SwiftUI
import UIKit

struct BossCampaign: Decodable {
    let summary: String
    let sharedPreparation: [String]
    let steps: [BossCampaignStep]
    let loadouts: [BossArmyGuide]
}
struct BossCampaignStep: Decodable, Identifiable {
    let id: String; let title: String; let reason: String; let bossIDs: [String]; let kind: String
}
struct BossArmyGuide: Decodable {
    let bossID: String; let entry: String; let warning: String
    let options: [BossArmyOption]; let sources: [GuideEvidence]
}
struct GuideEvidence: Decodable, Identifiable {
    let title: String; let url: String; let note: String
    var id: String { title + url }
}
struct BossArmyOption: Decodable, Identifiable {
    let id: String; let title: String; let team: String; let why: String
    let targets: [ArmyTarget]; let play: String; let confidence: String; let imageAsset: String
}
struct ArmyTarget: Decodable, Identifiable {
    let difficulty: String; let hp: String; let melee: String; let saddle: String; let extra: String
    var id: String { difficulty }
}
extension ArkMap {
    var campaign: BossCampaign? { Self.campaigns[self] ?? nil }
    private static let campaigns = Dictionary(uniqueKeysWithValues: allCases.map { ($0, try? load(BossCampaign.self, name: $0.rawValue + "-campaign")) })
    func bossName(_ id: String) -> String { self == .ragnarok ? RagnarokBoss.all.first { $0.id == id }?.name ?? id : bosses.first { $0.id == id }?.name ?? id.replacingOccurrences(of: "-", with: " ").capitalized }
    func bossImage(_ id: String) -> String { id == "nunatak" ? "Nunatak-Gamma" : "Boss-" + id }
}

struct BossCampaignScreen: View {
    @Environment(\.arkMap) private var map
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Text("Boss campaign").font(.largeTitle.bold()).accessibilityIdentifier("bossCampaignTitle")
                if map == .ragnarok { Text("1 main boss · 4 named mini-bosses · 3 dungeon encounter groups").font(.caption).foregroundStyle(.secondary) }
                if let campaign = map.campaign {
                    VisualBrief(text: campaign.summary).cardStyle()
                    NavigationLink(value: GuideDestination.preparation) {
                        Label("Levels, breeding, imprinting & stat allocation", systemImage: "graduationcap.fill").font(.headline).frame(maxWidth: .infinity, alignment: .leading).padding(8).contentShape(Rectangle())
                    }.cardStyle().accessibilityIdentifier("bossPreparation")
                    ForEach(campaign.steps) { step in
                        VStack(alignment: .leading, spacing: 16) {
                            Text(step.kind.uppercased()).font(.caption.bold()).foregroundStyle(.cyan)
                            Text(step.title).font(.title2.bold()).accessibilityIdentifier("boss-step-" + step.id)
                            VisualBrief(text: step.reason)
                            ForEach(step.bossIDs, id: \.self) { id in
                                HStack(spacing: 18) {
                                    CreatureCutout(asset: map.bossImage(id)).frame(width: 100, height: 80)
                                    VStack(alignment: .leading, spacing: 10) {
                                        if map.bosses.contains(where: { $0.id == id }) || map == .ragnarok {
                                            NavigationLink(value: GuideDestination.boss(id)) { Label(map.bossName(id), systemImage: "chevron.right") }.accessibilityIdentifier("boss-" + id)
                                        } else {
                                            Text(map.bossName(id)).font(.headline)
                                            Text("Detailed ASA requirements are being verified.").font(.caption).foregroundStyle(.secondary)
                                        }
                                        if campaign.loadouts.contains(where: { $0.bossID == id && !$0.options.isEmpty }) {
                                            NavigationLink(value: GuideDestination.army(id)) { Label("Creature army & preparation stats", systemImage: "pawprint.fill") }.labelStyle(.iconOnly).accessibilityLabel("Creature army & preparation stats").frame(width: 44, height: 44).accessibilityIdentifier("army-" + id)
                                        }
                                    }.font(.headline)
                                    Spacer(minLength: 0)
                                }.padding(.vertical, 6)
                            }
                        }.cardStyle()
                    }
                } else if let record = map.expansion { ExpansionProfile(record: record).cardStyle() }
            }.padding(24).frame(maxWidth: 1100).frame(maxWidth: .infinity)
        }.background(Color(red: 0.025, green: 0.045, blue: 0.065))
    }
}
struct BossPreparationScreen: View {
    @Environment(\.arkMap) private var map
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Build your boss army").font(.largeTitle.bold())
                Text(map.name + " · level does not replace HP / melee / saddles").foregroundStyle(.cyan)
                ForEach(Array((map.campaign?.sharedPreparation ?? []).enumerated()), id: \.offset) { index, text in
                    VStack(alignment: .leading, spacing: 10) { Text("\(index + 1)").font(.title2.bold()).foregroundStyle(.cyan); VisualBrief(text: text) }.cardStyle()
                }
            }.padding(24).frame(maxWidth: 1000).frame(maxWidth: .infinity)
        }.navigationTitle("Breeding & stat allocation")
    }
}
struct BossArmyScreen: View {
    let bossID: String
    @Environment(\.arkMap) private var map
    @State private var selected = 0
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Text("Army · " + map.bossName(bossID)).font(.largeTitle.bold()).accessibilityIdentifier("armyTitle")
                Text(map.name).foregroundStyle(.cyan)
                if let guide = map.campaign?.loadouts.first(where: { $0.bossID == bossID }), !guide.options.isEmpty {
                    VisualBrief(text: guide.entry).cardStyle()
                    Picker("Choose army", selection: $selected) {
                        ForEach(Array(guide.options.enumerated()), id: \.offset) { index, option in Text(option.title).tag(index) }
                    }.pickerStyle(.menu).accessibilityIdentifier("armyOptions")
                    Text("\(guide.options.count) options · choose an army to see details").font(.caption).foregroundStyle(.secondary).accessibilityIdentifier("armyOptionCount")
                    let option = guide.options[min(selected, guide.options.count - 1)]
                    VStack(alignment: .leading, spacing: 14) {
                        if UIImage(named: option.imageAsset) != nil { CreatureCutout(asset: option.imageAsset).frame(height: 150).frame(maxWidth: .infinity) }
                        Text(option.title).font(.title2.bold()).accessibilityIdentifier("armyOptionTitle")
                        VisualTeam(text: option.team)
                        VisualBrief(text: option.why)
                    }.cardStyle()
                    VStack(alignment: .leading, spacing: 18) {
                        Text("Preparation targets after imprinting & XP leveling").font(.title2.bold())
                        ForEach(option.targets) { target in
                            VStack(alignment: .leading, spacing: 12) {
                                Text(target.difficulty).font(.headline).foregroundStyle(.cyan)
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 180), alignment: .leading)], alignment: .leading, spacing: 14) {
                                    stat("HP", target.hp); stat("Melee", target.melee); stat("Saddle armor", target.saddle)
                                }
                                if !target.extra.isEmpty { VisualBrief(text: target.extra) }
                            }.padding(16).background(.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 14))
                        }
                    }.cardStyle()
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Controls & risks").font(.title2.bold()); VisualBrief(text: option.play)
                    }.cardStyle()
                    NavigationLink(value: GuideDestination.preparation) { Label("Choosing levels, breeding and stat allocation", systemImage: "graduationcap.fill") }
                    if map.bosses.contains(where: { $0.id == bossID }) || map == .ragnarok {
                        NavigationLink(value: GuideDestination.boss(bossID)) { Label("Profile, tribute & route to the boss", systemImage: "shield.lefthalf.filled") }
                    }
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Evidence & limits").font(.title2.bold())
                        ForEach(guide.sources, id: \.url) { source in
                            if let url = URL(string: source.url) { Link(source.title, destination: url) }
                            VisualBrief(text: source.note).font(.caption)
                        }
                    }.cardStyle()
                } else { Text("No army guide is available for this boss yet.") }
            }.padding(24).frame(maxWidth: 1000).frame(maxWidth: .infinity)
        }.navigationTitle("Creature army").navigationBarTitleDisplayMode(.inline)
    }
    private func stat(_ name: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 5) { Label(name, systemImage: VisualFacts.symbol(for: name)).labelStyle(.iconOnly).accessibilityLabel(name).foregroundStyle(.cyan); Text(value).font(.headline).textSelection(.enabled) }.frame(maxWidth: .infinity, alignment: .leading)
    }
}
// Research provenance is retained in bundled data and developer reports.
struct EvidenceLinks: View {
    let sources: [GuideEvidence]
    var body: some View { EmptyView() }
}
