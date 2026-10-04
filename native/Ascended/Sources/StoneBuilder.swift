import SwiftUI

struct StoneBuilder: View {
    let embedded:Bool
    @State private var catalogue=false
    @State private var activeTemplate:String?
    @State private var showParts=false
    @Environment(\.dismiss) private var dismiss
    @AppStorage private var saved:String
    @AppStorage private var previousDesign:String
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
    init(mapID:String,embedded:Bool=false) { self.embedded=embedded;_previousDesign=AppStorage(wrappedValue:"", "ascended.stone-builder.previous."+mapID);_saved=AppStorage(wrappedValue:"", "ascended.stone-builder.v1."+mapID) }
    private var ghost:StonePlacement { StonePlacement(kind:kind,x:x,z:z,level:level,turn:turn) }
    private var current:StoneModel? { StoneKit.shared.models.first {$0.id==kind} }
    var body:some View {
        NavigationStack {
            VStack(spacing:8) {
                templates
                palette
                HStack(alignment:.top,spacing:10) {
                StoneBuildScene(pieces:pieces,selected:selected,ghost:ghost,onPick:pick,onCursor:{ px,pz in selected=nil;x=px;z=pz;message="" })
                    .frame(maxHeight:.infinity).clipShape(RoundedRectangle(cornerRadius:14)).accessibilityIdentifier("stone-builder-scene")
                    if showParts { BuildPartsPanel(pieces:pieces,openBill:{bill=true},close:{showParts=false}).frame(width:210) }
                }
                controls
                if !message.isEmpty { Text(message).font(.caption).foregroundStyle(.orange).accessibilityIdentifier("builder-message") }
                Text(current?.referenceOnly == true ? "Ảnh tham chiếu · chưa có hình khối đo thực tế" : "Tỷ lệ mô phỏng · kéo xoay · chụm hai ngón để zoom").font(.caption).foregroundStyle(.secondary)
            }.padding(12).navigationTitle("Xây base").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement:.topBarLeading) { if !embedded { Button("Đóng") { dismiss() } } }
                ToolbarItem(placement:.topBarTrailing) { HStack {
                    Button { restorePrevious() } label: {Image(systemName:"arrow.uturn.backward.circle")} .disabled(previousDesign.isEmpty).accessibilityLabel("Khôi phục bản trước khi chọn mẫu").accessibilityIdentifier("builder-restore-design")
                    Text("\(pieces.count) món").font(.caption).accessibilityIdentifier("builder-count").accessibilityValue(String(pieces.count))
                    Button { bill=true } label: { Image(systemName:"shippingbox") }.accessibilityLabel("Vật liệu bản thiết kế").accessibilityIdentifier("builder-bill")
                    Button { clear=true } label: { Image(systemName:"trash") }.accessibilityLabel("Xóa bản thiết kế")
                } }
            }
            .sheet(isPresented:$bill) { BuildBillView(pieces:pieces) }
            .sheet(isPresented:$catalogue) { BuildItemPicker {id in kind=id;selected=nil;message=""} }
            .confirmationDialog("Xóa bản thiết kế này?",isPresented:$clear) { Button("Xóa",role:.destructive) { change { pieces=[];selected=nil;activeTemplate=nil;showParts=false } }.accessibilityIdentifier("builder-clear-confirm") }
        }.onAppear { load() }
        .onChange(of:pieces) { _,_ in persist() }
        .preferredColorScheme(.dark)
    }
    private var palette:some View {
        ScrollView(.horizontal) {
            HStack(spacing:8) {
                Button {catalogue=true} label: {VStack {Image(systemName:"square.grid.2x2");Text("Tất cả").font(.caption)}.frame(width:68,height:60)}.accessibilityIdentifier("build-catalogue")
                ForEach(["stone-foundation","stone-wall","stone-doorframe","reinforced-wooden-door","stone-ceiling","sloped-stone-roof","stone-ramp","stone-pillar","stone-windowframe","stone-triangle-foundation","stone-triangle-ceiling"].compactMap {id in StoneKit.shared.models.first {$0.id==id}}) { model in
                    Button { kind=model.id;selected=nil;message="" } label: {
                        VStack(spacing:4) {
                            if let asset=model.asset { Image(asset).resizable().scaledToFit().frame(width:44,height:34) }
                            Text(model.title).font(.caption)
                        }.frame(width:80,height:60).background(kind==model.id ? Color.cyan.opacity(0.22):Color.white.opacity(0.06)).clipShape(RoundedRectangle(cornerRadius:8))
                            .overlay(RoundedRectangle(cornerRadius:8).stroke(kind==model.id ? Color.cyan:.clear,lineWidth:2))
                    }.buttonStyle(.plain).accessibilityIdentifier("builder-kind-"+model.id)
                }
            }
        }
    }
    private var controls:some View {
        VStack(spacing:8) {
            HStack {
                Text(current?.title ?? "Stone").font(.caption).lineLimit(1).frame(maxWidth:150)
                Spacer()
                Stepper("↔ \(x.formatted())",value:$x,in:-6...6,step:0.5).frame(maxWidth:.infinity).accessibilityIdentifier("builder-x")
                Stepper("↕ \(z.formatted())",value:$z,in:-6...6,step:0.5).frame(maxWidth:.infinity).accessibilityIdentifier("builder-z")
                Stepper("Tầng \(level)",value:$level,in:0...8).frame(maxWidth:.infinity).accessibilityIdentifier("builder-level")
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
    private var templates:some View {
        ScrollView(.horizontal) {
            HStack(spacing:8) {
                ForEach(BuildTemplate.all) {t in
                    Button { previousDesign=saved;change {pieces=t.pieces;selected=nil;activeTemplate=t.id;showParts=true} } label: {
                        VStack(spacing:4) {BuildTemplatePreview(template:t).frame(width:150,height:94).clipShape(RoundedRectangle(cornerRadius:9));Text(t.title).font(.caption)}
                            .padding(5).background(activeTemplate==t.id ? Color.cyan.opacity(0.18):Color.white.opacity(0.04),in:RoundedRectangle(cornerRadius:10))
                    }.buttonStyle(.plain).accessibilityIdentifier("build-template-"+t.id)
                }
            }
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
    private func restorePrevious() {
        guard let data=previousDesign.data(using:.utf8),let old=try? JSONDecoder().decode([StonePlacement].self,from:data) else{return}
        let current=saved;change {pieces=old;selected=nil;activeTemplate=nil;showParts=false};previousDesign=current
    }
    private func persist() { if let data=try? JSONEncoder().encode(pieces) {saved=String(decoding:data,as:UTF8.self)} }
    private func load() {
        guard let data=saved.data(using:.utf8),let values=try? JSONDecoder().decode([StonePlacement].self,from:data) else{return}
        pieces=Array(values.filter { p in StoneKit.shared.models.contains {$0.id==p.kind} && p.x.isFinite && p.z.isFinite && abs(p.x)<=6 && abs(p.z)<=6 && (0...8).contains(p.level) && (0...3).contains(p.turn) }.prefix(500))
    }
}
