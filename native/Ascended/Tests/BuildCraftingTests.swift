import XCTest
@testable import Ascended

final class BuildCraftingTests:XCTestCase {
    func testEightFoundations() {
        let p=(0..<8).map {StonePlacement(kind:"stone-foundation",x:Double($0),z:0,level:0,turn:0)}
        XCTAssertEqual(BuildBill.direct(p),["Stone":640,"Wood":320,"Thatch":240])
    }
    func testFabricatorProcessing() {
        let input=BuildBill.ingredient("fabricator")!
        XCTAssertEqual(input,["Metal Ingot":35,"Cementing Paste":20,"Sparkpowder":50,"Crystal":15,"Oil":10])
        let e=BuildBill.expand(input)
        XCTAssertEqual(e.raw,["Metal":70,"Chitin or Keratin":80,"Stone":185,"Flint":50,"Crystal":15,"Oil":10])
        XCTAssertEqual(e.steps.first {$0.name=="Sparkpowder"}?.batches,25)
    }
    func testChemistryBenchSharedIntermediates() {
        let e=BuildBill.expand(BuildBill.ingredient("chemistry-bench")!)
        XCTAssertEqual(e.raw,["Metal":1000,"Chitin or Keratin":3000,"Stone":6050,"Flint":100,"Crystal":250,"Obsidian":500,"Silica Pearls":750])
        XCTAssertEqual(e.steps.first {$0.name=="Cementing Paste"}?.batches,750)
    }
    func testCombineBeforeBatchRounding() {
        let e=BuildBill.expand(["Sparkpowder":1,"Gunpowder":1])
        XCTAssertEqual(e.raw,["Flint":2,"Stone":1,"Wood":1])
        XCTAssertEqual(e.steps.first {$0.name=="Sparkpowder"}?.batches,1)
        XCTAssertEqual(BuildBill.expand(["Gasoline":3]).raw,["Hide":5,"Oil":6])
    }
    func testTemplateRecipesAndUnverifiedExclusion() {
        for t in BuildTemplate.all {for p in t.pieces {XCTAssertNotNil(BuildBill.ingredient(p.kind),p.kind)}}
        XCTAssertNil(BuildBill.ingredient("stone-staircase"))
        XCTAssertEqual(BuildBill.ingredient("large-crop-plot"),["Wood":80,"Thatch":40,"Fiber":60,"Stone":100])
        XCTAssertEqual(BuildBill.ingredient("reinforced-wooden-door"),["Stone":20,"Wood":14,"Thatch":8])
        let wall=StoneKit.shared.models.first {$0.id=="greenhouse-wall"}!
        let ys=stride(from:1,to:wall.positions.count,by:3).map {wall.positions[$0]}
        XCTAssertEqual(ys.max()!,1,accuracy:0.01);XCTAssertEqual(ys.min()!,0,accuracy:0.01)
    }
    func testCatalogueIntegrity() {
        XCTAssertEqual(StoneKit.shared.models.count,378)
        XCTAssertEqual(BuildCraftCatalogue.shared.items.count,728)
        XCTAssertTrue(BuildCraftCatalogue.shared.items.filter {$0.recipeVerified}.allSatisfy {$0.ingredients.values.allSatisfy {$0>0}})
        XCTAssertTrue(BuildTemplate.all.allSatisfy {!$0.pieces.isEmpty})
        XCTAssertEqual(BuildTemplate.all[0].pieces.filter {$0.kind=="stone-foundation"}.count,8)
    }
}
