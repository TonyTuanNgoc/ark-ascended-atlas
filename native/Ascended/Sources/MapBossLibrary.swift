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
        if UIImage(named: boss.imageAsset) != nil { CreatureAvatar(asset: boss.imageAsset) }
        else { Image(systemName: "shield.lefthalf.filled").resizable().scaledToFit().foregroundStyle(.cyan).padding(20) }
    }
}
struct MapBossLibrary: View {
    @Environment(\.arkMap) private var map
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Text("Boss · " + map.name).font(.largeTitle.bold())
                Text(map == .island ? "3 guardian riêng + Overseer qua Tek Cave" : "2 guardian trong cùng trận The Center Arena").font(.headline).foregroundStyle(.cyan)
                Text(map == .island ? "Single Player: Broodmother ở Green Obelisk, Megapithecus ở Blue Obelisk, Dragon ở Red Obelisk; Overseer qua Tek Cave." : "Broodmother Lysrix và Megapithecus cùng được triệu hồi. Không có Dragon, Overseer hoặc ascension của The Island trên map này.").foregroundStyle(.secondary)
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
                NavigationLink(value: GuideDestination.army(boss.id)) { Label("Đội Dino, level & chỉ số chuẩn bị", systemImage: "pawprint.fill") }.accessibilityIdentifier("bossArmy")
                VisualBrief(text: boss.summary).cardStyle()
                VStack(alignment: .leading, spacing: 14) {
                    Text("Địa điểm & đường vào").font(.title2.bold()); VisualBrief(text: boss.location)
                    if let id = boss.entranceID { NavigationLink(value: GuideDestination.map(id)) { Label("Xem điểm tiếp cận trên bản đồ", systemImage: "map") } }
                    if map == .center { ForEach(map.exploration?.obelisks ?? []) { point in
                        NavigationLink(value: GuideDestination.map(point.id)) { HStack { Text(point.label); GPSBadge(coordinates: point.coordinates); Image(systemName: "map") } }
                    } }
                }.cardStyle()
                VStack(alignment: .leading, spacing: 14) {
                    Text("Điều kiện · " + names[difficulty]).font(.title2.bold())
                    Picker("Độ khó", selection: $difficulty) { ForEach(0..<3) { Text(names[$0]).tag($0) } }.pickerStyle(.segmented).accessibilityIdentifier("bossDifficulty")
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
                    if difficulty == 0 && !boss.artifactIDs.isEmpty { Text("Gamma: không cần apex tribute thêm ngoài bộ artifact.").font(.caption) }
                }.cardStyle()
                VStack(alignment: .leading, spacing: 14) { Text("Chiến thuật & giới hạn").font(.title2.bold()); ForEach(boss.strategy, id: \.self) { VisualBrief(text: $0) } }.cardStyle()
                GuideChecklist(title: "Trước khi vào trận", items: boss.kit, key: boss.id)
            }.padding(24).frame(maxWidth: 1000).frame(maxWidth: .infinity)
        }.navigationTitle(boss.name).navigationBarTitleDisplayMode(.inline)
    }
}
