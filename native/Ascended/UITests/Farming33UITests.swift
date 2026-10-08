import XCTest

final class Farming33UITests: XCTestCase {
    @MainActor func testGenesisOceanAndLandUseTheirOwnResourcePinsAndClips() {
        XCUIDevice.shared.orientation = .landscapeLeft
        let app = XCUIApplication(); app.launch()
        func selectMap(_ id: String) {
            app.buttons["maps-picker"].tap()
            let choice = app.buttons["choose-" + id]
            if !choice.isHittable { app.swipeUp() }
            XCTAssertTrue(choice.waitForExistence(timeout: 5)); choice.tap()
        }
        func selectResource(_ name: String) {
            let strip = app.scrollViews["farming-resource-strip"]
            let resource = app.buttons["farm-resource-" + name]
            for _ in 0..<8 { if resource.isHittable { break }; strip.swipeLeft() }
            XCTAssertTrue(resource.isHittable); resource.tap()
        }
        func checkSelected(_ id: String) {
            let pin = app.buttons["pin-farm-" + id]
            XCTAssertTrue(pin.waitForExistence(timeout: 5)); pin.tap()
            XCTAssertEqual(pin.value as? String, "Selected")
            XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "farm-card-" + id).firstMatch.waitForExistence(timeout: 3))
            XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "farmClip-Resource-" + id + "-1").firstMatch.exists)
            let cards = app.descendants(matching: .any).matching(NSPredicate(format: "identifier BEGINSWITH %@", "farm-card-")).allElementsBoundByIndex.filter { $0.isHittable }
            XCTAssertEqual(cards.count, 1)
        }
        selectMap("genesis-part-1-ocean")
        app.buttons["section-Khai thác"].tap()
        selectResource("Silica Pearls")
        checkSelected("genesis-ocean-safe-beach-silica-90-15")
        let ocean = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        ocean.name = "Farming33-Genesis-Ocean-Pearls"; ocean.lifetime = .keepAlways; add(ocean)
        selectMap("genesis-part-1")
        app.buttons["section-Khai thác"].tap()
        selectResource("Organic Polymer")
        checkSelected("genesis-arctic-frozen-lake-polymer-74-14")
        XCTAssertFalse(app.buttons["pin-farm-genesis-ocean-safe-beach-silica-90-15"].exists)
        let land = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        land.name = "Farming33-Genesis-Arctic-Polymer"; land.lifetime = .keepAlways; add(land)
    }
}
