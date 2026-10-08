import XCTest

final class Survival38UITests: XCTestCase {
    @MainActor func testVisualGuideProgressPersistsAndOtherMapsDoNotReuseIslandRoute() {
        XCUIDevice.shared.orientation = .landscapeLeft
        let app = XCUIApplication(); app.launch()
        func chooseIsland() { app.buttons["maps-picker"].tap(); app.buttons["choose-the-island"].tap() }
        func openGuide() { app.buttons["section-Survival Guide"].tap(); XCTAssertTrue(app.descendants(matching: .any)["survival-guide"].waitForExistence(timeout: 5)) }
        chooseIsland(); openGuide()
        let strip = app.scrollViews["survival-phase-strip"]
        for _ in 0..<8 { if app.buttons["survival-phase-shore"].isHittable { break }; strip.swipeRight() }
        app.buttons["survival-phase-shore"].tap()
        let goal = app.buttons["survival-check-shore/bed"]
        XCTAssertTrue(goal.isHittable)
        let original = goal.value as? String
        goal.tap()
        let updated = goal.value as? String
        XCTAssertNotEqual(original, updated)
        app.terminate(); app.launch(); openGuide()
        for _ in 0..<8 { if app.buttons["survival-phase-shore"].isHittable { break }; app.scrollViews["survival-phase-strip"].swipeRight() }
        app.buttons["survival-phase-shore"].tap()
        XCTAssertEqual(goal.value as? String, updated)
        goal.tap() // Preserve the user's original checklist state.
        XCTAssertEqual(goal.value as? String, original)
        app.buttons["survival-info-shore/bed"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["survival-goal-detail"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Source references"].exists)
        app.buttons["Done"].tap()
        app.buttons["survival-sources"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["survival-source-sheet"].waitForExistence(timeout: 5))
        app.buttons["Done"].tap()
        let shot = XCTAttachment(screenshot: XCUIScreen.main.screenshot()); shot.name = "Survival38-Beach-Home"; shot.lifetime = .keepAlways; add(shot)
        app.buttons["maps-picker"].tap(); app.buttons["choose-ragnarok"].tap()
        app.buttons["section-Survival Guide"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["survival-map-unavailable"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["survival-check-shore/bed"].exists)
        chooseIsland(); openGuide()
        app.scrollViews["survival-phase-strip"].swipeLeft()
        let army = app.buttons["survival-phase-army"]
        for _ in 0..<6 { if army.isHittable { break }; app.scrollViews["survival-phase-strip"].swipeLeft() }
        army.tap()
        XCTAssertTrue(app.buttons["survival-check-army/theri-army"].isHittable)
        let phaseIDs = ["shore", "flight", "home", "explore", "army", "guardians", "dragon", "ascend"]
        for phaseID in phaseIDs {
            let phaseButton = app.buttons["survival-phase-" + phaseID]
            for _ in 0..<10 {
                if phaseButton.isHittable { break }
                if phaseID == "shore" || phaseID == "flight" || phaseID == "home" || phaseID == "explore" { app.scrollViews["survival-phase-strip"].swipeRight() }
                else { app.scrollViews["survival-phase-strip"].swipeLeft() }
            }
            phaseButton.tap()
            let grid = app.scrollViews["survival-goal-grid"]
            let checks = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "survival-check-" + phaseID + "/")).allElementsBoundByIndex
            XCTAssertFalse(checks.isEmpty)
            for check in checks {
                XCTAssertTrue(check.isHittable, check.identifier)
                XCTAssertLessThanOrEqual(check.frame.maxY, grid.frame.maxY + 1, check.identifier + " requires vertical scrolling")
            }
        }
        for _ in 0..<8 { if army.isHittable { break }; app.scrollViews["survival-phase-strip"].swipeRight() }
        army.tap()
        let armyShot = XCTAttachment(screenshot: XCUIScreen.main.screenshot()); armyShot.name = "Survival38-Army"; armyShot.lifetime = .keepAlways; add(armyShot)
    }
}
