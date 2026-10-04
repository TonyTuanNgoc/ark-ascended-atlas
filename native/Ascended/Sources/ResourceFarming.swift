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
    let risks: [String]?
    var videoURL: URL? {
        guard let videoID else { return sourceURL.flatMap(URL.init(string:)) }
        return URL(string: "https://www.youtube.com/watch?v=\(videoID)&t=\(Int(seconds ?? 0))s")
    }
    var id: String { map + ":" + resource }
}
struct VerifiedResourceSpot: Decodable, Identifiable {
    let id, map, name, imageAsset, videoID, direction, method, sourceURL: String
    let lat, lon, seconds: Double
    let resources, kit, risks: [String]
    let verified: Bool
    var videoURL: URL? { URL(string: "https://www.youtube.com/watch?v=\(videoID)&t=\(Int(seconds))s") }
    var point: MapLocation { MapLocation(id: "farm-" + id, name: name, lat: lat, lon: lon, layer: .resource, note: direction, routeID: nil, artifactID: nil, imageAsset: imageAsset, farmID: id, resourceNames: resources) }
}
struct FarmDetails: View {
    let spot: VerifiedResourceSpot
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
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 10) {
                    ForEach(spot.resources, id: \.self) { name in
                        VStack(spacing: 4) {
                            if UIImage(named: MapResources.asset(for: name)) != nil { Image(MapResources.asset(for: name)).resizable().scaledToFit().frame(width: 42, height: 42) }
                            else { Image(systemName: MapResources.symbol(for: name)).frame(width: 42, height: 42).foregroundStyle(name == "Water" ? .cyan : .orange) }
                            Text(MapResources.label(for: name)).font(.caption2).multilineTextAlignment(.center)
                        }.frame(width: 76)
                    }
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
            if let url = spot.videoURL { Link(destination: url) { Label("Watch the route", systemImage: "play.rectangle.fill") }.buttonStyle(.bordered).accessibilityIdentifier("farmVideo") }
        }
    }
}
struct ResourceFarmingScreen: View {
    @Environment(\.arkMap) private var map
    @State private var search = ""
    private var spots: [VerifiedResourceSpot] { ResourceFarmCatalog.spots(in: map).filter { search.isEmpty || ($0.name + " " + $0.resources.joined(separator: " ")).localizedStandardContains(search) } }
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 320), alignment: .top)], alignment: .leading, spacing: 16) {
                ForEach(spots) { spot in
                    VStack(alignment: .leading, spacing: 10) {
                        FarmDetails(spot: spot)
                        NavigationLink { MapScreen(initialFocus: "farm-" + spot.id) } label: { Label("Map", systemImage: "map.fill") }.buttonStyle(.bordered)
                    }.cardStyle().accessibilityIdentifier("farm-card-" + spot.id)
                }
            }.padding(20)
            VStack(alignment: .leading, spacing: 14) {
                ForEach((ResourceFarmCatalog.shared.coverage ?? []).filter { $0.map == map.rawValue && ["crafted", "crafting", "boss", "processing", "creature"].contains($0.status) && (search.isEmpty || ($0.resource + " " + $0.reason).localizedStandardContains(search)) }) { row in
                    VStack(alignment: .leading, spacing: 8) {
                        if let asset = row.imageAsset, UIImage(named: asset) != nil {
                            Image(asset).resizable().scaledToFit().frame(maxHeight: 220).clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        VisualBrief(text: row.resource)
                        Text(row.reason).font(.callout)
                        if let method = row.method, !method.isEmpty { Text(method).font(.callout) }
                        if let kit = row.kit, !kit.isEmpty { ScrollView(.horizontal, showsIndicators: false) { HStack { ForEach(VisualFacts.items(kit)) { FactTile(match: $0) } } } }
                        if let risks = row.risks, !risks.isEmpty { Label(risks.joined(separator: " · "), systemImage: "exclamationmark.triangle.fill").font(.caption).foregroundStyle(.orange) }
                        if let url = row.videoURL { Link(destination: url) { Label("Watch harvesting guide", systemImage: "play.rectangle.fill") }.buttonStyle(.bordered) }
                        if row.status == "boss" { NavigationLink { BossCampaignScreen() } label: { Label("Boss", systemImage: "shield.lefthalf.filled") }.buttonStyle(.bordered) }
                    }.cardStyle().accessibilityElement(children: .contain).accessibilityIdentifier("acquisition-" + row.map + "-" + row.resource)
                }
                if spots.isEmpty {
                    Text("Resources on " + map.name).font(.title2.bold())
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))]) {
                        ForEach(MapResources.types(in: map), id: \.self) { name in
                            VStack {
                                if UIImage(named: MapResources.asset(for: name)) != nil { Image(MapResources.asset(for: name)).resizable().scaledToFit().frame(height: 54) }
                                Text(MapResources.label(for: name)).font(.caption)
                            }.cardStyle()
                        }
                    }
                    NavigationLink { MapScreen(initialResources: true) } label: { Label("Open resource locations", systemImage: "map.fill") }.buttonStyle(.borderedProminent)
                }
            }.padding(20)

        }.searchable(text: $search, prompt: "Search resources")
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
    @State private var selectedIndex = 0
    @State private var visible = false
    var body: some View {
        if !guide.steps.isEmpty {
            let step = guide.steps[min(selectedIndex, guide.steps.count - 1)]
            VStack(alignment: .leading, spacing: 8) {
                ZStack {
                    Color.black
                    if visible && scenePhase == .active, let url = step.url {
                        AutoCaveGIF(step: step.caveStep, url: url).id(step.id)
                    } else if let image = step.caveStep.posterImage {
                        Image(uiImage: image).resizable().scaledToFit()
                    }
                    if step.url == nil { Text("Clip unavailable").font(.caption).foregroundStyle(.white) }
                }.aspectRatio(16 / 9, contentMode: .fit).clipShape(RoundedRectangle(cornerRadius: 10))
                    .accessibilityIdentifier("farmClip-" + step.id)
                HStack(spacing: 6) {
                    ForEach(Array(guide.steps.enumerated()), id: \.element.id) { index, item in
                        Button { selectedIndex = index } label: {
                            VStack(spacing:4) {
                                if let image=item.caveStep.posterImage {Image(uiImage:image).resizable().scaledToFit().clipShape(RoundedRectangle(cornerRadius:6))}
                                Text(item.title).font(.caption2).multilineTextAlignment(.center)
                            }.frame(maxWidth:.infinity).padding(3)
                                .background(selectedIndex==index ? Color.orange.opacity(0.15):Color.clear,in:RoundedRectangle(cornerRadius:8))
                        }.buttonStyle(.bordered).tint(selectedIndex == index ? .orange : .gray)
                            .accessibilityIdentifier("farmClipSelect-" + item.id)
                    }
                }
                HStack {
                    Text(step.title).font(.caption.bold()).foregroundStyle(.secondary)
                    Spacer()
                    if let url = URL(string: step.sourceURL) {
                        Link("Source video", destination: url).font(.caption).accessibilityIdentifier("farmClipSource")
                    }
                }
                if !guide.evidenceLimitations.isEmpty {
                    Text(guide.evidenceLimitations).font(.caption2).foregroundStyle(.secondary)
                }
            }.onAppear { visible = true }.onDisappear { visible = false }
        }
    }
}
