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
   
    // MARK: - PlanetContextMenuDelegate methods
    func onEdit() {
        self.hideContextMenu()
        print("Edit!")
        self.displayAddPlanetMenu()
    }
    
    func onDelete() {
        print("Delete!")
        self.currentSelectedStar?.removeFromParentNode()
    }
    
    func onOrbit() {
        print("Orbit!")
    }
    
    func onCopy() {
        print("Copy!")
    }
    
    
    
    @IBOutlet var sceneView: ARSCNView!
    
    let createPlanetContextMenu = CreatePlanetContextMenu.instance
    var planetContextMenuView: UIView = {
        let view = UIView()
        
        return view
    }()
    
    lazy var tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.onTap(_:)))
    lazy var contextMenuGesture: ContextMenuGestureRecognizer = ContextMenuGestureRecognizer(target: self, action: #selector(self.onContextMenu(_:)))
    
    var currentSelectedStar: SCNNode?{
        didSet{
            if self.currentSelectedStar == nil{
                self.isMovingNode = false
            } else {
                self.isMovingNode = true
            }
        }
    }
    
    var contextMenuNode: SCNNode?
    var contextMenuView: UIView? {
        didSet{
            if let _ = self.contextMenuView{
                self.isDisplayingUIContextMenu = true
            } else {
                self.isDisplayingUIContextMenu = false
            }
        }
    }
    
    var isMovingNode: Bool! = false
    var isDisplayingUIContextMenu: Bool = false
    
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
                   orbits: orbits)
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
        galaxyNode.transform =  SCNMatrix4Translate(self.sceneView.pointOfView?.transform ?? galaxyNode.transform, 0, 0, -3)
        galaxyNode.name = "galaxy"
        scene.rootNode.addChildNode(galaxyNode)
        
        // Set the scene to the view
        sceneView.scene = scene
        
        self.contextMenuGesture.delegate = self
        self.createPlanetContextMenu.delegate = self
        self.tapGesture.delegate = self
        self.planetContextMenu.delegate = self
//        contextMenuGesture.shouldRequireFailure(of: tapGesture)
        
        self.view.addGestureRecognizer(contextMenuGesture)
        self.view.addGestureRecognizer(tapGesture)
        
        self.contextMenuGesture.cancelsTouchesInView = false
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
        }
        
        if let contextMenu = self.contextMenuNode, let orientation = self.sceneView.pointOfView{
            contextMenu.position = SCNVector3(x: 0, y: 0, z: -3)
        }
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
            
            self.sceneView.scene.rootNode.addChildNode(newStar)
            newStar.setWorldTransform(transform)
            
            self.currentSelectedStar = nil
            self.planetContextMenu.onPanEnded(canceled: location.y < 100)
            
        } else {
            self.currentSelectedStar = nil
        }
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
//                    inclinator.eulerAngles.y = Float.pi * 2 * Float.random(in: -1...1)
//                    inclinator.localRotate(by: SCNQuaternion(0, Float.random(in: -1...1), 0, 0))
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
        if otherGestureRecognizer.name == "ContextMenuGesture"{
           return false
        }
//        if (self.contextMenuView?.frame.contains(gestureRecognizer.location(in: self.view))) ?? false{
//            return false
//        }
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

        
        self.hideContextMenu()
        let hitResults = self.sceneView.hitTest(position, options: [:])
        if let result = hitResults.first, let pov = self.sceneView.pointOfView{
            self.currentSelectedStar = result.node
            self.currentSelectedStar!.removeFromParentNode()
            pov.addChildNode(self.currentSelectedStar!)
            
            if self.isDisplayingUIContextMenu{
                self.hideUIContextMenu()
            } else {
                self.hideContextMenu()
            }
            
            self.displayPlanetMenu()
        }
        
    }

    
    func displayAddPlanetMenu(){
        
        
        if self.isMovingNode { return }
        
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
        
        print("Added menu!", self.contextMenuView)
        
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
    
    func onPanChanged(_ gesture: ContextMenuGestureRecognizer){
        let position = gesture.location(in: self.view)
        let center = CGPoint(x: self.view.frame.maxX  / 2, y: self.view.frame.maxY / 2)
        let diff = position - center
        
        self.planetContextMenu.updateHighlightedIcon(at: diff)
//        gesture
//        print("Position is", diff)
    }
    
    // MARK: - ContextMenuDelegate methods
    func onNewPlanetScaleChanged(to scale: Float) {
        if contextMenuNode == nil { return }
        self.contextMenuNode!.scale = SCNVector3(scale , scale, scale)
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
            if hit.node == self.contextMenuNode{
                print("Node!!")
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
    
    
}

