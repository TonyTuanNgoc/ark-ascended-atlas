import SwiftUI

struct BossKnowledge: View {
    let boss: RagnarokBoss
    var body: some View {
        if boss.id == "nunatak" { NunatakGuide() }
        else {
            let routeID = boss.id == "iceworm-queen" ? "frozen" : boss.id == "lava-elemental" ? "jungle" : "labyrinth"
            if let route = ArkMap.ragnarok.exploration?.routes.first(where: { $0.id == routeID }) {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Đường tới boss").font(.title2.bold())
                    Text(boss.id == "lava-elemental" ? "Khu arena tham khảo: LAT 21.60 · LON 26.90. Đây là vùng cuối Jungle Dungeon, không phải cửa hang." : "Đi qua " + route.name + " tới nhóm trận cuối. GPS dưới đây là cửa vào, chưa coi là GPS chính xác của boss trong arena.")
                    ForEach(route.entrances) { Text($0.label + " · " + $0.coordinates).font(.subheadline).foregroundStyle(.orange) }
                    NavigationLink("Mở hồ sơ hang & artifact", value: GuideDestination.cave(route.id))
                        .accessibilityIdentifier("bossCaveRoute")
                    NavigationLink("Xem lối tới boss trên bản đồ", value: GuideDestination.map(boss.id == "lava-elemental" ? "boss-lava-arena" : "entrance-" + (route.entrances.first?.id ?? "")))
                }.cardStyle()
                if boss.id == "iceworm-queen" {
                    info("Cơ chế & chỉ số tham khảo", "Nữ hoàng xuất hiện khi xuống cuối thác vào arena; cần xuống khi không cưỡi tame. Không tame, không cưỡi, không breed; miễn torpor. Bảng Wiki ghi HP 27.000 và melee nền 500 ở mốc tối thiểu level 10; số thực tế còn phụ thuộc level và settings, không phải phép đo save Single Player của anh.")
                    info("Giao chiến", "Giữ khoảng cách sau lúc boss trồi lên, vì hitbox rộng và bản Ascended nhanh hơn. Shotgun / vũ khí tầm xa tốt, khiên và thuốc hồi máu là phương án dự phòng. Solo phải tự quản lý cả sát thương lẫn né đòn; chiến thuật người tank + người bắn chỉ dành cho nhóm.")
                    info("Thu hoạch & mục tiêu", "Đi tiếp tới Pack trong khu tổ. Bản Ascended có Iceworm Queen Trophy riêng. Wiki còn liệt kê Deathworm Horn, AnglerGel, Black Pearl, Leech Blood, Organic Polymer và vật liệu từ xác; bảng chung có mục của Evolved nên không coi mọi skin/trophy trong đó là drop chắc chắn của ASA.")
                    GuideChecklist(title: "Bộ đồ đấu Iceworm Queen", items: ["Fur tốt + Fria Curry / Otter", "Shotgun, đạn và vũ khí dự phòng", "Khiên + Medical Brew", "Hồi đầy máu trước khi xuống thác", "Khảo sát lối ra và đường tới Pack"], key: boss.id)
                } else if boss.id == "lava-elemental" {
                    info("Cơ chế & chỉ số tham khảo", "Trận loot tùy chọn. Wiki ghi mốc level 10: HP 60.000, melee nền 120; level và settings làm thay đổi sức mạnh thực tế. Không tame, không cưỡi, không breed; miễn torpor. Hunter lấy được mà không cần thắng trận này.")
                    info("Vũ khí & vị trí bắn", "Ưu tiên Rocket Launcher và grapples để tìm vị trí cao, tránh sát mép. Wiki ghi đạn thường và melee bị giảm mạnh; Tek Rifle là lựa chọn sau khi có Tekgram. Chuẩn bị nhiều rocket và launcher dự phòng, tránh tự gây sát thương ở cự ly gần.")
                    info("Đòn đánh & điểm yếu", "Đá dung nham ném từ xa, sát thương lửa và melee có thể đẩy anh xuống hồ lava. nhắm tay/cánh tay và tận dụng điểm cao; không coi địa hình là bảo đảm boss không đánh trúng. Tuyệt đối giữ đường rút khỏi dung nham.")
                    info("Loot", "Crystal, Metal, Obsidian, Oil, Stone, Sulfur cùng trang bị/saddle hoặc blueprint. Chất lượng và số lượng loot phụ thuộc settings/phiên bản; không dùng khoảng chất lượng của bảng Evolved như cam kết cho ASA.")
                    GuideChecklist(title: "Bộ đồ đấu Lava Elemental", items: ["Rocket + nhiều launcher dự phòng", "Grappling Hook và dây", "Giáp, Medical Brew, đồ sửa", "Xác định bệ đứng và đường thoát lava", "Lấy Hunter trước nếu mục tiêu là artifact"], key: boss.id)
                } else {
                    info("Nhóm trận linh hồn", "Spirit Dire Bear và Spirit Direwolf cùng thuộc Life’s Labyrinth. các cặp xuất hiện theo đợt từ level 50, tăng 50 tới 250. Không lấy chỉ số Dire Bear / Direwolf thông thường làm HP của những đối thủ này.")
                    info("Kích hoạt & hoàn tất", "Tuyến có phòng hiến tế và cơ chế riêng. Khi tới khu cuối, nếu spirit chưa xuất hiện, tác động vào Megaloceros sau khi đã giải cơ chế trước đó. Khi các spirit được hạ, thông báo The spirits have calmed xuất hiện và đường tới artifact mở. Kiểm tra cơ chế trên thế giới của anh trước khi hiến tế tame có giá trị.")
                    info("Chuẩn bị solo", "Vũ khí tầm xa, giáp/khiên dự phòng, Medical Brew, nguồn sáng và SCUBA. Khảo sát bẫy và đường đi trước khi giao chiến; các đợt sau gây áp lực lớn hơn. Không dựa vào grapple/flyer để bỏ qua toàn bộ mê cung: các cách leo/bay bị hạn chế ở đây.")
                    GuideChecklist(title: "Bộ đồ cho nhóm Spirit", items: ["Shotgun, đạn và vũ khí dự phòng", "Giáp/khiên + thuốc", "SCUBA và nguồn sáng", "Parachute cho parkour", "Đọc cơ chế phòng hiến tế trước khi vào"], key: "spirit-group")
                }
            }
        }
    }
    private func info(_ title: String, _ text: String) -> some View {
        VStack(alignment: .leading, spacing: 12) { Text(title).font(.title2.bold()); Text(text).foregroundStyle(.secondary).textSelection(.enabled) }.cardStyle()
    }
}

struct NunatakGuide: View {
    @State private var difficulty = 0
    private let levels = ["Gamma", "Beta", "Alpha"]
    private let health = ["650.000", "950.000", "1.250.000"]
    private let elements = [100, 275, 550]
    private let tribute = ["Argentavis Talon", "Basilosaurus Blubber", "Megalania Toxin", "Megalodon Tooth", "Sarcosuchus Skin", "Sauropod Vertebra", "Spinosaurus Sail", "Thylacoleo Hook-Claw", "Titanoboa Venom", "Tusoteuthis Tentacle"]
    private let gammaTek = ["Tek Replicator", "Small Tek Teleporter", "Tek Behemoth Cellar Door", "Tek Behemoth Gate", "Tek Behemoth Gateway", "Tek Gauntlets", "Tek Generator", "Tek Leggings", "Tek Light", "Megalodon Tek Saddle", "Rex Tek Saddle", "Tapejara Tek Saddle", "Tek Trough"]
    private let betaAdds = ["Medium Tek Teleporter", "Tek Dedicated Storage", "Tek Doors & Windows", "Tek Fence Foundation & Support", "Tek Forcefield", "Tek Rifle", "Tek Roof, Ramp & Stairs", "Tek Sword", "Tek Transmitter", "Vacuum Compartment & Moonpool"]
    private let alphaAdds = ["Large Tek Teleporter", "Tek Chestpiece", "Tek Cloning Chamber", "Tek Grenade", "Tek Shield"]
    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Độ khó & phần thưởng").font(.title2.bold())
                Picker("Độ khó", selection: $difficulty) { ForEach(0..<3) { index in Text(levels[index]).tag(index) } }.pickerStyle(.segmented).accessibilityIdentifier("bossDifficulty")
                Image("Nunatak-" + levels[difficulty]).resizable().scaledToFit().frame(maxHeight: 280).frame(maxWidth: .infinity)
                HStack(alignment: .top) {
                    fact("HP nền", health[difficulty]); Spacer(); fact("Level vào trận", String([70,80,90][difficulty])); Spacer(); fact("Element", String(elements[difficulty]))
                }
                Text("HP nền, chưa áp dụng điều chỉnh Single Player. Phần thưởng còn có Nunatak Flag và trophy đúng cấp. Không tame, không cưỡi, không breed; miễn torpor.").font(.caption).foregroundStyle(.secondary)
            }.cardStyle()
            VStack(alignment: .leading, spacing: 14) {
                Text("Điểm triệu hồi Nunatak").font(.title2.bold())
                Text("Nunatak không đi lang thang ở một tọa độ ngoài bản đồ. Mang tribute tới Obelisk; trận diễn ra trong arena được dịch chuyển tới. Với Single Player, ưu tiên Obelisk và kiểm tra cổng trong game.")
                ForEach(ArkMap.ragnarok.exploration?.obelisks ?? []) { point in
                    NavigationLink(value: GuideDestination.map(point.id)) {
                        HStack { Text(point.label); Spacer(); Text(point.coordinates).monospacedDigit().foregroundStyle(.cyan); Image(systemName: "map") }
                    }.accessibilityIdentifier("summon-" + point.id)
                }
            }.cardStyle()
            VStack(alignment: .leading, spacing: 14) {
                Text("Tribute · " + levels[difficulty]).font(.title2.bold())
                Text("10 artifact bên dưới · mỗi loại ×1").font(.headline).foregroundStyle(.cyan)
                ForEach(ArkMap.ragnarok.exploration?.artifacts ?? []) { artifact in
                    NavigationLink(value: GuideDestination.artifact(artifact.id)) {
                        HStack {
                            Image(artifact.imageAsset).resizable().scaledToFit().frame(width: 36, height: 36)
                            Text(artifact.name); Spacer(); Text("×1")
                        }.contentShape(Rectangle())
                    }.buttonStyle(.plain)
                }
                Text(difficulty == 0 ? "Gamma không cần các trophy nguyên liệu bên dưới." : "Thêm các nguyên liệu sau, mỗi loại ×" + String(difficulty == 1 ? 10 : 25)).font(.subheadline).foregroundStyle(.orange)
                if difficulty > 0 { ForEach(tribute, id: \.self) { item in HStack { Text(item); Spacer(); Text(difficulty == 1 ? "×10" : "×25").monospacedDigit() } } }
            }.cardStyle()
            VStack(alignment: .leading, spacing: 14) {
                Text("Tekgram · " + levels[difficulty]).font(.title2.bold())
                Text("Cấp cao gồm các unlock của cấp thấp.").font(.caption).foregroundStyle(.secondary)
                ForEach(gammaTek + (difficulty > 0 ? betaAdds : []) + (difficulty > 1 ? alphaAdds : []), id: \.self) { Text("• " + $0) }
            }.cardStyle()
            VStack(alignment: .leading, spacing: 12) {
                Text("Nhịp giao chiến").font(.title2.bold())
                Text("Khi boss bay: dùng vũ khí tầm xa, xử lý các đợt Iceworm và giữ đội hình. Khi boss tiếp đất: tập trung damage; Nunatak không gọi Iceworm trong lúc ở mặt đất. Hơi băng làm chậm kết hợp minion gây áp lực lớn; nhiệt độ arena cũng cần tính vào bộ đồ.")
                Text("Rex / Therizino là lựa chọn phổ biến; Yutyrannus hỗ trợ courage, Daeodon hồi máu cần đủ food. Therizino có thể dùng Sweet Vegetable Cake. Chuẩn bị tame đã breed/imprint và saddle tốt; không áp một ngưỡng HP/damage chung cho mọi settings.")
            }.cardStyle()
            VStack(alignment: .leading, spacing: 12) {
                Text("Giới hạn & rủi ro trận").font(.title2.bold())
                Text("Không mang flyer vào arena. Quy tắc arena: tối đa 20 tame và 10 survivor; cart gắn trên tame có thể ngăn dịch chuyển. Timer hiện trên game là nguồn quyết định của save anh, vì Single Player/non-dedicated có khác biệt. Chết hoặc hết giờ có thể mất tame và đồ; xếp đội hình trong vùng cổng trước khi bấm.")
            }.cardStyle()
            GuideChecklist(title: "Trước khi triệu hồi", items: ["Đủ 10 artifact và tribute đúng cấp", "Toàn đội hồi đầy HP / food", "Saddle, imprint và đội hình đã kiểm tra", "Shotgun + đạn, giáp lạnh dự phòng", "Medical Brew, food, nước", "Tame hỗ trợ có đủ food/cake", "Kiểm tra giới hạn tame, gỡ cart, đứng trong cổng", "Đọc timer và settings của save"], key: "nunatak")
        }
    }
    private func fact(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 5) { Text(title).font(.caption).foregroundStyle(.secondary); Text(value).font(.title3.bold()).foregroundStyle(.cyan) }
    }
}
