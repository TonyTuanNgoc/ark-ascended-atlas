import SwiftUI
import UIKit

struct MapBadge: View {
    let id: String
    var width: CGFloat = 76
    var height: CGFloat = 48
    var body: some View {
        Group {
            if id == "the-island", let map = ArkMap(rawValue: id) {
                Image(map.imageAsset).resizable().scaledToFill()
            } else if UIImage(named: "MapLogo-" + id) != nil {
                Image("MapLogo-" + id).resizable().scaledToFit()
            } else if let map = ArkMap(rawValue: id) {
                Image(map.imageAsset).resizable().scaledToFit()
            } else { Image("ArkLogo").resizable().scaledToFit() }
        }.frame(width: width, height: height)
            .background(Color.black.opacity(0.25), in: RoundedRectangle(cornerRadius: 14))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay { RoundedRectangle(cornerRadius: 14).strokeBorder(.white.opacity(0.1)) }
            .accessibilityHidden(true)
    }
}
struct StoryGuide: Decodable {
    let overview: [StorySection]; let chapters: [StoryChapter]; let characters: [StorySection]
    static let shared = (try? ArkMap.load(StoryGuide.self, name: "story-guide")) ?? StoryGuide(overview: [], chapters: [], characters: [])
}
struct StorySection: Decodable, Identifiable { let id, title, symbol: String; let paragraphs: [String] }
struct StoryChapter: Decodable, Identifiable { let id, title, summary, playGoal: String; let mapID: String?; let paragraphs: [String] }
struct StoryGuideScreen: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    Label("ARK STORY GUIDE", systemImage: "book.closed.fill").font(.caption.bold()).foregroundStyle(.cyan)
                    Text("Understand the world of ARK").font(.largeTitle.bold())
                    Text("Explore the setting, follow the story across the ARKs, and meet the people behind the journey.").font(.title3).foregroundStyle(.secondary)
                }.padding(.vertical, 8)
                Text("The world & its mysteries").font(.title2.bold())
                ForEach(StoryGuide.shared.overview) { section in
                    DisclosureGroup { paragraphs(section.paragraphs) } label: {
                        Label(section.title, systemImage: section.symbol).font(.headline).padding(.vertical, 6)
                    }.cardStyle().accessibilityIdentifier("story-" + section.id)
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text("The complete journey").font(.title2.bold())
                    Text("Story spoilers · Open a chapter to read its events and gameplay goal.").font(.subheadline).foregroundStyle(.secondary)
                }.padding(.top, 8)
                DisclosureGroup {
                    VStack(spacing: 12) {
                        ForEach(StoryGuide.shared.chapters) { chapter in
                            DisclosureGroup {
                                Text(chapter.summary).font(.headline).foregroundStyle(.cyan).fixedSize(horizontal: false, vertical: true).padding(.top, 12)
                                paragraphs(chapter.paragraphs)
                                Label(chapter.playGoal, systemImage: "flag.checkered").font(.callout).fixedSize(horizontal: false, vertical: true)
                                    .padding(14).frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.cyan.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
                            } label: {
                                HStack(spacing: 12) { if let id = chapter.mapID { MapBadge(id: id) }; Text(chapter.title).font(.headline).fixedSize(horizontal: false, vertical: true) }.padding(.vertical, 6)
                            }.padding(16).background(Color.white.opacity(0.035), in: RoundedRectangle(cornerRadius: 12))
                                .accessibilityIdentifier("chapter-" + chapter.id)
                        }
                    }.padding(.top, 14)
                } label: { Label("Full story · contains spoilers", systemImage: "book.closed.fill").font(.headline).padding(.vertical, 6) }
                    .cardStyle().accessibilityIdentifier("story-full")
                DisclosureGroup {
                    VStack(spacing: 12) {
                        ForEach(StoryGuide.shared.characters) { section in
                            DisclosureGroup { paragraphs(section.paragraphs) } label: { Label(section.title, systemImage: section.symbol).font(.headline).padding(.vertical, 6) }
                                .padding(16).background(Color.white.opacity(0.035), in: RoundedRectangle(cornerRadius: 12))
                        }
                    }.padding(.top, 14)
                } label: { Label("Characters & concepts", systemImage: "person.2.fill").font(.headline).padding(.vertical, 6) }.cardStyle()
            }.padding(24).frame(maxWidth: 1050).frame(maxWidth: .infinity)
        }.accessibilityIdentifier("storyGuide")
    }
    private func paragraphs(_ values: [String]) -> some View {
        VStack(alignment: .leading, spacing: 16) { ForEach(values, id: \.self) { Text($0).font(.body).lineSpacing(5).fixedSize(horizontal: false, vertical: true).frame(maxWidth: .infinity, alignment: .leading) } }.padding(.vertical, 16)
    }
}
struct EquipmentCatalogue: Decodable {
    let items: [EquipmentItem]; let categories: [EquipmentCategory]
    static let shared = (try? ArkMap.load(EquipmentCatalogue.self, name: "equipment-library")) ?? EquipmentCatalogue(items: [], categories: [])
    static func find(_ name: String) -> EquipmentItem? { shared.items.first { $0.name.caseInsensitiveCompare(name) == .orderedSame } }
}
struct EquipmentCategory: Decodable, Identifiable { let id, title, symbol: String }
struct EquipmentItem: Decodable, Identifiable {
    let id, name, category, summary, use, station, unlock, sourceURL: String
    let mapIDs: [String]; let asset: String?; let availability: String?; let editionNote: String?
    var fact: VisualFact { VisualFact(id: id, name: name, aliases: [name], asset: asset, symbol: category == "tools" ? "wrench.and.screwdriver.fill" : category == "machines" ? "gearshape.2.fill" : "shippingbox.fill", category: "item") }
}
extension EquipmentCategory {
    var avatarAsset: String { "Library-" + id }
}
struct EquipmentLibraryScreen: View {
    @State private var search = ""
    @State private var selectedCategory = "resources"
    @FocusState private var searchFocused: Bool
    private var items: [EquipmentItem] {
        EquipmentCatalogue.shared.items.filter {
            $0.category == selectedCategory && (search.isEmpty || ($0.name + " " + $0.summary + " " + $0.use).localizedStandardContains(search))
        }
    }
    var body: some View {
        GeometryReader { geometry in
            let contentWidth = min(geometry.size.width, 1150)
            let columnCount = max(1, min(7, Int(max(0, contentWidth - 48) / 110)))
            let categoryWidth = max(110, (contentWidth - 80) / CGFloat(max(1, EquipmentCatalogue.shared.categories.count)))
            VStack(spacing: 14) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(EquipmentCatalogue.shared.categories) { category in
                            Button { selectedCategory = category.id } label: {
                                VStack(spacing: 6) {
                                    NavigationAvatar(asset: category.avatarAsset, size: 42)
                                    Text(category.title).font(.system(size: 14, weight: .semibold))
                                        .multilineTextAlignment(.center).lineLimit(2)
                                        .fixedSize(horizontal: false, vertical: true).frame(height: 36)
                                }.frame(width: categoryWidth, height: 88).padding(.vertical, 8)
                                    .background(selectedCategory == category.id ? Color.cyan.opacity(0.12) : .white.opacity(0.035), in: RoundedRectangle(cornerRadius: 14))
                                    .overlay { RoundedRectangle(cornerRadius: 14).strokeBorder(selectedCategory == category.id ? Color.cyan.opacity(0.45) : .clear) }
                            }.buttonStyle(.plain)
                                .accessibilityIdentifier("equipment-category-" + category.id)
                                .accessibilityValue(selectedCategory == category.id ? "Selected" : "Not selected")
                        }
                    }.padding(.horizontal, 24)
                }.accessibilityIdentifier("equipment-category-navigation")
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                    TextField("Search " + (EquipmentCatalogue.shared.categories.first { $0.id == selectedCategory }?.title.lowercased() ?? "equipment"), text: $search)
                        .textInputAutocapitalization(.never).autocorrectionDisabled()
                        .focused($searchFocused).submitLabel(.search).onSubmit { searchFocused = false }
                        .accessibilityIdentifier("equipment-search")
                    if !search.isEmpty { Button { search = "" } label: { Image(systemName: "xmark.circle.fill") }.accessibilityLabel("Clear search") }
                }.padding(14).background(.white.opacity(0.055), in: RoundedRectangle(cornerRadius: 12)).padding(.horizontal, 24)
                ScrollView {
                    if items.isEmpty { ContentUnavailableView.search(text: search).padding(.top, 50) }
                    else {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: columnCount), spacing: 10) {
                            ForEach(items) { item in
                                NavigationLink { EquipmentDetail(item: item) } label: {
                                    VStack(spacing: 8) {
                                        FactPicture(fact: item.fact).frame(height: 54)
                                        Text(item.name).font(.caption.bold()).fixedSize(horizontal: false, vertical: true)
                                            .multilineTextAlignment(.center).frame(maxWidth: .infinity)
                                    }.padding(8).frame(maxWidth: .infinity).frame(minHeight: 108, alignment: .top)
                                        .background(.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 12))
                                }.buttonStyle(.plain).accessibilityIdentifier("equipment-" + item.id)
                            }
                        }.padding(.horizontal, 24).padding(.bottom, 24)
                    }
                }.scrollDismissesKeyboard(.interactively).accessibilityIdentifier("equipment-results")
            }.padding(.top, 8).frame(maxWidth: 1150).frame(maxWidth: .infinity)
        }
    }
}
struct EquipmentDetail: View {
    let item: EquipmentItem
    @State private var craft=false
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                FactPicture(fact: item.fact).frame(height: 170).frame(maxWidth: .infinity)
                Text(item.name).font(.largeTitle.bold())
                if BuildCraftCatalogue.shared.item(item.id)?.recipeVerified == true {Button {craft=true} label: {Label("Craft",systemImage:"hammer.fill")}.buttonStyle(.bordered)}
                Text(item.summary)
                Label(item.use, systemImage: "hand.point.up.left.fill")
                if let recipe = BuildCraftCatalogue.shared.item(item.id), recipe.recipeVerified {
                    Label(recipe.stations.isEmpty ? "Crafting station not specified in the source" : recipe.stations.joined(separator: " · "), systemImage: "gearshape.fill")
                } else if !item.station.isEmpty {
                    Label(item.station, systemImage: "gearshape.fill")
                }
                if item.category != "resources" && item.category != "supplies" {
                    if !item.unlock.isEmpty { Label(item.unlock, systemImage: "lock.open.fill") }
                }
                if item.availability == "source-catalog-check-asa" { Label("Unconfirmed in ASA · check Engrams or DLC", systemImage: "questionmark.circle").font(.callout).foregroundStyle(.orange) }
                if !item.mapIDs.isEmpty {
                    DisclosureGroup("Related maps & content") {
                        ForEach(item.mapIDs, id: \.self) { id in HStack { MapBadge(id: id); Text(ExpansionCatalog.shared.maps.first { $0.id == id }?.name ?? id) } }
                    }
                }
            }.padding(24).frame(maxWidth: 900).frame(maxWidth: .infinity)
        }.sheet(isPresented:$craft) {BuildBillView(pieces:[StonePlacement(kind:item.id,x:0,z:0,level:0,turn:0)])}
        .navigationTitle(item.name).navigationBarTitleDisplayMode(.inline).accessibilityIdentifier("equipmentDetail")
    }
}
struct BasePlan: Decodable {
    let intro: String; let phases: [BasePhase]; let zones: [BaseZone]
    static let shared = (try? ArkMap.load(BasePlan.self, name: "base-plan")) ?? BasePlan(intro: "", phases: [], zones: [])
}
struct BasePhase: Decodable, Identifiable { let id, title, goal: String; let zoneIDs: [String]; let exit: [String] }
struct BaseZone: Decodable, Identifiable { let id, name, symbol, purpose, placement, flow, size: String; let items, steps: [String] }
struct BasePlanningScreen: View {
    @Environment(\.arkMap) private var map
    var body:some View { StoneBuilder(mapID:map.id,embedded:true) }
}
