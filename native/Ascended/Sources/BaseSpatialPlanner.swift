import SwiftUI
import SceneKit

struct BaseHouse: Codable, Identifiable {
    let id: String
    var width, depth, x, z, levels: Int
    static let defaults = (try? ArkMap.load([BaseHouse].self, name: "base-layout")) ?? []
    static func arranged(_ houses: [BaseHouse]) -> [BaseHouse] {
        var result = houses
        let frontDepth = houses.filter { ["main","garden","industry"].contains($0.id) }.map(\.depth).max() ?? 6
        for ids in [["main","garden","industry"],["dino","breeding"]] {
            var x = 0
            for id in ids {
                if let index = result.firstIndex(where: { $0.id == id }) {
                    result[index].x = x; result[index].z = ids[0] == "main" ? 0 : frontDepth + 4
                    x += result[index].width + (ids[0] == "main" ? 2 : 4)
                }
            }
        }
        return result
    }
    var title: String { BasePlan.shared.zones.first { $0.id == id }?.name ?? id }
}
struct BuildingRecipes: Decodable {
    let items: [BuildingRecipe]
    static let shared = (try? ArkMap.load(BuildingRecipes.self, name: "base-building-recipes")) ?? BuildingRecipes(items: [])
}
struct BuildingRecipe: Decodable { let id, name: String; let ingredients: [BuildingIngredient] }
struct BuildingIngredient: Decodable { let name: String; let amount: Int }
enum BaseBill {
    static func components(_ houses: [BaseHouse]) -> [String:Int] {
        var result: [String:Int] = [:]
        for h in houses {
            result["stone-foundation",default:0] += h.width * h.depth
            result["stone-ceiling",default:0] += h.width * h.depth
            result["stone-wall",default:0] += 2 * (h.width + h.depth) * h.levels - 1
            result["stone-doorframe",default:0] += 1
            result["reinforced-wooden-door",default:0] += 1
        }
        return result
    }
    static func materials(_ houses: [BaseHouse]) -> [(String,Int)] {
        var result: [String:Int] = [:]
        for (id,count) in components(houses) {
            if let recipe = BuildingRecipes.shared.items.first(where: {$0.id == id}) {
                for i in recipe.ingredients { result[i.name,default:0] += i.amount * count }
            }
        }
        return result.sorted { $0.key < $1.key }.map { ($0.key,$0.value) }
    }
}
struct BaseSpatialPlanner: View {
    let select: (String) -> Void
    @AppStorage("ascended.base-layout.v1") private var saved = ""
    @State private var houses = BaseHouse.defaults
    @State private var selectedID = "main"
    @State private var threeD = false
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Picker("Góc nhìn", selection: $threeD) { Text("Bản đồ base").tag(false); Text("Không gian 3D").tag(true) }.pickerStyle(.segmented)
                Button { houses = BaseHouse.defaults; persist() } label: { Image(systemName: "arrow.counterclockwise") }.accessibilityLabel("Đặt lại bố trí base")
            }
            if threeD { BaseSceneView(houses: BaseHouse.arranged(houses), select: { selectedID = $0 }).frame(height: 390).accessibilityIdentifier("base3D") }
            else { BaseFloorplan(houses: BaseHouse.arranged(houses), selectedID: selectedID, select: { selectedID = $0 }).frame(height: 370) }
            Text("Ô móng · khối bố trí; chưa có mô hình gốc của máy và Dino").font(.caption).foregroundStyle(.secondary)
            if let index = houses.firstIndex(where: { $0.id == selectedID }) {
                HStack { Text(houses[index].title).font(.headline); Spacer(); Button("Xem công năng") { select(selectedID) } }
                HStack {
                    Stepper("Ngang \(houses[index].width)", value: $houses[index].width, in: 2...12)
                    Stepper("Sâu \(houses[index].depth)", value: $houses[index].depth, in: 2...12)
                }.font(.callout)
                Stepper("Cao \(houses[index].levels) ô tường", value: $houses[index].levels, in: 1...5).font(.callout)
            }
            DisclosureGroup {
                Text("Mỗi nhà: móng kín, mái kín, một cửa người; chưa gồm cửa Dino lớn, nhà kính, nội thất và máy.").font(.caption).foregroundStyle(.secondary)
                HStack(spacing: 12) {
                    ForEach(BaseBill.materials(houses), id: \.0) { name,count in
                        VStack { FactTile(match: VisualFacts.items([name])[0]); Text("×\(count)").monospacedDigit().font(.headline).accessibilityIdentifier("base-material-"+name).accessibilityValue(String(count)) }
                    }
                }.padding(.vertical, 10)
            } label: { Text("Vật liệu khung 5 nhà").accessibilityIdentifier("base-materials") }
        }.onAppear { if let data = saved.data(using:.utf8), let values = try? JSONDecoder().decode([BaseHouse].self,from:data), values.count == 5 { houses = values } }
        .onChange(of: houses.map { "\($0.width)-\($0.depth)-\($0.levels)" }) { _,_ in persist() }
    }
    private func persist() { if let data = try? JSONEncoder().encode(houses) { saved = String(decoding:data,as:UTF8.self) } }
}
struct BaseFloorplan: View {
    let houses: [BaseHouse]; let selectedID: String; let select: (String)->Void
    var body: some View {
        GeometryReader { proxy in
            let scale = min(proxy.size.width / CGFloat(max(24, houses.map {$0.x+$0.width}.max() ?? 24)), proxy.size.height / CGFloat(max(19,houses.map {$0.z+$0.depth}.max() ?? 19)))
            ZStack(alignment:.topLeading) {
                Canvas { ctx,size in
                    for x in stride(from:CGFloat.zero,through:size.width,by:scale) { var p=Path();p.move(to:CGPoint(x:x,y:0));p.addLine(to:CGPoint(x:x,y:size.height));ctx.stroke(p,with:.color(.white.opacity(0.07)),lineWidth:0.5) }
                    for y in stride(from:CGFloat.zero,through:size.height,by:scale) { var p=Path();p.move(to:CGPoint(x:0,y:y));p.addLine(to:CGPoint(x:size.width,y:y));ctx.stroke(p,with:.color(.white.opacity(0.07)),lineWidth:0.5) }
                }
                ForEach(houses) { h in
                    Button { select(h.id) } label: {
                        VStack(spacing:4) { Text(h.title).font(.caption.bold()); Text("\(h.width) × \(h.depth)").font(.caption2).monospacedDigit() }
                            .frame(width:CGFloat(h.width)*scale,height:CGFloat(h.depth)*scale)
                            .background(h.id == selectedID ? Color.cyan.opacity(0.3) : Color.white.opacity(0.12))
                            .overlay(Rectangle().stroke(h.id == selectedID ? .cyan : .white.opacity(0.45),lineWidth:2))
                    }.buttonStyle(.plain).offset(x:CGFloat(h.x)*scale,y:CGFloat(h.z)*scale).accessibilityIdentifier("base-layout-"+h.id)
                }
                Text("Lối vận chuyển").font(.caption2).foregroundStyle(.secondary).offset(x:scale*8,y:scale*CGFloat((houses.filter { ["main","garden","industry"].contains($0.id) }.map(\.depth).max() ?? 6) + 2))
            }.clipped()
        }
    }
}
struct BaseSceneView: UIViewRepresentable {
    let houses: [BaseHouse]; let select: (String)->Void
    func makeUIView(context: Context)->SCNView { let v=SCNView();v.allowsCameraControl=true;v.autoenablesDefaultLighting=true;v.backgroundColor = .black; return v }
    func updateUIView(_ v: SCNView,context:Context) {
        let scene=SCNScene()
        for h in houses {
            let geometry=SCNBox(width:CGFloat(h.width),height:CGFloat(h.levels),length:CGFloat(h.depth),chamferRadius:0)
            geometry.firstMaterial?.diffuse.contents = h.id == "garden" ? UIColor.systemGreen.withAlphaComponent(0.5) : UIColor.systemTeal.withAlphaComponent(0.5)
            geometry.firstMaterial?.transparency=0.55
            let node=SCNNode(geometry:geometry);node.name=h.id;node.position=SCNVector3(Float(h.x)+Float(h.width)/2,Float(h.levels)/2,Float(h.z)+Float(h.depth)/2);scene.rootNode.addChildNode(node)
            let slab=SCNBox(width:CGFloat(h.width),height:0.08,length:CGFloat(h.depth),chamferRadius:0);slab.firstMaterial?.diffuse.contents=UIColor.darkGray
            let floor=SCNNode(geometry:slab);floor.position=SCNVector3(node.position.x,0,node.position.z);scene.rootNode.addChildNode(floor)
        }
        let camera=SCNNode();camera.camera=SCNCamera();let width=Float(houses.map {$0.x+$0.width}.max() ?? 20); let depth=Float(houses.map {$0.z+$0.depth}.max() ?? 16); let extent=max(width,depth); camera.position=SCNVector3(width/2+extent,extent*1.1,depth/2+extent);camera.look(at:SCNVector3(width/2,0,depth/2));scene.rootNode.addChildNode(camera)
        v.scene=scene;v.pointOfView=camera
    }
}
