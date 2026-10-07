import XCTest

final class Ascended23UITests: XCTestCase {
    @MainActor func testHorizontalModulesCategoriesAndSearch() {
        XCUIDevice.shared.orientation = .landscapeLeft
        let app = XCUIApplication()
        app.launch()
        let modules = ["Cốt truyện ARK", "Thư viện", "Khai thác", "Thông tin map", "Xây base", "Bản đồ", "Dino", "Boss", "Artifact & Hang"].map { app.buttons["section-" + $0] }
        for module in modules { XCTAssertTrue(module.isHittable, module.identifier) }
        XCTAssertTrue(modules.allSatisfy { abs($0.frame.midY - modules[0].frame.midY) < 2 })
        app.buttons["section-Thư viện"].tap()
        let categories = ["resources", "tools", "machines", "structures", "supplies"].map { app.buttons["equipment-category-" + $0] }
        XCTAssertTrue(categories.allSatisfy { $0.isHittable })
        XCTAssertTrue(categories.allSatisfy { abs($0.frame.midY - categories[0].frame.midY) < 2 })
        XCTAssertTrue(app.buttons["equipment-absorbent-substrate"].waitForExistence(timeout: 5))
        app.buttons["equipment-category-machines"].tap()
        XCTAssertTrue(app.buttons["equipment-air-conditioner"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["equipment-absorbent-substrate"].exists)
        let library = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        library.name = "Horizontal-equipment-library"; library.lifetime = .keepAlways; add(library)
        let search = app.textFields["equipment-search"]
        XCTAssertTrue(search.exists)
        search.tap(); search.typeText("Fabricator\n")
        XCTAssertTrue(app.buttons["equipment-fabricator"].waitForExistence(timeout: 5))
        let shot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        shot.name = "Horizontal-equipment-search"
        shot.lifetime = .keepAlways
        add(shot)
        app.buttons["equipment-fabricator"].tap()
        XCTAssertTrue(app.scrollViews["equipmentDetail"].waitForExistence(timeout: 5) || app.otherElements["equipmentDetail"].exists)
        app.buttons["section-Cốt truyện ARK"].tap()
        XCTAssertTrue(app.scrollViews["storyGuide"].waitForExistence(timeout: 5))
    }

    @MainActor func testUnifiedMapsPickerAndExplorationSelection() {
        XCUIDevice.shared.orientation = .landscapeLeft
        let app = XCUIApplication()
        app.launch()
        app.buttons["maps-picker"].tap()
        XCTAssertTrue(app.staticTexts["Story Maps"].exists)
        XCTAssertTrue(app.staticTexts["Exploration Maps"].exists)
        let row = app.buttons["choose-ragnarok"]
        for _ in 0..<8 {
            if row.isHittable { break }
            app.scrollViews["maps-list"].swipeUp()
        }
        XCTAssertTrue(row.isHittable)
        let shot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        shot.name = "Unified-Maps-picker"
        shot.lifetime = .keepAlways
        add(shot)
        row.tap()
        XCTAssertTrue(app.buttons["layer-Resources"].waitForExistence(timeout: 5))
    }
}
