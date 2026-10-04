import SwiftUI
import SceneKit

struct CommunityBuildLibrary:Decodable {
    let builds:[CommunityBuild]
    static let shared=(try? ArkMap.load(Self.self,name:"community-builds")) ?? Self(builds:[])
}
struct CommunityBuild:Decodable,Identifiable {
    let id,zone,title,creator,sourceURL:String
    let videoURL:String?;let parts:[CommunityPart];let requirements:[CommunityRequirement];let skins:Bool;let extent:Double
    var missing:Int {parts.filter {$0.modelID==nil}.count}
    func direct(through phase:Int)->[String:Int] {
        var result:[String:Int]=[:]
        for r in requirements where r.phase<=phase && r.verified {for (name,n) in r.ingredients {result[name,default:0]+=n*r.count}}
        return result
    }
}
struct CommunityPart:Decodable,Identifiable {let id:String;let modelID:String?;let x,y,z,pitch,yaw,roll:Double;let phase:Int;let sourceClass:String;let suggested:Bool}
struct CommunityRequirement:Decodable,Identifiable {let id,name:String;let count:Int;let asset:String?;let ingredients:[String:Int];let stations:[String];let verified:Bool;let phase:Int;let suggested:Bool}
struct CommunityBuildScene:UIViewRepresentable {
    let build:CommunityBuild;var phase=3;var interactive=true
    func makeUIView(context:Context)->SCNView {let v=SCNView();v.antialiasingMode = .multisampling4X;render(v);return v}
    func updateUIView(_ v:SCNView,context:Context) {if v.accessibilityValue != build.id+"-\(phase)" {render(v)}}
    private func render(_ v:SCNView) {
        let scene=SCNScene();v.scene=scene;v.backgroundColor=UIColor(red:0.8,green:0.86,blue:0.89,alpha:1);v.allowsCameraControl=interactive
        var geometries:[String:SCNGeometry]=[:]
        for p in build.parts where p.phase<=phase {
            guard let id=p.modelID,let m=StoneKit.shared.models.first(where:{$0.id==id}) else {continue}
            let g=geometries[id] ?? m.geometry;geometries[id]=g
            let n=SCNNode(geometry:g);n.position=SCNVector3(p.x,p.y,p.z)
            n.eulerAngles=SCNVector3(p.pitch * .pi/180,-p.yaw * .pi/180,p.roll * .pi/180)
            if p.phase==2 && phase==3 {n.opacity=0.5}
            if m.referenceOnly==true {let c=SCNBillboardConstraint();c.freeAxes = .Y;n.constraints=[c]}
            scene.rootNode.addChildNode(n)
        }
        let light=SCNNode();light.light=SCNLight();light.light?.type = .ambient;light.light?.intensity=700;scene.rootNode.addChildNode(light)
        let sun=SCNNode();sun.light=SCNLight();sun.light?.type = .directional;sun.light?.intensity=1600;sun.eulerAngles=SCNVector3(-0.8,-0.5,0);scene.rootNode.addChildNode(sun)
        let size=max(build.extent,4)
        let ground=SCNNode(geometry:SCNBox(width:size+2,height:0.05,length:size+2,chamferRadius:0));ground.position.y = -0.3;ground.geometry?.firstMaterial?.diffuse.contents=UIColor(red:0.64,green:0.7,blue:0.61,alpha:1);scene.rootNode.addChildNode(ground)
        let camera=SCNNode();camera.camera=SCNCamera();camera.camera?.usesOrthographicProjection=true;camera.camera?.orthographicScale=size*1.05;camera.position=SCNVector3(size,size*0.85,size);camera.look(at:SCNVector3(0,size*0.15,0));scene.rootNode.addChildNode(camera);v.pointOfView=camera;v.accessibilityValue=build.id+"-\(phase)"
    }
}
struct CommunityBuildGallery:View {
    @State private var zone="home"
    @State private var selected:String?
    @State private var phase=0
    @State private var materialTab=0
    private let zones=[("home","Home","house"),("workshop","Workshop","hammer"),("storage","Storage","shippingbox"),("garden","Greenhouse","leaf"),("forge","Forge","flame")]
    private let stages=["Foundations","Frame","Roof","Equipment"]
    private var choices:[CommunityBuild] {CommunityBuildLibrary.shared.builds.filter {$0.zone==zone}}
    private var current:CommunityBuild? {choices.first {$0.id==selected} ?? choices.first}
    var body:some View {
        VStack(spacing:12) {
            HStack(spacing:8) {ForEach(zones,id:\.0) {z in Button {zone=z.0;selected=nil;phase=0} label:{Label(z.1,systemImage:z.2).font(.subheadline.weight(.semibold)).frame(maxWidth:.infinity).padding(10).background(zone==z.0 ? Color.cyan.opacity(0.2):Color.white.opacity(0.06),in:RoundedRectangle(cornerRadius:10))}.buttonStyle(.plain).accessibilityIdentifier("gallery-zone-"+z.0)}}
            HStack(spacing:10) {ForEach(choices) {b in Button {selected=b.id;phase=0} label:{VStack(alignment:.leading,spacing:5) {CommunityBuildScene(build:b,interactive:false).frame(height:115).clipShape(RoundedRectangle(cornerRadius:10));Text(b.title).font(.subheadline.bold());Text("\(b.parts.filter {!$0.suggested}.count) structures").font(.caption).foregroundStyle(.secondary)}.padding(6).frame(maxWidth:.infinity).background(current?.id==b.id ? Color.cyan.opacity(0.14):Color.white.opacity(0.04),in:RoundedRectangle(cornerRadius:12))}.buttonStyle(.plain).accessibilityIdentifier("gallery-build-"+b.id)}}
            if let b=current {
                HStack(alignment:.top,spacing:12) {
                    VStack(alignment:.leading,spacing:10) {
                        CommunityBuildScene(build:b,phase:phase).frame(maxWidth:.infinity,maxHeight:.infinity).clipShape(RoundedRectangle(cornerRadius:14)).accessibilityIdentifier("community-build-scene")
                        HStack {ForEach(0..<4,id:\.self) {i in Button {phase=i} label:{Text(stages[i]).font(.caption.bold()).frame(maxWidth:.infinity).padding(.vertical,10).background(phase==i ? Color.cyan.opacity(0.2):Color.white.opacity(0.06),in:RoundedRectangle(cornerRadius:8))}.buttonStyle(.plain).accessibilityIdentifier("gallery-stage-\(i)")}}
                        HStack {Text("By \(b.creator)").font(.caption);Spacer();if let url=URL(string:b.sourceURL) {Link("Original design",destination:url).font(.caption)}}
                        Text("Planning geometry • source layout, approximate shapes and pivots").font(.caption).foregroundStyle(.secondary)
                        if b.missing>0 {Text("\(b.missing) decorative or unsupported objects are not modeled.").font(.caption).foregroundStyle(.orange)}
                        if b.skins {Text("Creator's cosmetic skins are not reproduced.").font(.caption).foregroundStyle(.secondary)}
                        if phase==3 {Text("Suggested functional equipment is added separately from the creator’s structure counts.").font(.caption).foregroundStyle(.secondary)}
                        if let video=b.videoURL,let url=URL(string:video) {Link(destination:url) {Label("Creator tutorial",systemImage:"play.rectangle.fill")}}
                    }
                    VStack(alignment:.leading,spacing:10) {
                        Text("Cumulative materials").font(.headline)
                        Picker("Materials",selection:$materialTab) {Text("Parts").tag(0);Text("Resources").tag(1);Text("Craft").tag(2)}.pickerStyle(.segmented)
                        ScrollView {
                            VStack(alignment:.leading,spacing:9) {
                                if materialTab==0 {ForEach(b.requirements.filter {$0.phase<=phase}) {r in HStack {if let asset=r.asset {Image(asset).resizable().scaledToFit().frame(width:32,height:32)};VStack(alignment:.leading) {Text(r.name).font(.caption);if r.suggested {Text("Suggested fit-out").font(.caption2).foregroundStyle(.cyan)}};Spacer();Text("×\(r.count)").font(.caption.bold())}.padding(7).background(Color.white.opacity(0.04),in:RoundedRectangle(cornerRadius:8))}}
                                else if materialTab==1 {amounts(b.direct(through:phase))}
                                else {let expanded=BuildBill.expand(b.direct(through:phase));ForEach(expanded.steps) {s in VStack(alignment:.leading,spacing:4) {Text("\(s.name) ×\(s.batches*s.recipe.output)").font(.caption.bold());Text(s.recipe.station).font(.caption2).foregroundStyle(.cyan);amounts(s.recipe.ingredients.mapValues {$0*s.batches})}};Text("Raw materials").font(.subheadline.bold());amounts(expanded.raw)}
                                let unknown=b.requirements.filter {$0.phase<=phase && !$0.verified}
                                if !unknown.isEmpty {Text("Recipe pending: "+unknown.map(\.name).joined(separator:", ")+". These items are excluded from resource totals.").font(.caption).foregroundStyle(.orange)}
                            }
                        }
                    }.padding(12).frame(width:260).background(Color.white.opacity(0.05),in:RoundedRectangle(cornerRadius:14)).accessibilityIdentifier("gallery-materials")
                }
            }
        }.padding(12)
    }
    private func amounts(_ values:[String:Int])->some View {VStack(spacing:8) {ForEach(values.keys.sorted(),id:\.self) {name in HStack {FactTile(match:VisualFacts.items([name])[0]).frame(width:75);Spacer();Text("×\(values[name] ?? 0)").font(.caption.bold()).monospacedDigit()}}}}
}
