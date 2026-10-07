import XCTest
final class Ascended20UITests:XCTestCase {
    @MainActor private func start()->XCUIApplication {XCUIDevice.shared.orientation = .landscapeLeft;let app=XCUIApplication();app.launch();app.buttons["maps-picker"].tap();let rag=app.buttons["choose-ragnarok"];for _ in 0..<8 {if rag.isHittable {break};app.scrollViews["maps-list"].swipeUp()};rag.tap();return app}
    @MainActor func testEmptyHierarchicalFiltersExcludeDedicatedLayers() {
        let app=start()
        for id in ["Artifact","Cửa hang","Obelisk","Boss","My Locations"] {XCTAssertEqual(app.buttons["layer-"+id].value as? String,"Hidden")}
        app.buttons["expand-layer-Artifact"].tap()
        let artifacts=app.buttons.matching(NSPredicate(format:"identifier BEGINSWITH %@","location-filter-artifact-"));XCTAssertTrue(artifacts.firstMatch.waitForExistence(timeout:5));XCTAssertGreaterThan(artifacts.count,0)
        let a=artifacts.element(boundBy:0);a.tap();XCTAssertEqual(a.value as? String,"Visible");XCTAssertEqual(app.buttons["layer-Artifact"].value as? String,"Partially visible")
        app.buttons["layer-Artifact"].tap();XCTAssertEqual(app.buttons["layer-Artifact"].value as? String,"Visible")
        app.buttons["layer-Artifact"].tap();XCTAssertEqual(a.value as? String,"Hidden");app.buttons["expand-layer-Artifact"].tap()
        app.buttons["expand-layer-Obelisk"].tap();let obelisk=app.buttons["location-filter-obelisk-red"];XCTAssertTrue(obelisk.waitForExistence(timeout:3));obelisk.tap();XCTAssertEqual(app.buttons["layer-Obelisk"].value as? String,"Partially visible");app.buttons["expand-layer-Obelisk"].tap()
        XCTAssertFalse(app.buttons["layer-Resources"].exists)
        XCTAssertFalse(app.buttons["layer-Base"].exists)
        let shot=XCTAttachment(screenshot:XCUIScreen.main.screenshot());shot.name="Map-hierarchical-dedicated-filters";shot.lifetime = .keepAlways;add(shot)
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
    @MainActor func testRemovedFieldGuideIsAbsentOnExpansionMaps() {
        let app = start(); app.buttons["maps-picker"].tap(); app.buttons["choose-scorched-earth"].tap()
        XCTAssertFalse(app.buttons["section-Thông tin map"].exists)
        XCTAssertTrue(app.buttons["section-Xây base"].exists)
        XCTAssertFalse(app.buttons["layer-Resources"].exists)
        XCTAssertFalse(app.buttons["layer-Base"].exists)
    }
}
