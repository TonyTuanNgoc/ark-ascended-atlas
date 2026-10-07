import SwiftUI

enum Destination: String, CaseIterable, Identifiable {
    case story = "Cốt truyện ARK", equipment = "Thư viện", expansions = "Map & DLC", farming = "Khai thác", information = "Thông tin map", bases = "Xây base", map = "Bản đồ", dinos = "Dino", bosses = "Boss", exploration = "Artifact & Hang"
    var id: String { rawValue }
    var title: String {
        switch self {
        case .story: "ASA Story"
        case .equipment: "Equipment"
        case .expansions: "Maps & DLC"
        case .farming: "Farming"
        case .information: "Field Guide"
        case .bases: "Base Building"
        case .map: "Atlas"
        case .dinos: "Creatures"
        case .bosses: "Bosses"
        case .exploration: "Artifacts & Caves"
        }
    }
    var symbol: String {
        switch self {
        case .story: "book.closed.fill"
        case .equipment: "square.grid.2x2.fill"
        case .expansions: "square.stack.3d.up.fill"
        case .farming: "hammer.fill"
        case .information: "mountain.2.fill"
        case .bases: "house.fill"
        case .map: "map.fill"
        case .dinos: "pawprint.fill"
        case .bosses: "shield.lefthalf.filled"
        case .exploration: "diamond.fill"
        }
    }
}

/// Original raster avatars are shared by the module rail and Maps picker.
struct NavigationAvatar: View {
    let asset: String
    var size: CGFloat = 40
    var body: some View {
        Image(asset).resizable().scaledToFit().frame(width: size, height: size)
            .accessibilityHidden(true)
    }
}
extension Destination {
    var avatarAsset: String {
        switch self {
        case .story: "Nav-story"
        case .equipment: "Nav-equipment"
        case .expansions: "Nav-maps"
        case .farming: "Nav-farming"
        case .information: "Nav-information"
        case .bases: "Nav-base"
        case .map: "Nav-map"
        case .dinos: "Nav-creatures"
        case .bosses: "Nav-bosses"
        case .exploration: "Nav-caves"
        }
    }
}

struct MapSessionShell: View {
    let map: ArkMap
    let chooseMap: (ArkMap) -> Void
    @State private var selection: Destination = .map
    var body: some View {
        VStack(spacing: 0) {
            header
            NavigationStack {
                Group {
                    switch selection {
                    case .story: StoryGuideScreen()
                    case .equipment: EquipmentLibraryScreen()
                    case .expansions: ExpansionCatalogScreen(chooseMap: selectMap)
                    case .farming: ResourceFarmingScreen()
                    case .information: MapInformationScreen(openMap: { selection = .map }, openDinos: { selection = .dinos }, openBosses: { selection = .bosses })
                    case .bases: BasePlanningScreen()
                    case .map: MapScreen()
                    case .dinos: CreatureLibrary()
                    case .bosses: BossCampaignScreen()
                    case .exploration: ExplorationLibrary()
                    }
                }.navigationDestination(for: GuideDestination.self) { $0.screen }
                    .navigationTitle(selection == .map ? map.name : selection.title)
                    .navigationBarTitleDisplayMode(.inline)
            }.id(map.rawValue + "-" + selection.rawValue)
        }.background(Color(red: 0.035, green: 0.05, blue: 0.065))
    }
    private func selectMap(_ map: ArkMap) {
        selection = .map
        chooseMap(map)
    }
    private var header: some View {
        HStack(spacing: 12) {
            Image("ArkLogo").resizable().scaledToFit()
                .frame(width: 64, height: 70)
                .accessibilityIdentifier("ascended-header-logo")
                .accessibilityLabel("ARK Survival Ascended")
            UnifiedMapsPicker(map: map, choose: selectMap)
            ScrollViewReader { reader in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 5) {
                        ForEach(Destination.allCases.filter { $0 != .expansions }) { item in
                            Button {
                                selection = item
                                withAnimation(.easeInOut(duration: 0.2)) { reader.scrollTo(item.id, anchor: .center) }
                            } label: {
                                VStack(spacing: 4) {
                                    NavigationAvatar(asset: item.avatarAsset, size: 30)
                                    Text(item.title).font(.system(size: 11, weight: .semibold))
                                        .multilineTextAlignment(.center).lineLimit(2)
                                        .fixedSize(horizontal: false, vertical: true).frame(height: 28)
                                }.frame(width: 84, height: 68)
                                    .background(selection == item ? Color.cyan.opacity(0.12) : Color.white.opacity(0.025), in: RoundedRectangle(cornerRadius: 12))
                                    .overlay { RoundedRectangle(cornerRadius: 12).strokeBorder(selection == item ? Color.cyan.opacity(0.5) : .clear, lineWidth: 1) }
                                    .contentShape(RoundedRectangle(cornerRadius: 12))
                            }.buttonStyle(.plain).foregroundStyle(selection == item ? .white : .white.opacity(0.78))
                                .accessibilityIdentifier("section-" + item.rawValue)
                                .accessibilityValue(selection == item ? "Selected" : "Not selected")
                                .id(item.id)
                        }
                    }
                }.accessibilityIdentifier("top-module-navigation")
            }
        }.frame(height: 70).padding(.horizontal, 14).padding(.vertical, 8)
            .background(LinearGradient(colors: [Color(red: 0.07, green: 0.10, blue: 0.12), Color(red: 0.035, green: 0.05, blue: 0.065)], startPoint: .top, endPoint: .bottom))
            .overlay(alignment: .bottom) { Rectangle().fill(.white.opacity(0.08)).frame(height: 1) }
    }

}

private struct CurrentMapArtwork: View {
    let map: ArkMap
    private var image: UIImage? {
        UIImage(named: map == .island ? map.imageAsset : "MapLogo-" + map.expansionID) ?? UIImage(named: map.imageAsset)
    }
    var body: some View {
        if let image {
            Image(uiImage: image).resizable().aspectRatio(image.size.width / image.size.height, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .frame(maxHeight: 68, alignment: .leading)
                .accessibilityHidden(true)
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

private struct UnifiedMapsPicker: View {
    let map: ArkMap
    let choose: (ArkMap) -> Void
    @State private var presented = false
    var body: some View {
        Button { presented.toggle() } label: {
            VStack(alignment: .leading, spacing: 4) {
                CurrentMapArtwork(map: map).frame(width: 114, height: 46, alignment: .leading)
                HStack(spacing: 5) {
                    Text(map.name).font(.system(size: 12, weight: .semibold)).lineLimit(1).minimumScaleFactor(0.75)
                    Image(systemName: "chevron.down").font(.system(size: 9, weight: .bold))
                }
            }.frame(width: 128, height: 68, alignment: .leading)
                .contentShape(RoundedRectangle(cornerRadius: 10))

        }.buttonStyle(.plain).accessibilityIdentifier("maps-picker").accessibilityLabel("Maps · " + map.name)
            .popover(isPresented: $presented) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("Maps").font(.title2.bold())
                        mapGroup("Story Maps", asset: "Nav-story", options: ArkMap.storyMaps)
                        mapGroup("Exploration Maps", asset: "Nav-map", options: ArkMap.extraMaps)
                    }.padding(20)
                }.accessibilityIdentifier("maps-list").frame(width: 420, height: 640)
                    .presentationCompactAdaptation(.popover)
            }
    }
    private func mapGroup(_ title: String, asset: String, options: [ArkMap]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) { NavigationAvatar(asset: asset, size: 32); Text(title).font(.headline).foregroundStyle(.cyan) }
            ForEach(options) { option in
                Button {
                    presented = false
                    choose(option)
                } label: {
                    HStack(spacing: 12) {
                        MapBadge(id: option.expansionID)
                        Text(option.name).font(.subheadline.weight(.semibold))
                        Spacer(minLength: 0)
                        if option == map || (option == .genesis && map == .genesisOcean) { Image(systemName: "checkmark.circle.fill").foregroundStyle(.cyan) }
                    }.padding(10).background(.white.opacity(option == map ? 0.08 : 0.025), in: RoundedRectangle(cornerRadius: 12))
                }.buttonStyle(.plain).accessibilityIdentifier("choose-" + option.rawValue)
                    .accessibilityValue(option == map ? "Selected" : "Not selected")
                if option == .genesis {
                    Button { presented = false; choose(.genesisOcean) } label: {
                        HStack(spacing: 10) {
                            NavigationAvatar(asset: "Nav-map", size: 26)
                            Text("Ocean biome").font(.caption)
                            Spacer()
                            if map == .genesisOcean { Image(systemName: "checkmark.circle.fill").foregroundStyle(.cyan) }
                        }.padding(10)
                    }.buttonStyle(.plain).padding(.leading, 30).accessibilityIdentifier("choose-" + ArkMap.genesisOcean.rawValue)
                }
            }
        }
    }
}
