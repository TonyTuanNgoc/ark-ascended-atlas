import SwiftUI
import UIKit

struct RagnarokMapScreen: View {
    @State private var resetToken = UUID()
    @State private var action: MapAction = .fit
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ragnarok Ascended").font(.title3.bold())
                    Text("8K · Bản đồ địa hình offline").font(.caption).foregroundStyle(.cyan)
                }
                Spacer()
                HStack(spacing: 8) {
                    Button { action = .out; resetToken = UUID() } label: { Image(systemName: "minus").frame(width: 28, height: 28) }
                        .accessibilityLabel("Thu nhỏ").accessibilityIdentifier("zoomOut")
                    Button { action = .inside; resetToken = UUID() } label: { Image(systemName: "plus").frame(width: 28, height: 28) }
                        .accessibilityLabel("Phóng to").accessibilityIdentifier("zoomIn")
                    Button { action = .fit; resetToken = UUID() } label: {
                        Image(systemName: "arrow.up.left.and.arrow.down.right").frame(width: 28, height: 28)
                    }.accessibilityLabel("Toàn bản đồ").accessibilityIdentifier("resetMap")
                }.buttonStyle(.bordered).buttonBorderShape(.circle)
            }.padding(16).background(.ultraThinMaterial)
            ZoomableMap(resetToken: resetToken, action: action)

            HStack {
                Label("Chụm để zoom · Kéo để di chuyển", systemImage: "hand.draw.fill")
                Spacer()
                Text("8192 × 8192 · Wikily")
            }.font(.caption).foregroundStyle(.secondary).padding(14)
        }.background(Color(red: 0.025, green: 0.045, blue: 0.065))
    }
}

enum MapAction { case fit, inside, out }

struct ZoomableMap: UIViewRepresentable {
    let resetToken: UUID
    let action: MapAction
    func makeUIView(context: Context) -> MapScrollView {
        let view = MapScrollView()
        view.delegate = context.coordinator
        view.isAccessibilityElement = true
        view.accessibilityIdentifier = "ragnarokMapViewport"
        view.accessibilityLabel = "Bản đồ Ragnarok"
        view.minimumZoomScale = 0.01
        view.maximumZoomScale = 8
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.bouncesZoom = true
        view.backgroundColor = UIColor(red: 0.025, green: 0.045, blue: 0.065, alpha: 1)
        view.imageView.image = UIImage(named: "RagnarokMap")
        view.imageView.frame = CGRect(origin: .zero, size: view.imageView.image?.size ?? CGSize(width: 2048, height: 2048))
        view.imageView.contentMode = .scaleAspectFit
        view.addSubview(view.imageView)
        view.contentSize = view.imageView.bounds.size
        let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.doubleTap(_:)))
        tap.numberOfTapsRequired = 2
        view.addGestureRecognizer(tap)
        context.coordinator.resetToken = resetToken
        return view
    }
    func updateUIView(_ uiView: MapScrollView, context: Context) {
        if context.coordinator.resetToken != resetToken {
            context.coordinator.resetToken = resetToken
            switch action {
            case .fit: uiView.fitMap(animated: true)
            case .inside: uiView.setZoomScale(min(uiView.zoomScale * 2, uiView.maximumZoomScale), animated: true)
            case .out: uiView.setZoomScale(max(uiView.zoomScale / 2, uiView.minimumZoomScale), animated: true)
            }
        }
    }
    func makeCoordinator() -> Coordinator { Coordinator() }
    final class Coordinator: NSObject, UIScrollViewDelegate {
        var resetToken: UUID?
        func viewForZooming(in scrollView: UIScrollView) -> UIView? { (scrollView as? MapScrollView)?.imageView }
        func scrollViewDidZoom(_ scrollView: UIScrollView) { (scrollView as? MapScrollView)?.centerMap() }
        @objc func doubleTap(_ gesture: UITapGestureRecognizer) {
            guard let scroll = gesture.view as? MapScrollView else { return }
            if scroll.zoomScale >= scroll.minimumZoomScale * 3.9 {
                scroll.fitMap(animated: true)
            } else {
                let scale = min(scroll.zoomScale * 2, scroll.maximumZoomScale)
                let point = gesture.location(in: scroll.imageView)
                let size = CGSize(width: scroll.bounds.width / scale, height: scroll.bounds.height / scale)
                scroll.zoom(to: CGRect(x: point.x - size.width / 2, y: point.y - size.height / 2, width: size.width, height: size.height), animated: true)
            }
        }
    }
}

final class MapScrollView: UIScrollView {
    let imageView = UIImageView()
    private var lastSize = CGSize.zero
    override func layoutSubviews() {
        super.layoutSubviews()
        guard bounds.width > 0, bounds.height > 0, imageView.bounds.width > 0 else { return }
        if lastSize != bounds.size {
            lastSize = bounds.size
            fitMap(animated: false)
        }
        centerMap()
    }
    func fitMap(animated: Bool) {
        guard imageView.bounds.width > 0, bounds.width > 0, bounds.height > 0 else { return }
        let fit = min(bounds.width / imageView.bounds.width, bounds.height / imageView.bounds.height)
        minimumZoomScale = fit
        maximumZoomScale = fit * 8
        setZoomScale(fit, animated: animated)
        centerMap()
    }
    func centerMap() {
        let horizontal = max((bounds.width - imageView.frame.width) / 2, 0)
        let vertical = max((bounds.height - imageView.frame.height) / 2, 0)
        let desired = UIEdgeInsets(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
        if contentInset != desired { contentInset = desired }
        if minimumZoomScale > 0 { accessibilityValue = String(format: "%.2f", zoomScale / minimumZoomScale) }
    }
}
