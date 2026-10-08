import XCTest
@testable import Ascended

final class Farming37Tests: XCTestCase {
    func testFreshIslandCoordinateReviewAndQuarantinedEvidence() throws {
        let spots = ResourceFarmCatalog.spots(in: .island)
        let mushroom = try XCTUnwrap(spots.first { $0.id == "island-swamp-mushrooms" })
        XCTAssertEqual(mushroom.lat, 74.4)
        XCTAssertEqual(mushroom.lon, 23.5)
        XCTAssertFalse(spots.contains { $0.id == "island-cave-black-pearls" })
        XCTAssertGreaterThanOrEqual(spots.filter { $0.resources.contains("Rare Flowers") }.count, 5)
    }

    func testLocationMountsAreResourceSpecificAndMapScoped() throws {
        let flower = try XCTUnwrap(ResourceFarmCatalog.spots(in: .island).first { $0.id == "island-rare-flower-red-peak" })
        XCTAssertEqual(flower.mounts(for: "Rare Flowers")?.names, ["Ankylosaurus"])
        XCTAssertNil(flower.mounts(for: "Cementing Paste"))
        XCTAssertFalse(ResourceFarmCatalog.spots(in: .ragnarok).contains { $0.id == flower.id })
        let legacy = try XCTUnwrap(ResourceFarmCatalog.spots(in: .island).first { $0.id == "island-surface-pearls" })
        XCTAssertNil(legacy.mounts(for: "Silica Pearls"))
        let cave = try XCTUnwrap(ResourceFarmCatalog.spots(in: .island).first { $0.id == "island-paste-swamp-648-350" })
        XCTAssertEqual(cave.mounts(for: "Cementing Paste")?.names, ["Beelzebufo"])
        XCTAssertEqual(cave.mounts(for: "Chitin")?.names.first, "Megatherium")
        XCTAssertTrue(cave.mounts(for: "Chitin")?.note.contains("cryopod") == true)
    }

    func testFiveSourceResourceGroupsHaveTheirOwnClips() throws {
        for resource in ["Metal", "Oil", "Obsidian", "Organic Polymer", "Cementing Paste"] {
            let spots = FarmingResourceCatalogue.spots(for: resource, in: .island)
            XCTAssertGreaterThanOrEqual(spots.count, 5, resource)
            for spot in spots {
                let guide = try XCTUnwrap(ResourceClipCatalog.guide(for: spot.id), spot.id)
                XCTAssertEqual(guide.spotID, spot.id)
                XCTAssertNotNil(guide.step(for: resource)?.url, spot.id)
            }
        }
    }
}
