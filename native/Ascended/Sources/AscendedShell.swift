import SwiftUI

enum Destination: String, CaseIterable, Identifiable {
    case ragnarok = "Ragnarok", map = "Bản đồ", dinos = "Dino", bosses = "Boss", exploration = "Artifact & Hang", notes = "Ghi chú", sources = "Nguồn tham khảo"
    var id: String { rawValue }
    var symbol: String {
        switch self {
        case .ragnarok: "mountain.2.fill"
        case .map: "map.fill"
        case .dinos: "pawprint.fill"
        case .bosses: "shield.lefthalf.filled"
        case .exploration: "diamond.fill"
        case .notes: "square.and.pencil"
        case .sources: "book.closed.fill"
        }
    }
}

struct AscendedShell: View {
    @State private var selection: Destination? = .ragnarok
    @State private var visibility: NavigationSplitViewVisibility = .all
    var body: some View {
        NavigationSplitView(columnVisibility: $visibility) {
            List(selection: $selection) {
                VStack(alignment: .leading, spacing: 8) {
                    Image("ArkLogo").resizable().scaledToFit().frame(height: 100)
                    Text("ASCENDED").font(.title2.weight(.bold)).tracking(3)
                    Text("Hành trình của anh").font(.subheadline).foregroundStyle(.secondary)
                }
                .padding(.vertical, 16).listRowBackground(Color.clear)
                Section("SINGLE PLAYER") {
                    ForEach(Destination.allCases) { item in
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
                    switch selection ?? .ragnarok {
                    case .ragnarok: RagnarokOverview(openMap: { selection = .map }, openDinos: { selection = .dinos }, openBosses: { selection = .bosses })
                    case .map: RagnarokMapScreen()
                    case .dinos: CreatureLibrary()
                    case .bosses: BossLibrary()
                    case .exploration: ExplorationLibrary()
                    case .notes: ExpeditionNotes()
                    case .sources: SourcesScreen()
                    }
                }
                .navigationDestination(for: GuideDestination.self) { $0.screen }
                .navigationTitle((selection ?? .ragnarok).rawValue)
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}
