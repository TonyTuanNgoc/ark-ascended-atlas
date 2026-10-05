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

struct ExplorationLibrary: View {
    @Environment(\.arkMap) private var map
    @State private var search = ""
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Text("Artifacts & caves").font(.largeTitle.bold())
                Text("\(map.exploration?.artifacts.count ?? 0) artifacts · \(map.exploration?.routes.count ?? 0) exploration routes · " + map.name + " Ascended").font(.headline).foregroundStyle(.cyan)
                Text("Entrance and artifact coordinates mark different locations. Match the surrounding terrain to confirm your approach.").foregroundStyle(.secondary)
                let unlinked = (map.exploration?.artifacts ?? []).filter { artifact in
                    !(map.exploration?.routes.contains { $0.id == artifact.routeID } ?? false)
                }.filter { search.isEmpty || $0.name.localizedStandardContains(search) }
                if !unlinked.isEmpty {
                    ForEach(unlinked) { artifact in
                        HStack(spacing: 14) {
                            if !artifact.imageAsset.isEmpty { Image(artifact.imageAsset).resizable().scaledToFit().frame(width: 52, height: 64) }
                            VStack(alignment: .leading, spacing: 6) { Text(artifact.name).font(.headline); GPSBadge(coordinates: artifact.coordinates).foregroundStyle(.cyan) }
                            Spacer()
                            NavigationLink(value: GuideDestination.map("artifact-" + artifact.id)) { Image(systemName: "map.fill") }.accessibilityLabel("Show artifact on map")
                        }.cardStyle()
                    }
                }
                if map.exploration?.routes.isEmpty == true, map.exploration?.artifacts.isEmpty == true, let record = map.expansion {
                    ExpansionProfile(record: record).cardStyle()
                }
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 240, maximum: 340), spacing: 16)], spacing: 16) {
                ForEach((map.exploration?.routes ?? []).filter { search.isEmpty || $0.name.localizedStandardContains(search) || $0.artifacts(in: map).contains { $0.name.localizedStandardContains(search) } }) { route in
                    NavigationLink(value: GuideDestination.cave(route.id)) {
                        SquareGuideTile(title: route.name, subtitle: route.artifacts(in: map).map { $0.name.replacingOccurrences(of: "Artifact of the ", with: "") }.joined(separator: " · "), gps: route.entrances.first?.coordinates ?? "Deep ocean") {
                            Image(route.imageAsset).resizable().scaledToFill()
                        }
                    }.buttonStyle(.plain).accessibilityIdentifier("route-" + route.id)
                }
                }
            }.padding(24).frame(maxWidth: 1100).frame(maxWidth: .infinity)
        }.searchable(text: $search, prompt: "Search caves or artifacts")
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
                HStack(alignment: .top, spacing: 18) {
                    VStack(alignment: .leading, spacing: 6) {
                        routePhoto.frame(width: 230, height: 160)
                        if route.imageAsset.hasPrefix("Map-") {
                            Text("Terrain overview").font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(route.artifacts(in: map)) { artifact in
                            HStack(spacing: 12) {
                                Image(artifact.imageAsset).resizable().scaledToFit().frame(width: 56, height: 64)
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(artifact.name.replacingOccurrences(of: "Artifact of the ", with: "")).font(.headline)
                                    GPSBadge(coordinates: artifact.coordinates)
                                }
                            }
                        }
                        ForEach(route.entrances) { entrance in
                            HStack(spacing: 10) {
                                Image(systemName: "mountain.2.fill").foregroundStyle(.orange)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(entrance.label).font(.caption)
                                    GPSBadge(coordinates: entrance.coordinates)
                                }
                                if entrance.isInsideAtlas {
                                    NavigationLink(value: GuideDestination.map("entrance-" + entrance.id)) { Image(systemName: "map") }
                                    .accessibilityLabel("Show cave entrance on map").accessibilityIdentifier("show-entrance-" + entrance.id)
                                } else {
                                    Text("Outside this map image").font(.caption).foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    Spacer(minLength: 0)
                }
                if AtlasReferenceLocations.references(in: map).contains(where: { $0.routeID == route.id && $0.kind == .caveEntrance }) {
                    Text("Atlas reference · confirm with in-game GPS").font(.caption).foregroundStyle(.secondary)
                }
                RoutePreparation(items: route.kit)
                if let guide = map.caveGIFs.first(where: { $0.routeID == route.id }) {
                    CaveGIFWalkthrough(guide: guide).id(map.rawValue + route.id)
                }
                VisualBrief(text: route.notes).cardStyle()
                if map.caveGIFs.first(where: { $0.routeID == route.id }) == nil,
                   let reference = AtlasReferenceLocations.references(in: map).first(where: { $0.routeID == route.id }),
                   let link = reference.walkthroughURL, let url = URL(string: link) {
                    Link(destination: url) { Label("Watch walkthrough", systemImage: "play.rectangle.fill") }
                        .accessibilityIdentifier("walkthrough-" + route.id)
                }

                if let video = map.caveVideos.first(where: { $0.routeID == route.id }) {
                    Button {
                        showFullVideo.toggle()
                    } label: {
                        HStack {
                            Label("Full video", systemImage: "play.rectangle")
                            Spacer()
                            Image(systemName: showFullVideo ? "chevron.up" : "chevron.down")
                        }.contentShape(Rectangle())
                    }.buttonStyle(.plain)
                        .accessibilityIdentifier("full-cave-video-" + route.id)
                        .accessibilityValue(showFullVideo ? "Expanded" : "Collapsed")
                    if showFullVideo { CaveVideoTimeline(guide: video) }
                }

            }.padding(24).frame(maxWidth: 1000).frame(maxWidth: .infinity)
        }.navigationTitle(route.name).navigationBarTitleDisplayMode(.inline)
    }
    private var routePhoto: some View {
        GeometryReader { geometry in
            Image(route.imageAsset).resizable().scaledToFill()
                .frame(width: geometry.size.width, height: geometry.size.height).clipped()
        }.clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
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
