import SwiftUI
import UIKit

struct MapScreen: View {
    @Environment(\.arkMap) private var map
    var initialFocus: String? = nil
    @State private var visibleLayers: Set<MapLayer> = Set(MapLayer.allCases.filter { $0 != .resource })
    @State private var resourceTypes: Set<String> = []
    private var allPoints: [MapLocation] { MapLocation.all(in: map) }
    private var availableLayers: [MapLayer] { MapLayer.allCases.filter { $0 != .base || map.bases != nil } }
    @State private var selected: MapLocation?
    @State private var focusedID: String?
    @State private var resetToken = UUID()
    @State private var action: MapAction = .fit
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
        ZoomableMap(imageAsset: map.imageAsset, mapName: map.name, resetToken: resetToken, action: action, locations: allPoints.filter { visibleLayers.contains($0.layer) && ($0.layer != .resource || resourceTypes.contains($0.name)) }, focusID: focusedID, select: { selected = $0; focusedID = $0.id })
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(alignment: .bottomTrailing) {
                if let point = selected {
                    HStack(alignment: .top, spacing: 12) {
                        if let asset = point.imageAsset, UIImage(named: asset) != nil {
                            Image(asset).renderingMode(asset == "Map-Obelisk" ? .template : .original).resizable().scaledToFit().foregroundStyle(Color(uiColor: point.color)).frame(width: 54, height: 64)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text(point.layer == .resource ? MapResources.label(for: point.name) : point.name).font(.headline).accessibilityIdentifier("selectedMapLocation")
                            GPSBadge(coordinates: point.coordinates).foregroundStyle(.cyan).monospacedDigit()
                            Text(point.layer == .artifact ? "Lấy tại tọa độ này. " + (map.exploration?.routes.first { $0.id == point.routeID }?.name ?? "") : point.note)
                                .font(.caption).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
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
                        .frame(maxWidth: 430).background(.black.opacity(0.94), in: RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.16)))
                        .padding(12)
                }
            }
            controls.frame(width: 134)
        }.padding(8)
        .onAppear {
            resourceTypes = Set(MapResources.nodes(in: map).map(\.resource_type))
            if let id = initialFocus, let point = MapLocation.all(in: map).first(where: { $0.id == id }) {
                selected = point; focusedID = id; visibleLayers.insert(point.layer)
            }
        }
    }

    private var controls: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 4) {
                    Button { visibleLayers = Set(availableLayers); resourceTypes = Set(MapResources.nodes(in: map).map(\.resource_type)) } label: { Image(systemName: "checkmark.circle.fill").frame(width: 54, height: 38) }
                        .accessibilityLabel("Chọn tất cả").accessibilityIdentifier("selectAllMapLayers")
                    Button { visibleLayers.removeAll(); selected = nil; focusedID = nil } label: { Image(systemName: "circle").frame(width: 54, height: 38) }
                        .accessibilityLabel("Bỏ chọn tất cả").accessibilityIdentifier("clearMapLayers")
                }
                ForEach(availableLayers, id: \.self) { layer in
                    Button {
                        if visibleLayers.contains(layer) { visibleLayers.remove(layer) } else { visibleLayers.insert(layer) }
                        if selected?.layer == layer && !visibleLayers.contains(layer) { selected = nil; focusedID = nil }
                    } label: {
                        HStack(spacing: 7) {
                            Image(systemName: layer.symbol).frame(width: 22)
                            Text(layer.rawValue).font(.caption.bold())
                            Spacer(minLength: 0)
                        }.padding(.horizontal, 8).frame(height: 40)
                            .background(visibleLayers.contains(layer) ? Color.cyan.opacity(0.16) : Color.clear, in: RoundedRectangle(cornerRadius: 8))
                    }.tint(visibleLayers.contains(layer) ? .cyan : .gray)
                        .accessibilityLabel(layer.rawValue).accessibilityIdentifier("layer-" + layer.rawValue)
                        .accessibilityValue(visibleLayers.contains(layer) ? "Hiện" : "Ẩn")
                }
                if visibleLayers.contains(.resource) {
                    ForEach(MapResources.types(in: map), id: \.self) { type in
                        Button {
                            if resourceTypes.contains(type) { resourceTypes.remove(type) } else { resourceTypes.insert(type) }
                        } label: {
                            HStack(spacing: 5) {
                                Image(MapResources.asset(for: type)).resizable().scaledToFit().frame(width: 24, height: 24)
                                Text(MapResources.label(for: type)).font(.system(size: 10, weight: .medium)).multilineTextAlignment(.leading)
                                Spacer(minLength: 0)
                            }.padding(5).frame(minHeight: 34)
                                .background(resourceTypes.contains(type) ? Color.cyan.opacity(0.13) : Color.clear, in: RoundedRectangle(cornerRadius: 6))
                        }.tint(resourceTypes.contains(type) ? .white : .gray).accessibilityIdentifier("resource-" + type)
                            .accessibilityValue(resourceTypes.contains(type) ? "Hiện" : "Ẩn")
                    }
                }
                Divider()
                Menu {
                    ForEach(allPoints.filter { $0.layer != .resource }) { point in
                        Button(point.name) { visibleLayers.insert(point.layer); selected = point; focusedID = point.id }
                    }
                } label: { Label("Tìm vị trí", systemImage: "magnifyingglass").font(.caption).frame(height: 38) }
                    .accessibilityIdentifier("findMapLocation")
                HStack(spacing: 0) {
                    Button { action = .out; resetToken = UUID() } label: { Image(systemName: "minus").frame(width: 38, height: 38) }.accessibilityLabel("Thu nhỏ").accessibilityIdentifier("zoomOut")
                    Button { action = .inside; resetToken = UUID() } label: { Image(systemName: "plus").frame(width: 38, height: 38) }.accessibilityLabel("Phóng to").accessibilityIdentifier("zoomIn")
                    Button { focusedID = nil; action = .fit; resetToken = UUID() } label: { Image(systemName: "arrow.counterclockwise").frame(width: 38, height: 38) }.accessibilityLabel("Căn giữa bản đồ").accessibilityIdentifier("resetMap")
                }
            }.padding(8)
        }.accessibilityIdentifier("mapFilterRail").buttonStyle(.plain).background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
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
        func scrollViewDidScroll(_ scrollView: UIScrollView) { (scrollView as? MapScrollView)?.refreshResources() }
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
    private let resourceSurface = ResourceSurface()
    private var resources: [MapLocation] = []
    var focusID: String?
    private var locationIDs: [String] = []
    private var locations: [MapLocation] = []
    private var markerButtons: [UIButton] = []
    private var markerLabels: [UILabel] = []
    private var select: ((MapLocation) -> Void)?
    private var menuMemberships: [String: [String]] = [:]
    func updateLocations(_ points: [MapLocation], select: @escaping (MapLocation) -> Void) {
        self.select = select
        resourceSurface.choose = select
        resources = points.filter { $0.layer == .resource }
        resourceSurface.points = resources
        if resourceSurface.superview == nil { addSubview(resourceSurface) }
        let points = points.filter { $0.layer != .resource }
        guard locationIDs != points.map(\.id) else { refreshResources(); return }
        markerButtons.forEach { $0.removeFromSuperview() }; markerButtons.removeAll()
        markerLabels.forEach { $0.removeFromSuperview() }; markerLabels.removeAll()
        locations = points; locationIDs = points.map(\.id); menuMemberships.removeAll()
        for point in points {
            let button = UIButton(type: .system)
            button.bounds = CGRect(x: 0, y: 0, width: 36, height: 36)
            let artwork = point.imageAsset.flatMap { UIImage(named: $0) }
            button.setImage(artwork?.withRenderingMode(point.imageAsset == "Map-Obelisk" ? .alwaysTemplate : .alwaysOriginal) ?? UIImage(systemName: point.symbol), for: .normal)
            button.imageView?.contentMode = .scaleAspectFit
            if point.layer == .cave, let artwork, point.imageAsset?.hasPrefix("Entrance-") == true {
                button.setImage(nil, for: .normal)
                let photo = UIImageView(image: artwork)
                photo.frame = button.bounds; photo.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                photo.contentMode = .scaleAspectFill; photo.clipsToBounds = true
                button.addSubview(photo)
            }
            button.contentEdgeInsets = point.layer == .cave ? .zero : UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
            button.tintColor = point.imageAsset == "Map-Obelisk" ? point.color : .white; button.backgroundColor = artwork != nil ? UIColor.black.withAlphaComponent(0.8) : point.color
            button.layer.cornerRadius = 18; button.clipsToBounds = true; button.layer.borderWidth = 2; button.layer.borderColor = UIColor.white.cgColor
            button.accessibilityIdentifier = "pin-" + point.id
            button.accessibilityLabel = point.name + ", " + point.coordinates

            imageView.addSubview(button); markerButtons.append(button)
            let label = UILabel()
            let shortName = point.name.components(separatedBy: " · ").first ?? point.name
            label.attributedText = NSAttributedString(string: shortName.replacingOccurrences(of: "Artifact of the ", with: ""), attributes: [.font: UIFont.systemFont(ofSize: 10, weight: .semibold), .foregroundColor: UIColor.white, .strokeColor: UIColor.black, .strokeWidth: -3.0])
            label.backgroundColor = .clear
            label.textAlignment = .center; label.numberOfLines = 2
            label.clipsToBounds = false
            label.bounds = CGRect(x: 0, y: 0, width: 110, height: 28)
            label.isAccessibilityElement = false; label.isUserInteractionEnabled = false
            imageView.addSubview(label); markerLabels.append(label)
        }
        centerMap()
    }
    func focusMap(animated: Bool) {
        guard bounds.width > 0, bounds.height > 0, let point = (locations + resources).first(where: { $0.id == focusID }) else { return }
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
        var labelFrames: [CGRect] = []
        for (index, button) in markerButtons.enumerated() {
            button.center = pixelPoint(locations[index])
            button.transform = CGAffineTransform(scaleX: 1 / max(zoomScale, 0.001), y: 1 / max(zoomScale, 0.001))
            let label = markerLabels[index]
            label.center = CGPoint(x: button.center.x, y: button.center.y + 34 / max(zoomScale, 0.001))
            label.transform = button.transform
            let labelFrame = imageView.convert(label.frame, to: self)
            label.isHidden = labelFrames.contains { $0.intersects(labelFrame.insetBy(dx: -3, dy: -2)) }
            if !label.isHidden { labelFrames.append(labelFrame) }
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
                        UIAction(title: item.name, image: item.imageAsset.flatMap { UIImage(named: $0) } ?? UIImage(systemName: item.symbol)) { [weak self] _ in self?.select?(item) }
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
        refreshResources()
        if minimumZoomScale > 0 { accessibilityValue = String(format: "%.2f", zoomScale / minimumZoomScale) }
    }
    func refreshResources() {
        guard bounds.width > 0 else { return }
        bringSubviewToFront(resourceSurface)
        let markers = locations.map { point in
            let pixel = imageView.convert(pixelPoint(point), to: self)
            return CGPoint(x: pixel.x - bounds.minX, y: pixel.y - bounds.minY)
        }
        resourceSurface.refresh(on: self, avoiding: markers)
    }

}
