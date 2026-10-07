import XCTest

final class Caves31UITests: XCTestCase {
    @MainActor func testCaveCardsDetailPauseAndSequence() {
        XCUIDevice.shared.orientation = .landscapeLeft
        let app = XCUIApplication(); app.launch()
        app.buttons["section-Cốt truyện ARK"].tap()
        app.buttons["maps-picker"].tap()
        let island = app.buttons["choose-the-island"]
        XCTAssertTrue(island.waitForExistence(timeout: 5)); island.tap()
        app.buttons["section-Artifact & Hang"].tap()
        XCTAssertEqual(app.staticTexts["module-screen-title"].label, "Artifacts & Caves")
        XCTAssertFalse(app.searchFields["Search caves or artifacts"].exists)
        for id in ["lower-south", "central", "lava", "upper-south", "north-east", "north-west", "swamp", "snow", "lost-faith", "lost-hope", "tek"] {
            let card = app.buttons["route-" + id]
            XCTAssertTrue(card.waitForExistence(timeout: 5), id)
            XCTAssertTrue(card.isHittable, "Cave card should fit the first landscape viewport: " + id)
        }
        shot("Caves-compact-photo-cards")
        app.buttons["route-lower-south"].tap()
        XCTAssertTrue(app.staticTexts["cave-detail-name"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Artifact of the Hunter"].exists)
        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "cave-route-map-lower-south").firstMatch.exists)
        XCTAssertTrue(app.buttons["pin-artifact-hunter"].exists)
        let routeMap = app.descendants(matching: .any).matching(identifier: "cave-route-map-lower-south").allElementsBoundByIndex.max { $0.frame.width * $0.frame.height < $1.frame.width * $1.frame.height }!
        shot("Cave-detail-default-map-and-heading")
        routeMap.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).doubleTap()
        XCTAssertTrue(app.buttons["pin-entrance-lower-south-0"].exists)
        shot("Cave-detail-title-and-pinned-map")
        let first = app.descendants(matching: .any).matching(identifier: "cave-gif-lower-south-hunter-01").firstMatch
        XCTAssertTrue(first.waitForExistence(timeout: 5))
        for _ in 0..<3 { if first.isHittable { break }; app.swipeUp() }
        first.tap()
        XCTAssertEqual(first.value as? String, "Paused")
        shot("Cave-detail-paused-and-pinned-map")
        first.tap()
        XCTAssertEqual(first.value as? String, "Playing")
        let second = app.descendants(matching: .any).matching(identifier: "cave-gif-lower-south-hunter-02").firstMatch
        expectation(for: NSPredicate(format: "value == %@", "Playing"), evaluatedWith: second)
        waitForExpectations(timeout: 22)
        second.tap()
        XCTAssertEqual(second.value as? String, "Paused")
        shot("Cave-next-clip-paused")
    }
    private func shot(_ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot()); attachment.name = name
        attachment.lifetime = .keepAlways; add(attachment)
    }
}
