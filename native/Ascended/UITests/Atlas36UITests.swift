import XCTest
final class Atlas36UITests: XCTestCase {
    @MainActor func testArtifactSelectionPreservesZoomAndOpensLinkedWalkthrough() {
        XCUIDevice.shared.orientation = .landscapeLeft
        let app = XCUIApplication(); app.launch()
        app.buttons["section-Cốt truyện ARK"].tap()
        app.buttons["maps-picker"].tap()
        app.buttons["choose-the-island"].tap()
        app.buttons["section-Bản đồ"].tap()
        let viewport = app.descendants(matching: .any).matching(identifier: "ragnarokMapViewport").firstMatch
        XCTAssertTrue(viewport.waitForExistence(timeout: 5))
        viewport.coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.1)).doubleTap()
        viewport.pinch(withScale: 1.5, velocity: 1)
        XCTAssertNotEqual(viewport.value as? String, "1.00", "Pinch must work before selecting a point")
        viewport.coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.1)).doubleTap()
        let before = viewport.value as? String
        XCTAssertEqual(before, "1.00")
        app.buttons["location-filter-artifact-clever"].tap()
        XCTAssertTrue(app.staticTexts["selectedMapLocation"].waitForExistence(timeout: 5))
        XCTAssertEqual(viewport.value as? String, before, "Selecting an artifact must preserve the user's zoom")
        let preview = app.buttons["atlas-cave-preview-central"]
        XCTAssertTrue(preview.waitForExistence(timeout: 5))
        XCTAssertEqual(app.buttons["pin-artifact-clever"].value as? String, "Selected")
        let shot = XCTAttachment(screenshot: XCUIScreen.main.screenshot()); shot.name = "Artifact-anchored-GIF-popup"; shot.lifetime = .keepAlways; add(shot)
        let popup = app.descendants(matching: .any).matching(identifier: "atlas-artifact-popup").firstMatch
        XCTAssertFalse(popup.frame.intersects(app.buttons["pin-artifact-clever"].frame), "Popup must leave the selected pin exposed")
        XCTAssertTrue(app.buttons["atlas-open-cave-page"].exists)
        preview.tap()
        XCTAssertTrue(app.staticTexts["atlas-walkthrough-title"].waitForExistence(timeout: 5))
        app.buttons["Done"].tap()
        XCTAssertEqual(viewport.value as? String, before)
        viewport.pinch(withScale: 2, velocity: 1)
        XCTAssertTrue(app.staticTexts["selectedMapLocation"].exists)
        XCTAssertNotEqual(viewport.value as? String, before, "Pinch must remain available")
        XCTAssertFalse(popup.frame.intersects(app.buttons["pin-artifact-clever"].frame))
        XCTAssertEqual(app.buttons["pin-artifact-clever"].value as? String, "Selected")
        viewport.coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.1)).doubleTap()
        XCTAssertEqual(viewport.value as? String, "1.00")
        XCTAssertFalse(app.staticTexts["selectedMapLocation"].exists)
        app.buttons["location-filter-artifact-hunter"].tap()
        XCTAssertTrue(app.buttons["atlas-cave-preview-lower-south"].waitForExistence(timeout: 5))
        XCTAssertEqual(viewport.value as? String, "1.00")
        XCTAssertFalse(popup.frame.intersects(app.buttons["pin-artifact-hunter"].frame))
        app.buttons["atlas-open-cave-page"].tap()
        XCTAssertTrue(app.staticTexts["cave-detail-name"].waitForExistence(timeout: 5))
    }
}
