import XCTest

final class BossBattleUITests: XCTestCase {
    @MainActor func testIslandLargePlanTabsAndNamedArmy() {
        XCUIDevice.shared.orientation = .landscapeLeft
        let app = XCUIApplication(); app.launch()
        choose("the-island", app)
        app.buttons["section-Boss"].tap()
        app.buttons["boss-card-megapithecus"].tap()
        XCTAssertTrue(app.buttons["battle-tab-Army"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Megapithecus"].firstMatch.exists)
        XCTAssertTrue(app.buttons["battle-play-brief"].exists)
        app.swipeUp()
        XCTAssertTrue(app.descendants(matching: .any)["battle-item-Rex"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["battle-item-Yutyrannus"].exists)
        shot("Island-large-army")
        app.swipeDown()
        app.buttons["battle-tab-Tribute"].tap()
        app.swipeUp()
        XCTAssertTrue(app.staticTexts["Artifact of the Brute"].exists)
        app.swipeDown()
        app.buttons["battle-tab-Location"].tap()
        app.swipeUp()
        XCTAssertTrue(app.descendants(matching: .any)["boss-location-map"].exists)
        XCTAssertTrue(app.buttons["pin-boss-summon-megapithecus-obelisk-blue"].exists)
        shot("Island-large-location")
        app.buttons["Close boss"].tap()
        XCTAssertTrue(app.buttons["boss-card-overseer"].waitForExistence(timeout: 5))
    }
    @MainActor func testRagnarokFivePlansAndPortraitPreparation() {
        XCUIDevice.shared.orientation = .landscapeLeft
        let app = XCUIApplication(); app.launch()
        choose("ragnarok", app)
        app.buttons["section-Boss"].tap()
        for id in ["iceworm-queen", "lava-elemental", "spirit-dire-bear", "spirit-direwolf", "nunatak"] {
            app.buttons["boss-card-" + id].tap()
            XCTAssertTrue(app.buttons["battle-tab-Preparation"].waitForExistence(timeout: 5), id)
            XCTAssertTrue(app.buttons["battle-play-brief"].exists, id)
            app.buttons["battle-tab-Combat"].tap()
            shot("Ragnarok-" + id)
            app.buttons["Close boss"].tap()
        }
        app.buttons["boss-card-lava-elemental"].tap()
        XCUIDevice.shared.orientation = .portrait
        app.swipeUp()
        app.buttons["battle-tab-Preparation"].tap()
        app.swipeUp()
        XCTAssertTrue(app.descendants(matching: .any)["battle-item-Rocket Launcher"].exists)
        shot("Lava-portrait-preparation")
        app.buttons["Close boss"].tap()
        XCUIDevice.shared.orientation = .landscapeLeft
    }
    @MainActor private func choose(_ map: String, _ app: XCUIApplication) {
        app.buttons["maps-picker"].tap()
        let button = app.buttons["choose-" + map]
        XCTAssertTrue(button.waitForExistence(timeout: 5)); button.tap()
    }
    private func shot(_ name: String) { let a = XCTAttachment(screenshot: XCUIScreen.main.screenshot()); a.name = name; a.lifetime = .keepAlways; add(a) }
}
