import XCTest
import UIKit
@testable import Ascended

final class Survival38Tests: XCTestCase {
    func testRouteIsIslandOnlyAndEveryIllustrationAndCitationResolves() throws {
        let guide = try XCTUnwrap(SurvivalGuide.load(for: .island))
        XCTAssertEqual(guide.phases.count, 8)
        XCTAssertGreaterThanOrEqual(guide.sources.filter { $0.kind == "Player experience" }.count, 5)
        let sourceIDs = Set(guide.sources.map(\.id))
        var keys = Set<String>()
        let roster = try ArkMap.island.creatures.get().creatures
        for phase in guide.phases {
            XCTAssertFalse(phase.required.isEmpty)
            XCTAssertEqual(phase.groups.count, 4)
            XCTAssertNotNil(UIImage(named: phase.asset), phase.asset)
            for goal in phase.goals {
                XCTAssertTrue(keys.insert(phase.key(goal)).inserted, phase.key(goal))
                XCTAssertNotNil(UIImage(named: goal.asset), goal.asset)
                for item in goal.contents {
                    XCTAssertFalse(item.name.isEmpty)
                    XCTAssertNotNil(UIImage(named: item.asset), item.asset)
                    if item.asset.hasPrefix("Dino-") { XCTAssertTrue(roster.contains { "Dino-" + $0.id == item.asset }, item.name) }
                }
                XCTAssertFalse(goal.sourceIDs.isEmpty)
                XCTAssertTrue(Set(goal.sourceIDs).isSubset(of: sourceIDs), goal.id)
                if goal.asset.hasPrefix("Dino-") { XCTAssertTrue(roster.contains { "Dino-" + $0.id == goal.asset }, goal.asset) }
            }
        }
        for map in ArkMap.allCases where map != .island { XCTAssertNil(SurvivalGuide.load(for: map)) }
    }
    func testExpandedOptionsHaveNamesAndPreserveExistingMilestones() throws {
        let guide = try XCTUnwrap(SurvivalGuide.load(for: .island))
        XCTAssertEqual(guide.phases.flatMap(\.goals).count, 106)
        XCTAssertEqual(guide.phases.flatMap(\.required).count, 74)
        XCTAssertEqual(guide.sources.count, 22)
        let shore = guide.phases[0]
        XCTAssertEqual(shore.goals.first { $0.id == "starter-tools" }?.contents.map(\.name), ["Stone Pick", "Stone Hatchet"])
        XCTAssertEqual(shore.goals.first { $0.id == "bed" }?.contents.map(\.name), ["Simple Bed"])
        XCTAssertEqual(shore.goals.first { $0.id == "starter" }?.contents.map(\.name), ["Moschops", "Parasaur"])
        XCTAssertTrue(guide.phases.first { $0.id == "army" }!.goals.contains { $0.id == "rex-option" && $0.optional })
        XCTAssertTrue(guide.phases.flatMap(\.goals).filter { $0.asset.hasPrefix("Dino-") }.allSatisfy { !$0.contents.isEmpty })
    }
    func testOptionalGoalsDoNotBlockProgressAndUncheckingReopensPhase() throws {
        let guide = try XCTUnwrap(SurvivalGuide.load(for: .island))
        let first = guide.phases[0]
        var done = Set(first.required.map { first.key($0) })
        XCTAssertTrue(first.isComplete(in: done))
        XCTAssertEqual(guide.nextPhase(in: done), 1)
        done = SurvivalProgress.toggled(first.key(first.required[0]), in: done)
        XCTAssertFalse(first.isComplete(in: done))
        XCTAssertEqual(guide.nextPhase(in: done), 0)
    }
    func testProgressRoundTripsWithoutCrossPhaseCollisionOrMalformedDataLoss() throws {
        let values: Set<String> = ["flight/argy", "guardians/hunter", "dragon/dragon-gamma"]
        XCTAssertEqual(SurvivalProgress.decode(SurvivalProgress.encode(values)), values)
        XCTAssertEqual(SurvivalProgress.decode("invalid"), [])
        XCTAssertEqual(SurvivalProgress.toggled("flight/argy", in: values), ["guardians/hunter", "dragon/dragon-gamma"])
    }
    func testGuardianSetsAndAscensionGateMatchIslandCatalogues() throws {
        let guide = try XCTUnwrap(SurvivalGuide.load(for: .island))
        let guardian = try XCTUnwrap(guide.phases.first { $0.id == "guardians" })
        let dragon = try XCTUnwrap(guide.phases.first { $0.id == "dragon" })
        XCTAssertEqual(Set(guardian.groups.first { $0.id == "equipment" }!.goals.filter { !$0.optional }.map(\.asset)), Set(["brute", "devourer", "pack", "hunter", "clever", "massive"].map { "Artifact-" + $0 }))
        XCTAssertEqual(Set(dragon.groups.first { $0.id == "equipment" }!.goals.filter { !$0.optional }.map(\.asset)), Set(["cunning", "immune", "skylord", "strong"].map { "Artifact-" + $0 }))
        let ascension = guide.phases.last!
        let trophies = try XCTUnwrap(ascension.goals.first { $0.id == "three-trophies" })
        XCTAssertEqual(trophies.quantity, "3")
        XCTAssertTrue(trophies.detail.contains("level 60"))
        XCTAssertTrue(dragon.note.contains("not fire immunity"))
        XCTAssertFalse(guide.phases.flatMap(\.goals).contains { $0.asset == "Dino-deinosuchus" })
    }
}
