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
            print("Loading UIImage for", i.rawValue)
            kTEXTURE_TO_IMAGE[i.rawValue] = UIImage(named: i.rawValue)
        }
    
    }
    
    func getPlanet(named modelName: String, color uiColor: UIColor?) -> SCNNode? {
        
        let scene = SCNScene(named: "art.scnassets/models.scn")!
        print("Model name is", modelName )
        let modelShape = kTEXTURE_TO_SHAPE[ShapeName.getShapeName(by: modelName)!]
        
        //        guard let modelTexture = UIImage(named: "\(modelName)") else { return nil }
        let modelTexture = kTEXTURE_TO_IMAGE[ShapeName.getShapeName(by: modelName)!.rawValue]!.copy() as! UIImage
        var hue: CGFloat = 1
        
        uiColor?.getHue(&hue, saturation: nil, brightness: nil, alpha: nil)
        let maskedTexture = modelTexture.tint(tintColor: uiColor ?? UIColor.purple)
        
        print("\t-> Model Texture is", modelTexture)
//        let maskedTexture = uiColor == nil ? modelTexture : modelTexture.maskWithColor(color: uiColor!)
        guard let modelNode = scene.rootNode.childNode(withName: modelShape!, recursively: true)?.clone() else { return nil }
        
        modelNode.geometry?.firstMaterial?.diffuse.contents = maskedTexture
        modelNode.position = SCNVector3Zero
        modelNode.name = "newPlanet"
        return modelNode
    }
}
