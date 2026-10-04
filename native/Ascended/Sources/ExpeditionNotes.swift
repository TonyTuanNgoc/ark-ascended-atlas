import SwiftUI

struct ExpeditionNotes: View {
    @Environment(\.arkMap) private var map
    @State private var notes = ""
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Expedition notes · " + map.name).font(.largeTitle.bold())
            Text("Record base coordinates, packing lists or discoveries. Notes save automatically on this iPad.")
                .foregroundStyle(.secondary)
            TextEditor(text: $notes)
                .font(.body).scrollContentBackground(.hidden)
                .padding(16).background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 18))
                .accessibilityLabel("Notes · " + map.name)
                .accessibilityIdentifier("ragnarokNotes")
            Label("Saved automatically on this device", systemImage: "checkmark.icloud")
                .font(.caption).foregroundStyle(.secondary)
        }.padding(24)
        .onAppear { notes = UserDefaults.standard.string(forKey: map.notesKey) ?? "" }
        .onChange(of: notes) { _, value in UserDefaults.standard.set(value, forKey: map.notesKey) }
    }
}
