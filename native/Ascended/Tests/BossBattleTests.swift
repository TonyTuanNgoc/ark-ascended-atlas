import XCTest
@testable import Ascended

final class BossBattleTests: XCTestCase {
    func testBothRequestedMapsHaveEveryGalleryEncounter() {
        XCTAssertEqual(BossBattleGuide.all.count, 9)
        for map in [ArkMap.ragnarok, .island] {
            for id in map.orderedBossIDs { XCTAssertNotNil(BossBattleGuide.find(map: map, bossID: id), id) }
        }
        XCTAssertNil(BossBattleGuide.find(map: .island, bossID: "nunatak"))
        XCTAssertNil(BossBattleGuide.find(map: .ragnarok, bossID: "dragon"))
    }
    func testArenaBudgetsDoNotAccidentallyAddA21stTame() {
        for guide in BossBattleGuide.all {
            XCTAssertFalse(guide.armies.isEmpty)
            for army in guide.armies {
                XCTAssertLessThanOrEqual(army.tameCount, 20, guide.id + army.id)
                for member in army.members { XCTAssertFalse(member.name.isEmpty); XCTAssertFalse(member.quantity.isEmpty) }
                if army.id == "rex" || army.id == "theri" { XCTAssertEqual(army.tameCount, 20) }
            }
        }
    }
    func testShortBriefingsStayInsideRealVideoDurations() {
        for guide in BossBattleGuide.all {
            XCTAssertFalse(guide.videos.isEmpty, guide.id)
            for video in guide.videos {
                XCTAssertLessThanOrEqual(video.briefSeconds, 120)
                XCTAssertGreaterThan(video.briefSeconds, 0)
                for segment in video.segments {
                    XCTAssertGreaterThanOrEqual(segment.start, 0)
                    XCTAssertGreaterThan(segment.end, segment.start)
                    XCTAssertLessThanOrEqual(segment.end, video.duration)
                }
                XCTAssertTrue(guide.sources.contains { $0.url.contains(video.videoID) })
            }
        }
    }
    func testEveryStatOptionResolvesToItsOwnMapAndBoss() {
        for guide in BossBattleGuide.all {
            let map = ArkMap(rawValue: guide.mapID)!
            for army in guide.armies {
                if let id = army.targetOptionID { XCTAssertNotNil(map.campaign?.loadouts.first { $0.bossID == guide.bossID }?.options.first { $0.id == id }, guide.id + id) }
            }
        }
    }
    func testSpiritPairSharesOneFightRatherThanTwoInventedArenas() {
        let bear = BossBattleGuide.find(map: .ragnarok, bossID: "spirit-dire-bear")!
        let wolf = BossBattleGuide.find(map: .ragnarok, bossID: "spirit-direwolf")!
        XCTAssertEqual(bear.videos.map(\.videoID), wolf.videos.map(\.videoID))
        XCTAssertEqual(bear.combat.map(\.action), wolf.combat.map(\.action))
    }
    func testOverseerCaveClearerDoesNotCountAsAnArenaTame() {
        let guide = BossBattleGuide.find(map: .island, bossID: "overseer")!
        XCTAssertEqual(guide.armies.first?.tameCount, 20)
        XCTAssertFalse(guide.armies.first!.members.contains { $0.name == "Carcharodontosaurus" })
        XCTAssertTrue(guide.armies.first!.note.contains("stays out"))
        XCTAssertTrue(guide.videos.first!.note.contains("Carcha is not"))
    }
}
