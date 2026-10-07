import XCTest
@testable import Ascended

final class EquipmentReferenceTests: XCTestCase {
    func testCompleteCatalogueAndCoreToolRecipes() throws {
        let all = EquipmentReferenceCatalogue.shared.items
        XCTAssertEqual(Set(all.map(\.id)), Set(EquipmentCatalogue.shared.items.map(\.id)))
        XCTAssertEqual(all.count, 728)
        let pick = try XCTUnwrap(EquipmentReferenceCatalogue.shared.item("metal-pick"))
        XCTAssertEqual(pick.ingredients, ["Metal Ingot": 1, "Wood": 1, "Hide": 10])
        let hatchet = try XCTUnwrap(EquipmentReferenceCatalogue.shared.item("metal-hatchet"))
        XCTAssertEqual(hatchet.ingredients, ["Metal Ingot": 8, "Wood": 1, "Hide": 10])
        XCTAssertTrue(pick.reviewedRecipe)
        XCTAssertEqual(BuildBill.expand(pick.ingredients).raw, ["Metal": 2, "Wood": 1, "Hide": 10])
        for row in all {
            XCTAssertTrue(row.ingredients.values.allSatisfy { $0 > 0 }, row.id)
            XCTAssertEqual(Set(row.stats.map(\.id)).count, row.stats.count, row.id)
        }
    }
    func testOutputAndAscendedEditionSafeguards() throws {
        let paste = try XCTUnwrap(EquipmentReferenceCatalogue.shared.item("cementing-paste"))
        XCTAssertEqual(paste.reviewedOutput, 1)
        XCTAssertEqual(EquipmentReferenceCatalogue.shared.item("sparkpowder")?.reviewedOutput, 2)
        let fridge = try XCTUnwrap(EquipmentReferenceCatalogue.shared.item("cryofridge"))
        XCTAssertEqual(fridge.ingredients, ["Crystal": 12, "Electronics": 7, "Metal Ingot": 115, "Polymer": 30])
        XCTAssertEqual(EquipmentReferenceCatalogue.shared.item("cryopod")?.ingredients.values.reduce(0, +), 40)
    }
    func testMeatGuidanceAndToolLookup() throws {
        let meat = try XCTUnwrap(HarvestingCatalogue.shared.resource("Raw Meat"))
        XCTAssertEqual(meat.tools.first?.name, "Metal Pick")
        XCTAssertTrue(meat.targets.contains { $0.contains("Phiomia") })
        XCTAssertTrue(HarvestingCatalogue.shared.uses("Metal Pick").contains { $0.resource == "Raw Meat" })
        let metal = try XCTUnwrap(HarvestingCatalogue.shared.resource("Rich Metal"))
        XCTAssertEqual(metal.weightReductions.first { $0.name == "Ankylosaurus" }?.percent, 85)
        for row in HarvestingCatalogue.shared.entries {
            XCTAssertFalse(row.summary.isEmpty)
            XCTAssertEqual(Set(row.tools.map(\.id)).count, row.tools.count)
            XCTAssertEqual(Set(row.creatures.map(\.id)).count, row.creatures.count)
            XCTAssertTrue(row.weightReductions.allSatisfy { (0...100).contains($0.percent) })
        }
    }
    func testIdentityCorrectionsAndBatchRounding() {
        XCTAssertEqual(BuildBill.ingredient("water-reservoir"), ["Stone": 30, "Cementing Paste or Achatina Paste": 5])
        XCTAssertNil(BuildBill.ingredient("bee-hive"))
        XCTAssertEqual(BuildBill.requirement("absorbent-substrate", count: 1), ["Black Pearl": 8, "Sap": 8, "Oil or Oil (Tusoteuthis)": 8])
        XCTAssertEqual(BuildBill.requirement("absorbent-substrate", count: 7), ["Black Pearl": 16, "Sap": 16, "Oil or Oil (Tusoteuthis)": 16])
        let pieces = (0..<6).map { _ in StonePlacement(kind: "absorbent-substrate", x: 0, z: 0, level: 0, turn: 0) }
        XCTAssertEqual(BuildBill.direct(pieces), BuildBill.requirement("absorbent-substrate", count: 1))
        XCTAssertEqual(BuildBill.expand(["Absorbent Substrate": 7]).raw, ["Black Pearl": 16, "Sap": 16, "Oil": 16])
    }
}
