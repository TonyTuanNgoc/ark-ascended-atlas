import SwiftUI

struct EquipmentReferenceCatalogue: Decodable {
    let items: [EquipmentReference]
    static let shared = (try? ArkMap.load(Self.self, name: "equipment-details")) ?? Self(items: [])
    func item(_ id: String) -> EquipmentReference? { items.first { $0.id == id } }
}
struct EquipmentReference: Decodable, Identifiable {
    let id, name, recipeStatus: String
    let ingredients: [String: Int]
    let stations: [String]
    let stats: [EquipmentStatistic]
    let output: Int?
    let outputStatus: String?
    let purpose: String?
    let stationStatus: String?
    let operationStatus: String?
    let acquisitionRequirements: [String: Int]?
    var reviewedRecipe: Bool { recipeStatus.hasPrefix("asa-cache-") || recipeStatus == "wiki-asa-explicit" }
    var knownOutput: Bool { ["existing-reviewed-standard-process", "primary-batch-reference"].contains(outputStatus ?? "") }
    var reviewedOutput: Int { knownOutput ? max(1, output ?? 1) : 1 }
}
struct EquipmentStatistic: Decodable, Identifiable {
    let key, label, value: String
    var id: String { key }
}
struct HarvestingCatalogue: Decodable {
    let entries: [HarvestingReference]
    static let shared = (try? ArkMap.load(Self.self, name: "harvesting-guide")) ?? Self(entries: [])
    func resource(_ name: String) -> HarvestingReference? {
        entries.first { $0.resource.caseInsensitiveCompare(name) == .orderedSame || $0.aliases.contains { $0.caseInsensitiveCompare(name) == .orderedSame } }
    }
    func uses(_ tool: String) -> [HarvestingReference] {
        entries.filter { $0.tools.contains { $0.name.caseInsensitiveCompare(tool) == .orderedSame } }
    }
}
struct HarvestingReference: Decodable, Identifiable {
    let resource, summary: String
    let aliases: [String]
    let tools, creatures: [HarvestingChoice]
    let targets, cautions: [String]
    let weightReductions: [HarvestingWeightReduction]
    var id: String { resource }
}
struct HarvestingWeightReduction: Decodable, Identifiable {
    let name: String
    let percent: Int
    var id: String { name }
}
struct HarvestingChoice: Decodable, Identifiable {
    let name, role: String
    var id: String { name }
}

struct EquipmentReferencePanel: View {
    let item: EquipmentItem
    let reference: EquipmentReference
    @State private var batches = 1
    private var ingredients: [String: Int] { reference.ingredients.mapValues { $0 * batches } }
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            if !reference.ingredients.isEmpty {
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Text(reference.reviewedRecipe ? "Crafting" : "Recipe reference").font(.title3.bold())
                        Spacer()
                        Stepper("×\(batches)", value: $batches, in: 1...1000).fixedSize().accessibilityIdentifier("equipment-craft-batches")
                    }
                    if reference.knownOutput {
                        Text("Produces \(batches * reference.reviewedOutput) · \(reference.stations.joined(separator: " · "))").font(.caption).foregroundStyle(.cyan)
                    } else {
                        Text(reference.stations.joined(separator: " · ")).font(.caption).foregroundStyle(.cyan)
                    }
                    ReferenceMaterials(amounts: ingredients)
                    if reference.stationStatus == "wiki-mixed-edition-station-review" {
                        Text("Confirm crafting location in your current ASA game.").font(.caption2).foregroundStyle(.secondary)
                    }
                    let expanded = BuildBill.expand(ingredients)
                    if !expanded.steps.isEmpty {
                        DisclosureGroup("Ingredient crafting") {
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(expanded.steps) { step in
                                    HStack {
                                        Text("\(step.name) ×\(step.batches * step.recipe.output)").font(.subheadline.bold())
                                        Spacer()
                                        Text(step.recipe.station).font(.caption).foregroundStyle(.cyan)
                                    }
                                    ReferenceMaterials(amounts: step.recipe.ingredients.mapValues { $0 * step.batches })
                                }
                                Text("Gather or obtain").font(.headline)
                                ReferenceMaterials(amounts: expanded.raw)
                            }.padding(.top, 10)
                        }.accessibilityIdentifier("equipment-ingredient-crafting")
                    }
                    Text(reference.reviewedRecipe ? (reference.recipeStatus == "asa-cache-wiki-difference" ? "Confirm the recipe in your game before bulk crafting. Blueprint quality and settings can change costs." : "Standard recipe. Blueprint quality and server overrides can change costs. Fuel and missing stations are separate.") : "Recipe reference; confirm edition and batch in your current ASA game before a bulk build.")
                        .font(.caption2).foregroundStyle(.secondary)
                }.padding(16).background(.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 16))
                    .accessibilityElement(children: .contain).accessibilityIdentifier("equipment-recipe")
            }
            if let requirements = reference.acquisitionRequirements, !requirements.isEmpty {
                Text("Obtain with").font(.title3.bold())
                ReferenceMaterials(amounts: requirements)
            }
            if !reference.stats.isEmpty {
                Text("At a glance").font(.title3.bold())
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), alignment: .leading)], alignment: .leading, spacing: 10) {
                    ForEach(reference.stats) { stat in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(stat.label).font(.caption).foregroundStyle(.secondary)
                            Text(stat.value).font(.subheadline.bold()).fixedSize(horizontal: false, vertical: true)
                        }.frame(maxWidth: .infinity, minHeight: 65, alignment: .leading).padding(12)
                            .background(.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 12))
                            .accessibilityElement(children: .combine).accessibilityIdentifier("equipment-stat-" + stat.key)
                    }
                }
                Text("Base reference values; quality, settings and edition can differ.").font(.caption2).foregroundStyle(.secondary)
            }
            if reference.operationStatus == "edition-conflict-review" {
                Text("Confirm power and fuel requirements in your current game.").font(.caption).foregroundStyle(.orange)
            }
        }
    }
}

struct ReferenceMaterials: View {
    let amounts: [String: Int]
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), alignment: .top)], alignment: .leading, spacing: 10) {
            ForEach(amounts.keys.sorted(), id: \.self) { name in
                VStack(spacing: 5) {
                    ReferencePicture(name: name).frame(height: 40)
                    Text("×\(amounts[name] ?? 0)").font(.headline).monospacedDigit().foregroundStyle(.cyan)
                    Text(name).font(.caption).multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
                }.frame(maxWidth: .infinity).padding(8).background(.white.opacity(0.035), in: RoundedRectangle(cornerRadius: 10))
                    .accessibilityElement(children: .combine).accessibilityIdentifier("ingredient-" + name)
            }
        }
    }
}
struct ReferencePicture: View {
    let name: String
    var body: some View {
        if let item = EquipmentCatalogue.find(name) {
            FactPicture(fact: item.fact)
        } else {
            FactPicture(fact: VisualFacts.items([name]).first!.fact)
        }
    }
}
struct HarvestingReferencePanel: View {
    let reference: HarvestingReference
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack { ReferencePicture(name: reference.resource).frame(width: 44, height: 44); Text("Gathering · " + reference.resource).font(.title3.bold()) }
            Text(reference.summary).font(.callout)
            if !reference.tools.isEmpty {
                Text("Tools").font(.headline)
                ForEach(reference.tools) { choice in
                    HStack(spacing: 12) {
                        ReferencePicture(name: choice.name).frame(width: 50, height: 45)
                        VStack(alignment: .leading, spacing: 4) { Text(choice.name).font(.subheadline.bold()); Text(choice.role).font(.caption).foregroundStyle(.secondary) }
                    }
                }
            }
            if !reference.creatures.isEmpty {
                Text("Creature options").font(.headline)
                ForEach(reference.creatures) { choice in
                    HStack(spacing: 12) {
                        FactPicture(fact: VisualFacts.items([choice.name]).first!.fact).frame(width: 50, height: 45)
                        VStack(alignment: .leading, spacing: 4) { Text(choice.name).font(.subheadline.bold()); Text(choice.role).font(.caption).foregroundStyle(.secondary) }
                    }
                }
            }
            if !reference.targets.isEmpty { Text("Look for").font(.headline); Text(reference.targets.joined(separator: " · ")).font(.callout) }
            if !reference.weightReductions.isEmpty {
                Text("Carry weight reduction").font(.headline)
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))], alignment: .leading, spacing: 10) {
                    ForEach(reference.weightReductions) { reduction in
                        VStack(spacing: 5) {
                            FactPicture(fact: VisualFacts.items([reduction.name]).first!.fact).frame(height: 36)
                            Text("−\(reduction.percent)%").font(.headline).foregroundStyle(.cyan)
                            Text(reduction.name).font(.caption)
                        }.frame(maxWidth: .infinity).padding(10).background(.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
            Text("Creature options may require another map, a transfer or DLC.").font(.caption2).foregroundStyle(.secondary)
            ForEach(reference.cautions, id: \.self) { Text($0).font(.caption).foregroundStyle(.secondary) }
        }.padding(16).background(.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 16))
            .accessibilityElement(children: .contain).accessibilityIdentifier("harvesting-" + reference.resource)
    }
}
