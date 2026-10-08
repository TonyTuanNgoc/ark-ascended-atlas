import XCTest

final class Farming34UITests: XCTestCase {
    @MainActor func testSharedCaveChangesItsSingleClipWithSelectedResource() {
        XCUIDevice.shared.orientation = .landscapeLeft
        let app = XCUIApplication(); app.launch()
        app.buttons["maps-picker"].tap()
        app.buttons["choose-ragnarok"].tap()
        app.buttons["section-Khai thác"].tap()
        func choose(_ resource: String, clip: String) {
            let strip = app.scrollViews["farming-resource-strip"]
            let item = app.buttons["farm-resource-" + resource]
            XCTAssertTrue(item.waitForExistence(timeout: 5))
            for _ in 0..<8 {
                if item.frame.minX < strip.frame.minX { strip.swipeRight() }
                else if item.frame.maxX > strip.frame.maxX { strip.swipeLeft() }
                else { break }
            }
            item.tap()
            let pin = app.buttons["pin-farm-rag-cave-metal-obsidian"]
            XCTAssertTrue(pin.waitForExistence(timeout: 5)); pin.tap()
            XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "farmClip-" + clip).firstMatch.waitForExistence(timeout: 3))
            let visible = app.descendants(matching: .any).matching(NSPredicate(format: "identifier BEGINSWITH %@", "farmClip-Resource-")).allElementsBoundByIndex.filter { $0.isHittable }
            XCTAssertEqual(Set(visible.map(\.identifier)).count, 1)
        }
        choose("Black Pearls", clip: "Resource-rag-cave-metal-obsidian-black-pearls-1")
        choose("Metal", clip: "Resource-rag-cave-metal-obsidian-metal-1")
        let shot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        shot.name = "Farming34-Resource-Specific-Cave"; shot.lifetime = .keepAlways; add(shot)
    }
}
