import SwiftUI
import UIKit

struct ResourceFarmCatalog: Decodable {
    let spots: [VerifiedResourceSpot]
    let coverage: [ResourceCoverage]?
    static let shared = (try? ArkMap.load(ResourceFarmCatalog.self, name: "verified-resource-spots")) ?? ResourceFarmCatalog(spots: [], coverage: [])
    static func spots(in map: ArkMap) -> [VerifiedResourceSpot] { shared.spots.filter { $0.map == map.rawValue && $0.verified } }
}
struct ResourceCoverage: Decodable, Identifiable {
    let map, resource, status, reason: String
    let spotIDs: [String]
    let videoID: String?
    let seconds: Double?
    let imageAsset: String?
    let sourceURL: String?
    let method: String?
    let kit: [String]?
    let acquisitionClass: String?
    let evidenceState: String?
    let limitations: String?
    let candidateSourceChapters: [ResourceSourceChapter]?
    let risks: [String]?
    var videoURL: URL? {
        guard let videoID else { return sourceURL.flatMap(URL.init(string:)) }
        return URL(string: "https://www.youtube.com/watch?v=\(videoID)&t=\(Int(seconds ?? 0))s")
    }
    var id: String { map + ":" + resource }
}
struct ResourceSourceChapter: Decodable, Identifiable {
    let videoID, title, sourceURL: String
    let startSeconds: Double
    var id: String { videoID + ":" + String(startSeconds) }
}
struct VerifiedResourceSpot: Decodable, Identifiable {
    let id, map, name, imageAsset, videoID, direction, method, sourceURL: String
    let lat, lon, seconds: Double
    let resources, kit, risks: [String]
    let verified: Bool
    let sourceCoordinateScope: String?
    var coordinateHint: String {
        (sourceCoordinateScope ?? "").localizedCaseInsensitiveContains("interior") ? "Cave chamber · not the entrance" : "Filmed area · nearby nodes can vary"
    }
    var videoURL: URL? { URL(string: "https://www.youtube.com/watch?v=\(videoID)&t=\(Int(seconds))s") }
    var point: MapLocation { MapLocation(id: "farm-" + id, name: name, lat: lat, lon: lon, layer: .resource, note: direction, routeID: nil, artifactID: nil, imageAsset: imageAsset, farmID: id, resourceNames: resources) }
}
struct FarmDetails: View {
    let spot: VerifiedResourceSpot
    var showGathering = true
    private var equipment: [FactMatch] {
        spot.kit.map { name in
            let base = VisualFacts.items([name])[0].fact
            let fact = VisualFact(id: name, name: name, aliases: [name], asset: base.asset, symbol: base.symbol, category: base.category)
            return FactMatch(fact: fact, quantity: nil)
        }
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let guide = ResourceClipCatalog.guide(for: spot.id) {
                ResourceClipWalkthrough(guide: guide).id(spot.id)
            } else {
                Image(spot.imageAsset).resizable().scaledToFit().clipShape(RoundedRectangle(cornerRadius: 10)).accessibilityIdentifier("farmPhoto")
            }
            Text(spot.name).font(.headline).accessibilityIdentifier("selectedMapLocation")
            GPSBadge(coordinates: spot.point.coordinates).foregroundStyle(.cyan)
            Text(spot.coordinateHint).font(.caption2).foregroundStyle(.secondary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 10) {
                    ForEach(spot.resources.filter { showGathering || !FarmingResourceCatalogue.excluded.contains($0) }, id: \.self) { name in
                        VStack(spacing: 4) {
                            FarmResourcePicture(name: FarmingResourceCatalogue.canonical(name) ?? name).frame(width: 42, height: 42)
                            Text(MapResources.label(for: name)).font(.caption2).multilineTextAlignment(.center)
                        }.frame(width: 76)
                    }
                }
            }
            ForEach(showGathering ? spot.resources : [], id: \.self) { resource in
                if let gathering = HarvestingCatalogue.shared.resource(resource) {
                    DisclosureGroup("Gathering · " + resource) {
                        HarvestingReferencePanel(reference: gathering).padding(.top, 8)
                    }.font(.subheadline).accessibilityIdentifier("farm-gathering-" + resource)
                }
            }
            Text(spot.direction).font(.callout)
            if !spot.method.isEmpty { Text(spot.method).font(.caption).foregroundStyle(.secondary) }
            if !spot.kit.isEmpty { ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(equipment) { match in FactTile(match: match) }
                    }
                } }
            if !spot.risks.isEmpty { Label(spot.risks.joined(separator: " · "), systemImage: "exclamationmark.triangle.fill").font(.caption).foregroundStyle(.orange) }

        }
    }
}
struct FarmingResourceCatalogue: Decodable {
    struct MapRow: Decodable { let map: String; let resources: [Entry] }
    struct Entry: Decodable { let name, availability, method, sourceURL: String }
    let maps: [MapRow]
    static let shared = (try? ArkMap.load(Self.self, name: "farming-resources")) ?? Self(maps: [])
    static let excluded: Set<String> = ["Wood", "Thatch", "Fiber", "Stone", "Flint"]
    static func names(in map: ArkMap) -> [String] {
        let curated = shared.maps.first { $0.map == map.rawValue }?.resources.map(\.name) ?? []
        let filmed = ResourceFarmCatalog.spots(in: map).flatMap(\.resources).compactMap(canonical)
        return Set(curated + filmed).subtracting(excluded).sorted { MapResources.label(for: $0).localizedStandardCompare(MapResources.label(for: $1)) == .orderedAscending }
    }
    static func canonical(_ name: String) -> String? {
        switch name {
        case "Honey": return "Giant Bee Honey"
        case "Salt": return "Raw Salt"
        case "Sandpile": return "Sand"
        case "Cactus with few berries": return "Cactus Sap"
        case "Beaver Dam", "Mushrooms (type unverified)", "Bone deposit (drops unverified)", "Gem (type unverified)": return nil
        default: return name
        }
    }
    static func spots(for resource: String, in map: ArkMap) -> [VerifiedResourceSpot] {
        ResourceFarmCatalog.spots(in: map).filter { $0.resources.compactMap(canonical).contains(resource) }
    }
}

private struct FarmingResourceIcons: Decodable {
    let assets: [String: String]
    static let shared = (try? ArkMap.load(Self.self, name: "farming-resource-icons")) ?? Self(assets: [:])
}

private struct FarmResourcePicture: View {
    let name: String
    var body: some View {
        let direct = FarmingResourceIcons.shared.assets[name] ?? MapResources.asset(for: name)
        let fact = EquipmentCatalogue.find(name)?.fact.asset ?? VisualFacts.items([name]).first?.fact.asset
        if let asset = UIImage(named: direct) != nil ? direct : fact, UIImage(named: asset) != nil {
            Image(asset).resizable().scaledToFit()
        } else {
            Image(systemName: MapResources.symbol(for: name)).foregroundStyle(name == "Water" ? .cyan : .orange)
        }
    }
}

struct ResourceFarmingScreen: View {
    @Environment(\.arkMap) private var map
    @State private var search = ""
    @State private var resource = "Metal"
    @State private var selectedID: String?
    @State private var resetToken = UUID()
    @State private var action: MapAction = .fit
    static let resourceSelection = ["Black Pearls", "Cementing Paste", "Chitin", "Crystal", "Giant Bee Honey", "Metal", "Obsidian", "Oil", "Organic Polymer", "Rare Flowers", "Rare Mushrooms", "Rich Metal", "Sap", "Silica Pearls"]
    private var names: [String] { Self.resourceSelection.filter { search.isEmpty || $0.localizedStandardContains(search) } }
    private var spots: [VerifiedResourceSpot] { FarmingResourceCatalogue.spots(for: resource, in: map) }
    private var selectedSpot: VerifiedResourceSpot? { spots.first { $0.id == selectedID } ?? spots.first }
    private var mapPoints: [MapLocation] {
        spots.map { spot in
            let point = spot.point
            return MapLocation(id: point.id, name: point.name, lat: point.lat, lon: point.lon, layer: point.layer, note: point.note, routeID: point.routeID, artifactID: point.artifactID, imageAsset: point.imageAsset, farmID: point.farmID, resourceNames: [resource])
        }
    }
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 14) {
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(names, id: \.self) { name in
                                Button {
                                    resource = name; selectedID = nil; action = .fit; resetToken = UUID()
                                } label: {
                                    VStack(spacing: 5) {
                                        FarmResourcePicture(name: name).frame(width: 38, height: 38)
                                        Text(name).font(.system(size: 12, weight: .semibold)).multilineTextAlignment(.center)
                                            .lineLimit(2).frame(height: 30)
                                    }.frame(width: 94, height: 78).padding(6)
                                        .background(resource == name ? Color.cyan.opacity(0.14) : .white.opacity(0.04), in: RoundedRectangle(cornerRadius: 12))
                                        .overlay { RoundedRectangle(cornerRadius: 12).strokeBorder(resource == name ? .cyan.opacity(0.5) : .clear) }
                                        .contentShape(Rectangle())
                                }.buttonStyle(.plain).id(name).accessibilityIdentifier("farm-resource-" + name)
                                    .accessibilityValue(resource == name ? "Selected" : "Not selected")
                            }
                        }
                    }.accessibilityIdentifier("farming-resource-strip")
                        .onAppear { proxy.scrollTo(resource, anchor: .center) }
                }
                HStack(spacing: 10) {
                    FarmResourcePicture(name: resource).frame(width: 28, height: 28)
                    Text(resource).font(.title3.bold())
                    Spacer()
                    Label(String(spots.count), systemImage: "mappin.and.ellipse").font(.caption.monospacedDigit()).foregroundStyle(.cyan)
                        .accessibilityLabel("\(spots.count) verified locations").accessibilityIdentifier("farm-location-count")
                }
                let columnWidth = max(1, (geometry.size.width - 64) / 3)
                HStack(alignment: .top, spacing: 12) {
                    miniMap.frame(width: columnWidth).frame(maxHeight: .infinity)
                    locations(width: columnWidth).frame(width: columnWidth).frame(maxHeight: .infinity, alignment: .top)
                    harvesting.frame(width: columnWidth).frame(maxHeight: .infinity, alignment: .top)
                }.frame(maxHeight: .infinity)
            }.padding(20)
        }.searchable(text: $search, prompt: "Search resources")
    }
    private var miniMap: some View {
        VStack(spacing: 0) {
            ZoomableMap(imageAsset: map.imageAsset, mapName: map.name, resetToken: resetToken, action: action, locations: mapPoints, focusID: nil, select: { point in selectedID = point.farmID }, highlightID: selectedSpot.map { "farm-" + $0.id })
                .frame(maxHeight: .infinity)
            HStack(spacing: 2) {
                Spacer()
                Button { action = .out; resetToken = UUID() } label: { Image(systemName: "minus").frame(width: 40, height: 40) }.accessibilityLabel("Zoom out farming map")
                Button { action = .inside; resetToken = UUID() } label: { Image(systemName: "plus").frame(width: 40, height: 40) }.accessibilityLabel("Zoom in farming map")
                Button { action = .fit; resetToken = UUID() } label: { Image(systemName: "arrow.counterclockwise").frame(width: 40, height: 40) }.accessibilityLabel("Fit farming map")
            }.buttonStyle(.plain).padding(.horizontal, 8).background(Color(red: 0.045, green: 0.075, blue: 0.085))
        }.clipShape(RoundedRectangle(cornerRadius: 16)).accessibilityIdentifier("farming-mini-map")
    }
    private func locations(width: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Locations").font(.headline)
            if spots.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "mappin.slash").font(.title2).foregroundStyle(.secondary)
                    Text("No verified location yet").font(.subheadline).multilineTextAlignment(.center)
                }.frame(maxWidth: .infinity).padding(24).accessibilityIdentifier("farm-no-verified-locations")
            } else if let spot = selectedSpot {
                VStack(alignment: .leading, spacing: 10) {
                    if let guide = ResourceClipCatalog.guide(for: spot.id) {
                        ResourceClipWalkthrough(guide: guide).id(spot.id)
                    }
                    Text(spot.name).font(.subheadline.bold()).fixedSize(horizontal: false, vertical: true)
                    GPSBadge(coordinates: spot.point.coordinates).font(.caption)
                    Text(spot.coordinateHint).font(.caption2).foregroundStyle(.secondary)
                    Text(spot.direction).font(.caption).foregroundStyle(.secondary).lineLimit(4)
                }.padding(10).frame(width: max(1, width - 2), alignment: .topLeading)
                    .background(.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 14))
                    .accessibilityElement(children: .contain).accessibilityIdentifier("farm-card-" + spot.id)
            }
            Spacer(minLength: 0)
        }.accessibilityElement(children: .contain).accessibilityIdentifier("farming-location-panel")
    }
    private var harvesting: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Harvesting").font(.headline)
                if let reference = HarvestingCatalogue.shared.resource(resource) {
                    if !reference.creatures.isEmpty {
                        Text("Creatures").font(.caption.bold()).foregroundStyle(.cyan)
                        ForEach(reference.creatures) { choice in harvestChoice(choice, creature: true) }
                    }
                    if !reference.tools.isEmpty {
                        Text("Tools").font(.caption.bold()).foregroundStyle(.cyan)
                        ForEach(reference.tools) { choice in harvestChoice(choice, creature: false) }
                    }
                    Text(reference.summary).font(.caption).foregroundStyle(.secondary)
                    ForEach(reference.cautions, id: \.self) { Text($0).font(.caption2).foregroundStyle(.secondary) }
                } else {
                    Text("Harvesting guidance is being verified.").font(.caption).foregroundStyle(.secondary)
                }
            }.padding(14).frame(maxWidth: .infinity, alignment: .leading)
        }.background(.white.opacity(0.035), in: RoundedRectangle(cornerRadius: 14))
            .accessibilityIdentifier("farming-harvesting-column")
    }
    private func harvestChoice(_ choice: HarvestingChoice, creature: Bool) -> some View {
        HStack(alignment: .center, spacing: 10) {
            if creature {
                CreatureAvatar(asset: choice.name == "Giant Bee" ? "Dino-giant-queen-bee" : "Dino-" + choice.name.lowercased().replacingOccurrences(of: " ", with: "-")).frame(width: 46, height: 46)
            } else { ReferencePicture(name: choice.name).frame(width: 46, height: 46) }
            VStack(alignment: .leading, spacing: 3) {
                Text(choice.name).font(.subheadline.weight(.semibold))
                Text(choice.role).font(.caption).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

private struct ResourceAcquisitionCard: View {
    let row: ResourceCoverage
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let asset = row.imageAsset, UIImage(named: asset) != nil {
                Image(asset).resizable().scaledToFit().frame(maxHeight: 220).clipShape(RoundedRectangle(cornerRadius: 12))
            }
            VisualBrief(text: row.resource)
            Text(row.acquisitionClass?.replacingOccurrences(of: "-", with: " ").capitalized ?? row.status.capitalized).font(.caption.bold()).foregroundStyle(.secondary)
            Text(row.reason).font(.callout)
            if let method = row.method, !method.isEmpty, method != row.reason { Text(method).font(.callout) }
            if let kit = row.kit, !kit.isEmpty { ScrollView(.horizontal, showsIndicators: false) { HStack { ForEach(VisualFacts.items(kit)) { FactTile(match: $0) } } } }
            if let risks = row.risks, !risks.isEmpty { Label(risks.joined(separator: " · "), systemImage: "exclamationmark.triangle.fill").font(.caption).foregroundStyle(.orange) }


            if row.status == "boss" { NavigationLink { BossCampaignScreen() } label: { Label("Boss", systemImage: "shield.lefthalf.filled") }.buttonStyle(.bordered) }
        }.cardStyle().accessibilityElement(children: .contain).accessibilityIdentifier("acquisition-" + row.map + "-" + row.resource)
    }
}

struct ResourceClipCatalog: Decodable {
    let guides: [ResourceClipGuide]
    static let shared = (try? ArkMap.load(ResourceClipCatalog.self, name: "resource-guides")) ?? ResourceClipCatalog(guides: [])
    static func guide(for spotID: String) -> ResourceClipGuide? { shared.guides.first { $0.spotID == spotID } }
}
struct ResourceClipGuide: Decodable {
    let spotID, sourceURL, evidenceLimitations: String
    let harvestDemonstrated: Bool
    let steps: [ResourceClipStep]
}
struct ResourceClipStep: Decodable, Identifiable {
    let id, title, loop, poster, sourceURL: String
    let startSeconds, endSeconds: Double
    let mapOverlayVisible: Bool?
    private func mediaURL(_ name: String, extension ext: String) -> URL? {
        Bundle.main.url(forResource: name, withExtension: ext, subdirectory: "ResourceClips") ?? Bundle.main.url(forResource: name, withExtension: ext)
    }
    var url: URL? { mediaURL(loop, extension: "mp4") }
    var caveStep: CaveGIFStep {
        let posterName = Bundle.main.url(forResource: poster, withExtension: "jpg", subdirectory: "ResourceClips") != nil ? "ResourceClips/" + poster : poster
        return CaveGIFStep(id: id, title: title, gif: id, poster: posterName, direction: nil, loop: loop)
    }
}
private struct ResourceClipWalkthrough: View {
    let guide: ResourceClipGuide
    @Environment(\.scenePhase) private var scenePhase
    @State private var visible = false
    var body: some View {
        if let step = guide.steps.first {
            ZStack(alignment: .bottomTrailing) {
                ZStack {
                    Color.black
                    if visible && scenePhase == .active, let url = step.url {
                        AutoCaveGIF(step: step.caveStep, url: url).id(step.id)
                    } else if let image = step.caveStep.posterImage {
                        Image(uiImage: image).resizable().scaledToFit()
                    }
                    if step.url == nil { Text("Clip unavailable").font(.caption).foregroundStyle(.white) }
                }.aspectRatio(16 / 9, contentMode: .fit).accessibilityIdentifier("farmClip-" + step.id)
                if let url = URL(string: step.sourceURL) {
                    Link(destination: url) { Image(systemName: "play.rectangle.fill").font(.title3).padding(10).background(.black.opacity(0.7), in: RoundedRectangle(cornerRadius: 9)) }
                        .accessibilityLabel("Open source video").accessibilityIdentifier("farmClipSource").padding(8)
                }
            }.clipShape(RoundedRectangle(cornerRadius: 12)).onAppear { visible = true }.onDisappear { visible = false }
        }
    }
}
