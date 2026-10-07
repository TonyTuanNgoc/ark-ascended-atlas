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
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(filters, id: \.self) { item in
                                    Button { filter = item } label: { Label(item, systemImage: Self.filterIcon(item)).font(.system(size: 15, weight: .semibold)) }
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
                .searchable(text: $search, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search dinosaurs & creatures")
                .accessibilityIdentifier("creatureLibrary")
            }
        }.background(Color(red: 0.025, green: 0.045, blue: 0.065))
    }
    static func filterIcon(_ name: String) -> String {
        switch name { case "Land": "pawprint.fill"; case "Flying": "bird.fill"; case "Aquatic": "fish.fill"; case "Alpha": "flame.fill"; case "DLC": "sparkles"; default: "square.grid.2x2.fill" }
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
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 18) {
                        CreaturePortrait(creature: creature).frame(width: 84, height: 84)
                        VStack(alignment: .leading, spacing: 7) {
                            Text(creature.name).font(.system(size: 28, weight: .bold, design: .rounded))
                            Label(creature.group, systemImage: CreatureLibrary.filterIcon(creature.group)).font(.subheadline).foregroundStyle(.secondary)
                            if !creature.dlc.isEmpty { Label(creature.dlc, systemImage: "sparkles").font(.caption).foregroundStyle(.orange) }
                        }
                    }
                    let columns = geometry.size.width > 750 ? 3 : 1
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), alignment: .top), count: columns), alignment: .leading, spacing: 14) {
                        if creature.detailAvailable {
                            panel("Taming", symbol: "hand.raised.fill") {
                                HStack(spacing: 8) {
                                    if !creature.diet.isEmpty { fact("Diet", value: creature.diet, icon: creature.diet.contains("Herbivore") ? "leaf.fill" : creature.diet.contains("Carnivore") ? "fish.fill" : "fork.knife") }
                                    if let tameable = creature.tameable { fact("Tameable", value: tameable ? "Tameable" : "Untameable", icon: tameable ? "checkmark.seal.fill" : "xmark.seal.fill") }
                                }
                                if creature.tameable == true {
                                    if !creature.method.isEmpty && creature.method != "X" { fact("Method", value: creature.method, icon: creature.method.contains("Knockout") ? "zzz" : "hand.draw.fill") }
                                    if !creature.foods.isEmpty { Text("Preferred food").font(.caption.bold()).foregroundStyle(.secondary); FactGrid(matches: VisualFacts.items(creature.foods)) }
                                }
                            }.accessibilityIdentifier("creature-taming-panel")
                            panel("Base stats", symbol: "chart.bar.fill") {
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                                    ForEach(creature.stats, id: \.label) { stat in
                                        fact(stat.label, value: stat.value.formatted(.number.precision(.fractionLength(0...2))), icon: VisualFacts.symbol(for: stat.label))
                                    }
                                }
                                Text("Wild base values · level and server settings affect final stats.").font(.caption2).foregroundStyle(.secondary)
                            }.accessibilityIdentifier("creature-stats-panel")
                            panel("Loot & immobilization", symbol: "shippingbox.fill") {
                                if !creature.drops.isEmpty { Text("Loot").font(.caption.bold()).foregroundStyle(.secondary); FactGrid(matches: VisualFacts.items(creature.drops)) }
                                if !creature.immobilizedBy.isEmpty { Text("Immobilization").font(.caption.bold()).foregroundStyle(.secondary); FactGrid(matches: VisualFacts.items(creature.immobilizedBy)) }
                            }.accessibilityIdentifier("creature-loot-panel")
                        } else {
                            panel("Profile", symbol: "book.closed.fill") { Text("Taming details are being added.").font(.subheadline).foregroundStyle(.secondary) }
                        }
                    }.accessibilityIdentifier("creature-profile-columns")
                    if let notes = creature.archive?.notes, !notes.isEmpty { notePanel("Practical notes", text: notes) }
                    if !creature.updateNote.isEmpty && creature.updateNote != creature.archive?.notes { notePanel("Recent updates", text: creature.updateNote) }
                    Link(destination: URL(string: creature.sourceURL)!) { Label("Creature reference", systemImage: "book.closed") }.font(.caption).foregroundStyle(.cyan)
                }.padding(20)
            }
        }.navigationTitle(creature.name).navigationBarTitleDisplayMode(.inline)
            .background(Color(red: 0.025, green: 0.045, blue: 0.065))
    }
    private func fact(_ label: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(label, systemImage: icon).font(.caption).foregroundStyle(.cyan)
            Text(value).font(.system(size: 16, weight: .semibold)).fixedSize(horizontal: false, vertical: true)
        }.padding(10).frame(maxWidth: .infinity, alignment: .leading).background(.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 10))
    }
    private func panel<Content: View>(_ title: String, symbol: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: symbol).font(.headline).foregroundStyle(.cyan)
            content()
        }.padding(14).frame(maxWidth: .infinity, alignment: .leading).background(.white.opacity(0.055), in: RoundedRectangle(cornerRadius: 14))
    }
    private func notePanel(_ title: String, text: String) -> some View {
        panel(title, symbol: "lightbulb.fill") { Text(text).font(.subheadline).fixedSize(horizontal: false, vertical: true) }
    }
}

extension View {
    func cardStyle() -> some View {
        self.padding(22).frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.055), in: RoundedRectangle(cornerRadius: 8))
    }
}

/// White dossier silhouettes use bright, source-backed accents for recognizable variants.
struct CreatureSilhouetteAliases: Decodable {
    let aliases: [String:String]
    static let shared = (try? ArkMap.load(CreatureSilhouetteAliases.self, name: "creature-silhouette-aliases")) ?? CreatureSilhouetteAliases(aliases: [:])
}
struct CreatureAvatar: View {
    let asset: String
    static func accent(for asset: String) -> Color {
        let id = asset.lowercased()
        if id.contains("alpha-") { return Color(red: 1, green: 0.30, blue: 0.34) }
        if id.contains("corrupted-") { return Color(red: 0.86, green: 0.48, blue: 1) }
        if id.contains("fire-wyvern") { return Color(red: 1, green: 0.60, blue: 0.27) }
        if id.contains("lightning-wyvern") { return Color(red: 0.63, green: 0.66, blue: 1) }
        if id.contains("poison-wyvern") { return Color(red: 0.58, green: 1, blue: 0.40) }
        if id.contains("ice-wyvern") { return Color(red: 0.65, green: 0.92, blue: 1) }
        return .white
    }
    private var silhouette: UIImage? {
        if let image = UIImage(named: asset) { return image }
        if let name = CreatureSilhouetteAliases.shared.aliases[asset.replacingOccurrences(of: "Dino-", with: "")], let image = UIImage(named: name) { return image }
        let parts = asset.replacingOccurrences(of: "Dino-", with: "").split(separator: "-").map(String.init)
        let variants: Set<String> = ["aberrant", "alpha", "corrupted", "tek", "x", "r", "spirit", "brute", "skeletal", "zombie", "malfunctioned", "polar", "summoned"]
        let base = parts.filter { !variants.contains($0) }.joined(separator: "-")
        return UIImage(named: "Dino-" + base)
    }
    var body: some View {
        if let image = silhouette { Image(uiImage: image).renderingMode(.template).resizable().scaledToFit().foregroundStyle(Self.accent(for: asset)) }
        else { Image(systemName: "pawprint.fill").resizable().scaledToFit().foregroundStyle(Self.accent(for: asset)).padding(18) }
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
