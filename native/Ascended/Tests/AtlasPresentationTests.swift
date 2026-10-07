import XCTest
import UIKit
@testable import Ascended
final class AtlasPresentationTests:XCTestCase {
    func testGalleryOrderAndDeduplication() {
        XCTAssertEqual(ArkMap.island.orderedBossIDs,["megapithecus","broodmother","dragon","overseer"])
        XCTAssertEqual(ArkMap.scorchedEarth.orderedBossIDs,["manticore"])
        for map in ArkMap.allCases {XCTAssertEqual(Set(map.orderedBossIDs).count,map.orderedBossIDs.count)}
    }
    func testSinglePlayerBossEntryUsesExistingTerminalCoordinates() {
        let points=MapLocation.all(in:.island)
        let boss=points.first {$0.bossID=="megapithecus"}
        let terminal=points.first {$0.id=="obelisk-blue"}
        XCTAssertNotNil(boss);XCTAssertEqual(boss?.lat,terminal?.lat);XCTAssertEqual(boss?.lon,terminal?.lon)
        XCTAssertTrue(boss?.note.contains("arena is separate") == true)
    }
    func testCaveIconUsesSameArtworkRegardlessOfPhoto() {
        let points=MapLocation.all(in:.scorchedEarth).filter {$0.layer == .cave}
        XCTAssertFalse(points.isEmpty)
        let images=points.map {AtlasMarkerArt.image(for:$0).pngData()}
        XCTAssertTrue(images.allSatisfy {$0==images.first!})
    }
    func testBossPortraitUsesColourCutouts() {
        XCTAssertEqual(ArkMap.island.bossPortrait("broodmother"),"Cutout-Boss-broodmother")
        XCTAssertNotNil(UIImage(named:ArkMap.island.bossPortrait("megapithecus")))
        let lava=MapLocation.all(in:.ragnarok).first {$0.id=="boss-lava-arena"}
        XCTAssertEqual(lava?.bossID,"lava-elemental")
    }
    func testObelisksHaveDistinctColouredArtwork() {
        let points=MapLocation.all(in:.scorchedEarth).filter {$0.layer == .obelisk && $0.symbolOverride==nil}
        XCTAssertEqual(points.count,3)
        XCTAssertEqual(Set(points.compactMap {AtlasMarkerArt.image(for:$0).pngData()}).count,3)
    }
}
