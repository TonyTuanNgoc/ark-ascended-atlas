import XCTest

final class Ascended24UITests: XCTestCase {
    @MainActor func testSingleRowCombinedMapPickerAndNames() {
        XCUIDevice.shared.orientation = .landscapeLeft
        let app = XCUIApplication(); app.launch()
        let picker = app.buttons["maps-picker"]
        let logo = app.images["ascended-header-logo"]
        let ids = ["Cốt truyện ARK", "Thư viện", "Khai thác", "Thông tin map", "Xây base", "Bản đồ", "Dino", "Boss", "Artifact & Hang"]
        let titles = ["ASA Story", "Equipment", "Farming", "Field Guide", "Base Building", "Atlas", "Creatures", "Bosses", "Artifacts & Caves"]
        XCTAssertTrue(picker.isHittable)
        for (id, title) in zip(ids, titles) {
            let button = app.buttons["section-" + id]
            XCTAssertTrue(button.isHittable, title)
            XCTAssertEqual(button.label, title)
            XCTAssertEqual(button.frame.midY, picker.frame.midY, accuracy: 4)
        }
        XCTAssertEqual(logo.frame.midY, picker.frame.midY, accuracy: 4)
        XCTAssertFalse(app.staticTexts["current-map-header"].exists)
        picker.tap()
        XCTAssertTrue(app.scrollViews["maps-list"].waitForExistence(timeout: 8))
        let rag = app.buttons["choose-ragnarok"]
        for _ in 0..<8 { if rag.isHittable { break }; app.scrollViews["maps-list"].swipeUp() }
        rag.tap()
        XCTAssertEqual(app.buttons["maps-picker"].label, "Maps · Ragnarok")
        let screenshot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        screenshot.name = "One-row-navigation-Ragnarok"; screenshot.lifetime = .keepAlways; add(screenshot)
    }

    @MainActor func testFarmingResourceFirstLayoutAndSingleClip() {
        XCUIDevice.shared.orientation = .landscapeLeft
        let app = XCUIApplication(); app.launch()
        app.buttons["maps-picker"].tap()
        XCTAssertTrue(app.scrollViews["maps-list"].waitForExistence(timeout: 8))
        let rag = app.buttons["choose-ragnarok"]
        for _ in 0..<8 { if rag.isHittable { break }; app.scrollViews["maps-list"].swipeUp() }
        rag.tap(); app.buttons["section-Khai thác"].tap()
        let strip = app.scrollViews["farming-resource-strip"]
        XCTAssertTrue(strip.waitForExistence(timeout: 8))
        XCTAssertEqual(app.buttons["farm-resource-Metal"].value as? String, "Selected")
        XCTAssertFalse(app.buttons["farm-resource-Wood"].exists)
        XCTAssertFalse(app.buttons["farm-resource-Stone"].exists)
        let miniMap = app.scrollViews["farming-mini-map"]
        let sideBySide = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in
            miniMap.exists && abs(miniMap.frame.width - ((app.frame.width - 64) / 3)) < 2
        }, object: miniMap)
        XCTAssertEqual(XCTWaiter.wait(for: [sideBySide], timeout: 8), .completed)
        XCTAssertFalse(app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "farmClipSelect-")).firstMatch.exists)
        let source = app.descendants(matching: .any).matching(identifier: "farmClipSource").firstMatch
        if !source.waitForExistence(timeout: 5) {
            print("FARM-SOURCE-DEBUG " + app.debugDescription)
            let shot = XCTAttachment(screenshot: XCUIScreen.main.screenshot()); shot.name = "Farming-source-debug"; shot.lifetime = .keepAlways; add(shot)
        }
        XCTAssertTrue(source.exists)
        XCTAssertFalse(app.staticTexts["Area / coordinates"].exists)
        XCTAssertFalse(app.buttons["Watch the route"].exists)
        let search = app.searchFields.firstMatch
        search.tap()
        XCTAssertTrue(app.keyboards.firstMatch.waitForExistence(timeout: 5))
        search.typeText("Black Pearls"); app.keyboards.buttons["Search"].tap()
        let resource = app.buttons["farm-resource-Black Pearls"]
        XCTAssertTrue(resource.waitForExistence(timeout: 5)); resource.tap()
        XCTAssertEqual(resource.value as? String, "Selected")
        XCTAssertFalse(app.buttons["farm-resource-Metal"].exists)
        XCTAssertTrue(app.scrollViews["farming-location-strip"].exists)
        let screenshot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        screenshot.name = "Farming-clean-footage-LAT-LON"; screenshot.lifetime = .keepAlways; add(screenshot)
    }
    @MainActor func testSourceTilesDeepZoomAndFit() {
        XCUIDevice.shared.orientation = .landscapeLeft
        let app = XCUIApplication(); app.launch()
        app.buttons["maps-picker"].tap()
        XCTAssertTrue(app.scrollViews["maps-list"].waitForExistence(timeout: 8))
        app.buttons["choose-scorched-earth"].tap()
        let viewport = app.scrollViews["ragnarokMapViewport"]
        XCTAssertTrue(viewport.waitForExistence(timeout: 8))
        for _ in 0..<5 { if app.buttons["zoomIn"].isHittable { break }; app.scrollViews["mapFilterRail"].swipeUp() }
        for _ in 0..<5 { app.buttons["zoomIn"].tap() }
        let zoom = Double(viewport.value as? String ?? "0") ?? 0
        XCTAssertGreaterThan(zoom, 8)
        let screenshot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        screenshot.name = "Source-tiles-deep-zoom"; screenshot.lifetime = .keepAlways; add(screenshot)
        app.buttons["resetMap"].tap()
        let fitted = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in
            abs((Double(viewport.value as? String ?? "0") ?? 0) - 1) < 0.1
        }, object: viewport)
        XCTAssertEqual(XCTWaiter.wait(for: [fitted], timeout: 5), .completed)
    }

}
