import SwiftUI
import UIKit

enum MapLayer: String, CaseIterable { case artifact = "Artifact", cave = "Cửa hang", boss = "Boss", base = "Base" }
struct MapLocation: Identifiable {
    let id: String; let name: String; let lat: Double; let lon: Double; let layer: MapLayer
    let note: String; let routeID: String?; let artifactID: String?
    var imageAsset: String? = nil
    var coordinates: String { String(format: "LAT %.2f · LON %.2f", lat, lon) }
    var symbol: String { switch layer { case .artifact: "diamond.fill"; case .cave: "mountain.2.fill"; case .boss: "shield.lefthalf.filled"; case .base: "house.fill" } }
    var color: UIColor { switch layer { case .artifact: .systemPurple; case .cave: .systemOrange; case .boss: id == "obelisk-red" ? .systemRed : id == "obelisk-green" ? .systemGreen : id == "obelisk-blue" ? .systemBlue : .systemCyan; case .base: .systemGreen } }
    static func all(in map: ArkMap) -> [MapLocation] {
        guard let data = map.exploration else { return [] }
        var list = data.artifacts.map { MapLocation(id: "artifact-" + $0.id, name: $0.name, lat: $0.lat, lon: $0.lon, layer: .artifact, note: "Vị trí lấy artifact", routeID: $0.routeID, artifactID: $0.id) }
        list += data.routes.flatMap { route in route.entrances.map { MapLocation(id: "entrance-" + $0.id, name: route.name + " · " + $0.label, lat: $0.lat, lon: $0.lon, layer: $0.kind == "area" ? .boss : .cave, note: $0.kind == "area" ? "Khu vực tiếp cận; tìm cửa hang theo địa hình" : "Cửa hang · đối chiếu địa hình để vào", routeID: route.id, artifactID: nil) } }
        list += data.obelisks.map { MapLocation(id: $0.id, name: $0.label + (map == .ragnarok ? " · triệu hồi Nunatak" : " · cổng boss"), lat: $0.lat, lon: $0.lon, layer: .boss, note: "Điểm triệu hồi; boss ở đấu trường được dịch chuyển tới", routeID: nil, artifactID: nil) }
        if map == .ragnarok { list.append(MapLocation(id: "boss-lava-arena", name: "Lava Elemental · khu đấu trường", lat: 21.6, lon: 26.9, layer: .boss, note: "Cuối Jungle Dungeon · trận loot tùy chọn", routeID: "jungle", artifactID: nil)) }
        list += (map.bases?.locations ?? []).map { MapLocation(id: "base-" + $0.id, name: $0.name, lat: $0.lat, lon: $0.lon, layer: .base, note: "Điểm khảo sát base · kiểm tra mặt bằng trước khi xây", routeID: nil, artifactID: nil) }
        for index in list.indices {
            let point = list[index]
            if let id = point.artifactID { list[index].imageAsset = data.artifacts.first { $0.id == id }?.imageAsset }
            else if point.layer == .cave, let id = point.routeID { list[index].imageAsset = data.routes.first { $0.id == id }?.imageAsset }
            else if point.layer == .base { list[index].imageAsset = "Base-" + point.id.replacingOccurrences(of: "base-", with: "") }
            else if point.id.hasPrefix("obelisk-") { list[index].imageAsset = "Map-Obelisk" }
            else if point.id == "boss-lava-arena" { list[index].imageAsset = "Game-Boss-lava-elemental" }
        }
        return list
    }
}
