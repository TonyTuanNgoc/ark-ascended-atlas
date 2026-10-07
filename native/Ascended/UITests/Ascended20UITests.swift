import XCTest
final class Ascended20UITests:XCTestCase {
    @MainActor private func start()->XCUIApplication {XCUIDevice.shared.orientation = .landscapeLeft;let app=XCUIApplication();app.launch();app.buttons["maps-picker"].tap();let rag=app.buttons["choose-ragnarok"];for _ in 0..<8 {if rag.isHittable {break};app.scrollViews["maps-list"].swipeUp()};rag.tap();return app}
    @MainActor func testEmptyHierarchicalFiltersAndThreeResourceClips() {
        let app=start()
        for id in ["Artifact","Cửa hang","Obelisk","Boss","Base","Resources","My Locations"] {XCTAssertEqual(app.buttons["layer-"+id].value as? String,"Hidden")}
        app.buttons["expand-layer-Artifact"].tap()
        let artifacts=app.buttons.matching(NSPredicate(format:"identifier BEGINSWITH %@","location-filter-artifact-"));XCTAssertGreaterThan(artifacts.count,0)
        let a=artifacts.element(boundBy:0);a.tap();XCTAssertEqual(a.value as? String,"Visible");XCTAssertEqual(app.buttons["layer-Artifact"].value as? String,"Partially visible")
        app.buttons["layer-Artifact"].tap();XCTAssertEqual(app.buttons["layer-Artifact"].value as? String,"Visible")
        app.buttons["layer-Artifact"].tap();XCTAssertEqual(a.value as? String,"Hidden");app.buttons["expand-layer-Artifact"].tap()
        app.buttons["expand-layer-Obelisk"].tap();let obelisk=app.buttons["location-filter-obelisk-red"];XCTAssertTrue(obelisk.waitForExistence(timeout:3));obelisk.tap();XCTAssertEqual(app.buttons["layer-Obelisk"].value as? String,"Partially visible");app.buttons["expand-layer-Obelisk"].tap()
        app.buttons["layer-Resources"].tap()
        let pins=app.buttons.matching(NSPredicate(format:"identifier BEGINSWITH %@","pin-farm-"))
        XCTAssertTrue(pins.firstMatch.waitForExistence(timeout:5))
        let farm=pins.allElementsBoundByIndex.first(where:{$0.isHittable})!
        let name=farm.label.components(separatedBy:", LAT").first!
        farm.tap()
        if !app.staticTexts["selectedMapLocation"].exists {app.buttons[name].tap()}
        XCTAssertTrue(app.staticTexts["selectedMapLocation"].waitForExistence(timeout:5))
        let selectors=app.buttons.matching(NSPredicate(format:"identifier BEGINSWITH %@","farmClipSelect-"));XCTAssertEqual(selectors.count,3)
        for i in 0..<3 {selectors.element(boundBy:i).tap();XCTAssertTrue(app.links["farmClipSource"].exists || app.buttons["farmClipSource"].exists)}
        let shot=XCTAttachment(screenshot:XCUIScreen.main.screenshot());shot.name="Map-hierarchical-filter-resource-loops";shot.lifetime = .keepAlways;add(shot)
    }
    @MainActor func testLongPressPersonalLocationPersistsAndMapIsolation() {
        let app=start();let map=app.descendants(matching:.any)["ragnarokMapViewport"].firstMatch;XCTAssertTrue(map.waitForExistence(timeout:5))
        map.coordinate(withNormalizedOffset:CGVector(dx:0.5,dy:0.5)).press(forDuration:0.9)
        let name=app.textFields["custom-location-name"];XCTAssertTrue(name.waitForExistence(timeout:5));name.tap();name.typeText("QA field camp")
        app.buttons["custom-icon-tent.fill"].tap();app.buttons["custom-color-orange"].tap();app.buttons["custom-location-save"].tap()
        XCTAssertEqual(app.staticTexts["selectedMapLocation"].label,"QA field camp")
        let shot=XCTAttachment(screenshot:XCUIScreen.main.screenshot());shot.name="Personal-GPS-location";shot.lifetime = .keepAlways;add(shot)
        app.buttons["Close location"].tap();app.terminate();app.launch();for _ in 0..<6 {if app.buttons["expand-layer-My Locations"].isHittable {break};app.scrollViews["mapFilterRail"].swipeUp()};app.buttons["expand-layer-My Locations"].tap()
        let row=app.buttons.matching(NSPredicate(format:"identifier BEGINSWITH %@ AND label CONTAINS %@","location-filter-custom-","QA field camp")).firstMatch
        XCTAssertTrue(row.waitForExistence(timeout:5))
        app.buttons["maps-picker"].tap();app.buttons["choose-the-island"].tap();app.buttons["expand-layer-My Locations"].tap();XCTAssertFalse(app.buttons.matching(NSPredicate(format:"label CONTAINS %@","QA field camp")).firstMatch.exists)
    }
    @MainActor func testScorchedGoalsKeepFullMeaningInDetailPage() {
        let app=start();app.buttons["maps-picker"].tap();app.buttons["choose-scorched-earth"].tap();app.buttons["section-Thông tin map"].tap()
        let goals=app.buttons["expansion-goals"]
        for _ in 0..<5 {if goals.isHittable {break};app.scrollViews.matching(NSPredicate(format: "identifier != %@", "top-module-navigation")).firstMatch.swipeUp()}
        XCTAssertTrue(goals.waitForExistence(timeout:5));goals.tap();XCTAssertTrue(app.scrollViews["information-detail-goals"].waitForExistence(timeout:5))
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format:"label CONTAINS[c] %@","Wyvern")).firstMatch.exists)
        let shot=XCTAttachment(screenshot:XCUIScreen.main.screenshot());shot.name="Scorched-goals-full-instructions";shot.lifetime = .keepAlways;add(shot)
    }
}
