import Foundation
struct MapFilterSelection {
    var locations:Set<String>=[]
    var resources:Set<String>=[]
    func includes(_ point:MapLocation)->Bool {point.layer == .resource ? !resources.isDisjoint(with:point.resourceNames):locations.contains(point.id)}
    func selectedCount(_ layer:MapLayer,points:[MapLocation],types:[String])->Int {layer == .resource ? resources.intersection(types).count:locations.intersection(points.filter {$0.layer==layer}.map(\.id)).count}
    func total(_ layer:MapLayer,points:[MapLocation],types:[String])->Int {layer == .resource ? types.count:points.filter {$0.layer==layer}.count}
    mutating func toggle(_ layer:MapLayer,points:[MapLocation],types:[String]) {
        if layer == .resource {let ids=Set(types);if !ids.isEmpty && ids.isSubset(of:resources) {resources.subtract(ids)} else {resources.formUnion(ids)}}
        else {let ids=Set(points.filter {$0.layer==layer}.map(\.id));if !ids.isEmpty && ids.isSubset(of:locations) {locations.subtract(ids)} else {locations.formUnion(ids)}}
    }
    mutating func togglePoint(_ id:String) {if locations.contains(id) {locations.remove(id)} else {locations.insert(id)}}
    mutating func toggleResource(_ name:String) {if resources.contains(name) {resources.remove(name)} else {resources.insert(name)}}
}
extension MapLayer {
    var illustration:String {switch self {case .artifact:"AtlasLayer-artifacts";case .cave:"AtlasLayer-caves";case .obelisk:"AtlasLayer-obelisks";case .boss:"AtlasLayer-bosses";case .base:"AtlasLayer-bases";case .resource:"AtlasLayer-resources";case .custom:"AtlasLayer-locations"}}
}
