import XCTest

final class Ascended27UITests: XCTestCase {
    @MainActor func testMapPickerWholeCardOpensOnceAndStoryTopicsAreHorizontal() {
        XCUIDevice.shared.orientation = .landscapeLeft
        let app = XCUIApplication(); app.launch()
        let picker = app.buttons["maps-picker"]
        XCTAssertTrue(picker.waitForExistence(timeout: 8))
        picker.tap()
        XCTAssertTrue(app.scrollViews["maps-list"].waitForExistence(timeout: 3))
        app.buttons["choose-the-island"].tap()
        for offset in [CGVector(dx: 0.12, dy: 0.2), CGVector(dx: 0.5, dy: 0.8), CGVector(dx: 0.88, dy: 0.5)] {
            picker.coordinate(withNormalizedOffset: offset).tap()
            XCTAssertTrue(app.scrollViews["maps-list"].waitForExistence(timeout: 3), "One tap must open Maps from any part of the card")
            app.buttons["choose-the-island"].tap()
        }
        XCTAssertEqual(picker.label, "Maps · The Island")
        app.buttons["section-Cốt truyện ARK"].tap()
        let topics = app.scrollViews["story-topic-navigation"]
        XCTAssertTrue(topics.waitForExistence(timeout: 5))
        let start = app.buttons["story-start"]
        let loop = app.buttons["story-loop"]
        XCTAssertEqual(start.frame.midY, loop.frame.midY, accuracy: 2)
        loop.tap()
        XCTAssertEqual(loop.value as? String, "Selected")
        XCTAssertEqual(start.value as? String, "Not selected")
        XCTAssertTrue(app.staticTexts["story-content-title"].exists)
        start.tap()
        XCTAssertEqual(start.value as? String, "Selected")
        let title = app.staticTexts["module-screen-title"]
        XCTAssertTrue(title.exists)
        XCTAssertGreaterThan(title.frame.height, 24)
        let shot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        shot.name = "Story-horizontal-topics-Island-picker"; shot.lifetime = .keepAlways; add(shot)
        app.buttons["story-full"].tap()
        let chapter = app.buttons["chapter-arks"]
        XCTAssertTrue(chapter.waitForExistence(timeout: 5)); chapter.tap()
        XCTAssertEqual(chapter.value as? String, "Selected")
        app.buttons["story-characters"].tap()
        XCTAssertTrue(app.buttons["Mei-Yin Li"].waitForExistence(timeout: 5))
        app.buttons["Mei-Yin Li"].tap()
        XCTAssertEqual(app.staticTexts["story-content-title"].label, "Mei-Yin Li")
        app.buttons["section-Thư viện"].tap()
        XCTAssertEqual(app.staticTexts["module-screen-title"].label, "Equipment")
        XCTAssertTrue(app.scrollViews["equipment-category-navigation"].exists)
    }
    @MainActor func testFocusedFarmingHasThreeFixedColumnsAndSmallLocationCards() {
        XCUIDevice.shared.orientation = .landscapeLeft
        let app = XCUIApplication(); app.launch()
        app.buttons["maps-picker"].tap()
        XCTAssertTrue(app.scrollViews["maps-list"].waitForExistence(timeout: 5))
        app.buttons["choose-the-island"].tap()
        app.buttons["section-Khai thác"].tap()
        let map = app.descendants(matching: .any).matching(identifier: "farming-mini-map").firstMatch
        let locations = app.descendants(matching: .any).matching(identifier: "farming-location-panel").firstMatch
        let harvest = app.scrollViews["farming-harvesting-column"]
        XCTAssertTrue(map.waitForExistence(timeout: 5))
        XCTAssertTrue(locations.exists); XCTAssertTrue(harvest.exists)
        XCTAssertLessThan(map.frame.maxX, locations.frame.minX)
        XCTAssertLessThan(locations.frame.maxX, harvest.frame.minX)
        XCTAssertEqual(map.frame.width, harvest.frame.width, accuracy: 3)
        XCTAssertLessThanOrEqual(locations.frame.maxY, app.frame.maxY)
        XCTAssertLessThanOrEqual(harvest.frame.maxY, app.frame.maxY)
        XCTAssertTrue(app.staticTexts["Ankylosaurus"].isHittable)
        XCTAssertTrue(app.staticTexts["Metal Pick"].isHittable)
        XCTAssertFalse(app.buttons["farm-resource-Raw Meat"].exists)
        XCTAssertFalse(app.buttons["farm-resource-Water"].exists)
        let strip = app.scrollViews["farming-resource-strip"]
        for _ in 0..<5 { if app.buttons["farm-resource-Rich Metal"].isHittable { break }; strip.swipeLeft() }
        let rich = app.buttons["farm-resource-Rich Metal"]
        XCTAssertTrue(rich.isHittable); rich.tap()
        XCTAssertEqual(rich.value as? String, "Selected")
        let shot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        shot.name = "Farming-three-columns-Rich-Metal"; shot.lifetime = .keepAlways; add(shot)
    }

}
