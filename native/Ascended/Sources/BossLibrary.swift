import SwiftUI

struct RagnarokBoss: Identifiable {
    let id: String
    let name: String
    let kind: String
    let encounter: String
    let location: String
    let summary: String
    let danger: String
    let rewards: String
    let source: String
    static let all: [RagnarokBoss] = [
        .init(id: "nunatak", name: "Nunatak", kind: "Boss chính", encounter: "Đấu trường Nunatak", location: "Triệu hồi tại Obelisk hoặc Supply Crate; đấu trường nằm trong khu băng giá.", summary: "Guardian của Ragnarok Ascended: một Ice Wyvern khổng lồ. Có ba cấp Gamma, Beta và Alpha. Đây là boss thay thế trận Dragon + Manticore của Ragnarok Evolved.", danger: "Đòn băng, đạn từ đuôi và Iceworm được triệu hồi. Cần quản lý đội hình trong lúc boss chuyển giữa bay và tiếp đất.", rewards: "Tiến trình Tek; thông báo ra mắt nhắc đến Tek Sword, Tek Shield và Tek Light. Phần thưởng cụ thể phụ thuộc cấp trận.", source: "https://ark.wiki.gg/wiki/Nunatak"),
        .init(id: "iceworm-queen", name: "Iceworm Queen", kind: "Mini-boss", encounter: "Frozen Dungeon", location: "Ice Queen Labyrinth, đi qua Frozen Dungeon.", summary: "Nữ hoàng Iceworm ở cuối tuyến hang băng. Là một cuộc chạm trán hang động, không phải một cấp Gamma/Beta/Alpha của Nunatak.", danger: "Xuất hiện từ dưới đất và tấn công mạnh ở cự ly gần; lối xuống đấu trường cần được khảo sát trước.", rewards: "Trophy và loot từ sinh vật; phần thưởng hang được theo dõi riêng với phần thưởng boss chính.", source: "https://ark.wiki.gg/wiki/Iceworm_Queen"),
        .init(id: "lava-elemental", name: "Lava Elemental", kind: "Mini-boss", encounter: "Jungle Dungeon", location: "Lava Elemental Arena ở cuối Jungle Dungeon.", summary: "Golem dung nham canh giữ trận cuối trong hang rừng.", danger: "Đá nóng được ném từ xa, dung nham và khoảng trống giữa các điểm đứng. Ưu tiên khảo sát đường di chuyển và vị trí bắn.", rewards: "Tài nguyên và loot trong tuyến dungeon. Không đồng nhất với Tekgram từ trận Nunatak.", source: "https://ark.wiki.gg/wiki/Lava_Elemental"),
        .init(id: "spirit-dire-bear", name: "Spirit Dire Bear", kind: "Mini-boss", encounter: "Life’s Labyrinth", location: "Khu cuối Life’s Labyrinth; cùng nhóm chạm trán với Spirit Direwolf.", summary: "Gấu linh hồn bảo vệ artifact cuối mê cung. Cùng Spirit Direwolf tạo thành một nhóm trận hang, không tính thành hai dungeon khác nhau.", danger: "Các đợt đối thủ tăng sức mạnh. Chuẩn bị đường rút và khả năng giao chiến liên tiếp.", rewards: "Mục tiêu chính của tuyến là các artifact được bảo vệ cuối mê cung.", source: "https://ark.wiki.gg/wiki/Spirit_Direwolf_%26_Spirit_Dire_Bear"),
        .init(id: "spirit-direwolf", name: "Spirit Direwolf", kind: "Mini-boss", encounter: "Life’s Labyrinth", location: "Khu cuối Life’s Labyrinth; cùng nhóm chạm trán với Spirit Dire Bear.", summary: "Sói linh hồn trong tuyến artifact của Life’s Labyrinth.", danger: "Áp lực giao chiến qua nhiều đợt tăng sức mạnh; cần phân biệt với Direwolf thông thường có thể tame.", rewards: "Artifact của tuyến mê cung. Không coi đây là một boss chính có cấp Gamma/Beta/Alpha.", source: "https://ark.wiki.gg/wiki/Spirit_Direwolf_%26_Spirit_Dire_Bear")
    ]
}

struct BossLibrary: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Text("Boss của Ragnarok").font(.largeTitle.bold())
                Text("1 boss chính · 4 mini-boss có tên · 3 nhóm trận hang động")
                    .font(.headline).foregroundStyle(.cyan)
                Text("Boss chính là Nunatak. Iceworm Queen, Lava Elemental và nhóm Spirit Bear + Spirit Wolf là những cuộc chạm trán trong hang. Các biến thể Alpha ngoài tự nhiên nằm trong thư viện Dino.")
                    .foregroundStyle(.secondary)
                ForEach(RagnarokBoss.all) { boss in
                    NavigationLink(value: GuideDestination.boss(boss.id)) {
                        HStack(spacing: 18) {
                            CreatureCutout(asset: boss.id == "nunatak" ? "Nunatak-Gamma" : "Boss-" + boss.id).frame(width: 120, height: 80)
                            VStack(alignment: .leading, spacing: 6) {
                                Text(boss.name).font(.title3.bold()).foregroundStyle(.primary)
                                Text(boss.kind + " · " + boss.encounter).font(.subheadline).foregroundStyle(.secondary)
                            }
                            Spacer(); Image(systemName: "chevron.right").foregroundStyle(.secondary)
                        }.cardStyle()
                    }.buttonStyle(.plain).accessibilityIdentifier("boss-" + boss.id)
                }
            }.padding(24).frame(maxWidth: 1100).frame(maxWidth: .infinity)
        }.background(Color(red: 0.025, green: 0.045, blue: 0.065))
    }
}
struct BossDetail: View {
    let boss: RagnarokBoss
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Label(boss.kind, systemImage: "shield.lefthalf.filled").foregroundStyle(.cyan)
                Text(boss.name).font(.largeTitle.bold())
                CreatureCutout(asset: boss.id == "nunatak" ? "Nunatak-Gamma" : "Boss-" + boss.id).frame(height: boss.id == "nunatak" ? 280 : 160).frame(maxWidth: .infinity)
                NavigationLink(value: GuideDestination.army(boss.id)) { Label("Đội Dino, level & chỉ số chuẩn bị", systemImage: "pawprint.fill") }.accessibilityIdentifier("bossArmy")
                BossKnowledge(boss: boss)
                block("Tổng quan", boss.summary)
                block("Tìm ở đâu", boss.location)
                block("Nguy hiểm cần chuẩn bị", boss.danger)
                block("Mục tiêu & phần thưởng", boss.rewards)
            }.padding(24).frame(maxWidth: 1000).frame(maxWidth: .infinity)
        }.navigationTitle(boss.name).navigationBarTitleDisplayMode(.inline)
            .background(Color(red: 0.025, green: 0.045, blue: 0.065))
    }
    private func block(_ title: String, _ body: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.title2.bold()); VisualBrief(text: body)
        }.cardStyle()
    }
}
