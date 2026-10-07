import SwiftUI

/// Original vector artwork, drawn at native resolution rather than font symbols.
struct GuideIcon: View {
    let name: String
    var size: CGFloat = 26
    var body: some View {
        Canvas { context, bounds in
            context.scaleBy(x:bounds.width/32,y:bounds.height/32)
            let path=Self.artwork(name.lowercased())
            context.fill(path,with:.linearGradient(Gradient(colors:[Color(red:0.8,green:1,blue:0.96),Color(red:0.1,green:0.7,blue:0.82)]),startPoint:CGPoint(x:6,y:3),endPoint:CGPoint(x:25,y:29)))
            context.stroke(path,with:.color(.white.opacity(0.65)),lineWidth:0.65)
        }.padding(3).frame(width:size,height:size)
            .background(LinearGradient(colors:[.cyan.opacity(0.10),.white.opacity(0.025)],startPoint:.topLeading,endPoint:.bottomTrailing),in:RoundedRectangle(cornerRadius:size*0.24))
            .accessibilityHidden(true)
    }
    private static func artwork(_ name:String)->Path {
        var p=Path()
        func polygon(_ points:[CGPoint]) {guard let first=points.first else{return};p.move(to:first);for point in points.dropFirst(){p.addLine(to:point)};p.closeSubpath()}
        if name.contains("health") || name.contains("tameable") {
            p.move(to:CGPoint(x:16,y:28));p.addCurve(to:CGPoint(x:3,y:12),control1:CGPoint(x:7,y:22),control2:CGPoint(x:3,y:18));p.addCurve(to:CGPoint(x:16,y:8),control1:CGPoint(x:3,y:2),control2:CGPoint(x:12,y:1));p.addCurve(to:CGPoint(x:29,y:12),control1:CGPoint(x:21,y:1),control2:CGPoint(x:29,y:2));p.addCurve(to:CGPoint(x:16,y:28),control1:CGPoint(x:29,y:18),control2:CGPoint(x:24,y:23));p.closeSubpath()
        } else if name.contains("herb") || name.contains("diet") {
            p.move(to:CGPoint(x:5,y:26));p.addCurve(to:CGPoint(x:27,y:3),control1:CGPoint(x:0,y:12),control2:CGPoint(x:12,y:1));p.addCurve(to:CGPoint(x:5,y:26),control1:CGPoint(x:31,y:23),control2:CGPoint(x:16,y:31));p.closeSubpath();p.move(to:CGPoint(x:6,y:27));p.addLine(to:CGPoint(x:23,y:8))
        } else if name.contains("carn") {
            polygon([CGPoint(x:5,y:5),CGPoint(x:26,y:5),CGPoint(x:23,y:14),CGPoint(x:17,y:29),CGPoint(x:12,y:15)])
        } else if name.contains("stats") {
            p.addRoundedRect(in:CGRect(x:3,y:17,width:6,height:12),cornerSize:CGSize(width:2,height:2));p.addRoundedRect(in:CGRect(x:13,y:10,width:6,height:19),cornerSize:CGSize(width:2,height:2));p.addRoundedRect(in:CGRect(x:23,y:3,width:6,height:26),cornerSize:CGSize(width:2,height:2))
        } else if name.contains("stamina") {
            polygon([CGPoint(x:18,y:2),CGPoint(x:6,y:19),CGPoint(x:14,y:19),CGPoint(x:11,y:30),CGPoint(x:28,y:12),CGPoint(x:19,y:12)])
        } else if name.contains("weight") {
            p.addEllipse(in:CGRect(x:12,y:2,width:8,height:8));polygon([CGPoint(x:9,y:11),CGPoint(x:23,y:11),CGPoint(x:29,y:28),CGPoint(x:3,y:28)])
        } else if name.contains("torpor") {
            p.move(to:CGPoint(x:23,y:3));p.addCurve(to:CGPoint(x:24,y:28),control1:CGPoint(x:2,y:-1),control2:CGPoint(x:0,y:28));p.addCurve(to:CGPoint(x:23,y:3),control1:CGPoint(x:12,y:21),control2:CGPoint(x:14,y:10));p.closeSubpath();p.addEllipse(in:CGRect(x:24,y:8,width:4,height:4))
        } else if name.contains("loot") {
            polygon([CGPoint(x:3,y:9),CGPoint(x:16,y:3),CGPoint(x:29,y:9),CGPoint(x:29,y:25),CGPoint(x:16,y:31),CGPoint(x:3,y:25)]);p.addRoundedRect(in:CGRect(x:13,y:11,width:6,height:10),cornerSize:CGSize(width:1,height:1))
        } else if name.contains("method") || name.contains("immobil") {
            polygon([CGPoint(x:4,y:28),CGPoint(x:9,y:18),CGPoint(x:22,y:5),CGPoint(x:28,y:11),CGPoint(x:15,y:24)]);polygon([CGPoint(x:18,y:6),CGPoint(x:23,y:1),CGPoint(x:31,y:9),CGPoint(x:26,y:14)])
        } else if name.contains("taming") || name.contains("creature") {
            p.addEllipse(in:CGRect(x:9,y:15,width:15,height:13));p.addEllipse(in:CGRect(x:2,y:8,width:7,height:9));p.addEllipse(in:CGRect(x:10,y:2,width:7,height:10));p.addEllipse(in:CGRect(x:20,y:3,width:7,height:10));p.addEllipse(in:CGRect(x:26,y:12,width:5,height:8))
        } else if name.contains("location") || name.contains("spawn") {
            p.addEllipse(in:CGRect(x:2,y:2,width:28,height:28));polygon([CGPoint(x:21,y:8),CGPoint(x:19,y:20),CGPoint(x:10,y:26),CGPoint(x:12,y:13)])
        } else if name.contains("harvest") || name.contains("tool") {
            polygon([CGPoint(x:6,y:29),CGPoint(x:3,y:26),CGPoint(x:21,y:6),CGPoint(x:24,y:9)]);p.move(to:CGPoint(x:2,y:9));p.addQuadCurve(to:CGPoint(x:30,y:13),control:CGPoint(x:16,y:-4));p.addQuadCurve(to:CGPoint(x:2,y:9),control:CGPoint(x:15,y:6));p.closeSubpath()
        } else {
            polygon([CGPoint(x:4,y:5),CGPoint(x:15,y:3),CGPoint(x:28,y:8),CGPoint(x:28,y:27),CGPoint(x:16,y:24),CGPoint(x:4,y:28)])
        }
        return p
    }
}
