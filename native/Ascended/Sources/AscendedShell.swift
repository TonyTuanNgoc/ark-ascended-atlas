import SwiftUI

enum Destination: String, CaseIterable, Identifiable {
    case information = "Thông tin map", bases = "Base Location", map = "Bản đồ", dinos = "Dino", bosses = "Boss", exploration = "Artifact & Hang"
    var id: String { rawValue }
    var symbol: String {
        switch self {
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
        NavigationSplitView(columnVisibility: $visibility) {
            List(selection: $selection) {
                Image("ArkLogo").resizable().scaledToFit().frame(height: 85)
                    .frame(maxWidth: .infinity).padding(.vertical, 8).listRowBackground(Color.clear)
                Section("Map") {
                    ForEach(ArkMap.allCases) { option in
                        Button { selection = .map; chooseMap(option) } label: {
                            HStack {
                                Text(option.name)
                                Spacer()
                                if map == option { Image(systemName: "checkmark").foregroundStyle(.cyan) }
                            }.contentShape(Rectangle())
                        }.foregroundStyle(map == option ? .cyan : .primary)
                            .accessibilityIdentifier("choose-" + option.rawValue)
                            .accessibilityValue(map == option ? "Đang chọn" : "Chưa chọn")
                    }
                }
                Section {
                    ForEach(Destination.allCases.filter { $0 != .bases || map == .ragnarok }) { item in
                        NavigationLink(value: item) {
                            Label(item.rawValue, systemImage: item.symbol).padding(.vertical, 4)
                        }.accessibilityIdentifier("section-" + item.rawValue)
                    }
                }
            }.navigationTitle("Ascended")
                .navigationSplitViewColumnWidth(min: 210, ideal: 230, max: 270)
        } detail: {
            NavigationStack {
                Group {
                    switch selection ?? .map {
                    case .information: MapInformationScreen(openMap: { selection = .map }, openDinos: { selection = .dinos }, openBosses: { selection = .bosses })
                    case .bases: BaseLocationsScreen()
                    case .map: MapScreen()
                    case .dinos: CreatureLibrary()
                    case .bosses: BossCampaignScreen()
                    case .exploration: ExplorationLibrary()
                    }
                }.navigationDestination(for: GuideDestination.self) { $0.screen }
                    .navigationTitle(selection == .map ? map.name : (selection ?? .map).rawValue)
                    .navigationBarTitleDisplayMode(.inline)
            }.id(map)
        }.navigationSplitViewStyle(.balanced)
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
