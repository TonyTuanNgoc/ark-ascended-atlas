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
    @State private var resource: String? = nil
    @State private var selectedID: String? = nil
    @State private var focusedID: String? = nil
    @State private var resetToken = UUID()
    @State private var action: MapAction = .fit
    private var names: [String] { FarmingResourceCatalogue.names(in: map).filter { search.isEmpty || MapResources.label(for: $0).localizedStandardContains(search) } }
    private var selectedEntry: FarmingResourceCatalogue.Entry? { FarmingResourceCatalogue.shared.maps.first { $0.map == map.rawValue }?.resources.first { $0.name == selectedResource } }
    private var selectedResource: String? { resource ?? names.first(where: { $0 == "Metal" }) ?? names.first }
    private var spots: [VerifiedResourceSpot] { selectedResource.map { FarmingResourceCatalogue.spots(for: $0, in: map) } ?? [] }
    private var selectedSpot: VerifiedResourceSpot? { spots.first { $0.id == selectedID } ?? spots.first }
    private var acquisition: [ResourceCoverage] { (ResourceFarmCatalog.shared.coverage ?? []).filter { $0.map == map.rawValue && ["crafted", "crafting", "boss", "processing", "creature"].contains($0.status) && (search.isEmpty || $0.resource.localizedStandardContains(search)) } }
    var body: some View {
        GeometryReader { geometry in
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 8) {
                        ForEach(names, id: \.self) { name in
                            Button { resource = name; selectedID = nil; focusedID = nil; action = .fit; resetToken = UUID() } label: {
                                VStack(spacing: 6) {
                                    FarmResourcePicture(name: name).frame(width: 46, height: 46)
                                    Text(MapResources.label(for: name)).font(.caption.weight(.medium)).multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
                                }.frame(width: 92).frame(minHeight: 86).padding(8)
                                    .background(selectedResource == name ? Color.cyan.opacity(0.15) : Color.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 12))
                                    .overlay { RoundedRectangle(cornerRadius: 12).strokeBorder(selectedResource == name ? .cyan.opacity(0.65) : .white.opacity(0.06), lineWidth: 1) }
                            }.buttonStyle(.plain).foregroundStyle(selectedResource == name ? .cyan : .primary)
                                .id(name).accessibilityLabel(MapResources.label(for: name)).accessibilityValue(selectedResource == name ? "Selected" : "Not selected").accessibilityIdentifier("farm-resource-" + name)
                        }
                    }
                }.accessibilityIdentifier("farming-resource-strip")
                    .onAppear { if let name = selectedResource { proxy.scrollTo(name, anchor: .center) } }
                }
                if let name = selectedResource {
                    HStack(spacing: 10) {
                        FarmResourcePicture(name: name).frame(width: 34, height: 34)
                        Text(MapResources.label(for: name)).font(.title2.bold())
                        Spacer()
                        Label(String(spots.count), systemImage: "mappin.and.ellipse").font(.subheadline.monospacedDigit()).foregroundStyle(.cyan).accessibilityLabel("\(spots.count) verified locations").accessibilityIdentifier("farm-location-count")
                    }
                    if geometry.size.width >= 1000 {
                        HStack(alignment: .top, spacing: 16) {
                            miniMap.frame(width: 380, height: 380)
                            spotPreview.frame(maxWidth: .infinity)
                        }
                    } else {
                        VStack(spacing: 14) { miniMap.frame(height: 300); spotPreview }
                    }
                    if !spots.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(alignment: .top, spacing: 10) {
                                ForEach(spots) { spot in
                                    Button { selectedID = spot.id; focusedID = spot.point.id } label: {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Image(spot.imageAsset).resizable().scaledToFill().frame(width: 188, height: 106).clipped().clipShape(RoundedRectangle(cornerRadius: 8))
                                            Text(spot.name).font(.caption.weight(.medium)).multilineTextAlignment(.leading).lineLimit(3).frame(height: 46, alignment: .top)
                                            GPSBadge(coordinates: spot.point.coordinates).font(.caption2)
                                        }.padding(8).background(selectedSpot?.id == spot.id ? Color.cyan.opacity(0.13) : Color.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 12))
                                            .overlay { RoundedRectangle(cornerRadius: 12).strokeBorder(selectedSpot?.id == spot.id ? .cyan.opacity(0.6) : .clear, lineWidth: 1) }
                                    }.buttonStyle(.plain).accessibilityIdentifier("farm-site-" + spot.id).accessibilityValue(selectedSpot?.id == spot.id ? "Selected" : "Not selected")
                                }
                            }
                        }.accessibilityIdentifier("farming-location-strip")
                    }
                    if let entry = selectedEntry {
                        HStack(alignment: .top, spacing: 12) {
                            FarmResourcePicture(name: entry.name).frame(width: 44, height: 44)
                            Text(entry.method).font(.callout).fixedSize(horizontal: false, vertical: true)
                        }.frame(maxWidth: .infinity, alignment: .leading).cardStyle().accessibilityIdentifier("farming-resource-method")
                    }
                    if selectedEntry?.availability != "production", selectedEntry?.availability != "boss", let gathering = HarvestingCatalogue.shared.resource(name) {
                        HarvestingReferencePanel(reference: gathering).cardStyle().accessibilityIdentifier("farming-harvesting-reference")
                    }
                }
                if !acquisition.isEmpty {
                    Divider().padding(.vertical, 8)
                    HStack { Image(systemName: "gearshape.2.fill").foregroundStyle(.cyan); Text("Production & crafting").font(.title3.bold()) }
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 300), alignment: .top)], alignment: .leading, spacing: 14) {
                        ForEach(acquisition) { row in ResourceAcquisitionCard(row: row) }
                    }
                }
            }.padding(20)
        }.searchable(text: $search, prompt: "Search resources")
            .onChange(of: search) { _, _ in if let resource, !names.contains(resource) { self.resource = nil; selectedID = nil; focusedID = nil; action = .fit; resetToken = UUID() } }
    }
    }
    private var miniMap: some View {
        ZoomableMap(imageAsset: map.imageAsset, mapName: map.name, resetToken: resetToken, action: action, locations: spots.map(\.point), focusID: focusedID, select: { point in selectedID = point.farmID; focusedID = point.id })
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(alignment: .bottomTrailing) {
                HStack(spacing: 2) {
                    Button { action = .out; resetToken = UUID() } label: { Image(systemName: "minus").frame(width: 38, height: 38) }.accessibilityLabel("Zoom out farming map")
                    Button { action = .inside; resetToken = UUID() } label: { Image(systemName: "plus").frame(width: 38, height: 38) }.accessibilityLabel("Zoom in farming map")
                    Button { focusedID = nil; action = .fit; resetToken = UUID() } label: { Image(systemName: "arrow.counterclockwise").frame(width: 38, height: 38) }.accessibilityLabel("Fit farming map")
                }.buttonStyle(.plain).padding(4).background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10)).padding(10)
            }.accessibilityIdentifier("farming-mini-map")
    }
    @ViewBuilder private var spotPreview: some View {
        if let spot = selectedSpot {
            FarmDetails(spot: spot, showGathering: false).cardStyle().accessibilityElement(children: .contain).accessibilityIdentifier("farm-card-" + spot.id)
        } else {
            VStack(spacing: 14) {
                if let name = selectedResource { FarmResourcePicture(name: name).frame(width: 80, height: 80) }
                Label("No verified location video yet", systemImage: "mappin.slash").font(.headline)
                Text("Gathering advice is below. Pins appear only after the location and footage are checked.").font(.callout).foregroundStyle(.secondary).multilineTextAlignment(.center)
            }.frame(maxWidth: .infinity, minHeight: 320).padding(18).background(.white.opacity(0.035), in: RoundedRectangle(cornerRadius: 16)).accessibilityIdentifier("farm-no-verified-locations")
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
