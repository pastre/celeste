//
//  PlanetProvider.swift
//  Celeste
//
//  Created by Bruno Pastre on 26/08/19.
//  Copyright © 2019 Bruno Pastre. All rights reserved.
//

import Foundation
import SceneKit

enum Color: String, CaseIterable{
    case blue = "blue"
    case orange = "orange"
    case pink = "pink"
    case purple = "purple"
    case red = "red"
    case yellow = "yellow"
    
}

class PlanetProvider{
    
    static let instance = PlanetProvider()
    
    private init(){
    
    }
    
    func getPlanet(named modelName: String, color: Color) -> SCNNode? {
        
        let scene = SCNScene(named: "art.scnassets/models.scn")!
        
        guard let modelTexture = UIImage(named: "\(modelName)_\(color.rawValue)") else { return nil }
        guard let modelNode = scene.rootNode.childNode(withName: modelName, recursively: true)?.clone() else { return nil }
 
        modelNode.geometry?.firstMaterial?.diffuse.contents = modelTexture
        modelNode.position = SCNVector3Zero
        modelNode.name = "newPlanet"
        return modelNode
    }
    
    func getPlanet(model: SCNNode, texture: UIImage, color: Color, icon: UIImage, scale: CGFloat) -> SCNNode {
        let node = SCNNode()
        
        model.position = SCNVector3Zero
        node.addChildNode(model)
        model.geometry?.materials.first?.emission.contents = color
        
//        node.geometry?.materials.first?.diffuse.contents = texture.tinted(color: color)
//        node.scale = SCNVector3(scale, scale, scale)
        
        
        return node
    }
}
