import XCTest

final class AscendedUITests: XCTestCase {
    @MainActor func testRagnarokNavigationMapAndNotesPersistence() throws {
        let app = XCUIApplication()
        XCUIDevice.shared.orientation = .landscapeLeft
        app.launch()
        Thread.sleep(forTimeInterval: 1)
        XCTAssertTrue(app.buttons["openRagnarokMap"].waitForExistence(timeout: 10))
        let overview = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        overview.name = "Ragnarok-landscape"; overview.lifetime = .keepAlways; add(overview)
        app.buttons["openRagnarokMap"].tap()
        XCTAssertTrue(app.buttons["resetMap"].waitForExistence(timeout: 5))
        app.buttons["resetMap"].tap()
        let map = app.descendants(matching: .any)["ragnarokMapViewport"].firstMatch
        XCTAssertTrue(map.waitForExistence(timeout: 5))
        XCTAssertEqual(map.value as? String, "1.00")
        map.doubleTap()
        let zoomed = NSPredicate(format: "value != %@", "1.00")
        expectation(for: zoomed, evaluatedWith: map)
        waitForExpectations(timeout: 5)
        map.swipeLeft()
        app.buttons["resetMap"].tap()
        expectation(for: NSPredicate(format: "value == %@", "1.00"), evaluatedWith: map)
        waitForExpectations(timeout: 5)
        let landscape = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        landscape.name = "Map-landscape"; landscape.lifetime = .keepAlways; add(landscape)
        XCUIDevice.shared.orientation = .portrait
        Thread.sleep(forTimeInterval: 1)
        XCTAssertTrue(app.buttons["resetMap"].waitForExistence(timeout: 5))
        let portrait = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        portrait.name = "Map-portrait"; portrait.lifetime = .keepAlways; add(portrait)
        XCUIDevice.shared.orientation = .landscapeLeft
        Thread.sleep(forTimeInterval: 1)
        app.buttons["Ghi chú"].tap()
        let notes = app.textViews["ragnarokNotes"]
        XCTAssertTrue(notes.waitForExistence(timeout: 5))
        notes.tap()
        let marker = "Ragnarok QA " + UUID().uuidString
        notes.typeText(marker)
        app.terminate(); app.launch()
        app.buttons["Ghi chú"].tap()
        XCTAssertTrue(app.textViews["ragnarokNotes"].waitForExistence(timeout: 5))
        XCTAssertTrue((app.textViews["ragnarokNotes"].value as? String ?? "").contains(marker))
    }
    @MainActor func testCurrentCreatureLibraryAndBosses() throws {
        let app = XCUIApplication()
        XCUIDevice.shared.orientation = .landscapeLeft
        app.launch()
        XCTAssertTrue(app.buttons["openDinos"].waitForExistence(timeout: 10))
        app.buttons["openDinos"].tap()
        XCTAssertTrue(app.buttons["filter-DLC"].waitForExistence(timeout: 5))
        app.buttons["filter-DLC"].tap()
        XCTAssertTrue(app.staticTexts["12"].waitForExistence(timeout: 5))
        let library = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        library.name = "Dino-DLC-library"; library.lifetime = .keepAlways; add(library)
        let search = app.searchFields.firstMatch
        XCTAssertTrue(search.waitForExistence(timeout: 5))
        search.tap(); search.typeText("Cerberax")
        XCTAssertTrue(app.buttons["creature-cerberax"].waitForExistence(timeout: 5))
        app.buttons["creature-cerberax"].tap()
        XCTAssertTrue(app.staticTexts["Cập nhật mới"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Thử thách đặc biệt"].exists)
        let detail = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        detail.name = "Cerberax-profile"; detail.lifetime = .keepAlways; add(detail)
        app.buttons["Boss"].firstMatch.tap()
        XCTAssertTrue(app.buttons["boss-nunatak"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["1 boss chính · 4 mini-boss có tên · 3 nhóm trận hang động"].exists)
        let bosses = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        bosses.name = "Boss-library"; bosses.lifetime = .keepAlways; add(bosses)
        app.buttons["boss-nunatak"].tap()
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "Gamma")).firstMatch.waitForExistence(timeout: 5))
    }

}
