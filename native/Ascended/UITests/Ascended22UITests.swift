import XCTest

final class Ascended22UITests: XCTestCase {
    @MainActor func testAberrationUnlinkedArtifactRemainsDiscoverable() {
        XCUIDevice.shared.orientation = .landscapeLeft
        let app = XCUIApplication()
        app.launch()
        app.buttons["map-group-Cốt truyện"].tap()
        app.buttons["choose-aberration"].tap()
        app.buttons["section-Artifact & Hang"].tap()
        XCTAssertTrue(app.staticTexts["Artifact of the Lost"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["route-reference-aberration-old-railway-cave"].exists)
    }

    @MainActor func testScorchedEntranceArtifactAndExternalWalkthrough() {
        XCUIDevice.shared.orientation = .landscapeLeft
        let app = XCUIApplication()
        app.launch()
        app.buttons["map-group-Cốt truyện"].tap()
        app.buttons["choose-scorched-earth"].tap()
        app.buttons["section-Artifact & Hang"].tap()
        let route = app.buttons["route-reference-scorched-earth-grave-of-the-tyrants"]
        XCTAssertTrue(route.waitForExistence(timeout: 5))
        route.tap()
        XCTAssertTrue(app.staticTexts["Crag"].waitForExistence(timeout: 5))
        let walkthrough = app.descendants(matching: .any)["walkthrough-reference-scorched-earth-grave-of-the-tyrants"].firstMatch
        for _ in 0..<5 {
            if walkthrough.isHittable { break }
            app.scrollViews.firstMatch.swipeUp()
        }
        XCTAssertTrue(walkthrough.exists)
        let shot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        shot.name = "Scorched-entrance-artifact-walkthrough"
        shot.lifetime = .keepAlways
        add(shot)
    }
}
