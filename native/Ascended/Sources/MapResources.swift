import SwiftUI
import UIKit

struct ResourceNode: Decodable {
    let resource_type: String
    let lat: Double
    let lon: Double
    let is_cave: Bool
}
enum MapResources {
    private static let catalog = Dictionary(uniqueKeysWithValues: ArkMap.allCases.map { ($0, (try? ArkMap.load([ResourceNode].self, name: $0.rawValue + "-resources")) ?? []) })
    private static let pointCatalog = Dictionary(uniqueKeysWithValues: ArkMap.allCases.map { map in
        (map, nodes(in: map).enumerated().map { index, node in
            MapLocation(id: "resource-\(map.rawValue)-\(index)", name: node.resource_type, lat: node.lat, lon: node.lon, layer: .resource, note: node.is_cave ? "Trong hang · cần tìm cửa vào trước." : "Điểm thu thập ngoài trời.", routeID: nil, artifactID: nil, imageAsset: asset(for: node.resource_type))
        })
    })
    static func nodes(in map: ArkMap) -> [ResourceNode] { catalog[map] ?? [] }
    static func points(in map: ArkMap) -> [MapLocation] { pointCatalog[map] ?? [] }
    static func types(in map: ArkMap) -> [String] { Set(nodes(in: map).map(\.resource_type)).sorted() }
    static func asset(for type: String) -> String {
        switch type {
        case "Beaver Dam": return "Item-beaver-dam"
        case "Cactus with few berries": return "Item-cactus-sap"
        case "Gem Bio": return "Item-blue-gem"
        case "Sandpile": return "Item-sand"
        default: return "Item-" + type.lowercased().replacingOccurrences(of: " ", with: "-")
        }
    }
    static func label(for type: String) -> String {
        switch type { case "Cactus with few berries": "Cactus"; case "Gem Bio": "Blue Gem"; case "Sandpile": "Sand"; default: type }
    }
}

/// Draw visible resource clusters at screen resolution, without thousands of UIButtons.
/// Every cluster retains an actual source node, never an averaged GPS position.
final class ResourceSurface: UIView {
    var points: [MapLocation] = [] {
        didSet {
            guard points.count != oldValue.count || !zip(points, oldValue).allSatisfy({ $0.0.id == $0.1.id }) else { return }
            bins = Dictionary(grouping: points) { Int(floor($0.lat)) * 101 + Int(floor($0.lon)) }
        }
    }
    private var bins: [Int: [MapLocation]] = [:]
    var choose: ((MapLocation) -> Void)?
    private var clusters: [(position: CGPoint, point: MapLocation, count: Int)] = []
    private var pictures: [String: UIImage] = [:]
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear; isOpaque = false
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped(_:))))
        accessibilityIdentifier = "resourceMapSurface"
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    func refresh(on scroll: MapScrollView, avoiding markers: [CGPoint]) {
        frame = CGRect(origin: scroll.contentOffset, size: scroll.bounds.size)
        var cells: [String: (CGPoint, MapLocation, Int)] = [:]
        let zero = scroll.imageView.convert(CGPoint.zero, to: scroll)
        let origin = CGPoint(x: zero.x - scroll.bounds.minX, y: zero.y - scroll.bounds.minY)
        let width = scroll.imageView.bounds.width * scroll.zoomScale
        let height = scroll.imageView.bounds.height * scroll.zoomScale
        guard width > 0, height > 0 else { return }
        let minLon = max(0, min(100, Int(floor((-16 - origin.x) / width * 100))))
        let maxLon = max(0, min(100, Int(floor((bounds.width + 16 - origin.x) / width * 100))))
        let minLat = max(0, min(100, Int(floor((-16 - origin.y) / height * 100))))
        let maxLat = max(0, min(100, Int(floor((bounds.height + 16 - origin.y) / height * 100))))
        var visible: [MapLocation] = []
        if minLat <= maxLat && minLon <= maxLon {
            for lat in minLat...maxLat { for lon in minLon...maxLon { visible.append(contentsOf: bins[lat * 101 + lon] ?? []) } }
        }
        for point in visible {
            let position = CGPoint(x: origin.x + point.lon / 100 * width, y: origin.y + point.lat / 100 * height)
            guard position.x >= -16, position.y >= -16, position.x <= bounds.width + 16, position.y <= bounds.height + 16 else { continue }
            guard !markers.contains(where: { hypot($0.x - position.x, $0.y - position.y) < 30 }) else { continue }
            let key = "\(Int(floor(position.x / 48))):\(Int(floor(position.y / 48)))"
            if let cell = cells[key] { cells[key] = (cell.0, cell.1, cell.2 + 1) }
            else { cells[key] = (position, point, 1) }
        }
        clusters = cells.keys.sorted().compactMap { cells[$0] }.map { ($0.0, $0.1, $0.2) }
        accessibilityValue = "\(points.count) điểm · \(clusters.count) cụm đang hiện"
        accessibilityElements = clusters.map { cluster in
            let element = ResourceAccessibilityElement(accessibilityContainer: self)
            element.accessibilityIdentifier = "resource-pin-" + cluster.point.id
            element.accessibilityLabel = MapResources.label(for: cluster.point.name) + ", " + cluster.point.coordinates
            element.accessibilityTraits = .button
            element.accessibilityFrameInContainerSpace = CGRect(x: cluster.position.x - 12, y: cluster.position.y - 12, width: 24, height: 24)
            element.activate = { [weak self] in self?.select(cluster) }
            return element
        }
        setNeedsDisplay()
    }
    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        for cluster in clusters {
            let box = CGRect(x: cluster.position.x - 12, y: cluster.position.y - 12, width: 24, height: 24)
            ctx.setFillColor(UIColor.black.withAlphaComponent(0.48).cgColor)
            ctx.fillEllipse(in: box)
            if let asset = cluster.point.imageAsset {
                if pictures[asset] == nil { pictures[asset] = UIImage(named: asset) }
                pictures[asset]?.draw(in: box.insetBy(dx: 2, dy: 2))
            }
            if cluster.count > 1 {
                let text = String(cluster.count) as NSString
                text.draw(at: CGPoint(x: box.maxX - 4, y: box.minY - 5), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 9), .foregroundColor: UIColor.white, .strokeColor: UIColor.black, .strokeWidth: -4.0])
            }
        }
    }
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        clusters.contains { hypot($0.position.x - point.x, $0.position.y - point.y) < 17 }
    }
    @objc private func tapped(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: self)
        guard let nearest = clusters.min(by: { hypot($0.position.x - point.x, $0.position.y - point.y) < hypot($1.position.x - point.x, $1.position.y - point.y) }) else { return }
        select(nearest)
    }
    private func select(_ cluster: (position: CGPoint, point: MapLocation, count: Int)) {
        var node = cluster.point
        if cluster.count > 1 {
            node = MapLocation(id: node.id, name: node.name, lat: node.lat, lon: node.lon, layer: .resource, note: node.note + " Cụm \(cluster.count) điểm tài nguyên; phóng to để tách từng điểm.", routeID: nil, artifactID: nil, imageAsset: node.imageAsset)
        }
        choose?(node)
    }
}

private final class ResourceAccessibilityElement: UIAccessibilityElement {
    var activate: (() -> Void)?
    override func accessibilityActivate() -> Bool { activate?(); return true }
}
