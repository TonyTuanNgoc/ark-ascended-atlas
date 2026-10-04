import SwiftUI
import SceneKit

struct BuildTemplate:Identifiable {
    let id,title:String;let width,depth,height:Int;let equipment:[String];let greenhouse:Bool
    static let all:[Self]=[
        .init(id:"starter",title:"Nhà 2 × 4",width:2,depth:4,height:1,equipment:["simple-bed","storage-box","mortar-and-pestle","campfire"],greenhouse:false),
        .init(id:"workshop",title:"Xưởng 4 × 4",width:4,depth:4,height:2,equipment:["smithy","fabricator","refining-forge","chemistry-bench","power-generator"],greenhouse:false),
        .init(id:"storage",title:"Kho 3 × 3",width:3,depth:3,height:2,equipment:["large-storage-box","large-storage-box","vault","refrigerator"],greenhouse:false),
        .init(id:"garden",title:"Nhà kính 3 × 3",width:3,depth:3,height:2,equipment:["large-crop-plot","large-crop-plot","large-crop-plot","compost-bin"],greenhouse:true),
        .init(id:"forge",title:"Xưởng mở 4 × 4",width:4,depth:4,height:0,equipment:["industrial-forge","smithy","industrial-grill"],greenhouse:false)
    ]
    var pieces:[StonePlacement] {
        var p:[StonePlacement]=[];let wall=greenhouse ? "greenhouse-wall":"stone-wall";let frame=greenhouse ? "greenhouse-doorframe":"stone-doorframe"
        for x in 0..<width {for z in 0..<depth {
            p.append(.init(kind:"stone-foundation",x:Double(x)-Double(width-1)/2,z:Double(z)-Double(depth-1)/2,level:0,turn:0))
            if height>0 {p.append(.init(kind:greenhouse ? "greenhouse-ceiling":"stone-ceiling",x:Double(x)-Double(width-1)/2,z:Double(z)-Double(depth-1)/2,level:height,turn:0))}
        }}
        for h in 0..<height {
            for x in 0..<width {
                let px=Double(x)-Double(width-1)/2
                p.append(.init(kind:wall,x:px,z:Double(depth)/2,level:h,turn:0))
                p.append(.init(kind:x==0 && h==0 ? frame:wall,x:px,z:-Double(depth)/2,level:h,turn:0))
            }
            for z in 0..<depth {
                let pz=Double(z)-Double(depth-1)/2
                for edge in [-1.0,1.0] {p.append(.init(kind:wall,x:edge*Double(width)/2,z:pz,level:h,turn:1))}
            }
        }
        if height>0 {p.append(.init(kind:greenhouse ? "greenhouse-door":"reinforced-wooden-door",x:-Double(width-1)/2,z:-Double(depth)/2,level:0,turn:0))}
        for (i,kind) in equipment.enumerated() {
            var x=Double(i%2)*1.6-0.8;var z=Double(i/2)*1.4-0.7
            if id=="starter" {x=Double(i%2)*0.6-0.3;z=Double(i/2)*1.5-0.7}
            if id=="workshop" {x=i==4 ? 1.4 : Double(i%2)*2-1;z=i==4 ? 0 : Double(i/2)*1.8-0.9}
            if id=="forge" {x=i==0 ? -0.65 : (i==1 ? 1.25:-1.25);z=i==0 ? 0.65:-1.4}
            p.append(.init(kind:kind,x:x,z:z,level:0,turn:0))
        }
        return p.filter {p in StoneKit.shared.models.contains {$0.id==p.kind}}
    }
}
struct BuildTemplatePreview:UIViewRepresentable {
    let template:BuildTemplate
    func makeUIView(context:Context)->SCNView {
        let v=SCNView();v.backgroundColor=UIColor(red:0.78,green:0.84,blue:0.89,alpha:1);v.antialiasingMode = .multisampling4X
        let scene=SCNScene();v.scene=scene
        for p in template.pieces {
            guard let m=StoneKit.shared.models.first(where:{$0.id==p.kind}) else {continue}
            let n=SCNNode(geometry:m.geometry);n.position=p.position;n.eulerAngles.y=Float(p.turn)*Float.pi/2
            if m.referenceOnly==true {n.position.y+=0.4;let c=SCNBillboardConstraint();c.freeAxes = .Y;n.constraints=[c]}
            // Cutaway preview reveals the furniture; bill still includes full walls/roof.
            if p.kind.contains("ceiling") || (p.z == -Double(template.depth)/2 && p.kind.contains("wall")) {n.opacity=0.16}
            scene.rootNode.addChildNode(n)
        }
        let ambient=SCNNode();ambient.light=SCNLight();ambient.light?.type = .ambient;ambient.light?.intensity=700;scene.rootNode.addChildNode(ambient)
        let sun=SCNNode();sun.light=SCNLight();sun.light?.type = .directional;sun.light?.intensity=1800;sun.eulerAngles=SCNVector3(-0.8,-0.6,0);scene.rootNode.addChildNode(sun)
        let ground=SCNNode(geometry:SCNBox(width:Double(template.width)+1,height:0.03,length:Double(template.depth)+1,chamferRadius:0.05));ground.position.y = -0.05;ground.geometry?.firstMaterial?.diffuse.contents=UIColor(red:0.6,green:0.66,blue:0.58,alpha:1);scene.rootNode.addChildNode(ground)
        let camera=SCNNode();camera.camera=SCNCamera();let size=Float(max(template.width,template.depth));camera.position=SCNVector3(size*1.3,size*1.4,size*1.5);camera.look(at:SCNVector3(0,template.id=="forge" ? 2.7:0.8,0));camera.camera?.usesOrthographicProjection=true;camera.camera?.orthographicScale=template.id=="forge" ? 8.5:Double(size)*1.25;scene.rootNode.addChildNode(camera);v.pointOfView=camera
        return v
    }
    func updateUIView(_ v:SCNView,context:Context) {}
}
struct BuildItemPicker:View {
    let choose:(String)->Void
    @Environment(\.dismiss) private var dismiss
    @State private var search=""
    @State private var group="structures"
    @State private var detail:BuildCraftItem?
    var body:some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns:[GridItem(.adaptive(minimum:110))],spacing:10) {
                    ForEach(BuildCraftCatalogue.shared.items.filter {$0.category==group && (search.isEmpty || $0.name.localizedStandardContains(search))}) {item in
                        Button {
                            if StoneKit.shared.models.contains(where:{$0.id==item.id}) {choose(item.id);dismiss()} else {detail=item}
                        } label: {
                            VStack {
                                if let asset=item.asset {Image(asset).resizable().scaledToFit().frame(height:55)}
                                Text(item.name).font(.caption).lineLimit(2)
                                if group=="tools" || group=="resources" {Text(item.stations.first ?? "Thu thập").font(.caption2).foregroundStyle(.secondary)}
                            }.frame(maxWidth:.infinity).frame(height:100).padding(8).background(Color.white.opacity(0.05),in:RoundedRectangle(cornerRadius:8))
                        }.buttonStyle(.plain).accessibilityIdentifier("build-item-"+item.id)
                    }
                }.padding(18)
            }.searchable(text:$search,prompt:"Tìm kết cấu, máy, đồ nghề")
                .navigationTitle("Đồ xây dựng").navigationBarTitleDisplayMode(.inline)
                .safeAreaInset(edge:.top) {
                    Picker("Nhóm",selection:$group) {Text("Kết cấu").tag("structures");Text("Máy").tag("machines");Text("Đồ nghề").tag("tools");Text("Vật liệu").tag("resources")}.pickerStyle(.segmented).padding()
                }.sheet(item:$detail) {item in BuildBillView(pieces:[StonePlacement(kind:item.id,x:0,z:0,level:0,turn:0)])}
                .toolbar {Button("Xong") {dismiss()}}
        }
    }
}

struct BuildPartsPanel:View {
    let pieces:[StonePlacement];let openBill:()->Void;let close:()->Void
    var body:some View {
        let counts=Dictionary(pieces.map {($0.kind,1)},uniquingKeysWith:+)
        VStack(alignment:.leading,spacing:10) {
            HStack {Button("Vật liệu",action:openBill).accessibilityIdentifier("template-bill");Spacer();Button(action:close) {Image(systemName:"xmark")}}
            ScrollView {
                VStack(spacing:6) {
                    ForEach(counts.keys.sorted(),id:\.self) {id in
                        let item=BuildCraftCatalogue.shared.item(id)
                        HStack {
                            if let asset=item?.asset {Image(asset).resizable().scaledToFit().frame(width:40,height:38)}
                            Text(item?.name ?? id).font(.caption).lineLimit(2);Spacer();Text("×\(counts[id] ?? 0)").font(.caption.bold())
                        }.padding(6).background(Color.white.opacity(0.05),in:RoundedRectangle(cornerRadius:8)).accessibilityElement(children:.combine).accessibilityIdentifier("template-part-"+id).accessibilityValue(String(counts[id] ?? 0))
                    }
                }
            }
        }.padding(10).background(Color.white.opacity(0.04),in:RoundedRectangle(cornerRadius:12))
    }
}
