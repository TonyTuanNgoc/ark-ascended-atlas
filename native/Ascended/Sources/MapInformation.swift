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
                        Text(map.name).font(.system(size: 46, weight: .bold, design: .rounded)).accessibilityIdentifier("mapInformationTitle")
                    }.padding(24)
                }.frame(height: 310).clipShape(RoundedRectangle(cornerRadius: 22))
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 14) {
                    metric("\((try? map.creatures.get().creatures.count) ?? 0)", "Dino")
                    metric("\(map.exploration?.artifacts.count ?? 0)", "Artifact")
                    metric(map == .ragnarok ? "5" : "\(map.bosses.isEmpty ? (map.expansion?.bosses.count ?? 0) : map.bosses.count)", "Boss")
                }
                HStack {
                    Button(action: openMap) { Label("Mở bản đồ", systemImage: "map.fill") }.labelStyle(.iconOnly).accessibilityLabel("Mở bản đồ").accessibilityIdentifier("openRagnarokMap")
                    Button(action: openDinos) { Label("Dino", systemImage: "pawprint.fill") }.labelStyle(.iconOnly).accessibilityLabel("Dino").accessibilityIdentifier("openDinos")
                    Button(action: openBosses) { Label("Boss", systemImage: "shield.lefthalf.filled") }.labelStyle(.iconOnly).accessibilityLabel("Boss").accessibilityIdentifier("openBosses")
                }.buttonStyle(.bordered)
                if map.information != nil, let record = map.expansion {
                    ExpansionProfile(record: record).cardStyle()
                }
                if let info = map.information {
                    ForEach(info.sections.filter { search.isEmpty || $0.title.localizedStandardContains(search) || $0.items.contains { $0.localizedStandardContains(search) } }) { section in
                        VStack(alignment: .leading, spacing: 14) {
                            Text(section.title).font(.title2.bold())
                            ForEach(section.items, id: \.self) { VisualBrief(text: $0) }
                        }.cardStyle().accessibilityIdentifier("information-" + section.id)
                    }
                    if search.isEmpty || "tài nguyên resources".localizedStandardContains(search) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Tài nguyên").font(.title2.bold())
                            ForEach(info.resources) { resource in VisualBrief(text: resource.name) }
                        }.cardStyle()
                    }
                } else {
                    if let record = map.expansion { ExpansionProfile(record: record).cardStyle() }
                }
            }.padding(24).frame(maxWidth: 1100).frame(maxWidth: .infinity)
        }.searchable(text: $search, prompt: "Tìm thông tin " + map.name)
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
            Section(map.name + " · nguồn dữ liệu") {
                ForEach(map.information?.sources ?? []) { source in
                    if let url = URL(string: source.url) { Link(source.title, destination: url) }
                }
            }
            Section("Hình ảnh & tọa độ") {
                Link("Bản đồ " + map.name + " Ascended · Wikily", destination: URL(string: map.mapURL)!)
                Text("Địa hình 8192 × 8192 từ tile gốc zoom 5; zoom 6 không có trên nguồn đã kiểm tra. Sinh vật, artifact và terminal lấy đúng bộ dữ liệu map đang chọn. Ảnh tuyến được chú thích rõ; không tự coi ảnh minh họa là ảnh cửa hang.")
                if map == .island { Text("The Island có khác biệt giữa hệ mini-map (M một lần) và waypoint (M hai lần). Tọa độ artifact theo lớp Wikily; cửa hang theo hướng dẫn Ascended. Dùng địa hình và chú thích của từng tuyến để nhận diện.") }
            }
            Section("Dino & Boss") {
                if case .success(let catalogue) = map.creatures {
                    Text("\(catalogue.spawnRegistryEntries) mục trong registry của map + \(catalogue.wikiSupplementEntries) mục Wiki bổ sung. Biến thể được đếm riêng; sinh vật sự kiện / mod không được tự gộp thành spawn thường.")
                    Text("\(catalogue.creatures.filter(\.detailAvailable).count) hồ sơ có thông tin loài; các hồ sơ còn lại ghi rõ chưa có chi tiết. Danh mục map và chỉ số loài là dữ liệu nguồn, không phải đo save Single Player.")
                }
                Text("Settings Single Player, difficulty, mods và bản game có thể thay đổi trải nghiệm. Dữ liệu Wiki có phần Evolved; chỉ áp dụng bảng Ascended được nêu và xem chú thích khi nguồn mâu thuẫn.")
            }
            Section("App cá nhân") {
                Text("Ascended 0.5.1 (6) · " + map.name)
                Text("Logo / artwork thuộc Studio Wildcard và nguồn được dẫn. App đồng hành cá nhân; dữ liệu và ghi chú lưu offline trên iPad. Link tham khảo cần mạng. Ghi chú, checklist và tiến độ được lưu riêng từng map; xóa app sẽ xóa dữ liệu cục bộ.")
            }
        }
    }
}
