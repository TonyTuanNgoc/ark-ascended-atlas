import XCTest
final class Ascended31UITests: XCTestCase {
    @MainActor func testAtlasHorizontalCategoriesAndCreatureSpawn() {
        XCUIDevice.shared.orientation = .landscapeLeft
        let app = XCUIApplication(); app.launch()
        app.buttons["section-Cốt truyện ARK"].tap()
        app.buttons["maps-picker"].tap()
        let island = app.buttons["choose-the-island"]
        XCTAssertTrue(island.waitForExistence(timeout: 5)); island.tap()
        app.buttons["section-Bản đồ"].tap()
        let categories = ["Artifact", "Cửa hang", "Obelisk", "Boss", "My Locations"].map { app.buttons["expand-layer-" + $0] }
        for category in categories { XCTAssertTrue(category.isHittable) }
        for index in 1..<categories.count {
            XCTAssertGreaterThan(categories[index].frame.minX, categories[index-1].frame.minX)
            XCTAssertEqual(categories[index].frame.minY, categories[0].frame.minY, accuracy: 2)
        }
        XCTAssertFalse(app.buttons["zoomIn"].exists)
        XCTAssertFalse(app.buttons["zoomOut"].exists)
        XCTAssertFalse(app.staticTexts["Hold to add your own location"].exists)
        categories[1].tap()
        let cave = app.buttons["location-filter-entrance-lower-south-0"]
        XCTAssertTrue(cave.waitForExistence(timeout: 5)); cave.tap()
        XCTAssertTrue(app.staticTexts["selectedMapLocation"].waitForExistence(timeout: 5))
        shot("Atlas-horizontal-categories-and-cave-popup")
        let map = app.descendants(matching: .any).matching(identifier: "ragnarokMapViewport").firstMatch
        map.coordinate(withNormalizedOffset: CGVector(dx: 0.15, dy: 0.15)).doubleTap()
        XCTAssertFalse(app.staticTexts["selectedMapLocation"].waitForExistence(timeout: 1))
        app.buttons["section-Dino"].tap()
        let search = app.searchFields.firstMatch
        search.tap(); search.typeText("Argentavis")
        let arg = app.buttons["creature-argentavis"]
        XCTAssertTrue(arg.waitForExistence(timeout: 5)); arg.tap()
        XCTAssertEqual(app.staticTexts.matching(NSPredicate(format: "label == %@", "Argentavis")).allElementsBoundByIndex.filter { $0.isHittable }.count, 1)
        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "creature-profile-columns").firstMatch.exists)
        shot("Creature-single-heading-and-custom-icons")
        let expand = app.buttons["creature-spawn-expand"]
        for _ in 0..<5 { if expand.isHittable { break }; app.swipeUp() }
        XCTAssertTrue(expand.isHittable); expand.tap()
        XCTAssertTrue(app.staticTexts["Argentavis · The Island"].waitForExistence(timeout: 5))
        shot("Argentavis-The-Island-spawn-regions")
        app.buttons["Done"].tap()
    }
    @MainActor func testFarmingCompactNames() {
        XCUIDevice.shared.orientation = .landscapeLeft
        let app = XCUIApplication(); app.launch()
        app.buttons["section-Khai thác"].tap()
        XCTAssertTrue(app.staticTexts["Locations"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Harvesting"].exists)
        XCTAssertFalse(app.staticTexts["Filmed area · nearby nodes can vary"].exists)
        XCTAssertFalse(app.staticTexts["Tail swing; ASA Harvest Only can select metal."].exists)
        shot("Farming-compact-harvesting")
    }
    private func shot(_ name: String) {
        let item = XCTAttachment(screenshot: XCUIScreen.main.screenshot()); item.name = name
        item.lifetime = .keepAlways; add(item)
    }
}
