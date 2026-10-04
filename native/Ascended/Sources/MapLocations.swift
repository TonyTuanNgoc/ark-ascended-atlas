import SwiftUI
import UIKit

enum MapLayer: String, CaseIterable { case artifact = "Artifact", cave = "Cửa hang", obelisk = "Obelisk", boss = "Boss", base = "Base", resource = "Resources" }
extension MapLayer {
    var title: String { switch self { case .artifact: "Artifacts"; case .cave: "Cave Entrances"; case .obelisk: "Obelisks"; case .boss: "Bosses"; case .base: "Bases"; case .resource: "Resources" } }
    var symbol: String { switch self { case .artifact: "diamond.fill"; case .cave: "door.left.hand.open"; case .obelisk: "triangle.fill"; case .boss: "shield.lefthalf.filled"; case .base: "house.fill"; case .resource: "shippingbox.fill" } }
}
struct MapLocation: Identifiable {
    let id: String; let name: String; let lat: Double; let lon: Double; let layer: MapLayer
    let note: String; let routeID: String?; let artifactID: String?
    var imageAsset: String? = nil
    var farmID: String? = nil
    var resourceNames: [String] = []
    var coordinates: String { String(format: "LAT %.2f · LON %.2f", lat, lon) }
    var title: String { layer.title }
    var symbol: String { layer.symbol }
    var color: UIColor { switch layer { case .artifact: .systemPurple; case .cave: .systemOrange; case .boss, .obelisk: id == "obelisk-red" ? .systemRed : id == "obelisk-green" ? .systemGreen : id == "obelisk-blue" ? .systemBlue : .systemCyan; case .base: .systemGreen; case .resource: .systemYellow } }
    static func all(in map: ArkMap) -> [MapLocation] {
        let data = map.exploration ?? ExplorationCatalog(reviewedAt: "", artifacts: [], routes: [], obelisks: [])
        var list = data.artifacts.map { MapLocation(id: "artifact-" + $0.id, name: $0.name, lat: $0.lat, lon: $0.lon, layer: .artifact, note: "Artifact collection location", routeID: $0.routeID, artifactID: $0.id) }
        list += data.routes.flatMap { route in route.entrances.map { MapLocation(id: "entrance-" + $0.id, name: route.name + " · " + $0.label, lat: $0.lat, lon: $0.lon, layer: .cave, note: $0.kind == "area" ? "Approach area; use the terrain to locate the entrance" : "Cave entrance · use the terrain to identify it", routeID: route.id, artifactID: nil) } }
        list += data.obelisks.map { MapLocation(id: $0.id, name: $0.label + (map == .ragnarok ? " · summon Nunatak" : " · boss portal"), lat: $0.lat, lon: $0.lon, layer: .obelisk, note: "Summoning location; teleport to the boss arena", routeID: nil, artifactID: nil) }
        if map == .ragnarok { list.append(MapLocation(id: "boss-lava-arena", name: "Lava Elemental · arena", lat: 21.6, lon: 26.9, layer: .boss, note: "End of Jungle Dungeon · optional loot encounter", routeID: "jungle", artifactID: nil)) }
        list += (map.bases?.locations ?? []).map { MapLocation(id: "base-" + $0.id, name: $0.name, lat: $0.lat, lon: $0.lon, layer: .base, note: "Base scouting location · check the terrain before building", routeID: nil, artifactID: nil) }
        for index in list.indices {
            let point = list[index]
            if let id = point.artifactID { list[index].imageAsset = data.artifacts.first { $0.id == id }?.imageAsset }
            else if point.layer == .cave, point.routeID != nil { list[index].imageAsset = UIImage(named: "Entrance-" + map.rawValue + "-" + point.id.replacingOccurrences(of: "entrance-", with: "")) != nil ? "Entrance-" + map.rawValue + "-" + point.id.replacingOccurrences(of: "entrance-", with: "") : nil }
            else if point.layer == .base { list[index].imageAsset = "Base-" + point.id.replacingOccurrences(of: "base-", with: "") }
            else if point.id.hasPrefix("obelisk-") { list[index].imageAsset = "Map-Obelisk" }
            else if point.id == "boss-lava-arena" { list[index].imageAsset = "Boss-lava-elemental" }
        }
        return list + MapResources.points(in: map) + ResourceFarmCatalog.spots(in: map).map(\.point)
    }
}
