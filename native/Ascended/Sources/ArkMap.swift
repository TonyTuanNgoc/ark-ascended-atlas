import SwiftUI

enum ArkMap: String, CaseIterable, Identifiable {
    case ragnarok, island = "the-island", center = "the-center"
    case scorchedEarth = "scorched-earth", aberration, extinction, lostColony = "lost-colony"
    case genesis = "genesis-part-1", genesisOcean = "genesis-part-1-ocean", valguero, astraeos
    var id: String { rawValue }
    var expansionID: String { self == .genesisOcean ? "genesis-part-1" : rawValue }
    var expansion: ExpansionMap? { ExpansionCatalog.shared.maps.first { $0.id == expansionID } }
    static let storyMaps: [ArkMap] = [.island, .scorchedEarth, .aberration, .extinction, .lostColony, .genesis]
    static let extraMaps: [ArkMap] = [.center, .ragnarok, .valguero, .astraeos]
    var name: String { self == .genesisOcean ? "Genesis · Ocean" : expansion?.name ?? rawValue }
    var imageAsset: String { switch self { case .ragnarok: "RagnarokMap"; case .island: "TheIslandMap"; case .center: "TheCenterMap"; default: "Map-" + rawValue } }
    var summary: String { expansion?.summary ?? "" }
    var wikiURL: String { "https://ark.wiki.gg/wiki/" + (expansion?.name ?? name).replacingOccurrences(of: " ", with: "_") }
    var mapURL: String { "https://wikily.gg/ark-survival-ascended/maps/" + ((self == .genesis || self == .genesisOcean) ? "genesis" : rawValue) + "/" }
    var creatures: Result<CreatureCatalog, Error> { Self.creatureCatalogues[self]! }
    var exploration: ExplorationCatalog? { Self.explorationCatalogues[self] ?? nil }
    var information: MapInformation? { Self.informationCatalogues[self] ?? nil }
    var bosses: [MapBoss] { (try? Self.load([MapBoss].self, name: rawValue + "-bosses")) ?? [] }
    var notesKey: String { "ascended." + (self == .ragnarok ? "ragnarok" : rawValue) + ".notes.v1" }
    var collectedKey: String { self == .ragnarok ? "ascended.artifacts.collected.v1" : "ascended." + rawValue + ".artifacts.collected.v1" }
    var checklistKey: String { self == .ragnarok ? "ascended.guide.checklist.v1" : "ascended." + rawValue + ".guide.checklist.v1" }
    static func load<T: Decodable>(_ type: T.Type, name: String) throws -> T {
        guard let url = Bundle.main.url(forResource: name, withExtension: "json") else { throw CocoaError(.fileNoSuchFile) }
        return try JSONDecoder().decode(type, from: Data(contentsOf: url))
    }
    private static let creatureCatalogues = Dictionary(uniqueKeysWithValues: allCases.map { map in (map, Result { try load(CreatureCatalog.self, name: map.rawValue + "-creatures") }) })
    private static let explorationCatalogues = Dictionary(uniqueKeysWithValues: allCases.map { ($0, try? load(ExplorationCatalog.self, name: $0.rawValue + "-exploration")) })
    private static let informationCatalogues = Dictionary(uniqueKeysWithValues: allCases.map { ($0, try? load(MapInformation.self, name: $0.rawValue + "-information")) })
}
private struct ArkMapKey: EnvironmentKey { static let defaultValue: ArkMap = .ragnarok }
extension EnvironmentValues {
    var arkMap: ArkMap { get { self[ArkMapKey.self] } set { self[ArkMapKey.self] = newValue } }
}
