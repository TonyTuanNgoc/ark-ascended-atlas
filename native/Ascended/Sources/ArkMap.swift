import SwiftUI

enum ArkMap: String, CaseIterable, Identifiable {
    case ragnarok, island = "the-island", center = "the-center"
    var id: String { rawValue }
    var name: String { switch self { case .ragnarok: "Ragnarok"; case .island: "The Island"; case .center: "The Center" } }
    var imageAsset: String { switch self { case .ragnarok: "RagnarokMap"; case .island: "TheIslandMap"; case .center: "TheCenterMap" } }
    var summary: String { switch self { case .ragnarok: "Nunatak · hang băng · Wyvern · 10 artifact"; case .island: "4 boss · Tek Cave · ascension · 10 artifact"; case .center: "Đảo nổi · thế giới ngầm · 2 guardian · 11 artifact" } }
    var wikiURL: String { "https://ark.wiki.gg/wiki/" + (self == .island ? "The_Island" : self == .center ? "Center" : "Ragnarok") }
    var mapURL: String { "https://wikily.gg/ark-survival-ascended/maps/" + rawValue + "/" }
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
