import SwiftUI
import UIKit

struct BaseCatalogue: Decodable {
    let reviewedAt: String; let methodology: String; let limits: String
    let videos: [BaseVideo]; let locations: [BaseSpot]
}
struct BaseVideo: Decodable, Identifiable {
    let id: String; let title: String; let channel: String; let url: String; let thumbnailURL: String
    let views: Int; let likes: Int; let observedAt: String
}
struct BaseSpot: Decodable, Identifiable {
    let id: String; let name: String; let rank: Int; let lat: Double; let lon: Double; let tag: String
    let why: String; let pros: [String]; let cons: [String]; let layout: [String]
    let videoID: String; let seconds: Int; let support: String; let sources: [GuideEvidence]
    var coordinates: String { String(format: "LAT %.2f · LON %.2f", lat, lon) }
    var videoURL: URL { URL(string: "https://www.youtube.com/watch?v=\(videoID)&t=\(seconds)s")! }
    var timestamp: String { String(format: "%d:%02d", seconds / 60, seconds % 60) }
}
extension ArkMap {
    var bases: BaseCatalogue? { Self.baseCatalogues[self] ?? nil }
    private static let baseCatalogues = Dictionary(uniqueKeysWithValues: [ArkMap.ragnarok, .island, .center].map { ($0, try? load(BaseCatalogue.self, name: $0.rawValue == "ragnarok" ? "ragnarok-bases" : $0.rawValue + "-bases")) })
}
struct BaseLocationsScreen: View {
    @Environment(\.arkMap) private var map
    @State private var selectedID: String?
    @State private var resetToken = UUID()
    @State private var action: MapAction = .fit
    private var spots: [BaseSpot] { (map.bases?.locations ?? []).sorted { $0.rank < $1.rank } }
    private var selected: BaseSpot? { spots.first { $0.id == selectedID } ?? spots.first }
    private var points: [MapLocation] { spots.map { MapLocation(id: "base-" + $0.id, name: $0.name, lat: $0.lat, lon: $0.lon, layer: .base, note: $0.tag, routeID: nil, artifactID: nil, imageAsset: "Base-" + $0.id) } }
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 14) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(spots) { spot in
                            Button { selectedID = spot.id } label: {
                                VStack(spacing: 6) {
                                    BaseTerrainPreview(spot: spot).frame(width: 116, height: 56).clipShape(RoundedRectangle(cornerRadius: 8))
                                    Text(spot.name).font(.system(size: 12, weight: .semibold)).lineLimit(2).multilineTextAlignment(.center).frame(height: 32)
                                }.padding(8).frame(width: 132)
                                    .background(selected?.id == spot.id ? Color.cyan.opacity(0.14) : Color.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 12))
                                    .overlay { RoundedRectangle(cornerRadius: 12).strokeBorder(selected?.id == spot.id ? .cyan.opacity(0.5) : .clear) }
                            }.buttonStyle(.plain).accessibilityIdentifier("base-choice-" + spot.id).accessibilityValue(selected?.id == spot.id ? "Selected" : "Not selected")
                        }
                    }
                }.accessibilityIdentifier("base-location-strip")
                if let spot = selected {
                    let width = max(1, (geometry.size.width - 64) / 3)
                    HStack(alignment: .top, spacing: 12) {
                        VStack(spacing: 0) {
                            ZoomableMap(imageAsset: map.imageAsset, mapName: map.name, resetToken: resetToken, action: action, locations: points, focusID: nil, select: { selectedID = String($0.id.dropFirst(5)) }, highlightID: "base-" + spot.id)
                            HStack {
                                Spacer()
                                Button { action = .out; resetToken = UUID() } label: { Image(systemName: "minus").frame(width: 40, height: 40) }.accessibilityLabel("Zoom out")
                                Button { action = .inside; resetToken = UUID() } label: { Image(systemName: "plus").frame(width: 40, height: 40) }.accessibilityLabel("Zoom in")
                                Button { action = .fit; resetToken = UUID() } label: { Image(systemName: "arrow.counterclockwise").frame(width: 40, height: 40) }.accessibilityLabel("Fit map")
                            }.buttonStyle(.plain).background(Color.white.opacity(0.04))
                        }.frame(width: width).clipShape(RoundedRectangle(cornerRadius: 16)).accessibilityIdentifier("base-locations-map")
                        VStack(alignment: .leading, spacing: 10) {
                            BaseTerrainPreview(spot: spot).frame(height: min(170, geometry.size.height * 0.30)).clipShape(RoundedRectangle(cornerRadius: 14))
                            Text(spot.name).font(.title3.bold())
                            GPSBadge(coordinates: spot.coordinates).foregroundStyle(.cyan)
                            Text(spot.tag).font(.caption).foregroundStyle(.secondary)
                            Text(spot.why).font(.subheadline).fixedSize(horizontal: false, vertical: true)
                            Link(destination: spot.videoURL) { Label("Source · " + spot.timestamp, systemImage: "play.rectangle.fill") }.font(.caption).foregroundStyle(.cyan)
                            Text(map == .center ? "GPS from creator captions · confirm in game." : "Creator location coordinates · scout before building.").font(.caption2).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
                        }.padding(12).frame(width: width, alignment: .leading).background(Color.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 16)).accessibilityElement(children: .contain).accessibilityIdentifier("base-selected-" + spot.id)
                        ScrollView {
                            VStack(alignment: .leading, spacing: 18) {
                                details("Strengths", icon: "checkmark.shield", items: spot.pros)
                                details("Tradeoffs", icon: "exclamationmark.triangle", items: spot.cons)
                                details("Before building", icon: "hammer", items: spot.layout)
                            }.padding(14)
                        }.frame(width: width).background(Color.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 16)).accessibilityIdentifier("base-scouting-info")
                    }.frame(maxHeight: .infinity)
                } else {
                    ContentUnavailableView("Base scouting", systemImage: "house", description: Text("Researched base locations are not available for this map yet."))
                }
            }.padding(20)
        }
    }
    private func details(_ title: String, icon: String, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon).font(.headline).foregroundStyle(.cyan)
            ForEach(items, id: \.self) { Text($0).font(.subheadline).fixedSize(horizontal: false, vertical: true) }
        }
    }
}
struct BaseSpotGrid: View {
    let catalogue: BaseCatalogue
    var body: some View {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 240, maximum: 340), spacing: 16)], spacing: 16) {
                        ForEach(catalogue.locations.sorted { $0.rank < $1.rank }) { spot in
                            NavigationLink(value: GuideDestination.base(spot.id)) {
                                SquareGuideTile(title: "\(spot.rank) · " + spot.name, subtitle: spot.tag, gps: spot.coordinates) {
                                    BaseTerrainPreview(spot: spot)
                                }
                            }.buttonStyle(.plain).accessibilityIdentifier("base-" + spot.id)
                        }
                    }
    }
}
struct BaseTerrainPreview: View {
    let spot: BaseSpot
    var body: some View {
        GeometryReader { proxy in
            if let photo = UIImage(named: "Base-" + spot.id) {
                Image(uiImage: photo).resizable().scaledToFill()
                    .frame(width: proxy.size.width, height: proxy.size.height).clipped()
                    .accessibilityIdentifier("base-photo-" + spot.id)
            } else {
                ZStack { Color.white.opacity(0.04); Image(systemName: "photo").font(.largeTitle).foregroundStyle(.secondary) }
                    .accessibilityLabel("No verified image available")
            }
        }
    }
}
struct BaseLocationDetail: View {
    let spot: BaseSpot
    @Environment(\.arkMap) private var map
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Text(spot.name).font(.largeTitle.bold())
                Text(spot.tag).foregroundStyle(.cyan)
                BaseTerrainPreview(spot: spot).frame(height: 250).clipShape(RoundedRectangle(cornerRadius: 20))
                GPSBadge(coordinates: spot.coordinates).font(.title2.bold()).monospacedDigit().foregroundStyle(.orange)
                HStack {
                    NavigationLink(value: GuideDestination.map("base-" + spot.id)) { Label("Show on map", systemImage: "map.fill") }.labelStyle(.iconOnly).accessibilityLabel("Show on map").accessibilityIdentifier("show-base-" + spot.id)
                    Link(destination: spot.videoURL) { Label("YouTube · " + spot.timestamp, systemImage: "play.rectangle.fill") }.labelStyle(.iconOnly).accessibilityLabel("Xem video").accessibilityIdentifier("baseVideo")
                }.buttonStyle(.bordered)
                VisualBrief(text: spot.why).cardStyle()
                block("Strengths", spot.pros)
                block("Tradeoffs & dangers", spot.cons)
                block("Base layout & preparation", spot.layout)
                GuideChecklist(title: "Before moving your main base", items: ["Check GPS, dangerous spawns and building permissions", "Test transport routes for large creatures and Argentavis", "Check water, breeding space and farming routes", "Place backup beds and storage first", "Keep resource spawns and cave entrances clear"], key: "base-" + spot.id)
            }.padding(24).frame(maxWidth: 1000).frame(maxWidth: .infinity)
        }.navigationTitle(spot.name).navigationBarTitleDisplayMode(.inline)
    }
    private func block(_ title: String, _ items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) { Text(title).font(.title2.bold()); ForEach(items, id: \.self) { VisualBrief(text: $0) } }.cardStyle()
    }
}
