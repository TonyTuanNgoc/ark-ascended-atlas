import SwiftUI
import UIKit

struct MapScreen: View {
    @Environment(\.arkMap) private var map
    var initialFocus: String? = nil
    var initialResources = false
    @State private var filters=MapFilterSelection()
    @State private var expandedLayers:Set<MapLayer>=[]
    @AppStorage("ascended.map.personal-locations.v1") private var personalJSON="[]"
    @State private var draft:PersonalMapLocation?
    private var personal:[PersonalMapLocation] {PersonalMapLocation.decode(personalJSON)}
    private var allPoints:[MapLocation] {MapLocation.all(in:map)+personal.filter {$0.map==map.rawValue}.map(\.point)}
    private var resourceTypes:[String] {MapResources.types(in:map)}
    private var availableLayers:[MapLayer] {MapLayer.allCases}
    @State private var selected: MapLocation?
    @State private var focusedID: String?
    @State private var resetToken = UUID()
    @State private var action: MapAction = .fit
    var body: some View {
        GeometryReader { geometry in
        HStack(alignment: .top, spacing: 8) {
        ZoomableMap(imageAsset: map.imageAsset, mapName: map.name, resetToken: resetToken, action: action, locations: allPoints.filter {filters.includes($0)}, focusID: focusedID, select: { selected = $0; focusedID = $0.id }, addLocation:{gps in draft=PersonalMapLocation(map:map.rawValue,name:"",lat:gps.lat,lon:gps.lon)})
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(alignment: .bottomTrailing) {
                if let point = selected {
                    if let farmID = point.farmID, let spot = ResourceFarmCatalog.spots(in: map).first(where: { $0.id == farmID }) {
                        VStack(alignment: .trailing, spacing: 4) {
                            Button { selected = nil; focusedID = nil } label: { Image(systemName: "xmark") }.accessibilityLabel("Close location")
                            ScrollView { FarmDetails(spot: spot) }.frame(maxHeight: 490)
                        }.padding(14).frame(maxWidth: 440).background(.black.opacity(0.94), in: RoundedRectangle(cornerRadius: 16)).padding(12)
                    } else {
                    HStack(alignment: .top, spacing: 12) {
                        if let asset = point.imageAsset, UIImage(named: asset) != nil {
                            Image(asset).renderingMode(asset == "Map-Obelisk" ? .template : .original).resizable().scaledToFit().foregroundStyle(Color(uiColor: point.color)).frame(width: 54, height: 64)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text(point.layer == .resource ? MapResources.label(for: point.name) : point.name).font(.headline).accessibilityIdentifier("selectedMapLocation")
                            GPSBadge(coordinates: point.coordinates).foregroundStyle(.cyan).monospacedDigit()
                            Text(point.layer == .artifact ? "Collect at these coordinates. " + (map.exploration?.routes.first { $0.id == point.routeID }?.name ?? "") : point.note)
                                .font(.caption).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer()
                        if point.layer == .custom,let saved=personal.first(where:{"custom-"+$0.id==point.id}) {
                            Button {draft=saved} label:{Image(systemName:"pencil")}.accessibilityLabel("Edit location")
                            Button {personalJSON=PersonalMapLocation.encode(personal.filter {$0.id != saved.id});filters.locations.remove(point.id);selected=nil;focusedID=nil} label:{Image(systemName:"trash")}.accessibilityLabel("Delete location").accessibilityIdentifier("deletePersonalLocation")
                        }
                        if let id = point.artifactID, map.exploration?.artifacts.contains(where: { $0.id == id }) == true {
                            NavigationLink(value: GuideDestination.artifact(id)) { Image(systemName: "diamond.fill") }.accessibilityLabel("Artifact")
                        } else if let id = point.routeID, map.exploration?.routes.contains(where: { $0.id == id }) == true {
                            NavigationLink(value: GuideDestination.cave(id)) { Image(systemName: "mountain.2.fill") }.accessibilityLabel("Cave")
                        }
                        if let id = point.bossID, map.bosses.contains(where: { $0.id == id }) {
                            NavigationLink(value: GuideDestination.boss(id)) { Image(systemName: "shield.lefthalf.filled") }.accessibilityLabel("Boss profile")
                        }
                        if point.layer == .base, let spot = map.bases?.locations.first(where: { "base-" + $0.id == point.id }) {
                            NavigationLink(value: GuideDestination.base(spot.id)) { Image(systemName: "house.fill") }.accessibilityLabel("Base profile").accessibilityIdentifier("mapBaseProfile")
                        }
                        Button { selected = nil; focusedID = nil } label: { Image(systemName: "xmark") }.accessibilityLabel("Close location")
                    }.buttonStyle(.bordered).padding(14)
                        .frame(maxWidth: 430).background(.black.opacity(0.94), in: RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.16)))
                        .padding(12)
                    }
                }
            }
            controls.frame(width: 240)
        }.padding(8)
        .onAppear {
            if initialResources {filters.resources=Set(resourceTypes)}
            if let id=initialFocus,let point=allPoints.first(where:{$0.id==id}) {
                if point.layer == .resource {filters.resources.formUnion(point.resourceNames)} else {filters.locations.insert(id)}
                selected=point;focusedID=id
            }
        }
        .sheet(item:$draft) {value in PersonalLocationEditor(location:value) {saved in
            var rows=personal;rows.removeAll {$0.id==saved.id};rows.append(saved)
            personalJSON=PersonalMapLocation.encode(rows);filters.locations.insert(saved.point.id);selected=saved.point;focusedID=saved.point.id
        }}
        }
    }

    private var controls:some View {
        ScrollView(.vertical,showsIndicators:false) {
            VStack(alignment:.leading,spacing:10) {
                ForEach(availableLayers,id:\.self) {layer in
                    let count=filters.selectedCount(layer,points:allPoints,types:resourceTypes)
                    let total=filters.total(layer,points:allPoints,types:resourceTypes)
                    VStack(alignment:.leading,spacing:5) {
                        HStack(spacing:5) {
                            Button {if expandedLayers.contains(layer) {expandedLayers.remove(layer)} else {expandedLayers.insert(layer)}} label:{
                                HStack(spacing:8) {
                                    Image(layer.illustration).resizable().scaledToFit().frame(width:36,height:38)
                                    Text(layer.title).font(.subheadline.bold()).multilineTextAlignment(.leading).fixedSize(horizontal:false,vertical:true)
                                    Spacer(minLength:0)
                                    Image(systemName:expandedLayers.contains(layer) ? "chevron.up":"chevron.down").font(.system(size:9,weight:.semibold))
                                }.frame(maxWidth:.infinity,alignment:.leading)
                            }.accessibilityIdentifier("expand-layer-"+layer.rawValue).accessibilityLabel("Show "+layer.title)
                            Button {filters.toggle(layer,points:allPoints,types:resourceTypes);if let point=selected,!filters.includes(point) {selected=nil;focusedID=nil}} label:{
                                Image(systemName:count==0 ? "square":count==total ? "checkmark.square.fill":"minus.square.fill").font(.title3).frame(width:32,height:42)
                            }.accessibilityLabel("Select "+layer.title).accessibilityIdentifier("layer-"+layer.rawValue).accessibilityValue(count==0 ? "Hidden":count==total ? "Visible":"Partially visible").disabled(total==0)
                        }.foregroundStyle(count>0 ? .cyan:.primary)
                        if expandedLayers.contains(layer) {
                            if layer == .resource {
                                ForEach(resourceTypes,id:\.self) {name in
                                    Button {filters.toggleResource(name);if let point=selected,!filters.includes(point) {selected=nil;focusedID=nil}} label:{
                                        HStack(spacing:8) {resourcePicture(name);Text(MapResources.label(for:name)).font(.caption).multilineTextAlignment(.leading);Spacer(minLength:0);Image(systemName:filters.resources.contains(name) ? "checkmark.square.fill":"square")}
                                            .padding(7).background(filters.resources.contains(name) ? Color.cyan.opacity(0.12):Color.white.opacity(0.035),in:RoundedRectangle(cornerRadius:8))
                                    }.accessibilityIdentifier("resource-"+name).accessibilityValue(filters.resources.contains(name) ? "Visible":"Hidden")
                                }
                            } else {
                                ForEach(allPoints.filter {$0.layer==layer}) {point in
                                    Button {filters.togglePoint(point.id);if !filters.locations.contains(point.id) && selected?.id==point.id {selected=nil;focusedID=nil}} label:{
                                        HStack(spacing:8) {pointPicture(point);Text(point.name.replacingOccurrences(of:"Artifact of the ",with:"" )).font(.caption).multilineTextAlignment(.leading).fixedSize(horizontal:false,vertical:true);Spacer(minLength:0);Image(systemName:filters.locations.contains(point.id) ? "checkmark.square.fill":"square")}
                                            .padding(7).background(filters.locations.contains(point.id) ? Color.cyan.opacity(0.12):Color.white.opacity(0.035),in:RoundedRectangle(cornerRadius:8))
                                    }.accessibilityIdentifier("location-filter-"+point.id).accessibilityValue(filters.locations.contains(point.id) ? "Visible":"Hidden")
                                }
                            }
                            if total==0 {Text(layer == .custom ? "Hold the map to add a location." : "No verified locations yet.").font(.caption).foregroundStyle(.secondary).padding(7)}
                        }
                    }.padding(8).background(count>0 ? Color.cyan.opacity(0.06):Color.white.opacity(0.03),in:RoundedRectangle(cornerRadius:12))
                }
                Divider()
                Menu {
                    ForEach(allPoints) {point in
                        Button(point.name) {if point.layer == .resource {filters.resources.formUnion(point.resourceNames)} else {filters.locations.insert(point.id)};selected=point;focusedID=point.id}.accessibilityIdentifier("find-"+point.id)
                    }
                } label:{Label("Find location",systemImage:"magnifyingglass").font(.caption).frame(height:38)}.accessibilityIdentifier("findMapLocation")
                HStack {Button {action = .out;resetToken=UUID()} label:{Image(systemName:"minus").frame(width:38,height:38)}.accessibilityLabel("Zoom out").accessibilityIdentifier("zoomOut");Button {action = .inside;resetToken=UUID()} label:{Image(systemName:"plus").frame(width:38,height:38)}.accessibilityLabel("Zoom in").accessibilityIdentifier("zoomIn");Button {focusedID=nil;action = .fit;resetToken=UUID()} label:{Image(systemName:"arrow.counterclockwise").frame(width:38,height:38)}.accessibilityLabel("Fit map").accessibilityIdentifier("resetMap")}
                Text("Hold to add your own location").font(.caption2).foregroundStyle(.secondary)
            }.padding(8)
        }.accessibilityIdentifier("mapFilterRail").buttonStyle(.plain).background(.ultraThinMaterial,in:RoundedRectangle(cornerRadius:16))
    }
    private func resourcePicture(_ name:String)->some View {
        Image(UIImage(named:MapResources.asset(for:name)) != nil ? MapResources.asset(for:name):MapLayer.resource.illustration).resizable().scaledToFit().frame(width:28,height:30)
    }
    @ViewBuilder private func pointPicture(_ point:MapLocation)->some View {
        if let asset=point.imageAsset,UIImage(named:asset) != nil {
            Image(asset).renderingMode(point.layer == .obelisk ? .template:.original).resizable().scaledToFit().foregroundStyle(Color(uiColor:point.color)).frame(width:28,height:30).clipShape(RoundedRectangle(cornerRadius:5))
        } else if point.layer == .custom {Image(systemName:point.symbol).foregroundStyle(Color(uiColor:point.color)).frame(width:28,height:30)}
        else {Image(point.layer.illustration).resizable().scaledToFit().frame(width:28,height:30)}
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
    var addLocation:((MapGPS)->Void)? = nil
    func makeUIView(context: Context) -> MapScrollView {
        let view = MapScrollView()
        view.delegate = context.coordinator
        view.isAccessibilityElement = false
        view.accessibilityIdentifier = "ragnarokMapViewport"
        view.accessibilityLabel = "Map " + mapName
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
        context.coordinator.addLocation=addLocation
        let hold=UILongPressGestureRecognizer(target:context.coordinator,action:#selector(Coordinator.longPress(_:)));hold.minimumPressDuration=0.65
        view.imageView.addGestureRecognizer(hold)
        return view
    }
    func updateUIView(_ uiView: MapScrollView, context: Context) {
        context.coordinator.addLocation=addLocation
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
        var addLocation:((MapGPS)->Void)?
        @objc func longPress(_ gesture:UILongPressGestureRecognizer) {
            guard gesture.state == .began,let image=gesture.view,let gps=MapCoordinateTransform.gps(at:gesture.location(in:image),size:image.bounds.size) else {return}
            addLocation?(gps)
        }
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
        resources = points.filter { $0.layer == .resource && $0.farmID == nil }
        resourceSurface.points = resources
        if resourceSurface.superview == nil { addSubview(resourceSurface) }
        let points = points.filter { $0.layer != .resource || $0.farmID != nil }
        guard locations != points else { refreshResources(); return }
        markerButtons.forEach { $0.removeFromSuperview() }; markerButtons.removeAll()
        markerLabels.forEach { $0.removeFromSuperview() }; markerLabels.removeAll()
        locations = points; locationIDs = points.map(\.id); menuMemberships.removeAll()
        for point in points {
            let button = UIButton(type: .system)
            button.bounds = CGRect(x: 0, y: 0, width: 32, height: 32)
            let asset: String? = point.layer == .resource ? point.resourceNames.first.map { MapResources.asset(for: $0) } : point.layer == .cave || point.layer == .base ? nil : point.imageAsset
            let artwork = asset.flatMap { UIImage(named: $0) }
            button.setImage(artwork?.withRenderingMode(point.layer == .obelisk || point.layer == .boss ? .alwaysTemplate : .alwaysOriginal) ?? UIImage(systemName: point.symbol), for: .normal)
            button.imageView?.contentMode = .scaleAspectFit
            button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
            button.tintColor = point.layer == .obelisk || point.layer == .custom ? point.color : .white
            button.backgroundColor = UIColor.black.withAlphaComponent(0.85)
            button.layer.cornerRadius = 16; button.layer.borderWidth = 1.5; button.layer.borderColor = point.color.cgColor
            let badge = UILabel(frame: CGRect(x: 21, y: -4, width: 17, height: 17))
            badge.tag = 88; badge.font = .systemFont(ofSize: 10, weight: .bold); badge.textColor = .black; badge.backgroundColor = .white; badge.textAlignment = .center; badge.layer.cornerRadius = 8.5; badge.clipsToBounds = true; badge.isHidden = true
            button.addSubview(badge)
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
        MapCoordinateTransform.pixel(lat:point.lat,lon:point.lon,size:imageView.bounds.size)
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
        var occupied: [CGPoint] = []
        let order = markerButtons.indices.sorted { locations[$0].id == focusID && locations[$1].id != focusID ? true : locations[$1].id == focusID ? false : $0 < $1 }
        for index in order {
            let button = markerButtons[index]
            button.center = pixelPoint(locations[index])
            button.transform = CGAffineTransform(scaleX: 1 / max(zoomScale, 0.001), y: 1 / max(zoomScale, 0.001))
            let label = markerLabels[index]
            label.center = CGPoint(x: button.center.x, y: button.center.y + 34 / max(zoomScale, 0.001))
            label.transform = button.transform
            let labelFrame = imageView.convert(label.frame, to: self)
            let center = imageView.convert(button.center, to: self)
            button.isHidden = occupied.contains { hypot($0.x - center.x, $0.y - center.y) < 40 }
            if !button.isHidden { occupied.append(center) }
            label.isHidden = button.isHidden || (locations[index].id != focusID && zoomScale < minimumZoomScale * 1.6) || labelFrames.contains { $0.intersects(labelFrame.insetBy(dx: -3, dy: -2)) }
            if !label.isHidden { labelFrames.append(labelFrame) }
            let point = locations[index]
            let nearby = locations.filter {
                let deltaX = (pixelPoint($0).x - button.center.x) * zoomScale
                let deltaY = (pixelPoint($0).y - button.center.y) * zoomScale
                return hypot(deltaX, deltaY) < 40
            }
            if let badge = button.viewWithTag(88) as? UILabel { badge.text = String(nearby.count); badge.isHidden = nearby.count < 2 }
            if menuMemberships[point.id] != nearby.map(\.id) {
                menuMemberships[point.id] = nearby.map(\.id)
                let actionID = UIAction.Identifier("select-marker")
                button.removeAction(identifiedBy: actionID, for: .touchUpInside)
                if nearby.count > 1 {
                    button.menu = UIMenu(title: "Choose nearby location", children: nearby.map { item in
                        UIAction(title: item.name, image: item.imageAsset.flatMap { UIImage(named: $0) } ?? UIImage(systemName: item.symbol)) { [weak self] _ in self?.select?(item) }
                    })
                    button.showsMenuAsPrimaryAction = true
                    button.accessibilityHint = "Open nearby locations"
                } else {
                    button.menu = nil; button.showsMenuAsPrimaryAction = false
                    button.addAction(UIAction(identifier: actionID) { [weak self] _ in self?.select?(point) }, for: .touchUpInside)
                    button.accessibilityHint = "Open location details"
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
