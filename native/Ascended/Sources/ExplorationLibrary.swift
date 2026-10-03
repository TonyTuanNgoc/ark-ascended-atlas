import SwiftUI

struct GPSPoint: Decodable, Identifiable {
    let id: String; let label: String; let lat: Double; let lon: Double
    var coordinates: String { String(format: "LAT %.2f · LON %.2f", lat, lon) }
}
struct ArtifactRecord: Decodable, Identifiable {
    let id: String; let name: String; let lat: Double; let lon: Double
    let routeID: String; let imageAsset: String; let sourceURL: String
    var coordinates: String { String(format: "LAT %.2f · LON %.2f", lat, lon) }
    var route: CaveRoute? { ExplorationData.catalog?.routes.first { $0.id == routeID } }
}
struct CaveRoute: Decodable, Identifiable {
    let id: String; let name: String; let artifactIDs: [String]; let entrances: [GPSPoint]
    let boss: String; let notes: String; let kit: [String]; let sourceURL: String; let entranceSourceURL: String
    let imageAsset: String; let imageCaption: String
    var artifacts: [ArtifactRecord] { ExplorationData.catalog?.artifacts.filter { artifactIDs.contains($0.id) } ?? [] }
}
struct ExplorationCatalog: Decodable {
    let reviewedAt: String; let artifacts: [ArtifactRecord]; let routes: [CaveRoute]; let obelisks: [GPSPoint]
}
enum ExplorationData {
    static let catalog: ExplorationCatalog? = {
        guard let url = Bundle.main.url(forResource: "ragnarok-exploration", withExtension: "json"), let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(ExplorationCatalog.self, from: data)
    }()
}

struct ExplorationLibrary: View {
    @State private var search = ""
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Text("Artifact & Hang").font(.largeTitle.bold())
                Text("10 artifact · 6 tuyến khám phá · Ragnarok Ascended").font(.headline).foregroundStyle(.cyan)
                Text("GPS artifact là điểm lấy vật phẩm. GPS cửa hang là lối tiếp cận, không phải vị trí artifact. Tọa độ cửa hang theo hướng dẫn cộng đồng có thể lệch vài phần mười; dùng địa hình để nhận diện.").foregroundStyle(.secondary)
                ForEach((ExplorationData.catalog?.routes ?? []).filter { search.isEmpty || $0.name.localizedStandardContains(search) || $0.artifacts.contains { $0.name.localizedStandardContains(search) } }) { route in
                    NavigationLink(value: GuideDestination.cave(route.id)) {
                        VStack(alignment: .leading, spacing: 14) {
                            Image(route.imageAsset).resizable().scaledToFill().frame(height: 170).clipped().clipShape(RoundedRectangle(cornerRadius: 14))
                            Text(route.name).font(.title2.bold()).foregroundStyle(.primary)
                            Text(route.artifacts.map { $0.name.replacingOccurrences(of: "Artifact of the ", with: "") }.joined(separator: " · ")).foregroundStyle(.cyan)
                            HStack {
                                Text(route.entrances.first?.coordinates ?? "Biển sâu · không có cửa hang").font(.subheadline).foregroundStyle(.secondary)
                                Spacer(); Image(systemName: "chevron.right")
                            }.contentShape(Rectangle())
                        }.cardStyle()
                    }.buttonStyle(.plain).accessibilityIdentifier("route-" + route.id)
                }
                Text("Strong đã chuyển sang Wyvern Cave phía nam. Brute không nằm trong 10 artifact hiện tại của Ragnarok Ascended.").font(.caption).foregroundStyle(.secondary)
            }.padding(24).frame(maxWidth: 1100).frame(maxWidth: .infinity)
        }.searchable(text: $search, prompt: "Tìm hang hoặc artifact")
            .background(Color(red: 0.025, green: 0.045, blue: 0.065))
    }
}
struct CaveRouteDetail: View {
    let route: CaveRoute
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Image(route.imageAsset).resizable().scaledToFit().clipShape(RoundedRectangle(cornerRadius: 20))
                Text(route.imageCaption).font(.caption).foregroundStyle(.secondary)
                Text(route.name).font(.largeTitle.bold())
                Text(route.notes).textSelection(.enabled).cardStyle()
                VStack(alignment: .leading, spacing: 14) {
                    Text("Artifact trong tuyến").font(.title2.bold())
                    ForEach(route.artifacts) { artifact in
                        NavigationLink(value: GuideDestination.artifact(artifact.id)) {
                            HStack(spacing: 16) {
                                Image(artifact.imageAsset).resizable().scaledToFit().frame(width: 68, height: 68)
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(artifact.name).font(.headline)
                                    Text(artifact.coordinates).font(.subheadline).foregroundStyle(.cyan)
                                }
                                Spacer(); Image(systemName: "chevron.right")
                            }.contentShape(Rectangle())
                        }.buttonStyle(.plain).accessibilityIdentifier("artifact-" + artifact.id)
                    }
                }.cardStyle()
                VStack(alignment: .leading, spacing: 14) {
                    Text("Cửa hang / lối tiếp cận").font(.title2.bold())
                    if route.entrances.isEmpty { Text("Không có cửa hang: lặn xuống điểm Devourer giữa tàu đắm.") }
                    ForEach(route.entrances) { entrance in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(entrance.label).font(.headline)
                            Text(entrance.coordinates).monospacedDigit().foregroundStyle(.orange).textSelection(.enabled)
                            NavigationLink(value: GuideDestination.map("entrance-" + entrance.id)) { Label("Xem cửa hang trên bản đồ", systemImage: "map") }
                                .accessibilityIdentifier("show-entrance-" + entrance.id)
                        }
                    }
                }.cardStyle()
                GuideChecklist(title: "Chuẩn bị cho tuyến", items: route.kit, key: "cave-" + route.id)
                if !route.boss.isEmpty { Label(route.boss, systemImage: "shield.lefthalf.filled").foregroundStyle(.cyan) }
                VStack(alignment: .leading, spacing: 10) {
                    Text("Đối chiếu 03/10/2026").font(.caption).foregroundStyle(.secondary)
                    Link("Hồ sơ hang & cơ chế", destination: URL(string: route.sourceURL)!)
                    Link("Hướng dẫn cửa hang bản Ascended", destination: URL(string: route.entranceSourceURL)!)
                }.cardStyle()
            }.padding(24).frame(maxWidth: 1000).frame(maxWidth: .infinity)
        }.navigationTitle(route.name).navigationBarTitleDisplayMode(.inline)
    }
}
struct ArtifactDetail: View {
    let artifact: ArtifactRecord
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Image(artifact.imageAsset).resizable().scaledToFit().frame(height: 160).frame(maxWidth: .infinity)
                Text(artifact.name).font(.largeTitle.bold())
                VStack(alignment: .leading, spacing: 12) {
                    Text("Vị trí artifact").font(.headline)
                    Text(artifact.coordinates).font(.title2.bold()).monospacedDigit().foregroundStyle(.cyan).textSelection(.enabled)
                    Text("Điểm GPS lấy artifact, không phải cửa hang. LAT tăng về phía nam; LON tăng về phía đông.").font(.caption).foregroundStyle(.secondary)
                    NavigationLink(value: GuideDestination.map("artifact-" + artifact.id)) { Label("Xem artifact trên bản đồ", systemImage: "map") }
                        .accessibilityIdentifier("show-artifact-" + artifact.id)
                }.cardStyle()
                if let route = artifact.route {
                    NavigationLink(value: GuideDestination.cave(route.id)) { Label("Hang & đường vào · " + route.name, systemImage: "mountain.2.fill") }.cardStyle()
                }
                Text("Nunatak cần 1 artifact này cho mỗi lần triệu hồi ở cả Gamma, Beta và Alpha.").cardStyle()
                Toggle("Đã lấy artifact này", isOn: completion).accessibilityIdentifier("collected-" + artifact.id).cardStyle()
                Text("Danh sách đánh dấu của anh; bỏ đánh dấu sau khi dùng để triệu hồi. Nếu Single Player chưa có artifact, hãy để khu vực được tải và kiểm tra lại sau; không mặc định rằng artifact đã bị xóa.").font(.caption).foregroundStyle(.secondary)
                Link("Tọa độ spawn Ragnarok Ascended · Wikily", destination: URL(string: "https://wikily.gg/ark-survival-ascended/maps/ragnarok/")!)
                Text("Đối chiếu 03/10/2026 · ảnh vật phẩm Wikily").font(.caption).foregroundStyle(.secondary)
            }.padding(24).frame(maxWidth: 1000).frame(maxWidth: .infinity)
        }.navigationTitle(artifact.name).navigationBarTitleDisplayMode(.inline)
    }
    @AppStorage("ascended.artifacts.collected.v1") private var collected = ""
    private var completion: Binding<Bool> {
        Binding(get: { collected.split(separator: ",").contains(Substring(artifact.id)) }, set: { value in
            var ids = Set(collected.split(separator: ",").map(String.init)); if value { ids.insert(artifact.id) } else { ids.remove(artifact.id) }; collected = ids.sorted().joined(separator: ",")
        })
    }
}
struct GuideChecklist: View {
    let title: String; let items: [String]; let key: String
    @AppStorage("ascended.guide.checklist.v1") private var stored = ""
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title).font(.title2.bold())
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                Toggle(item, isOn: binding(index)).toggleStyle(.checkboxCompat)
            }
        }.cardStyle()
    }
    private func binding(_ index: Int) -> Binding<Bool> {
        let token = key + ":" + String(index)
        return Binding(get: { stored.split(separator: "|").contains(Substring(token)) }, set: { enabled in
            var tokens = Set(stored.split(separator: "|").map(String.init)); if enabled { tokens.insert(token) } else { tokens.remove(token) }; stored = tokens.sorted().joined(separator: "|")
        })
    }
}
struct ChecklistToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button { configuration.isOn.toggle() } label: {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle").foregroundStyle(configuration.isOn ? .cyan : .gray)
                configuration.label.foregroundStyle(.primary); Spacer()
            }.contentShape(Rectangle())
        }.buttonStyle(.plain).accessibilityValue(configuration.isOn ? "Đã chuẩn bị" : "Chưa chuẩn bị")
    }
}
extension ToggleStyle where Self == ChecklistToggleStyle { static var checkboxCompat: ChecklistToggleStyle { ChecklistToggleStyle() } }


enum GuideDestination: Hashable {
    case cave(String), artifact(String), map(String)
    @ViewBuilder var screen: some View {
        switch self {
        case .cave(let id):
            if let route = ExplorationData.catalog?.routes.first(where: { $0.id == id }) { CaveRouteDetail(route: route) }
        case .artifact(let id):
            if let artifact = ExplorationData.catalog?.artifacts.first(where: { $0.id == id }) { ArtifactDetail(artifact: artifact) }
        case .map(let id): RagnarokMapScreen(initialFocus: id)
        }
    }
}
