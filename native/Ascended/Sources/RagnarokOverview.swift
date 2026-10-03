import SwiftUI

struct RagnarokOverview: View {
    let openMap: () -> Void
    let openDinos: () -> Void
    let openBosses: () -> Void
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                ZStack(alignment: .bottomLeading) {
                    GeometryReader { proxy in
                        Image("RagnarokMap").resizable().scaledToFill()
                            .frame(width: proxy.size.width, height: proxy.size.height).clipped()
                    }
                    LinearGradient(colors: [.clear, .black.opacity(0.9)], startPoint: .top, endPoint: .bottom)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("ARK: SURVIVAL ASCENDED").font(.caption.weight(.bold)).tracking(2).foregroundStyle(.cyan)
                        Text("Ragnarok").font(.system(size: 48, weight: .bold, design: .rounded))
                        Text("Một thế giới. Từng bước chinh phục.").font(.title3)
                        Label("Single Player", systemImage: "person.fill")
                            .font(.subheadline.weight(.semibold))
                            .padding(.horizontal, 12).padding(.vertical, 8)
                            .background(.ultraThinMaterial, in: Capsule())
                    }.padding(28)
                }
                .frame(height: 360).clipShape(RoundedRectangle(cornerRadius: 24))
                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 16) { facts }
                    VStack(alignment: .leading, spacing: 16) { facts }
                }
                VStack(alignment: .leading, spacing: 14) {
                    Text("Bắt đầu từ bản đồ").font(.title2.bold())
                    Text("Quan sát địa hình, chọn nơi dừng chân và ghi lại những gì anh khám phá. Bản đồ được lưu sẵn để anh mở cả khi không có mạng.")
                        .foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
                    Button(action: openMap) {
                        Label("Khám phá Ragnarok", systemImage: "map.fill")
                            .font(.headline).padding(.vertical, 8).frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent).tint(.cyan).foregroundStyle(.black)
                    .accessibilityIdentifier("openRagnarokMap")
                }
                .padding(24).background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 20))
                HStack(spacing: 16) {
                    Button(action: openDinos) { Label("\(RagnarokCatalog.count) Dino & sinh vật", systemImage: "pawprint.fill").frame(maxWidth: .infinity).padding(14) }
                        .buttonStyle(.bordered).accessibilityIdentifier("openDinos")
                    Button(action: openBosses) { Label("Boss Ragnarok", systemImage: "shield.lefthalf.filled").frame(maxWidth: .infinity).padding(14) }
                        .buttonStyle(.bordered).accessibilityIdentifier("openBosses")
                }
                Text("App đồng hành cá nhân · Dev 0.2 (2)")
                    .font(.caption).foregroundStyle(.secondary)
            }.padding(24).frame(maxWidth: 1100)
                .frame(maxWidth: .infinity)
        }.background(Color(red: 0.025, green: 0.045, blue: 0.065))
    }
    @ViewBuilder private var facts: some View {
        fact("144 km²", subtitle: "Thế giới khám phá", symbol: "globe.europe.africa.fill")
        fact("Miễn phí", subtitle: "Map mở rộng chính thức", symbol: "mountain.2.fill")
        fact("Chơi một mình", subtitle: "Tiến độ của riêng anh", symbol: "person.fill")
    }
    private func fact(_ title: String, subtitle: String, symbol: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: symbol).font(.title2).foregroundStyle(.cyan)
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.headline)
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
        }.frame(maxWidth: .infinity, alignment: .leading)
            .padding(18).background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 16))
    }
}
