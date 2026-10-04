import SwiftUI
import SceneKit

struct StoneBuildScene:UIViewRepresentable {
    let pieces:[StonePlacement];let selected:UUID?;let ghost:StonePlacement
    let onPick:(UUID)->Void;let onCursor:(Double,Double)->Void
    func makeCoordinator()->Coordinator { Coordinator(self) }
    func makeUIView(context:Context)->SCNView {
        let view=SCNView();view.scene=SCNScene();view.backgroundColor=UIColor(red:0.78,green:0.84,blue:0.89,alpha:1);view.allowsCameraControl=true
        view.antialiasingMode = .multisampling4X
        let root=view.scene!.rootNode
        let floor=SCNNode(geometry:SCNBox(width:14,height:0.04,length:14,chamferRadius:0));floor.name="ground";floor.position.y = -0.04;floor.geometry?.firstMaterial?.diffuse.contents=UIColor(red:0.58,green:0.64,blue:0.57,alpha:1);root.addChildNode(floor)
        for i in -6...6 {
            for vertical in [false,true] {
                let line=SCNNode(geometry:SCNBox(width:vertical ? 0.008:12,height:0.004,length:vertical ? 12:0.008,chamferRadius:0));line.categoryBitMask=2;line.position=SCNVector3(vertical ? Float(i):0,-0.017,vertical ? 0:Float(i));line.geometry?.firstMaterial?.diffuse.contents=UIColor(white:0.28,alpha:1);root.addChildNode(line)
            }
        }
        let ambient=SCNNode();ambient.light=SCNLight();ambient.light?.type = .ambient;ambient.light?.intensity=700;root.addChildNode(ambient)
        let sun=SCNNode();sun.light=SCNLight();sun.light?.type = .directional;sun.light?.intensity=1800;sun.light?.castsShadow=true;sun.eulerAngles=SCNVector3(-Float.pi/3,-Float.pi/4,0);root.addChildNode(sun)
        let camera=SCNNode();camera.name="camera";camera.camera=SCNCamera();camera.camera?.zFar=100;camera.position=SCNVector3(4,5,6);camera.look(at:SCNVector3(0,0,0));root.addChildNode(camera);view.pointOfView=camera
        view.defaultCameraController.target=SCNVector3(0,0,0)
        let tap=UITapGestureRecognizer(target:context.coordinator,action:#selector(Coordinator.tap(_:)));view.addGestureRecognizer(tap)
        let builds=SCNNode();builds.name="builds";root.addChildNode(builds);context.coordinator.builds=builds
        return view
    }
    func updateUIView(_ view:SCNView,context:Context) {
        let c=context.coordinator;c.parent=self
        let stamp=pieces.map {"\($0.id)-\($0.kind)-\($0.x)-\($0.z)-\($0.level)-\($0.turn)"}.joined()+"\(selected?.uuidString ?? "")-\(ghost.kind)-\(ghost.x)-\(ghost.z)-\(ghost.level)-\(ghost.turn)"
        guard c.stamp != stamp,let builds=c.builds else{return};c.stamp=stamp
        builds.childNodes.forEach {$0.removeFromParentNode()}
        for p in pieces { let node=c.node(p);node.name=p.id.uuidString;if p.id==selected {node.opacity=0.25};builds.addChildNode(node) }
        let preview=c.node(ghost);preview.name="preview";preview.categoryBitMask=2;preview.opacity=0.6;preview.enumerateChildNodes {node,_ in node.categoryBitMask=2};builds.addChildNode(preview)
        let marker=SCNNode(geometry:SCNBox(width:1.04,height:0.025,length:1.04,chamferRadius:0));marker.categoryBitMask=2;marker.position=SCNVector3(Float(ghost.x),Float(ghost.level)+0.01,Float(ghost.z));let m=SCNMaterial();m.diffuse.contents=UIColor.cyan;m.emission.contents=UIColor.cyan;m.fillMode = .lines;marker.geometry?.materials=[m];builds.addChildNode(marker)
    }
    class Coordinator:NSObject {
        var parent:StoneBuildScene;var builds:SCNNode?;var stamp=""
        var geometries:[String:SCNGeometry]=[:]
        init(_ parent:StoneBuildScene) {self.parent=parent}
        func node(_ p:StonePlacement)->SCNNode {let model=StoneKit.shared.models.first {$0.id==p.kind}
            if geometries[p.kind]==nil {geometries[p.kind]=model?.geometry}
            let n=SCNNode(geometry:geometries[p.kind]);n.position=p.position
            if model?.referenceOnly==true {n.position.y+=0.4;let c=SCNBillboardConstraint();c.freeAxes = .Y;n.constraints=[c]}
            n.eulerAngles.y=Float(p.turn)*Float.pi/2;return n}
        @objc func tap(_ recognizer:UITapGestureRecognizer) {
            guard let view=recognizer.view as? SCNView else{return}
            let hits=view.hitTest(recognizer.location(in:view),options:[.categoryBitMask:1,.searchMode:SCNHitTestSearchMode.all.rawValue])
            if let match=hits.first(where:{$0.node.name.flatMap(UUID.init(uuidString:)) != nil}),let id=match.node.name.flatMap(UUID.init(uuidString:)) {parent.onPick(id);return}
            if let hit=hits.first(where:{$0.node.name=="ground"}) {
                let x=Double(hit.worldCoordinates.x),z=Double(hit.worldCoordinates.z)
                guard abs(x)<=6.25 && abs(z)<=6.25 else{return}
                parent.onCursor(max(-6,min(6,(x*2).rounded()/2)),max(-6,min(6,(z*2).rounded()/2)))
            }
        }
    }
}
