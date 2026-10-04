import SwiftUI
import UIKit

struct BaseCatalogue: Decodable {
    let reviewedAt: String; let methodology: String; let limits: String
    let videos: [BaseVideo]; let locations: [BaseSpot]
}
struct BaseVideo: Decodable, Identifiable {
    let id: String; let title: String; let channel: String; let url: String; let thumbnailURL: String
    let views: Int; let likes: Int; let observedAt: String
}
struct BaseSpot: Decodable, Identifiable {
    let id: String; let name: String; let rank: Int; let lat: Double; let lon: Double; let tag: String
    let why: String; let pros: [String]; let cons: [String]; let layout: [String]
    let videoID: String; let seconds: Int; let support: String; let sources: [GuideEvidence]
    var coordinates: String { String(format: "LAT %.2f · LON %.2f", lat, lon) }
    var videoURL: URL { URL(string: "https://www.youtube.com/watch?v=\(videoID)&t=\(seconds)s")! }
    var timestamp: String { String(format: "%d:%02d", seconds / 60, seconds % 60) }
}
extension ArkMap {
    var bases: BaseCatalogue? { self == .ragnarok ? Self.ragnarokBases : nil }
    private static let ragnarokBases = try? load(BaseCatalogue.self, name: "ragnarok-bases")
}
struct BaseLocationsScreen: View {
    @Environment(\.arkMap) private var map
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Text("Base Location").font(.largeTitle.bold()).accessibilityIdentifier("baseLocationsTitle")
                if let catalogue = map.bases {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 240, maximum: 340), spacing: 16)], spacing: 16) {
                        ForEach(catalogue.locations.sorted { $0.rank < $1.rank }) { spot in
                            NavigationLink(value: GuideDestination.base(spot.id)) {
                                SquareGuideTile(title: "\(spot.rank) · " + spot.name, subtitle: spot.tag, gps: spot.coordinates) {
                                    BaseTerrainPreview(spot: spot)
                                }
                            }.buttonStyle(.plain).accessibilityIdentifier("base-" + spot.id)
                        }
                    }
                } else { Text("Map này chưa có bộ vị trí base được nghiên cứu.") }
            }.padding(24).frame(maxWidth: 1100).frame(maxWidth: .infinity)
        }.background(Color(red: 0.025, green: 0.045, blue: 0.065))
    }
}
struct BaseTerrainPreview: View {
    let spot: BaseSpot
    private var terrain: UIImage? {
        guard let cg = UIImage(named: "RagnarokMap")?.cgImage else { return nil }
        let size = CGFloat(cg.width) * 0.18
        let x = min(max(0, CGFloat(spot.lon / 100) * CGFloat(cg.width) - size / 2), CGFloat(cg.width) - size)
        let y = min(max(0, CGFloat(spot.lat / 100) * CGFloat(cg.height) - size / 2), CGFloat(cg.height) - size)
        guard let crop = cg.cropping(to: CGRect(x: x, y: y, width: size, height: size)) else { return nil }
        return UIImage(cgImage: crop)
    }
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottomLeading) {
                if let terrain { Image(uiImage: terrain).resizable().scaledToFill().frame(width: proxy.size.width, height: proxy.size.height).clipped() }
                else { Image("RagnarokMap").resizable().scaledToFill().frame(width: proxy.size.width, height: proxy.size.height).clipped() }
                LinearGradient(colors: [.clear, .black.opacity(0.8)], startPoint: .center, endPoint: .bottom)
            }.frame(width: proxy.size.width, height: proxy.size.height).clipped()
        }
    }
}
struct BaseLocationDetail: View {
    let spot: BaseSpot
    @Environment(\.arkMap) private var map
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Text(spot.name).font(.largeTitle.bold())
                Text(spot.tag).foregroundStyle(.cyan)
                BaseTerrainPreview(spot: spot).frame(height: 250).clipShape(RoundedRectangle(cornerRadius: 20))
                GPSBadge(coordinates: spot.coordinates).font(.title2.bold()).monospacedDigit().foregroundStyle(.orange)
                HStack {
                    NavigationLink(value: GuideDestination.map("base-" + spot.id)) { Label("Xem trên bản đồ", systemImage: "map.fill") }.labelStyle(.iconOnly).accessibilityLabel("Xem trên bản đồ").accessibilityIdentifier("show-base-" + spot.id)
                    Link(destination: spot.videoURL) { Label("YouTube · " + spot.timestamp, systemImage: "play.rectangle.fill") }.labelStyle(.iconOnly).accessibilityLabel("Xem video").accessibilityIdentifier("baseVideo")
                }.buttonStyle(.bordered)
                VisualBrief(text: spot.why).cardStyle()
                block("Điểm mạnh", spot.pros)
                block("Đánh đổi & nguy hiểm", spot.cons)
                block("Bố trí base & chuẩn bị", spot.layout)
                GuideChecklist(title: "Trước khi chuyển main base", items: ["Khảo sát GPS, spawn nguy hiểm và quyền build", "Thử đường vận chuyển Dino lớn / Argy", "Kiểm tra nước, sân breed và tuyến farm", "Đặt giường / kho dự phòng trước", "Giữ nguồn resource và cửa hang thông thoáng"], key: "base-" + spot.id)
            }.padding(24).frame(maxWidth: 1000).frame(maxWidth: .infinity)
        }.navigationTitle(spot.name).navigationBarTitleDisplayMode(.inline)
    }
    private func block(_ title: String, _ items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) { Text(title).font(.title2.bold()); ForEach(items, id: \.self) { VisualBrief(text: $0) } }.cardStyle()
    }
}
