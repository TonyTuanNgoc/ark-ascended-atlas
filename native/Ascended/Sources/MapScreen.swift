import SwiftUI
import UIKit

struct MapScreen: View {
    @Environment(\.arkMap) private var map
    var initialFocus: String? = nil
    var initialResources = false
    @State private var filters=MapFilterSelection()
    @State private var selectedLayer:MapLayer = .artifact
    @AppStorage("ascended.map.personal-locations.v1") private var personalJSON="[]"
    @State private var draft:PersonalMapLocation?
    private var personal:[PersonalMapLocation] {PersonalMapLocation.decode(personalJSON)}
    private var allPoints:[MapLocation] {(MapLocation.all(in:map)+personal.filter {$0.map==map.rawValue}.map(\.point)).filter {$0.layer != .resource && $0.layer != .base}}
    private var resourceTypes:[String] {MapResources.types(in:map)}
    private var availableLayers:[MapLayer] {MapLayer.allCases.filter {$0 != .resource && $0 != .base}}
    @State private var selected: MapLocation?
    @State private var focusedID: String?
    @State private var resetToken = UUID()
    @State private var action: MapAction = .fit
    @State private var artifactViewport = AtlasPopupViewport(anchor: .zero, zoom: 1)
    @State private var walkthrough: CaveGIFGuide?
    @State private var pinchStartZoom: CGFloat?
    @State private var requestedZoom: AtlasZoomRequest?
    var body: some View {
        GeometryReader { geometry in
        let imageSize = UIImage(named: map.imageAsset)?.size ?? CGSize(width: 1, height: 1)
        let aspect = imageSize.width / max(1, imageSize.height)
        let mapWidth = min(max(1, geometry.size.width - 320), max(1, geometry.size.height - 90) * aspect)
        VStack(spacing:12) {
        categoryBar
        HStack(alignment: .top, spacing: 16) {
        ZoomableMap(imageAsset: map.imageAsset, mapName: map.name, resetToken: resetToken, action: action, locations: allPoints.filter {filters.includes($0)}, focusID: focusedID, select: { selected = $0; focusedID = $0.id }, addLocation:{gps in draft=PersonalMapLocation(map:map.rawValue,name:"",lat:gps.lat,lon:gps.lon)}, automaticallyFocus:false, requestedZoom:requestedZoom, viewportChanged:{ artifactViewport = $0 }, highlightID: selected?.id, doubleTapResets:true, resetView:{focusedID=nil;selected=nil})
            .frame(width: mapWidth, height: mapWidth / aspect)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(alignment: .bottomTrailing) { legacyPopup }
            .overlay(alignment: .topLeading) { artifactPopup(mapWidth: mapWidth, mapHeight: mapWidth / aspect) }
            .simultaneousGesture(MagnifyGesture().onChanged { value in
                if pinchStartZoom == nil { pinchStartZoom = artifactViewport.zoom }
                requestedZoom = AtlasZoomRequest(ratio: (pinchStartZoom ?? 1) * value.magnification, anchor: CGPoint(x: value.startAnchor.x, y: value.startAnchor.y))
            }.onEnded { _ in pinchStartZoom = nil; requestedZoom = nil })
            .simultaneousGesture(TapGesture(count: 2).onEnded {
                requestedZoom = nil; pinchStartZoom = nil
                selected = nil; focusedID = nil; action = .fit; resetToken = UUID()
            })
            controls.frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        }.padding(8)
        .onAppear {
            // Farming and Base Locations own their dedicated map layers.
            if let id=initialFocus,let point=allPoints.first(where:{$0.id==id}) {
                if point.layer == .resource {filters.resources.formUnion(point.resourceNames)} else {filters.locations.insert(id)}
                selected=point;focusedID=id;selectedLayer=point.layer
            }
        }
        .sheet(item: $walkthrough) { guide in
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(map.exploration?.routes.first { $0.id == guide.routeID }?.name ?? "Cave walkthrough")
                            .font(.largeTitle.bold()).accessibilityIdentifier("atlas-walkthrough-title")
                        CaveGIFWalkthrough(guide: guide)
                    }.padding(20)
                }.background(Color(red: 0.025, green: 0.045, blue: 0.065))
                    .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { walkthrough = nil } } }
            }.preferredColorScheme(.dark)
        }
        .sheet(item:$draft) {value in PersonalLocationEditor(location:value) {saved in
            var rows=personal;rows.removeAll {$0.id==saved.id};rows.append(saved)
            personalJSON=PersonalMapLocation.encode(rows);filters.locations.insert(saved.point.id);selected=saved.point;focusedID=saved.point.id
        }}
        }
    }

    @ViewBuilder private var legacyPopup: some View {

                if let point = selected, point.layer != .artifact {
                    if let farmID = point.farmID, let spot = ResourceFarmCatalog.spots(in: map).first(where: { $0.id == farmID }) {
                        VStack(alignment: .trailing, spacing: 4) {
                            Button { selected = nil; focusedID = nil } label: { Image(systemName: "xmark") }.accessibilityLabel("Close location")
                            ScrollView { FarmDetails(spot: spot) }.frame(maxHeight: 490)
                        }.padding(14).frame(maxWidth: 440).background(.black.opacity(0.94), in: RoundedRectangle(cornerRadius: 16)).padding(12)
                    } else {
                    VStack(alignment:.leading, spacing:10) {
                        HStack {
                            Text(point.name).font(.headline).accessibilityIdentifier("selectedMapLocation")
                            Spacer(minLength:8)
                            Button { selected=nil;focusedID=nil } label:{Image(systemName:"xmark")}.accessibilityLabel("Close location")
                        }
                        GPSBadge(coordinates:point.coordinates).foregroundStyle(.cyan).monospacedDigit()
                        HStack(alignment:.top,spacing:12) {
                            AtlasLocationImage(point:point).frame(width:150,height:115)
                            Text(point.layer == .artifact ? "Collect at these coordinates. " + (map.exploration?.routes.first { $0.id == point.routeID }?.name ?? "") : point.note)
                                .font(.caption).foregroundStyle(.secondary).fixedSize(horizontal:false,vertical:true).frame(maxWidth:.infinity,alignment:.leading)
                        }
                        HStack {
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
                        }
                    }.buttonStyle(.bordered).padding(14)
                        .frame(maxWidth: 430).background(.black.opacity(0.94), in: RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.16)))
                        .padding(12)
                    }
                }

    }
    @ViewBuilder private func artifactPopup(mapWidth: CGFloat, mapHeight: CGFloat) -> some View {
        if let point = selected, point.layer == .artifact {
            let desiredWidth = min(mapWidth - 16, 238 + min(max(artifactViewport.zoom - 1, 0), 4) * 22)
            let desiredHeight = 100 + (desiredWidth - 24) * 9 / 16
            let verticalRoom = max(artifactViewport.anchor.y, mapHeight - artifactViewport.anchor.y) - 44
            let sideRoom = max(artifactViewport.anchor.x, mapWidth - artifactViewport.anchor.x) - 44
            let width = verticalRoom >= desiredHeight ? desiredWidth : min(desiredWidth, max(150, sideRoom))
            let height = 100 + (width - 24) * 9 / 16
            let origin = AtlasPopupViewport.popupOrigin(anchor: artifactViewport.anchor, card: CGSize(width: width, height: height), viewport: CGSize(width: mapWidth, height: mapHeight))
            AtlasArtifactPopup(point: point, guide: map.caveGIFs.first { $0.routeID == point.routeID }, playing: walkthrough == nil, close: { selected = nil; focusedID = nil }, open: { walkthrough = $0 })
                .frame(width: width).accessibilityElement(children: .contain).accessibilityIdentifier("atlas-artifact-popup").offset(x: origin.x, y: origin.y).id(point.id)
        }
    }

    private var categoryBar:some View {
        HStack(spacing:8) {
            ForEach(availableLayers,id:\.self) {layer in
                let count=filters.selectedCount(layer,points:allPoints,types:resourceTypes)
                let total=filters.total(layer,points:allPoints,types:resourceTypes)
                HStack(spacing:5) {
                    Button {selectedLayer=layer} label:{
                        HStack(spacing:7) {Image(layer.illustration).resizable().scaledToFit().frame(width:30,height:32);Text(layer.title).font(.system(size:13,weight:.semibold)).lineLimit(2)}
                            .frame(maxWidth:.infinity,minHeight:48).contentShape(Rectangle())
                    }.accessibilityIdentifier("expand-layer-"+layer.rawValue)
                    Button {filters.toggle(layer,points:allPoints,types:resourceTypes);if let point=selected,!filters.includes(point) {selected=nil;focusedID=nil}} label:{
                        Image(systemName:count==0 ? "square":count==total ? "checkmark.square.fill":"minus.square.fill").frame(width:28,height:44)
                    }.accessibilityIdentifier("layer-"+layer.rawValue).accessibilityLabel("Select "+layer.title).accessibilityValue(count==0 ? "Hidden":count==total ? "Visible":"Partially visible").disabled(total==0)
                }.padding(.horizontal,8).foregroundStyle(selectedLayer==layer ? .cyan:.white)
                    .background(selectedLayer==layer ? Color.cyan.opacity(0.12):Color.white.opacity(0.035),in:RoundedRectangle(cornerRadius:13))
                    .overlay(RoundedRectangle(cornerRadius:13).stroke(selectedLayer==layer ? .cyan.opacity(0.35):.clear))
            }
        }.buttonStyle(.plain).accessibilityElement(children: .contain).accessibilityIdentifier("atlas-category-strip")
    }
    private var controls:some View {
        ScrollView(.vertical,showsIndicators:false) {
            VStack(alignment:.leading,spacing:10) {
                Menu {
                    ForEach(allPoints) {point in
                        Button(point.name) {filters.locations.insert(point.id);selected=point;focusedID=point.id;selectedLayer=point.layer}.accessibilityIdentifier("find-"+point.id)
                    }
                } label:{Label("Find location",systemImage:"magnifyingglass").font(.subheadline).frame(maxWidth:.infinity,minHeight:44,alignment:.leading)}.accessibilityIdentifier("findMapLocation")
                Divider()
                ForEach(allPoints.filter {$0.layer==selectedLayer}) {point in
                    Button {
                        filters.togglePoint(point.id)
                        if filters.locations.contains(point.id) {selected=point;focusedID=point.id}
                        else if selected?.id==point.id {selected=nil;focusedID=nil}
                    } label:{
                        HStack(spacing:10) {pointPicture(point);Text(point.name).font(.subheadline).multilineTextAlignment(.leading).fixedSize(horizontal:false,vertical:true);Spacer(minLength:0);Image(systemName:filters.locations.contains(point.id) ? "checkmark.square.fill":"square")}
                            .padding(10).background(filters.locations.contains(point.id) ? Color.cyan.opacity(0.12):Color.white.opacity(0.035),in:RoundedRectangle(cornerRadius:10))
                    }.accessibilityIdentifier("location-filter-"+point.id).accessibilityValue(filters.locations.contains(point.id) ? "Visible":"Hidden")
                }
                if !allPoints.contains(where:{$0.layer==selectedLayer}) {
                    Text(selectedLayer == .custom ? "No saved locations" : "No verified locations yet").font(.caption).foregroundStyle(.secondary).padding(10)
                }
            }.padding(12)
        }.accessibilityIdentifier("mapFilterRail").buttonStyle(.plain).background(.ultraThinMaterial,in:RoundedRectangle(cornerRadius:16))
    }
    private func resourcePicture(_ name:String)->some View {
        Image(UIImage(named:MapResources.asset(for:name)) != nil ? MapResources.asset(for:name):MapLayer.resource.illustration).resizable().scaledToFit().frame(width:28,height:30)
    }
    private func pointPicture(_ point: MapLocation) -> some View {
        Image(uiImage: AtlasMarkerArt.image(for: point)).resizable().scaledToFit().frame(width: 30, height: 34)
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
    var automaticallyFocus = true
    var requestedZoom: AtlasZoomRequest? = nil
    var viewportChanged: ((AtlasPopupViewport) -> Void)? = nil
    var highlightID: String? = nil
    var doubleTapResets = false
    var resetView:(()->Void)? = nil
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
        view.pinchGestureRecognizer?.isEnabled = automaticallyFocus
        view.automaticallyFocus = automaticallyFocus
        view.viewportChanged = viewportChanged
        view.highlightID = highlightID
        view.updateLocations(locations, select: select)
        view.focusID = focusID
        view.addSubview(view.imageView)
        view.contentSize = view.imageView.bounds.size
        let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.doubleTap(_:)))
        tap.numberOfTapsRequired = 2
        view.addGestureRecognizer(tap)
        context.coordinator.resetView=resetView
        context.coordinator.doubleTapResets = doubleTapResets
        context.coordinator.resetToken = resetToken
        context.coordinator.addLocation=addLocation
        let hold=UILongPressGestureRecognizer(target:context.coordinator,action:#selector(Coordinator.longPress(_:)));hold.minimumPressDuration=0.65
        view.imageView.addGestureRecognizer(hold)
        return view
    }
    func updateUIView(_ uiView: MapScrollView, context: Context) {
        context.coordinator.addLocation=addLocation
        context.coordinator.resetView=resetView
        context.coordinator.doubleTapResets = doubleTapResets
        uiView.pinchGestureRecognizer?.isEnabled = automaticallyFocus
        uiView.automaticallyFocus = automaticallyFocus
        uiView.viewportChanged = viewportChanged
        uiView.highlightID = highlightID
        uiView.updateLocations(locations, select: select)
        if let requestedZoom {
            let scale = min(max(uiView.minimumZoomScale * requestedZoom.ratio, uiView.minimumZoomScale), uiView.maximumZoomScale)
            if abs(uiView.zoomScale - scale) > 0.00001 {
                let viewportPoint = CGPoint(x: uiView.bounds.minX + uiView.bounds.width * requestedZoom.anchor.x, y: uiView.bounds.minY + uiView.bounds.height * requestedZoom.anchor.y)
                let pixel = uiView.imageView.convert(viewportPoint, from: uiView)
                uiView.setZoomScale(scale, animated: false)
                let after = uiView.imageView.convert(pixel, to: uiView)
                uiView.setContentOffset(CGPoint(x: after.x - uiView.bounds.width * requestedZoom.anchor.x, y: after.y - uiView.bounds.height * requestedZoom.anchor.y), animated: false)
            }
        }
        uiView.centerMap()
        if uiView.focusID != focusID {
            uiView.focusID = focusID
            if automaticallyFocus { uiView.focusMap(animated: true) }
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
        var doubleTapResets=false
        var resetView:(()->Void)?
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
            if doubleTapResets || scroll.zoomScale >= scroll.minimumZoomScale * 3.9 {
                if doubleTapResets {scroll.focusID=nil;resetView?()}
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
    let imageView = MapTerrainView(frame: .zero)
    private let resourceSurface = ResourceSurface()
    private var resources: [MapLocation] = []
    var automaticallyFocus = true
    var viewportChanged: ((AtlasPopupViewport) -> Void)?
    private var lastViewport: AtlasPopupViewport?
    var focusID: String?
    var highlightID: String?
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
            button.setImage(AtlasMarkerArt.image(for: point).withRenderingMode(.alwaysOriginal), for: .normal)
            button.imageView?.contentMode = .scaleAspectFit
            button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
            button.tintColor = point.layer == .base ? .darkGray : point.layer == .obelisk || point.layer == .custom ? point.color : .white
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
            if automaticallyFocus { focusMap(animated: false) }
        }
        centerMap()
    }
    func fitMap(animated: Bool) {
        guard imageView.bounds.width > 0, bounds.width > 0, bounds.height > 0 else { return }
        let fit = max(bounds.width / imageView.bounds.width, bounds.height / imageView.bounds.height)
        minimumZoomScale = fit
        maximumZoomScale = max(fit * 32, 1)
        setZoomScale(fit, animated: animated)
        centerMap()
        let offset = CGPoint(x: max(0, (imageView.bounds.width * fit - bounds.width) / 2), y: max(0, (imageView.bounds.height * fit - bounds.height) / 2))
        setContentOffset(offset, animated: animated)
    }
    func centerMap() {
        var labelFrames: [CGRect] = []
        var occupied: [CGPoint] = []
        let order = markerButtons.indices.sorted { locations[$0].id == (highlightID ?? focusID) && locations[$1].id != (highlightID ?? focusID) ? true : locations[$1].id == (highlightID ?? focusID) ? false : $0 < $1 }
        for index in order {
            let button = markerButtons[index]
            let pointIsSelected = locations[index].id == highlightID
            if locations[index].farmID != nil || locations[index].layer == .base || locations[index].layer == .artifact {
                let diameter: CGFloat = pointIsSelected ? 44 : 36
                button.bounds.size = CGSize(width: diameter, height: diameter)
                button.layer.cornerRadius = diameter / 2
                button.backgroundColor = pointIsSelected ? UIColor(red: 0.82, green: 0.97, blue: 1, alpha: 1) : UIColor(white: 0.94, alpha: 0.96)
                button.layer.borderColor = (pointIsSelected ? UIColor.systemCyan : UIColor.darkGray).cgColor
                button.layer.borderWidth = pointIsSelected ? 3 : 1.5
                button.layer.shadowColor = UIColor.black.cgColor
                button.layer.shadowOpacity = 0.45
                button.layer.shadowRadius = pointIsSelected ? 5 : 2
                button.layer.shadowOffset = CGSize(width: 0, height: 1)
                button.accessibilityValue = pointIsSelected ? "Selected" : "Not selected"
            }
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
        if let viewportChanged {
            let pixel = locations.first(where: { $0.id == highlightID }).map { imageView.convert(pixelPoint($0), to: self) } ?? CGPoint(x: bounds.minX, y: bounds.minY)
            let value = AtlasPopupViewport(anchor: CGPoint(x: pixel.x - bounds.minX, y: pixel.y - bounds.minY), zoom: zoomScale / max(minimumZoomScale, 0.001))
            if lastViewport != value {
                lastViewport = value
                DispatchQueue.main.async { viewportChanged(value) }
            }
        }
    }

}

struct AtlasZoomRequest {
    let ratio: CGFloat
    let anchor: CGPoint
}

struct AtlasPopupViewport: Equatable {
    let anchor: CGPoint
    let zoom: CGFloat
    static func popupOrigin(anchor: CGPoint, card: CGSize, viewport: CGSize) -> CGPoint {
        let gap: CGFloat = 36
        let x = min(max(anchor.x - card.width / 2, 8), max(8, viewport.width - card.width - 8))
        let y = min(max(anchor.y - card.height / 2, 8), max(8, viewport.height - card.height - 8))
        let candidates = [CGPoint(x: x, y: anchor.y + gap), CGPoint(x: anchor.x + gap, y: y), CGPoint(x: anchor.x - gap - card.width, y: y), CGPoint(x: x, y: anchor.y - gap - card.height)]
        let bounds = CGRect(x: 8, y: 8, width: max(0, viewport.width - 16), height: max(0, viewport.height - 16))
        if let origin = candidates.first(where: { bounds.contains(CGRect(origin: $0, size: card)) }) { return origin }
        // At high zoom the pin can be outside the viewport; keep the card visible
        // at the opposite edge without moving the map or hiding an on-screen pin.
        let edgeX: CGFloat = anchor.x < viewport.width / 2 ? max(8, viewport.width - card.width - 8) : 8
        let edgeY: CGFloat = anchor.y < viewport.height / 2 ? max(8, viewport.height - card.height - 8) : 8
        return CGPoint(x: edgeX, y: edgeY)
    }
}

private struct AtlasArtifactPopup: View {
    let point: MapLocation
    let guide: CaveGIFGuide?
    let playing: Bool
    let close: () -> Void
    let open: (CaveGIFGuide) -> Void
    @Environment(\.scenePhase) private var scenePhase
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(uiImage: AtlasMarkerArt.image(for: point)).resizable().scaledToFit().frame(width: 30, height: 36)
                VStack(alignment: .leading, spacing: 1) {
                    Text("ARTIFACT OF THE").font(.system(size: 9, weight: .semibold)).tracking(1.2).foregroundStyle(.cyan)
                    Text(point.name.replacingOccurrences(of: "Artifact of the ", with: ""))
                        .font(.system(size: 22, weight: .bold, design: .rounded)).lineLimit(1).minimumScaleFactor(0.7)
                        .accessibilityIdentifier("selectedMapLocation")
                }
                Spacer(minLength: 0)
                if let routeID = point.routeID {
                    NavigationLink(value: GuideDestination.cave(routeID)) {
                        Image(systemName: "arrow.up.right.square").font(.title3).foregroundStyle(.cyan)
                    }.accessibilityLabel("Open cave page").accessibilityIdentifier("atlas-open-cave-page")
                }
                Button(action: close) { Image(systemName: "xmark").font(.caption.bold()).padding(8).background(.white.opacity(0.1), in: Circle()) }.accessibilityLabel("Close location")
            }
            GPSBadge(coordinates: point.coordinates).font(.caption).foregroundStyle(.cyan).monospacedDigit()
            if let guide, let step = guide.sections.first?.steps.first, let url = step.gifURL {
                Button { open(guide) } label: {
                    ZStack(alignment: .topTrailing) {
                        if playing && scenePhase == .active {
                            AutoCaveGIF(step: step, url: url)
                        } else if let poster = step.posterThumbnail {
                            Image(uiImage: poster).resizable().scaledToFit()
                        }
                        Image(systemName: "arrow.up.left.and.arrow.down.right").font(.caption.bold())
                            .padding(8).background(.black.opacity(0.7), in: RoundedRectangle(cornerRadius: 8)).padding(6)
                    }.aspectRatio(16 / 9, contentMode: .fit).clipShape(RoundedRectangle(cornerRadius: 10))
                }.buttonStyle(.plain).accessibilityLabel("Open cave walkthrough").accessibilityIdentifier("atlas-cave-preview-" + guide.routeID)
            } else {
                AtlasLocationImage(point: point).frame(height: 112).clipShape(RoundedRectangle(cornerRadius: 10))
                if let routeID = point.routeID {
                    NavigationLink(value: GuideDestination.cave(routeID)) { Label("Cave route", systemImage: "map") }.font(.caption)
                }
            }
        }.padding(12).foregroundStyle(.white)
            .background(Color(red: 0.035, green: 0.075, blue: 0.09).opacity(0.97), in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(.cyan.opacity(0.5)))
            .shadow(color: .black.opacity(0.4), radius: 12, y: 4)
    }
}
