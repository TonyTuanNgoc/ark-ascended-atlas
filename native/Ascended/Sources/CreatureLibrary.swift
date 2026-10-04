import SwiftUI
import UIKit

struct CreatureLibrary: View {
    @Environment(\.arkMap) private var map
    @State private var search = ""
    @State private var filter = "All"
    private let filters = ["All", "Land", "Flying", "Aquatic", "Alpha", "DLC"]
    var body: some View {
        Group {
            switch map.creatures {
            case .failure:
                ContentUnavailableView("Unable to open library", systemImage: "book.closed", description: Text("Close and reopen Ascended."))
            case .success(let catalog):
                let items = catalog.creatures.filter { d in
                    (filter == "All" || (filter == "DLC" ? !d.dlc.isEmpty : d.group == filter)) &&
                    (search.isEmpty || ([d.name] + d.aliases).contains { $0.localizedStandardContains(search) })
                }
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack(alignment: .firstTextBaseline) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Dinosaurs & creatures").font(.largeTitle.bold())
                                Text(map.name).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text("\(items.count)").font(.largeTitle.bold()).foregroundStyle(.cyan)
                        }
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(filters, id: \.self) { item in
                                    Button(item) { filter = item }
                                        .buttonStyle(.bordered).tint(filter == item ? .cyan : .gray)
                                        .accessibilityIdentifier("filter-" + (["All": "Tất cả", "Land": "Trên cạn", "Flying": "Bay", "Aquatic": "Dưới nước"][item] ?? item))
                                }
                            }
                        }
                        if items.isEmpty {
                            ContentUnavailableView.search(text: search)
                        } else {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 240), spacing: 16)], spacing: 16) {
                                ForEach(items) { dino in
                                    NavigationLink { CreatureDetail(creature: dino) } label: {
                                        CreatureCard(creature: dino)
                                    }.buttonStyle(.plain).accessibilityIdentifier("creature-" + dino.id)
                                }
                            }
                        }
                    }.padding(24)
                }
                .searchable(text: $search, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search creatures on " + map.name)
                .accessibilityIdentifier("creatureLibrary")
            }
        }.background(Color(red: 0.025, green: 0.045, blue: 0.065))
    }
}

struct CreaturePortrait: View {
    let creature: Creature
    var body: some View {
        CreatureAvatar(asset: creature.iconAsset)
    }
}
struct CreatureCard: View {
    let creature: Creature
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                CreaturePortrait(creature: creature).frame(width: 76, height: 76)
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(.secondary)
            }
            Text(creature.name).font(.headline).foregroundStyle(.primary).lineLimit(2)
            HStack {
                Text(creature.group).font(.caption).foregroundStyle(.secondary)
                Spacer()
                if !creature.dlc.isEmpty { Text("DLC").font(.caption.bold()).foregroundStyle(.orange) }
            }
        }.padding(14).frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.055), in: RoundedRectangle(cornerRadius: 8))
    }
}

struct CreatureDetail: View {
    @Environment(\.arkMap) private var map
    let creature: Creature
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                HStack(spacing: 22) {
                    CreaturePortrait(creature: creature).frame(width: 120, height: 120)
                    VStack(alignment: .leading, spacing: 8) {
                        Text(creature.name).font(.largeTitle.bold())
                        Text(map.name + " · " + creature.group).foregroundStyle(.secondary)
                        if !creature.dlc.isEmpty { Label(creature.dlc, systemImage: "lock.open.fill").font(.subheadline).foregroundStyle(.orange) }
                    }
                }
                if !creature.updateNote.isEmpty {
                    section("Recent updates", text: creature.updateNote)
                }
                if creature.detailAvailable {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Taming").font(.title2.bold())
                        if !creature.diet.isEmpty { row("Diet", creature.diet) }
                        if let tameable = creature.tameable { row("Directly tameable", tameable ? "Yes" : "No") }
                        if creature.tameable == true {
                            if !creature.method.isEmpty && creature.method != "X" { row("Method", translatedMethod(creature.method)) }
                            if !creature.foods.isEmpty { FactGrid(matches: VisualFacts.items(creature.foods)) }
                        }
                    }.cardStyle()
                    if !creature.stats.isEmpty {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Base stats").font(.title2.bold())
                            ForEach(creature.stats, id: \.label) { stat in
                                row(stat.label, stat.value.formatted(.number.precision(.fractionLength(0...2))))
                            }
                        }.cardStyle()
                    }
                    if !creature.drops.isEmpty { itemSection("Loot", items: creature.drops) }
                    if !creature.immobilizedBy.isEmpty { itemSection("Immobilization", items: creature.immobilizedBy) }
                } else {
                    section("Listed on " + map.name, text: "Taming details are being added.")
                }
            }.padding(24).frame(maxWidth: 1000).frame(maxWidth: .infinity)
        }.navigationTitle(creature.name).navigationBarTitleDisplayMode(.inline)
            .background(Color(red: 0.025, green: 0.045, blue: 0.065))
    }
    private func translatedMethod(_ value: String) -> String {
        switch value { case "Knockout": "Knockout"; case "Passive": "Passive taming"; case "Special": "Special method"; default: value }
    }
    private func itemSection(_ title: String, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) { Text(title).font(.title2.bold()); FactGrid(matches: VisualFacts.items(items)) }.cardStyle()
    }
    private func row(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(label, systemImage: VisualFacts.symbol(for: label)).labelStyle(.iconOnly).accessibilityLabel(label).foregroundStyle(.cyan)
            if VisualFacts.matches(value).isEmpty { Text(value).textSelection(.enabled) }
            else { FactGrid(matches: VisualFacts.matches(value)) }
        }
    }
    private func section(_ title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.title2.bold()); VisualBrief(text: text)
        }.frame(maxWidth: .infinity, alignment: .leading).cardStyle()
    }
}

extension View {
    func cardStyle() -> some View {
        self.padding(22).frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.055), in: RoundedRectangle(cornerRadius: 8))
    }
}

/// Species dossier silhouettes remain white in every creature context.
struct CreatureSilhouetteAliases: Decodable {
    let aliases: [String:String]
    static let shared = (try? ArkMap.load(CreatureSilhouetteAliases.self, name: "creature-silhouette-aliases")) ?? CreatureSilhouetteAliases(aliases: [:])
}
struct CreatureAvatar: View {
    let asset: String
    private var silhouette: UIImage? {
        if let image = UIImage(named: asset) { return image }
        if let name = CreatureSilhouetteAliases.shared.aliases[asset.replacingOccurrences(of: "Dino-", with: "")], let image = UIImage(named: name) { return image }
        let parts = asset.replacingOccurrences(of: "Dino-", with: "").split(separator: "-").map(String.init)
        let variants: Set<String> = ["aberrant", "alpha", "corrupted", "tek", "x", "r", "spirit", "brute", "skeletal", "zombie", "malfunctioned", "polar", "summoned"]
        let base = parts.filter { !variants.contains($0) }.joined(separator: "-")
        return UIImage(named: "Dino-" + base)
    }
    var body: some View {
        if let image = silhouette { Image(uiImage: image).renderingMode(.template).resizable().scaledToFit().foregroundStyle(.white) }
        else { Image(systemName: "pawprint.fill").resizable().scaledToFit().foregroundStyle(.white).padding(18) }
    }
}
struct CreatureCutout: View {
    let asset: String
    var body: some View { CreatureAvatar(asset: asset) }
}

struct SquareGuideTile<Preview: View>: View {
    let title: String
    let subtitle: String
    let gps: String
    @ViewBuilder let preview: () -> Preview
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 10) {
                preview().frame(height: geometry.size.height * 0.52).clipped().clipShape(RoundedRectangle(cornerRadius: 6))
                Text(title).font(.headline).foregroundStyle(.primary).lineLimit(2).fixedSize(horizontal: false, vertical: true)
                Text(subtitle).font(.caption).foregroundStyle(.cyan).lineLimit(2)
                Spacer(minLength: 0)
                GPSBadge(coordinates: gps).font(.caption).scaleEffect(0.9, anchor: .leading)
            }.padding(12).frame(width: geometry.size.width, height: geometry.size.height, alignment: .topLeading)
                .background(.white.opacity(0.055), in: RoundedRectangle(cornerRadius: 8))
        }.aspectRatio(1, contentMode: .fit).clipped().contentShape(Rectangle())
            .accessibilityElement(children: .ignore).accessibilityLabel(title + ". " + subtitle + ". " + gps)
    }
}
