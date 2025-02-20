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

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate, ContextMenuGestureDelegate, ContextMenuDelegate, UITextViewDelegate, AppMenuDelegate {
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var loadingImage: UIImageView!
    
    let sessionInfoView: UIView! = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }()
    
    var sessionInfoLabel: UILabel! = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.white
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        return label
        }() {
        didSet{
            self.sessionInfoView.isHidden =  self.sessionInfoLabel.text == ""
        }
    }
    
    
    var timer: Timer?
    func animateLoadingScreen(){
//        let images = ["loading_brain", "loading_lamp", "loading_planet", "loading_venus", "loading_teapot"]
//        var currentIndex: Int = 0 {
//            didSet{
//                if currentIndex >= images.count {
//                    currentIndex = 0
//                }
//            }
//        }
//        let duration: TimeInterval =  1.2
//        DispatchQueue.main.async {
//            self.timer = Timer.scheduledTimer(withTimeInterval: duration + 0.2 , repeats: true) { (_) in
//                UIView.animate(withDuration: duration/2, animations: {
//                    self.loadingImage.transform = self.loadingImage.transform.scaledBy(x: 0.1, y: 0.1)
//                }, completion: { (_) in
//                    self.loadingImage.image = UIImage(named: images[currentIndex])
//                    UIView.animate(withDuration: duration/2, animations: {
//                        self.loadingImage.transform = self.loadingImage.transform.scaledBy(x: 10, y: 10)
//                    }, completion: { (_) in
////                        UIView.animate(withDuration: duration/3, animations: {
////                            self.loadingImage.transform = .identity
////                        })
//                    currentIndex  += 1
//                    })
//                })
//            }
//        }
    }
    
    // Mark: - Constants
    
    let createPlanetContextMenu = CreatePlanetContextMenu.instance
    let appMenu = AppMenu.instance
    
//    let orbitContextMenu = OrbitContextMenu.instance
    
    let galaxyFacade = GalaxyFacade.instance

    // MARK: - Gestures
    
    lazy var tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.onTap(_:)))
    lazy var contextMenuGesture: ContextMenuGestureRecognizer = ContextMenuGestureRecognizer(target: self, action: #selector(self.onContextMenu(_:)))
    
    // MARK: - UIKit elements
    
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
    

    
    lazy var appMenuButton: UIView = self.getOption(imageView: UIImageView(image: UIImage(named: "menu")), action: #selector(self.onAppMenu), mult: 8/13, heightMult: 0.5, rightMargin: 20)
    
    @objc func onAppMenu(_ sender: UIButton){
        print("AppMenu!!!")
        self.openAppMenu()
    }
    
    lazy var addPlanetButton: UIView = self.getOption(imageView: UIImageView(image: UIImage(named: "planetMenuIcon")), action: #selector(self.onDisplayAddPlanetMenu))
    
    // MARK: - SCNKit elements
    weak var tappedNode: SCNNode?
    weak var highlighterNode: SCNNode?
    weak var currentSelectedStar: SCNNode?{
        didSet{
            if self.currentSelectedStar == nil{
                self.isMovingNode = false
            } else {
                self.isMovingNode = true
                if self.currentSelectedStar?.parent == nil{
                    
                    self.sceneView.pointOfView?.addChildNode(self.currentSelectedStar!)
                }
            }
        }
    }

    // MARK: - Flags
    var isMovingNode: Bool! = false
    var isDisplayingUIContextMenu: Bool = false{
        didSet{
            
                self.sessionInfoView.isHidden = self.isDisplayingUIContextMenu
            
        }
    }
    var hasDeleted = false
    var hasLoaded = false


    // MARK: - UIViewController overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.animateLoadingScreen()
        
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
        
        self.tapGesture.name = "TapGesture"
//        contextMenuGesture.shouldRequireFailure(of: tapGesture)
        
        self.view.addGestureRecognizer(contextMenuGesture)
        self.view.addGestureRecognizer(tapGesture)
        
        self.contextMenuGesture.cancelsTouchesInView = false
        
        contextMenuGesture.require(toFail: tapGesture)
        
        animateLoadingScreen()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    func resetTracking(){
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = [.horizontal]
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewDidLayoutSubviews() {
        self.setupAddDisplayButton()
        self.setupMenuAppButton()
        self.setupARInfoView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        self.contextMenuGesture.delegate = self
        self.createPlanetContextMenu.currentParent = self
        self.createPlanetContextMenu.delegate = self
        self.appMenu.delegate = self
        self.tapGesture.delegate = self

        for star in self.galaxyFacade.galaxy.stars{
            let node = star.getNode()
            self.sceneView.scene.rootNode.addChildNode(node)
            self.applyPlanetName(name: star.name, to: node)
        }
        
        self.resetTracking()
        self.enableAllOrbits()

        
        self.timer?.invalidate()
        if !self.hasLoaded{
            self.loadingView.removeFromSuperview()
            self.hasLoaded = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        
    }
    
    deinit {
        
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
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else { return }
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }
    
    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else { return }
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        updateSessionInfoLabel(for: session.currentFrame!, trackingState: camera.trackingState)
    }

    
    // MARK: - OnScreen UI menu methods
    
    func getOption(imageView: UIImageView, action selector: Selector, mult: CGFloat = 1, heightMult: CGFloat = 0.8, rightMargin: CGFloat = 40) -> UIView{
        
        let tapGesture = UITapGestureRecognizer()
        let buttonView = UIView()
        
        tapGesture.addTarget(self, action: selector)
        
        buttonView.addGestureRecognizer(tapGesture)
        buttonView.clipsToBounds = true
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        buttonView.layer.cornerRadius = buttonView.frame.height / 2
        buttonView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        
        buttonView.addSubview(imageView)
        
        imageView.heightAnchor.constraint(equalTo: buttonView.heightAnchor, multiplier: heightMult).isActive = true
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: mult).isActive = true
        
        imageView.rightAnchor.constraint(equalTo: buttonView.leftAnchor, constant: rightMargin).isActive = true
        imageView.centerYAnchor.constraint(equalTo: buttonView.centerYAnchor).isActive = true
        
        return buttonView
    }
    
    func hideMenus(){
        
        
        UIView.animate(withDuration: 0.3, animations: {
            self.contextMenuView?.transform = (self.contextMenuView?.transform.translatedBy(x: 414, y: 0))!
            self.addPlanetButton.transform = .identity
            self.appMenuButton.transform = .identity
        }, completion: { (_) in
            
            self.hideContextMenu()
        })
    }
    func openMenu(){
        
        self.contextMenuView?.transform = (self.contextMenuView?.transform.translatedBy(x: 414, y: 0))!
        
        UIView.animate(withDuration: 0.3) {
            self.contextMenuView?.transform = .identity
            self.addPlanetButton.transform = self.addPlanetButton.transform.translatedBy(x: 414, y: 0)
            self.appMenuButton.transform = self.addPlanetButton.transform.translatedBy(x: 414, y: 0)
        }
    }
    
    func setupARInfoView(){
        self.view.addSubview(self.sessionInfoView)
        self.sessionInfoView.addSubview(self.sessionInfoLabel)
        
//        sessionInfoLabel.centerXAnchor.constraint(equalTo: self.sessionInfoView.centerXAnchor).isActive = true
//        sessionInfoLabel.centerYAnchor.constraint(equalTo: self.sessionInfoView.centerYAnchor).isActive = true
//        sessionInfoLabel.widthAnchor.constraint(equalTo: self.sessionInfoView.widthAnchor, multiplier: 0.95).isActive = true
//        sessionInfoLabel.heightAnchor.constraint(equalTo: self.sessionInfoView.heightAnchor).isActive = true
        
        sessionInfoLabel.topAnchor.constraint(equalTo: self.sessionInfoView.topAnchor, constant: 10).isActive = true
        sessionInfoLabel.leftAnchor.constraint(equalTo: self.sessionInfoView.leftAnchor, constant: 10).isActive = true
        sessionInfoLabel.rightAnchor.constraint(equalTo: self.sessionInfoView.rightAnchor, constant: -10).isActive = true
        sessionInfoLabel.bottomAnchor.constraint(equalTo: self.sessionInfoView.bottomAnchor, constant: -10).isActive = true
        
//        self.sessionInfoView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -40).isActive = true
        self.sessionInfoView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 20).isActive = true
        self.sessionInfoView.topAnchor.constraint(equalTo: self.appMenuButton.topAnchor).isActive = true
        self.sessionInfoView.widthAnchor.constraint(lessThanOrEqualTo: self.view.widthAnchor, multiplier: 0.4).isActive = true
        self.sessionInfoView.heightAnchor.constraint(lessThanOrEqualTo: self.view.heightAnchor, multiplier: 0.3).isActive = true
//        self.sessionInfoView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.4).isActive = true
//        self.sessionInfoView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.08).isActive = true
        
        
    }
    
    func setupMenuAppButton() {
        self.view.addSubview(self.appMenuButton)
        
        self.appMenuButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        self.appMenuButton.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.03).isActive = true
        
        self.appMenuButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 70).isActive = true
        self.appMenuButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 60).isActive = true
        
        
        self.appMenuButton.layer.cornerRadius = self.appMenuButton.frame.height / 2
        self.appMenuButton.clipsToBounds = true
//        self.appMenuButton.cor
    }
    func openAppMenu(){
        
        self.displayAppMenu()
        self.openMenu()
    }
    func displayAppMenu(){
        self.hideContextMenu()
        let menu = self.appMenu.getView()
        
        self.view.addSubview(menu)
        
        menu.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.34).isActive = true
        menu.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.13).isActive = true
        
        menu.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 80).isActive = true
        menu.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        
        self.view.bringSubviewToFront(menu)
        
        self.contextMenuView = menu
        self.isDisplayingUIContextMenu = true
    }
    
    func setupAddDisplayButton(){
        self.view.addSubview(self.addPlanetButton)
        
        self.addPlanetButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        self.addPlanetButton.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.05).isActive = true
        self.addPlanetButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 30).isActive = true
        self.addPlanetButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -40).isActive = true
        
        self.addPlanetButton.layer.cornerRadius = self.addPlanetButton.frame.height / 2
        self.addPlanetButton.clipsToBounds = true
        
        self.addPlanetButton.setNeedsLayout()
        self.addPlanetButton.setNeedsDisplay()
    }
    func openAddPlanetMenu(){
        
        self.displayAddPlanetMenu()
        self.openMenu()
    }
    func displayAddPlanetMenu(){
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
    func closeAddPlanetMenu() {
        self.hideMenus()
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
        let scale: CGFloat = 0.5
        
        let geometry = SCNPyramid(width: scale * 0.6, height: scale * 0.8, length: scale * 0.6)
        let node = SCNNode(geometry: geometry)
        
        geometry.firstMaterial?.diffuse.contents = UIColor.white
        
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
        guard let geometry = highlighter.geometry as? SCNPyramid else { return }
        
        let rotate = SCNAction.rotateBy(x: 0, y: CGFloat.pi, z: 0, duration: 1)
        let foreverAction = SCNAction.repeatForever(rotate)
        
        highlighterNode?.runAction(foreverAction)
        
        highlighterNode?.eulerAngles.x = Float.pi
        highlighterNode?.position = SCNVector3(x: 0, y: (radius + geometry.height + 0.05), z: 0)
        
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
            }
            
            
            self.sceneView.scene.rootNode.addChildNode(newStar)
            newStar.setWorldTransform(transform)
//            newStar.eulerAngles = SCNVector3Zero
            
            self.updatedOrbit(newStar)
            self.clearHighlight()
            self.applyPlanetName(name: self.createPlanetContextMenu.currentName, to: newStar)
            
            self.galaxyFacade.sync(node: newStar, name: self.createPlanetContextMenu.currentName, description: self.createPlanetContextMenu.currentDescription, color: self.createPlanetContextMenu.currentColor, shape: self.createPlanetContextMenu.currentShape)
            
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
                guard let node = self.galaxyFacade.galaxy.getStar(by: test.node.position)?.getNode() else { return }
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
        guard let inclinator = node.childNode(withName: "inclinator", recursively: true) else { return }
        guard let orbiter = node.childNode(withName: "rotator", recursively: true)?.childNodes.first else { return }
        let worldPos = orbiter.worldPosition
        
        orbiter.removeFromParentNode()
        self.sceneView.scene.rootNode.addChildNode(orbiter)
        orbiter.worldPosition = worldPos
        
        inclinator.removeFromParentNode()
        
    }
    
    
    func enableAllOrbits(){
        var orbitingNodes = [SCNNode]()
        
        for star in self.galaxyFacade.galaxy.stars{
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
    
    // Chamada quando da o tempo minimo para abrir o menu de contexto
    func onTriggered(_ gesture: ContextMenuGestureRecognizer) {
//
//
//        if ((self.contextMenuView?.frame.contains(position)) ?? false){
//            return
//        }

        if self.isDisplayingUIContextMenu || self.contextMenuView != nil { return }
        
//
        self.tapGesture.state = .cancelled
//        gesture.state = .cancelled
//
//        self.hideContextMenu()
        let position = gesture.location(in: self.view)
        let hitResults = self.sceneView.hitTest(position, options: [:])
        
        if let result = hitResults.first, let pov = self.sceneView.pointOfView{
            self.currentSelectedStar = result.node

            let vib = UIImpactFeedbackGenerator()
            vib.impactOccurred()
            
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
    
    
    func resetPosition(of star: Star){
        guard let selectedStar = self.currentSelectedStar else { return }
        guard let transform = self.selectedNodePreviousWorldPosition else { return }
        
        let newStar = selectedStar.clone()
        
        self.currentSelectedStar!.removeFromParentNode()
        
        self.sceneView.scene.rootNode.addChildNode(newStar)
        
        newStar.worldPosition = transform
        newStar.name = star.id
        
        self.clearHighlight()
        
        self.galaxyFacade.sync(node: newStar, name: self.createPlanetContextMenu.currentName, description: self.createPlanetContextMenu.currentDescription, color: self.createPlanetContextMenu.currentColor, shape: self.createPlanetContextMenu.currentShape)
        
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
//        self.
        if let s  = star {
            self.resetPosition(of: s)
        } else {
            self.moveNodeFromCamera()
        }
        
//        self.galaxyFacade.sync(node: <#T##SCNNode#>, name: <#T##String?#>, description: <#T##String?#>)
        self.closeAddPlanetMenu()
    }
    
    func onDelete(star: Star) {
//        self.galaxyFacade.deletePlanet(with: self.tappedNode!)
        self.galaxyFacade.delete(star: star)
        self.currentSelectedStar?.removeFromParentNode()
        self.currentSelectedStar = nil
        self.closeAddPlanetMenu()
    }
    
    
    

    
    // MARK: - Callbacks
    
    @objc func onContextMenu(_ sender: ContextMenuGestureRecognizer){
        if sender.state == .ended && (!self.isDisplayingUIContextMenu || self.contextMenuView == nil) {
                self.moveNodeFromCamera()
        }
    }
    
    
    @objc func onDisplayAddPlanetMenu(){
        self.openAddPlanetMenu()
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
                
                let star = self.galaxyFacade.galaxy.getStar(by: hit.node)
                self.createPlanetContextMenu.currentStar = star
                
                self.selectedNodePreviousWorldPosition = hit.node.worldPosition
                
                self.openAddPlanetMenu()
                
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
    
    // MARK: - ARSessionObserver
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay.
        sessionInfoLabel.text = "Session was interrupted"
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required.
        sessionInfoLabel.text = "Session interruption ended"
        resetTracking()
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

    
    // MARK: - ARState methods
    
    private func updateSessionInfoLabel(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
        // Update the UI to provide feedback on the state of the AR experience.
        let message: String
        
        switch trackingState {
        case .normal where frame.anchors.isEmpty:
            // No planes detected; provide instructions for this app's AR interactions.
            message = "Move the device around to detect horizontal and vertical surfaces."
            
        case .notAvailable:
            message = "Tracking unavailable."
            
        case .limited(.excessiveMotion):
            message = "Tracking limited - Move the device more slowly."
            
        case .limited(.insufficientFeatures):
            message = "Tracking limited - Point the device at an area with visible surface detail, or improve lighting conditions."
            
        case .limited(.initializing):
            message = "Initializing AR session."
            
        default:
            // No feedback needed when tracking is normal and planes are visible.
            // (Nor when in unreachable limited-tracking states.)
            message = ""
            
        }
        
        sessionInfoLabel.text = message
        sessionInfoView.isHidden = message.isEmpty ||  self.isDisplayingUIContextMenu
    }
    
    
    func onChangeMode() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let vc = storyboard.instantiateViewController(withIdentifier: "2d")
        
        self.present(vc, animated: true, completion: {
            for i in self.sceneView.scene.rootNode.childNodes{
                if i == self.currentSelectedStar { continue }
                if i == self.tappedNode { continue }
                if i == self.sceneView.pointOfView { continue }
                
                i.removeFromParentNode()
            }
        })
        
        self.closeAddPlanetMenu()
    }
}
