import XCTest
import UIKit
@testable import Ascended
final class MapFieldTests:XCTestCase {
    func testSemanticRelationshipsRemainText() {
        XCTAssertFalse(VisualFacts.isInventory("SCUBA / Lazarus Chowder"))
        XCTAssertFalse(VisualFacts.isInventory("SCUBA or Lazarus Chowder"))
        XCTAssertFalse(VisualFacts.isInventory("Dragon: Metal"))
        XCTAssertFalse(VisualFacts.isInventory("Water is essential before entering the desert."))
    }
    func testAtlasProjectionAndInvalidTouches() {
        for size in [CGSize(width:8192,height:8192),CGSize(width:2048,height:2048),CGSize(width:800,height:600)] {
            for gps in [MapGPS(lat:0,lon:0),MapGPS(lat:100,lon:100),MapGPS(lat:21.58,lon:27.26),MapGPS(lat:50,lon:50)] {
                let p=MapCoordinateTransform.pixel(lat:gps.lat,lon:gps.lon,size:size)
                let found=MapCoordinateTransform.gps(at:p,size:size)!
                XCTAssertEqual(found.lat,gps.lat,accuracy:0.000001);XCTAssertEqual(found.lon,gps.lon,accuracy:0.000001)
            }
            XCTAssertNil(MapCoordinateTransform.gps(at:CGPoint(x:-1,y:0),size:size))
            XCTAssertNil(MapCoordinateTransform.gps(at:CGPoint(x:0,y:size.height+1),size:size))
        }
        XCTAssertNil(MapCoordinateTransform.gps(at:.zero,size:.zero))
        XCTAssertNil(MapCoordinateTransform.gps(at:CGPoint(x:CGFloat.nan,y:0),size:CGSize(width:10,height:10)))
    }
    @MainActor func testUIKitImageCoordinateSurvivesZoomAndPan() {
        let scroll=UIScrollView(frame:CGRect(x:0,y:0,width:500,height:400));let image=UIView(frame:CGRect(x:0,y:0,width:2048,height:2048));scroll.addSubview(image);scroll.contentSize=image.bounds.size
        image.transform=CGAffineTransform(scaleX:0.75,y:0.75);scroll.contentOffset=CGPoint(x:100,y:200)
        let local=MapCoordinateTransform.pixel(lat:33.6,lon:62,size:image.bounds.size)
        let touch=image.convert(local,to:scroll);let recovered=image.convert(touch,from:scroll)
        let gps=MapCoordinateTransform.gps(at:recovered,size:image.bounds.size)!
        XCTAssertEqual(gps.lat,33.6,accuracy:0.000001);XCTAssertEqual(gps.lon,62,accuracy:0.000001)
    }
    func testParentPartialAndResourceIntersection() {
        let a=MapLocation(id:"a",name:"a",lat:10,lon:10,layer:.artifact,note:"",routeID:nil,artifactID:nil)
        let b=MapLocation(id:"b",name:"b",lat:20,lon:20,layer:.artifact,note:"",routeID:nil,artifactID:nil)
        let farm=MapLocation(id:"f",name:"f",lat:30,lon:30,layer:.resource,note:"",routeID:nil,artifactID:nil,resourceNames:["Metal","Crystal"])
        let points=[a,b,farm];var s=MapFilterSelection();XCTAssertFalse(points.contains(where:s.includes))
        s.togglePoint("a");XCTAssertEqual(s.selectedCount(.artifact,points:points,types:[]),1)
        s.toggle(.artifact,points:points,types:[]);XCTAssertTrue(s.includes(a));XCTAssertTrue(s.includes(b))
        s.toggle(.artifact,points:points,types:[]);XCTAssertFalse(s.includes(a));XCTAssertFalse(s.includes(b))
        s.toggleResource("Metal");XCTAssertTrue(s.includes(farm));s.toggleResource("Metal");XCTAssertFalse(s.includes(farm))
        s.toggle(.resource,points:points,types:["Metal","Crystal"]);XCTAssertEqual(s.resources.count,2)
        s.toggle(.resource,points:points,types:["Metal","Crystal"]);XCTAssertTrue(s.resources.isEmpty)
    }
    func testPersonalLocationsRoundTripAndInvalidRecords() {
        let a=PersonalMapLocation(map:ArkMap.island.rawValue,name:"Main base",lat:25.2,lon:63.8)
        let b=PersonalMapLocation(map:ArkMap.center.rawValue,name:"Forge",symbol:"hammer.fill",color:"orange",lat:30,lon:40)
        let invalid=PersonalMapLocation(map:"wrong-map",name:"",lat:Double.nan,lon:200)
        XCTAssertEqual(PersonalMapLocation.decode(PersonalMapLocation.encode([a,b])),[a,b]);XCTAssertFalse(invalid.valid)
        XCTAssertTrue(PersonalMapLocation.decode("bad json").isEmpty)
        XCTAssertEqual([a,b].filter {$0.map==ArkMap.island.rawValue},[a])
    }
    func testFarmingRosterAndResourceSpecificPins() {
        for map in ArkMap.allCases {
            let names = FarmingResourceCatalogue.names(in: map)
            XCTAssertFalse(names.isEmpty, map.rawValue)
            XCTAssertTrue(Set(names).isDisjoint(with: FarmingResourceCatalogue.excluded), map.rawValue)
            for resource in names {
                let spots = FarmingResourceCatalogue.spots(for: resource, in: map)
                XCTAssertTrue(spots.allSatisfy { $0.map == map.rawValue && $0.verified && $0.resources.compactMap(FarmingResourceCatalogue.canonical).contains(resource) })
            }
        }
        XCTAssertTrue(FarmingResourceCatalogue.names(in: .island).contains("Raw Meat"))
        XCTAssertTrue(FarmingResourceCatalogue.names(in: .island).contains("Hide"))
        XCTAssertTrue(FarmingResourceCatalogue.names(in: .aberration).contains("Green Gem"))
        XCTAssertFalse(FarmingResourceCatalogue.names(in: .island).contains("Cactus Sap"))
        let iconRows = try! ArkMap.load(FarmIconTestRows.self, name: "farming-resource-icons")
        for map in ArkMap.allCases {
            for name in FarmingResourceCatalogue.names(in: map) {
                let asset = iconRows.assets[name]
                XCTAssertNotNil(asset, map.rawValue + ":" + name)
                XCTAssertNotNil(asset.flatMap(UIImage.init(named:)), name)
            }
        }
        let extinction = FarmingResourceCatalogue.shared.maps.first { $0.map == ArkMap.extinction.rawValue }!
        XCTAssertTrue(extinction.resources.first { $0.name == "Congealed Gas Ball" }!.method.contains("Gacha"))
        XCTAssertEqual(extinction.resources.first { $0.name == "Congealed Gas Ball" }!.availability, "production")
        XCTAssertEqual(extinction.resources.first { $0.name == "Blue Crystalized Sap" }!.availability, "gatherable")
    }
    func testVerifiedResourceMediaAndMapCoverage() {
        let spots=ResourceFarmCatalog.shared.spots.filter(\.verified);let guides=ResourceClipCatalog.shared.guides
        XCTAssertEqual(Set(spots.map(\.id)).count,spots.count)
        for map in ArkMap.allCases {XCTAssertFalse(spots.filter {$0.map==map.rawValue}.isEmpty,map.rawValue)}
        for spot in spots {
            XCTAssertTrue((0...100).contains(spot.lat));XCTAssertTrue((0...100).contains(spot.lon))
            XCTAssertNotNil(UIImage(named:spot.imageAsset),spot.id)
            let guide=ResourceClipCatalog.guide(for:spot.id);XCTAssertNotNil(guide,spot.id)
            XCTAssertEqual(guide?.steps.count,1);XCTAssertEqual(Set(guide?.steps.map(\.loop) ?? []).count,1)
            for step in guide?.steps ?? [] {XCTAssertEqual(step.mapOverlayVisible, false, step.id);XCTAssertFalse(step.title.localizedCaseInsensitiveContains("coordinates"), step.id);XCTAssertNotNil(step.url,step.id);XCTAssertNotNil(step.caveStep.posterImage,step.id);XCTAssertGreaterThan(step.endSeconds,step.startSeconds);XCTAssertLessThanOrEqual(step.endSeconds-step.startSeconds,10.001);XCTAssertTrue(step.sourceURL.hasPrefix("https://www.youtube.com/watch?v="))}
        }
        XCTAssertEqual(spots.count,guides.count)
        let coverage = ResourceFarmCatalog.shared.coverage ?? []
        for map in ArkMap.allCases { XCTAssertFalse(coverage.filter { $0.map == map.rawValue }.isEmpty, "Missing acquisition coverage: " + map.rawValue) }
    }
    func testSharedFarmRegionSelectsMediaForEachResource() throws {
        let guide = try XCTUnwrap(ResourceClipCatalog.guide(for: "rag-cave-metal-obsidian"))
        XCTAssertEqual(guide.step(for: "Black Pearls")?.loop, "Resource-rag-cave-metal-obsidian-black-pearls-1")
        XCTAssertEqual(guide.step(for: "Metal")?.loop, "Resource-rag-cave-metal-obsidian-metal-1")
        XCTAssertEqual(guide.step(for: "Obsidian")?.loop, "Resource-rag-cave-metal-obsidian-1")
        XCTAssertEqual(guide.step(for: nil)?.loop, guide.steps.first?.loop)
        for (resource, step) in guide.resourceSteps ?? [:] {
            XCTAssertNotNil(step.url, resource)
            XCTAssertNotNil(step.caveStep.posterImage, resource)
            XCTAssertEqual(step.mapOverlayVisible, false)
        }
    }
    func testCaveEntranceAnchorIsNotPresentedAsAnInteriorCoordinate() throws {
        let spot = try XCTUnwrap(ResourceFarmCatalog.shared.spots.first { $0.id == "valguero-lava-cave-chitin-342-514" })
        XCTAssertEqual(spot.coordinateHint, "Cave entrance · follow the filmed route inside")
        let interior = try XCTUnwrap(ResourceFarmCatalog.shared.spots.first { $0.id == "island-cave-black-pearls" })
        XCTAssertEqual(interior.coordinateHint, "Cave chamber · not the entrance")
    }
}

private struct FarmIconTestRows: Decodable { let assets: [String: String] }
