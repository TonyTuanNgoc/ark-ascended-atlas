import SwiftUI
import UIKit

struct CreatureSpawnCatalog: Decodable {
    let schemaVersion: Int
    let reviewedAt: String
    let maps: [CreatureSpawnMapSource]
    let records: [CreatureSpawnRecord]
    static let shared = try? ArkMap.load(CreatureSpawnCatalog.self, name: "creature-spawns")
    func record(map: ArkMap, creatureID: String) -> CreatureSpawnRecord? {
        records.first { $0.mapID == map.rawValue && $0.creatureID == creatureID }
    }
}
struct CreatureSpawnMapSource: Decodable {
    let mapID: String
    let registryMapID: Int
    let sourceURL: String
    let sourceDump: String
}
struct CreatureSpawnRecord: Decodable {
    let mapID: String
    let creatureID: String
    let availability: String
    let regions: [CreatureSpawnRegion]
    let sourceURL: String
    var hasVerifiedRegions: Bool { availability == "verified-regions" && !regions.isEmpty }
}
struct CreatureSpawnRegion: Decodable {
    let latMin: Double
    let latMax: Double
    let lonMin: Double
    let lonMax: Double
    let count: Int
    let hasCave: Bool
    let sourceBounds: CreatureSpawnSourceBounds?
    let displayIntersectionOfSourceRegion: Bool?
    enum CodingKeys: String, CodingKey {
        case latMin = "lat_min", latMax = "lat_max", lonMin = "lon_min", lonMax = "lon_max", count, hasCave = "has_cave", sourceBounds, displayIntersectionOfSourceRegion
    }
    /// Source rectangles are retained as areas; their midpoint is never claimed as a creature position.
    func rect(in size: CGSize) -> CGRect {
        CGRect(x: lonMin / 100 * size.width, y: latMin / 100 * size.height,
               width: (lonMax - lonMin) / 100 * size.width, height: (latMax - latMin) / 100 * size.height)
    }
    var isWithinGPSPlane: Bool {
        latMin.isFinite && latMax.isFinite && lonMin.isFinite && lonMax.isFinite &&
        latMin >= 0 && lonMin >= 0 && latMax <= 100 && lonMax <= 100 && latMax >= latMin && lonMax >= lonMin
    }
}

/// Original source rectangle when its display is cropped to the visible GPS plane.
struct CreatureSpawnSourceBounds: Decodable {
    let latMin: Double
    let latMax: Double
    let lonMin: Double
    let lonMax: Double
    enum CodingKeys: String, CodingKey {
        case latMin = "lat_min", latMax = "lat_max", lonMin = "lon_min", lonMax = "lon_max"
    }
}

struct CreatureSpawnMap: View {
    @Environment(\.arkMap) private var map
    let creature: Creature
    @State private var expanded = false
    @State private var selectedArea = ""
    private var record: CreatureSpawnRecord? { CreatureSpawnCatalog.shared?.record(map: map, creatureID: creature.id) }
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing:8) {GuideIcon(name:"Spawn");Text("Spawn map")}.font(.headline).foregroundStyle(.cyan)
                Spacer()
                Text(map.name).font(.subheadline).foregroundStyle(.secondary)
            }
            SpawnRegionMap(imageAsset: map.imageAsset, regions: record?.regions ?? [], selection: { selectedArea = $0 }).id(map.rawValue + ":" + creature.id)
                .aspectRatio(1, contentMode: .fit).frame(maxWidth: 540)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .accessibilityIdentifier("creature-spawn-terrain")
                .overlay(alignment: .bottomTrailing) {
                    Button { expanded = true } label: { Label("Explore", systemImage: "arrow.up.left.and.arrow.down.right").font(.caption.bold()) }
                        .buttonStyle(.borderedProminent).tint(.black.opacity(0.8)).padding(10)
                        .accessibilityIdentifier("creature-spawn-expand")
                }
            if !selectedArea.isEmpty { Text(selectedArea).font(.caption.monospacedDigit()).foregroundStyle(.cyan).accessibilityIdentifier("creature-spawn-coordinate-range") }
            if let record, record.hasVerifiedRegions {
                HStack(spacing: 16) {
                    Label("Surface", systemImage: "square.fill").foregroundStyle(.cyan)
                    if record.regions.contains(where: \.hasCave) { Label("Includes cave spawns", systemImage: "square.fill").foregroundStyle(.orange) }
                }.font(.caption)
                Text("\(record.regions.count) source spawn areas · tap an area for GPS · pinch to zoom")
                    .font(.caption).foregroundStyle(.secondary)
                Text("Shaded areas show where this creature can spawn on \(map.name). They are spawn regions, not guaranteed creature positions. Cave areas may overlap the surface.")
                    .font(.caption).foregroundStyle(.secondary)
            } else {
                Label("Verified spawn areas unavailable", systemImage: "info.circle").font(.subheadline)
                Text("No verified \(map.name) spawn coordinates are bundled for \(creature.name). The map remains available; check the source before searching in game.")
                    .font(.caption).foregroundStyle(.secondary)
            }
            if let url = URL(string: map.mapURL) {
                Link("Spawn map source · Wikily", destination: url).font(.caption).foregroundStyle(.cyan)
            }
        }.padding(16).frame(maxWidth: .infinity, alignment: .leading)
            .background(.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 12))
            .accessibilityElement(children: .contain).accessibilityIdentifier("creature-spawn-panel")
            .sheet(isPresented: $expanded) {
                NavigationStack {
                    VStack(spacing: 10) {
                        SpawnRegionMap(imageAsset: map.imageAsset, regions: record?.regions ?? [], selection: { selectedArea = $0 }).id(map.rawValue + ":" + creature.id)
                        if !selectedArea.isEmpty { Text(selectedArea).font(.caption.monospacedDigit()).foregroundStyle(.cyan) }
                        Text(record?.hasVerifiedRegions == true ? "Cyan: surface · Orange: includes caves · Pinch to zoom, drag to explore" : "Verified spawn areas unavailable for this creature on this map")
                            .font(.caption).foregroundStyle(.secondary).padding(.horizontal)
                    }.padding(.bottom).background(Color(red: 0.025, green: 0.045, blue: 0.065))
                        .navigationTitle("\(creature.name) · \(map.name)").navigationBarTitleDisplayMode(.inline)
                        .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { expanded = false } } }
                }
            }
    }
}

private struct SpawnRegionMap: UIViewRepresentable {
    let imageAsset: String
    let regions: [CreatureSpawnRegion]
    let selection: (String) -> Void
    func makeUIView(context: Context) -> SpawnRegionScrollView { SpawnRegionScrollView() }
    func updateUIView(_ view: SpawnRegionScrollView, context: Context) { view.selection = selection; view.configure(asset: imageAsset, regions: regions) }
}
private final class SpawnRegionScrollView: UIScrollView, UIScrollViewDelegate {
    private let terrain = MapTerrainView()
    private let surface = CAShapeLayer()
    private let caves = CAShapeLayer()
    var selection: ((String) -> Void)?
    private var regions: [CreatureSpawnRegion] = []
    private var configuredAsset: String?
    private var previousSize = CGSize.zero
    override init(frame: CGRect) {
        super.init(frame: frame)
        delegate = self; bouncesZoom = true
        showsVerticalScrollIndicator = false; showsHorizontalScrollIndicator = false
        addSubview(terrain); terrain.layer.addSublayer(surface); terrain.layer.addSublayer(caves)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectArea(_:))))
        surface.fillColor = UIColor.cyan.withAlphaComponent(0.36).cgColor
        surface.strokeColor = UIColor.cyan.withAlphaComponent(0.65).cgColor
        caves.fillColor = UIColor.orange.withAlphaComponent(0.42).cgColor
        caves.strokeColor = UIColor.orange.withAlphaComponent(0.8).cgColor
        backgroundColor = UIColor(red: 0.025, green: 0.045, blue: 0.065, alpha: 1)
        accessibilityLabel = "Creature spawn map. Pinch to zoom and drag to explore."
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    func configure(asset: String, regions: [CreatureSpawnRegion]) {
        guard configuredAsset != asset else { return }
        configuredAsset = asset; self.regions = regions
        guard let image = UIImage(named: asset) else { return }
        terrain.image = image; terrain.frame = CGRect(origin: .zero, size: image.size)
        contentSize = image.size
        let surfacePath = UIBezierPath(), cavePath = UIBezierPath()
        for region in regions where region.isWithinGPSPlane {
            let path = UIBezierPath(rect: region.rect(in: image.size))
            (region.hasCave ? cavePath : surfacePath).append(path)
        }
        surface.path = surfacePath.cgPath; caves.path = cavePath.cgPath
        surface.lineWidth = image.size.width / 1400; caves.lineWidth = image.size.width / 1400
        previousSize = .zero; setNeedsLayout()
    }
    @objc private func selectArea(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: terrain)
        guard let region = regions.first(where: { $0.isWithinGPSPlane && $0.rect(in: terrain.bounds.size).contains(point) }) else {
            selection?("Tap a shaded spawn area to read its GPS range."); return
        }
        selection?(String(format: "Spawn area · Lat %.1f–%.1f · Lon %.1f–%.1f%@", region.latMin, region.latMax, region.lonMin, region.lonMax, region.hasCave ? " · includes caves" : ""))
    }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? { terrain }
    func scrollViewDidZoom(_ scrollView: UIScrollView) { centerTerrain() }
    override func layoutSubviews() {
        super.layoutSubviews()
        if bounds.size != previousSize, bounds.width > 0, bounds.height > 0, let image = terrain.image {
            previousSize = bounds.size
            let fit = min(bounds.width / image.size.width, bounds.height / image.size.height)
            minimumZoomScale = fit; maximumZoomScale = max(fit * 16, 1)
            setZoomScale(fit, animated: false)
        }
        centerTerrain()
    }
    private func centerTerrain() {
        contentInset = UIEdgeInsets(top: max(0, (bounds.height - contentSize.height) / 2), left: max(0, (bounds.width - contentSize.width) / 2), bottom: 0, right: 0)
    }
}
