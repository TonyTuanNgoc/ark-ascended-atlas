import XCTest

final class Ascended25UITests: XCTestCase {
    @MainActor private func search(_ text: String, category: String) -> XCUIApplication {
        XCUIDevice.shared.orientation = .landscapeLeft
        let app = XCUIApplication(); app.launch()
        app.buttons["section-Thư viện"].tap()
        app.buttons["equipment-category-" + category].tap()
        let search = app.textFields["equipment-search"]
        search.tap(); search.typeText(text + "\n")
        return app
    }
    @MainActor func testMetalPickRecipeAndIntermediateCrafting() {
        let app = search("Metal Pick", category: "tools")
        let item = app.buttons["equipment-metal-pick"]
        XCTAssertTrue(item.waitForExistence(timeout: 5)); item.tap()
        let ingot = app.descendants(matching: .any)["ingredient-Metal Ingot"].firstMatch
        XCTAssertTrue(ingot.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Smithy · Tek Replicator"].exists)
        let crafting = app.buttons["equipment-ingredient-crafting"]
        if !crafting.isHittable { app.scrollViews["equipmentDetail"].swipeUp() }
        crafting.tap()
        let ore = app.descendants(matching: .any)["ingredient-Metal"].firstMatch
        for _ in 0..<5 { if ore.isHittable { break }; app.scrollViews["equipmentDetail"].swipeUp() }
        XCTAssertTrue(ore.isHittable)
        XCTAssertTrue(app.staticTexts["Metal Ingot ×1"].exists)
        let screenshot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        screenshot.name = "Metal-Pick-materials-and-crafting"; screenshot.lifetime = .keepAlways; add(screenshot)
    }
    @MainActor func testRawMeatToolsCreaturesAndPrey() {
        let app = search("Raw Meat", category: "supplies")
        let item = app.buttons["equipment-raw-meat"]
        XCTAssertTrue(item.waitForExistence(timeout: 5)); item.tap()
        let pick = app.staticTexts["Metal Pick"]
        for _ in 0..<8 { if pick.isHittable { break }; app.scrollViews["equipmentDetail"].swipeUp() }
        XCTAssertTrue(pick.isHittable)
        XCTAssertTrue(app.staticTexts["Metal Hatchet"].exists)
        let prey = app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "Phiomia:")).firstMatch
        for _ in 0..<8 { if prey.isHittable { break }; app.scrollViews["equipmentDetail"].swipeUp() }
        XCTAssertTrue(prey.isHittable)
        XCTAssertTrue(app.staticTexts["Giganotosaurus"].exists)
        let screenshot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        screenshot.name = "Raw-Meat-tools-creatures-prey"; screenshot.lifetime = .keepAlways; add(screenshot)
    }
}
