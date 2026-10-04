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
    @Environment(\.scenePhase) private var scenePhase
    @State private var selectedSectionID: String?
    @State private var selectedIndex = 0
    @State private var isVisible = false

    private var section: CaveGIFSection? {
        guide.sections.first(where: { $0.id == selectedSectionID }) ?? guide.sections.first
    }

    var body: some View {
        if let section, !section.steps.isEmpty {
            let index = min(selectedIndex, section.steps.count - 1)
            let step = section.steps[index]
            VStack(alignment: .leading, spacing: 16) {
                Label("Đi từng đoạn", systemImage: "point.topleft.down.to.point.bottomright.curvepath")
                    .font(.title2.bold())
                if guide.sections.count > 1 {
                    Menu {
                        ForEach(guide.sections) { option in
                            Button(option.title) {
                                selectedIndex = 0
                                selectedSectionID = option.id
                            }.accessibilityIdentifier("gif-section-option-" + option.id)
                        }
                    } label: {
                        HStack {
                            Text(section.title).font(.headline)
                            Image(systemName: "chevron.down")
                        }
                    }.accessibilityIdentifier("gif-section-selector")
                } else {
                    Text(section.title).font(.headline)
                }
                HStack(spacing: 16) {
                    Button { withAnimation { selectedIndex = index - 1 } } label: {
                        Image(systemName: "chevron.left").frame(width: 40, height: 40)
                    }.disabled(index == 0).accessibilityLabel("Đoạn trước")
                        .accessibilityIdentifier("gif-previous-" + guide.routeID)
                    Text("\(index + 1) / \(section.steps.count)").monospacedDigit()
                        .accessibilityIdentifier("gif-position-" + guide.routeID)
                    Button { withAnimation { selectedIndex = index + 1 } } label: {
                        Image(systemName: "chevron.right").frame(width: 40, height: 40)
                    }.disabled(index == section.steps.count - 1).accessibilityLabel("Đoạn tiếp theo")
                        .accessibilityIdentifier("gif-next-" + guide.routeID)
                    Spacer()
                }.buttonStyle(.plain)
                Text(step.title).font(.headline)
                GeometryReader { geometry in
                    TabView(selection: $selectedIndex) {
                        ForEach(Array(section.steps.enumerated()), id: \.element.id) { page, item in
                            ZStack {
                                if page == index && isVisible && scenePhase == .active, let url = item.gifURL {
                                    AutoCaveGIF(step: item, url: url).id(item.gif)
                                } else if let poster = item.posterImage {
                                    Image(uiImage: poster).resizable().scaledToFit()
                                }
                            }
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .background(.black)
                            .accessibilityElement(children: .ignore)
                            .accessibilityLabel(item.title)
                            .accessibilityValue(page == index && isVisible && scenePhase == .active ? "Đang phát" : "Chưa chọn")
                            .accessibilityIdentifier("cave-gif-\(guide.routeID)-\(item.id)")
                            .tag(page)
                        }
                    }.tabViewStyle(.page(indexDisplayMode: .never))
                }
                .aspectRatio(16 / 9, contentMode: .fit)
                .frame(maxWidth: 640)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                // Carry the relevant phase instruction through its continuation clips.
                if let direction = section.steps.prefix(index + 1).reversed().compactMap(\.direction).first,
                   !direction.isEmpty {
                    Text(direction).font(.body).foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .textSelection(.enabled)
                        .accessibilityIdentifier("cave-direction-" + step.id)
                }
                ScrollViewReader { proxy in
                    ScrollView(.horizontal) {
                        LazyHStack(spacing: 12) {
                            ForEach(Array(section.steps.enumerated()), id: \.element.id) { card, item in
                                Button { withAnimation { selectedIndex = card } } label: {
                                    VStack(alignment: .leading, spacing: 8) {
                                        ZStack(alignment: .topLeading) {
                                            if let poster = item.posterImage {
                                                Image(uiImage: poster).resizable().scaledToFill()
                                                    .frame(width: 140, height: 79).clipped()
                                            }
                                            Text("\(card + 1)").font(.caption.bold())
                                                .padding(5).background(.black.opacity(0.75), in: RoundedRectangle(cornerRadius: 4))
                                                .padding(4)
                                        }.clipShape(RoundedRectangle(cornerRadius: 5))
                                        Text(item.title).font(.caption).lineLimit(2)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        Spacer(minLength: 0)
                                    }
                                    .padding(8).frame(width: 156, height: 156)
                                    .foregroundStyle(.white)
                                    .background(card == index ? Color.cyan.opacity(0.12) : Color.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 8))
                                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(card == index ? Color.cyan : Color.clear, lineWidth: 2))
                                    .contentShape(Rectangle())
                                }.buttonStyle(.plain)
                                    .accessibilityLabel("\(card + 1) · " + item.title)
                                    .accessibilityValue(card == index ? "Đang chọn" : "Chưa chọn")
                                    .accessibilityIdentifier("gif-card-\(guide.routeID)-\(item.id)")
                                    .id(card)
                            }
                        }.padding(2)
                    }.scrollIndicators(.hidden)
                        .onChange(of: selectedIndex) { _, value in
                            withAnimation { proxy.scrollTo(value, anchor: .center) }
                        }
                        .onChange(of: selectedSectionID) { _, _ in proxy.scrollTo(0, anchor: .leading) }
                }
                .id(section.id)
            }
            .cardStyle()
            .onAppear { isVisible = true }
            .onDisappear { isVisible = false }
        }
    }
}

private struct AutoCaveGIF: View {
    let step: CaveGIFStep
    let url: URL
    @State private var isReady = false

    var body: some View {
        ZStack {
            if let poster = step.posterImage {
                Image(uiImage: poster).resizable().scaledToFit()
            }
            LocalCaveGIF(url: url) { isReady = true }
                .opacity(isReady ? 1 : 0)
        }
    }
}

private struct LocalCaveGIF: UIViewRepresentable {
    let url: URL
    let onReady: () -> Void

    final class Coordinator: NSObject, WKNavigationDelegate {
        let onReady: () -> Void
        init(onReady: @escaping () -> Void) { self.onReady = onReady }
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) { onReady() }
    }
    func makeCoordinator() -> Coordinator { Coordinator(onReady: onReady) }
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .nonPersistent()
        let view = WKWebView(frame: .zero, configuration: configuration)
        view.navigationDelegate = context.coordinator
        view.isOpaque = false
        view.backgroundColor = .clear
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
    static func dismantleUIView(_ view: WKWebView, coordinator: Coordinator) {
        view.navigationDelegate = nil
        view.stopLoading()
        view.loadHTMLString("", baseURL: nil)
    }
}
