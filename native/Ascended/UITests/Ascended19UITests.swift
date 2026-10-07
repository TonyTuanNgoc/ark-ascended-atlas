import XCTest
final class Ascended19UITests:XCTestCase {
    @MainActor func testTopMapsAndReadableRail() {
        let app=XCUIApplication();XCUIDevice.shared.orientation = .landscapeLeft;app.launch()
        app.buttons["maps-picker"].tap()
        XCTAssertTrue(app.buttons["choose-the-island"].waitForExistence(timeout:5));app.buttons["choose-the-island"].tap()
        XCTAssertFalse(app.buttons["section-Map & DLC"].exists)
        XCTAssertTrue(app.buttons["layer-Cửa hang"].waitForExistence(timeout:5))
        XCTAssertTrue(app.buttons["layer-Cửa hang"].label.contains("Cave Entrances"))
        let shot=XCTAttachment(screenshot:XCUIScreen.main.screenshot());shot.name="English-map-wide-rail";shot.lifetime = .keepAlways;add(shot)
    }
    @MainActor func testGalleryStagesAndManualIsolation() {
        let app=XCUIApplication();XCUIDevice.shared.orientation = .landscapeLeft;app.launch()
        let base=app.buttons["section-Xây base"]
        for _ in 0..<8 {if base.isHittable {break};app.collectionViews.firstMatch.swipeUp()};base.tap()
        XCTAssertTrue(app.buttons["gallery-zone-home"].waitForExistence(timeout:8))
        app.buttons["Build freely"].tap()
        let count=app.staticTexts["builder-count"].value as? String
        app.buttons["House designs"].tap()
        for zone in ["home","workshop","storage","garden","forge"] {app.buttons["gallery-zone-"+zone].tap();XCTAssertEqual(app.buttons.matching(NSPredicate(format:"identifier BEGINSWITH %@","gallery-build-")).count,3);app.buttons["gallery-stage-3"].tap()}
                let shot=XCTAttachment(screenshot:XCUIScreen.main.screenshot());shot.name="Community-3D-progress-materials";shot.lifetime = .keepAlways;add(shot)
        app.buttons["Build freely"].tap();XCTAssertEqual(app.staticTexts["builder-count"].value as? String,count);XCTAssertTrue(app.buttons["builder-place"].waitForExistence(timeout:5))
        XCTAssertTrue(app.buttons["Stone"].exists);XCTAssertTrue(app.buttons["Metal"].exists)
    }
    @MainActor func testEnglishStoryAndSevenColumnLibrary() {
        let app=XCUIApplication();XCUIDevice.shared.orientation = .landscapeLeft;app.launch()
        func section(_ id:String) {
            let b=app.buttons[id]
            for _ in 0..<6 {if b.isHittable {break};app.collectionViews.firstMatch.swipeDown()};b.tap()
        }
        section("section-Cốt truyện ARK")
        XCTAssertTrue(app.scrollViews["storyGuide"].waitForExistence(timeout:5))
        app.buttons["story-start"].tap()
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format:"label BEGINSWITH %@","You wake up")).firstMatch.exists)
        let story=XCTAttachment(screenshot:XCUIScreen.main.screenshot());story.name="English-story-cards";story.lifetime = .keepAlways;add(story)
        section("section-Thư viện")
        app.buttons["equipment-category-resources"].tap()
        XCTAssertTrue(app.buttons["equipment-absorbent-substrate"].waitForExistence(timeout:5))
        let firstRow=["absorbent-substrate","achatina-paste","ambergris","ammonite-bile","anglergel","bio-toxin","black-pearl"].map {app.buttons["equipment-"+$0].frame}
        XCTAssertEqual(firstRow.count,7)
        XCTAssertTrue(firstRow.allSatisfy {abs($0.minY-firstRow[0].minY)<2})
        let library=XCTAttachment(screenshot:XCUIScreen.main.screenshot());library.name="Seven-column-English-library";library.lifetime = .keepAlways;add(library)
    }
    @MainActor func testPortraitHeaderGeometry() {
        let app=XCUIApplication();XCUIDevice.shared.orientation = .landscapeLeft;app.launch()
        let landscape=XCTNSPredicateExpectation(predicate:NSPredicate { _,_ in app.frame.width > app.frame.height },object:app)
        guard XCTWaiter.wait(for:[landscape],timeout:8) == .completed else {
            XCTFail("Landscape precondition was not delivered: app frame \(app.frame)"); return
        }
        XCUIDevice.shared.orientation = .portrait
        let rotated=XCTNSPredicateExpectation(predicate:NSPredicate { _,_ in app.frame.width < app.frame.height },object:app)
        guard XCTWaiter.wait(for:[rotated],timeout:8) == .completed else {
            XCTFail("Portrait sensor rotation was not delivered: app frame \(app.frame). Portrait geometry is unverified."); return
        }
        let maps=app.buttons["maps-picker"]
        XCTAssertTrue(maps.isHittable);XCTAssertTrue(app.frame.contains(maps.frame))
        let logo=app.images["ascended-header-logo"]
        XCTAssertTrue(logo.exists)
        XCTAssertEqual(logo.frame.midX,app.frame.midX,accuracy:2)
        for layer in ["Cửa hang","Resources","My Locations"] {
            let label=app.buttons["expand-layer-"+layer]
            XCTAssertTrue(label.exists,"Expected portrait layer label: \(layer)")
            if label.exists {XCTAssertLessThanOrEqual(label.frame.height,50,"Layer label should use at most two readable lines: \(layer)")}
        }
        let screenshot=XCUIScreen.main.screenshot()
        XCTAssertLessThan(screenshot.image.size.width,screenshot.image.size.height,"Screenshot pixels must prove portrait, not just a sensor command")
        let geometry=XCTAttachment(string:"App: \(app.frame); screenshot: \(screenshot.image.size); Maps: \(maps.frame); centered logo: \(logo.frame)")
        geometry.name="Portrait-verified-geometry";geometry.lifetime = .keepAlways;add(geometry)
        let portrait=XCTAttachment(screenshot:screenshot);portrait.name="Portrait-map-header";portrait.lifetime = .keepAlways;add(portrait)
    }
}
