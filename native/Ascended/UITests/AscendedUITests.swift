import XCTest

final class AscendedUITests: XCTestCase {
    @MainActor func testStoryBaseAndEquipmentLibrary() throws {
        let app = XCUIApplication(); XCUIDevice.shared.orientation = .landscapeLeft; app.launch()
        func sidebar(_ id: String) {
            let button = app.buttons[id]
            for _ in 0..<8 { if button.isHittable { break }; app.collectionViews.firstMatch.swipeDown() }
            for _ in 0..<8 { if button.isHittable { break }; app.collectionViews.firstMatch.swipeUp() }
            XCTAssertTrue(button.isHittable, id); button.tap()
        }
        sidebar("section-Cốt truyện ARK")
        XCTAssertTrue(app.scrollViews["storyGuide"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts.containing(NSPredicate(format: "label BEGINSWITH %@", "Bạn tỉnh dậy")).firstMatch.exists)
        app.buttons["story-start"].tap()
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label BEGINSWITH %@", "Bạn tỉnh dậy")).firstMatch.exists)
        let storyShot = XCTAttachment(screenshot: XCUIScreen.main.screenshot()); storyShot.name = "ARK-story-expand"; storyShot.lifetime = .keepAlways; add(storyShot)
        sidebar("section-Xây base")
        XCTAssertTrue(app.scrollViews["basePlanning"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["Điểm hồi sinh, thay đồ và chuẩn bị trước khi rời base."].exists)
        app.buttons["base-zone-main"].tap()
        XCTAssertTrue(app.staticTexts["Điểm hồi sinh, thay đồ và chuẩn bị trước khi rời base."].exists)
        let baseShot = XCTAttachment(screenshot: XCUIScreen.main.screenshot()); baseShot.name = "Base-zone-equipment"; baseShot.lifetime = .keepAlways; add(baseShot)
        app.buttons["Bố trí các khu"].tap()
        let industrial = app.buttons["base-layout-industry"]
        for _ in 0..<4 { if industrial.isHittable { break }; app.scrollViews["basePlanning"].swipeUp() }
        XCTAssertTrue(industrial.isHittable); industrial.tap()
        XCTAssertTrue(app.staticTexts["Luyện kim loại, sản xuất polymer và hóa chất, chế tạo trang bị."].waitForExistence(timeout: 5))
        sidebar("section-Thư viện")
        XCTAssertTrue(app.scrollViews["equipmentLibrary"].waitForExistence(timeout: 5))
        let search = app.searchFields.firstMatch; search.tap(); search.typeText("Chemistry Bench")
        let item = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Chemistry Bench")).firstMatch
        XCTAssertTrue(item.waitForExistence(timeout: 5)); item.tap()
        XCTAssertTrue(app.scrollViews["equipmentDetail"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Chemistry Bench"].firstMatch.exists)
        let machineShot = XCTAttachment(screenshot: XCUIScreen.main.screenshot()); machineShot.name = "Machine-reference"; machineShot.lifetime = .keepAlways; add(machineShot)
    }
    @MainActor func testCollapsedMapListsAndCatalogue() throws {
        let app = XCUIApplication(); XCUIDevice.shared.orientation = .landscapeLeft; app.launch()
        XCTAssertFalse(app.buttons["choose-scorched-earth"].exists)
        app.buttons["map-group-Cốt truyện"].tap()
        let island = app.buttons["choose-the-island"]
        XCTAssertTrue(island.isHittable); island.tap()
        XCTAssertEqual(app.descendants(matching: .any)["ragnarokMapViewport"].firstMatch.label, "Bản đồ The Island")
        let section = app.buttons["section-Map & DLC"]
        for _ in 0..<8 { if section.isHittable { break }; app.collectionViews.firstMatch.swipeUp() }
        section.tap()
        XCTAssertFalse(app.buttons["Chọn map"].exists)
        app.buttons["Map cốt truyện"].tap()
        let scorched = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Scorched Earth")).allElementsBoundByIndex.last!
        XCTAssertTrue(scorched.waitForExistence(timeout: 5)); scorched.tap()
        XCTAssertTrue(app.buttons["Chọn map"].exists)
        let shot = XCTAttachment(screenshot: XCUIScreen.main.screenshot()); shot.name = "Collapsed-map-catalogue"; shot.lifetime = .keepAlways; add(shot)
    }
    @MainActor func testExpansionMapsAndGenesisPlanes() throws {
        let app = XCUIApplication(); XCUIDevice.shared.orientation = .landscapeLeft; app.launch()
        func tapSidebar(_ id: String) {
            let button = app.buttons[id]
            for _ in 0..<8 { if button.isHittable { break }; app.collectionViews.firstMatch.swipeDown() }
            for _ in 0..<8 { if button.isHittable { break }; app.collectionViews.firstMatch.swipeUp() }
            XCTAssertTrue(button.isHittable, id); button.tap()
        }
        for id in ["the-island", "scorched-earth", "aberration", "extinction", "lost-colony", "genesis-part-1", "genesis-part-1-ocean", "the-center", "ragnarok", "valguero", "astraeos"] {
            tapSidebar("choose-" + id)
            XCTAssertTrue(app.descendants(matching: .any)["ragnarokMapViewport"].firstMatch.waitForExistence(timeout: 8), id)
            XCTAssertEqual(app.buttons["choose-" + id].value as? String, "Đang chọn")
            tapSidebar("section-Thông tin map")
            XCTAssertTrue(app.staticTexts["mapInformationTitle"].waitForExistence(timeout: 5))
            tapSidebar("section-Dino")
            XCTAssertTrue(app.scrollViews["creatureLibrary"].waitForExistence(timeout: 5))
            let shot = XCTAttachment(screenshot: XCUIScreen.main.screenshot()); shot.name = "Expansion-" + id; shot.lifetime = .keepAlways; add(shot)
        }
        tapSidebar("section-Map & DLC")
        XCTAssertTrue(app.otherElements["expansion-the-island"].exists || app.buttons["expansion-the-island"].exists)
        XCTAssertFalse(app.buttons["choose-dragontopia"].exists)
    }
    @MainActor func testAcquisitionAndCatalogSelection() throws {
        let app = XCUIApplication(); XCUIDevice.shared.orientation = .landscapeLeft; app.launch()
        func tapSidebar(_ id: String) {
            let button = app.buttons[id]
            for _ in 0..<10 { if button.isHittable { break }; app.collectionViews.firstMatch.swipeDown() }
            for _ in 0..<10 { if button.isHittable { break }; app.collectionViews.firstMatch.swipeUp() }
            XCTAssertTrue(button.isHittable, id); button.tap()
        }
        tapSidebar("choose-ragnarok"); tapSidebar("section-Khai thác")
        let search = app.searchFields.firstMatch
        XCTAssertTrue(search.waitForExistence(timeout: 5)); search.tap(); search.typeText("Chitin")
        XCTAssertTrue(app.otherElements["acquisition-ragnarok-Chitin"].exists)
        XCTAssertFalse(app.buttons["pin-farm-acquisition-rag-chitin"].exists)
        let shot = XCTAttachment(screenshot: XCUIScreen.main.screenshot()); shot.name = "Creature-acquisition-no-guessed-GPS"; shot.lifetime = .keepAlways; add(shot)
        tapSidebar("section-Map & DLC")
        app.buttons["expansion-the-island"].tap()
        let open = app.buttons["Chọn map"]
        for _ in 0..<12 { if open.isHittable { break }; app.scrollViews.firstMatch.swipeUp() }
        XCTAssertTrue(open.isHittable); open.tap()
        XCTAssertTrue(app.descendants(matching: .any)["ragnarokMapViewport"].firstMatch.waitForExistence(timeout: 8))
        XCTAssertEqual(app.descendants(matching: .any)["ragnarokMapViewport"].firstMatch.label, "Bản đồ The Island")
    }
    @MainActor func testResourcePopupsAndZoomAcrossMaps() throws {
        let app = XCUIApplication(); XCUIDevice.shared.orientation = .landscapeLeft; app.launch()
        app.buttons["map-group-Cốt truyện"].tap(); app.buttons["map-group-Khám phá"].tap()
        for map in ["ragnarok", "the-island", "the-center"] {
            let choose = app.buttons["choose-" + map]
            for _ in 0..<10 { if choose.isHittable { break }; app.collectionViews.firstMatch.swipeDown() }
            for _ in 0..<10 { if choose.isHittable { break }; app.collectionViews.firstMatch.swipeUp() }
            choose.tap()
            app.buttons["clearMapLayers"].tap(); app.buttons["layer-Resources"].tap()
            let rail = app.scrollViews["mapFilterRail"]
            let pins = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "pin-farm-"))
            XCTAssertTrue(pins.firstMatch.waitForExistence(timeout: 8))
            let visible = try XCTUnwrap(pins.allElementsBoundByIndex.first(where: { $0.isHittable }))
            visible.tap()
            if !app.staticTexts["selectedMapLocation"].exists {
                let name = visible.label.components(separatedBy: ", LAT").first ?? visible.label
                app.buttons[name].tap()
            }
            XCTAssertTrue(app.staticTexts["selectedMapLocation"].waitForExistence(timeout: 5))
            XCTAssertTrue(app.images["farmPhoto"].exists)
            XCTAssertTrue(app.links["farmVideo"].exists || app.buttons["farmVideo"].exists)
            let shot = XCTAttachment(screenshot: XCUIScreen.main.screenshot()); shot.name = "Verified-farm-" + map; shot.lifetime = .keepAlways; add(shot)
            app.buttons["Đóng vị trí"].tap()
            for _ in 0..<12 { if app.buttons["zoomIn"].isHittable { break }; rail.swipeUp() }
            app.buttons["zoomIn"].tap()
            let viewport = app.descendants(matching: .any)["ragnarokMapViewport"].firstMatch
            XCTAssertTrue(Double(viewport.value as? String ?? "0")! > 1)
        }
    }
    @MainActor func testMapRightRailFiltersAndResources() throws {
        let app = XCUIApplication(); XCUIDevice.shared.orientation = .landscapeLeft; app.launch()
        app.buttons["choose-ragnarok"].tap(); app.buttons["section-Bản đồ"].tap()
        let rail = app.scrollViews["mapFilterRail"]
        let viewport = app.descendants(matching: .any)["ragnarokMapViewport"].firstMatch
        XCTAssertTrue(rail.waitForExistence(timeout: 8))
        XCTAssertGreaterThan(rail.frame.minX, viewport.frame.midX)
        app.buttons["clearMapLayers"].tap()
        XCTAssertFalse(app.buttons["pin-obelisk-red"].exists)
        app.buttons["layer-Obelisk"].tap()
        XCTAssertTrue(app.buttons["pin-obelisk-red"].exists)
        XCTAssertFalse(app.buttons["pin-artifact-hunter"].exists)
        app.buttons["layer-Artifact"].tap()
        XCTAssertTrue(app.buttons["pin-artifact-hunter"].exists)
        app.buttons["layer-Resources"].tap()
        XCTAssertTrue(app.buttons["resource-Rich Metal"].exists)
        let filters = XCTAttachment(screenshot: XCUIScreen.main.screenshot()); filters.name = "Right-rail-resource-filters"; filters.lifetime = .keepAlways; add(filters)
        app.buttons["clearMapLayers"].tap()
        app.buttons["selectAllMapLayers"].tap()
        XCTAssertEqual(app.buttons["layer-Resources"].value as? String, "Hiện")
        XCTAssertTrue(app.buttons["pin-obelisk-red"].exists)
        app.buttons["clearMapLayers"].tap()
        app.buttons["layer-Cửa hang"].tap()
        XCTAssertTrue(app.buttons["pin-entrance-jungle-0"].exists)
        XCTAssertFalse(app.buttons["pin-obelisk-red"].exists)
        XCUIDevice.shared.orientation = .portrait
        XCTAssertTrue(app.buttons["layer-Cửa hang"].isHittable)
        let portrait = XCTAttachment(screenshot: XCUIScreen.main.screenshot()); portrait.name = "Portrait-cave-photo-pins"; portrait.lifetime = .keepAlways; add(portrait)
    }

    @MainActor func testVisualArmyCountsAndUnits() throws {
        let app = XCUIApplication(); XCUIDevice.shared.orientation = .landscapeLeft; app.launch()
        app.buttons["choose-ragnarok"].tap(); app.buttons["section-Boss"].tap()
        let army = app.buttons["army-nunatak"]
        for _ in 0..<8 { if army.isHittable { break }; app.swipeUp() }; army.tap()
        app.buttons["armyOptions"].tap(); app.buttons["Therizino + cake · tái dùng dòng breed"].tap()
        let unit = app.descendants(matching: .any)["unit-per-dino"].firstMatch
        for _ in 0..<8 { if unit.isHittable { break }; app.swipeUp() }
        XCTAssertTrue(unit.isHittable)
        XCTAssertEqual(unit.label, "Số lượng cho mỗi Dino")
        let shot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        shot.name = "Army-counts-per-dino"; shot.lifetime = .keepAlways; add(shot)
    }

    @MainActor func testNamedMapPopups() throws {
        let app = XCUIApplication(); XCUIDevice.shared.orientation = .landscapeLeft; app.launch()
        app.buttons["choose-ragnarok"].tap(); app.buttons["section-Bản đồ"].tap()
        app.buttons["pin-obelisk-red"].tap()
        XCTAssertTrue(app.staticTexts["selectedMapLocation"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["selectedMapLocation"].label, "Red Obelisk · triệu hồi Nunatak")
        XCTAssertTrue(app.otherElements["gps-35.03-85.69"].exists)
        let portal = XCTAttachment(screenshot: XCUIScreen.main.screenshot()); portal.name = "Named-red-obelisk-popup"; portal.lifetime = .keepAlways; add(portal)
        app.buttons["Đóng vị trí"].tap()
        app.buttons["findMapLocation"].tap()
        let choice = app.collectionViews.buttons["Artifact of the Hunter"].firstMatch
        XCTAssertTrue(choice.waitForExistence(timeout: 5)); choice.tap()
        XCTAssertEqual(app.staticTexts["selectedMapLocation"].label, "Artifact of the Hunter")
        XCTAssertTrue(app.otherElements["gps-21.58-27.26"].exists)
        let artifact = XCTAttachment(screenshot: XCUIScreen.main.screenshot()); artifact.name = "Named-Hunter-popup"; artifact.lifetime = .keepAlways; add(artifact)
    }

    @MainActor func testCaveSinglePagePreparation() throws {
        let app = XCUIApplication(); XCUIDevice.shared.orientation = .landscapeLeft; app.launch()
        app.buttons["choose-ragnarok"].tap(); app.buttons["section-Artifact & Hang"].tap(); app.buttons["route-jungle"].tap()
        XCTAssertTrue(app.staticTexts["Hunter"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.otherElements["gps-21.58-27.26"].exists)
        XCTAssertFalse(app.buttons["artifact-hunter"].exists)
        XCTAssertFalse(app.buttons["Chi tiết"].exists)
        XCTAssertFalse(app.buttons["kit-quantity-simple-shotgun-ammo"].exists)
        XCTAssertFalse(app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "kit-check-")).firstMatch.exists)
        let gif = app.descendants(matching: .any)["cave-gif-jungle-01"].firstMatch
        for _ in 0..<6 { if gif.isHittable { break }; app.swipeUp() }
        XCTAssertTrue(gif.isHittable)
        let shot = XCTAttachment(screenshot: XCUIScreen.main.screenshot()); shot.name = "One-page-cave"; shot.lifetime = .keepAlways; add(shot)
    }

    @MainActor func testSidebarMapsAndHDLoop() throws {
        let app = XCUIApplication()
        XCUIDevice.shared.orientation = .landscapeLeft
        app.launch()
        XCTAssertTrue(app.buttons["section-Bản đồ"].waitForExistence(timeout: 8))
        XCTAssertFalse(app.buttons["section-Hôm nay"].exists)
        XCTAssertTrue(app.buttons["choose-the-center"].exists)
        app.buttons["choose-ragnarok"].tap()
        XCTAssertTrue(app.buttons["resetMap"].waitForExistence(timeout: 5))
        app.buttons["choose-the-island"].tap()
        XCTAssertEqual(app.buttons["choose-the-island"].value as? String, "Đang chọn")
        app.buttons["choose-ragnarok"].tap()
        app.buttons["section-Artifact & Hang"].tap(); app.buttons["route-jungle"].tap()
        let gif = app.descendants(matching: .any)["cave-gif-jungle-01"].firstMatch
        for _ in 0..<7 { if gif.isHittable { break }; app.swipeUp() }
        XCTAssertTrue(gif.isHittable)
        Thread.sleep(forTimeInterval: 2)
        let before = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        before.name = "HD-loop-before"; before.lifetime = .keepAlways; add(before)
        Thread.sleep(forTimeInterval: 3)
        let after = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        after.name = "HD-loop-after"; after.lifetime = .keepAlways; add(after)
        app.buttons["gif-card-jungle-02"].tap()
        XCTAssertEqual(app.buttons["gif-card-jungle-02"].value as? String, "Đang chọn")
        app.buttons["choose-the-center"].tap()
        XCTAssertTrue(app.buttons["resetMap"].waitForExistence(timeout: 5))
        XCTAssertFalse(gif.exists)
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
        XCTAssertFalse(app.buttons["Chi tiết"].firstMatch.exists)
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
        XCTAssertTrue(app.staticTexts["Hunter"].waitForExistence(timeout: 5))
        app.buttons["show-entrance-jungle-0"].tap()
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
        XCTAssertTrue(app.otherElements["gps-89.11-57.05"].waitForExistence(timeout: 5))
        let collected = app.switches["collected-hunter"]
        for _ in 0..<3 { if collected.isHittable { break }; app.swipeUp() }
        XCTAssertTrue(collected.isHittable)
        if collected.value as? String != "1" { collected.tap() }
        XCTAssertEqual(collected.value as? String, "1")

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
        XCTAssertTrue(app.otherElements["gps-19.99-49.81"].waitForExistence(timeout: 5))
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

        app.buttons["choose-the-island"].tap(); app.buttons["section-Thông tin map"].tap()
        XCTAssertEqual(app.staticTexts["mapInformationTitle"].label, "The Island")
        // Verify map progress after a real process restart.
        app.terminate(); app.launch()
        app.buttons["choose-the-island"].tap(); app.buttons["section-Thông tin map"].tap()
        app.buttons["section-Boss"].tap()
        app.buttons["boss-broodmother"].tap()
        let hunter = app.buttons["boss-artifact-hunter"]
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
        XCTAssertTrue(app.otherElements["gps-39.80-44.80"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.links["baseVideo"].exists || app.buttons["baseVideo"].exists)
        app.buttons["show-base-canyon"].tap()
        XCTAssertTrue(app.scrollViews["ragnarokMapViewport"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["pin-base-canyon"].isHittable)
        XCTAssertEqual(app.staticTexts["selectedMapLocation"].label, "Canyon Plateaus")
        let mapShot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        mapShot.name = "Base-focused-map"; mapShot.lifetime = .keepAlways; add(mapShot)
        app.buttons["mapBaseProfile"].tap()
        XCTAssertTrue(app.buttons["show-base-canyon"].waitForExistence(timeout: 5))
        app.buttons["choose-the-island"].tap(); app.buttons["section-Thông tin map"].tap()
        XCTAssertFalse(app.buttons["section-Base Location"].exists)
        app.buttons["section-Boss"].tap()
        XCTAssertTrue(app.staticTexts["boss-step-monkey"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["boss-nunatak"].exists)
        let mega = app.buttons["army-broodmother"]
        for _ in 0..<4 { if mega.isHittable { break }; app.swipeUp() }
        XCTAssertTrue(mega.isHittable); mega.tap()
        XCTAssertTrue(app.staticTexts["armyOptionTitle"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["armyOptionTitle"].label.contains("Megatherium"))
        app.buttons["choose-the-center"].tap(); app.buttons["section-Thông tin map"].tap()
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

        app.buttons["choose-the-island"].tap(); app.buttons["section-Thông tin map"].tap()
        app.buttons["section-Artifact & Hang"].tap()
        app.buttons["route-central"].tap()
        let islandVideo = app.buttons["full-cave-video-central"]
        for _ in 0..<6 { if islandVideo.isHittable { break }; app.swipeUp() }
        XCTAssertTrue(islandVideo.isHittable); islandVideo.tap()
        XCTAssertTrue(app.buttons["cave-video-central-196"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["cave-video-jungle-134"].exists)

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
        XCTAssertFalse(app.buttons["gif-previous-central"].exists)
        Thread.sleep(forTimeInterval: 2)
        let first = clip.screenshot().pngRepresentation
        Thread.sleep(forTimeInterval: 1.5)
        XCTAssertNotEqual(first, clip.screenshot().pngRepresentation, "GIF must animate without tapping")
        clip.swipeLeft()
        let second = app.descendants(matching: .any)["cave-gif-central-clever-02"].firstMatch
        expectation(for: NSPredicate(format: "value == %@", "Đang phát"), evaluatedWith: second)
        waitForExpectations(timeout: 5)
        XCTAssertEqual(second.value as? String, "Đang phát")
        XCTAssertTrue(app.staticTexts["cave-direction-clever-02"].exists)
        second.swipeRight()
        expectation(for: NSPredicate(format: "value == %@", "Đang phát"), evaluatedWith: clip)
        waitForExpectations(timeout: 5)
        let card = app.buttons["gif-card-central-clever-04"]
        for _ in 0..<4 { if card.isHittable { break }; app.swipeUp() }
        XCTAssertTrue(card.isHittable); card.tap()
        XCTAssertFalse(app.staticTexts["gif-position-central"].exists)
        XCTAssertEqual(card.value as? String, "Đang chọn")
        XCTAssertFalse(app.buttons["gif-next-central"].exists)
        let selected = app.descendants(matching: .any)["cave-gif-central-clever-04"].firstMatch
        Thread.sleep(forTimeInterval: 2)
        let selectedFrame = selected.screenshot().pngRepresentation
        Thread.sleep(forTimeInterval: 1.5)
        XCTAssertNotEqual(selectedFrame, selected.screenshot().pngRepresentation, "Selected card must autoplay its own GIF")
        let playing = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        playing.name = "Auto-GIF-card-library"; playing.lifetime = .keepAlways; add(playing)
        app.buttons["choose-ragnarok"].tap(); app.buttons["section-Thông tin map"].tap()
        app.buttons["section-Artifact & Hang"].tap(); app.buttons["route-jungle"].tap()
        let rag = app.descendants(matching: .any).matching(NSPredicate(format: "identifier BEGINSWITH %@", "cave-gif-jungle-")).firstMatch
        reveal(rag)
        XCTAssertTrue(rag.isHittable)
        XCTAssertEqual(rag.value as? String, "Đang phát")
        XCTAssertFalse(clip.exists)
        app.buttons["choose-the-center"].tap(); app.buttons["section-Thông tin map"].tap()
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
        XCTAssertTrue(app.descendants(matching: .any)["cave-gif-carnivorous-cunning-01"].firstMatch.exists)
        selector.tap()
        let immune = app.buttons["gif-section-option-immune"]
        XCTAssertTrue(immune.waitForExistence(timeout: 5)); immune.tap()
        XCTAssertFalse(app.staticTexts["gif-position-carnivorous"].exists)
        let card = app.buttons["gif-card-carnivorous-immune-10"]
        for _ in 0..<4 { if app.buttons["gif-card-carnivorous-immune-01"].isHittable { break }; app.swipeUp() }
        let firstCard = app.buttons["gif-card-carnivorous-immune-01"]
        XCTAssertTrue(firstCard.isHittable)
        XCTAssertGreaterThan(firstCard.frame.width, firstCard.frame.height)
        // Browse the horizontal library without changing the active step until a card is tapped.
        let origin = app.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        let libraryY = firstCard.frame.midY, libraryLeft = firstCard.frame.minX + 15
        for _ in 0..<5 {
            if card.isHittable { break }
            origin.withOffset(CGVector(dx: app.frame.maxX - 100, dy: libraryY)).press(forDuration: 0.1,
                thenDragTo: origin.withOffset(CGVector(dx: libraryLeft, dy: libraryY)))
        }
        XCTAssertTrue(card.isHittable)
        XCTAssertFalse(app.staticTexts["gif-position-carnivorous"].exists)
        card.tap()
        XCTAssertTrue(app.descendants(matching: .any)["cave-gif-carnivorous-immune-10"].firstMatch.exists)
        XCTAssertEqual(card.value as? String, "Đang chọn")

    }

}
