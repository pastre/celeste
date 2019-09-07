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

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate, ContextMenuGestureDelegate, ContextMenuDelegate, PlanetContextMenuDelegate, UITextViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    func getOnScreenMenuBg() -> UIView {
        let view = UIView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = view.frame.height / 2
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        return view
    }
    
    // Mark: - Constants
    
    let createPlanetContextMenu = CreatePlanetContextMenu.instance
    let planetContextMenu = PlanetContextMenu.instance
//    let orbitContextMenu = OrbitContextMenu.instance
    lazy var galaxy: Galaxy = self.galaxyFacade.galaxy
    let galaxyFacade = GalaxyFacade.instance

    // MARK: - Gestures
    
    lazy var tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.onTap(_:)))
    lazy var contextMenuGesture: ContextMenuGestureRecognizer = ContextMenuGestureRecognizer(target: self, action: #selector(self.onContextMenu(_:)))
    
    // MARK: - UIKit elements
    
    var floorPaintingMenu = FloorPaintingMenu()
    var planetContextMenuView: UIView? = UIView()
    var contextMenuView: UIView? {
        didSet{
            if let _ = self.contextMenuView{
                self.isDisplayingUIContextMenu = true
            } else {
                self.isDisplayingUIContextMenu = false
            }
        }
    }
    lazy var addPlanetButton: UIView = {
        let tapGesture = UITapGestureRecognizer()
        let button = UIView()
        let imageView = UIImageView(image: UIImage(named: "planetMenuIcon"))
        
        tapGesture.addTarget(self, action: #selector(self.onDisplayAddPlanetMenu))

        button.addGestureRecognizer(tapGesture)
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = button.frame.height / 2
        button.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        
        button.addSubview(imageView)
        
        imageView.heightAnchor.constraint(equalTo: button.heightAnchor, multiplier: 0.8).isActive = true
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true
        
        imageView.rightAnchor.constraint(equalTo: button.leftAnchor, constant: 40).isActive = true
        imageView.centerYAnchor.constraint(equalTo: button.centerYAnchor).isActive = true
        
        return button
    }()
    
    // MARK: - SCNKit elements
    weak var tappedNode: SCNNode?
    weak var highlighterNode: SCNNode?
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
//        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
//        let galaxyNode = self.galaxy.getScene()
//        galaxyNode.transform =  SCNMatrix4Translate(self.sceneView.pointOfView?.transform ?? galaxyNode.transform, 0, 0, -3)
//        galaxyNode.name = "galaxy"
//        scene.rootNode.addChildNode(galaxyNode)
        
        // Set the scene to the view
        sceneView.scene = scene
        
        self.contextMenuGesture.delegate = self
        self.createPlanetContextMenu.currentParent = self
        self.createPlanetContextMenu.delegate = self
        self.tapGesture.delegate = self
        self.planetContextMenu.delegate = self
        
        self.tapGesture.name = "TapGesture"
//        contextMenuGesture.shouldRequireFailure(of: tapGesture)
        
        self.view.addGestureRecognizer(contextMenuGesture)
        self.view.addGestureRecognizer(tapGesture)
        
        self.contextMenuGesture.cancelsTouchesInView = false
        self.modalPresentationStyle = .overCurrentContext
        
        contextMenuGesture.require(toFail: tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
        
        
        self.enableAllOrbits()
        self.setupAddDisplayButton()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        for star in self.galaxy.stars{
            let node = star.getNode()
            self.sceneView.scene.rootNode.addChildNode(node)
        }
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
        
        if let camera = self.sceneView.pointOfView{
            
            for node in self.sceneView.scene.rootNode.childNodes{
                if let textNode = node.childNode(withName: "planetName", recursively: true){
                    textNode.look(at: camera.position)
                }
                
            }

        }
    }
    
    override func viewDidLayoutSubviews() {
        self.setupAddDisplayButton()
        print("LAYOUT")
    }
    
    // MARK: - OnScreen UI menu methods
    
    func setupAddDisplayButton(){
        self.view.addSubview(self.addPlanetButton)
        
        self.addPlanetButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        self.addPlanetButton.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.05).isActive = true
        self.addPlanetButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 30).isActive = true
        self.addPlanetButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -40).isActive = true
        
        self.addPlanetButton.layer.cornerRadius = self.addPlanetButton.frame.height / 2
        self.addPlanetButton.clipsToBounds = true
        
        print("Frame size is", self.addPlanetButton.frame.height)
        
        self.addPlanetButton.setNeedsLayout()
        self.addPlanetButton.setNeedsDisplay()
    }
    func displayAddPlanetMenu(){
        
        self.displayAddPlanetMeny()
        self.contextMenuView?.transform = (self.contextMenuView?.transform.translatedBy(x: 414, y: 0))!
        
        UIView.animate(withDuration: 0.3) {
            self.contextMenuView?.transform = .identity
            self.addPlanetButton.transform = self.addPlanetButton.transform.translatedBy(x: 414, y: 0)
        }
    }
    
    func closeAddPlanetMenu() {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.contextMenuView?.transform = (self.contextMenuView?.transform.translatedBy(x: 414, y: 0))!
            self.addPlanetButton.transform = .identity
        }, completion: { (_) in
            
            self.hideContextMenu()
        })
        
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
        self.highlighterNode?.geometry?.firstMaterial = nil
        self.highlighterNode = nil
    }
    
    // MARK: - Planet dragging helper functions
    
    func applyPlanetName(name: String?, to node: SCNNode){
        
        guard let radius = node.geometry?.boundingSphere.radius else { return }
        if let currentText = node.childNode(withName: "planetName", recursively: true){
            currentText.removeFromParentNode()
        }
        
        if name == "" { return }
        
        let text = SCNText(string: name, extrusionDepth: 1)
        let textNode = SCNNode(geometry: text)
        textNode.name = "planetName"
        
        
        node.addChildNode(textNode)
//        node.eulerAngles = SCNVector3(0, 0, 0)
        
        textNode.position = SCNVector3Zero
        textNode.position = SCNVector3(0, -(radius + 0.2), 0)
        textNode.scale = SCNVector3(0.01, 0.01, 0.01)
        
    }
    
    func onStartDrag(at position: CGPoint){
        
    }
    
    func moveNodeFromCamera(){
        if let selectedStar = self.currentSelectedStar{
            
            let newStar = selectedStar.clone()
            let transform = selectedStar.worldTransform
            
            self.currentSelectedStar!.removeFromParentNode()
            
            if self.createPlanetContextMenu.isDirty{
                // Planet creation
                let color = self.createPlanetContextMenu.currentColor!
                let scale = self.createPlanetContextMenu.getScale()
                var planet: Star!
                if let name = self.createPlanetContextMenu.currentName, let description = self.createPlanetContextMenu.currentDescription {
                 planet = self.galaxyFacade.createPlanet(node: newStar, color: color, shapeName: self.createPlanetContextMenu.currentShape, scaled: scale, name: name, description: description)
                    self.applyPlanetName(name: name, to: newStar)
                } else {
                    
                    planet = self.galaxyFacade.createPlanet(node: newStar, color: color, shapeName: self.createPlanetContextMenu.currentShape, scaled: scale)
                }
                
                
                newStar.name = planet.id
                
                self.createPlanetContextMenu.isDirty = false
                //                self.createPlanetContextMenu.setDefaults()
            } else {
                
            }
            
            self.sceneView.scene.rootNode.addChildNode(newStar)
            newStar.setWorldTransform(transform)
//            newStar.eulerAngles = SCNVector3Zero
            
            self.updatedOrbit(newStar)
            self.clearHighlight()
            self.applyPlanetName(name: self.createPlanetContextMenu.currentName, to: newStar)
            
            if self.hasDeleted {
                self.hasDeleted = false
            } else {
                self.galaxyFacade.sync(node: newStar, name: self.createPlanetContextMenu.currentName, description: self.createPlanetContextMenu.currentDescription)
            }
            
        }
        
        self.currentSelectedStar = nil
    }
    
    func onEndDrag(at location: CGPoint){
        self.moveNodeFromCamera()
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
        
        rotator.name = "rotator"
        inclinator.name = "inclinator"
        
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
//        if otherGestureRecognizer.name == "ContextMenuGesture" || gestureRecognizer.name == "TapGesture"{
//           return false
//        }
        
        return true
    }
//
    func displayPlanetMenu(){

        let displayMenuView = self.planetContextMenu.getView()

        self.view.addSubview(displayMenuView)

        displayMenuView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        displayMenuView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true

        displayMenuView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.5).isActive = true
        displayMenuView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.3).isActive = true

        self.contextMenuView = displayMenuView
    }
    
    // Chamada quando da o tempo minimo para abrir o menu de contexto
    func onTriggered(_ gesture: ContextMenuGestureRecognizer) {
//
//
//        if ((self.contextMenuView?.frame.contains(position)) ?? false){
//            return
//        }

        if self.isDisplayingUIContextMenu || self.contextMenuView != nil { return }
        
        let vib = UIImpactFeedbackGenerator()
        vib.impactOccurred()
//
        self.tapGesture.state = .cancelled
//        gesture.state = .cancelled
//
//        self.hideContextMenu()
        let position = gesture.location(in: self.view)
        let hitResults = self.sceneView.hitTest(position, options: [:])
        
        if let result = hitResults.first, let pov = self.sceneView.pointOfView{
            self.currentSelectedStar = result.node

            if self.currentSelectedStar!.parent?.name == "rotator"{
                self.currentSelectedStar!.parent?.parent?.removeFromParentNode()
                self.galaxyFacade.updateOrbit(of: result.node)

            } else {
                self.currentSelectedStar!.removeFromParentNode()
            }
            self.currentSelectedStar!.removeFromParentNode()
            self.currentSelectedStar?.removeAllActions()
            pov.addChildNode(self.currentSelectedStar!)

        }
//
    }
    
    // MARK: - ContextMenu related functions
    
    func displayAddPlanetMeny(){
        self.hideContextMenu()
        let menu = self.createPlanetContextMenu.getView()
        
        self.view.addSubview(menu)
        
        menu.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        menu.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        menu.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -40).isActive = true
        menu.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.95).isActive = true
        
        self.view.bringSubviewToFront(menu)
        
        self.contextMenuView = menu
        self.isDisplayingUIContextMenu = true
    }
    
    func resetPosition(of star: Star){
        guard let selectedStar = self.currentSelectedStar else { return }
        guard let transform = self.selectedNodePreviousWorldPosition else { return }
        
        let newStar = selectedStar.clone()
        
        self.currentSelectedStar!.removeFromParentNode()
        
        self.sceneView.scene.rootNode.addChildNode(newStar)
        
        newStar.worldPosition = transform
        newStar.name = star.id
        
        self.clearHighlight()
        
        self.galaxyFacade.sync(node: newStar, name: self.createPlanetContextMenu.currentName, description: self.createPlanetContextMenu.currentDescription)
        
        self.applyPlanetName(name: self.createPlanetContextMenu.currentName, to: newStar)
    }
    
    func hideUIContextMenu(){
        self.contextMenuView?.removeFromSuperview()
        self.contextMenuView = nil
        self.isDisplayingUIContextMenu = false
    }
    
    func hideSCNNodeMenu(){
        
        self.currentSelectedStar?.removeFromParentNode()
        self.currentSelectedStar = nil
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
        if currentSelectedStar == nil { return }
        self.currentSelectedStar!.scale = SCNVector3(scale , scale, scale)
    }
    
    func onNewPlanetTextureChanged(to texture: UIImage?){
        self.currentSelectedStar?.geometry?.firstMaterial?.diffuse.contents = texture
    }
    
    func onNewPlanetUpdated(planetNode: SCNNode) {
        
        planetNode.removeFromParentNode()
        if self.currentSelectedStar == nil{
            self.sceneView.pointOfView?.addChildNode(planetNode)
        }else{
            self.sceneView.pointOfView?.replaceChildNode(self.currentSelectedStar!, with: planetNode)
        }
        
        self.currentSelectedStar = planetNode
        
    }
    
    var selectedNodePreviousWorldPosition: SCNVector3?
 
    func onCancel(_ star: Star?) {
        if let s  = star {
            self.resetPosition(of: s)
        }
        self.currentSelectedStar?.removeFromParentNode()
        self.currentSelectedStar = nil
        self.closeAddPlanetMenu()
        
    }
    
    func onSave(_ star: Star?){
        if let s  = star {
            self.resetPosition(of: s)
        } else {
            self.moveNodeFromCamera()
        }
        
        
        self.closeAddPlanetMenu()
    }
    
    func onDelete(star: Star) {
        self.galaxyFacade.deletePlanet(with: self.currentSelectedStar!)
        self.currentSelectedStar?.removeFromParentNode()
        self.currentSelectedStar = nil
        self.closeAddPlanetMenu()
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
        if sender.state == .ended && (!self.isDisplayingUIContextMenu || self.contextMenuView == nil) {
                self.moveNodeFromCamera()
        }
    }
    
    
    @objc func onDisplayAddPlanetMenu(){
        self.displayAddPlanetMenu()
    }
    
    @objc func onTap(_ sender: UITapGestureRecognizer){
        
        if self.isDisplayingUIContextMenu {
            self.contextMenuView?.endEditing(true)
            self.view.endEditing(true)
            
            return
        }
        
        let position = sender.location(in: self.view)
        
        if self.addPlanetButton.frame.contains(position) { return }
        
        if let hit = self.sceneView.hitTest(position, options: [:]).first{
            if hit.node == self.currentSelectedStar{
                print("Node!!")
            } else  if !self.contextMenuGesture.hasTriggered{
                self.tappedNode = hit.node
                
                let star = self.galaxy.getStar(by: hit.node)
                self.createPlanetContextMenu.currentStar = star
                
                self.selectedNodePreviousWorldPosition = hit.node.worldPosition
                
                self.displayAddPlanetMenu()
                
                hit.node.removeFromParentNode()
//                let vc = self.createPlanetContextMenu()
//                vc.sceneViewController = self
//                self.modalTransitionStyle = .crossDissolve
//                vc.modalPresentationStyle = .overCurrentContext
//                vc.modalTransitionStyle = .crossDissolve
//                self.present(vc, animated: true) {
//                    print("Saca so acabou de apresentar")
//                }
            }
        }
//        let isInView = self.contextMenuView?.frame.contains(position) ?? false
//        print("isInView", isInView, self.contextMenuView?.frame.contains(position), self.contextMenuView?.frame, position, self.contextMenuView?.bounds)
//        if !(isInView ?? true) {
//        if !((self.contextMenuView?.subviews.first?.frame.contains(position)) ?? false){
//            self.hideContextMenu()
//        }
//        }
        
    }
    
    
    // MARK: - ARSceneView interruption delegates
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
    
    

    // MARK: - UITextFieldDelegate methods
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == self.createPlanetContextMenu.PLACEHOLDER_COLOR && (textView.text == self.createPlanetContextMenu.NAME_PLACEHOLDER_TEXT || textView.text == self.createPlanetContextMenu.DESCRIPTION_PLACEHOLDER_TEXT){
            textView.text = ""
            textView.textColor = self.createPlanetContextMenu.TEXT_COLOR
        }
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty{
            textView.textColor = self.createPlanetContextMenu.PLACEHOLDER_COLOR
            textView.text = self.createPlanetContextMenu.DESCRIPTION_PLACEHOLDER_TEXT
            
            if textView.tag == 1{
                textView.text = self.createPlanetContextMenu.NAME_PLACEHOLDER_TEXT
            }
        }
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let updatedText = textView.text as NSString? else { return true }
        let realText  = updatedText.replacingCharacters(in: range, with: text)
        
        if textView.tag == 1{
            self.createPlanetContextMenu.currentName = realText
        }else {
            self.createPlanetContextMenu.currentDescription = realText
        }
        
        return true
    }
    
    
}

