import SwiftUI

struct BossKnowledge: View {
    let boss: RagnarokBoss
    var body: some View {
        if boss.id == "nunatak" { NunatakGuide() }
        else {
            let routeID = boss.id == "iceworm-queen" ? "frozen" : boss.id == "lava-elemental" ? "jungle" : "labyrinth"
            if let route = ArkMap.ragnarok.exploration?.routes.first(where: { $0.id == routeID }) {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Route to the boss").font(.title2.bold())
                    if boss.id == "lava-elemental" { GPSBadge(coordinates: "LAT 21.60 · LON 26.90"); Label("Arena", systemImage: "scope").font(.caption) }
                    else { VisualBrief(text: "Follow " + route.name + " to the final encounter group. The GPS below marks the entrance, rather than the exact boss position inside the arena.") }
                    ForEach(route.entrances) { entrance in HStack { Text(entrance.label); GPSBadge(coordinates: entrance.coordinates) } }
                    NavigationLink("Open cave & artifact guide", value: GuideDestination.cave(route.id))
                        .accessibilityIdentifier("bossCaveRoute")
                    NavigationLink("Show boss approach on map", value: GuideDestination.map(boss.id == "lava-elemental" ? "boss-lava-arena" : "entrance-" + (route.entrances.first?.id ?? "")))
                }.cardStyle()
                if boss.id == "iceworm-queen" {
                    info("Mechanics & reference stats", "The Queen appears when you descend to the arena at the bottom of the waterfall; descend without riding a tame. It cannot be tamed, ridden or bred and is immune to torpor. The Wiki lists 27,000 HP and 500 base melee at the minimum level of 10; actual values depend on level and settings and are not measurements of your Single Player save.")
                    info("Combat", "Keep your distance after the boss emerges: its hitbox is wide and the Ascended version is faster. Bring a good shotgun or ranged weapon, with a shield and healing supplies as backups. Solo players must manage both damage and dodging; a separate tank-and-shooter strategy requires a group.")
                    info("Harvesting & goals", "Continue to Pack in the nest area. Ascended has its own Iceworm Queen Trophy. The Wiki also lists Deathworm Horn, AnglerGel, Black Pearl, Leech Blood, Organic Polymer and corpse materials; the shared table includes Evolved entries, so not every listed skin or trophy is a confirmed ASA drop.")
                    GuideChecklist(title: "Iceworm Queen loadout", items: ["Quality Fur armor + Fria Curry / Otter", "Shotgun, ammunition and backup weapon", "Shield + Medical Brew", "Restore full health before descending the waterfall", "Scout the exit and route to Pack"], key: boss.id)
                } else if boss.id == "lava-elemental" {
                    info("Mechanics & reference stats", "An optional loot encounter. The Wiki lists 60,000 HP and 120 base melee at level 10; actual strength changes with level and settings. It cannot be tamed, ridden or bred and is immune to torpor. Hunter can be collected without winning this fight.")
                    info("Weapons & firing positions", "Prioritize Rocket Launchers and grapples to reach high positions, staying clear of edges. The Wiki reports heavy reductions to ordinary bullet and melee damage; a Tek Rifle is an option once its Tekgram is unlocked. Bring plenty of rockets and spare launchers, and avoid close-range self-damage.")
                    info("Attacks & weak points", "Thrown lava rocks, fire damage and melee can knock you into lava. Aim at the hands or arms and use elevated positions; terrain does not guarantee protection from attacks. Always keep an escape route away from lava.")
                    info("Loot", "Crystal, Metal, Obsidian, Oil, Stone and Sulfur, alongside equipment, saddles or blueprints. Loot quantity and quality depend on settings and version; Evolved quality ranges are not guarantees for ASA.")
                    GuideChecklist(title: "Lava Elemental loadout", items: ["Rockets + spare launchers", "Grappling Hook and grapples", "Armor, Medical Brew and repair supplies", "Identify firing ledges and lava escape routes", "Collect Hunter first if the artifact is your goal"], key: boss.id)
                } else {
                    info("Spirit encounter group", "Spirit Dire Bear and Spirit Direwolf belong to the same Life’s Labyrinth encounter. Pairs appear in waves from level 50, rising in increments of 50 up to 250. Ordinary Dire Bear and Direwolf stats do not represent these enemies’ HP.")
                    info("Triggering & completion", "This route has a sacrifice room and its own mechanics. At the final area, if spirits have not appeared, interact with the Megaloceros after completing the preceding mechanics. Defeating the spirits displays The spirits have calmed and opens the artifact route. Verify the mechanics in your world before sacrificing a valuable tame.")
                    info("Solo preparation", "Bring ranged weapons, spare armor and shields, Medical Brew, lighting and SCUBA. Scout traps and paths before combat; later waves apply more pressure. Do not rely on grapples or flyers to bypass the entire labyrinth: climbing and flying methods are restricted here.")
                    GuideChecklist(title: "Spirit encounter loadout", items: ["Shotgun, ammunition and backup weapon", "Armor/shield + healing supplies", "SCUBA and a light source", "Parachute for parkour", "Read the sacrifice room mechanics before entering"], key: "spirit-group")
                }
            }
        }
    }
    private func info(_ title: String, _ text: String) -> some View {
        VStack(alignment: .leading, spacing: 12) { Text(title).font(.title2.bold()); VisualBrief(text: text) }.cardStyle()
    }
}

struct NunatakGuide: View {
    @State private var difficulty = 0
    private let levels = ["Gamma", "Beta", "Alpha"]
    private let health = ["650.000", "950.000", "1.250.000"]
    private let elements = [100, 275, 550]
    private let tribute = ["Argentavis Talon", "Basilosaurus Blubber", "Megalania Toxin", "Megalodon Tooth", "Sarcosuchus Skin", "Sauropod Vertebra", "Spinosaurus Sail", "Thylacoleo Hook-Claw", "Titanoboa Venom", "Tusoteuthis Tentacle"]
    private let gammaTek = ["Tek Replicator", "Small Tek Teleporter", "Tek Behemoth Cellar Door", "Tek Behemoth Gate", "Tek Behemoth Gateway", "Tek Gauntlets", "Tek Generator", "Tek Leggings", "Tek Light", "Megalodon Tek Saddle", "Rex Tek Saddle", "Tapejara Tek Saddle", "Tek Trough"]
    private let betaAdds = ["Medium Tek Teleporter", "Tek Dedicated Storage", "Tek Doors & Windows", "Tek Fence Foundation & Support", "Tek Forcefield", "Tek Rifle", "Tek Roof, Ramp & Stairs", "Tek Sword", "Tek Transmitter", "Vacuum Compartment & Moonpool"]
    private let alphaAdds = ["Large Tek Teleporter", "Tek Chestpiece", "Tek Cloning Chamber", "Tek Grenade", "Tek Shield"]
    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Difficulty & rewards").font(.title2.bold())
                Picker("Difficulty", selection: $difficulty) { ForEach(0..<3) { index in Text(levels[index]).tag(index) } }.pickerStyle(.segmented).accessibilityIdentifier("bossDifficulty")
                Image("Nunatak-" + levels[difficulty]).resizable().scaledToFit().frame(maxHeight: 280).frame(maxWidth: .infinity)
                HStack(alignment: .top) {
                    fact("Base HP", health[difficulty]); Spacer(); fact("Entry level", String([70,80,90][difficulty])); Spacer(); fact("Element", String(elements[difficulty]))
                }
                VisualBrief(text: "Base HP before Single Player adjustments. Rewards also include a Nunatak Flag and the trophy for the selected tier. The boss cannot be tamed, ridden or bred and is immune to torpor.").font(.caption).foregroundStyle(.secondary)
            }.cardStyle()
            VStack(alignment: .leading, spacing: 14) {
                Text("Nunatak summoning locations").font(.title2.bold())
                VisualBrief(text: "Nunatak does not roam at a fixed overworld coordinate. Take tribute to an Obelisk and teleport into the arena. In Single Player, prioritize an Obelisk and check the portal in-game.")
                ForEach(ArkMap.ragnarok.exploration?.obelisks ?? []) { point in
                    NavigationLink(value: GuideDestination.map(point.id)) {
                        HStack { Text(point.label); Spacer(); GPSBadge(coordinates: point.coordinates).monospacedDigit().foregroundStyle(.cyan); Image(systemName: "map") }
                    }.accessibilityIdentifier("summon-" + point.id)
                }
            }.cardStyle()
            VStack(alignment: .leading, spacing: 14) {
                Text("Tribute · " + levels[difficulty]).font(.title2.bold())
                Text("10 artifacts below · each ×1").font(.headline).foregroundStyle(.cyan)
                ForEach(ArkMap.ragnarok.exploration?.artifacts ?? []) { artifact in
                    NavigationLink(value: GuideDestination.artifact(artifact.id)) {
                        HStack {
                            Image(artifact.imageAsset).resizable().scaledToFit().frame(width: 36, height: 36)
                            Text(artifact.name); Spacer(); Text("×1")
                        }.contentShape(Rectangle())
                    }.buttonStyle(.plain)
                }
                Text(difficulty == 0 ? "Gamma does not require the trophy materials below." : "Add the following materials, each ×" + String(difficulty == 1 ? 10 : 25)).font(.subheadline).foregroundStyle(.orange)
                if difficulty > 0 { ForEach(tribute, id: \.self) { item in VisualBrief(text: String(difficulty == 1 ? 10 : 25) + " " + item) } }
            }.cardStyle()
            VStack(alignment: .leading, spacing: 14) {
                Text("Tekgram · " + levels[difficulty]).font(.title2.bold())
                Text("Higher tiers include lower-tier unlocks.").font(.caption).foregroundStyle(.secondary)
                ForEach(gammaTek + (difficulty > 0 ? betaAdds : []) + (difficulty > 1 ? alphaAdds : []), id: \.self) { VisualBrief(text: $0) }
            }.cardStyle()
            VStack(alignment: .leading, spacing: 12) {
                Text("Combat flow").font(.title2.bold())
                VisualBrief(text: "During flight, use ranged weapons, handle Iceworm waves and maintain formation. After landing, focus damage; Nunatak does not summon Iceworms while grounded. Slowing ice breath and minions create heavy pressure; account for arena temperature in your loadout.")
                VisualBrief(text: "Rex and Therizino are common choices; Yutyrannus provides courage, while Daeodon healing requires enough food. Therizino can use Sweet Vegetable Cake. Prepare bred and imprinted creatures with good saddles; one HP or damage threshold does not fit every settings configuration.")
            }.cardStyle()
            VStack(alignment: .leading, spacing: 12) {
                Text("Arena limits & risks").font(.title2.bold())
                VisualBrief(text: "Flyers cannot enter the arena. Arena limits are 20 tames and 10 survivors; carts attached to tames may prevent teleportation. The in-game timer determines the limit for your save because Single Player and non-dedicated behavior differs. Death or timeout can cost creatures and gear; arrange your army inside the portal area before activating it.")
            }.cardStyle()
            GuideChecklist(title: "Before summoning", items: ["All 10 artifacts and the tribute for the selected tier", "Full HP and food for the entire army", "Check saddles, imprint and formation", "Shotgun + ammunition and spare cold-weather armor", "Medical Brew, food and water", "Enough food/cake for support creatures", "Check creature limits, remove carts and stand inside the portal", "Check the timer and your save settings"], key: "nunatak")
        }
    }
    private func fact(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            if title == "Element", let item = VisualFacts.matches("Element").first { FactPicture(fact: item.fact).frame(width: 40, height: 40) }
            else { Label(title, systemImage: VisualFacts.symbol(for: title)).labelStyle(.iconOnly).accessibilityLabel(title).foregroundStyle(.secondary) }
            Text(value).font(.title3.bold()).foregroundStyle(.cyan)
        }
    }
}
