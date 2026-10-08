import XCTest

final class Farming32UITests: XCTestCase {
    @MainActor func testNewPearlPinsSelectExactlyOneMatchingClipAndStayMapScoped() {
        XCUIDevice.shared.orientation = .landscapeLeft
        let app = XCUIApplication(); app.launch()
        app.buttons["maps-picker"].tap()
        let island = app.buttons["choose-the-island"]
        XCTAssertTrue(island.waitForExistence(timeout: 5)); island.tap()
        app.buttons["section-Khai thác"].tap()
        let strip = app.scrollViews["farming-resource-strip"]
        let pearls = app.buttons["farm-resource-Silica Pearls"]
        for _ in 0..<8 { if pearls.isHittable { break }; strip.swipeLeft() }
        XCTAssertTrue(pearls.isHittable); pearls.tap()
        for (id, name) in [("island-north-central-pearls", "North central snow pond"), ("island-north-coast-pearls", "North coast pearl beach"), ("island-north-peninsula-pearls", "North coast peninsula")] {
            let pin = app.buttons["pin-farm-" + id]
            if pin.exists { pin.tap() }
            else { app.buttons["pin-farm-island-north-coast-pearls"].tap() }
            let nearby = app.buttons[name]
            if nearby.waitForExistence(timeout: 1) { nearby.tap() }
            let card = app.descendants(matching: .any).matching(identifier: "farm-card-" + id).firstMatch
            XCTAssertTrue(card.waitForExistence(timeout: 3), id)
            XCTAssertEqual(app.buttons["pin-farm-" + id].value as? String, "Selected")
            XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "farmClip-Resource-" + id + "-1").firstMatch.exists)
            let visibleCards = app.descendants(matching: .any).matching(NSPredicate(format: "identifier BEGINSWITH %@", "farm-card-")).allElementsBoundByIndex.filter { $0.isHittable }
            XCTAssertEqual(visibleCards.count, 1)
        }
        let shot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        shot.name = "Farming32-Island-Pearls-selected-location"; shot.lifetime = .keepAlways; add(shot)
        app.buttons["maps-picker"].tap(); app.buttons["choose-ragnarok"].tap()
        XCTAssertFalse(app.buttons["pin-farm-island-north-central-pearls"].exists)
    }
}
