import SwiftUI

enum Destination: String, CaseIterable, Identifiable {
    case session = "Hôm nay", information = "Thông tin map", bases = "Base Location", map = "Bản đồ", dinos = "Dino", bosses = "Boss", exploration = "Artifact & Hang"
    var id: String { rawValue }
    var symbol: String {
        switch self {
        case .session: "scope"
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
    let changeMap: () -> Void
    @State private var selection: Destination? = .session
    @State private var visibility: NavigationSplitViewVisibility = .all
    var body: some View {
        NavigationSplitView(columnVisibility: $visibility) {
            List(selection: $selection) {
                VStack(alignment: .leading, spacing: 8) {
                    Image("ArkLogo").resizable().scaledToFit().frame(height: 100)
                    Text("ASCENDED").font(.title2.weight(.bold)).tracking(3)
                    Text(map.name).font(.subheadline).foregroundStyle(.secondary)
                }
                .padding(.vertical, 16).listRowBackground(Color.clear)
                Button(action: changeMap) { Label("Chọn map khác", systemImage: "square.grid.2x2.fill") }.accessibilityIdentifier("changeMap")
                Section(map.name.uppercased() + " · SINGLE PLAYER") {
                    ForEach(Destination.allCases.filter { $0 != .bases || map == .ragnarok }) { item in
                        NavigationLink(value: item) {
                            Label(item.rawValue, systemImage: item.symbol)
                                .padding(.vertical, 8)
                        }.accessibilityIdentifier("section-" + item.rawValue)
                    }
                }
            }
            .navigationTitle("Ascended")
            .navigationSplitViewColumnWidth(min: 230, ideal: 260, max: 320)
        } detail: {
            NavigationStack {
                Group {
                    switch selection ?? .information {
                    case .session: PlaySessionScreen(openBosses: { selection = .bosses })
                    case .information: MapInformationScreen(openMap: { selection = .map }, openDinos: { selection = .dinos }, openBosses: { selection = .bosses })
                    case .bases: BaseLocationsScreen()
                    case .map: MapScreen()
                    case .dinos: CreatureLibrary()
                    case .bosses: BossCampaignScreen()
                    case .exploration: ExplorationLibrary()
                    }
                }
                .navigationDestination(for: GuideDestination.self) { $0.screen }
                .navigationTitle((selection ?? .information).rawValue)
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

struct AscendedShell: View {
    @State private var selectedMap: ArkMap?
    var body: some View {
        if let map = selectedMap {
            MapSessionShell(map: map, changeMap: { selectedMap = nil })
                .environment(\.arkMap, map).id(map)
        } else {
            MapPicker { selectedMap = $0 }
        }
    }
}
