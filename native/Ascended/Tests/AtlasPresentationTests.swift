import XCTest
import UIKit
@testable import Ascended
final class AtlasPresentationTests:XCTestCase {
    func testIslandArtifactsResolveTheirOwnCaveClips() {
        let points = MapLocation.all(in: .island).filter { $0.layer == .artifact }
        XCTAssertEqual(points.count, 10)
        for point in points {
            let guide = ArkMap.island.caveGIFs.first { $0.routeID == point.routeID }
            XCTAssertNotNil(guide, point.name)
            XCTAssertNotNil(guide?.sections.first?.steps.first?.gifURL, point.name)
        }
    }
    func testPopupPlacementKeepsThePinExposedAtMapEdges() {
        let card = CGSize(width: 238, height: 220)
        let viewport = CGSize(width: 560, height: 560)
        for anchor in [CGPoint(x: 280, y: 280), CGPoint(x: 20, y: 20), CGPoint(x: 540, y: 540), CGPoint(x: 280, y: 480)] {
            let origin = AtlasPopupViewport.popupOrigin(anchor: anchor, card: card, viewport: viewport)
            let frame = CGRect(origin: origin, size: card)
            XCTAssertTrue(CGRect(origin: .zero, size: viewport).contains(frame))
            XCTAssertFalse(frame.intersects(CGRect(x: anchor.x - 22, y: anchor.y - 22, width: 44, height: 44)))
        }
    }
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
