import SwiftUI

struct ExpeditionNotes: View {
    @Environment(\.arkMap) private var map
    @State private var notes = ""
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Nhật ký " + map.name).font(.largeTitle.bold())
            Text("Ghi tọa độ base, đồ cần chuẩn bị hoặc điều anh vừa khám phá. Nội dung tự lưu trên iPad này.")
                .foregroundStyle(.secondary)
            TextEditor(text: $notes)
                .font(.body).scrollContentBackground(.hidden)
                .padding(16).background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 18))
                .accessibilityLabel("Ghi chú " + map.name)
                .accessibilityIdentifier("ragnarokNotes")
            Label("Tự lưu trên thiết bị", systemImage: "checkmark.icloud")
                .font(.caption).foregroundStyle(.secondary)
        }.padding(24)
        .onAppear { notes = UserDefaults.standard.string(forKey: map.notesKey) ?? "" }
        .onChange(of: notes) { _, value in UserDefaults.standard.set(value, forKey: map.notesKey) }
    }
}
