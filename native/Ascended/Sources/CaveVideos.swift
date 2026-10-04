import SwiftUI
import SafariServices

struct CaveVideoGuide: Decodable, Identifiable {
    let routeID: String
    let videoID: String
    let title: String
    let channel: String
    let chapters: [CaveVideoChapter]
    var id: String { routeID }
}
struct CaveVideoChapter: Decodable, Identifiable {
    let title: String
    let start: Int
    let end: Int
    var id: Int { start }
}
extension ArkMap {
    var caveVideos: [CaveVideoGuide] { Self.videoGuides[self] ?? [] }
    private static let videoGuides = Dictionary(uniqueKeysWithValues: allCases.map { ($0, (try? load([CaveVideoGuide].self, name: $0.rawValue + "-cave-videos")) ?? []) })
}
struct CaveVideoTimeline: View {
    let guide: CaveVideoGuide
    @State private var playing: VideoSelection?
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Route video", systemImage: "play.rectangle.fill").font(.title2.bold())
            ForEach(Array(guide.chapters.enumerated()), id: \.element.id) { index, chapter in
                Button {
                    playing = VideoSelection(url: URL(string: "https://www.youtube.com/watch?v=\(guide.videoID)&t=\(chapter.start)s")!)
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: "play.circle.fill").font(.title2).foregroundStyle(.cyan)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(index + 1) · " + chapter.title).font(.headline).foregroundStyle(.primary)
                            Text(String(format: "%d:%02d", chapter.start / 60, chapter.start % 60)).font(.caption).monospacedDigit().foregroundStyle(.secondary)
                        }
                        Spacer()
                    }.padding(12).background(.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 8))
                }.buttonStyle(.plain).accessibilityIdentifier("cave-video-\(guide.routeID)-\(chapter.start)")
            }
        }.cardStyle()
            .sheet(item: $playing) { selection in CaveVideoPlayer(url: selection.url).ignoresSafeArea() }
    }
}
private struct VideoSelection: Identifiable {
    let id = UUID()
    let url: URL
}
private struct CaveVideoPlayer: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> SFSafariViewController { SFSafariViewController(url: url) }
    func updateUIViewController(_ controller: SFSafariViewController, context: Context) {}
}
