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
    
    let galaxy: Galaxy = Galaxy(stars: [
        Planet(radius: 0.5 * 1, center: Point.zero, color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), child: [
            Moon(radius: 0.5 * 0.5, center: Point(x: 1, y: 1, z: 1), color: #colorLiteral(red: 0.5771069097, green: 0.3387015595, blue: 0.5715773573, alpha: 1), child: nil),
            Moon(radius: 0.5 * 0.5, center: Point(x: 1, y: 1, z: 0), color: #colorLiteral(red: 0.05881351963, green: 0.180391161, blue: 0.1470588137, alpha: 1), child: nil),
            Moon(radius: 0.5 * 0.5, center: Point(x: 1, y: -1, z: 1), color: #colorLiteral(red: 0.3098039319, green: 0.1039115714, blue: 0.03911568766, alpha: 1), child: nil),
            Moon(radius: 0.5 * 0.5, center: Point(x: 1, y: -1, z: 0), color: #colorLiteral(red: 0.1194117719, green: 0.1156861766, blue: 0.06666667014, alpha: 1), child: nil),
            Moon(radius: 0.5 * 0.5, center: Point(x: 0, y: 1, z: 0), color: #colorLiteral(red: 0.06174510175, green: 0, blue: 0.1911568661, alpha: 1), child: nil),
            Moon(radius: 0.5 * 0.5, center: Point(x: 0, y: 1, z: 1), color: #colorLiteral(red: 0.1911568661, green: 0.007843137719, blue: 0.09019608051, alpha: 1), child: nil),
            Moon(radius: 0.5 * 0.5, center: Point(x: 0, y: -1, z: 0), color: #colorLiteral(red: 0.1764705916, green: 0.4980391158, blue: 0.7568617596, alpha: 1), child: nil),
            Moon(radius: 0.5 * 0.5, center: Point(x: 0, y: -1, z: 1), color: #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1), child: nil),
            Moon(radius: 0.5 * 0.5, center: Point(x: -1, y: -1, z: 1), color: #colorLiteral(red: 0.3098039319, green: 0.1039115714, blue: 0.03911568766, alpha: 1), child: nil),
            Moon(radius: 0.5 * 0.5, center: Point(x: -1, y: -1, z: 0), color: #colorLiteral(red: 0.1194117719, green: 0.1156861766, blue: 0.06666667014, alpha: 1), child: nil),
            Moon(radius: 0.5 * 0.5, center: Point(x: -1, y: 1, z: 0), color: #colorLiteral(red: 0.1764705916, green: 0.4980391158, blue: 0.7568617596, alpha: 1), child: nil),
            Moon(radius: 0.5 * 0.5, center: Point(x: -1, y: 1, z: 1), color: #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1), child: nil),
            ]
        ),
        ]
    )
    
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
    }
    
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = self.galaxy.getScene()
        
        self.sceneView.scene.rootNode.addChildNode(node)
        print("Coloquei", node)
        return node
    }
    
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        let cameraTransform = SCNMatrix4(frame.camera.transform)
        let cameraPos = SCNVector3(cameraTransform.m41, cameraTransform.m42, cameraTransform.m43)
        
        if let selectedStar = self.currentSelectedStar{
            selectedStar.position = SCNVector3((cameraPos.x) + (self.startDragPosition.x), selectedStar.position.y, (cameraPos.z) + self.startDragPosition.z)
        }
        
        if let contextMenu = self.contextMenuNode, let orientation = self.getCameraPosition(){
            contextMenu.look(at: orientation)
        }
    }
    
    var startDragPosition: SCNVector3!
    
    func onStartDrag(at position: CGPoint){
        let hitResults = self.sceneView.hitTest(position, options: [:])
        if let result = hitResults.first{
            print("DEU  BOMMM SO ALEGRIA")
            self.startDragPosition = result.node.position
            self.currentSelectedStar = result.node
            
        }  else {
            print("AIII NAO PEGOU NADA")
        }
    }
    
    func onEndDrag(endPosition: CGPoint){
        self.currentSelectedStar = nil
    }
    
    // Chamado pelo menu de contexto
    @objc func onContextMenu(_ sender: ContextMenuGestureRecognizer){
        if !sender.hasTriggered { return }
        
    }
    
    // MARK: - UIGestureRecognizer delegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        print(gestureRecognizer.state.rawValue, otherGestureRecognizer.state.rawValue)
        
        return true
    }
    
    // Chamada quando da o tempo minimo para abrir o menu de contexto
    func onTriggered(_ gesture: ContextMenuGestureRecognizer) {
        print("Saca so deu boa o gesto!!!!!!!!!!!")
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
        
        if hitTest.count == 0{
            // Nao achou nada, mostrar menu de contexto do espaco
            self.contextMenu.openContextMenu(mode: .galaxy)
            
            let ctxMenuNode = self.contextMenu.getNode()
            guard let position = self.getLookingCameraPosition() else { return }
            ctxMenuNode.position = position
                
            self.sceneView.scene.rootNode.addChildNode(ctxMenuNode)
            self.contextMenuNode = ctxMenuNode
            
        } else if let hit = hitTest.first{
            // Encontrou em alguma coisa, mostrar o menu a partir disso
            self.contextMenu.openContextMenu(mode: .planet)
        }
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
        return pos + orientation.normalized() * 0.5
//        return pos + SCNVector3(0,-0.07,0) + orientation.normalized() * 0.5
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
    
    @objc func onTap(_ sender: UITapGestureRecognizer){
        self.hideContextMenu()
    }
}
