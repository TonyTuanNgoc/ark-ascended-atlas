import XCTest
import UIKit
@testable import Ascended

final class AtlasContentTests: XCTestCase {
    func testMainMapBaseCataloguesHaveTenDistinctSourceBackedCandidates() throws {
        for map in [ArkMap.ragnarok, .island, .center] {
            let catalogue = try XCTUnwrap(map.bases, map.rawValue)
            XCTAssertEqual(catalogue.locations.count, 10)
            XCTAssertEqual(Set(catalogue.locations.map(\.id)).count, 10)
            for spot in catalogue.locations {
                XCTAssertTrue((0...100).contains(spot.lat) && (0...100).contains(spot.lon), spot.id)
                XCTAssertTrue(catalogue.videos.contains { $0.id == spot.videoID }, spot.id)
                XCTAssertNotNil(UIImage(named: "Base-" + spot.id), spot.id)
                XCTAssertFalse(spot.sources.isEmpty, spot.id)
                XCTAssertFalse(spot.support.isEmpty, spot.id)
                XCTAssertFalse(spot.pros.isEmpty || spot.cons.isEmpty || spot.layout.isEmpty, spot.id)
            }
        }
    }

    func testReferenceCatalogueAndStableMapIdentifiers() throws {
        let catalogue = try XCTUnwrap(AtlasReferenceLocations.catalogue)
        XCTAssertGreaterThan(catalogue.locations.count, 60)
        for map in ArkMap.allCases {
            let points = MapLocation.all(in: map)
            XCTAssertEqual(Set(points.map(\.id)).count, points.count, map.rawValue)
            for point in points {
                XCTAssertTrue(point.lat.isFinite && point.lon.isFinite)
                XCTAssertTrue((0...100).contains(point.lat) && (0...100).contains(point.lon), point.id)
            }
        }
        for record in catalogue.locations {
            XCTAssertFalse(record.source.url.isEmpty)
            XCTAssertEqual(record.source.cacheSHA256.count, 64)
            if record.geometryStatus != .insideAtlas { XCTAssertNil(record.point, record.id) }
        }
        let island = MapLocation.all(in: .island)
        XCTAssertEqual(island.filter { $0.layer == .obelisk }.count, 3)
        let ragnarok = MapLocation.all(in: .ragnarok).filter { $0.layer == .obelisk }
        XCTAssertEqual(ragnarok.count, 3)
        XCTAssertEqual(Set(ragnarok.map(\.id)), Set(["obelisk-red", "obelisk-green", "obelisk-blue"]))
        let tek = try XCTUnwrap(island.first { $0.id == "entrance-tek-0" })
        XCTAssertEqual(tek.lat, 42.041, accuracy: 0.001)
        XCTAssertEqual(tek.lon, 37.301, accuracy: 0.001)
        XCTAssertEqual(tek.routeID, "tek")
    }

    func testExpansionCampaignsDecodeAndHavePlayableSteps() throws {
        for map in [ArkMap.scorchedEarth, .aberration, .extinction, .valguero, .lostColony, .genesis, .astraeos] {
            let campaign = try XCTUnwrap(map.campaign, map.rawValue)
            XCTAssertFalse(campaign.summary.isEmpty)
            XCTAssertFalse(campaign.sharedPreparation.isEmpty)
            XCTAssertGreaterThanOrEqual(campaign.steps.count, 3)
            XCTAssertEqual(Set(campaign.steps.map(\.id)).count, campaign.steps.count)
            for step in campaign.steps { XCTAssertFalse(step.reason.isEmpty, step.id) }
        }
        for map in ArkMap.allCases {
            for boss in map.bosses {
                XCTAssertNotNil(UIImage(named: boss.imageAsset), boss.id)
                XCTAssertEqual(boss.levels.count, 3, boss.id)
                XCTAssertTrue(boss.elements.isEmpty || boss.elements.count == 3, boss.id)
                for tribute in boss.tribute { XCTAssertEqual(tribute.quantities.count, 3, tribute.name) }
            }
        }
        let manticore = try XCTUnwrap(ArkMap.scorchedEarth.bosses.first { $0.id == "manticore" })
        XCTAssertTrue(manticore.tribute.contains { ($0.quantities.first ?? 0) > 0 })
    }

    func testExpansionEntrancesResolveAndOutsidePlaneStaysOffMap() throws {
        for map in [ArkMap.scorchedEarth, .aberration, .lostColony, .astraeos] {
            let routes = try XCTUnwrap(map.exploration).routes
            XCTAssertFalse(routes.isEmpty, map.rawValue)
            XCTAssertEqual(Set(routes.map(\.id)).count, routes.count)
            for reference in AtlasReferenceLocations.references(in: map) where reference.kind == .caveEntrance {
                let route = try XCTUnwrap(routes.first { $0.id == reference.routeID }, reference.id)
                XCTAssertTrue(route.entrances.contains { abs($0.lat - reference.lat) < 0.001 && abs($0.lon - reference.lon) < 0.001 })
                if reference.point == nil {
                    XCTAssertFalse(MapLocation.all(in: map).contains { $0.routeID == route.id })
                }
            }
        }
    }
}
