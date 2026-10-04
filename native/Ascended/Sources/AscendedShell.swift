import SwiftUI

enum Destination: String, CaseIterable, Identifiable {
    case story = "Cốt truyện ARK", equipment = "Thư viện", expansions = "Map & DLC", farming = "Khai thác", information = "Thông tin map", bases = "Xây base", map = "Bản đồ", dinos = "Dino", bosses = "Boss", exploration = "Artifact & Hang"
    var id: String { rawValue }
    var title: String {
        switch self {
        case .story: "ARK Story"
        case .equipment: "Equipment Library"
        case .expansions: "Maps & DLC"
        case .farming: "Resource Farming"
        case .information: "Map Information"
        case .bases: "Build a Base"
        case .map: "Map"
        case .dinos: "Creatures"
        case .bosses: "Boss Campaign"
        case .exploration: "Artifacts & Caves"
        }
    }
    var symbol: String {
        switch self {
        case .story: "book.closed.fill"
        case .equipment: "square.grid.2x2.fill"
        case .expansions: "square.stack.3d.up.fill"
        case .farming: "pickaxe"
        case .information: "mountain.2.fill"
        case .bases: "house.fill"
        case .map: "map.fill"
        case .dinos: "pawprint.fill"
        case .bosses: "shield.lefthalf.filled"
        case .exploration: "diamond.fill"
        }
    }
}

struct MapSessionShell: View {
    let map: ArkMap
    let chooseMap: (ArkMap) -> Void
    @State private var selection: Destination? = .map
    @State private var visibility: NavigationSplitViewVisibility = .all
    var body: some View {
        VStack(spacing: 0) {
            adaptiveHeader
        NavigationSplitView(columnVisibility: $visibility) {
            List(selection: $selection) {
                Section {
                    ForEach(Destination.allCases.filter { $0 != .expansions }) { item in
                        NavigationLink(value: item) {
                            Label(item.title, systemImage: item.symbol).padding(.vertical, 4)
                        }.accessibilityIdentifier("section-" + item.rawValue)
                    }
                }
            }.navigationTitle("Ascended")
                .navigationSplitViewColumnWidth(min: 240, ideal: 270, max: 300)
        } detail: {
            NavigationStack {
                Group {
                    switch selection ?? .map {
                    case .story: StoryGuideScreen()
                    case .equipment: EquipmentLibraryScreen()
                    case .expansions: ExpansionCatalogScreen(chooseMap: { selection = .map; chooseMap($0) })
                    case .farming: ResourceFarmingScreen()
                    case .information: MapInformationScreen(openMap: { selection = .map }, openDinos: { selection = .dinos }, openBosses: { selection = .bosses })
                    case .bases: BasePlanningScreen()
                    case .map: MapScreen()
                    case .dinos: CreatureLibrary()
                    case .bosses: BossCampaignScreen()
                    case .exploration: ExplorationLibrary()
                    }
                }.navigationDestination(for: GuideDestination.self) { $0.screen }
                    .navigationTitle(selection == .map ? map.name : (selection ?? .map).title)
                    .navigationBarTitleDisplayMode(.inline)
            }.id(map)
        }.navigationSplitViewStyle(.balanced)
        }
    }
    private var adaptiveHeader: some View {
                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 18) {
                        appLogo
                        currentMapHeader.fixedSize(horizontal: true, vertical: true)
                        Spacer(minLength: 8)
                        mapSelectors.fixedSize(horizontal: true, vertical: true)
                    }
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 14) {
                            appLogo
                            currentMapHeader
                            Spacer(minLength: 0)
                        }
                        mapSelectors.frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }.padding(.horizontal, 20).padding(.vertical, 12)
                    .background(.regularMaterial)
                    .overlay(alignment: .bottom) { Divider() }
    }
    private var appLogo: some View {
        Image("ArkLogo").resizable().scaledToFit().frame(width: 82, height: 46).accessibilityHidden(true)
    }
    private var currentMapHeader: some View {
        HStack(spacing: 10) {
            MapBadge(id: map.expansionID)
            VStack(alignment: .leading, spacing: 2) {
                Text("CURRENT MAP").font(.caption2.bold()).foregroundStyle(.secondary)
                Text(map.name).font(.headline).fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    private var mapSelectors: some View {
        HStack(spacing: 12) {
            mapMenu("Story Maps", stableID: "Cốt truyện", options: ArkMap.storyMaps, symbol: "book.closed.fill")
            mapMenu("Exploration Maps", stableID: "Khám phá", options: ArkMap.extraMaps, symbol: "map.fill")
        }
    }
    private func mapMenu(_ title: String, stableID: String, options: [ArkMap], symbol: String) -> some View {
        MapSelectionCard(title: title, stableID: stableID, symbol: symbol, map: map, options: options) { option in
            selection = .map
            chooseMap(option)
        }
    }

}

struct AscendedShell: View {
    @AppStorage("ascended.selected-map.v1") private var selectedMapID = ArkMap.ragnarok.rawValue
    private var selectedMap: ArkMap { ArkMap(rawValue: selectedMapID) ?? .ragnarok }
    var body: some View {
        MapSessionShell(map: selectedMap, chooseMap: { selectedMapID = $0.rawValue })
            .environment(\.arkMap, selectedMap)
    }
}

private struct MapSelectionCard: View {
    let title, stableID, symbol: String
    let map: ArkMap
    let options: [ArkMap]
    let choose: (ArkMap) -> Void
    @State private var presented = false
    var body: some View {
        Button { presented.toggle() } label: {
            HStack(spacing: 8) {
                Image(systemName: symbol).foregroundStyle(.cyan)
                Text(title).font(.subheadline.bold()).fixedSize(horizontal: false, vertical: true)
                Image(systemName: "chevron.down").font(.caption.bold())
            }.padding(.horizontal, 14).padding(.vertical, 12)
                .background(Color.cyan.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
                .overlay { RoundedRectangle(cornerRadius: 12).strokeBorder(Color.cyan.opacity(0.18)) }
        }.buttonStyle(.plain).accessibilityIdentifier("map-group-" + stableID)
            .popover(isPresented: $presented) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(title).font(.title2.bold()).padding(.bottom, 6)
                        ForEach(options) { option in
                            Button {
                                presented = false
                                choose(option)
                            } label: {
                                HStack(spacing: 12) {
                                    MapBadge(id: option.expansionID)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(option.name).font(.headline)
                                        Text(option == map ? "Current map" : "Open map session").font(.caption).foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: option == map ? "checkmark.circle.fill" : "arrow.up.right").foregroundStyle(.cyan)
                                }.padding(12).background(Color.cyan.opacity(option == map ? 0.14 : 0.04), in: RoundedRectangle(cornerRadius: 12))
                            }.buttonStyle(.plain).accessibilityIdentifier("choose-" + option.rawValue)
                                .accessibilityValue(option == map ? "Selected" : "Not selected")
                        }
                        if options.contains(.genesis) {
                            Button { presented = false; choose(.genesisOcean) } label: {
                                Label("Genesis · Ocean", systemImage: "water.waves").font(.subheadline.bold()).padding(12)
                            }.buttonStyle(.plain).accessibilityIdentifier("choose-" + ArkMap.genesisOcean.rawValue)
                        }
                    }.padding(20)
                }.frame(width: 380, height: min(CGFloat(options.count * 78 + 100), 620))
                    .presentationCompactAdaptation(.popover)
            }
    }
}
