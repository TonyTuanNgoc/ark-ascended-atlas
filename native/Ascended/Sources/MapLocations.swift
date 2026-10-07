import SwiftUI
import UIKit

enum MapLayer: String, CaseIterable { case artifact = "Artifact", cave = "Cửa hang", obelisk = "Obelisk", boss = "Boss", base = "Base", resource = "Resources", custom = "My Locations" }
extension MapLayer {
    var title: String { switch self { case .artifact: "Artifacts"; case .cave: "Cave Entrances"; case .obelisk: "Obelisks"; case .boss: "Bosses"; case .base: "Bases"; case .resource: "Resources"; case .custom: "My Locations" } }
    var symbol: String { switch self { case .artifact: "diamond.fill"; case .cave: "door.left.hand.open"; case .obelisk: "triangle.fill"; case .boss: "shield.lefthalf.filled"; case .base: "house.fill"; case .resource: "shippingbox.fill"; case .custom: "mappin" } }
}
struct MapLocation: Identifiable, Equatable {
    let id: String; let name: String; let lat: Double; let lon: Double; let layer: MapLayer
    let note: String; let routeID: String?; let artifactID: String?
    var imageAsset: String? = nil
    var farmID: String? = nil
    var resourceNames: [String] = []
    var symbolOverride:String? = nil
    var colorOverride:String? = nil
    var bossID:String? = nil
    var coordinates: String { String(format: "LAT %.2f · LON %.2f", lat, lon) }
    var title: String { layer.title }
    var symbol: String { symbolOverride ?? layer.symbol }
    var color: UIColor { if let colorOverride {switch colorOverride {case "blue":return .systemBlue;case "green":return .systemGreen;case "yellow":return .systemYellow;case "orange":return .systemOrange;case "red":return .systemRed;case "purple":return .systemPurple;case "white":return .white;default:return .systemCyan}};return switch layer { case .artifact: .systemPurple; case .cave: .systemOrange; case .boss, .obelisk: id == "obelisk-red" ? .systemRed : id == "obelisk-green" ? .systemGreen : id == "obelisk-blue" ? .systemBlue : .systemCyan; case .base: .systemGreen; case .resource: .systemYellow;case .custom:.systemCyan } }
    static func all(in map: ArkMap) -> [MapLocation] {
        let data = map.exploration ?? ExplorationCatalog(reviewedAt: "", artifacts: [], routes: [], obelisks: [])
        let references = AtlasReferenceLocations.references(in: map)
        let referencePoints = references.compactMap { reference -> MapLocation? in
            guard let source = reference.point else { return nil }
            let color = reference.color ?? ["Red Obelisk":"red", "Green Obelisk":"green", "Blue Obelisk":"blue"][reference.name]
            let id: String
            if reference.kind == .obelisk, let color { id = "obelisk-" + color }
            else if reference.kind == .caveEntrance, let routeID = reference.routeID,
                    let entrance = data.routes.first(where: { $0.id == routeID })?.entrances.first {
                id = "entrance-" + entrance.id
            } else { id = source.id }
            let note: String
            switch reference.kind {
            case .caveEntrance: note = "Identify the cave opening using the surrounding terrain."
            case .obelisk: note = "Summoning terminal; the boss arena is a separate location."
            case .terminal: note = "Check the terminal's interaction menu before preparing tribute."
            default: note = source.note
            }
            return MapLocation(id:id,name:source.name,lat:source.lat,lon:source.lon,layer:source.layer,note:note,routeID:source.routeID,artifactID:source.artifactID,imageAsset:source.imageAsset,symbolOverride:source.symbolOverride,colorOverride:color)
        }
        let replacedRoutes = Set(references.filter { $0.kind == .caveEntrance }.compactMap(\.routeID))
        var list = data.artifacts.map { MapLocation(id: "artifact-" + $0.id, name: $0.name, lat: $0.lat, lon: $0.lon, layer: .artifact, note: "Artifact collection location", routeID: $0.routeID, artifactID: $0.id) }
        list += data.routes.filter { !replacedRoutes.contains($0.id) }.flatMap { route in route.entrances.map { MapLocation(id: "entrance-" + $0.id, name: route.name + " · " + $0.label, lat: $0.lat, lon: $0.lon, layer: .cave, note: $0.kind == "area" ? "Approach area; use the terrain to locate the entrance" : "Cave entrance · use the terrain to identify it", routeID: route.id, artifactID: nil) } }
        list += data.obelisks.filter { obelisk in !referencePoints.contains(where: { $0.id == obelisk.id }) }.map { MapLocation(id: $0.id, name: $0.label, lat: $0.lat, lon: $0.lon, layer: .obelisk, note: "Summoning terminal; the arena is a separate location", routeID: nil, artifactID: nil) }
        list += referencePoints
        for reference in references where reference.point != nil {
            for boss in reference.bossIDs {
                list.append(MapLocation(id:"boss-summon-"+boss,name:boss.capitalized+" · summon point",lat:reference.lat,lon:reference.lon,layer:.boss,note:"Enter the boss encounter here; this is not the remote arena position.",routeID:reference.routeID,artifactID:nil,bossID:boss))
            }
        }
        // Verified Single Player entry terminals use existing atlas coordinates.
        // These markers deliberately describe summoning/approach, not arena GPS.
        let entryIDs: [String: [String]]
        switch map {
        case .island: entryIDs = ["broodmother":["obelisk-green"], "megapithecus":["obelisk-blue"], "dragon":["obelisk-red"], "overseer":["entrance-tek-0"]]
        case .center: entryIDs = ["broodmother":["obelisk-blue","obelisk-green","obelisk-red"], "megapithecus":["obelisk-blue","obelisk-green","obelisk-red"]]
        case .scorchedEarth: entryIDs = ["manticore":["obelisk-blue","obelisk-green","obelisk-red"]]
        case .ragnarok: entryIDs = ["nunatak":["obelisk-blue","obelisk-green","obelisk-red"]]
        default: entryIDs = [:]
        }
        for (boss, ids) in entryIDs where !list.contains(where: { $0.bossID == boss }) {
            for id in ids {
                if let entry = list.first(where: { $0.id == id }) {
                    list.append(MapLocation(id:"boss-summon-"+boss+"-"+id, name:map.bossName(boss)+" · "+entry.name, lat:entry.lat, lon:entry.lon, layer:.boss, note:"Summoning terminal or cave approach; the boss arena is separate.", routeID:entry.routeID, artifactID:nil, bossID:boss))
                }
            }
        }
        if map == .ragnarok { list.append(MapLocation(id: "boss-lava-arena", name: "Lava Elemental · arena", lat: 21.6, lon: 26.9, layer: .boss, note: "End of Jungle Dungeon · optional loot encounter", routeID: "jungle", artifactID: nil, bossID: "lava-elemental")) }
        list += (map.bases?.locations ?? []).map { MapLocation(id: "base-" + $0.id, name: $0.name, lat: $0.lat, lon: $0.lon, layer: .base, note: "Base scouting location · check the terrain before building", routeID: nil, artifactID: nil) }
        for index in list.indices {
            let point = list[index]
            if point.imageAsset != nil { continue }
            if let id = point.artifactID { list[index].imageAsset = data.artifacts.first { $0.id == id }?.imageAsset }
            else if point.layer == .cave, point.routeID != nil { list[index].imageAsset = UIImage(named: "Entrance-" + map.rawValue + "-" + point.id.replacingOccurrences(of: "entrance-", with: "")) != nil ? "Entrance-" + map.rawValue + "-" + point.id.replacingOccurrences(of: "entrance-", with: "") : nil }
            else if point.layer == .base { list[index].imageAsset = "Base-" + point.id.replacingOccurrences(of: "base-", with: "") }
            else if point.id.hasPrefix("obelisk-") { list[index].imageAsset = "Map-Obelisk" }
            else if point.id == "boss-lava-arena" { list[index].imageAsset = "Boss-lava-elemental" }
        }
        return (list + ResourceFarmCatalog.spots(in: map).map(\.point)).filter {
            $0.lat.isFinite && $0.lon.isFinite && (0...100).contains($0.lat) && (0...100).contains($0.lon)
        }
    }
}
