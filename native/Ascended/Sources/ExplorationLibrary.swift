import SwiftUI

struct GPSPoint: Decodable, Identifiable {
    let id: String; let label: String; let lat: Double; let lon: Double; let kind: String?
    var coordinates: String { String(format: "LAT %.2f · LON %.2f", lat, lon) }
}
struct ArtifactRecord: Decodable, Identifiable {
    let id: String; let name: String; let lat: Double; let lon: Double
    let routeID: String; let imageAsset: String; let sourceURL: String
    var coordinates: String { String(format: "LAT %.2f · LON %.2f", lat, lon) }
    func route(in map: ArkMap) -> CaveRoute? { map.exploration?.routes.first { $0.id == routeID } }
}
struct CaveRoute: Decodable, Identifiable {
    let id: String; let name: String; let artifactIDs: [String]; let entrances: [GPSPoint]
    let boss: String; let notes: String; let kit: [String]; let sourceURL: String; let entranceSourceURL: String
    let imageAsset: String; let imageCaption: String
    func artifacts(in map: ArkMap) -> [ArtifactRecord] { map.exploration?.artifacts.filter { artifactIDs.contains($0.id) } ?? [] }
}
struct ExplorationCatalog: Decodable {
    let reviewedAt: String; let artifacts: [ArtifactRecord]; let routes: [CaveRoute]; let obelisks: [GPSPoint]
}

struct ExplorationLibrary: View {
    @Environment(\.arkMap) private var map
    @State private var search = ""
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Text("Artifact & Hang").font(.largeTitle.bold())
                Text("\(map.exploration?.artifacts.count ?? 0) artifact · \(map.exploration?.routes.count ?? 0) tuyến khám phá · " + map.name + " Ascended").font(.headline).foregroundStyle(.cyan)
                Text("GPS artifact là điểm lấy vật phẩm. GPS cửa hang là lối tiếp cận, không phải vị trí artifact. Tọa độ cửa hang theo hướng dẫn cộng đồng có thể lệch vài phần mười; dùng địa hình để nhận diện.").foregroundStyle(.secondary)
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 240, maximum: 340), spacing: 16)], spacing: 16) {
                ForEach((map.exploration?.routes ?? []).filter { search.isEmpty || $0.name.localizedStandardContains(search) || $0.artifacts(in: map).contains { $0.name.localizedStandardContains(search) } }) { route in
                    NavigationLink(value: GuideDestination.cave(route.id)) {
                        SquareGuideTile(title: route.name, subtitle: route.artifacts(in: map).map { $0.name.replacingOccurrences(of: "Artifact of the ", with: "") }.joined(separator: " · "), gps: route.entrances.first?.coordinates ?? "Biển sâu") {
                            Image(route.imageAsset).resizable().scaledToFill()
                        }
                    }.buttonStyle(.plain).accessibilityIdentifier("route-" + route.id)
                }
                }
                Text(map == .ragnarok ? "Strong đã chuyển sang Wyvern Cave phía nam. Brute không nằm trong 10 artifact hiện tại của Ragnarok Ascended." : "Bấm artifact để xem điểm lấy, đánh dấu đã lấy hoặc mở bản đồ. Danh sách dùng dữ liệu Ascended riêng của " + map.name + ".").font(.caption).foregroundStyle(.secondary)
            }.padding(24).frame(maxWidth: 1100).frame(maxWidth: .infinity)
        }.searchable(text: $search, prompt: "Tìm hang hoặc artifact")
            .background(Color(red: 0.025, green: 0.045, blue: 0.065))
    }
}
struct CaveRouteDetail: View {
    @Environment(\.arkMap) private var map
    @State private var showFullVideo = false
    let route: CaveRoute
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Image(route.imageAsset).resizable().scaledToFit().frame(maxHeight: 240).frame(maxWidth: .infinity).clipShape(RoundedRectangle(cornerRadius: 8))
                Text(route.name).font(.largeTitle.bold())
                Text(route.notes).textSelection(.enabled).cardStyle()
                VStack(alignment: .leading, spacing: 14) {
                    Text("Artifact trong tuyến").font(.title2.bold())
                    if route.artifactIDs.isEmpty { Text("Tuyến này không có artifact; đọc điều kiện trophy trong mục Boss.").foregroundStyle(.secondary) }
                    ForEach(route.artifacts(in: map)) { artifact in
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
                    Text("Hang, cửa vào & vùng tiếp cận").font(.title2.bold())
                    if route.entrances.isEmpty { Text("Không có cửa hang trong tuyến này: tiếp cận điểm artifact từ biển; đọc hướng dẫn và chuẩn bị đồ lặn.") }
                    ForEach(route.entrances) { entrance in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(entrance.label).font(.headline)
                            Text(entrance.coordinates).monospacedDigit().foregroundStyle(.orange).textSelection(.enabled)
                            NavigationLink(value: GuideDestination.map("entrance-" + entrance.id)) { Label(entrance.kind == "area" ? "Xem khu vực trên bản đồ" : "Xem cửa hang trên bản đồ", systemImage: "map") }.labelStyle(.iconOnly).accessibilityLabel("Xem cửa hang trên bản đồ")
                                .accessibilityIdentifier("show-entrance-" + entrance.id)
                        }
                    }
                }.cardStyle()
                GuideChecklist(title: "Chuẩn bị cho tuyến", items: route.kit, key: "cave-" + route.id)
                if !route.boss.isEmpty { Label(route.boss, systemImage: "shield.lefthalf.filled").foregroundStyle(.cyan) }
                if let video = map.caveVideos.first(where: { $0.routeID == route.id }) {
                    Button {
                        showFullVideo.toggle()
                    } label: {
                        HStack {
                            Label("Video đầy đủ", systemImage: "play.rectangle")
                            Spacer()
                            Image(systemName: showFullVideo ? "chevron.up" : "chevron.down")
                        }.contentShape(Rectangle())
                    }.buttonStyle(.plain)
                        .accessibilityIdentifier("full-cave-video-" + route.id)
                        .accessibilityValue(showFullVideo ? "Đã mở" : "Đã đóng")
                    if showFullVideo { CaveVideoTimeline(guide: video) }
                }
                if let guide = map.caveGIFs.first(where: { $0.routeID == route.id }) {
                    CaveGIFWalkthrough(guide: guide).id(map.rawValue + route.id)
                }
            }.padding(24).frame(maxWidth: 1000).frame(maxWidth: .infinity)
        }.navigationTitle(route.name).navigationBarTitleDisplayMode(.inline)
    }
}
struct ArtifactDetail: View {
    @Environment(\.arkMap) private var map
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
                    NavigationLink(value: GuideDestination.map("artifact-" + artifact.id)) { Label("Xem artifact trên bản đồ", systemImage: "map") }.labelStyle(.iconOnly).accessibilityLabel("Xem Artifact trên bản đồ")
                        .accessibilityIdentifier("show-artifact-" + artifact.id)
                }.cardStyle()
                if let route = artifact.route(in: map) {
                    NavigationLink(value: GuideDestination.cave(route.id)) { Label("Hang & đường vào · " + route.name, systemImage: "mountain.2.fill") }.labelStyle(.iconOnly).accessibilityLabel("Hang và đường vào").cardStyle()
                }
                Text(map == .ragnarok ? "Nunatak cần 1 artifact này cho mỗi lần triệu hồi ở cả Gamma, Beta và Alpha." : "Mục Boss ghi rõ artifact này thuộc bộ tribute nào. Không phải mọi artifact trên map đều dùng trong mỗi trận.").cardStyle()
                Toggle("Đã lấy artifact này", isOn: completion).accessibilityIdentifier("collected-" + artifact.id).cardStyle()
                Text("Danh sách đánh dấu của anh; bỏ đánh dấu sau khi dùng để triệu hồi. Nếu Single Player chưa có artifact, hãy để khu vực được tải và kiểm tra lại sau; không mặc định rằng artifact đã bị xóa.").font(.caption).foregroundStyle(.secondary)
            }.padding(24).frame(maxWidth: 1000).frame(maxWidth: .infinity)
        }.navigationTitle(artifact.name).navigationBarTitleDisplayMode(.inline)
    }
    private var collected: String { UserDefaults.standard.string(forKey: map.collectedKey) ?? "" }
    @State private var collectionRevision = 0
    private var completion: Binding<Bool> {
        Binding(get: { _ = collectionRevision; return collected.split(separator: ",").contains(Substring(artifact.id)) }, set: { value in
            var ids = Set(collected.split(separator: ",").map(String.init)); if value { ids.insert(artifact.id) } else { ids.remove(artifact.id) }; UserDefaults.standard.set(ids.sorted().joined(separator: ","), forKey: map.collectedKey); collectionRevision += 1
        })
    }
}
struct GuideChecklist: View {
    @Environment(\.arkMap) private var map
    let title: String; let items: [String]; let key: String
    private var stored: String { UserDefaults.standard.string(forKey: map.checklistKey) ?? "" }
    @State private var checklistRevision = 0
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
        return Binding(get: { _ = checklistRevision; return stored.split(separator: "|").contains(Substring(token)) }, set: { enabled in
            var tokens = Set(stored.split(separator: "|").map(String.init)); if enabled { tokens.insert(token) } else { tokens.remove(token) }; UserDefaults.standard.set(tokens.sorted().joined(separator: "|"), forKey: map.checklistKey); checklistRevision += 1
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
    case cave(String), artifact(String), map(String), boss(String), army(String), base(String), preparation
    var screen: some View { GuideDestinationScreen(destination: self) }
}
struct GuideDestinationScreen: View {
    let destination: GuideDestination
    @Environment(\.arkMap) private var map
    @ViewBuilder var body: some View {
        switch destination {
        case .cave(let id):
            if let route = map.exploration?.routes.first(where: { $0.id == id }) { CaveRouteDetail(route: route) }
        case .artifact(let id):
            if let artifact = map.exploration?.artifacts.first(where: { $0.id == id }) { ArtifactDetail(artifact: artifact) }
        case .army(let id): BossArmyScreen(bossID: id)
        case .preparation: BossPreparationScreen()
        case .base(let id):
            if let spot = map.bases?.locations.first(where: { $0.id == id }) { BaseLocationDetail(spot: spot) }
        case .map(let id): MapScreen(initialFocus: id)
        case .boss(let id):
            if map == .ragnarok, let boss = RagnarokBoss.all.first(where: { $0.id == id }) { BossDetail(boss: boss) }
            else if let boss = map.bosses.first(where: { $0.id == id }) { MapBossDetail(boss: boss) }
        }
    }
}
