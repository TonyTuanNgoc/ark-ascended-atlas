import XCTest

final class Ascended21UITests: XCTestCase {
    @MainActor func testScorchedCampaignArmyAndGammaTribute() {
        XCUIDevice.shared.orientation = .landscapeLeft
        let app = XCUIApplication()
        app.launch()
        app.buttons["map-group-Cốt truyện"].tap()
        app.buttons["choose-scorched-earth"].tap()
        app.buttons["section-Boss"].tap()
        let boss = app.buttons["boss-manticore"].firstMatch
        for _ in 0..<4 { if boss.isHittable { break }; app.scrollViews.firstMatch.swipeUp() }
        XCTAssertTrue(boss.waitForExistence(timeout: 5))
        boss.tap()
        XCTAssertTrue(app.buttons["bossArmy"].waitForExistence(timeout: 5))
        app.buttons["bossArmy"].tap()
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "Rex")).firstMatch.waitForExistence(timeout: 5))
        let shot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        shot.name = "Scorched-native-army-options"
        shot.lifetime = .keepAlways
        add(shot)
    }
}
