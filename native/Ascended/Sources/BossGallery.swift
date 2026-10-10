import SwiftUI
import UIKit

extension ArkMap {
    var orderedBossIDs: [String] {
        var seen=Set<String>()
        return ((campaign?.steps.flatMap(\.bossIDs) ?? []) + bosses.map(\.id)).filter { seen.insert($0).inserted }
    }
    func bossPortrait(_ id: String) -> String {
        if let record=AtlasPhoto.all.first(where:{$0.bossID==id}), UIImage(named:record.asset) != nil { return record.asset }
        if UIImage(named:"Cutout-Boss-"+id) != nil { return "Cutout-Boss-"+id }
        if id == "nunatak" { return "Nunatak-Gamma" }
        if UIImage(named:"Game-Boss-"+id) != nil { return "Game-Boss-"+id }
        return bossImage(id)
    }
}

struct BossGalleryScreen: View {
    @Environment(\.arkMap) private var map
    @State private var selected: String?
    var body: some View {
        GeometryReader { geometry in
            let ids=map.orderedBossIDs
            let columns=ids.count <= 2 ? max(1,ids.count) : ids.count <= 4 ? 2 : 3
            let rows=max(1,Int(ceil(Double(ids.count)/Double(columns))))
            LazyVGrid(columns:Array(repeating:GridItem(.flexible(),spacing:14),count:columns),spacing:14) {
                ForEach(Array(ids.enumerated()),id:\.element) { index,id in
                    Button { selected=id } label: {
                        VStack(spacing:8) {
                            if UIImage(named:map.bossPortrait(id)) != nil {
                                Image(map.bossPortrait(id)).renderingMode(map.bossPortrait(id).hasPrefix("Boss-") ? .template : .original).resizable().scaledToFit().foregroundStyle(.cyan).frame(maxWidth:.infinity,maxHeight:.infinity)
                            } else {
                                Image("AtlasLayer-bosses").resizable().scaledToFit().frame(maxWidth:.infinity,maxHeight:.infinity)
                                Text("Portrait pending").font(.caption2).foregroundStyle(.secondary)
                            }
                            HStack { Text(String(index+1)).font(.caption.bold()).foregroundStyle(.cyan); Text(map.bossName(id)).font(.headline); Spacer(minLength:0) }
                        }.padding(14).frame(height:max(90,(geometry.size.height-40-Double(rows-1)*14)/Double(rows)))
                            .background(Color.white.opacity(0.055),in:RoundedRectangle(cornerRadius:18))
                            .overlay(RoundedRectangle(cornerRadius:18).stroke(.cyan.opacity(0.15)))
                    }.buttonStyle(.plain).accessibilityIdentifier("boss-card-"+id)
                }
            }.padding(20)
            .overlay { if ids.isEmpty { Text("Boss encounters are not verified for this map yet.").foregroundStyle(.secondary) } }
        }.fullScreenCover(item: Binding(get:{selected.map { BossSelection(id:$0) }},set:{selected=$0?.id})) { boss in
            if let guide = BossBattleGuide.find(map: map, bossID: boss.id) {
                BossBattleScreen(guide: guide).environment(\.arkMap,map)
            } else {
                BossGalleryDetail(bossID:boss.id).environment(\.arkMap,map)
            }
        }.onChange(of:map) { _,_ in selected=nil }
    }
}
private struct BossSelection: Identifiable { let id:String }

struct BossGalleryDetail: View {
    let bossID:String
    @Environment(\.arkMap) private var map
    @Environment(\.dismiss) private var dismiss
    @State private var tab="Army"
    @State private var difficulty=0
    @State private var option=0
    @State private var locationID:String?
    private var boss:MapBoss? {map.bosses.first {$0.id==bossID}}
    private var army:BossArmyGuide? {map.campaign?.loadouts.first {$0.bossID==bossID}}
    private var points:[MapLocation] {
        let all=MapLocation.all(in:map)
        let matches=all.filter {$0.bossID==bossID || $0.id=="boss-lava-arena" && bossID=="lava-elemental"}
        if !matches.isEmpty {return matches}
        let routeID=boss?.entranceID ?? (bossID=="iceworm-queen" ? "frozen":bossID=="lava-elemental" ? "jungle":bossID.hasPrefix("spirit-") ? "labyrinth":"")
        return all.filter {$0.routeID==routeID && $0.layer == .cave}
    }
    var body:some View {
        VStack(spacing:16) {
            HStack {
                Image(map.bossPortrait(bossID)).resizable().scaledToFit().frame(width:120,height:100)
                Text(map.bossName(bossID)).font(.largeTitle.bold()); Spacer()
                Button {dismiss()} label:{Image(systemName:"xmark.circle.fill").font(.title)}.accessibilityLabel("Close boss")
            }
            if map.bossPortrait(bossID).hasPrefix("Portrait-") { Text("Illustrated boss portrait").font(.caption2).foregroundStyle(.secondary) }
            Picker("Boss details",selection:$tab) {
                Label("Army",systemImage:"pawprint.fill").tag("Army")
                Label("Tribute",systemImage:"diamond.fill").tag("Tribute")
                Label("Location",systemImage:"map.fill").tag("Location")
                Label("Combat",systemImage:"flame.fill").tag("Combat")
            }.pickerStyle(.segmented).accessibilityIdentifier("boss-detail-tabs")
            if boss != nil || bossID=="nunatak" {
                Picker("Difficulty",selection:$difficulty) {ForEach(0..<3) {Text(["Gamma","Beta","Alpha"][$0]).tag($0)}}.pickerStyle(.segmented)
            }
            ScrollView {
                VStack(alignment:.leading,spacing:14) {
                    switch tab {
                    case "Army": armyPanel
                    case "Tribute": tributePanel
                    case "Location": locationPanel
                    default: combatPanel
                    }
                }.frame(maxWidth:.infinity,alignment:.leading)
            }
        }.padding(24).presentationDetents([.large]).presentationDragIndicator(.visible).accessibilityIdentifier("boss-gallery-detail")
    }
    @ViewBuilder private var armyPanel:some View {
        if let army, !army.options.isEmpty {
            Picker("Army plan",selection:$option) { ForEach(Array(army.options.enumerated()),id:\.offset) {i,row in Text(row.title).tag(i)} }.pickerStyle(.menu)
            let plan=army.options[min(option,army.options.count-1)]
            VisualTeam(text:plan.team)
            if let target=plan.targets.first(where:{$0.difficulty==["Gamma","Beta","Alpha"][difficulty]}) {
                HStack(spacing:24) {
                    Label(target.hp,systemImage:"heart.fill")
                    Label(target.melee,systemImage:"bolt.fill")
                    Label(target.saddle,systemImage:"shield.fill")
                }.font(.headline).foregroundStyle(.cyan).padding(14).background(.white.opacity(0.05),in:RoundedRectangle(cornerRadius:12))
                Text(target.extra).font(.subheadline).foregroundStyle(.secondary)
            }
            Text("Suggested team • adjust for your difficulty and save settings").font(.caption).foregroundStyle(.secondary)
        } else { Text("A reliable creature count has not been verified for this encounter.").foregroundStyle(.secondary) }
    }
    @ViewBuilder private var tributePanel:some View {
        if let boss {
            ForEach(boss.artifactIDs,id:\.self) {id in
                if let artifact=map.exploration?.artifacts.first(where:{$0.id==id}) {
                    HStack {Image(artifact.imageAsset).resizable().scaledToFit().frame(width:44,height:44);Text(artifact.name);Spacer();Text("×1").bold()}.padding(8)
                }
            }
            ForEach(boss.tribute.filter {$0.quantities.indices.contains(difficulty) && $0.quantities[difficulty]>0}) { row in
                HStack {VisualBrief(text:row.name);Spacer();Text("×\(row.quantities[difficulty])").bold()}.padding(8)
            }
            if boss.artifactIDs.isEmpty && boss.tribute.isEmpty {Text("Tribute requirements have not been verified.").foregroundStyle(.secondary)}
        } else if bossID=="nunatak" {
            ForEach(map.exploration?.artifacts ?? []) {artifact in
                HStack {Image(artifact.imageAsset).resizable().scaledToFit().frame(width:44,height:44);Text(artifact.name);Spacer();Text("×1").bold()}
            }
            if difficulty>0 {ForEach(["Argentavis Talon","Basilosaurus Blubber","Megalania Toxin","Megalodon Tooth","Sarcosuchus Skin","Sauropod Vertebra","Spinosaurus Sail","Thylacoleo Hook-Claw","Titanoboa Venom","Tusoteuthis Tentacle"],id:\.self) {name in HStack {VisualBrief(text:name);Spacer();Text(difficulty==1 ? "×10":"×25").bold()}}}
        } else {Text("No verified summoning tribute table for this encounter.").foregroundStyle(.secondary)}
    }
    @ViewBuilder private var locationPanel:some View {
        let selected=points.first {$0.id==locationID} ?? points.first
        ZoomableMap(imageAsset:map.imageAsset,mapName:map.name,resetToken:UUID(),action:.fit,locations:points,focusID:nil,select:{locationID=$0.id},highlightID:selected?.id)
            .frame(width:330,height:330).frame(maxWidth:.infinity).clipShape(RoundedRectangle(cornerRadius:16)).accessibilityIdentifier("boss-location-map")
        if let selected {HStack {Text(selected.name).bold();GPSBadge(coordinates:selected.coordinates)};Text(selected.note).font(.caption).foregroundStyle(.secondary)}
        else {Text("An exact atlas coordinate has not been verified for this encounter.").foregroundStyle(.secondary)}
        Text(boss?.location ?? RagnarokBoss.all.first {$0.id==bossID}?.location ?? "Use the verified encounter entrance or summoning terminal.").font(.subheadline)
    }
    @ViewBuilder private var combatPanel:some View {
        if let boss { ForEach(boss.strategy,id:\.self) {Text($0).padding(10).background(.white.opacity(0.05),in:RoundedRectangle(cornerRadius:10))} }
        else if let army {Text(army.warning);if let plan=army.options.first {Text(plan.play)}}
        else {Text("A current combat strategy has not been verified yet.").foregroundStyle(.secondary)}
    }
}
