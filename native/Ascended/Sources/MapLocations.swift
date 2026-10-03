import SwiftUI
import UIKit

enum MapLayer: String, CaseIterable { case artifact = "Artifact", cave = "Cửa hang", boss = "Boss", base = "Base" }
struct MapLocation: Identifiable {
    let id: String; let name: String; let lat: Double; let lon: Double; let layer: MapLayer
    let note: String; let routeID: String?; let artifactID: String?
    var coordinates: String { String(format: "LAT %.2f · LON %.2f", lat, lon) }
    var symbol: String { switch layer { case .artifact: "diamond.fill"; case .cave: "mountain.2.fill"; case .boss: "shield.lefthalf.filled"; case .base: "house.fill" } }
    var color: UIColor { switch layer { case .artifact: .systemPurple; case .cave: .systemOrange; case .boss: .systemCyan; case .base: .systemGreen } }
    static func all(in map: ArkMap) -> [MapLocation] {
        guard let data = map.exploration else { return [] }
        var list = data.artifacts.map { MapLocation(id: "artifact-" + $0.id, name: $0.name, lat: $0.lat, lon: $0.lon, layer: .artifact, note: "Điểm artifact · dữ liệu spawn Ascended", routeID: $0.routeID, artifactID: $0.id) }
        list += data.routes.flatMap { route in route.entrances.map { MapLocation(id: "entrance-" + $0.id, name: route.name + " · " + $0.label, lat: $0.lat, lon: $0.lon, layer: $0.kind == "area" ? .boss : .cave, note: $0.kind == "area" ? "Tâm khu vực từ dữ liệu Wikily; chưa xác minh cửa vào chính xác" : "Lối tiếp cận theo hướng dẫn cộng đồng; đối chiếu địa hình", routeID: route.id, artifactID: nil) } }
        list += data.obelisks.map { MapLocation(id: $0.id, name: $0.label + (map == .ragnarok ? " · triệu hồi Nunatak" : " · cổng boss"), lat: $0.lat, lon: $0.lon, layer: .boss, note: "Điểm triệu hồi; boss ở đấu trường được dịch chuyển tới", routeID: nil, artifactID: nil) }
        if map == .ragnarok { list.append(MapLocation(id: "boss-lava-arena", name: "Lava Elemental · khu đấu trường", lat: 21.6, lon: 26.9, layer: .boss, note: "Vùng trận cuối Jungle Dungeon · tọa độ tham khảo ASA", routeID: "jungle", artifactID: nil)) }
        list += (map.bases?.locations ?? []).map { MapLocation(id: "base-" + $0.id, name: $0.name, lat: $0.lat, lon: $0.lon, layer: .base, note: "Điểm khảo sát base · GPS từ guide ASA, chưa test xây trong save", routeID: nil, artifactID: nil) }
        return list
    }
}
