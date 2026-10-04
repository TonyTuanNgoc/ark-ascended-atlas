import SwiftUI

struct RagnarokBoss: Identifiable {
    let id: String
    let name: String
    let kind: String
    let encounter: String
    let location: String
    let summary: String
    let danger: String
    let rewards: String
    let source: String
    static let all: [RagnarokBoss] = [
        .init(id: "nunatak", name: "Nunatak", kind: "Main boss", encounter: "Nunatak Arena", location: "Summon at an Obelisk or Supply Crate; the arena is in an icy region.", summary: "The guardian of Ragnarok Ascended is a giant Ice Wyvern with Gamma, Beta and Alpha tiers. It replaces the Dragon + Manticore encounter from Ragnarok Evolved.", danger: "Ice attacks, tail projectiles and summoned Iceworms. Manage your formation as the boss alternates between flight and landing.", rewards: "Tek progression; the launch announcement mentions Tek Sword, Tek Shield and Tek Light. Exact rewards depend on the encounter tier.", source: "https://ark.wiki.gg/wiki/Nunatak"),
        .init(id: "iceworm-queen", name: "Iceworm Queen", kind: "Mini-boss", encounter: "Frozen Dungeon", location: "Ice Queen Labyrinth, reached through Frozen Dungeon.", summary: "The Iceworm Queen waits at the end of the ice cave route. This is a dungeon encounter, rather than a Gamma/Beta/Alpha tier of Nunatak.", danger: "Emerges from underground and hits hard at close range; scout the descent into the arena first.", rewards: "Creature trophies and loot; dungeon rewards are tracked separately from main-boss rewards.", source: "https://ark.wiki.gg/wiki/Iceworm_Queen"),
        .init(id: "lava-elemental", name: "Lava Elemental", kind: "Mini-boss", encounter: "Jungle Dungeon", location: "Lava Elemental Arena at the end of Jungle Dungeon.", summary: "A lava golem guards the final encounter in the jungle dungeon.", danger: "Thrown lava rocks, lava pools and gaps between ledges. Scout movement routes and firing positions first.", rewards: "Resources and dungeon loot. These are separate from Nunatak Tekgram rewards.", source: "https://ark.wiki.gg/wiki/Lava_Elemental"),
        .init(id: "spirit-dire-bear", name: "Spirit Dire Bear", kind: "Mini-boss", encounter: "Life’s Labyrinth", location: "The final area of Life’s Labyrinth, in the same encounter group as Spirit Direwolf.", summary: "A spirit bear guards the artifacts at the end of the labyrinth. Together with Spirit Direwolf, it forms one dungeon encounter group, rather than two separate dungeons.", danger: "Enemy waves grow stronger. Prepare an escape route and supplies for consecutive fights.", rewards: "The main goal of this route is the artifacts guarded at the end of the labyrinth.", source: "https://ark.wiki.gg/wiki/Spirit_Direwolf_%26_Spirit_Dire_Bear"),
        .init(id: "spirit-direwolf", name: "Spirit Direwolf", kind: "Mini-boss", encounter: "Life’s Labyrinth", location: "The final area of Life’s Labyrinth, in the same encounter group as Spirit Dire Bear.", summary: "A spirit wolf on the Life’s Labyrinth artifact route.", danger: "Increasing combat pressure across multiple waves; distinguish this enemy from ordinary tameable Direwolves.", rewards: "Artifacts from the labyrinth route. This is not a main boss with Gamma/Beta/Alpha tiers.", source: "https://ark.wiki.gg/wiki/Spirit_Direwolf_%26_Spirit_Dire_Bear")
    ]
}

struct BossLibrary: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Text("Ragnarok bosses").font(.largeTitle.bold())
                Text("1 main boss · 4 named mini-bosses · 3 dungeon encounter groups")
                    .font(.headline).foregroundStyle(.cyan)
                Text("Nunatak is the main boss. Iceworm Queen, Lava Elemental and the Spirit Bear + Spirit Wolf group are dungeon encounters. Wild Alpha variants are listed in the Creature Library.")
                    .foregroundStyle(.secondary)
                ForEach(RagnarokBoss.all) { boss in
                    NavigationLink(value: GuideDestination.boss(boss.id)) {
                        HStack(spacing: 18) {
                            CreatureCutout(asset: boss.id == "nunatak" ? "Nunatak-Gamma" : "Boss-" + boss.id).frame(width: 120, height: 80)
                            VStack(alignment: .leading, spacing: 6) {
                                Text(boss.name).font(.title3.bold()).foregroundStyle(.primary)
                                Text(boss.kind + " · " + boss.encounter).font(.subheadline).foregroundStyle(.secondary)
                            }
                            Spacer(); Image(systemName: "chevron.right").foregroundStyle(.secondary)
                        }.cardStyle()
                    }.buttonStyle(.plain).accessibilityIdentifier("boss-" + boss.id)
                }
            }.padding(24).frame(maxWidth: 1100).frame(maxWidth: .infinity)
        }.background(Color(red: 0.025, green: 0.045, blue: 0.065))
    }
}
struct BossDetail: View {
    let boss: RagnarokBoss
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Label(boss.kind, systemImage: "shield.lefthalf.filled").foregroundStyle(.cyan)
                Text(boss.name).font(.largeTitle.bold())
                CreatureCutout(asset: boss.id == "nunatak" ? "Nunatak-Gamma" : "Boss-" + boss.id).frame(height: boss.id == "nunatak" ? 280 : 160).frame(maxWidth: .infinity)
                NavigationLink(value: GuideDestination.army(boss.id)) { Label("Creature army, levels & preparation stats", systemImage: "pawprint.fill") }.accessibilityIdentifier("bossArmy")
                BossKnowledge(boss: boss)
                block("Overview", boss.summary)
                block("Where to find it", boss.location)
                block("Dangers to prepare for", boss.danger)
                block("Goals & rewards", boss.rewards)
            }.padding(24).frame(maxWidth: 1000).frame(maxWidth: .infinity)
        }.navigationTitle(boss.name).navigationBarTitleDisplayMode(.inline)
            .background(Color(red: 0.025, green: 0.045, blue: 0.065))
    }
    private func block(_ title: String, _ body: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.title2.bold()); VisualBrief(text: body)
        }.cardStyle()
    }
}
