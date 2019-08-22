//
//  ViewController.swift
//  Celeste
//
//  Created by Bruno Pastre on 15/08/19.
//  Copyright © 2019 Bruno Pastre. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate, ContextMenuGestureDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    let contextMenu = ContextMenu.instance
    
    lazy var tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.onTap(_:)))
    lazy var contextMenuGesture: ContextMenuGestureRecognizer = ContextMenuGestureRecognizer(target: self, action: #selector(self.onContextMenu(_:)))
    
    var currentSelectedStar: SCNNode?
    var contextMenuNode: SCNNode?
    
    lazy var galaxy: Galaxy =  self.getDebugGalaxy()
    
    func getDebugGalaxy() -> Galaxy{
        
        let moons = [
             Star(radius: 0.5 * 0.5, center: Point(x: 1, y: -1, z: 1), color: #colorLiteral(red: 1, green: 1, blue: 0, alpha: 1)),
             Star(radius: 0.5 * 0.5, center: Point(x: -1, y: -1, z: 1), color: #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)),
             Star(radius: 0.5 * 0.5, center: Point(x: 1, y: 1, z: 1), color: #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 1)),
             Star(radius: 0.5 * 0.5, center: Point(x: -1, y: 1, z: 1), color: #colorLiteral(red: 0.1921568662, green: 0.007843137719, blue: 0.09019608051, alpha: 1)),
             Star(radius: 0.5 * 0.5, center: Point(x: 1, y: 1, z: -1), color: #colorLiteral(red: 0.3098039329, green: 0.2039215714, blue: 0.03921568766, alpha: 1)),
             Star(radius: 0.5 * 0.5, center: Point(x: -1, y: 1, z: -1), color: #colorLiteral(red: 0.1294117719, green: 0.2156862766, blue: 0.06666667014, alpha: 1)),
        ]
        
        let orbits = moons.map { (star) -> Orbit in
            return Orbit(radius: CGFloat.random(in: 0.001...0.2), orbiter: star)
        }
        
        return Galaxy(stars: [
            Planet(radius: 0.5 * 1, center: Point.zero, color: #colorLiteral(red: 0.5073578358, green: 1, blue: 0.4642170072, alpha: 1), child: moons,
//                [
                
//                Moon(radius: 0.5 * 0.5, center: Point(x: 1, y: 1, z: 0), color: #colorLiteral(red: 0.05881351963, green: 0.180391161, blue: 0.1470588137, alpha: 1), child: nil),
//                Moon(radius: 0.5 * 0.5, center: Point(x: 1, y: -1, z: 1), color: #colorLiteral(red: 0.3098039319, green: 0.1039115714, blue: 0.03911568766, alpha: 1), child: nil),
//                Moon(radius: 0.5 * 0.5, center: Point(x: 1, y: -1, z: 0), color: #colorLiteral(red: 0.1194117719, green: 0.1156861766, blue: 0.06666667014, alpha: 1), child: nil),
//                Moon(radius: 0.5 * 0.5, center: Point(x: 0, y: 1, z: 0), color: #colorLiteral(red: 0.06174510175, green: 0, blue: 0.1911568661, alpha: 1), child: nil),
//                Moon(radius: 0.5 * 0.5, center: Point(x: 0, y: 1, z: 1), color: #colorLiteral(red: 0.1911568661, green: 0.007843137719, blue: 0.09019608051, alpha: 1), child: nil),
//                Moon(radius: 0.5 * 0.5, center: Point(x: 0, y: -1, z: 0), color: #colorLiteral(red: 0.1764705916, green: 0.4980391158, blue: 0.7568617596, alpha: 1), child: nil),
//                Moon(radius: 0.5 * 0.5, center: Point(x: 0, y: -1, z: 1), color: #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1), child: nil),
//                Moon(radius: 0.5 * 0.5, center: Point(x: -1, y: -1, z: 1), color: #colorLiteral(red: 0.3098039319, green: 0.1039115714, blue: 0.03911568766, alpha: 1), child: nil),
//                Moon(radius: 0.5 * 0.5, center: Point(x: -1, y: -1, z: 0), color: #colorLiteral(red: 0.1194117719, green: 0.1156861766, blue: 0.06666667014, alpha: 1), child: nil),
//                Moon(radius: 0.5 * 0.5, center: Point(x: -1, y: 1, z: 0), color: #colorLiteral(red: 0.1764705916, green: 0.4980391158, blue: 0.7568617596, alpha: 1), child: nil),
//                Moon(radius: 0.5 * 0.5, center: Point(x: -1, y: 1, z: 1), color: #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1), child: nil),
//                ],
                   orbits: orbits
            )
            ]
        )
    }
    
    // MARK: - UIViewController overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        let galaxyNode = self.galaxy.getScene()
        galaxyNode.position = SCNVector3(1, 0, -3)
        scene.rootNode.addChildNode(galaxyNode)
        
        // Set the scene to the view
        sceneView.scene = scene
        
        contextMenuGesture.delegate = self
        tapGesture.delegate = self
        
//        contextMenuGesture.shouldRequireFailure(of: tapGesture)
        
        self.view.addGestureRecognizer(contextMenuGesture)
        self.view.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
        
        self.enableAllOrbits()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - ARSessionDelegate  methods
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
//        frame.camera.transform
        if let selectedStar = self.currentSelectedStar {
            let matrix = SCNMatrix4(frame.camera.transform)
            selectedStar.transform = SCNMatrix4Translate(matrix, 0, 0, -2)
        }
        
        if let contextMenu = self.contextMenuNode, let orientation = self.getCameraPosition(){
            contextMenu.look(at: orientation)
        }
    }
    
    
    // MARK: - Planet dragging helper functions
    
    func onStartDrag(at position: CGPoint){
        let hitResults = self.sceneView.hitTest(position, options: [:])
        if let result = hitResults.first, let pov = self.sceneView.pointOfView{
            self.currentSelectedStar = result.node
            self.currentSelectedStar!.removeFromParentNode()
            pov.addChildNode(self.currentSelectedStar!)
            
        }  else {
            print("AIII NAO PEGOU NADA")
        }
    }
    
    func onEndDrag(){
        if let selectedStar = self.currentSelectedStar{
//            print("selectedStar.transform", selectedStar.transform)
            let transform = selectedStar.worldTransform
            selectedStar.removeFromParentNode()
//            print("selectedStar.transform", selectedStar.transform)
            self.sceneView.scene.rootNode.addChildNode(selectedStar)
            selectedStar.setWorldTransform(transform)
        }
        
        self.currentSelectedStar = nil
    }
    
    // MARK: - Orbit helper methods
    func createOrbit(around center: SCNNode, child: SCNNode, radius: CGFloat){
        let orbitingNode = SCNNode()
        orbitingNode.position = SCNVector3(radius, 0, 0)
        child.removeFromParentNode()
        orbitingNode.addChildNode(child)
        let action = SCNAction.rotate(by: 3.1415, around: SCNVector3Zero, duration: 1)
        center.addChildNode(orbitingNode)
        orbitingNode.runAction(action)
        
    }
    
    func disableOrbit(of node: SCNNode){
        node.removeAllActions()
    }
    
    func enableAllOrbits(){
        for star in self.galaxy.stars{
            if let planet = star as? Planet{
                guard let parentNode = self.getNode(star: planet) else {
                    print("Oia so deu ruim cuzao")
                    continue
                }
                
                for orbit in planet.orbits ?? []{
                    guard let child = self.getNode(star: orbit.orbiter) else {
                        print("Na trave bro")
                        continue
                    }
                    var x: CGFloat = 0, y: CGFloat = 0, z: CGFloat = 0
                    let r = Int.random(in: 0...1)
                    if r == 0{
                        x = CGFloat.random(in: -0.5...0.5)
                        x = 1
                    } else if r == 1{
                        y = CGFloat.random(in: -0.5...0.5)
                        y = 1
                    }else{
                        z = CGFloat.random(in: -0.5...0.5)
                    }
                    
                    let worldTransform = child.worldTransform
                    let rotator = SCNNode()
                    let inclinator = SCNNode()
                    
                    
                    child.removeFromParentNode()
                    
                    rotator.addChildNode(child)

                    child.setWorldTransform(worldTransform)
                    
                    rotator.position = SCNVector3Zero
                    inclinator.addChildNode(rotator)
                    
                    inclinator.localTranslate(by: SCNVector3(0, Float.random(in: -1...1), 0))
                    
                    parentNode.addChildNode(inclinator)
                    
                    let rotateAction = SCNAction.rotate(by: CGFloat.pi, around: inclinator.position, duration: 3)
                    let foreverAction = SCNAction.repeatForever(rotateAction)
                    
                    rotator.runAction(foreverAction)
                    
//                    self.createOrbit(around: planetNode, child: child, radius: planet.radius + orbit.radius)
                    print("AEEEEEE")
                }
            }
        }
    }
    
    // MARK: - UIGestureRecognizer delegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
    }
    
    // Chamada quando da o tempo minimo para abrir o menu de contexto
    func onTriggered(_ gesture: ContextMenuGestureRecognizer) {
        
        self.onEndDrag()
        
        self.tapGesture.state = .failed
        let vib = UIImpactFeedbackGenerator()
        vib.impactOccurred()
        
        let position = gesture.location(in: self.view)
        self.displayContextMenu(at: position)
        
    }
    
    
    // MARK: - ContextMenu related functions
    
    func displayContextMenu(at position: CGPoint){
        let hitTest =  self.sceneView.hitTest(position, options: [:])
        
        if let contextMenuNode = self.contextMenuNode{
            contextMenuNode.removeFromParentNode()
            self.contextMenuNode = nil
        }
        
        var position: SCNVector3!
        var rootNode: SCNNode!
        
        if hitTest.count == 0{
            // Nao achou nada, mostrar menu de contexto do espaco
            self.contextMenu.openContextMenu(mode: .galaxy)
            
            guard let pos = self.getLookingCameraPosition() else { return }
            position = pos
            rootNode = self.sceneView.scene.rootNode
        } else if let hit = hitTest.first{
            // Encontrou em alguma coisa, mostrar o menu a partir disso
            
            self.contextMenu.openContextMenu(mode: .planet)
            guard let star = self.galaxy.getStar(by: hit.node.position) else {
                print("Olha so ta dando ruim")
                return
            }
            
            position = SCNVector3(0, 0.25 + star.radius, 0)
            rootNode = hit.node
        }
        
        let ctxMenuNode = self.contextMenu.getNode()
        ctxMenuNode.position = position
        
        rootNode.addChildNode(ctxMenuNode)
        
        let it = SCNLookAtConstraint(target: self.sceneView.pointOfView)
        it.isGimbalLockEnabled = true
        
        rootNode.constraints = [it]
        return
            
        self.contextMenuNode = ctxMenuNode

    }
    
    func hideContextMenu(){
        self.contextMenuNode?.removeFromParentNode()
        self.contextMenuNode = nil
        print("Hidden context menu")
    }
    
    // MARK: - Camera and world position related methods
    
    func getLookingCameraPosition(withOffset: Float? = nil) -> SCNVector3? {
        guard let orientation = self.getCameraOrientation() else { return nil }
        guard var pos = self.getCameraPosition() else { return nil }
        
        if let offset = withOffset{
            pos.x += offset
            pos.y += offset
            pos.z += offset
        }
//        return pos * orientation.versor() * 0.5
        return pos + orientation.normalized() * 0.5
    }
    
    func getCameraOrientation() -> SCNVector3?{
        guard let frame = self.sceneView.session.currentFrame else { return nil }
        
        let mat = SCNMatrix4(frame.camera.transform)
        
        return SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33)
    }
    
    func getCameraPosition() -> SCNVector3? {
        guard let frame = self.sceneView.session.currentFrame else { return nil }
        let mat = SCNMatrix4(frame.camera.transform)
        
        return SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33)
        
    }
    
    // MARK: - Callbacks
    
    @objc func onContextMenu(_ sender: ContextMenuGestureRecognizer){
        switch sender.state {
        case .began:
            self.onStartDrag(at: sender.location(in: self.view))
        case .ended:
            self.onEndDrag()
        default:
            break
        }
        
    }
    
    @objc func onTap(_ sender: UITapGestureRecognizer){
        let position = sender.location(in: self.view)
        
        if let hit = self.sceneView.hitTest(position, options: [:]).first{
            if hit.node == self.contextMenuNode{
                print("Node!!")
            }
        }
        
        self.hideContextMenu()
    }
    
    // Mark: - ARSceneView interruption delegates
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    func getNode(star named: Star) -> SCNNode?{
        return self.sceneView.scene.rootNode.childNode(withName: named.id, recursively: true)
    }
}


extension UIColor {
    
    class func randomColor(randomAlpha randomApha:Bool = false)->UIColor{
        
        let redValue = CGFloat(arc4random_uniform(255)) / 255.0;
        let greenValue = CGFloat(arc4random_uniform(255)) / 255.0;
        let blueValue = CGFloat(arc4random_uniform(255)) / 255.0;
        let alphaValue = randomApha ? CGFloat(arc4random_uniform(255)) / 255.0 : 1;
        
        return UIColor(red: redValue, green: greenValue, blue: blueValue, alpha: alphaValue)
        
    }
}
