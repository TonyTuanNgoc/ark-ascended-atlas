import SwiftUI
import WebKit

struct CaveGIFGuide: Decodable, Identifiable {
    let routeID: String
    let sections: [CaveGIFSection]
    var id: String { routeID }
}

struct CaveGIFSection: Decodable, Identifiable {
    let id: String
    let title: String
    let steps: [CaveGIFStep]
}

struct CaveGIFStep: Decodable, Identifiable {
    let id: String
    let title: String
    let gif: String
    let poster: String
    let direction: String?

    var gifURL: URL? { Bundle.main.url(forResource: gif, withExtension: "gif") }
    var posterImage: UIImage? {
        guard let url = Bundle.main.url(forResource: poster, withExtension: "jpg") else { return nil }
        return UIImage(contentsOfFile: url.path)
    }
}

extension ArkMap {
    var caveGIFs: [CaveGIFGuide] { Self.gifGuides[self] ?? [] }
    private static let gifGuides = Dictionary(uniqueKeysWithValues: allCases.map {
        ($0, (try? load([CaveGIFGuide].self, name: $0.rawValue + "-cave-gifs")) ?? [])
    })
}

struct CaveGIFWalkthrough: View {
    let guide: CaveGIFGuide
    @State private var playingID: String?

    var body: some View {
        LazyVStack(alignment: .leading, spacing: 20) {
            Label("Đi từng đoạn", systemImage: "point.topleft.down.to.point.bottomright.curvepath")
                .font(.title2.bold())
            ForEach(guide.sections) { section in
                Text(section.title).font(.title3.bold())
                ForEach(Array(section.steps.enumerated()), id: \.element.id) { index, step in
                    VStack(alignment: .leading, spacing: 10) {
                        Text("\(index + 1) · \(step.title)").font(.headline)
                        Button {
                            playingID = playingID == step.id ? nil : step.id
                        } label: {
                            ZStack {
                                if playingID == step.id, let url = step.gifURL {
                                    LocalCaveGIF(url: url)
                                } else if let poster = step.posterImage {
                                    Image(uiImage: poster).resizable().scaledToFit()
                                }
                                if playingID == step.id {
                                    VStack {
                                        Spacer()
                                        HStack {
                                            Spacer()
                                            Image(systemName: "pause.circle.fill")
                                                .font(.system(size: 28)).padding(10)
                                        }
                                    }.foregroundStyle(.white).shadow(color: .black, radius: 5)
                                } else {
                                    Image(systemName: "play.circle.fill")
                                        .font(.system(size: 46)).foregroundStyle(.white)
                                        .shadow(color: .black, radius: 5)
                                }
                            }
                            .aspectRatio(16 / 9, contentMode: .fit)
                            .frame(maxWidth: 640)
                            .background(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel((playingID == step.id ? "Dừng · " : "Xem · ") + step.title)
                        .accessibilityValue(playingID == step.id ? "Đang phát" : "Đã dừng")
                        .accessibilityIdentifier("cave-gif-\(guide.routeID)-\(step.id)")
                        if let direction = step.direction, !direction.isEmpty {
                            Text(direction).font(.body).foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                                .textSelection(.enabled)
                                .accessibilityIdentifier("cave-direction-\(step.id)")
                        }
                    }
                    .onDisappear { if playingID == step.id { playingID = nil } }
                }
            }
        }
        .cardStyle()
        .onDisappear { playingID = nil }
    }
}

private struct LocalCaveGIF: UIViewRepresentable {
    let url: URL
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .nonPersistent()
        let view = WKWebView(frame: .zero, configuration: configuration)
        view.isOpaque = false
        view.backgroundColor = .black
        view.scrollView.isScrollEnabled = false
        view.isUserInteractionEnabled = false
        if let data = try? Data(contentsOf: url) {
            // One active clip; no source video, audio, network request or decoded UIImage frame array.
            let html = """
            <html><head><meta name="viewport" content="width=device-width, initial-scale=1"></head>
            <body style="margin:0;background:#000;overflow:hidden"><img alt="" style="width:100%;height:100%;object-fit:contain" src="data:image/gif;base64,\(data.base64EncodedString())"></body></html>
            """
            view.loadHTMLString(html, baseURL: nil)
        }
        return view
    }
    func updateUIView(_ view: WKWebView, context: Context) {}
    static func dismantleUIView(_ view: WKWebView, coordinator: ()) {
        view.stopLoading()
        view.loadHTMLString("", baseURL: nil)
    }
}
