import SwiftUI
import UIKit

struct MapBadge: View {
    let id: String
    var width: CGFloat = 76
    var height: CGFloat = 48
    var body: some View {
        Group {
            if UIImage(named: "MapLogo-" + id) != nil {
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
private struct StoryTopic: Identifiable {
    let id, title, asset: String
    static let all: [Self] = [
        .init(id: "start", title: "Start here", asset: "Nav-information"),
        .init(id: "loop", title: "Game loop", asset: "Nav-creatures"),
        .init(id: "notes", title: "Explorer notes", asset: "Nav-story"),
        .init(id: "reading-order", title: "Reading order", asset: "Equipment-compass"),
        .init(id: "asa-order", title: "ASA timeline", asset: "Nav-maps"),
        .init(id: "full", title: "Full story", asset: "Nav-map"),
        .init(id: "characters", title: "Characters", asset: "Nav-bosses")
    ]
}
struct StoryGuideScreen: View {
    @State private var selected = "start"
    @State private var chapterID = StoryGuide.shared.chapters.first?.id ?? ""
    @State private var characterID = StoryGuide.shared.characters.first?.id ?? ""
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HStack(spacing: 20) {
                    NavigationAvatar(asset: "Nav-story", size: 90)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Understand the world of ARK").font(.system(size: 32, weight: .bold, design: .rounded))
                        Text("The world, the journey, and the people behind it.").font(.title3).foregroundStyle(.secondary)
                    }
                }.padding(.vertical, 8)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(StoryTopic.all) { topic in
                            topicButton(id: topic.id, title: topic.title, asset: topic.asset)
                        }
                    }.padding(.vertical, 2)
                }.accessibilityIdentifier("story-topic-navigation")
                Group {
                    if let section = StoryGuide.shared.overview.first(where: { $0.id == selected }) {
                        readingPanel(title: section.title, paragraphs: section.paragraphs)
                    } else if selected == "full" {
                        VStack(alignment: .leading, spacing: 18) {
                            Label("Contains story spoilers", systemImage: "eye").font(.caption).foregroundStyle(.orange)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(StoryGuide.shared.chapters) { chapter in
                                        Button { chapterID = chapter.id } label: {
                                            VStack(spacing: 8) {
                                                if let id = chapter.mapID { MapBadge(id: id, width: 110, height: 68) }
                                                else { NavigationAvatar(asset: "Nav-story", size: 68) }
                                                Text(chapter.title.replacingOccurrences(of: "SPOILER — ", with: "")).font(.caption.weight(.semibold)).lineLimit(3).frame(height: 48)
                                            }.frame(width: 130).padding(10)
                                                .background(chapterID == chapter.id ? Color.cyan.opacity(0.13) : .white.opacity(0.035), in: RoundedRectangle(cornerRadius: 14))
                                        }.buttonStyle(.plain).accessibilityIdentifier("chapter-" + chapter.id)
                                            .accessibilityValue(chapterID == chapter.id ? "Selected" : "Not selected")
                                    }
                                }
                            }
                            if let chapter = StoryGuide.shared.chapters.first(where: { $0.id == chapterID }) {
                                readingPanel(title: chapter.summary, paragraphs: chapter.paragraphs)
                                Label(chapter.playGoal, systemImage: "flag.checkered").font(.callout).foregroundStyle(.cyan)
                                    .fixedSize(horizontal: false, vertical: true).padding(18)
                            }
                        }
                    } else if selected == "characters" {
                        VStack(alignment: .leading, spacing: 18) {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(StoryGuide.shared.characters) { person in
                                        Button { characterID = person.id } label: {
                                            Text(person.title).font(.subheadline.weight(.semibold)).padding(14)
                                                .background(characterID == person.id ? Color.cyan.opacity(0.15) : .white.opacity(0.04), in: RoundedRectangle(cornerRadius: 12))
                                        }.buttonStyle(.plain)
                                    }
                                }
                            }
                            if let person = StoryGuide.shared.characters.first(where: { $0.id == characterID }) {
                                readingPanel(title: person.title, paragraphs: person.paragraphs)
                            }
                        }
                    }
                }
            }.padding(24).frame(maxWidth: 1150).frame(maxWidth: .infinity)
        }.accessibilityIdentifier("storyGuide")
    }
    private func topicButton(id: String, title: String, asset: String) -> some View {
        Button { selected = id } label: {
            VStack(spacing: 10) {
                NavigationAvatar(asset: asset, size: 60)
                    .shadow(color: .cyan.opacity(selected == id ? 0.28 : 0.08), radius: 12)
                Text(title).font(.system(size: 14, weight: .semibold, design: .rounded)).multilineTextAlignment(.center)
                    .lineLimit(2).frame(height: 34)
            }.frame(width: 126, height: 120).padding(6)
                .background(LinearGradient(colors: [Color.cyan.opacity(selected == id ? 0.16 : 0.035), Color.white.opacity(0.025)], startPoint: .top, endPoint: .bottom), in: RoundedRectangle(cornerRadius: 16))
                .overlay { RoundedRectangle(cornerRadius: 16).strokeBorder(selected == id ? .cyan.opacity(0.55) : .white.opacity(0.08)) }
                .contentShape(Rectangle())
        }.buttonStyle(.plain).foregroundStyle(selected == id ? .white : .secondary)
            .accessibilityIdentifier("story-" + id).accessibilityValue(selected == id ? "Selected" : "Not selected")
    }
    private func readingPanel(title: String, paragraphs: [String]) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(title).font(.title2.bold()).accessibilityIdentifier("story-content-title")
            ForEach(paragraphs, id: \.self) {
                Text($0).font(.body).lineSpacing(5).fixedSize(horizontal: false, vertical: true).frame(maxWidth: .infinity, alignment: .leading)
            }
        }.padding(24).frame(maxWidth: .infinity, alignment: .leading)
            .background(.white.opacity(0.035), in: RoundedRectangle(cornerRadius: 18))
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
                let reference = EquipmentReferenceCatalogue.shared.item(item.id)
                Text(reference?.purpose ?? item.summary).font(.callout)
                if reference?.purpose == nil && !item.use.isEmpty { Text(item.use).font(.callout).foregroundStyle(.secondary) }
                if let reference {
                    EquipmentReferencePanel(item: item, reference: reference)
                }
                if let gathering = HarvestingCatalogue.shared.resource(item.name) {
                    HarvestingReferencePanel(reference: gathering)
                } else {
                    ForEach(HarvestingCatalogue.shared.uses(item.name)) { gathering in
                        HarvestingReferencePanel(reference: gathering)
                    }
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
