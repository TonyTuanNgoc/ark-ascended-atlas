import SwiftUI

struct ExpeditionNotes: View {
    @AppStorage("ascended.ragnarok.notes.v1") private var notes = ""
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Nhật ký Ragnarok").font(.largeTitle.bold())
            Text("Ghi tọa độ base, đồ cần chuẩn bị hoặc điều anh vừa khám phá. Nội dung tự lưu trên iPad này.")
                .foregroundStyle(.secondary)
            TextEditor(text: $notes)
                .font(.body).scrollContentBackground(.hidden)
                .padding(16).background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 18))
                .accessibilityLabel("Ghi chú Ragnarok")
                .accessibilityIdentifier("ragnarokNotes")
            Label("Tự lưu trên thiết bị", systemImage: "checkmark.icloud")
                .font(.caption).foregroundStyle(.secondary)
        }.padding(24)
    }
}

struct SourcesScreen: View {
    var body: some View {
        List {
            Section("Game và Ragnarok") {
                Link("Ragnarok Ascended · Studio Wildcard", destination: URL(string: "https://survivetheark.com/index.php?/forums/topic/772489-ragnarok-ascended-and-lost-colony-expansion-pass-are-now-live/")!)
                Link("Ragnarok Ascended · Steam", destination: URL(string: "https://store.steampowered.com/app/3675020/ARK_Ragnarok_Ascended/")!)
            }
            Section("Bản đồ và hình ảnh") {
                Link("Bản đồ Ragnarok Ascended · Wikily", destination: URL(string: "https://wikily.gg/ark-survival-ascended/maps/ragnarok/")!)
                Text("Logo ARK: Survival Ascended thuộc Studio Wildcard. Bản đồ và ảnh Ragnarok được lấy từ Wikily; bản đồ 8K trong app là địa hình, chưa có lớp tài nguyên hay vị trí sinh vật.")
                    .foregroundStyle(.secondary)
            }
            Section("Dino & Boss") {
                Link("Ragnarok · ARK Official Community Wiki", destination: URL(string: "https://ark.wiki.gg/wiki/Ragnarok")!)
                Link("Cập nhật sinh vật 30/09/2026 · Studio Wildcard", destination: URL(string: "https://survivetheark.com/index.php?/forums/topic/774248-therizino-tlc-cerberax-and-gargantar-are-out-now/")!)
                Text("159 mục gồm sinh vật và biến thể: 151 mục trong danh sách spawn của Wikily, cộng Xiphactinus và 7 Alpha từ Wiki. Dữ liệu spawn có thể khác trên save cũ hoặc khi dùng mod. Boss được trình bày riêng. Ghi chép cũ trong hồ sơ được ghi ngày và tách khỏi dữ liệu mới.")
                    .foregroundStyle(.secondary)
            }
            Section("Bản dev hiện tại") {
                Text("Ascended 0.2.0 (2) · Single Player · Ragnarok")
                Text("App đồng hành cá nhân, không phải ứng dụng chính thức của Studio Wildcard. Bản đồ và ghi chú dùng offline; các liên kết tham khảo cần mạng.")
                    .foregroundStyle(.secondary)
            }
        }
    }
}
