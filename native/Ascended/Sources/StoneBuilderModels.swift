import SceneKit
import SwiftUI

struct StoneKit: Decodable {
    let models: [StoneModel]
    static let shared:StoneKit = {
        let stone=(try? ArkMap.load(StoneKit.self,name:"stone-building-kit"))?.models ?? []
        let other=(try? ArkMap.load(StoneKit.self,name:"construction-models"))?.models ?? []
        return StoneKit(models:stone+other)
    }()
}
struct StoneModel: Decodable, Identifiable {
    let id, title, name: String
    let asset: String?
    let category:String?
    let referenceOnly:Bool?
    var group:String {category ?? "structures"}
    let positions, normals, uv, colors: [Float]
    let ingredients: [String:Int]
    var geometry: SCNGeometry {
        if referenceOnly == true {
            let g=SCNPlane(width:0.8,height:0.8);let m=SCNMaterial();m.lightingModel = .constant;m.isDoubleSided=true;m.diffuse.contents=asset.flatMap {UIImage(named:$0)};g.materials=[m];return g
        }
        func vectors(_ data:[Float])->[SCNVector3] { stride(from:0,to:data.count,by:3).map { SCNVector3(data[$0],data[$0+1],data[$0+2]) } }
        let vertices=SCNGeometrySource(vertices:vectors(positions))
        let ns=SCNGeometrySource(normals:vectors(normals))
        let tex=SCNGeometrySource(textureCoordinates:stride(from:0,to:uv.count,by:2).map { CGPoint(x:CGFloat(uv[$0]),y:CGFloat(uv[$0+1])) })
        let colorData=colors.withUnsafeBufferPointer { Data(buffer:$0) }
        let cs=SCNGeometrySource(data:colorData,semantic:.color,vectorCount:colors.count/4,usesFloatComponents:true,componentsPerVector:4,bytesPerComponent:4,dataOffset:0,dataStride:16)
        let indices=(0..<positions.count/3).map { Int32($0) }
        let data=indices.withUnsafeBufferPointer { Data(buffer:$0) }
        let element=SCNGeometryElement(data:data,primitiveType:.triangles,primitiveCount:indices.count/3,bytesPerIndex:4)
        let g=SCNGeometry(sources:[vertices,ns,tex,cs],elements:[element])
        let material=SCNMaterial();material.lightingModel = .physicallyBased;material.roughness.contents=0.95;material.isDoubleSided=true
        if let url=Bundle.main.url(forResource:"stone-builder-grain",withExtension:"png"),let image=UIImage(contentsOfFile:url.path) { material.diffuse.contents=image;material.diffuse.wrapS = .repeat;material.diffuse.wrapT = .repeat }
        else { material.diffuse.contents=UIColor(white:0.85,alpha:1) }
        g.materials=[material];return g
    }
}
struct StonePlacement: Codable, Identifiable, Equatable {
    var id=UUID();var kind:String;var x,z:Double;var level:Int;var turn:Int
    var position:SCNVector3 {
        let model=StoneKit.shared.models.first {$0.id==kind}
        let base:Float = kind.contains("foundation") ? 0 : (kind.contains("ceiling") || model?.category != nil ? 0.25:0)
        return SCNVector3(Float(x),Float(level)+base,Float(z))
    }
    func occupiesSameSlot(as other:Self)->Bool { kind==other.kind && x==other.x && z==other.z && level==other.level && turn==other.turn }
}
enum StoneBudget {
    static func materials(_ pieces:[StonePlacement])->[(String,Int)] {
        var result:[String:Int]=[:]
        for p in pieces { for (key,n) in StoneKit.shared.models.first(where:{$0.id==p.kind})?.ingredients ?? [:] { result[key,default:0]+=n } }
        return result.sorted {$0.key<$1.key}.map {($0.key,$0.value)}
    }
}
