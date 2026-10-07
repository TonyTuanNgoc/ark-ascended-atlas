import XCTest

final class Ascended28UITests: XCTestCase {
    @MainActor func testPinSelectsExactlyOneClipAndHighlightsWithoutZoom() {
        XCUIDevice.shared.orientation = .landscapeLeft
        let app = XCUIApplication(); app.launch()
        app.buttons["maps-picker"].tap()
        XCTAssertTrue(app.scrollViews["maps-list"].waitForExistence(timeout: 5))
        let rag = app.buttons["choose-ragnarok"]
        for _ in 0..<8 { if rag.isHittable { break }; app.scrollViews["maps-list"].swipeUp() }
        rag.tap(); app.buttons["section-Khai thác"].tap()
        let map = app.descendants(matching: .any).matching(identifier: "farming-mini-map").firstMatch
        XCTAssertTrue(map.waitForExistence(timeout: 5))
        let pins = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "pin-farm-"))
        XCTAssertGreaterThanOrEqual(pins.count, 2)
        let initialZoom = map.value as? String
        for index in 0..<pins.count {
            let pin = pins.element(boundBy: index)
            let id = String(pin.identifier.dropFirst("pin-farm-".count))
            XCTAssertTrue(pin.isHittable); pin.tap()
            XCTAssertEqual(pin.value as? String, "Selected")
            let card = app.descendants(matching: .any).matching(identifier: "farm-card-" + id).firstMatch
            XCTAssertTrue(card.waitForExistence(timeout: 5))
            let clips = app.descendants(matching: .any).matching(NSPredicate(format: "identifier BEGINSWITH %@", "farmClip-")).allElementsBoundByIndex
            XCTAssertEqual(Set(clips.map(\.identifier)).count, 1)
            XCTAssertEqual(app.descendants(matching: .any).matching(NSPredicate(format: "identifier BEGINSWITH %@", "farm-card-")).count, 1)
            XCTAssertEqual(map.value as? String, initialZoom)
        }
        let shot = XCTAttachment(screenshot: XCUIScreen.main.screenshot()); shot.name = "Farming-selected-pin-single-clip"; shot.lifetime = .keepAlways; add(shot)
        XCTAssertGreaterThan(app.staticTexts["module-screen-title"].frame.height, 34)
    }
    @MainActor func testAtlasFitsWholeImageAndHasOnlyDedicatedLayers() {
        XCUIDevice.shared.orientation = .landscapeLeft
        let app = XCUIApplication(); app.launch()
        app.buttons["section-Bản đồ"].tap()
        XCTAssertFalse(app.buttons["section-Thông tin map"].exists)
        XCTAssertFalse(app.buttons["layer-Resources"].exists)
        XCTAssertFalse(app.buttons["layer-Base"].exists)
        let map = app.descendants(matching: .any).matching(identifier: "ragnarokMapViewport").firstMatch
        XCTAssertTrue(map.waitForExistence(timeout: 5))
        XCTAssertEqual(map.frame.width, map.frame.height, accuracy: 2)
        XCTAssertGreaterThan(app.scrollViews["mapFilterRail"].frame.width, 240)
        XCTAssertEqual(app.buttons["layer-Artifact"].value as? String, "Hidden")
        app.buttons["layer-Artifact"].tap()
        XCTAssertEqual(app.buttons["layer-Artifact"].value as? String, "Visible")
        app.buttons["layer-Artifact"].tap()
        let shot = XCTAttachment(screenshot: XCUIScreen.main.screenshot()); shot.name = "Atlas-full-square-map"; shot.lifetime = .keepAlways; add(shot)
    }
    @MainActor func testBaseLocationsHasTenChoicesForEachMainMap() {
        XCUIDevice.shared.orientation = .landscapeLeft
        let app = XCUIApplication(); app.launch()
        for mapID in ["the-island", "the-center", "ragnarok"] {
            app.buttons["maps-picker"].tap()
            let list = app.scrollViews["maps-list"]
            XCTAssertTrue(list.waitForExistence(timeout: 5))
            let choice = app.buttons["choose-" + mapID]
            for _ in 0..<8 { if choice.isHittable { break }; list.swipeUp() }
            choice.tap(); app.buttons["section-Xây base"].tap()
            let strip = app.scrollViews["base-location-strip"]
            XCTAssertTrue(strip.waitForExistence(timeout: 5))
            XCTAssertEqual(app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "base-choice-")).count, 10)
            let buttons = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "base-choice-"))
            let second = buttons.element(boundBy: 1); second.tap()
            XCTAssertEqual(second.value as? String, "Selected")
            let id = String(second.identifier.dropFirst("base-choice-".count))
            XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "base-selected-" + id).firstMatch.exists)
            XCTAssertTrue(app.scrollViews["base-scouting-info"].exists)
            let shot = XCTAttachment(screenshot: XCUIScreen.main.screenshot()); shot.name = "Base-Locations-" + mapID; shot.lifetime = .keepAlways; add(shot)
        }
    }

}
