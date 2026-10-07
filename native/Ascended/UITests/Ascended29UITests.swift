import XCTest
final class Ascended29UITests: XCTestCase {
    @MainActor func testGroupedNavigationAndCompactCreatureProfile() {
        XCUIDevice.shared.orientation = .landscapeLeft
        let app = XCUIApplication(); app.launch()
        app.buttons["maps-picker"].tap()
        let maps = app.scrollViews["maps-list"]; XCTAssertTrue(maps.waitForExistence(timeout: 5))
        let rag = app.buttons["choose-ragnarok"]
        for _ in 0..<8 { if rag.isHittable { break }; maps.swipeUp() }; rag.tap()
        let ids = ["Cốt truyện ARK", "Bản đồ", "Khai thác", "Thư viện", "Xây base", "Dino", "Artifact & Hang", "Boss"]
        for index in 1..<ids.count {
            XCTAssertGreaterThan(app.buttons["section-" + ids[index]].frame.minX, app.buttons["section-" + ids[index-1]].frame.minX)
        }
        XCTAssertEqual(app.buttons["section-Cốt truyện ARK"].label, "Story")
        app.buttons["section-Dino"].tap()
        XCTAssertEqual(app.staticTexts["module-screen-title"].label, "Dinosaurs & Creatures")
        XCTAssertEqual(app.staticTexts["creature-total-count"].label, "159")
        XCTAssertLessThanOrEqual(app.staticTexts.matching(identifier: "Ragnarok").count, 1)
        let alpha = app.buttons["filter-Alpha"]; XCTAssertTrue(alpha.isHittable); alpha.tap()
        XCTAssertTrue(app.buttons["creature-alpha-carnotaurus"].waitForExistence(timeout: 5))
        let shot = XCTAttachment(screenshot: XCUIScreen.main.screenshot()); shot.name = "Bright-Alpha-creatures"; shot.lifetime = .keepAlways; add(shot)
        app.buttons["filter-Tất cả"].tap()
        app.buttons["creature-achatina"].tap()
        let taming = app.descendants(matching: .any).matching(identifier: "creature-taming-panel").firstMatch
        let stats = app.descendants(matching: .any).matching(identifier: "creature-stats-panel").firstMatch
        let loot = app.descendants(matching: .any).matching(identifier: "creature-loot-panel").firstMatch
        XCTAssertTrue(taming.waitForExistence(timeout: 5)); XCTAssertTrue(stats.exists); XCTAssertTrue(loot.exists)
        XCTAssertLessThan(taming.frame.minX, stats.frame.minX); XCTAssertLessThan(stats.frame.minX, loot.frame.minX)
        XCTAssertEqual(taming.frame.minY, stats.frame.minY, accuracy: 3)
        XCTAssertTrue(app.staticTexts["Health"].isHittable)
        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "fact-chitin").firstMatch.isHittable)
        XCTAssertFalse(app.staticTexts["Yes"].exists)
        let detail = XCTAttachment(screenshot: XCUIScreen.main.screenshot()); detail.name = "Compact-Achatina-profile"; detail.lifetime = .keepAlways; add(detail)
    }
}
