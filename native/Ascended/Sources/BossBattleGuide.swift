import SwiftUI
import WebKit

struct BossBattleGuide: Decodable, Identifiable {
    let mapID: String
    let bossID: String
    let encounter: String
    let entry: String
    let armies: [BattleArmy]
    let kit: [BattleSupply]
    let combat: [BattleStep]
    let videos: [BattleVideo]
    let sources: [GuideEvidence]
    var id: String { mapID + ":" + bossID }
    static let all = (try? ArkMap.load([BossBattleGuide].self, name: "boss-battle-guides")) ?? []
    static func find(map: ArkMap, bossID: String) -> BossBattleGuide? {
        all.first { $0.mapID == map.rawValue && $0.bossID == bossID }
    }
}
struct BattleArmy: Decodable, Identifiable {
    let id: String
    let title: String
    let members: [BattleSupply]
    let note: String
    let targetOptionID: String?
    var tameCount: Int { members.filter { $0.kind == "tame" }.reduce(0) { $0 + (Int($1.quantity) ?? 0) } }
}
struct BattleSupply: Decodable, Identifiable {
    let name: String
    let quantity: String
    let role: String
    let kind: String
    var id: String { name + role }
    var fact: VisualFact { VisualFacts.items([name])[0].fact }
}
struct BattleStep: Decodable, Identifiable {
    let title: String
    let action: String
    let symbol: String
    var id: String { title }
}
struct BattleVideo: Decodable, Identifiable {
    let videoID: String
    let title: String
    let channel: String
    let tier: String
    let duration: Int
    let note: String
    let segments: [BattleVideoSegment]
    var id: String { videoID }
    var briefSeconds: Int { segments.reduce(0) { $0 + $1.end - $1.start } }
    var url: URL { URL(string: "https://www.youtube.com/watch?v=\(videoID)&t=\(segments.first?.start ?? 0)s")! }
}
struct BattleVideoSegment: Codable, Identifiable {
    let title: String
    let start: Int
    let end: Int
    var id: Int { start }
}

struct BossBattleScreen: View {
    let guide: BossBattleGuide
    @Environment(\.arkMap) private var map
    @Environment(\.dismiss) private var dismiss
    @State private var tab = "Army"
    @State private var difficulty = 0
    @State private var armyIndex = 0
    @State private var videoIndex = 0
    @State private var showSources = false
    @State private var locationID: String?
    @State private var resetToken = UUID()
    private let tiers = ["Gamma", "Beta", "Alpha"]
    private var boss: MapBoss? { map.bosses.first { $0.id == guide.bossID } }
    private var tiered: Bool { boss != nil || guide.bossID == "nunatak" }
    private var army: BattleArmy { guide.armies[armyIndex] }
    private var targets: [ArmyTarget] {
        guard let optionID = army.targetOptionID else { return [] }
        return map.campaign?.loadouts.first { $0.bossID == guide.bossID }?.options.first { $0.id == optionID }?.targets ?? []
    }
    private var selectedTargets: [ArmyTarget] {
        let matching = targets.filter { $0.difficulty.contains(tiers[difficulty]) }
        return matching.isEmpty ? targets.filter { !$0.difficulty.contains("Gamma") && !$0.difficulty.contains("Beta") && !$0.difficulty.contains("Alpha") } : matching
    }
    private var points: [MapLocation] {
        let all = MapLocation.all(in: map)
        let matched = all.filter { $0.bossID == guide.bossID }
        if !matched.isEmpty { return matched }
        let route = guide.bossID == "iceworm-queen" ? "frozen" : guide.bossID == "lava-elemental" ? "jungle" : "labyrinth"
        return all.filter { $0.routeID == route && $0.layer == .cave }
    }
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                HStack(spacing: 14) {
                    Image(map.bossPortrait(guide.bossID)).resizable().scaledToFit().frame(width: 74, height: 66)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(map.bossName(guide.bossID)).font(.system(size: geo.size.width > 800 ? 36 : 28, weight: .bold, design: .rounded))
                        Text(map.name + " · " + guide.encounter).font(.subheadline).foregroundStyle(.cyan)
                    }
                    Spacer()
                    Button { showSources.toggle() } label: { Image(systemName: "info.circle").font(.title2).frame(width: 44, height: 44) }.accessibilityLabel("Boss sources")
                    Button { dismiss() } label: { Image(systemName: "xmark").font(.title2.bold()).frame(width: 48, height: 48).background(.white.opacity(0.08), in: Circle()) }.accessibilityLabel("Close boss")
                }.padding(.horizontal, 24).padding(.vertical, 12)
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        if geo.size.width > 850 {
                            HStack(alignment: .top, spacing: 20) {
                                videoPanel.frame(width: max(480, geo.size.width * 0.52 - 24))
                                entryPanel.frame(maxWidth: .infinity)
                            }
                        } else {
                            videoPanel
                            entryPanel
                        }
                        HStack(spacing: 10) {
                            ForEach([("Army", "pawprint.fill"), ("Preparation", "backpack.fill"), ("Tribute", "diamond.fill"), ("Location", "map.fill"), ("Combat", "flame.fill")], id: \.0) { title, icon in
                                Button { tab = title } label: {
                                    Label(title, systemImage: icon).font(.system(size: geo.size.width > 800 ? 19 : 15, weight: .semibold))
                                        .frame(maxWidth: .infinity).padding(.vertical, 15)
                                        .background(tab == title ? Color.cyan.opacity(0.18) : Color.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 13))
                                        .overlay(RoundedRectangle(cornerRadius: 13).stroke(tab == title ? Color.cyan : Color.clear))
                                }.buttonStyle(.plain).accessibilityIdentifier("battle-tab-" + title)
                            }
                        }
                        Group {
                            switch tab {
                            case "Army": armyPanel
                            case "Preparation": preparationPanel
                            case "Tribute": tributePanel
                            case "Location": locationPanel(width: geo.size.width - 48)
                            default: combatPanel
                            }
                        }.padding(20).frame(maxWidth: .infinity, alignment: .leading)
                            .background(.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 20))
                    }.padding(.horizontal, 24).padding(.bottom, 24)
                }.accessibilityIdentifier("battle-content")
            }.background(Color(red: 0.025, green: 0.045, blue: 0.055))
                .sheet(isPresented: $showSources) {
                    NavigationStack {
                        List {
                            Section("Fight videos") {
                                ForEach(guide.videos) { v in
                                    VStack(alignment: .leading, spacing: 8) { Link(v.channel + " · " + v.title, destination: v.url); Text(v.note).font(.caption).foregroundStyle(.secondary) }
                                }
                            }
                            Section("Army & mechanics") {
                                ForEach(guide.sources) { s in
                                    VStack(alignment: .leading, spacing: 8) { if let u = URL(string: s.url) { Link(s.title, destination: u) }; Text(s.note).font(.caption).foregroundStyle(.secondary) }
                                }
                            }
                        }.navigationTitle("Sources").toolbar { Button("Done") { showSources = false } }
                    }
                }
        }
    }
    private var videoPanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            if !guide.videos.isEmpty {
                let video = guide.videos[min(videoIndex, guide.videos.count - 1)]
                BattleVideoPanel(video: video)
                if guide.videos.count > 1 {
                    Picker("Fight video", selection: $videoIndex) { ForEach(Array(guide.videos.enumerated()), id: \.offset) { i, v in Text(v.tier + " · " + v.channel).tag(i) } }.pickerStyle(.menu)
                }
            }
        }
    }
    private var entryPanel: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("YOUR BATTLE PLAN").font(.caption.bold()).tracking(2).foregroundStyle(.cyan)
            Text(guide.entry).font(.title3.weight(.medium)).fixedSize(horizontal: false, vertical: true)
            if tiered {
                Picker("Difficulty", selection: $difficulty) { ForEach(0..<3) { Text(tiers[$0]).tag($0) } }.pickerStyle(.segmented).accessibilityIdentifier("battle-difficulty")
                HStack(spacing: 22) {
                    if let level = boss?.levels[safe: difficulty] { metric("Entry level", String(level), "person.fill") }
                    if let element = boss?.elements[safe: difficulty] { metric("Element", String(element), "cube.fill") }
                    if guide.bossID == "nunatak" { metric("Entry level", String([70,80,90][difficulty]), "person.fill"); metric("Element", String([100,275,550][difficulty]), "cube.fill") }
                }
            } else { Label("Dungeon encounter · one difficulty", systemImage: "mountain.2.fill").font(.headline).foregroundStyle(.orange) }
            Text("Choose your team, pack your kit, then follow the approach and fight steps.").font(.subheadline).foregroundStyle(.secondary)
        }.padding(20).frame(maxWidth: .infinity, alignment: .leading).background(.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 20))
    }
    private var armyPanel: some View {
        VStack(alignment: .leading, spacing: 16) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Array(guide.armies.enumerated()), id: \.offset) { i, a in
                        Button { armyIndex = i } label: { Text(a.title).font(.headline).padding(13).background(armyIndex == i ? Color.cyan.opacity(0.18) : Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 12)) }.buttonStyle(.plain).accessibilityIdentifier("battle-army-" + a.id)
                    }
                }
            }
            HStack { Text(army.title).font(.title2.bold()); Spacer(); Text("\(army.tameCount) tames").font(.title3.bold()).foregroundStyle(.cyan).accessibilityIdentifier("battle-tame-count") }
            supplies(army.members)
            ForEach(selectedTargets) { t in
                HStack(spacing: 28) { metric("Health", t.hp, "heart.fill"); metric("Melee", t.melee, "bolt.fill"); metric("Saddle armor", t.saddle, "shield.fill") }
                if !t.extra.isEmpty { Text(t.extra.replacingOccurrences(of: "/ con", with: "/ tame")).font(.subheadline).foregroundStyle(.secondary) }
            }
            Text(army.note).font(.subheadline).foregroundStyle(.secondary)
            if !targets.isEmpty { Text("Preparation targets after imprinting & leveling · not guaranteed minimums").font(.caption).foregroundStyle(.secondary) }
        }
    }
    private var preparationPanel: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Pack before you leave", systemImage: "backpack.fill").font(.title2.bold())
            supplies(guide.kit)
            Text("Packing amounts are planning budgets; weapon damage, durability, difficulty and save settings change what you need.").font(.caption).foregroundStyle(.secondary)
            Label("Full health · fed · saddled · whistle groups ready", systemImage: "checkmark.seal.fill").font(.headline).foregroundStyle(.cyan)
        }
    }
    @ViewBuilder private var tributePanel: some View {
        if let boss {
            VStack(alignment: .leading, spacing: 14) {
                Label("Summon · " + tiers[difficulty], systemImage: "diamond.fill").font(.title2.bold())
                supplies(boss.artifactIDs.compactMap { id in
                    guard let a = map.exploration?.artifacts.first(where: { $0.id == id }) else { return nil }
                    return BattleSupply(name: a.name, quantity: "1", role: "Artifact", kind: "item")
                } + boss.tribute.filter { $0.quantities.indices.contains(difficulty) && $0.quantities[difficulty] > 0 }.map { BattleSupply(name: $0.name, quantity: String($0.quantities[difficulty]), role: "Tribute", kind: "item") })
            }
        } else if guide.bossID == "nunatak" {
            let names = ["Argentavis Talon", "Basilosaurus Blubber", "Megalania Toxin", "Megalodon Tooth", "Sarcosuchus Skin", "Sauropod Vertebra", "Spinosaurus Sail", "Thylacoleo Hook-Claw", "Titanoboa Venom", "Tusoteuthis Tentacle"]
            VStack(alignment: .leading, spacing: 14) {
                Text("Nunatak · " + tiers[difficulty]).font(.title2.bold())
                supplies((map.exploration?.artifacts ?? []).map { BattleSupply(name: $0.name, quantity: "1", role: "Artifact", kind: "item") })
                if difficulty > 0 { supplies(names.map { BattleSupply(name: $0, quantity: difficulty == 1 ? "10" : "25", role: "Tribute", kind: "item") }) }
            }
        } else {
            Label("No arena tribute · follow the dungeon trigger", systemImage: "door.left.hand.open").font(.title2.bold())
        }
    }
    private func locationPanel(width: CGFloat) -> some View {
        let selected = points.first { $0.id == locationID } ?? points.first
        let size = min(width > 800 ? width * 0.44 : width - 40, 480)
        return ViewThatFits(in: .horizontal) {
            HStack(alignment: .top, spacing: 22) { locationMap(size: size, selected: selected); locationNotes(selected: selected).frame(minWidth: 280, maxWidth: .infinity) }
            VStack(alignment: .leading, spacing: 18) { locationMap(size: size, selected: selected); locationNotes(selected: selected) }
        }
    }
    private func locationMap(size: CGFloat, selected: MapLocation?) -> some View {
        ZoomableMap(imageAsset: map.imageAsset, mapName: map.name, resetToken: resetToken, action: .fit, locations: points, focusID: nil, select: { locationID = $0.id }, highlightID: selected?.id)
            .frame(width: size, height: size).clipShape(RoundedRectangle(cornerRadius: 18)).accessibilityIdentifier("boss-location-map")
    }
    private func locationNotes(selected: MapLocation?) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Approach & entry", systemImage: "map.fill").font(.title2.bold())
            ForEach(points) { p in
                Button { locationID = p.id } label: { VStack(alignment: .leading, spacing: 8) { Text(p.name).font(.headline); GPSBadge(coordinates: p.coordinates) }.padding(14).frame(maxWidth: .infinity, alignment: .leading).background(locationID == p.id || selected?.id == p.id ? Color.cyan.opacity(0.12) : Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 12)) }.buttonStyle(.plain)
            }
            Text(boss?.location ?? RagnarokBoss.all.first { $0.id == guide.bossID }?.location ?? guide.entry).font(.subheadline)
            if let selected { Text(selected.note).font(.caption).foregroundStyle(.secondary) }
        }
    }
    private var combatPanel: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 260), alignment: .top)], alignment: .leading, spacing: 14) {
            ForEach(Array(guide.combat.enumerated()), id: \.element.id) { i, step in
                VStack(alignment: .leading, spacing: 12) {
                    HStack { Image(systemName: step.symbol).font(.title2).foregroundStyle(.cyan); Spacer(); Text(String(format: "%02d", i + 1)).font(.title2.bold()).foregroundStyle(.cyan.opacity(0.6)) }
                    Text(step.title).font(.title3.bold()); Text(step.action).font(.body)
                }.padding(18).frame(maxWidth: .infinity, alignment: .leading).background(.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 16))
            }
        }
    }
    private func supplies(_ items: [BattleSupply]) -> some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 155, maximum: 220), alignment: .top)], alignment: .leading, spacing: 12) {
            ForEach(items) { item in
                VStack(spacing: 8) {
                    HStack { Spacer(); Text("×" + item.quantity).font(.title2.bold()).foregroundStyle(.cyan) }
                    if let artifact = map.exploration?.artifacts.first(where: { $0.name == item.name }) {
                        Image(artifact.imageAsset).resizable().scaledToFit().frame(height: 70)
                    } else { FactPicture(fact: item.fact).frame(height: 70) }
                    Text(item.name).font(.headline).multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
                    Text(item.role).font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.center)
                }.padding(14).frame(maxWidth: .infinity, alignment: .top).background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 15))
                    .accessibilityIdentifier("battle-item-" + item.name)
            }
        }
    }
    private func metric(_ title: String, _ value: String, _ icon: String) -> some View {
        VStack(alignment: .leading, spacing: 6) { Label(title, systemImage: icon).font(.caption).foregroundStyle(.secondary); Text(value).font(.title2.bold()).foregroundStyle(.cyan) }
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? { indices.contains(index) ? self[index] : nil }
}

struct BattleVideoPanel: View {
    let video: BattleVideo
    @State private var mode: Int? = nil
    @State private var status = ""
    @State private var speed = 2.0
    @State private var playbackToken = UUID()
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Fight video", systemImage: "play.rectangle.fill").font(.title2.bold())
                Spacer()
                Link(destination: video.url) { Image(systemName: "arrow.up.right.square").font(.title2) }.accessibilityLabel("Open fight on YouTube")
            }
            if let mode {
                BossYouTubePlayer(video: video, segments: mode == -1 ? video.segments : [mode == -2 ? BattleVideoSegment(title: "Full fight", start: 0, end: video.duration) : video.segments[mode]], speed: speed, onStatus: { status = $0 })
                    .id(playbackToken).frame(height: 280).accessibilityIdentifier("battle-video-player")
            } else {
                Button { mode = -1 } label: {
                    ZStack {
                        AsyncImage(url: URL(string: "https://i.ytimg.com/vi/\(video.videoID)/hqdefault.jpg")) { image in image.resizable().scaledToFit() } placeholder: { Color.white.opacity(0.04) }
                        Image(systemName: "play.circle.fill").font(.system(size: 70)).foregroundStyle(.white).shadow(radius: 12)
                    }.frame(height: 280).frame(maxWidth: .infinity).background(.black)
                }.buttonStyle(.plain).accessibilityIdentifier("battle-play-brief")
            }
            HStack(spacing: 12) {
                Button { mode = -1; playbackToken = UUID(); status = "" } label: { Label("\(Int(Double(video.briefSeconds) / speed))s briefing", systemImage: "play.fill") }.accessibilityIdentifier("battle-brief")
                Picker("Video speed", selection: $speed) { Text("1×").tag(1.0); Text("2×").tag(2.0) }.pickerStyle(.segmented).frame(width: 112)
                Spacer()
                Button("Full video") { mode = -2; playbackToken = UUID(); status = "" }.accessibilityIdentifier("battle-full-video")
            }.font(.subheadline.bold())
            HStack(spacing: 10) { ForEach(Array(video.segments.enumerated()), id: \.offset) { i, s in Button { mode = i; playbackToken = UUID(); status = "" } label: { Text(s.title).font(.caption.bold()).padding(10).frame(maxWidth: .infinity).background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 10)) }.buttonStyle(.plain).accessibilityIdentifier("battle-video-segment-\(i)") } }
            Text(video.channel + " · " + video.tier).font(.caption).foregroundStyle(.secondary)
            if !status.isEmpty { Text(status).font(.caption).foregroundStyle(.orange).accessibilityIdentifier("battle-video-status") }
        }.onChange(of: video.id) { _, _ in mode = nil; status = "" }
    }
}

struct BossYouTubePlayer: UIViewRepresentable {
    let video: BattleVideo
    let segments: [BattleVideoSegment]
    let speed: Double
    let onStatus: (String) -> Void
    final class Coordinator: NSObject, WKScriptMessageHandler {
        let status: (String) -> Void
        var speed: Double = 2
        init(status: @escaping (String) -> Void) { self.status = status }
        func userContentController(_ controller: WKUserContentController, didReceive message: WKScriptMessage) {
            guard let text = message.body as? String else { return }
            DispatchQueue.main.async { self.status(text) }
        }
    }
    func makeCoordinator() -> Coordinator { Coordinator(status: onStatus) }
    func makeUIView(context: Context) -> WKWebView {
        let c = WKWebViewConfiguration(); c.allowsInlineMediaPlayback = true; c.mediaTypesRequiringUserActionForPlayback = []
        c.userContentController.add(context.coordinator, name: "battleStatus")
        let view = WKWebView(frame: .zero, configuration: c)
        view.isOpaque = false; view.backgroundColor = .black; view.scrollView.isScrollEnabled = false
        let encoded = String(data: try! JSONEncoder().encode(segments), encoding: .utf8)!
        let origin = "https://" + (Bundle.main.bundleIdentifier ?? "com.tonytuanngoc.ascended").lowercased()
        let html = """
        <!doctype html><html><head><meta name="viewport" content="width=device-width,initial-scale=1"><meta name="referrer" content="strict-origin-when-cross-origin"><style>html,body{margin:0;width:100%;height:100%;background:#000}#player{width:100%;height:100%}</style></head><body><div id="player"></div><script src="https://www.youtube.com/iframe_api"></script><script>
        var player, clips=\(encoded), index=0, speed=\(speed), finished=false;
        function say(s){window.webkit.messageHandlers.battleStatus.postMessage(s);}
        function onYouTubeIframeAPIReady(){player=new YT.Player('player',{videoId:'\(video.videoID)',playerVars:{playsinline:1,controls:1,origin:'\(origin)',start:clips[0].start},events:{onReady:function(e){e.target.setPlaybackRate(speed);e.target.playVideo();},onPlaybackRateChange:function(e){if(e.data!==speed)say('Playback '+e.data+'×');},onError:function(){say('Video unavailable here. Open the source on YouTube.');},onStateChange:function(e){if(e.data===YT.PlayerState.PLAYING)player.setPlaybackRate(speed);}}});}
        setInterval(function(){if(!player||!player.getCurrentTime||finished)return;if(player.getPlayerState()!==YT.PlayerState.PLAYING)return;if(player.getCurrentTime()>=clips[index].end){index++;if(index<clips.length){player.seekTo(clips[index].start,true);player.setPlaybackRate(speed);}else{finished=true;player.pauseVideo();say('Briefing complete');}}},250);
        setTimeout(function(){if(!player||!player.getPlayerState||player.getPlayerState()===-1)say('If playback does not start, open the source on YouTube.');},15000);
        </script></body></html>
        """
        view.loadHTMLString(html, baseURL: URL(string: origin)); context.coordinator.speed = speed
        return view
    }
    func updateUIView(_ view: WKWebView, context: Context) {
        if context.coordinator.speed != speed { context.coordinator.speed = speed; view.evaluateJavaScript("speed=\(speed);if(player&&player.setPlaybackRate)player.setPlaybackRate(speed);") }
    }
    static func dismantleUIView(_ view: WKWebView, coordinator: Coordinator) {
        view.evaluateJavaScript("if(player&&player.destroy)player.destroy();")
        view.configuration.userContentController.removeScriptMessageHandler(forName: "battleStatus")
        view.stopLoading()
    }
}
