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

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate, ContextMenuGestureDelegate, ContextMenuDelegate, PlanetContextMenuDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    // Mark: - Constants
    let createPlanetContextMenu = CreatePlanetContextMenu.instance
//    let orbitContextMenu = OrbitContextMenu.instance
    lazy var galaxy: Galaxy =  self.getDebugGalaxy()
    let galaxyFacade = GalaxyFacade.instance

    // MARK: - Gestures
    lazy var tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.onTap(_:)))
    lazy var contextMenuGesture: ContextMenuGestureRecognizer = ContextMenuGestureRecognizer(target: self, action: #selector(self.onContextMenu(_:)))
    
    // MARK: - UIKit elements
    var planetContextMenuView: UIView? = UIView()
    var addPlanetButton: UIButton = {
        let button = UIButton()
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "add_icon"), for: .normal)
        button.layer.cornerRadius = button.frame.height / 2
        button.layer.borderWidth = 1
        button.layer.borderColor = #colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1)
        button.backgroundColor = #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)
        
        
        return button
    }()
    var contextMenuView: UIView? {
        didSet{
            if let _ = self.contextMenuView{
                self.isDisplayingUIContextMenu = true
            } else {
                self.isDisplayingUIContextMenu = false
            }
        }
    }
    
    // MARK: - SCNKit elements
    weak var tappedNode: SCNNode?
    weak var highlighterNode: SCNNode?
    weak var contextMenuNode: SCNNode?
    weak var currentSelectedStar: SCNNode?{
        didSet{
            if self.currentSelectedStar == nil{
                self.isMovingNode = false
            } else {
                self.isMovingNode = true
            }
        }
    }

    // MARK: - Flags
    var isMovingNode: Bool! = false
    var isDisplayingUIContextMenu: Bool = false
    var hasDeleted = false
    
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
        
//        let galaxyNode = self.galaxy.getScene()
//        galaxyNode.transform =  SCNMatrix4Translate(self.sceneView.pointOfView?.transform ?? galaxyNode.transform, 0, 0, -3)
//        galaxyNode.name = "galaxy"
//        scene.rootNode.addChildNode(galaxyNode)
  
        for star in self.galaxy.stars{
            let node = star.getNode()
            scene.rootNode.addChildNode(node)
        }
        
        // Set the scene to the view
        sceneView.scene = scene
        
        self.contextMenuGesture.delegate = self
        self.createPlanetContextMenu.delegate = self
        self.tapGesture.delegate = self
        self.planetContextMenu.delegate = self
        
        self.tapGesture.name = "TapGesture"
//        contextMenuGesture.shouldRequireFailure(of: tapGesture)
        
        self.view.addGestureRecognizer(contextMenuGesture)
        self.view.addGestureRecognizer(tapGesture)
        
        self.contextMenuGesture.cancelsTouchesInView = false
        self.setupAddPlanetButton()
        self.modalPresentationStyle = .overCurrentContext
    }
    
    func setupAddPlanetButton(){
        self.addPlanetButton.addTarget(self, action: #selector(self.displayAddPlanetMenu), for: .touchDown)
        
        self.view.addSubview(self.addPlanetButton)
        
        self.addPlanetButton.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 40).isActive = true
        self.addPlanetButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -20).isActive = true
        
        self.addPlanetButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.1).isActive = true
        self.addPlanetButton.heightAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.1).isActive = true
        
        self.addPlanetButton.layer.cornerRadius = self.addPlanetButton.frame.width / 2
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
            selectedStar.position = SCNVector3(x: 0, y: 0, z: -3)
            self.updateHighlightedNode()
        }
        
        if let contextMenu = self.contextMenuNode{
            contextMenu.position = SCNVector3(x: 0, y: 0, z: -3)
        }
    
        if let camera = self.sceneView.pointOfView{
            
            for node in self.sceneView.scene.rootNode.childNodes{
                if let textNode = node.childNode(withName: "planetName", recursively: true){
                    textNode.look(at: camera.position)
                }
                
            }

        }
    }
    
    // MARK: - Node highlight related methods
    
    func updateHighlightedNode(){
        
        let centerPoint = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height / 2)
        let hitTest = self.sceneView.hitTest(centerPoint, options: [:])
        
        for test in hitTest{
            if test.node == self.currentSelectedStar{ continue }
            self.highlight(node: test.node)
            return
            
        }
    }
    
    func getHighlighterNode() -> SCNNode{
        let geometry = SCNPyramid(width: 0.6, height: 0.8, length: 0.6)
        let node = SCNNode(geometry: geometry)
        
        geometry.firstMaterial?.diffuse.contents = UIColor.purple
        
        return node
    }
    
    func highlight(node: SCNNode){
        
        if let n = self.highlighterNode{
            n.removeFromParentNode()
        }
        
        let a = self.sceneView.scene.rootNode
        
        
        let highlighter = self.getHighlighterNode()
        self.highlighterNode = highlighter
        node.addChildNode(highlighter)
        guard let radius = node.geometry?.boundingSphere.radius else { return }
        
        let rotate = SCNAction.rotateBy(x: 0, y: CGFloat.pi, z: 0, duration: 1)
        let foreverAction = SCNAction.repeatForever(rotate)
        
        highlighterNode?.runAction(foreverAction)
        
        highlighterNode?.eulerAngles.x = Float.pi
        highlighterNode?.position = SCNVector3(x: 0, y: (radius + 0.85), z: 0)
        
    }
    
    func clearHighlight(){
        self.highlighterNode?.removeFromParentNode()
        self.highlighterNode = nil
    }
    
    // MARK: - Planet dragging helper functions
    
    func onStartDrag(at position: CGPoint){
//        let position = gesture.location(in: self.view)
//
//        if ((self.contextMenuView?.subviews.first?.frame.contains(position)) ?? false){
//            return
//        }
//
//        self.hideContextMenu()
//        let hitResults = self.sceneView.hitTest(position, options: [:])
//        if let result = hitResults.first, let pov = self.sceneView.pointOfView{
//            self.currentSelectedStar = result.node
//            self.currentSelectedStar!.removeFromParentNode()
//            pov.addChildNode(self.currentSelectedStar!)
//
//            if self.isDisplayingUIContextMenu{
//                self.hideUIContextMenu()
//            } else {
//                self.hideContextMenu()
//            }
//        }
    }
    
    func onEndDrag(at location: CGPoint){
        if let selectedStar = self.currentSelectedStar{
            
            let newStar = selectedStar.clone()
            let transform = selectedStar.worldTransform
            selectedStar.removeFromParentNode()

            if let color = self.createPlanetContextMenu.currentColor{
                let scale = self.createPlanetContextMenu.getScale()
                let planet = self.galaxyFacade.createPlanet(node: newStar, color: color, shapeName: self.createPlanetContextMenu.currentShape, scaled: scale)
                
                newStar.name = planet.id
                self.createPlanetContextMenu.currentColor = nil
            }
            
            self.sceneView.scene.rootNode.addChildNode(newStar)
            newStar.setWorldTransform(transform)
            newStar.eulerAngles = SCNVector3Zero
            
            self.planetContextMenu.onPanEnded(canceled: location.y < 100, lastNode: newStar)
        
            self.updatedOrbit(newStar)
            self.clearHighlight()
            
            if self.hasDeleted {
                self.hasDeleted = false
            } else {
                self.galaxyFacade.sync(node: newStar)
            }
            
        }
        
        self.currentSelectedStar = nil
    }
    
    // MARK: - Orbit helper methods
    
    func updatedOrbit(_ star: SCNNode){
        let centerPoint = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height / 2)
        let hitTest = self.sceneView.hitTest(centerPoint, options: [:])
        
        for test in hitTest{
            if test.node == self.currentSelectedStar{ continue }
            
            print("created orbit!")
            self.createOrbit(around: test.node, child: star, radius: 0.02)
            
            if test.node.name == "sphere"{
                guard let node = self.galaxy.getStar(by: test.node.position)?.getNode() else { return }
                self.galaxyFacade.createOrbit(around: node, child: star, with: 0.02)
            } else {
                self.galaxyFacade.createOrbit(around: test.node, child: star, with: 0.02)
            }
            
            break
        }
    }
    
    func createOrbit(around center: SCNNode, child: SCNNode, radius: CGFloat){
        
        let worldTransform = child.worldTransform
        let rotator = SCNNode()
        let inclinator = SCNNode()
        
        
        child.removeFromParentNode()
        
        rotator.addChildNode(child)
        
        child.setWorldTransform(worldTransform)
        
        rotator.position = SCNVector3Zero
        inclinator.addChildNode(rotator)
        inclinator.localTranslate(by: SCNVector3(0, Float.random(in: -1...1), 0))
        
        center.addChildNode(inclinator)
        
        let rotateAction = SCNAction.rotate(by: CGFloat.pi, around: inclinator.position, duration: 3)
        let foreverAction = SCNAction.repeatForever(rotateAction)
        
        rotator.runAction(foreverAction)
    }
    
    func disableOrbit(of node: SCNNode){
        node.removeAllActions()
    }
    
    func enableAllOrbits(){
        var orbitingNodes = [SCNNode]()
        
        for star in self.galaxy.stars{
            if let planet = star as? Planet{
                print("ASPLANET BRO")
                guard let parentNode = self.getNode(star: planet) else {
                    print("Oia so deu ruim cuzao")
                    continue
                }
                
                for orbit in planet.orbits ?? []{
                    guard let child = self.getNode(star: orbit.orbiter) else {
                        print("Na trave bro")
                        continue
                    }
                    
                    self.createOrbit(around: parentNode, child: child, radius: CGFloat.random(in: 0...0.5))
                    orbitingNodes.append(child)
                    print("AEEEEEE")
                }
            } else {
                print("NOPLANET BRO")
            }
        }
        
        for node in orbitingNodes{
            let root = self.sceneView.scene.rootNode
            print("Testing")
            if root.childNodes.contains(node) {
                node.removeFromParentNode()
                print("aeeeeeeee tirou")
            }
        }
    }
    
    // MARK: - UIGestureRecognizer delegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer.name == "ContextMenuGesture" || gestureRecognizer.name == "TapGesture"{
           return false
        }
        
        return true
    }
    
    
    let planetContextMenu = PlanetContextMenu.instance
    
    func displayPlanetMenu(){

        let displayMenuView = self.planetContextMenu.getView()
        
        self.view.addSubview(displayMenuView)
        
        displayMenuView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        displayMenuView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        
        displayMenuView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.5).isActive = true
        displayMenuView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.3).isActive = true
        
        self.contextMenuView = displayMenuView
        
        self.contextMenuGesture.state = .possible
    }
    
    // Chamada quando da o tempo minimo para abrir o menu de contexto
    func onTriggered(_ gesture: ContextMenuGestureRecognizer) {
        
        let position = gesture.location(in: self.view)
        
        if ((self.contextMenuView?.subviews.first?.frame.contains(position)) ?? false){
            return
        }
        
        let vib = UIImpactFeedbackGenerator()
        vib.impactOccurred()

        self.tapGesture.state = .cancelled
        self.hideContextMenu()
        let hitResults = self.sceneView.hitTest(position, options: [:])
        if let result = hitResults.first, let pov = self.sceneView.pointOfView{
            self.currentSelectedStar = result.node
            self.currentSelectedStar!.removeFromParentNode()
            self.currentSelectedStar?.removeAllActions()
            pov.addChildNode(self.currentSelectedStar!)
            
            if self.isDisplayingUIContextMenu{
                self.hideUIContextMenu()
            } else {
                self.hideContextMenu()
            }
            
            self.displayPlanetMenu()
        } else {
            self.displayAddPlanetMenu()
        }
        
    }

    
    @objc func displayAddPlanetMenu(){
        
        self.tapGesture.state = .failed
        let vib = UIImpactFeedbackGenerator()
        vib.impactOccurred()
        
        self.displayUIContextMenu()
        displaySceneContextMenu( )

    }
    
    // MARK: - ContextMenu related functions
    
    func displayUIContextMenu(){
        self.hideContextMenu()
        let menu = self.createPlanetContextMenu.getView()
        
        self.view.addSubview(menu)
        
        menu.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        menu.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        menu.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        menu.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 1).isActive = true
        
        self.view.bringSubviewToFront(menu)
        
        self.contextMenuView = menu
        self.isDisplayingUIContextMenu = true
    }
    
    func displaySceneContextMenu(){
        
        let node = self.createPlanetContextMenu.getNode()
        self.onNewPlanetUpdated(planetNode: node)
        self.createPlanetContextMenu.openContextMenu(mode: .planet)
        
    }
    
    func hideUIContextMenu(){
        self.contextMenuView?.removeFromSuperview()
        self.contextMenuView = nil
        self.isDisplayingUIContextMenu = false
    }
    
    func hideSCNNodeMenu(){
        self.contextMenuNode?.removeFromParentNode()
        self.contextMenuNode = nil
    }
    
    func hideContextMenu(){
        self.hideUIContextMenu()
        self.hideSCNNodeMenu()
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
    
    func onPanChanged(_ gesture: ContextMenuGestureRecognizer){
        let position = gesture.location(in: self.view)
        let center = CGPoint(x: self.view.frame.maxX  / 2, y: self.view.frame.maxY / 2)
        let diff =  position - center
        let dist = (diff.x * diff.x + diff.y * diff.y).squareRoot()

        self.planetContextMenu.updateHighlightedIcon(at: dist > 50 ? diff : nil)
    }
    
    // MARK: - ContextMenuDelegate methods
    func onNewPlanetScaleChanged(to scale: Float) {
        if contextMenuNode == nil { return }
        self.contextMenuNode!.scale = SCNVector3(scale , scale, scale)
    }
    
    func onNewPlanetTextureChanged(to texture: UIImage?){
        self.contextMenuNode?.geometry?.firstMaterial?.diffuse.contents = texture
    }
    
    func onNewPlanetUpdated(planetNode: SCNNode) {
        
        planetNode.removeFromParentNode()
        if self.contextMenuNode == nil{
            self.sceneView.pointOfView?.addChildNode(planetNode)
        }else{
            self.sceneView.pointOfView?.replaceChildNode(self.contextMenuNode!, with: planetNode)
        }
        
        self.contextMenuNode = planetNode
        
    }
    
    
    
    // MARK: - PlanetContextMenuDelegate methods
    func onEdit() {
        defer { self.hideUIContextMenu()}
        print("Mostrei!")
    }
    
    func onOrbit(source node: SCNNode) {
        defer { self.hideUIContextMenu()}
        print("Orbit!")
        
    }
    
    func onCopy() {
        defer { self.hideUIContextMenu()}
        print("Copy!")
        
    }
    
    func onDelete(node: SCNNode) {
        defer { self.hideUIContextMenu()}
        print("Delete!")
        //        self.hideContextMenu()
        //        assert(self.currentSelectedStar != nil)
        self.hasDeleted = true
        self.galaxyFacade.deletePlanet(with: node)
        node.removeFromParentNode()
        //         = nil
    }
    
    func onEnded() {
        defer { self.hideUIContextMenu()}
        print("Ended!")
    }
    

    
    // MARK: - Callbacks
    
    @objc func onContextMenu(_ sender: ContextMenuGestureRecognizer){
        switch sender.state {
        case .began:
            self.onStartDrag(at: sender.location(in: self.view))
        case .changed:
            self.onPanChanged(sender)
        case .ended:
            self.onEndDrag(at: sender.location(in: self.view))
        default:
            break
        }
        
    }
    
    @objc func onTap(_ sender: UITapGestureRecognizer){
        let position = sender.location(in: self.view)
        
        if let hit = self.sceneView.hitTest(position, options: [:]).first{
            if hit.node == self.contextMenuNode || hit.node == self.currentSelectedStar{
                print("Node!!")
            } else  if !self.contextMenuGesture.hasTriggered{
                self.tappedNode = hit.node
                let vc = PlanetDetailViewController()
                vc.sceneViewController = self
                self.modalTransitionStyle = .crossDissolve
                vc.modalPresentationStyle = .overCurrentContext
                vc.modalTransitionStyle = .crossDissolve
                self.present(vc, animated: true) {
                    print("Saca so acabou de apresentar")
                }
            }
        }
//        let isInView = self.contextMenuView?.frame.contains(position) ?? false
//        print("isInView", isInView, self.contextMenuView?.frame.contains(position), self.contextMenuView?.frame, position, self.contextMenuView?.bounds)
//        if !(isInView ?? true) {
        if !((self.contextMenuView?.subviews.first?.frame.contains(position)) ?? false){
            self.hideContextMenu()
        }
//        }
        
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
    
    
    
    func getDebugGalaxy() -> Galaxy{
        return self.galaxyFacade.getCurrentGalaxy()
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
                   orbits: orbits)
            ]
        )
    }
    
    

}

