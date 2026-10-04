import SwiftUI

struct StoneBuilder: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage private var saved:String
    @State private var pieces:[StonePlacement]=[]
    @State private var history:[[StonePlacement]]=[]
    @State private var selected:UUID?
    @State private var kind="stone-foundation"
    @State private var x=0.0
    @State private var z=0.0
    @State private var level=0
    @State private var turn=0
    @State private var message=""
    @State private var bill=false
    @State private var clear=false
    init(mapID:String) { _saved=AppStorage(wrappedValue:"", "ascended.stone-builder.v1."+mapID) }
    private var ghost:StonePlacement { StonePlacement(kind:kind,x:x,z:z,level:level,turn:turn) }
    private var current:StoneModel? { StoneKit.shared.models.first {$0.id==kind} }
    var body:some View {
        NavigationStack {
            VStack(spacing:12) {
                palette
                StoneBuildScene(pieces:pieces,selected:selected,ghost:ghost,onPick:pick,onCursor:{ px,pz in selected=nil;x=px;z=pz;message="" })
                    .frame(maxHeight:.infinity).accessibilityIdentifier("stone-builder-scene")
                controls
                if !message.isEmpty { Text(message).font(.caption).foregroundStyle(.orange).accessibilityIdentifier("builder-message") }
                Text("Chạm mặt đất để chọn ô · chạm cấu kiện để sửa · kéo để xoay góc nhìn").font(.caption).foregroundStyle(.secondary)
            }.padding(16).navigationTitle("Xây Stone").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement:.topBarLeading) { Button("Đóng") { dismiss() } }
                ToolbarItem(placement:.topBarTrailing) { HStack {
                    Text("\(pieces.count) món · đã lưu").font(.caption).accessibilityIdentifier("builder-count").accessibilityValue(String(pieces.count))
                    Button { bill=true } label: { Image(systemName:"shippingbox") }.accessibilityLabel("Vật liệu bản thiết kế").accessibilityIdentifier("builder-bill")
                    Button { clear=true } label: { Image(systemName:"trash") }.accessibilityLabel("Xóa bản thiết kế")
                } }
            }
            .sheet(isPresented:$bill) { budget }
            .confirmationDialog("Xóa bản thiết kế này?",isPresented:$clear) { Button("Xóa",role:.destructive) { change { pieces=[];selected=nil } } }
        }.onAppear { load() }
        .onChange(of:pieces) { _,_ in persist() }
        .preferredColorScheme(.dark)
    }
    private var palette:some View {
        ScrollView(.horizontal) {
            HStack(spacing:8) {
                ForEach(StoneKit.shared.models) { model in
                    Button { kind=model.id;selected=nil;message="" } label: {
                        VStack(spacing:4) {
                            if let asset=model.asset { Image(asset).resizable().scaledToFit().frame(width:58,height:48) }
                            Text(model.title).font(.caption)
                        }.frame(width:96,height:78).background(kind==model.id ? Color.cyan.opacity(0.22):Color.white.opacity(0.06)).clipShape(RoundedRectangle(cornerRadius:8))
                            .overlay(RoundedRectangle(cornerRadius:8).stroke(kind==model.id ? Color.cyan:.clear,lineWidth:2))
                    }.buttonStyle(.plain).accessibilityIdentifier("builder-kind-"+model.id)
                }
            }
        }
    }
    private var controls:some View {
        VStack(spacing:8) {
            HStack {
                Text(current?.title ?? "Stone").font(.headline)
                Spacer()
                Stepper("↔ \(x.formatted())",value:$x,in:-6...6,step:0.5).frame(maxWidth:.infinity).accessibilityIdentifier("builder-x")
                Stepper("↕ \(z.formatted())",value:$z,in:-6...6,step:0.5).frame(maxWidth:.infinity).accessibilityIdentifier("builder-z")
                Stepper("Tầng \(level)",value:$level,in:0...5).frame(maxWidth:.infinity).accessibilityIdentifier("builder-level")
            }
            HStack(spacing:16) {
                Button { turn=(turn+1)%4 } label: { Label("\(turn*90)°",systemImage:"rotate.right") }.accessibilityIdentifier("builder-rotate")
                Button(selected == nil ? "Đặt" : "Di chuyển") { apply() }.buttonStyle(.borderedProminent).accessibilityIdentifier("builder-place")
                Button { duplicate() } label: { Label("Nhân bản",systemImage:"plus.square.on.square") }.disabled(selected==nil).accessibilityIdentifier("builder-copy")
                Button { if let id=selected { change { pieces.removeAll {$0.id==id};selected=nil } } } label: { Label("Xóa",systemImage:"trash") }.disabled(selected==nil).accessibilityIdentifier("builder-delete")
                Button { if let last=history.popLast() { pieces=last;selected=nil;message="" } } label: { Image(systemName:"arrow.uturn.backward") }.disabled(history.isEmpty).accessibilityLabel("Hoàn tác").accessibilityIdentifier("builder-undo")
                if selected != nil { Button("Bỏ chọn") { selected=nil } }
            }
        }
    }
    private var budget:some View {
        NavigationStack {
            List {
                Section("Nguyên liệu") {
                    ForEach(StoneBudget.materials(pieces),id:\.0) { name,count in
                        HStack { FactTile(match:VisualFacts.items([name])[0]);Spacer();Text("×\(count)").font(.title2).monospacedDigit().accessibilityIdentifier("builder-material-"+name).accessibilityValue(String(count)) }
                    }
                }
                Section("Cấu kiện") {
                    ForEach(StoneKit.shared.models) { m in
                        let count=pieces.filter {$0.kind==m.id}.count
                        if count>0 { HStack { Text(m.title);Spacer();Text("×\(count)") } }
                    }
                }
                Text("Công thức engram ASA thường · chưa gồm máy, nhiên liệu hay blueprint có hệ số khác. Model và tỷ lệ dựng lại; bố trí chưa kiểm tra chịu lực hoặc va chạm trong game.").font(.caption).foregroundStyle(.secondary)
            }.navigationTitle("Vật liệu").toolbar { Button("Xong") { bill=false } }
        }
    }
    private func pick(_ id:UUID) {
        guard let p=pieces.first(where:{$0.id==id}) else { return }
        selected=id;kind=p.kind;x=p.x;z=p.z;level=p.level;turn=p.turn;message=""
    }
    private func change(_ edit:()->Void) { history.append(pieces);if history.count>50 {history.removeFirst()};edit();message="" }
    private func apply() {
        let p=ghost
        if pieces.contains(where:{$0.id != selected && $0.occupiesSameSlot(as:p)}) {message="Ô này đã có cấu kiện cùng loại và góc xoay.";return}
        if let id=selected,let i=pieces.firstIndex(where:{$0.id==id}) { change { pieces[i]=StonePlacement(id:id,kind:kind,x:x,z:z,level:level,turn:turn) } }
        else if pieces.count<500 { let added=p;change {pieces.append(added);selected=added.id} }
        else {message="Bản thiết kế đã đạt 500 cấu kiện."}
    }
    private func duplicate() {
        guard let id=selected,let original=pieces.first(where:{$0.id==id}) else{return}
        guard pieces.count<500 else {message="Bản thiết kế đã đạt 500 cấu kiện.";return}
        let candidates=Array(stride(from:original.x+1,through:6,by:0.5)) + (original.x+0.5<=6 ? [original.x+0.5] : [])
        guard let next=candidates.first(where:{newX in !pieces.contains(where:{$0.occupiesSameSlot(as:StonePlacement(kind:original.kind,x:newX,z:original.z,level:original.level,turn:original.turn))})}) else {message="Không còn ô trống bên phải; chọn vị trí khác để đặt.";return}
        let p=StonePlacement(kind:original.kind,x:next,z:original.z,level:original.level,turn:original.turn)
        change {pieces.append(p);selected=p.id;x=p.x;z=p.z;level=p.level;turn=p.turn}
    }
    private func persist() { if let data=try? JSONEncoder().encode(pieces) {saved=String(decoding:data,as:UTF8.self)} }
    private func load() {
        guard let data=saved.data(using:.utf8),let values=try? JSONDecoder().decode([StonePlacement].self,from:data) else{return}
        pieces=Array(values.filter { p in StoneKit.shared.models.contains {$0.id==p.kind} && p.x.isFinite && p.z.isFinite && abs(p.x)<=6 && abs(p.z)<=6 && (0...5).contains(p.level) && (0...3).contains(p.turn) }.prefix(500))
    }
}
