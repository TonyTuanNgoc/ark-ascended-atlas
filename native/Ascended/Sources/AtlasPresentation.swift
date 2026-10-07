import SwiftUI
import UIKit

struct AtlasPhoto: Decodable {
    let mapID: String?
    let pointID: String
    let asset: String
    let sourceURL: String
    let caption: String
    let bossID: String?
    static let all: [AtlasPhoto] = (try? ArkMap.load([AtlasPhoto].self, name: "atlas-photo-media")) ?? []
}

enum AtlasMarkerArt {
    static func image(for point: MapLocation) -> UIImage {
        if point.layer == .boss, let bossID=point.bossID {
            let asset=AtlasPhoto.all.first(where:{$0.bossID==bossID})?.asset ?? (bossID=="nunatak" ? "Nunatak-Gamma":"Cutout-Boss-"+bossID)
            if let image=UIImage(named:asset) {return image}
        }
        if point.layer == .obelisk && point.symbolOverride == nil {
            return UIGraphicsImageRenderer(size: CGSize(width: 48, height: 64)).image { context in
                let c = context.cgContext
                c.setShadow(offset: .zero, blur: 8, color: point.color.cgColor)
                point.color.setFill()
                let crystal = UIBezierPath(); crystal.move(to: CGPoint(x:24,y:2)); crystal.addLine(to:CGPoint(x:34,y:19)); crystal.addLine(to:CGPoint(x:29,y:48)); crystal.addLine(to:CGPoint(x:24,y:55)); crystal.addLine(to:CGPoint(x:19,y:48)); crystal.addLine(to:CGPoint(x:14,y:19)); crystal.close(); crystal.fill()
                c.setShadow(offset: .zero, blur: 0)
                UIColor.white.withAlphaComponent(0.85).setStroke()
                let edge = UIBezierPath(); edge.move(to:CGPoint(x:24,y:7)); edge.addLine(to:CGPoint(x:24,y:47)); edge.lineWidth=2; edge.stroke()
                UIColor(white:0.25,alpha:1).setFill()
                let base = UIBezierPath(ovalIn:CGRect(x:8,y:55,width:32,height:7)); base.fill()
                point.color.setStroke(); base.lineWidth=2; base.stroke()
            }
        }
        let asset: String? = point.layer == .cave ? MapLayer.cave.illustration : point.layer == .resource ? point.resourceNames.first.map { MapResources.asset(for:$0) } : point.layer == .boss ? MapLayer.boss.illustration : point.imageAsset
        return asset.flatMap { UIImage(named:$0) } ?? UIImage(systemName:point.symbol)?.withTintColor(point.color, renderingMode:.alwaysOriginal) ?? UIImage()
    }
}

struct AtlasLocationImage: View {
    let point: MapLocation
    @Environment(\.arkMap) private var map
    private var photo: AtlasPhoto? { AtlasPhoto.all.first { $0.pointID == point.id && $0.mapID == map.rawValue } }
    private var asset: String? {
        if let photo, UIImage(named:photo.asset) != nil { return photo.asset }
        if let id=point.bossID, UIImage(named:map.bossPortrait(id)) != nil { return map.bossPortrait(id) }
        if point.layer != .obelisk, let asset=point.imageAsset, UIImage(named:asset) != nil { return asset }
        return nil
    }
    var body: some View {
        VStack(spacing:4) {
            if let asset {
                Image(asset).resizable().scaledToFit().frame(maxWidth:.infinity,maxHeight:.infinity)
            } else {
                Image(uiImage:AtlasMarkerArt.image(for:point)).resizable().scaledToFit().padding(8)
                Text("Location photo not yet verified").font(.system(size:9)).foregroundStyle(.secondary).multilineTextAlignment(.center)
            }
            if let photo { Text(photo.caption).font(.system(size:9)).foregroundStyle(.secondary).lineLimit(2) }
        }.clipShape(RoundedRectangle(cornerRadius:10)).accessibilityIdentifier("atlas-location-photo")
    }
}
