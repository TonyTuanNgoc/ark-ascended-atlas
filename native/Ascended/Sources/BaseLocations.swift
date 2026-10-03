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
                Text(map.name + " · 5 lựa chọn cho Single Player").foregroundStyle(.cyan)
                if let catalogue = map.bases {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Xếp theo độ cân bằng cho Single Player. Like/vote nguồn nằm trong từng hồ sơ; thứ tự không phải bảng bình chọn.").foregroundStyle(.secondary)
                        DisclosureGroup("Cách chọn & tín hiệu cộng đồng") { Text(catalogue.methodology).font(.subheadline).padding(.top, 8) }
                    }.cardStyle()
                    ForEach(catalogue.locations.sorted { $0.rank < $1.rank }) { spot in
                        NavigationLink(value: GuideDestination.base(spot.id)) {
                            VStack(alignment: .leading, spacing: 14) {
                                BaseTerrainPreview(spot: spot).frame(height: 180).clipShape(RoundedRectangle(cornerRadius: 16))
                                HStack { Text("\(spot.rank) · " + spot.name).font(.title2.bold()); Spacer(); Image(systemName: "chevron.right") }
                                Text(spot.tag).foregroundStyle(.cyan)
                                Text(spot.coordinates).monospacedDigit().foregroundStyle(.secondary)
                            }.cardStyle().contentShape(Rectangle())
                        }.buttonStyle(.plain).accessibilityIdentifier("base-" + spot.id)
                    }
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Video đã đối chiếu").font(.title2.bold())
                        Text("Like / view của cả video, không phải vote cho từng điểm. Snapshot 03/10/2026.").font(.caption).foregroundStyle(.secondary)
                        ForEach(catalogue.videos) { video in
                            VStack(alignment: .leading, spacing: 8) {
                                Link(video.title, destination: URL(string: video.url)!)
                                Text(video.channel + " · \(video.likes.formatted()) like · \(video.views.formatted()) view").font(.subheadline).foregroundStyle(.cyan)
                            }
                        }
                    }.cardStyle()
                    Text(catalogue.limits).font(.caption).foregroundStyle(.secondary).cardStyle()
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
                Label("Địa hình vùng GPS · không phải ảnh base", systemImage: "map.fill").font(.caption.bold()).padding(12).foregroundStyle(.white).accessibilityIdentifier("basePreview-caption-" + spot.id)
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
                Text(spot.coordinates).font(.title2.bold()).monospacedDigit().foregroundStyle(.orange)
                HStack {
                    NavigationLink(value: GuideDestination.map("base-" + spot.id)) { Label("Xem trên bản đồ", systemImage: "map.fill") }.accessibilityIdentifier("show-base-" + spot.id)
                    Link(destination: spot.videoURL) { Label("YouTube · " + spot.timestamp, systemImage: "play.rectangle.fill") }.accessibilityIdentifier("baseVideo")
                }.buttonStyle(.bordered)
                Text(spot.why).font(.headline).cardStyle()
                block("Điểm mạnh", spot.pros)
                block("Đánh đổi & nguy hiểm", spot.cons)
                block("Bố trí base & chuẩn bị", spot.layout)
                VStack(alignment: .leading, spacing: 14) {
                    Text("Tín hiệu cộng đồng").font(.title2.bold()); Text(spot.support)
                    if let video = map.bases?.videos.first(where: { $0.id == spot.videoID }) {
                        Text(video.channel + " · \(video.likes.formatted()) like / \(video.views.formatted()) view cho cả video").foregroundStyle(.cyan)
                        AsyncImage(url: URL(string: video.thumbnailURL)) { image in image.resizable().scaledToFit() } placeholder: { Label("Thumbnail video · cần mạng", systemImage: "play.rectangle") }.frame(maxHeight: 220).clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    Text("Rank là đánh giá cân bằng do em tổng hợp. GPS chỉ điểm khảo sát, chưa phải nền đã test xây. Bấm video để xem creator ở chương liên quan.").font(.caption).foregroundStyle(.secondary)
                }.cardStyle()
                EvidenceLinks(sources: spot.sources)
                GuideChecklist(title: "Trước khi chuyển main base", items: ["Khảo sát GPS, spawn nguy hiểm và quyền build", "Thử đường vận chuyển Dino lớn / Argy", "Kiểm tra nước, sân breed và tuyến farm", "Đặt giường / kho dự phòng trước", "Giữ nguồn resource và cửa hang thông thoáng"], key: "base-" + spot.id)
            }.padding(24).frame(maxWidth: 1000).frame(maxWidth: .infinity)
        }.navigationTitle(spot.name).navigationBarTitleDisplayMode(.inline)
    }
    private func block(_ title: String, _ items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) { Text(title).font(.title2.bold()); ForEach(items, id: \.self) { Text($0).foregroundStyle(.secondary) } }.cardStyle()
    }
}
