import SwiftUI

struct SurvivalSource: Decodable, Identifiable {
    let id, title, url, kind, note, reviewedAt: String
}
struct SurvivalKitItem: Decodable, Hashable {
    let name, asset: String
}
struct SurvivalGoal: Decodable, Identifiable {
    let id, title, asset, detail: String
    let sourceIDs: [String]
    let optional: Bool
    let contents: [SurvivalKitItem]
    let quantity: String?
}
struct SurvivalGroup: Decodable, Identifiable {
    let id, title, icon: String
    let goals: [SurvivalGoal]
}
struct SurvivalPhase: Decodable, Identifiable {
    let id, title, subtitle, asset, note: String
    let groups: [SurvivalGroup]
    var goals: [SurvivalGoal] { groups.flatMap(\.goals) }
    var required: [SurvivalGoal] { goals.filter { !$0.optional } }
    func key(_ goal: SurvivalGoal) -> String { id + "/" + goal.id }
    func completed(in keys: Set<String>) -> Int { required.filter { keys.contains(key($0)) }.count }
    func isComplete(in keys: Set<String>) -> Bool { !required.isEmpty && completed(in: keys) == required.count }
}
struct SurvivalGuide: Decodable {
    let mapID, title, reviewedAt, mode, approach, editorialNote: String
    let sources: [SurvivalSource]
    let phases: [SurvivalPhase]
    static func load(for map: ArkMap) -> SurvivalGuide? {
        guard map == .island else { return nil }
        return try? ArkMap.load(Self.self, name: "the-island-survival-guide")
    }
    func nextPhase(in keys: Set<String>) -> Int { phases.firstIndex { !$0.isComplete(in: keys) } ?? max(0, phases.count - 1) }
}
enum SurvivalProgress {
    static func decode(_ value: String) -> Set<String> {
        Set((try? JSONDecoder().decode([String].self, from: Data(value.utf8))) ?? [])
    }
    static func encode(_ keys: Set<String>) -> String {
        String(data: (try? JSONEncoder().encode(keys.sorted())) ?? Data("[]".utf8), encoding: .utf8) ?? "[]"
    }
    static func toggled(_ key: String, in keys: Set<String>) -> Set<String> {
        var updated = keys
        if updated.contains(key) { updated.remove(key) } else { updated.insert(key) }
        return updated
    }
}

struct SurvivalGuideScreen: View {
    @Environment(\.arkMap) private var map
    let openModule: (Destination) -> Void
    @AppStorage("ascended.survival.the-island.v1") private var storedProgress = "[]"
    @State private var phaseIndex = 0
    @State private var presentedGoal: SurvivalGoal?
    @State private var showSources = false
    @State private var groupFilter: String?
    private func visibleGroups(_ phase: SurvivalPhase) -> [SurvivalGroup] {
        phase.groups.filter { groupFilter == nil || $0.id == groupFilter }
    }
    private var done: Set<String> { SurvivalProgress.decode(storedProgress) }
    var body: some View {
        if let guide = SurvivalGuide.load(for: map) {
            GeometryReader { geometry in
                let phase = guide.phases[min(phaseIndex, guide.phases.count - 1)]
                VStack(spacing: 14) {
                    phaseStrip(guide)
                    HStack(spacing: 16) {
                        SurvivalArtwork(asset: phase.asset).frame(width: 90, height: 70)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(phase.title).font(.system(size: 26, weight: .bold, design: .rounded))
                            Text(phase.note).font(.system(size: 13)).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer(minLength: 8)
                        VStack(alignment: .trailing, spacing: 5) {
                            Text("\(phase.completed(in: done)) / \(phase.required.count)").font(.title3.bold()).monospacedDigit().foregroundStyle(.cyan)
                            Text(phase.isComplete(in: done) ? "Phase complete" : "Your checklist").font(.caption).foregroundStyle(.secondary)
                        }.accessibilityIdentifier("survival-phase-progress")
                        Button { showSources = true } label: { Image(systemName: "books.vertical").font(.title3).padding(12).background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 12)) }
                            .accessibilityLabel("Sources and route notes").accessibilityIdentifier("survival-sources")
                    }.padding(.horizontal, 6)
                    groupStrip(phase)
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12, alignment: .topLeading), count: groupFilter == nil ? (geometry.size.width > 950 ? 4 : 2) : 1), alignment: .leading, spacing: 12) {
                            ForEach(visibleGroups(phase)) { group in
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack(spacing: 8) { GuideIcon(name: group.icon, size: 28); Text(group.title).font(.system(size: 17, weight: .bold, design: .rounded)) }
                                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8, alignment: .topLeading), count: groupFilter == nil ? 2 : (geometry.size.width > 950 ? 4 : 3)), spacing: 8) {
                                        ForEach(group.goals) { goal in goalTile(goal, phase: phase) }
                                    }
                                }.padding(12).frame(maxWidth: .infinity, alignment: .topLeading)
                                    .background(Color.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 18))
                                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(.white.opacity(0.055)))
                            }
                        }
                    }.accessibilityIdentifier("survival-goal-grid")
                    HStack(spacing: 8) {
                        Text("PvE · play at your pace").font(.caption).foregroundStyle(.secondary)
                        Spacer()
                        ForEach([Destination.bases, .farming, .dinos, .exploration, .bosses]) { module in
                            Button { openModule(module) } label: {
                                HStack(spacing: 5) { NavigationAvatar(asset: module.avatarAsset, size: 23); Text(module.title).font(.caption.bold()).lineLimit(1) }
                                    .padding(.horizontal, 10).padding(.vertical, 6).background(.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 10))
                            }.buttonStyle(.plain).accessibilityIdentifier("survival-open-" + module.id)
                        }
                    }
                }.padding(.horizontal, 20).padding(.vertical, 12)
                .onAppear { phaseIndex = guide.nextPhase(in: done) }
                .sheet(item: $presentedGoal) { goal in
                    SurvivalGoalDetail(goal: goal, guide: guide)
                }
                .sheet(isPresented: $showSources) { SurvivalSourcesSheet(guide: guide) }
            }.accessibilityElement(children: .contain).accessibilityIdentifier("survival-guide")
        } else {
            VStack(spacing: 18) {
                NavigationAvatar(asset: "Nav-information", size: 86)
                Text("The Island comes first").font(.title2.bold())
                Text("Choose The Island to open its researched Survival Guide.").foregroundStyle(.secondary)
            }.frame(maxWidth: .infinity, maxHeight: .infinity).accessibilityIdentifier("survival-map-unavailable")
        }
    }
    private func groupStrip(_ phase: SurvivalPhase) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Button { groupFilter = nil } label: { Text("All").font(.subheadline.bold()).padding(.horizontal, 16).padding(.vertical, 8).background(groupFilter == nil ? Color.cyan.opacity(0.18) : .white.opacity(0.05), in: Capsule()) }
                    .buttonStyle(.plain).accessibilityIdentifier("survival-group-all")
                ForEach(phase.groups) { group in
                    Button { groupFilter = group.id } label: {
                        HStack(spacing: 6) { GuideIcon(name: group.icon, size: 20); Text(group.title).font(.subheadline.bold()); Text(String(group.goals.count)).font(.caption).foregroundStyle(.secondary) }
                            .padding(.horizontal, 12).padding(.vertical, 8).background(groupFilter == group.id ? Color.cyan.opacity(0.18) : .white.opacity(0.05), in: Capsule())
                    }.buttonStyle(.plain).accessibilityIdentifier("survival-group-" + group.id)
                }
            }
        }
    }
    private func phaseStrip(_ guide: SurvivalGuide) -> some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(guide.phases.enumerated()), id: \.element.id) { index, phase in
                        Button { phaseIndex = index; withAnimation { proxy.scrollTo(phase.id, anchor: .center) } } label: {
                            HStack(spacing: 8) {
                                SurvivalArtwork(asset: phase.asset).frame(width: 40, height: 44)
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(spacing: 5) { Text(String(format: "%02d", index + 1)).foregroundStyle(.cyan); if phase.isComplete(in: done) { Image(systemName: "checkmark.circle.fill").foregroundStyle(.mint) } }
                                        .font(.caption2.bold())
                                    Text(phase.title).font(.system(size: 13, weight: .semibold)).lineLimit(2)
                                }
                            }.frame(width: 142, height: 58).padding(8)
                                .background(phaseIndex == index ? Color.cyan.opacity(0.12) : .white.opacity(0.035), in: RoundedRectangle(cornerRadius: 14))
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(phaseIndex == index ? .cyan.opacity(0.65) : .white.opacity(0.06)))
                        }.buttonStyle(.plain).accessibilityIdentifier("survival-phase-" + phase.id).accessibilityValue(phaseIndex == index ? "Selected" : "Not selected").id(phase.id)
                    }
                }
            }.onChange(of: phaseIndex) { _, _ in proxy.scrollTo(guide.phases[phaseIndex].id, anchor: .center) }
                .onAppear { proxy.scrollTo(guide.phases[min(phaseIndex, guide.phases.count - 1)].id, anchor: .center) }
        }.accessibilityIdentifier("survival-phase-strip")
    }
    private func goalTile(_ goal: SurvivalGoal, phase: SurvivalPhase) -> some View {
        let selected = done.contains(phase.key(goal))
        return VStack(spacing: 3) {
            HStack {
                if goal.optional { Text("Optional").font(.system(size: 10, weight: .semibold)).foregroundStyle(.orange) }
                else if let quantity = goal.quantity { Text("× " + quantity).font(.caption2.bold()).foregroundStyle(.cyan) }
                Spacer(minLength: 0)
                Button { presentedGoal = goal } label: { Image(systemName: "info.circle").font(.system(size: 15)).padding(2) }
                    .buttonStyle(.plain).foregroundStyle(.secondary).accessibilityLabel("Details: " + goal.title).accessibilityIdentifier("survival-info-" + phase.key(goal))
            }
            Button {
                storedProgress = SurvivalProgress.encode(SurvivalProgress.toggled(phase.key(goal), in: done))
            } label: {
                VStack(spacing: 4) {
                    HStack(alignment: .top) {
                        Text(goal.title).font(.system(size: 12, weight: .semibold)).multilineTextAlignment(.leading).fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: 2)
                        Image(systemName: selected ? "checkmark.circle.fill" : "circle").font(.system(size: 19, weight: .semibold)).foregroundStyle(selected ? .mint : .white.opacity(0.4))
                    }
                    if goal.contents.isEmpty {
                        SurvivalArtwork(asset: goal.asset).frame(height: 46).frame(maxWidth: .infinity)
                    } else {
                        ForEach(goal.contents, id: \.self) { item in
                            HStack(spacing: 6) {
                                SurvivalArtwork(asset: item.asset).frame(width: 32, height: 32)
                                Text(item.name).font(.system(size: 11, weight: .medium)).multilineTextAlignment(.leading).fixedSize(horizontal: false, vertical: true).frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                }.contentShape(Rectangle())
            }.buttonStyle(.plain).accessibilityIdentifier("survival-check-" + phase.key(goal)).accessibilityLabel(([goal.title] + goal.contents.map(\.name)).joined(separator: ", ")).accessibilityValue(selected ? "Completed" : "Not completed")
        }.padding(6).background(selected ? Color.mint.opacity(0.085) : .white.opacity(0.035), in: RoundedRectangle(cornerRadius: 12))
    }
}
private struct SurvivalArtwork: View {
    let asset: String
    var body: some View {
        if asset.hasPrefix("Dino-") { CreatureAvatar(asset: asset) }
        else { Image(asset).resizable().scaledToFit().clipShape(RoundedRectangle(cornerRadius: 8)) }
    }
}
private struct SurvivalGoalDetail: View {
    let goal: SurvivalGoal
    let guide: SurvivalGuide
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(spacing: 20) {
                        SurvivalArtwork(asset: goal.asset).frame(width: 100, height: 100)
                        VStack(alignment: .leading, spacing: 6) { Text(goal.title).font(.title2.bold()); if let quantity = goal.quantity { Text("Suggested: " + quantity).foregroundStyle(.cyan) } }
                    }
                    if !goal.contents.isEmpty {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 12) {
                            ForEach(goal.contents, id: \.self) { item in
                                VStack(spacing: 8) { SurvivalArtwork(asset: item.asset).frame(height: 64); Text(item.name).font(.subheadline.bold()).multilineTextAlignment(.center) }.padding(12).frame(maxWidth: .infinity).background(.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                    Text(goal.detail).font(.body)
                    Text("Source references").font(.headline)
                    ForEach(guide.sources.filter { goal.sourceIDs.contains($0.id) }) { row in sourceRow(row) }
                    Text("This milestone is a planning recommendation. Tame choices and quantities are flexible.").font(.caption).foregroundStyle(.secondary)
                }.padding(24)
            }.navigationTitle("Milestone").navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } } }
        }.presentationDetents([.medium, .large]).accessibilityIdentifier("survival-goal-detail")
    }
}
private struct SurvivalSourcesSheet: View {
    let guide: SurvivalGuide
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(guide.mode).font(.headline).foregroundStyle(.cyan)
                    Text(guide.editorialNote).font(.subheadline)
                    Text("Reviewed " + guide.reviewedAt).font(.caption).foregroundStyle(.secondary)
                    ForEach(guide.sources) { sourceRow($0) }
                }.padding(24)
            }.navigationTitle("Sources & route notes").navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } } }
        }.presentationDetents([.large]).accessibilityIdentifier("survival-source-sheet")
    }
}
private func sourceRow(_ source: SurvivalSource) -> some View {
    VStack(alignment: .leading, spacing: 7) {
        Text(source.kind).font(.caption.bold()).foregroundStyle(.cyan)
        if let url = URL(string: source.url) { Link(destination: url) { HStack { Text(source.title).font(.headline); Spacer(); Image(systemName: "arrow.up.right") } } }
        Text(source.note).font(.subheadline).foregroundStyle(.secondary)
    }.padding(14).frame(maxWidth: .infinity, alignment: .leading).background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 12))
}
