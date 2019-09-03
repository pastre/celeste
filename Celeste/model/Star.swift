//
//  Astro.swift
//  Celeste
//
//  Created by Bruno Pastre on 15/08/19.
//  Copyright © 2019 Bruno Pastre. All rights reserved.
//

import Foundation
import SceneKit

protocol SCNNodeTransformer{
    func getPosition() -> SCNVector3
    func getNode() -> SCNNode
//    func contains(point: CGPoint) -> Bool
    
}

protocol SceneNodeInteractable{
    func didPress(in location: CGPoint)
    func didRelease(in location: CGPoint)
}

class Color: Encodable, Decodable{
    var r: CGFloat
    var g: CGFloat
    var b: CGFloat
    
    enum CodingKeys: String, CodingKey{
        case r = "r"
        case g = "g"
        case b = "b"

    }
    
    required init(decoder aDecoder: Decoder) throws {
        let container = try aDecoder.container(keyedBy: CodingKeys.self)
        self.r = try CGFloat(container.decode(Float.self, forKey: .r))
        self.g = try CGFloat(container.decode(Float.self, forKey: .g))
        self.b = try CGFloat(container.decode(Float.self, forKey: .b))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(r, forKey: .r)
        try container.encode(g, forKey: .g)
        try container.encode(b, forKey: .b)
    }
    
    init(uiColor: UIColor){
        var red: CGFloat = 1
        var green: CGFloat = 1
        var blue: CGFloat = 1
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: nil)
        self.r = red
        self.g = green
        self.b = blue
    }
    
    func getUIColor() -> UIColor{
        
        return UIColor(red: r, green: g, blue: b, alpha: 1)
    }
}

class Star: SCNNodeTransformer, Encodable, Decodable{
    
    
    func contains(point: CGPoint) -> Bool {
        return self.getNode().frame.contains(point)
    }
    
    func encode(to encoder: Encoder) throws{
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.radius, forKey: .radius)
        try container.encode(self.center, forKey: .center)
        try container.encode(Color(uiColor: self.color), forKey: .color)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.name ?? "No name", forKey: .name)
        try container.encode(self.planetDescription ?? "No description", forKey: .description)
        try container.encode(self.shapeName.rawValue, forKey: .shapeName)
        try container.encode(self.scale ?? 1, forKey: .scale)
        
    }
    
    enum CodingKeys: String, CodingKey{
        case radius = "radius"
        case center = "center"
        case color = "color"
        case id = "id"
        case name = "name"
        case description = "description"
        case shapeName = "shapeName"
        case scale = "scale"
        
        case child = "child"
        
        case orbits = "orbits"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.radius = try CGFloat(container.decode(Float.self, forKey: .radius))
        self.center = try container.decode(Point.self, forKey: .center)
        self.color = try container.decode(Color.self, forKey: .color).getUIColor()
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.planetDescription = try container.decode(String.self, forKey: .description)
        self.shapeName = ShapeName.getShapeName(by: try container.decode(String.self, forKey: .shapeName))
        self.scale = try container.decode(Float.self, forKey: .scale)
    }
    
    internal init(radius: CGFloat?, center: Point?, color: UIColor?) {
        self.radius = radius
        self.center = center
        self.color = color
        self.id = String.random()
    }
    
    
    
    func getPosition() -> SCNVector3 {
        // TODO: Pensar em um fator de escala para ficar bem  posicionado
        return SCNVector3(self.center.x, self.center.y, self.center.z!)
    }
    
    func getRawNode() -> SCNNode{
        let node =  PlanetTextureProvider.instance.getPlanet(named: self.shapeName.rawValue, color: self.color)!
        let scale = self.scale ?? 1
        
        node.scale = SCNVector3(x: scale, y: scale, z: scale)
        node.name = self.id
        
        return node
        
    }
    
    func getNode() -> SCNNode{
        let node = self.getRawNode()
        node.position = self.getPosition()
        return node
    }
    
    static func == (_ a: Star, _ b: Star) -> Bool{
        return a.center == b.center
    }
    
    // Classe abstrata pra nois
    var radius: CGFloat!
    var center: Point!
    var color: UIColor!
    var id: String!
    var name: String?
    var planetDescription: String?
    var scale: Float?
    var shapeName: ShapeName!
}

class NesteableStar: Star {
    
    var child: [Star]?
    
    internal init(radius: CGFloat?, center: Point?, color: UIColor?, child: [Star]?) {
        super.init(radius: radius, center: center, color: color)
        self.child = child
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: Star.CodingKeys.self)
        
        self.child = try container.decode([Star].self, forKey: .child)
    }
    
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = try encoder.container(keyedBy: Star.CodingKeys.self)
        
        try container.encode(self.child, forKey: .child)
    }
    
    override func getNode() -> SCNNode {
        let ret = super.getNode()
        
        for i in self.child ?? []{
            ret.addChildNode(i.getNode())
        }
        
        return ret
    }
    
    func getChild() -> [Star] {
        var ret: [Star] = [Star]()
        
        ret.append(self)
        
        for i in self.child ?? []{
            if let c = i as? NesteableStar{
                ret.append(contentsOf: c.getChild())
            }
        }
        
        return ret
    }
    
}

