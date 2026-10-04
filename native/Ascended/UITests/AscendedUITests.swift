import XCTest

final class AscendedUITests: XCTestCase {
    @MainActor func testSessionNavigatorConfirmationAndResume() throws {
        let app = XCUIApplication()
        XCUIDevice.shared.orientation = .landscapeLeft
        app.launch()
        app.buttons["choose-ragnarok"].tap()
        XCTAssertTrue(app.staticTexts["session-title"].waitForExistence(timeout: 8))
        app.buttons["session-navigate"].tap()
        XCTAssertTrue(app.buttons["navigator-reset"].waitForExistence(timeout: 8))
        app.buttons["navigator-reset"].tap()
        XCTAssertEqual(app.staticTexts["navigator-location"].label, "Chưa xác nhận vị trí")
        app.buttons["diagram-waypoint-2"].tap()
        XCTAssertEqual(app.staticTexts["navigator-location"].label, "Chưa xác nhận vị trí")
        XCTAssertTrue(app.buttons["navigator-confirm"].label.contains("Nhánh gỗ"))
        app.buttons["navigator-confirm"].tap()
        XCTAssertEqual(app.staticTexts["navigator-location"].label, "Anh đang ở: Nhánh gỗ qua vực")
        XCTAssertTrue(app.buttons["navigator-confirm"].label.contains("Hành lang cam"))
        app.buttons["diagram-waypoint-8"].tap()
        app.buttons["navigator-confirm"].tap()
        app.switches["navigator-return"].tap()
        app.buttons["navigator-confirm"].tap()
        XCTAssertTrue(app.buttons["navigator-confirm"].label.contains("Sau thác"))
        XCTAssertTrue(app.staticTexts["navigator-next"].label.contains("GIF"))
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = "Jungle-waypoint-pilot"; attachment.lifetime = .keepAlways; add(attachment)
        app.terminate(); app.launch()
        app.buttons["choose-ragnarok"].tap(); app.buttons["session-navigate"].tap()
        XCTAssertEqual(app.staticTexts["navigator-location"].label, "Anh đang ở: Artifact Hunter")
        app.buttons["navigator-reset"].tap()
        app.buttons["changeMap"].tap(); app.buttons["choose-the-island"].tap()
        XCTAssertTrue(app.staticTexts["session-title"].waitForExistence(timeout: 8))
        XCTAssertFalse(app.buttons["session-navigate"].exists)
    }

    @MainActor func testRagnarokMapNavigation() throws {
        let app = XCUIApplication()
        XCUIDevice.shared.orientation = .landscapeLeft
        app.launch()
        XCTAssertTrue(app.buttons["choose-ragnarok"].waitForExistence(timeout: 8)); app.buttons["choose-ragnarok"].tap(); app.buttons["section-Thông tin map"].tap()
        Thread.sleep(forTimeInterval: 1)
        XCTAssertTrue(app.buttons["openRagnarokMap"].waitForExistence(timeout: 10))
        let overview = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        overview.name = "Ragnarok-landscape"; overview.lifetime = .keepAlways; add(overview)
        app.buttons["openRagnarokMap"].tap()
        XCTAssertTrue(app.buttons["resetMap"].waitForExistence(timeout: 5))
        app.buttons["resetMap"].tap()
        let map = app.descendants(matching: .any)["ragnarokMapViewport"].firstMatch
        XCTAssertTrue(map.waitForExistence(timeout: 5))
        XCTAssertEqual(map.value as? String, "1.00")
        map.doubleTap()
        let zoomed = NSPredicate(format: "value != %@", "1.00")
        expectation(for: zoomed, evaluatedWith: map)
        waitForExpectations(timeout: 5)
        map.swipeLeft()
        app.buttons["resetMap"].tap()
        expectation(for: NSPredicate(format: "value == %@", "1.00"), evaluatedWith: map)
        waitForExpectations(timeout: 5)
        let landscape = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        landscape.name = "Map-landscape"; landscape.lifetime = .keepAlways; add(landscape)
        XCUIDevice.shared.orientation = .portrait
        Thread.sleep(forTimeInterval: 1)
        XCTAssertTrue(app.buttons["resetMap"].waitForExistence(timeout: 5))
        let portrait = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        portrait.name = "Map-portrait"; portrait.lifetime = .keepAlways; add(portrait)
        XCUIDevice.shared.orientation = .landscapeLeft
        Thread.sleep(forTimeInterval: 1)
        XCTAssertFalse(app.buttons["section-Ghi chú"].exists)
        XCTAssertFalse(app.buttons["section-Nguồn tham khảo"].exists)

    }
    @MainActor func testCurrentCreatureLibraryAndBosses() throws {
        let app = XCUIApplication()
        XCUIDevice.shared.orientation = .landscapeLeft
        app.launch()
        XCTAssertTrue(app.buttons["choose-ragnarok"].waitForExistence(timeout: 8)); app.buttons["choose-ragnarok"].tap(); app.buttons["section-Thông tin map"].tap()
        XCTAssertTrue(app.buttons["openDinos"].waitForExistence(timeout: 10))
        app.buttons["openDinos"].tap()
        XCTAssertTrue(app.buttons["filter-DLC"].waitForExistence(timeout: 5))
        app.buttons["filter-DLC"].tap()
        XCTAssertTrue(app.staticTexts["12"].waitForExistence(timeout: 5))
        let library = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        library.name = "Dino-DLC-library"; library.lifetime = .keepAlways; add(library)
        let search = app.searchFields.firstMatch
        XCTAssertTrue(search.waitForExistence(timeout: 5))
        search.tap(); search.typeText("Cerberax")
        XCTAssertTrue(app.buttons["creature-cerberax"].waitForExistence(timeout: 5))
        app.buttons["creature-cerberax"].tap()
        XCTAssertTrue(app.staticTexts["Cập nhật mới"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Thử thách đặc biệt"].exists)
        let detail = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        detail.name = "Cerberax-profile"; detail.lifetime = .keepAlways; add(detail)
        app.buttons["section-Boss"].tap()
        XCTAssertTrue(app.buttons["boss-nunatak"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["1 boss chính · 4 mini-boss có tên · 3 nhóm trận hang động"].exists)
        let bosses = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        bosses.name = "Boss-library"; bosses.lifetime = .keepAlways; add(bosses)
        for _ in 0..<5 { if app.buttons["boss-nunatak"].isHittable { break }; app.swipeUp() }
        app.buttons["boss-nunatak"].tap()
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "Gamma")).firstMatch.waitForExistence(timeout: 5))
    }

    @MainActor func testArtifactRouteMapLayersAndBossDifficulty() throws {
        let app = XCUIApplication()
        XCUIDevice.shared.orientation = .landscapeLeft
        app.launch()
        XCTAssertTrue(app.buttons["choose-ragnarok"].waitForExistence(timeout: 8)); app.buttons["choose-ragnarok"].tap(); app.buttons["section-Thông tin map"].tap()
        app.buttons["Artifact & Hang"].firstMatch.tap()
        XCTAssertTrue(app.buttons["route-jungle"].waitForExistence(timeout: 5))
        app.buttons["route-jungle"].tap()
        let hunter = app.buttons["artifact-hunter"]
        for _ in 0..<3 { if hunter.isHittable { break }; app.swipeUp() }
        XCTAssertTrue(hunter.isHittable); hunter.tap()
        XCTAssertTrue(app.buttons["show-artifact-hunter"].waitForExistence(timeout: 5), app.debugDescription)
        XCTAssertTrue(app.staticTexts["LAT 21.58 · LON 27.26"].waitForExistence(timeout: 5))
        app.buttons["show-artifact-hunter"].tap()
        let map = app.scrollViews["ragnarokMapViewport"]
        XCTAssertTrue(map.waitForExistence(timeout: 5))
        expectation(for: NSPredicate(format: "value == %@", "4.00"), evaluatedWith: map)
        waitForExpectations(timeout: 5)
        let pin = app.buttons["pin-artifact-hunter"]
        XCTAssertTrue(pin.exists); XCTAssertTrue(pin.isHittable)
        XCTAssertLessThan(pin.frame.width, 60)
        pin.tap()
        let clusterChoice = app.collectionViews.buttons["Artifact of the Hunter"].firstMatch
        if clusterChoice.waitForExistence(timeout: 2) { clusterChoice.tap() }
        XCTAssertEqual(app.staticTexts["selectedMapLocation"].label, "Artifact of the Hunter")
        let focused = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        focused.name = "Artifact-focused-map"; focused.lifetime = .keepAlways; add(focused)
        XCUIDevice.shared.orientation = .portrait
        Thread.sleep(forTimeInterval: 1)
        XCTAssertTrue(pin.isHittable); XCTAssertLessThan(pin.frame.width, 60)
        let portrait = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        portrait.name = "Artifact-focused-portrait"; portrait.lifetime = .keepAlways; add(portrait)
        XCUIDevice.shared.orientation = .landscapeLeft
        Thread.sleep(forTimeInterval: 1)
        app.buttons["layer-Artifact"].tap()
        XCTAssertFalse(app.buttons["pin-artifact-hunter"].exists)
        app.buttons["layer-Artifact"].tap()
        XCTAssertTrue(app.buttons["pin-artifact-hunter"].exists)
        app.buttons["section-Boss"].tap()
        XCTAssertTrue(app.buttons["boss-nunatak"].waitForExistence(timeout: 5))
        for _ in 0..<5 { if app.buttons["boss-nunatak"].isHittable { break }; app.swipeUp() }
        app.buttons["boss-nunatak"].tap()
        let alpha = app.segmentedControls["bossDifficulty"].buttons["Alpha"]
        for _ in 0..<3 { if alpha.isHittable { break }; app.swipeUp() }
        XCTAssertTrue(alpha.isHittable); alpha.tap()
        XCTAssertTrue(app.staticTexts["1.250.000"].exists)
        XCTAssertTrue(app.staticTexts["550"].exists)
        let boss = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        boss.name = "Nunatak-Alpha-guide"; boss.lifetime = .keepAlways; add(boss)
    }

    @MainActor func testMapSelectionIsolationAndProgress() throws {
        let app = XCUIApplication()
        XCUIDevice.shared.orientation = .landscapeLeft
        app.launch()
        XCTAssertTrue(app.buttons["choose-the-island"].waitForExistence(timeout: 8))
        let picker = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        picker.name = "Three-map-picker"; picker.lifetime = .keepAlways; add(picker)
        app.buttons["choose-the-island"].tap(); app.buttons["section-Thông tin map"].tap()
        XCTAssertEqual(app.staticTexts["mapInformationTitle"].label, "The Island")
        app.buttons["section-Boss"].tap()
        XCTAssertTrue(app.staticTexts["bossCampaignTitle"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["boss-dragon"].exists)
        XCTAssertFalse(app.buttons["boss-nunatak"].exists)
        app.buttons["boss-broodmother"].tap()
        let artifact = app.buttons["boss-artifact-hunter"]
        for _ in 0..<4 { if artifact.isHittable { break }; app.swipeUp() }
        XCTAssertTrue(artifact.isHittable); artifact.tap()
        XCTAssertTrue(app.staticTexts["LAT 89.11 · LON 57.05"].waitForExistence(timeout: 5))
        let collected = app.switches["collected-hunter"]
        for _ in 0..<3 { if collected.isHittable { break }; app.swipeUp() }
        XCTAssertTrue(collected.isHittable)
        if collected.value as? String != "1" { collected.tap() }
        XCTAssertEqual(collected.value as? String, "1")
        app.buttons["changeMap"].tap()
        app.buttons["choose-the-center"].tap(); app.buttons["section-Thông tin map"].tap()
        XCTAssertEqual(app.staticTexts["mapInformationTitle"].label, "The Center")
        app.buttons["section-Dino"].tap()
        let search = app.searchFields.firstMatch
        XCTAssertTrue(search.waitForExistence(timeout: 5)); search.tap(); search.typeText("Shastasaurus")
        XCTAssertTrue(app.buttons["creature-shastasaurus"].waitForExistence(timeout: 5))
        app.buttons["creature-shastasaurus"].tap()
        app.buttons["section-Boss"].tap()
        XCTAssertTrue(app.buttons["boss-broodmother"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["boss-megapithecus"].exists)
        XCTAssertFalse(app.buttons["boss-dragon"].exists); XCTAssertFalse(app.buttons["boss-overseer"].exists)
        app.buttons["boss-broodmother"].tap()
        let centerHunter = app.buttons["boss-artifact-hunter"]
        for _ in 0..<5 { if centerHunter.isHittable { break }; app.swipeUp() }
        XCTAssertTrue(centerHunter.isHittable); centerHunter.tap()
        XCTAssertTrue(app.staticTexts["LAT 19.99 · LON 49.81"].waitForExistence(timeout: 5))
        for _ in 0..<3 { if collected.isHittable { break }; app.swipeUp() }
        XCTAssertTrue(collected.isHittable)
        // Leave Center's Hunter uncollected, independent of Island's collected Hunter.
        if collected.value as? String == "1" { collected.tap() }
        XCTAssertEqual(collected.value as? String, "0")
        app.buttons["show-artifact-hunter"].tap()
        let viewport = app.scrollViews["ragnarokMapViewport"]
        XCTAssertTrue(viewport.waitForExistence(timeout: 5))
        XCTAssertEqual(viewport.label, "Bản đồ The Center")
        let centerMap = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        centerMap.name = "Center-focused-map"; centerMap.lifetime = .keepAlways; add(centerMap)
        app.buttons["changeMap"].tap()
        app.buttons["choose-the-island"].tap(); app.buttons["section-Thông tin map"].tap()
        XCTAssertEqual(app.staticTexts["mapInformationTitle"].label, "The Island")
        // Verify map progress after a real process restart.
        app.terminate(); app.launch()
        app.buttons["choose-the-island"].tap(); app.buttons["section-Thông tin map"].tap()
        app.buttons["section-Artifact & Hang"].tap()
        app.buttons["route-lower-south"].tap()
        let hunter = app.buttons["artifact-hunter"]
        for _ in 0..<3 { if hunter.isHittable { break }; app.swipeUp() }
        hunter.tap()
        for _ in 0..<3 { if collected.isHittable { break }; app.swipeUp() }
        XCTAssertEqual(collected.value as? String, "1")
        collected.tap() // Restore collection state for later sessions.
    }

    @MainActor func testBossCampaignArmiesAndBaseMapLinks() throws {
        let app = XCUIApplication()
        XCUIDevice.shared.orientation = .landscapeLeft
        app.launch()
        XCTAssertTrue(app.buttons["choose-ragnarok"].waitForExistence(timeout: 8)); app.buttons["choose-ragnarok"].tap(); app.buttons["section-Thông tin map"].tap()
        app.buttons["section-Boss"].tap()
        XCTAssertTrue(app.staticTexts["boss-step-queen"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["boss-step-lava"].exists)
        let army = app.buttons["army-nunatak"]
        for _ in 0..<5 { if army.isHittable { break }; app.swipeUp() }
        XCTAssertTrue(army.isHittable); army.tap()
        XCTAssertTrue(app.staticTexts["armyTitle"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["armyTitle"].label.contains("Nunatak"))
        XCTAssertTrue(app.staticTexts["armyOptionCount"].label.hasPrefix("3"))
        let options = app.buttons["armyOptions"]
        XCTAssertTrue(options.exists); options.tap()
        app.buttons["Therizino + cake · tái dùng dòng breed"].tap()
        XCTAssertTrue(app.staticTexts["armyOptionTitle"].label.contains("Therizino"))
        let armyShot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        armyShot.name = "Nunatak-army-options"; armyShot.lifetime = .keepAlways; add(armyShot)
        app.buttons["section-Base Location"].tap()
        XCTAssertTrue(app.staticTexts["baseLocationsTitle"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["base-canyon"].exists)
        XCTAssertFalse(app.staticTexts["basePreview-caption-canyon"].exists)
        XCTAssertFalse(app.buttons["section-Ghi chú"].exists)
        XCTAssertFalse(app.buttons["section-Nguồn tham khảo"].exists)
        XCTAssertTrue(app.buttons["base-falls"].exists)
        XCTAssertTrue(app.buttons["base-viking"].exists)
        XCTAssertTrue(app.buttons["base-highlands"].exists)
        XCTAssertTrue(app.buttons["base-herbivore"].exists)
        let baseShot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        baseShot.name = "Ragnarok-base-shortlist"; baseShot.lifetime = .keepAlways; add(baseShot)
        app.buttons["base-canyon"].tap()
        XCTAssertTrue(app.staticTexts["LAT 39.80 · LON 44.80"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.links["baseVideo"].exists || app.buttons["baseVideo"].exists)
        app.buttons["show-base-canyon"].tap()
        XCTAssertTrue(app.scrollViews["ragnarokMapViewport"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["pin-base-canyon"].isHittable)
        XCTAssertEqual(app.staticTexts["selectedMapLocation"].label, "Canyon Plateaus")
        let mapShot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        mapShot.name = "Base-focused-map"; mapShot.lifetime = .keepAlways; add(mapShot)
        app.buttons["mapBaseProfile"].tap()
        XCTAssertTrue(app.buttons["show-base-canyon"].waitForExistence(timeout: 5))
        app.buttons["changeMap"].tap(); app.buttons["choose-the-island"].tap(); app.buttons["section-Thông tin map"].tap()
        XCTAssertFalse(app.buttons["section-Base Location"].exists)
        app.buttons["section-Boss"].tap()
        XCTAssertTrue(app.staticTexts["boss-step-monkey"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["boss-nunatak"].exists)
        let mega = app.buttons["army-broodmother"]
        for _ in 0..<4 { if mega.isHittable { break }; app.swipeUp() }
        XCTAssertTrue(mega.isHittable); mega.tap()
        XCTAssertTrue(app.staticTexts["armyOptionTitle"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["armyOptionTitle"].label.contains("Megatherium"))
        app.buttons["changeMap"].tap(); app.buttons["choose-the-center"].tap(); app.buttons["section-Thông tin map"].tap()
        XCTAssertFalse(app.buttons["section-Base Location"].exists)
        app.buttons["section-Boss"].tap()
        XCTAssertTrue(app.staticTexts["boss-step-joint"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["boss-dragon"].exists)
        app.buttons["army-megapithecus"].tap()
        XCTAssertTrue(app.staticTexts["armyTitle"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["armyOptionCount"].label.hasPrefix("3"))
    }

    @MainActor func testCompactCardsAndCaveVideos() throws {
        let app = XCUIApplication()
        XCUIDevice.shared.orientation = .landscapeLeft
        app.launch()
        app.buttons["choose-ragnarok"].tap(); app.buttons["section-Thông tin map"].tap()
        XCTAssertFalse(app.buttons["section-Ghi chú"].exists)
        XCTAssertFalse(app.buttons["section-Nguồn tham khảo"].exists)
        app.buttons["section-Base Location"].tap()
        let tile = app.buttons["base-canyon"]
        XCTAssertTrue(tile.waitForExistence(timeout: 5))
        XCTAssertEqual(tile.frame.width, tile.frame.height, accuracy: 2)
        XCTAssertFalse(app.staticTexts["Video đã đối chiếu"].exists)
        let grid = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        grid.name = "Compact-base-grid"; grid.lifetime = .keepAlways; add(grid)
        app.buttons["section-Artifact & Hang"].tap()
        let cave = app.buttons["route-jungle"]
        XCTAssertTrue(cave.waitForExistence(timeout: 5))
        XCTAssertEqual(cave.frame.width, cave.frame.height, accuracy: 2)
        cave.tap()
        let fullVideo = app.buttons["full-cave-video-jungle"]
        for _ in 0..<6 { if fullVideo.isHittable { break }; app.swipeUp() }
        XCTAssertTrue(fullVideo.isHittable); fullVideo.tap()
        let chapter = app.buttons["cave-video-jungle-134"]
        for _ in 0..<4 { if chapter.isHittable { break }; app.swipeUp() }
        XCTAssertTrue(chapter.isHittable)
        let route = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        route.name = "Cave-video-chapters"; route.lifetime = .keepAlways; add(route)
        chapter.tap()
        // SFSafariViewController presents the source video in-app; playback needs network.
        XCTAssertTrue(app.buttons["Close"].waitForExistence(timeout: 15))
        app.buttons["Close"].tap()
        XCTAssertTrue(chapter.waitForExistence(timeout: 5))
        XCTAssertTrue(chapter.isHittable)
        app.buttons["changeMap"].tap()
        app.buttons["choose-the-island"].tap(); app.buttons["section-Thông tin map"].tap()
        app.buttons["section-Artifact & Hang"].tap()
        app.buttons["route-central"].tap()
        let islandVideo = app.buttons["full-cave-video-central"]
        for _ in 0..<6 { if islandVideo.isHittable { break }; app.swipeUp() }
        XCTAssertTrue(islandVideo.isHittable); islandVideo.tap()
        XCTAssertTrue(app.buttons["cave-video-central-196"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["cave-video-jungle-134"].exists)
        app.buttons["changeMap"].tap()
        app.buttons["choose-the-center"].tap(); app.buttons["section-Thông tin map"].tap()
        app.buttons["section-Artifact & Hang"].tap()
        app.buttons["route-north-ice"].tap()
        let centerVideo = app.buttons["full-cave-video-north-ice"]
        for _ in 0..<6 { if centerVideo.isHittable { break }; app.swipeUp() }
        XCTAssertTrue(centerVideo.isHittable); centerVideo.tap()
        XCTAssertTrue(app.buttons["cave-video-north-ice-325"].waitForExistence(timeout: 5))
    }

    @MainActor func testLocalGIFPlaybackAndMapIsolation() throws {
        let app = XCUIApplication()
        XCUIDevice.shared.orientation = .landscapeLeft
        app.launch()
        XCTAssertTrue(app.buttons["choose-the-island"].waitForExistence(timeout: 8))
        app.buttons["choose-the-island"].tap(); app.buttons["section-Thông tin map"].tap()
        app.buttons["section-Artifact & Hang"].tap()
        app.buttons["route-central"].tap()
        func reveal(_ element: XCUIElement) {
            for _ in 0..<10 { if element.isHittable { break }; app.swipeUp() }
            for _ in 0..<4 {
                let delta = element.frame.maxY - (app.frame.maxY - 150)
                if delta <= 0 { break }
                let origin = app.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
                let x = app.frame.maxX - 90, y = app.frame.maxY - 100
                origin.withOffset(CGVector(dx: x, dy: y)).press(forDuration: 0.1,
                    thenDragTo: origin.withOffset(CGVector(dx: x, dy: y - min(delta, 350))))
            }
        }
        let clip = app.descendants(matching: .any)["cave-gif-central-clever-01"].firstMatch
        reveal(clip)
        XCTAssertTrue(clip.isHittable)
        XCTAssertEqual(clip.value as? String, "Đang phát")
        XCTAssertFalse(app.buttons["gif-previous-central"].isEnabled)
        Thread.sleep(forTimeInterval: 2)
        let first = clip.screenshot().pngRepresentation
        Thread.sleep(forTimeInterval: 1.5)
        XCTAssertNotEqual(first, clip.screenshot().pngRepresentation, "GIF must animate without tapping")
        clip.swipeLeft()
        let second = app.descendants(matching: .any)["cave-gif-central-clever-02"].firstMatch
        expectation(for: NSPredicate(format: "value == %@", "Đang phát"), evaluatedWith: second)
        waitForExpectations(timeout: 5)
        XCTAssertEqual(app.staticTexts["gif-position-central"].label, "2 / 4")
        XCTAssertTrue(app.staticTexts["cave-direction-clever-02"].exists)
        second.swipeRight()
        expectation(for: NSPredicate(format: "value == %@", "Đang phát"), evaluatedWith: clip)
        waitForExpectations(timeout: 5)
        let card = app.buttons["gif-card-central-clever-04"]
        for _ in 0..<4 { if card.isHittable { break }; app.swipeUp() }
        XCTAssertTrue(card.isHittable); card.tap()
        XCTAssertEqual(app.staticTexts["gif-position-central"].label, "4 / 4")
        XCTAssertEqual(card.value as? String, "Đang chọn")
        XCTAssertFalse(app.buttons["gif-next-central"].isEnabled)
        let selected = app.descendants(matching: .any)["cave-gif-central-clever-04"].firstMatch
        Thread.sleep(forTimeInterval: 2)
        let selectedFrame = selected.screenshot().pngRepresentation
        Thread.sleep(forTimeInterval: 1.5)
        XCTAssertNotEqual(selectedFrame, selected.screenshot().pngRepresentation, "Selected card must autoplay its own GIF")
        let playing = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        playing.name = "Auto-GIF-card-library"; playing.lifetime = .keepAlways; add(playing)
        app.buttons["changeMap"].tap(); app.buttons["choose-ragnarok"].tap(); app.buttons["section-Thông tin map"].tap()
        app.buttons["section-Artifact & Hang"].tap(); app.buttons["route-jungle"].tap()
        let rag = app.descendants(matching: .any).matching(NSPredicate(format: "identifier BEGINSWITH %@", "cave-gif-jungle-")).firstMatch
        reveal(rag)
        XCTAssertTrue(rag.isHittable)
        XCTAssertEqual(rag.value as? String, "Đang phát")
        XCTAssertFalse(clip.exists)
        app.buttons["changeMap"].tap(); app.buttons["choose-the-center"].tap(); app.buttons["section-Thông tin map"].tap()
        app.buttons["section-Artifact & Hang"].tap(); app.buttons["route-north-ice"].tap()
        let center = app.descendants(matching: .any).matching(NSPredicate(format: "identifier BEGINSWITH %@", "cave-gif-north-ice-")).firstMatch
        reveal(center)
        XCTAssertTrue(center.isHittable)
        XCTAssertEqual(center.value as? String, "Đang phát")
        XCTAssertFalse(rag.exists)
        let shot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        shot.name = "Center-auto-GIF-directions"; shot.lifetime = .keepAlways; add(shot)
    }

    @MainActor func testGIFCarouselSectionsAndOrderedCards() throws {
        let app = XCUIApplication()
        XCUIDevice.shared.orientation = .landscapeLeft
        app.launch()
        app.buttons["choose-ragnarok"].tap(); app.buttons["section-Thông tin map"].tap()
        app.buttons["section-Artifact & Hang"].tap()
        app.buttons["route-carnivorous"].tap()
        let selector = app.buttons["gif-section-selector"]
        for _ in 0..<10 { if selector.isHittable { break }; app.swipeUp() }
        XCTAssertTrue(selector.isHittable)
        selector.tap()
        app.buttons["Từ cửa sườn núi → Cunning"].tap()
        XCTAssertEqual(app.staticTexts["gif-position-carnivorous"].label, "1 / 8")
        app.buttons["gif-next-carnivorous"].tap()
        XCTAssertEqual(app.staticTexts["gif-position-carnivorous"].label, "2 / 8")
        selector.tap(); app.buttons["Từ cửa dưới lâu đài → Immune"].tap()
        XCTAssertEqual(app.staticTexts["gif-position-carnivorous"].label, "1 / 10")
        let card = app.buttons["gif-card-carnivorous-immune-10"]
        for _ in 0..<4 { if app.buttons["gif-card-carnivorous-immune-01"].isHittable { break }; app.swipeUp() }
        let firstCard = app.buttons["gif-card-carnivorous-immune-01"]
        XCTAssertTrue(firstCard.isHittable)
        XCTAssertEqual(firstCard.frame.width, firstCard.frame.height, accuracy: 2)
        // Browse the horizontal library without changing the active step until a card is tapped.
        let origin = app.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        let libraryY = firstCard.frame.midY, libraryLeft = firstCard.frame.minX + 15
        for _ in 0..<5 {
            if card.isHittable { break }
            origin.withOffset(CGVector(dx: app.frame.maxX - 100, dy: libraryY)).press(forDuration: 0.1,
                thenDragTo: origin.withOffset(CGVector(dx: libraryLeft, dy: libraryY)))
        }
        XCTAssertTrue(card.isHittable)
        XCTAssertEqual(app.staticTexts["gif-position-carnivorous"].label, "1 / 10")
        card.tap()
        XCTAssertEqual(app.staticTexts["gif-position-carnivorous"].label, "10 / 10")
        XCTAssertEqual(card.value as? String, "Đang chọn")

    }

}
