import XCTest
@testable import Ascended
final class CommunityBuildTests:XCTestCase {
    func testGalleryCoverageAndPhaseIntegrity() {
        let builds=CommunityBuildLibrary.shared.builds
        XCTAssertEqual(builds.count,15)
        for zone in ["home","workshop","storage","garden","forge"] {XCTAssertEqual(builds.filter {$0.zone==zone}.count,3)}
        for b in builds {
            XCTAssertFalse(b.parts.isEmpty)
            XCTAssertEqual(Set(b.parts.map(\.id)).count,b.parts.count)
            XCTAssertTrue(b.parts.allSatisfy {(0...3).contains($0.phase) && $0.x.isFinite && $0.y.isFinite && $0.z.isFinite})
            XCTAssertTrue(b.requirements.allSatisfy {$0.count>0 && (0...3).contains($0.phase)})
            XCTAssertEqual(b.requirements.reduce(0) {$0+$1.count},b.parts.count,b.id)
            for phase in 0..<4 {XCTAssertEqual(b.parts.filter {$0.phase==phase}.count,b.requirements.filter {$0.phase==phase}.reduce(0) {$0+$1.count},b.id)}
            XCTAssertTrue(b.parts.contains {$0.phase==3})
            var independent:[String:Int]=[:]
            for r in b.requirements where r.verified {for (k,v) in r.ingredients {independent[k,default:0]+=v*r.count}}
            XCTAssertEqual(b.direct(through:3),independent)
            for i in 0..<3 {for (k,v) in b.direct(through:i) {XCTAssertGreaterThanOrEqual(b.direct(through:i+1)[k] ?? 0,v)}}
            for p in b.parts {if let id=p.modelID {XCTAssertTrue(StoneKit.shared.models.contains {$0.id==id})}}
        }
    }
    func testUnverifiedRecipeIsExcluded() {
        let r=CommunityRequirement(id:"missing",name:"Missing",count:9,asset:nil,ingredients:["Stone":100],stations:[],verified:false,phase:0,suggested:false)
        let b=CommunityBuild(id:"test",zone:"home",title:"Test",creator:"",sourceURL:"",videoURL:nil,parts:[],requirements:[r],skins:false,extent:1)
        XCTAssertEqual(b.direct(through:3),[:])
    }
}
