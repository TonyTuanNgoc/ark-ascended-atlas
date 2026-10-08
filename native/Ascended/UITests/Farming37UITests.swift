import XCTest

final class Farming37UITests: XCTestCase {
    @MainActor func testIslandFarmingPinsSwitchOneClipAndLocationMounts() {
        XCUIDevice.shared.orientation = .landscapeLeft
        let app = XCUIApplication(); app.launch()
        app.buttons["maps-picker"].tap()
        app.buttons["choose-the-island"].tap()
        app.buttons["section-Khai thác"].tap()
        func select(_ resource: String, _ id: String) {
            let strip = app.scrollViews["farming-resource-strip"]
            let item = app.buttons["farm-resource-" + resource]
            for _ in 0..<8 {
                if item.frame.minX < strip.frame.minX { strip.swipeRight() }
                else if item.frame.maxX > strip.frame.maxX { strip.swipeLeft() }
                else { break }
            }
            item.tap()
            let pin = app.buttons["pin-farm-" + id]
            for _ in 0..<5 { if pin.exists { break }; app.buttons["Zoom in farming map"].tap() }
            XCTAssertTrue(pin.waitForExistence(timeout: 5)); pin.tap()
            XCTAssertEqual(pin.value as? String, "Selected")
            XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "farmClip-Resource-" + id + "-1").firstMatch.waitForExistence(timeout: 5))
            let clips = app.descendants(matching: .any).matching(NSPredicate(format: "identifier BEGINSWITH %@", "farmClip-Resource-")).allElementsBoundByIndex.filter { $0.isHittable }
            XCTAssertEqual(Set(clips.map(\.identifier)).count, 1)
        }
        select("Metal", "island-f37-metal-herbivore")
        select("Cementing Paste", "island-paste-swamp-648-350")
        XCTAssertTrue(app.staticTexts["Beelzebufo"].firstMatch.exists)
        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "farm-location-mounts").firstMatch.exists)
        let shot = XCTAttachment(screenshot: XCUIScreen.main.screenshot()); shot.name = "Farming37-Island-Swamp-Mounts"; shot.lifetime = .keepAlways; add(shot)
        select("Chitin", "island-paste-swamp-648-350")
        XCTAssertTrue(app.staticTexts["Megatherium"].firstMatch.exists)
        app.buttons["maps-picker"].tap()
        let cover = XCTAttachment(screenshot: XCUIScreen.main.screenshot()); cover.name = "Farming37-Island-Cover"; cover.lifetime = .keepAlways; add(cover)
        app.buttons["choose-ragnarok"].tap()
        app.buttons["section-Khai thác"].tap()
        XCTAssertFalse(app.buttons["pin-farm-island-paste-swamp-648-350"].exists)
    }
}
