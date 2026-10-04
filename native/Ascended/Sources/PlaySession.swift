import SwiftUI

struct PlaySessionScreen: View {
    @Environment(\.arkMap) private var map
    let openBosses: () -> Void
    @State private var routeID = ""
    private var key: String { "ascended.\(map.rawValue).session.route.v1" }
    private var routes: [CaveRoute] { map.exploration?.routes ?? [] }
    private var route: CaveRoute? { routes.first { $0.id == routeID } ?? routes.first }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Hôm nay chinh phục gì?").font(.largeTitle.bold()).accessibilityIdentifier("session-title")
                Text(map.name + " · Chuẩn bị → lên đường → lấy artifact → trở về").foregroundStyle(.cyan)
                if let route {
                    VStack(alignment: .leading, spacing: 16) {
                        Label("Lấy artifact", systemImage: "diamond.fill").font(.title2.bold())
                        Picker("Chọn tuyến", selection: $routeID) {
                            ForEach(routes) { Text($0.name).tag($0.id) }
                        }.pickerStyle(.menu).accessibilityIdentifier("session-route")
                        Text(route.name).font(.headline)
                        if let entrance = route.entrances.first {
                            Text("Đi tới: " + entrance.coordinates).monospacedDigit()
                            NavigationLink(value: GuideDestination.map("entrance-" + entrance.id)) { Label("Tìm cửa hang", systemImage: "map.fill") }
                        }
                        if map == .ragnarok && route.id == "jungle" {
                            NavigationLink(value: GuideDestination.navigator) { Label("Bắt đầu dẫn đường Hunter", systemImage: "location.north.line.fill") }
                                .buttonStyle(.borderedProminent).accessibilityIdentifier("session-navigate")
                            Text("Lấy Hunter không cần đánh Lava Golem. Để flyer ngoài cửa; vào bằng đường bộ.").foregroundStyle(.secondary)
                        } else {
                            NavigationLink(value: GuideDestination.cave(route.id)) { Label("Mở đường đi & GIF", systemImage: "play.rectangle.fill") }.buttonStyle(.borderedProminent)
                        }
                        NavigationLink(value: GuideDestination.cave(route.id)) { Label("Xem toàn tuyến", systemImage: "list.bullet.rectangle") }
                    }.cardStyle()
                    GuideChecklist(title: "Xong đồ rồi mới xuất phát", items: route.kit, key: "cave-" + route.id).id(route.id)
                }
                if let spots = map.bases?.locations {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Xây căn cứ", systemImage: "house.fill").font(.title2.bold())
                        Text("Chọn vị trí → xem đường tiếp cận → dựng theo bố cục của điểm đó.")
                        ForEach(spots.sorted { $0.rank < $1.rank }) { spot in
                            NavigationLink(value: GuideDestination.base(spot.id)) { Text("\(spot.rank). " + spot.name) }
                        }
                    }.cardStyle()
                }
                Button(action: openBosses) {
                    HStack { Label("Chuẩn bị boss tiếp theo", systemImage: "shield.lefthalf.filled"); Spacer(); Image(systemName: "chevron.right") }
                }.buttonStyle(.plain).cardStyle().accessibilityIdentifier("session-bosses")
            }.padding(24).frame(maxWidth: 1000).frame(maxWidth: .infinity)
        }.onAppear { routeID = UserDefaults.standard.string(forKey: key) ?? routes.first?.id ?? "" }
            .onChange(of: routeID) { _, value in UserDefaults.standard.set(value, forKey: key) }
    }
}

struct JungleLandmark: Identifiable {
    let id: Int
    let name: String
    let clips: [Int]
    static let all: [Self] = [
        .init(id: 0, name: "Cửa hang", clips: [0]),
        .init(id: 1, name: "Lối đá · cây xanh", clips: [1, 2]),
        .init(id: 2, name: "Nhánh gỗ qua vực", clips: [3, 4]),
        .init(id: 3, name: "Hành lang cam", clips: [6]),
        .init(id: 4, name: "Cầu dung nham", clips: [7, 8]),
        .init(id: 5, name: "Mép đá · móc qua", clips: [9, 10]),
        .init(id: 6, name: "Vòng ngoài khu loot", clips: [11, 12]),
        .init(id: 7, name: "Sau thác dung nham", clips: [13]),
        .init(id: 8, name: "Artifact Hunter", clips: [14, 15])
    ]
}

struct JungleNavigator: View {
    @AppStorage("ascended.ragnarok.jungle.confirmed.v1") private var confirmed = -1
    @State private var selected = 0
    @State private var clip = 0
    @State private var returning = false
    @State private var visible = false
    @State private var yaw: Double = 0
    @State private var scale: CGFloat = 1
    @Environment(\.scenePhase) private var scenePhase
    private let landmarks = JungleLandmark.all
    private var steps: [CaveGIFStep] { ArkMap.ragnarok.caveGIFs.first { $0.routeID == "jungle" }?.sections.first?.steps ?? [] }
    private var landmark: JungleLandmark { landmarks[selected] }
    private var next: Int? { returning ? (confirmed > 0 ? confirmed - 1 : nil) : (confirmed < 8 ? confirmed + 1 : nil) }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Jungle Dungeon · Hunter").font(.title.bold())
                Text(confirmed < 0 ? "Chưa xác nhận vị trí" : "Anh đang ở: " + landmarks[max(0, min(8, confirmed))].name)
                    .font(.headline).foregroundStyle(.cyan).accessibilityIdentifier("navigator-location")
                HStack {
                    Toggle("Đường về", isOn: $returning).toggleStyle(.switch).accessibilityIdentifier("navigator-return")
                    Spacer()
                    Button { selected = 0; clip = 0; confirmed = -1; returning = false } label: { Image(systemName: "arrow.counterclockwise") }
                        .accessibilityLabel("Bắt đầu chuyến mới").accessibilityIdentifier("navigator-reset")
                }
                Text(returning ? "Đối chiếu các mốc theo thứ tự ngược để về cửa. GIF bên dưới quay chiều đi vào; chưa có video riêng chiều về." : "Tiếp theo: " + (next.map { landmarks[$0].name } ?? "Đã tới Hunter — lấy artifact rồi chọn Đường về."))
                    .accessibilityIdentifier("navigator-next")
                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .top, spacing: 20) {
                        diagramPanel.frame(width: 280)
                        clipPanel.frame(width: 440)
                    }
                    VStack(alignment: .leading, spacing: 18) { clipPanel; diagramPanel }
                }
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(returning ? Array(landmarks.reversed()) : landmarks) { point in
                            Button { select(point.id) } label: {
                                VStack(alignment: .leading, spacing: 8) {
                                    if steps.indices.contains(point.clips[0]), let poster = steps[point.clips[0]].posterImage {
                                        Image(uiImage: poster).resizable().scaledToFill().frame(width: 126, height: 66).clipped().clipShape(RoundedRectangle(cornerRadius: 5))
                                    }
                                    Text("\(point.id + 1)").font(.headline)
                                    Text(point.name).font(.subheadline.bold()).frame(height: 44, alignment: .topLeading)
                                    Image(systemName: confirmed == point.id ? "location.fill" : "play.rectangle")
                                }.frame(width: 126, alignment: .leading).padding(12)
                                    .background(selected == point.id ? Color.cyan.opacity(0.2) : Color.white.opacity(0.05)).clipShape(RoundedRectangle(cornerRadius: 8))
                            }.buttonStyle(.plain).accessibilityIdentifier("waypoint-\(point.id)")
                        }
                    }
                }
                Text("Chỉ bấm khi cảnh trong game khớp mốc đang xem. Xem GIF hoặc chọn mốc không đổi vị trí đã xác nhận.").font(.caption).foregroundStyle(.secondary)
                if let artifact = ArkMap.ragnarok.exploration?.artifacts.first(where: { $0.id == "hunter" }) {
                    NavigationLink(value: GuideDestination.artifact(artifact.id)) { Label("Đã cầm Hunter? Mở để đánh dấu đã lấy", systemImage: "diamond.fill") }
                }
            }.padding(24).frame(maxWidth: 1000).frame(maxWidth: .infinity)
        }.safeAreaInset(edge: .bottom) {
            Button {
                confirmed = selected
                if let next { select(next) }
            } label: {
                Label("Anh đã tới: " + landmark.name, systemImage: "checkmark.circle.fill")
                    .frame(maxWidth: .infinity).padding(8)
            }.buttonStyle(.borderedProminent).padding(12).background(.ultraThinMaterial)
                .accessibilityIdentifier("navigator-confirm")
        }.navigationTitle("Dẫn đường Hunter")
            .onAppear { select(max(0, min(8, confirmed))); visible = true }
            .onDisappear { visible = false }
            .onChange(of: returning) { _, _ in select(max(0, min(8, confirmed))) }
    }
    private var diagramPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
                    Text("Chạm mốc để xem · kéo để xoay · chụm để zoom").font(.subheadline)
                    waypointDiagram.frame(height: 180).clipped()
                    Text("Sơ đồ liên kết mốc, không biểu diễn kích thước hay hình dạng thật của hang. Vị trí do anh xác nhận.").font(.caption).foregroundStyle(.secondary)
                }.cardStyle()
    }
    private var clipPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\(selected + 1) · " + landmark.name).font(.title2.bold()).accessibilityIdentifier("navigator-selected")
                if steps.indices.contains(clip) {
                    let step = steps[clip]
                    if visible && scenePhase == .active, let url = step.gifURL {
                        AutoCaveGIF(step: step, url: url).id(step.gif).aspectRatio(16/9, contentMode: .fit).frame(maxWidth: 640)
                            .accessibilityIdentifier("navigator-gif").accessibilityLabel(step.title)
                    } else if let poster = step.posterImage { Image(uiImage: poster).resizable().scaledToFit().frame(maxWidth: 640) }
                    Text(step.title).font(.headline)
                    if let direction = step.direction { Text(direction).fixedSize(horizontal: false, vertical: true) }
                    HStack {
                        ForEach(landmark.clips, id: \.self) { index in
                            Button(steps.indices.contains(index) ? steps[index].title : "") { clip = index }.buttonStyle(.bordered)
                        }
                    }
                    if selected == 2 {
                        Button("Nếu trượt xuống: xem cách móc trở lại") { clip = 5 }.buttonStyle(.bordered).accessibilityIdentifier("navigator-recovery")
                    }
                }
        }
    }
    private func select(_ id: Int) { selected = id; clip = landmarks[id].clips[0] }
    private func position(_ id: Int, size: CGSize) -> CGPoint {
        // Abstract layout only: one plane, no invented elevations or surveyed distances.
        let x = Double(id % 3 - 1) * 0.25
        let z = Double(id / 3 - 1) * 0.27
        let rx = x * cos(yaw) - z * sin(yaw)
        let rz = x * sin(yaw) + z * cos(yaw)
        return CGPoint(x: size.width / 2 + CGFloat(rx) * size.width * scale, y: size.height / 2 + CGFloat(rz) * size.height * scale)
    }
    private var waypointDiagram: some View {
        GeometryReader { geometry in
            ZStack {
                Path { path in
                    for point in landmarks {
                        let position = position(point.id, size: geometry.size)
                        if point.id == 0 { path.move(to: position) } else { path.addLine(to: position) }
                    }
                }.stroke(Color.cyan.opacity(0.5), style: StrokeStyle(lineWidth: 3, dash: [6, 4]))
                ForEach(landmarks) { point in
                    Button { select(point.id) } label: {
                        Text("\(point.id + 1)").font(.headline).frame(width: 38, height: 38)
                            .background(confirmed == point.id ? Color.orange : selected == point.id ? Color.cyan : Color(white: 0.17))
                            .foregroundStyle(selected == point.id || confirmed == point.id ? .black : .white).clipShape(Circle())
                    }.accessibilityLabel(point.name).accessibilityIdentifier("diagram-waypoint-\(point.id)").position(position(point.id, size: geometry.size))
                }
            }.contentShape(Rectangle())
                .simultaneousGesture(DragGesture().onChanged { yaw = $0.translation.width / 100 })
                .simultaneousGesture(MagnifyGesture().onChanged { scale = min(1.4, max(0.65, $0.magnification)) })
        }
    }
}
