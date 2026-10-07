import XCTest
final class Ascended30UITests:XCTestCase {
    @MainActor func testBossGalleryAndAtlasPopup() {
        XCUIDevice.shared.orientation = .landscapeLeft
        let app=XCUIApplication();app.launch()
        app.buttons["section-Cốt truyện ARK"].tap()
        app.buttons["maps-picker"].tap()
        let island=app.buttons["choose-the-island"];XCTAssertTrue(island.waitForExistence(timeout:5));island.tap()
        app.buttons["section-Boss"].tap()
        XCTAssertFalse(app.staticTexts["Boss campaign"].exists)
        let cards=["megapithecus","broodmother","dragon","overseer"].map {app.buttons["boss-card-"+$0]}
        for card in cards {XCTAssertTrue(card.waitForExistence(timeout:5));XCTAssertTrue(card.isHittable)}
        XCTAssertLessThan(cards[0].frame.minX,cards[3].frame.minX)
        shot("Boss-gallery")
        cards[0].tap()
        XCTAssertTrue(app.descendants(matching:.any).matching(identifier:"boss-gallery-detail").firstMatch.waitForExistence(timeout:5))
        app.buttons["Tribute"].tap();XCTAssertTrue(app.staticTexts["×1"].firstMatch.waitForExistence(timeout:5))
        app.buttons["Location"].tap();XCTAssertTrue(app.descendants(matching:.any).matching(identifier:"boss-location-map").firstMatch.waitForExistence(timeout:5))
        XCTAssertTrue(app.buttons["pin-boss-summon-megapithecus-obelisk-blue"].exists)
        shot("Boss-location-and-tabs")
        app.buttons["Close boss"].tap()
        app.buttons["section-Bản đồ"].tap()
        XCTAssertEqual(app.staticTexts["module-screen-title"].label,"The Island Atlas")
        XCTAssertLessThan(app.buttons["findMapLocation"].frame.minY,app.buttons["expand-layer-Artifact"].frame.minY)
        app.buttons["findMapLocation"].tap()
        let entrance=app.buttons.matching(NSPredicate(format:"identifier BEGINSWITH %@","find-entrance-")).firstMatch
        XCTAssertTrue(entrance.waitForExistence(timeout:5));entrance.tap()
        XCTAssertTrue(app.descendants(matching:.any).matching(identifier:"atlas-location-photo").firstMatch.waitForExistence(timeout:5))
        shot("Atlas-cave-photo-popup")
    }
    private func shot(_ name:String) {let a=XCTAttachment(screenshot:XCUIScreen.main.screenshot());a.name=name;a.lifetime = .keepAlways;add(a)}
}
