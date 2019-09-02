//
//  PlanetProvider.swift
//  Celeste
//
//  Created by Bruno Pastre on 26/08/19.
//  Copyright © 2019 Bruno Pastre. All rights reserved.
//

import Foundation
import SceneKit


//let colors: [UIColor] = [#colorLiteral(red: 0.1725490196, green: 0.6039215686, blue: 1, alpha: 1), #colorLiteral(red: 0.4392156863, green: 0.7529411765, blue: 0.3098039216, alpha: 1), #colorLiteral(red: 0.9921568627, green: 0.7960784314, blue: 0.3568627451, alpha: 1), #colorLiteral(red: 0.9882352941, green: 0.5490196078, blue: 0.1960784314, alpha: 1), #colorLiteral(red: 0.9333333333, green: 0.2862745098, blue: 0.3411764706, alpha: 1), #colorLiteral(red: 0.7882352941, green: 0.03529411765, blue: 0.4352941176, alpha: 1), #colorLiteral(red: 0.631372549, green: 0.03921568627, blue: 0.7294117647, alpha: 1) ]
enum ShapeColor: String, CaseIterable{
    case blue = "blue"
    case green = "green"
    case yellow = "yellow"
    case orange = "orange"
    case red = "red"
    case pink = "pink"
    case purple = "purple"
    
    
}

enum ShapeName: String, CaseIterable{
    case neptune = "neptune"
    case uranus = "uranus"
    case ceres = "ceres"
//    case eris = "eris"
    case haumea = "haumea"
//    case makemake = "makemake"
    case jupiter = "jupiter"
    case mars = "mars"
//    case mercury = "mercury"
    case saturn = "saturn"
    case sun = "sun"
    case venus = "venus"
    case brain = "brain"
    
    static func getShapeName(by string: String) -> ShapeName?{
        for i in ShapeName.allCases{
            if i.rawValue == string{
                return i
            }
        }
        return nil
    }
}

let kTEXTURE_TO_SHAPE = [
    ShapeName.neptune : "sphere",
    ShapeName.uranus : "sphere",
    ShapeName.ceres : "sphere",
//    ShapeName.eris : "sphere",
    ShapeName.haumea : "sphere",
//    ShapeName.makemake : "sphere",
    ShapeName.jupiter : "sphere",
    ShapeName.mars : "sphere",
//    ShapeName.mercury : "sphere",
    ShapeName.saturn : "sphere",
    ShapeName.sun : "sphere",
    ShapeName.venus : "sphere",
    ShapeName.brain: "brain"
//    ShapeName.venus : "sphere",
]

var kTEXTURE_TO_IMAGE: [String: UIImage] = [String: UIImage]()

class PlanetProvider{
    
    static let instance = PlanetProvider()
    
    private init(){
        for i in ShapeName.allCases{
            kTEXTURE_TO_IMAGE[i.rawValue] = UIImage(named: i.rawValue)
        }
    
    }
    
//    func getPlanet(with shape: ShapeName, color: ShapeColor) -> SCNNode? {
//
//        let scene = SCNScene(named: "art.scnassets/models.scn")!
//        let modelShape = kTEXTURE_TO_SHAPE[shape]!
//        var diffuse: Any!
//
//        guard let modelNode = scene.rootNode.childNode(withName: modelShape, recursively: true)?.clone() else { return nil }
//
//        if let image = UIImage(named: "\(shape.rawValue)_\(modelShape)_\(color.rawValue)"){
//            diffuse = image
//        } else {
//
//            let colors: [UIColor] = [#colorLiteral(red: 0.1725490196, green: 0.6039215686, blue: 1, alpha: 1), #colorLiteral(red: 0.4392156863, green: 0.7529411765, blue: 0.3098039216, alpha: 1), #colorLiteral(red: 0.9921568627, green: 0.7960784314, blue: 0.3568627451, alpha: 1), #colorLiteral(red: 0.9882352941, green: 0.5490196078, blue: 0.1960784314, alpha: 1), #colorLiteral(red: 0.9333333333, green: 0.2862745098, blue: 0.3411764706, alpha: 1), #colorLiteral(red: 0.7882352941, green: 0.03529411765, blue: 0.4352941176, alpha: 1), #colorLiteral(red: 0.631372549, green: 0.03921568627, blue: 0.7294117647, alpha: 1) ]
//            diffuse = colors[ShapeColor.allCases.firstIndex(of: color)!]
//        }
//
//        let material = SCNMaterial()
//        material.diffuse.contents = diffuse
//
//        modelNode.geometry?.firstMaterial = material
//
//        for i in modelNode.childNodes{
//            i.geometry?.firstMaterial = material
//        }
//        modelNode.position = SCNVector3Zero
//        modelNode.name = "newPlanet"
//
//        return modelNode
//
//
//    }
    
    func getPlanet(named modelName: String, color: ShapeColor) -> SCNNode? {
        
        let scene = SCNScene(named: "art.scnassets/models.scn")!
        
        guard let modelTexture = UIImage(named: "\(modelName)_\(color.rawValue)") else { return nil }
        guard let modelNode = scene.rootNode.childNode(withName: modelName, recursively: true)?.clone() else { return nil }
 
        modelNode.geometry?.firstMaterial?.diffuse.contents = modelTexture
        modelNode.position = SCNVector3Zero
        modelNode.name = "newPlanet"
        return modelNode
    }
    
    func getPlanet(named modelName: String, color: CGFloat) -> SCNNode? {
        
        let scene = SCNScene(named: "art.scnassets/models.scn")!
        print("Model name is", modelName )
        let modelShape = kTEXTURE_TO_SHAPE[ShapeName.getShapeName(by: modelName)!]
        let uiColor = UIColor(hue: color, saturation: 1, brightness: 1, alpha: 1)
        
//        guard let modelTexture = UIImage(named: "\(modelName)") else { return nil }
        let modelTexture = kTEXTURE_TO_IMAGE[ShapeName.getShapeName(by: modelName)!.rawValue]!.copy() as! UIImage
//        let maskedTexture = rotateHue(with: modelTexture, rotatedByHue: color)
        let maskedTexture = modelTexture.maskWithColor(color: uiColor)
        guard let modelNode = scene.rootNode.childNode(withName: modelShape!, recursively: true)?.clone() else { return nil }
        
        modelNode.geometry?.firstMaterial?.diffuse.contents = maskedTexture
        modelNode.position = SCNVector3Zero
        modelNode.name = "newPlanet"
        return modelNode
    }
    
    
    func getPlanet(model: SCNNode, texture: UIImage, color: ShapeColor, icon: UIImage, scale: CGFloat) -> SCNNode {
        let node = SCNNode()
        
        model.position = SCNVector3Zero
        node.addChildNode(model)
        model.geometry?.materials.first?.emission.contents = color
        
//        node.geometry?.materials.first?.diffuse.contents = texture.tinted(color: color)
//        node.scale = SCNVector3(scale, scale, scale)
        
        
        return node
    }
}
