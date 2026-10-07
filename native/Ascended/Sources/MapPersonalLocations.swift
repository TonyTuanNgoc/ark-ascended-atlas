import SwiftUI

struct MapGPS:Equatable {let lat,lon:Double}
/// The bundled terrain uses the source atlas's full 0–100 GPS plane.
/// Work in image-local coordinates, never viewport coordinates (zoom/pan do not change GPS).
enum MapCoordinateTransform {
    static func gps(at p:CGPoint,size:CGSize)->MapGPS? {
        guard size.width.isFinite,size.height.isFinite,size.width>0,size.height>0,p.x.isFinite,p.y.isFinite,p.x>=0,p.y>=0,p.x<=size.width,p.y<=size.height else {return nil}
        return MapGPS(lat:Double(p.y/size.height)*100,lon:Double(p.x/size.width)*100)
    }
    static func pixel(lat:Double,lon:Double,size:CGSize)->CGPoint {CGPoint(x:lon/100*size.width,y:lat/100*size.height)}
}
struct PersonalMapLocation:Codable,Identifiable,Equatable {
    var id=UUID().uuidString
    var map:String;var name:String;var symbol="house.fill";var color="cyan";var lat,lon:Double
    static let symbols=["house.fill","tent.fill","bed.double.fill","shippingbox.fill","hammer.fill","leaf.fill","flame.fill","pawprint.fill","fish.fill","mountain.2.fill","drop.fill","diamond.fill","flag.fill","exclamationmark.triangle.fill","mappin"]
    static let colors=["cyan","blue","green","yellow","orange","red","purple","white"]
    var valid:Bool {ArkMap(rawValue:map) != nil && lat.isFinite && lon.isFinite && (0...100).contains(lat) && (0...100).contains(lon) && !name.trimmingCharacters(in:.whitespacesAndNewlines).isEmpty && name.count<=80 && Self.symbols.contains(symbol) && Self.colors.contains(color)}
    var tint:Color {switch color {case "blue":.blue;case "green":.green;case "yellow":.yellow;case "orange":.orange;case "red":.red;case "purple":.purple;case "white":.white;default:.cyan}}
    var point:MapLocation {MapLocation(id:"custom-"+id,name:name,lat:lat,lon:lon,layer:.custom,note:"Personal location",routeID:nil,artifactID:nil,symbolOverride:symbol,colorOverride:color)}
    static func decode(_ json:String)->[Self] {guard let data=json.data(using:.utf8),let values=try? JSONDecoder().decode([Self].self,from:data) else{return []};return values.filter(\.valid)}
    static func encode(_ values:[Self])->String {guard let data=try? JSONEncoder().encode(values.filter(\.valid)) else{return "[]"};return String(decoding:data,as:UTF8.self)}
}
struct PersonalLocationEditor:View {
    @State var location:PersonalMapLocation
    let save:(PersonalMapLocation)->Void
    @Environment(\.dismiss) private var dismiss
    var body:some View {
        NavigationStack {
            ScrollView {
                VStack(alignment:.leading,spacing:24) {
                    HStack(spacing:18) {Image(systemName:location.symbol).font(.system(size:38)).foregroundStyle(location.tint).frame(width:80,height:80).background(location.tint.opacity(0.13),in:RoundedRectangle(cornerRadius:20));TextField("Location name",text:$location.name).font(.title2.bold()).accessibilityIdentifier("custom-location-name")}
                    Text("Icon").font(.headline)
                    LazyVGrid(columns:[GridItem(.adaptive(minimum:58))],spacing:10) {ForEach(PersonalMapLocation.symbols,id:\.self) {symbol in Button {location.symbol=symbol} label:{Image(systemName:symbol).font(.title2).frame(width:58,height:52).background(location.symbol==symbol ? location.tint.opacity(0.2):Color.white.opacity(0.05),in:RoundedRectangle(cornerRadius:10))}.buttonStyle(.plain).accessibilityLabel(symbol).accessibilityIdentifier("custom-icon-"+symbol)}}
                    Text("Color").font(.headline)
                    HStack {ForEach(PersonalMapLocation.colors,id:\.self) {name in let swatch=PersonalMapLocation(map:location.map,name:"Color",color:name,lat:0,lon:0);Button {location.color=name} label:{Circle().fill(swatch.tint).frame(width:32,height:32).overlay {if location.color==name {Image(systemName:"checkmark").foregroundStyle(name=="white" || name=="yellow" ? .black:.white)}}.padding(4)}.accessibilityLabel(name).accessibilityIdentifier("custom-color-"+name)}}
                    Text("GPS").font(.headline)
                    HStack(spacing:18) {GPSCoordinateWheel(title:"Latitude",value:$location.lat);GPSCoordinateWheel(title:"Longitude",value:$location.lon)}
                    Text("Coordinates are picked from the terrain under your finger. Adjust the wheels to refine the location.").font(.caption).foregroundStyle(.secondary)
                }.padding(24)
            }.navigationTitle("Add Location").navigationBarTitleDisplayMode(.inline)
                .toolbar {ToolbarItem(placement:.cancellationAction) {Button("Cancel") {dismiss()}};ToolbarItem(placement:.confirmationAction) {Button("Save") {location.name=String(location.name.trimmingCharacters(in:.whitespacesAndNewlines).prefix(80));save(location);dismiss()}.disabled(!location.valid).accessibilityIdentifier("custom-location-save")}}
        }.preferredColorScheme(.dark)
    }
}
private struct GPSCoordinateWheel:View {
    let title:String;@Binding var value:Double
    private var whole:Binding<Int> {Binding(get:{Int(value)},set:{value=min(100,Double($0)+(value-Double(Int(value))))})}
    private var fraction:Binding<Int> {Binding(get:{Int((value-Double(Int(value)))*100+0.00001)},set:{value=min(100,Double(Int(value))+Double($0)/100)})}
    var body:some View {
        VStack(spacing:4) {Text(title == "Latitude" ? "LAT" : "LON").font(.subheadline.bold());Text(value.formatted(.number.precision(.fractionLength(2)))).font(.title3.monospacedDigit()).foregroundStyle(.cyan).accessibilityIdentifier("custom-"+title.lowercased());HStack(spacing:0) {Picker(title,selection:whole) {ForEach(0...100,id:\.self) {Text(String($0)).tag($0)}};Text(".");Picker(title+" decimals",selection:fraction) {ForEach(0..<100,id:\.self) {Text(String(format:"%02d",$0)).tag($0)}}}.pickerStyle(.wheel).frame(height:120)}.frame(maxWidth:.infinity).padding(12).background(.white.opacity(0.04),in:RoundedRectangle(cornerRadius:14))
    }
}
