import SwiftUI

struct GPSPoint: Decodable, Identifiable {
    let id: String; let label: String; let lat: Double; let lon: Double; let kind: String?
    var coordinates: String { String(format: "LAT %.2f · LON %.2f", lat, lon) }
    var isInsideAtlas: Bool { lat.isFinite && lon.isFinite && (0...100).contains(lat) && (0...100).contains(lon) }
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

// Cave-only presentation: atlas entrance photos first, licensed walkthrough frames second.
struct CaveRoutePhoto: View {
    let route: CaveRoute
    let map: ArkMap
    private var photo: AtlasPhoto? {
        let ids = Set(route.entrances.map { "entrance-" + $0.id })
        return AtlasPhoto.all.first { $0.mapID == map.rawValue && ids.contains($0.pointID) }
    }
    var body: some View {
        GeometryReader { geometry in
            Group {
                if let photo, UIImage(named: photo.asset) != nil {
                    Image(photo.asset).resizable().scaledToFill()
                } else if let frame = map.caveGIFs.first(where: { $0.routeID == route.id })?.sections.first?.steps.first?.posterImage {
                    Image(uiImage: frame).resizable().scaledToFill()
                } else if !route.imageAsset.hasPrefix("Map-") {
                    Image(route.imageAsset).resizable().scaledToFill()
                } else {
                    ZStack { Color.white.opacity(0.04); Label("Photo pending", systemImage: "mountain.2").font(.caption).foregroundStyle(.secondary) }
                }
            }.frame(width: geometry.size.width, height: geometry.size.height).clipped()
        }.accessibilityIdentifier("cave-photo-" + route.id)
    }
}

struct ExplorationLibrary: View {
    @Environment(\.arkMap) private var map
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                let unlinked = (map.exploration?.artifacts ?? []).filter { artifact in
                    !(map.exploration?.routes.contains { $0.id == artifact.routeID } ?? false)
                }
                if !unlinked.isEmpty {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 230), spacing: 12)], spacing: 12) {
                        ForEach(unlinked) { artifact in
                            NavigationLink(value: GuideDestination.artifact(artifact.id)) {
                                HStack(spacing: 8) {
                                    Image(artifact.imageAsset).resizable().scaledToFit().frame(width: 28, height: 34)
                                    Text(artifact.name).font(.subheadline.bold()).multilineTextAlignment(.leading)
                                }.frame(maxWidth: .infinity, alignment: .leading).padding(12)
                            }.buttonStyle(.plain).background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
                if map.exploration?.routes.isEmpty == true, map.exploration?.artifacts.isEmpty == true, let record = map.expansion {
                    ExpansionProfile(record: record).cardStyle()
                }
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 180, maximum: 260), spacing: 12)], spacing: 12) {
                    ForEach(map.exploration?.routes ?? []) { route in
                        NavigationLink(value: GuideDestination.cave(route.id)) {
                            VStack(alignment: .leading, spacing: 6) {
                                CaveRoutePhoto(route: route, map: map).frame(height: 85).clipped()
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(route.name).font(.subheadline.bold()).lineLimit(2)
                                    ForEach(route.artifacts(in: map)) { artifact in
                                        HStack(spacing: 5) {
                                            Image(artifact.imageAsset).resizable().scaledToFit().frame(width: 20, height: 24)
                                            Text(artifact.name).font(.system(size: 11, weight: .medium)).fixedSize(horizontal: false, vertical: true)
                                        }
                                    }
                                }.padding(.horizontal, 9).padding(.bottom, 9)
                            }.frame(maxWidth: .infinity, alignment: .leading)
                                .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 12))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }.buttonStyle(.plain).accessibilityIdentifier("route-" + route.id)
                    }
                }
            }.padding(16).frame(maxWidth: 1200).frame(maxWidth: .infinity)
        }.background(Color(red: 0.025, green: 0.045, blue: 0.065))
    }
}

struct CaveRouteAtlas: View {
    let route: CaveRoute
    let map: ArkMap
    @State private var resetToken = UUID()
    private var locations: [MapLocation] {
        MapLocation.all(in: map).filter { $0.routeID == route.id && ($0.layer == .artifact || $0.layer == .cave) }
    }
    var body: some View {
        let size = UIImage(named: map.imageAsset)?.size ?? CGSize(width: 1, height: 1)
        ZoomableMap(imageAsset: map.imageAsset, mapName: map.name, resetToken: resetToken, action: .fit, locations: locations, focusID: nil, select: { _ in })
            .aspectRatio(size.width / max(1, size.height), contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(alignment: .bottomLeading) {
                if let entrance = locations.first(where: { $0.layer == .cave }) {
                    HStack(spacing: 6) {
                        Image(MapLayer.cave.illustration).resizable().scaledToFit().frame(width: 22, height: 22)
                        GPSBadge(coordinates: entrance.coordinates).font(.caption).foregroundStyle(.cyan)
                    }.padding(8).background(.black.opacity(0.82), in: RoundedRectangle(cornerRadius: 9)).padding(8)
                }
            }
            .accessibilityIdentifier("cave-route-map-" + route.id)
    }
}

struct CaveRouteDetail: View {
    @Environment(\.arkMap) private var map
    @State private var showFullVideo = false
    let route: CaveRoute
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(route.name).font(.system(size: 32, weight: .bold)).accessibilityIdentifier("cave-detail-name")
                HStack(alignment: .top, spacing: 18) {
                    VStack(alignment: .leading, spacing: 10) {
                        CaveRoutePhoto(route: route, map: map).frame(height: 145).clipShape(RoundedRectangle(cornerRadius: 12))
                        ForEach(route.artifacts(in: map)) { artifact in
                            HStack(spacing: 10) {
                                Image(artifact.imageAsset).resizable().scaledToFit().frame(width: 32, height: 38)
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(artifact.name).font(.subheadline.bold())
                                    GPSBadge(coordinates: artifact.coordinates).font(.caption).foregroundStyle(.cyan)
                                }
                            }
                        }
                    }.frame(maxWidth: .infinity, alignment: .leading)
                    CaveRouteAtlas(route: route, map: map).frame(maxWidth: .infinity)
                }
                if let guide = map.caveGIFs.first(where: { $0.routeID == route.id }) {
                    CaveGIFWalkthrough(guide: guide).id(map.rawValue + route.id)
                }
                RoutePreparation(items: route.kit)
                if let video = map.caveVideos.first(where: { $0.routeID == route.id }) {
                    Button { showFullVideo.toggle() } label: {
                        HStack { Label("Source video", systemImage: "play.rectangle"); Spacer(); Image(systemName: showFullVideo ? "chevron.up" : "chevron.down") }
                    }.buttonStyle(.plain).accessibilityIdentifier("full-cave-video-" + route.id)
                        .accessibilityValue(showFullVideo ? "Expanded" : "Collapsed")
                    if showFullVideo { CaveVideoTimeline(guide: video) }
                } else if let reference = AtlasReferenceLocations.references(in: map).first(where: { $0.routeID == route.id }),
                          let link = reference.walkthroughURL, let url = URL(string: link) {
                    Link(destination: url) { Label("Watch source walkthrough", systemImage: "play.rectangle.fill") }.accessibilityIdentifier("walkthrough-" + route.id)
                }
            }.padding(18).frame(maxWidth: 1100).frame(maxWidth: .infinity)
        }.navigationTitle("").navigationBarTitleDisplayMode(.inline)
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
                    Text("Artifact location").font(.headline)
                    GPSBadge(coordinates: artifact.coordinates).font(.title2.bold()).monospacedDigit().foregroundStyle(.cyan).textSelection(.enabled)
                    NavigationLink(value: GuideDestination.map("artifact-" + artifact.id)) { Label("Show artifact on map", systemImage: "map") }.labelStyle(.iconOnly).accessibilityLabel("Show artifact on map")
                        .accessibilityIdentifier("show-artifact-" + artifact.id)
                }.cardStyle()
                if let route = artifact.route(in: map) {
                    NavigationLink(value: GuideDestination.cave(route.id)) { Label("Cave & entrance · " + route.name, systemImage: "mountain.2.fill") }.labelStyle(.iconOnly).accessibilityLabel("Cave and entrance").cardStyle()
                }
                VisualBrief(text: map == .ragnarok ? "Nunatak requires one of this artifact for each summon at Gamma, Beta and Alpha." : "The Boss section identifies which tribute set uses this artifact. Each encounter does not require every artifact on the map.").cardStyle()
                Toggle("Collected this artifact", isOn: completion).accessibilityIdentifier("collected-" + artifact.id).cardStyle()
                VisualBrief(text: "Your collection checklist; uncheck an artifact after using it to summon. If an artifact has not appeared in Single Player, keep the area loaded and check again later; do not assume it has been removed.").font(.caption).foregroundStyle(.secondary)
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
                VisualKitGroup(text: item, token: key + ":" + String(index), checked: binding(index))
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
        }.buttonStyle(.plain).accessibilityValue(configuration.isOn ? "Prepared" : "Not prepared")
    }
}
extension ToggleStyle where Self == ChecklistToggleStyle { static var checkboxCompat: ChecklistToggleStyle { ChecklistToggleStyle() } }


enum GuideDestination: Hashable {
    case navigator, cave(String), artifact(String), map(String), boss(String), army(String), base(String), preparation
    var screen: some View { GuideDestinationScreen(destination: self) }
}
struct GuideDestinationScreen: View {
    let destination: GuideDestination
    @Environment(\.arkMap) private var map
    @ViewBuilder var body: some View {
        switch destination {
        case .navigator: JungleNavigator()
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
