import SwiftUI
import UIKit

struct CreatureLibrary: View {
    @Environment(\.arkMap) private var map
    @State private var search = ""
    @State private var filter = "Tất cả"
    private let filters = ["Tất cả", "Trên cạn", "Bay", "Dưới nước", "Alpha", "DLC"]
    var body: some View {
        Group {
            switch map.creatures {
            case .failure:
                ContentUnavailableView("Chưa mở được thư viện", systemImage: "book.closed", description: Text("Hãy đóng và mở lại Ascended."))
            case .success(let catalog):
                let items = catalog.creatures.filter { d in
                    (filter == "Tất cả" || (filter == "DLC" ? !d.dlc.isEmpty : d.group == filter)) &&
                    (search.isEmpty || ([d.name] + d.aliases).contains { $0.localizedStandardContains(search) })
                }
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack(alignment: .firstTextBaseline) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Dino & sinh vật").font(.largeTitle.bold())
                                Text(map.name + " Ascended · Đối chiếu 03/10/2026").foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text("\(items.count)").font(.largeTitle.bold()).foregroundStyle(.cyan)
                        }
                        Text("Danh mục gồm sinh vật và biến thể. Những con cần DLC được đánh dấu riêng; boss nằm trong mục Boss.")
                            .font(.subheadline).foregroundStyle(.secondary)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(filters, id: \.self) { item in
                                    Button(item) { filter = item }
                                        .buttonStyle(.bordered).tint(filter == item ? .cyan : .gray)
                                        .accessibilityIdentifier("filter-" + item)
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
                .searchable(text: $search, placement: .navigationBarDrawer(displayMode: .always), prompt: "Tìm Dino trên " + map.name)
                .accessibilityIdentifier("creatureLibrary")
            }
        }.background(Color(red: 0.025, green: 0.045, blue: 0.065))
    }
}

struct CreaturePortrait: View {
    let creature: Creature
    var body: some View {
        Group {
            if UIImage(named: creature.iconAsset) != nil {
                CreatureAvatar(asset: creature.iconAsset)
            } else {
                Image(systemName: "pawprint.fill").resizable().scaledToFit().foregroundStyle(.cyan.opacity(0.6)).padding(18)
            }
        }
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
        }.padding(18).frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.055), in: RoundedRectangle(cornerRadius: 18))
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
                    section("Cập nhật mới", text: creature.updateNote)
                    if let url = creature.updateSourceURL.flatMap(URL.init(string:)) { Link("Xem thông báo Studio Wildcard", destination: url) }
                }
                if creature.detailAvailable {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Thuần hóa").font(.title2.bold())
                        if !creature.diet.isEmpty { row("Chế độ ăn", creature.diet) }
                        if let tameable = creature.tameable { row("Tame trực tiếp", tameable ? "Có" : "Không") }
                        if creature.tameable == true {
                            if !creature.method.isEmpty && creature.method != "X" { row("Phương pháp", translatedMethod(creature.method)) }
                            if !creature.foods.isEmpty { row("Thức ăn được nguồn ghi nhận", creature.foods.joined(separator: " · ")) }
                        }
                    }.cardStyle()
                    if !creature.stats.isEmpty {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Chỉ số nền").font(.title2.bold())
                            Text("Giá trị gốc trong dữ liệu sinh vật, chưa cộng level, tame, imprint hay settings Single Player.").font(.caption).foregroundStyle(.secondary)
                            ForEach(creature.stats, id: \.label) { stat in
                                row(stat.label, stat.value.formatted(.number.precision(.fractionLength(0...2))))
                            }
                        }.cardStyle()
                    }
                    if !creature.drops.isEmpty { section("Loot khi hạ sinh vật", text: creature.drops.joined(separator: " · ")) }
                    if !creature.immobilizedBy.isEmpty { section("Công cụ có thể giữ chân", text: creature.immobilizedBy.joined(separator: " · ")) }
                } else {
                    section("Có trong danh mục " + map.name, text: "Tên và sự hiện diện đã được đối chiếu từ danh mục map. Hướng dẫn tame và chỉ số riêng chưa được xác minh đầy đủ trong app.")
                }
                if let archive = creature.archive {
                    DisclosureGroup("Ghi chép trước đây của anh · " + archive.date) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Bản lưu từ repo cũ; dùng để đối chiếu, không coi là hướng dẫn cập nhật.").font(.caption).foregroundStyle(.secondary)
                            if !archive.method.isEmpty { row("Tame", archive.method) }
                            if !archive.food.isEmpty { row("Thức ăn", archive.food) }
                            if !archive.notes.isEmpty { Text(archive.notes).foregroundStyle(.secondary) }
                        }.padding(.top, 12)
                    }.cardStyle()
                }
                VStack(alignment: .leading, spacing: 10) {
                    Text("Nguồn & ngày kiểm tra").font(.headline)
                    Text("Đối chiếu " + creature.reviewedAt).font(.caption).foregroundStyle(.secondary)
                    Link("Hồ sơ sinh vật", destination: URL(string: creature.sourceURL)!)
                    Link("Danh mục " + map.name + " · " + creature.rosterSource, destination: URL(string: creature.rosterSource == "Wiki bổ sung" ? map.wikiURL : map.mapURL)!)
                }.cardStyle()
            }.padding(24).frame(maxWidth: 1000).frame(maxWidth: .infinity)
        }.navigationTitle(creature.name).navigationBarTitleDisplayMode(.inline)
            .background(Color(red: 0.025, green: 0.045, blue: 0.065))
    }
    private func translatedMethod(_ value: String) -> String {
        switch value { case "Knockout": "Đánh ngất"; case "Passive": "Tame thụ động"; case "Special": "Phương pháp đặc biệt"; default: value }
    }
    private func row(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.caption).foregroundStyle(.secondary)
            Text(value).textSelection(.enabled)
        }
    }
    private func section(_ title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.title2.bold()); Text(text).foregroundStyle(.secondary).textSelection(.enabled)
        }.frame(maxWidth: .infinity, alignment: .leading).cardStyle()
    }
}

extension View {
    func cardStyle() -> some View {
        self.padding(22).frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.055), in: RoundedRectangle(cornerRadius: 18))
    }
}

/// Shared high-contrast rendering for creature/boss icons on the dark field guide.
/// Photographic assets such as Nunatak retain their original colours.
struct CreatureAvatar: View {
    let asset: String
    var body: some View {
        Image(asset)
            .renderingMode(asset.hasPrefix("Dino-") || asset.hasPrefix("Boss-") ? .template : .original)
            .resizable()
            .scaledToFit()
            .foregroundStyle(.white)
    }
}
