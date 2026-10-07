import XCTest
@testable import Ascended

final class CreatureSpawnTests: XCTestCase {
    func testEveryMapAndCreatureHasAnExplicitMapScopedRecord() throws {
        let catalog = try XCTUnwrap(CreatureSpawnCatalog.shared)
        XCTAssertEqual(catalog.schemaVersion, 1)
        XCTAssertEqual(Set(catalog.maps.map(\.mapID)), Set(ArkMap.allCases.map(\.rawValue)))
        XCTAssertEqual(Set(catalog.records.map { $0.mapID + ":" + $0.creatureID }).count, catalog.records.count)
        for map in ArkMap.allCases {
            let creatures = try map.creatures.get().creatures
            for creature in creatures {
                let record = try XCTUnwrap(catalog.record(map: map, creatureID: creature.id), "Missing explicit spawn status: \(map.rawValue)/\(creature.id)")
                XCTAssertEqual(record.hasVerifiedRegions, !record.regions.isEmpty)
                XCTAssertTrue(record.regions.allSatisfy(\.isWithinGPSPlane))
                XCTAssertTrue(record.sourceURL.hasPrefix("https://wikily.gg/"))
            }
        }
    }
    func testIslandArgentavisAndIndependentCoordinatePlanes() throws {
        let catalog = try XCTUnwrap(CreatureSpawnCatalog.shared)
        let island = try XCTUnwrap(catalog.record(map: .island, creatureID: "argentavis"))
        XCTAssertTrue(island.hasVerifiedRegions)
        let ragnarok = try XCTUnwrap(catalog.record(map: .ragnarok, creatureID: "argentavis"))
        XCTAssertNotEqual(island.sourceURL, ragnarok.sourceURL)
        let land = try XCTUnwrap(catalog.maps.first { $0.mapID == ArkMap.genesis.rawValue })
        let ocean = try XCTUnwrap(catalog.maps.first { $0.mapID == ArkMap.genesisOcean.rawValue })
        XCTAssertNotEqual(land.registryMapID, ocean.registryMapID, "Genesis ocean must never reuse the main plane's GPS grid")
    }
    func testCoastalRegionsRetainSourceBoundsAndDisplayOnlyViewportIntersection() throws {
        let catalog = try XCTUnwrap(CreatureSpawnCatalog.shared)
        let liopleurodon = try XCTUnwrap(catalog.record(map: .island, creatureID: "liopleurodon"))
        let pelagornis = try XCTUnwrap(catalog.record(map: .astraeos, creatureID: "pelagornis"))
        XCTAssertEqual(liopleurodon.regions.count, 4)
        XCTAssertEqual(pelagornis.regions.count, 2)
        for record in [liopleurodon, pelagornis] {
            XCTAssertTrue(record.hasVerifiedRegions)
            for region in record.regions {
                let source = try XCTUnwrap(region.sourceBounds)
                XCTAssertEqual(region.displayIntersectionOfSourceRegion, true)
                XCTAssertEqual(region.latMin, max(0, source.latMin))
                XCTAssertEqual(region.latMax, min(100, source.latMax))
                XCTAssertEqual(region.lonMin, max(0, source.lonMin))
                XCTAssertEqual(region.lonMax, min(100, source.lonMax))
                XCTAssertTrue(region.isWithinGPSPlane)
            }
        }
    }
    func testRegionProjectionKeepsLatitudeVerticalAndLongitudeHorizontal() throws {
        let region = try JSONDecoder().decode(CreatureSpawnRegion.self, from: Data(#"{"lat_min":20,"lat_max":30,"lon_min":60,"lon_max":80,"count":1,"has_cave":false}"#.utf8))
        let rect = region.rect(in: CGSize(width: 1000, height: 500))
        XCTAssertEqual(rect.origin.x, 600); XCTAssertEqual(rect.origin.y, 100)
        XCTAssertEqual(rect.width, 200); XCTAssertEqual(rect.height, 50)
        XCTAssertTrue(region.isWithinGPSPlane)
    }
}
