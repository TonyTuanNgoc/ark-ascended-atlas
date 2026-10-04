import SwiftUI
import UIKit

struct MapScreen: View {
    @Environment(\.arkMap) private var map
    var initialFocus: String? = nil
    @State private var visibleLayers: Set<MapLayer> = Set(MapLayer.allCases)
    @State private var selected: MapLocation?
    @State private var focusedID: String?
    @State private var resetToken = UUID()
    @State private var action: MapAction = .fit
    var body: some View {
        ZoomableMap(imageAsset: map.imageAsset, mapName: map.name, resetToken: resetToken, action: action, locations: MapLocation.all(in: map).filter { visibleLayers.contains($0.layer) }, focusID: focusedID, select: { selected = $0; focusedID = $0.id })
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(alignment: .top) {
                HStack(alignment: .top, spacing: 12) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 4) {
                            ForEach(MapLayer.allCases.filter { $0 != .base || map.bases != nil }, id: \.self) { layer in
                                Button {
                                    if visibleLayers.contains(layer) { visibleLayers.remove(layer) } else { visibleLayers.insert(layer) }
                                    if selected?.layer == layer && !visibleLayers.contains(layer) { selected = nil; focusedID = nil }
                                } label: {
                                    Image(systemName: layer == .artifact ? "diamond.fill" : layer == .cave ? "mountain.2.fill" : layer == .base ? "house.fill" : "shield.lefthalf.filled")
                                        .frame(width: 42, height: 42)
                                }.accessibilityLabel(layer.rawValue)
                                    .tint(visibleLayers.contains(layer) ? .cyan : .gray)
                                    .accessibilityIdentifier("layer-" + layer.rawValue)
                            }
                            Menu {
                                ForEach(MapLocation.all(in: map)) { point in
                                    Button(point.name) { visibleLayers.insert(point.layer); selected = point; focusedID = point.id }
                                }
                            } label: { Image(systemName: "magnifyingglass").frame(width: 42, height: 42) }
                                .accessibilityLabel("Tìm vị trí").accessibilityIdentifier("findMapLocation")
                        }.padding(4)
                    }.fixedSize(horizontal: true, vertical: false)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                    Spacer(minLength: 0)
                    HStack(spacing: 0) {
                        Button { action = .out; resetToken = UUID() } label: { Image(systemName: "minus").frame(width: 42, height: 42) }
                            .accessibilityLabel("Thu nhỏ").accessibilityIdentifier("zoomOut")
                        Button { action = .inside; resetToken = UUID() } label: { Image(systemName: "plus").frame(width: 42, height: 42) }
                            .accessibilityLabel("Phóng to").accessibilityIdentifier("zoomIn")
                        Button { focusedID = nil; action = .fit; resetToken = UUID() } label: { Image(systemName: "arrow.counterclockwise").frame(width: 42, height: 42) }
                            .accessibilityLabel("Căn giữa bản đồ").accessibilityIdentifier("resetMap")
                    }.padding(4).background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                }.buttonStyle(.plain).padding(12)
            }
            .safeAreaInset(edge: .bottom, spacing: 8) {
                if let point = selected {
                    HStack(spacing: 14) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(point.name).font(.headline).accessibilityIdentifier("selectedMapLocation")
                            GPSBadge(coordinates: point.coordinates).foregroundStyle(.cyan).monospacedDigit()
                        }
                        Spacer()
                        if let id = point.artifactID, map.exploration?.artifacts.contains(where: { $0.id == id }) == true {
                            NavigationLink(value: GuideDestination.artifact(id)) { Image(systemName: "diamond.fill") }.accessibilityLabel("Artifact")
                        } else if let id = point.routeID, map.exploration?.routes.contains(where: { $0.id == id }) == true {
                            NavigationLink(value: GuideDestination.cave(id)) { Image(systemName: "mountain.2.fill") }.accessibilityLabel("Hang")
                        }
                        if point.layer == .base, let spot = map.bases?.locations.first(where: { "base-" + $0.id == point.id }) {
                            NavigationLink(value: GuideDestination.base(spot.id)) { Image(systemName: "house.fill") }.accessibilityLabel("Hồ sơ base").accessibilityIdentifier("mapBaseProfile")
                        }
                        Button { selected = nil; focusedID = nil } label: { Image(systemName: "xmark") }.accessibilityLabel("Đóng vị trí")
                    }.buttonStyle(.bordered).padding(14)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                }
            }.padding(8)
        .onAppear {
            if let id = initialFocus, let point = MapLocation.all(in: map).first(where: { $0.id == id }) {
                selected = point; focusedID = id; visibleLayers.insert(point.layer)
            }
        }
    }
}

enum MapAction { case fit, inside, out }

struct ZoomableMap: UIViewRepresentable {
    let imageAsset: String
    let mapName: String
    let resetToken: UUID
    let action: MapAction
    let locations: [MapLocation]
    let focusID: String?
    let select: (MapLocation) -> Void
    func makeUIView(context: Context) -> MapScrollView {
        let view = MapScrollView()
        view.delegate = context.coordinator
        view.isAccessibilityElement = false
        view.accessibilityIdentifier = "ragnarokMapViewport"
        view.accessibilityLabel = "Bản đồ " + mapName
        view.minimumZoomScale = 0.01
        view.maximumZoomScale = 8
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.bouncesZoom = true
        view.backgroundColor = UIColor(red: 0.025, green: 0.045, blue: 0.065, alpha: 1)
        view.imageView.image = UIImage(named: imageAsset)
        view.imageView.frame = CGRect(origin: .zero, size: view.imageView.image?.size ?? CGSize(width: 2048, height: 2048))
        view.contentInsetAdjustmentBehavior = .never
        view.imageView.layer.minificationFilter = .trilinear
        view.imageView.layer.magnificationFilter = .linear
        view.imageView.layer.allowsEdgeAntialiasing = true
        view.imageView.contentMode = .scaleAspectFit
        view.imageView.isUserInteractionEnabled = true
        view.updateLocations(locations, select: select)
        view.focusID = focusID
        view.addSubview(view.imageView)
        view.contentSize = view.imageView.bounds.size
        let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.doubleTap(_:)))
        tap.numberOfTapsRequired = 2
        view.addGestureRecognizer(tap)
        context.coordinator.resetToken = resetToken
        return view
    }
    func updateUIView(_ uiView: MapScrollView, context: Context) {
        uiView.updateLocations(locations, select: select)
        if uiView.focusID != focusID {
            uiView.focusID = focusID
            uiView.focusMap(animated: true)
        }
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
    var focusID: String?
    private var locationIDs: [String] = []
    private var locations: [MapLocation] = []
    private var markerButtons: [UIButton] = []
    private var select: ((MapLocation) -> Void)?
    private var menuMemberships: [String: [String]] = [:]
    func updateLocations(_ points: [MapLocation], select: @escaping (MapLocation) -> Void) {
        self.select = select
        guard locationIDs != points.map(\.id) else { return }
        markerButtons.forEach { $0.removeFromSuperview() }; markerButtons.removeAll()
        locations = points; locationIDs = points.map(\.id); menuMemberships.removeAll()
        for point in points {
            let button = UIButton(type: .system)
            button.bounds = CGRect(x: 0, y: 0, width: 36, height: 36)
            button.setImage(UIImage(systemName: point.symbol), for: .normal)
            button.tintColor = .white; button.backgroundColor = point.color
            button.layer.cornerRadius = 18; button.layer.borderWidth = 2; button.layer.borderColor = UIColor.white.cgColor
            button.accessibilityIdentifier = "pin-" + point.id
            button.accessibilityLabel = point.name + ", " + point.coordinates

            imageView.addSubview(button); markerButtons.append(button)
        }
        centerMap()
    }
    func focusMap(animated: Bool) {
        guard bounds.width > 0, bounds.height > 0, let point = locations.first(where: { $0.id == focusID }) else { return }
        let scale = min(minimumZoomScale * 4, maximumZoomScale)
        let center = pixelPoint(point)
        let size = CGSize(width: bounds.width / scale, height: bounds.height / scale)
        zoom(to: CGRect(x: center.x - size.width / 2, y: center.y - size.height / 2, width: size.width, height: size.height), animated: animated)
    }
    private func pixelPoint(_ point: MapLocation) -> CGPoint {
        CGPoint(x: point.lon / 100 * imageView.bounds.width, y: point.lat / 100 * imageView.bounds.height)
    }
    private var lastSize = CGSize.zero
    override func layoutSubviews() {
        super.layoutSubviews()
        guard bounds.width > 0, bounds.height > 0, imageView.bounds.width > 0 else { return }
        if lastSize != bounds.size {
            lastSize = bounds.size
            fitMap(animated: false)
            focusMap(animated: false)
        }
        centerMap()
    }
    func fitMap(animated: Bool) {
        guard imageView.bounds.width > 0, bounds.width > 0, bounds.height > 0 else { return }
        let fit = max(bounds.width / imageView.bounds.width, bounds.height / imageView.bounds.height)
        minimumZoomScale = fit
        maximumZoomScale = fit * 8
        setZoomScale(fit, animated: animated)
        centerMap()
        let offset = CGPoint(x: max(0, (imageView.bounds.width * fit - bounds.width) / 2), y: max(0, (imageView.bounds.height * fit - bounds.height) / 2))
        setContentOffset(offset, animated: animated)
    }
    func centerMap() {
        for (index, button) in markerButtons.enumerated() {
            button.center = pixelPoint(locations[index])
            button.transform = CGAffineTransform(scaleX: 1 / max(zoomScale, 0.001), y: 1 / max(zoomScale, 0.001))
            let point = locations[index]
            let nearby = locations.filter {
                let deltaX = (pixelPoint($0).x - button.center.x) * zoomScale
                let deltaY = (pixelPoint($0).y - button.center.y) * zoomScale
                return hypot(deltaX, deltaY) < 40
            }
            if menuMemberships[point.id] != nearby.map(\.id) {
                menuMemberships[point.id] = nearby.map(\.id)
                let actionID = UIAction.Identifier("select-marker")
                button.removeAction(identifiedBy: actionID, for: .touchUpInside)
                if nearby.count > 1 {
                    button.menu = UIMenu(title: "Chọn vị trí gần nhau", children: nearby.map { item in
                        UIAction(title: item.name, image: UIImage(systemName: item.symbol)) { [weak self] _ in self?.select?(item) }
                    })
                    button.showsMenuAsPrimaryAction = true
                    button.accessibilityHint = "Mở danh sách vị trí gần nhau"
                } else {
                    button.menu = nil; button.showsMenuAsPrimaryAction = false
                    button.addAction(UIAction(identifier: actionID) { [weak self] _ in self?.select?(point) }, for: .touchUpInside)
                    button.accessibilityHint = "Mở thông tin vị trí"
                }
            }
        }
        let horizontal = max((bounds.width - imageView.frame.width) / 2, 0)
        let vertical = max((bounds.height - imageView.frame.height) / 2, 0)
        let desired = UIEdgeInsets(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
        if contentInset != desired { contentInset = desired }
        if minimumZoomScale > 0 { accessibilityValue = String(format: "%.2f", zoomScale / minimumZoomScale) }
    }
}
