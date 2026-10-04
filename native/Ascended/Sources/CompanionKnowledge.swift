import SwiftUI
import UIKit

struct MapBadge: View {
    let id: String
    var body: some View {
        Group {
            if id == "the-island" {
                Image("TheIslandMap").resizable().scaledToFill()
            } else if UIImage(named: "MapLogo-" + id) != nil {
                Image("MapLogo-" + id).resizable().scaledToFit()
            } else if let map = ArkMap(rawValue: id) {
                Image(map.imageAsset).resizable().scaledToFit()
            } else { Image("ArkLogo").resizable().scaledToFit() }
        }.frame(width: 64, height: 38).background(Color.white.opacity(0.05)).clipShape(RoundedRectangle(cornerRadius:8)).accessibilityHidden(true)
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
            VStack(alignment: .leading, spacing: 16) {
                Text("Hiểu thế giới ARK").font(.largeTitle.bold())
                ForEach(StoryGuide.shared.overview) { section in
                    DisclosureGroup {
                        paragraphs(section.paragraphs)
                    } label: { Label(section.title, systemImage: section.symbol).font(.headline) }
                    .cardStyle().accessibilityIdentifier("story-" + section.id)
                }
                DisclosureGroup {
                    ForEach(StoryGuide.shared.chapters) { chapter in
                        DisclosureGroup {
                            Text(chapter.summary).foregroundStyle(.cyan).padding(.vertical, 8)
                            paragraphs(chapter.paragraphs)
                            Label(chapter.playGoal, systemImage: "flag.checkered").font(.callout).padding(.vertical, 10)
                        } label: {
                            HStack { if let id = chapter.mapID { MapBadge(id: id) }; Text(chapter.title).font(.headline) }
                        }.padding(.vertical, 8).accessibilityIdentifier("chapter-" + chapter.id)
                    }
                } label: { Label("Diễn biến đầy đủ · có tiết lộ", systemImage: "book.closed.fill").font(.headline) }
                .cardStyle().accessibilityIdentifier("story-full")
                DisclosureGroup {
                    ForEach(StoryGuide.shared.characters) { section in
                        DisclosureGroup { paragraphs(section.paragraphs) } label: { Label(section.title, systemImage: section.symbol) }.padding(.vertical, 8)
                    }
                } label: { Label("Nhân vật & khái niệm", systemImage: "person.2.fill").font(.headline) }.cardStyle()
            }.padding(24).frame(maxWidth: 1050).frame(maxWidth: .infinity)
        }.accessibilityIdentifier("storyGuide")
    }
    private func paragraphs(_ values: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) { ForEach(values, id: \.self) { Text($0).fixedSize(horizontal: false, vertical: true) } }.padding(.vertical, 12)
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
struct EquipmentLibraryScreen: View {
    @State private var search = ""
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(EquipmentCatalogue.shared.categories) { category in
                    let items = EquipmentCatalogue.shared.items.filter { $0.category == category.id && (search.isEmpty || ($0.name + " " + $0.summary + " " + $0.use).localizedStandardContains(search)) }
                    if !items.isEmpty {
                        EquipmentCategoryGroup(category: category, items: items, searching: !search.isEmpty)
                    }
                }
                if !search.isEmpty && !EquipmentCatalogue.shared.items.contains(where: { ($0.name + " " + $0.summary + " " + $0.use).localizedStandardContains(search) }) {
                    ContentUnavailableView.search(text: search)
                }
            }.padding(24).frame(maxWidth: 1150).frame(maxWidth: .infinity)
        }.searchable(text: $search, prompt: "Tìm tài nguyên, công cụ, máy móc")
            .accessibilityIdentifier("equipmentLibrary")
    }
}
private struct EquipmentCategoryGroup: View {
    let category: EquipmentCategory; let items: [EquipmentItem]; let searching: Bool
    @State private var expanded = false
    var body: some View {
        DisclosureGroup(isExpanded: Binding(get: { expanded || searching }, set: { expanded = $0 })) {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 145, maximum: 200))], spacing: 12) {
                ForEach(items) { item in
                    NavigationLink { EquipmentDetail(item: item) } label: {
                        VStack(spacing: 10) { FactPicture(fact: item.fact).frame(height: 85); Text(item.name).font(.callout.bold()).lineLimit(2).multilineTextAlignment(.center) }
                        .padding(12).frame(maxWidth: .infinity).frame(height: 145).background(.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 12))
                    }.buttonStyle(.plain).accessibilityIdentifier("equipment-" + item.id)
                }
            }.padding(.top, 14)
        } label: { Label(category.title + " · \(items.count)", systemImage: category.symbol).font(.headline) }
        .cardStyle().accessibilityIdentifier("equipment-category-" + category.id)
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
                if !item.station.isEmpty { Label(item.station, systemImage: "gearshape.fill") }
                if item.category != "resources" && item.category != "supplies" {
                    if let end = item.unlock.range(of: " theo danh mục") { Label(String(item.unlock[..<end.lowerBound]), systemImage: "lock.open.fill") }
                    else if item.unlock.contains("Tekgram") { Label("Cần Tekgram từ boss phù hợp", systemImage: "lock.open.fill") }
                }
                if item.availability == "source-catalog-check-asa" { Label("Chưa xác nhận trong ASA · kiểm tra Engram hoặc DLC", systemImage: "questionmark.circle").font(.callout).foregroundStyle(.orange) }
                if !item.mapIDs.isEmpty {
                    DisclosureGroup("Map & nội dung liên quan") {
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
