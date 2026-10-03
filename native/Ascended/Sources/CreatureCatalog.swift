import Foundation

struct CreatureCatalog: Decodable {
    let reviewedAt: String
    let spawnRegistryEntries: Int
    let wikiSupplementEntries: Int
    let creatures: [Creature]
}
struct Creature: Decodable, Identifiable {
    let id: String
    let name: String
    let aliases: [String]
    let group: String
    let dlc: String
    let sourceURL: String
    let rosterSource: String
    let reviewedAt: String
    let detailAvailable: Bool
    let tameable: Bool?
    let diet: String
    let method: String
    let foods: [String]
    let drops: [String]
    let immobilizedBy: [String]
    let stats: [CreatureStat]
    let archive: LegacyCreatureNote?
    let updateNote: String
    let updateSourceURL: String?
    var iconAsset: String { "Dino-" + id }
}
struct CreatureStat: Decodable { let label: String; let value: Double }
struct LegacyCreatureNote: Decodable {
    let date: String; let method: String; let food: String; let notes: String; let source: String
}
