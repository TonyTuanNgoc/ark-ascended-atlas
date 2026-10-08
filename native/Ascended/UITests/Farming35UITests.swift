import XCTest

final class Farming35UITests: XCTestCase {
    @MainActor func testNewValgueroAndExtinctionRegionsHaveMapScopedSingleClips() {
        XCUIDevice.shared.orientation = .landscapeLeft
        let app = XCUIApplication(); app.launch()
        func map(_ id: String) {
            app.buttons["maps-picker"].tap()
            let choice = app.buttons["choose-" + id]
            for _ in 0..<4 { if choice.isHittable { break }; app.swipeUp() }
            XCTAssertTrue(choice.waitForExistence(timeout: 5)); choice.tap()
            app.buttons["section-Khai thác"].tap()
        }
        func check(_ resource: String, _ id: String) {
            let strip = app.scrollViews["farming-resource-strip"]
            let item = app.buttons["farm-resource-" + resource]
            XCTAssertTrue(item.waitForExistence(timeout: 5))
            for _ in 0..<8 {
                if item.frame.minX < strip.frame.minX { strip.swipeRight() }
                else if item.frame.maxX > strip.frame.maxX { strip.swipeLeft() }
                else { break }
            }
            item.tap()
            let pin = app.buttons["pin-farm-" + id]
            // Nearby locations share a marker at the fitted scale; zoom separates them.
            for _ in 0..<8 {
                if pin.exists { break }
                app.buttons["Zoom in farming map"].tap()
            }
            XCTAssertTrue(pin.waitForExistence(timeout: 5)); pin.tap()
            XCTAssertEqual(pin.value as? String, "Selected")
            XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "farmClip-Resource-" + id + "-1").firstMatch.waitForExistence(timeout: 3))
            let clips = app.descendants(matching: .any).matching(NSPredicate(format: "identifier BEGINSWITH %@", "farmClip-Resource-")).allElementsBoundByIndex.filter { $0.isHittable }
            XCTAssertEqual(Set(clips.map(\.identifier)).count, 1)
        }
        map("valguero")
        check("Silica Pearls", "valguero-ne-ice-pearls-181-885")
        check("Silica Pearls", "valguero-nw-ice-pearls-301-178")
        check("Crystal", "valguero-nw-snow-crystal-243-12")
        check("Crystal", "valguero-south-red-cliff-crystal-842-396")
        check("Chitin", "valguero-lava-cave-chitin-342-514")
        check("Rare Mushrooms", "valguero-ab-red-cap-mushrooms-312-863")
        map("extinction")
        XCTAssertFalse(app.buttons["pin-farm-valguero-ab-red-cap-mushrooms-312-863"].exists)
        check("Metal", "extinction-metal-forest-154-257")
        check("Obsidian", "extinction-obsidian-desert-775-382")
        check("Rare Mushrooms", "extinction-desert-lakes-purple-bushes-863-839")
        check("Rare Flowers", "extinction-desert-lakes-purple-bushes-863-839")
        let shot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        shot.name = "Farming35-Extinction-Flowers"; shot.lifetime = .keepAlways; add(shot)
        map("lost-colony")
        XCTAssertFalse(app.buttons["pin-farm-extinction-desert-lakes-purple-bushes-863-839"].exists)
        check("Sap", "lost-colony-south-sap-trees-875-346")
        check("Crystal", "lost-colony-south-city-gargoyles-561-611")
        check("Obsidian", "lost-colony-south-city-gargoyles-561-611")
        check("Metal", "lost-colony-south-city-gargoyles-561-611")
        check("Oil", "lost-colony-blue-ice-cave-oil-687-463")
        check("Oil", "lost-colony-arch-river-oil-585-561")
        check("Chitin", "lost-colony-north-cave-chitin-28-30")
        check("Giant Bee Honey", "lost-colony-cliff-arch-honey-231-199")
        check("Giant Bee Honey", "lost-colony-stacked-cliff-honey-36-421")
    }
}
