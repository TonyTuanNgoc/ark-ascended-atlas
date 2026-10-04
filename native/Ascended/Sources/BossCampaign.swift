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
    func bossName(_ id: String) -> String { self == .ragnarok ? RagnarokBoss.all.first { $0.id == id }?.name ?? id : bosses.first { $0.id == id }?.name ?? id }
    func bossImage(_ id: String) -> String { id == "nunatak" ? "Nunatak-Gamma" : "Boss-" + id }
}

struct BossCampaignScreen: View {
    @Environment(\.arkMap) private var map
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Text("Lộ trình Boss").font(.largeTitle.bold()).accessibilityIdentifier("bossCampaignTitle")
                Text(map.name + " · Single Player").font(.headline).foregroundStyle(.cyan)
                if map == .ragnarok { Text("1 boss chính · 4 mini-boss có tên · 3 nhóm trận hang động").font(.caption).foregroundStyle(.secondary) }
                if let campaign = map.campaign {
                    Text(campaign.summary).font(.title3).cardStyle()
                    NavigationLink(value: GuideDestination.preparation) {
                        Label("Level, breed, imprint & cách lên điểm", systemImage: "graduationcap.fill").font(.headline).frame(maxWidth: .infinity, alignment: .leading).padding(8).contentShape(Rectangle())
                    }.cardStyle().accessibilityIdentifier("bossPreparation")
                    ForEach(campaign.steps) { step in
                        VStack(alignment: .leading, spacing: 16) {
                            Text(step.kind.uppercased()).font(.caption.bold()).foregroundStyle(.cyan)
                            Text(step.title).font(.title2.bold()).accessibilityIdentifier("boss-step-" + step.id)
                            Text(step.reason).foregroundStyle(.secondary)
                            ForEach(step.bossIDs, id: \.self) { id in
                                HStack(spacing: 18) {
                                    CreatureAvatar(asset: map.bossImage(id)).frame(width: 100, height: 80)
                                    VStack(alignment: .leading, spacing: 10) {
                                        NavigationLink(value: GuideDestination.boss(id)) { Label(map.bossName(id), systemImage: "chevron.right") }.accessibilityIdentifier("boss-" + id)
                                        NavigationLink(value: GuideDestination.army(id)) { Label("Đội Dino & chỉ số chuẩn bị", systemImage: "pawprint.fill") }.accessibilityIdentifier("army-" + id)
                                    }.font(.headline)
                                    Spacer(minLength: 0)
                                }.padding(.vertical, 6)
                            }
                        }.cardStyle()
                    }
                    Text("Thứ tự gợi ý do em tổng hợp; gate trophy và trận chung được nêu riêng. Nguồn thực chiến nằm trong từng bộ đội, không coi chỉ số diễn đàn là minimum chắc thắng.").font(.caption).foregroundStyle(.secondary)
                } else { Text("Chưa tải được lộ trình của map này.") }
            }.padding(24).frame(maxWidth: 1100).frame(maxWidth: .infinity)
        }.background(Color(red: 0.025, green: 0.045, blue: 0.065))
    }
}
struct BossPreparationScreen: View {
    @Environment(\.arkMap) private var map
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Xây đội boss").font(.largeTitle.bold())
                Text(map.name + " · level không thay thế HP / melee / saddle").foregroundStyle(.cyan)
                ForEach(Array((map.campaign?.sharedPreparation ?? []).enumerated()), id: \.offset) { index, text in
                    VStack(alignment: .leading, spacing: 10) { Text("\(index + 1)").font(.title2.bold()).foregroundStyle(.cyan); Text(text).textSelection(.enabled) }.cardStyle()
                }
                EvidenceLinks(sources: [GuideEvidence(title: "Wiki · Single Player Settings", url: "https://ark.wiki.gg/wiki/Server_configuration", note: "Các hệ số Single Player có thể nhân thêm vào giá trị đã đặt."), GuideEvidence(title: "Wiki · Deinosuchus changelog", url: "https://ark.wiki.gg/wiki/Deinosuchus", note: "Patch73.13 loại bleed khỏi boss; phân biệt Deinosuchus với Deinonychus.")])
            }.padding(24).frame(maxWidth: 1000).frame(maxWidth: .infinity)
        }.navigationTitle("Breed & lên điểm")
    }
}
struct BossArmyScreen: View {
    let bossID: String
    @Environment(\.arkMap) private var map
    @State private var selected = 0
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Text("Đội hình · " + map.bossName(bossID)).font(.largeTitle.bold()).accessibilityIdentifier("armyTitle")
                Text(map.name + " · đối chiếu 03/10/2026").foregroundStyle(.cyan)
                if let guide = map.campaign?.loadouts.first(where: { $0.bossID == bossID }), !guide.options.isEmpty {
                    Text(guide.entry).cardStyle()
                    if !guide.warning.isEmpty { Label(guide.warning, systemImage: "exclamationmark.bubble").foregroundStyle(.orange).cardStyle() }
                    Picker("Chọn đội hình", selection: $selected) {
                        ForEach(Array(guide.options.enumerated()), id: \.offset) { index, option in Text(option.title).tag(index) }
                    }.pickerStyle(.menu).accessibilityIdentifier("armyOptions")
                    Text("\(guide.options.count) phương án · chọn đội hình để xem chi tiết").font(.caption).foregroundStyle(.secondary).accessibilityIdentifier("armyOptionCount")
                    let option = guide.options[min(selected, guide.options.count - 1)]
                    VStack(alignment: .leading, spacing: 14) {
                        if UIImage(named: option.imageAsset) != nil { CreatureAvatar(asset: option.imageAsset).frame(height: 150).frame(maxWidth: .infinity) }
                        Text(option.title).font(.title2.bold()).accessibilityIdentifier("armyOptionTitle")
                        Text(option.team).font(.headline).foregroundStyle(.cyan)
                        Text(option.why)
                    }.cardStyle()
                    VStack(alignment: .leading, spacing: 18) {
                        Text("Mốc chuẩn bị sau imprint & lên XP").font(.title2.bold())
                        Text("Mục tiêu lập kế hoạch, không phải minimum đã thử trên save anh. HP / melee là của attacker; support có chú thích riêng.").font(.subheadline).foregroundStyle(.secondary)
                        ForEach(option.targets) { target in
                            VStack(alignment: .leading, spacing: 12) {
                                Text(target.difficulty).font(.headline).foregroundStyle(.cyan)
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 180), alignment: .leading)], alignment: .leading, spacing: 14) {
                                    stat("HP", target.hp); stat("Melee", target.melee); stat("Saddle armor", target.saddle)
                                }
                                if !target.extra.isEmpty { Text(target.extra).font(.subheadline).foregroundStyle(.secondary) }
                            }.padding(16).background(.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 14))
                        }
                    }.cardStyle()
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Điều khiển & rủi ro").font(.title2.bold()); Text(option.play)
                        Text(option.confidence).font(.caption).foregroundStyle(.orange)
                    }.cardStyle()
                    NavigationLink(value: GuideDestination.preparation) { Label("Cách chọn level, breed và lên điểm", systemImage: "graduationcap.fill") }
                    EvidenceLinks(sources: guide.sources)
                    NavigationLink(value: GuideDestination.boss(bossID)) { Label("Hồ sơ, tribute & đường tới boss", systemImage: "shield.lefthalf.filled") }
                } else { Text("Chưa có đội hình cho boss này.") }
            }.padding(24).frame(maxWidth: 1000).frame(maxWidth: .infinity)
        }.navigationTitle("Đội Dino").navigationBarTitleDisplayMode(.inline)
    }
    private func stat(_ name: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 5) { Text(name).font(.caption).foregroundStyle(.secondary); Text(value).font(.headline).textSelection(.enabled) }.frame(maxWidth: .infinity, alignment: .leading)
    }
}
struct EvidenceLinks: View {
    let sources: [GuideEvidence]
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Nguồn & độ tin cậy").font(.title2.bold())
            ForEach(sources) { source in
                VStack(alignment: .leading, spacing: 8) {
                    if let url = URL(string: source.url) { Link(source.title, destination: url) }
                    Text(source.note).font(.subheadline).foregroundStyle(.secondary)
                }
            }
        }.cardStyle()
    }
}
