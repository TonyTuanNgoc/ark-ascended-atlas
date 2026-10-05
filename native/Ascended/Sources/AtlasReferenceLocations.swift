import Foundation

/// ASA source references. This catalogue deliberately distinguishes source atlas
/// coordinates from independently observed in-game GPS and arena positions.
struct AtlasReferenceCatalog: Decodable {
    let schemaVersion: Int
    let acquiredAt: String
    let coordinateDisclosure: String
    let locations: [AtlasReferenceLocation]
    let coverage: [AtlasReferenceCoverage]
}

struct AtlasReferenceCoverage: Decodable {
    let mapID: String
    let sourceMapID: Int
    let entranceCount: Int
    let terminalCount: Int
    let status: String
    let limitations: [String]
    let videoGPSStatus: String
}

struct AtlasReferenceSource: Decodable {
    let url: String
    let dataURL: String
    let revisionID: Int?
    let cacheSHA256: String
    let sourceKind: String
}

struct AtlasReferenceLocation: Decodable, Identifiable {
    enum Kind: String, Decodable { case caveEntrance, obelisk, terminal, artifactSite, bossSummon, arenaApproach }
    enum GeometryStatus: String, Decodable { case insideAtlas, outsideAtlas, unresolved }
    let id: String
    let mapID: String
    let name: String
    let lat: Double
    let lon: Double
    let kind: Kind
    let granularity: String
    let verification: String
    let coordinatePlane: String
    let geometryStatus: GeometryStatus
    let note: String
    let routeID: String?
    let artifactID: String?
    let bossIDs: [String]
    let color: String?
    let source: AtlasReferenceSource
    let photoURL: String?
    let photoStatus: String?
    let imageAsset: String?

    /// Outside-plane records remain in the catalogue, without a misleading
    /// clamped marker. The caller controls map projection and source priority.
    var point: MapLocation? {
        guard geometryStatus == .insideAtlas, (0...100).contains(lat), (0...100).contains(lon) else { return nil }
        let layer: MapLayer = switch kind {
        case .caveEntrance: .cave
        case .obelisk, .terminal: .obelisk
        case .artifactSite: .artifact
        case .bossSummon, .arenaApproach: .boss
        }
        var value = MapLocation(id: id, name: name, lat: lat, lon: lon, layer: layer, note: note, routeID: routeID, artifactID: kind == .artifactSite ? artifactID : nil)
        value.imageAsset = imageAsset
        value.colorOverride = color
        if kind == .terminal { value.symbolOverride = "door.left.hand.open" }
        return value
    }
}

enum AtlasReferenceLocations {
    static let catalogue: AtlasReferenceCatalog? = try? ArkMap.load(AtlasReferenceCatalog.self, name: "map-reference-locations")
    static func references(in map: ArkMap) -> [AtlasReferenceLocation] {
        catalogue?.locations.filter { $0.mapID == map.rawValue } ?? []
    }
    static func points(in map: ArkMap) -> [MapLocation] {
        references(in: map).compactMap(\.point)
    }
    static func coverage(in map: ArkMap) -> AtlasReferenceCoverage? {
        catalogue?.coverage.first { $0.mapID == map.rawValue }
    }
}
