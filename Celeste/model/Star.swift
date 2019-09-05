//
//  Astro.swift
//  Celeste
//
//  Created by Bruno Pastre on 15/08/19.
//  Copyright © 2019 Bruno Pastre. All rights reserved.
//

import Foundation
import SceneKit
import SpriteKit

protocol SKNodeTransformer {
    func get2DPosition() -> CGPoint
    func get2DNode() -> SKShapeNode
}

protocol SCNNodeTransformer{
    func getPosition() -> SCNVector3
    func getNode() -> SCNNode
//    func contains(point: CGPoint) -> Bool
    
}

protocol SceneNodeInteractable{
    func didPress(in location: CGPoint)
    func didRelease(in location: CGPoint)
}

class Star: SCNNodeTransformer, SKNodeTransformer{
    
    func contains(point: CGPoint) -> Bool {
        return self.getNode().frame.contains(point)
    }
    
    internal init(radius: CGFloat?, center: Point?, color: UIColor?) {
        self.radius = radius
        self.center = center
        self.color = color
        self.id = String.random()
    }
    
    func get2DPosition() -> CGPoint {
        return CGPoint(x: center.x, y: center.y)
    }
    
    func get2DNode() -> SKShapeNode {
        let shape = SKShapeNode(circleOfRadius: radius * multiplier)
        shape.position = get2DPosition()
        shape.strokeColor = color
        shape.fillColor = color
        shape.name = id
        
        let randomInt32 = UInt32.random(in: 0...4294967295)
        shape.physicsBody = SKPhysicsBody(circleOfRadius: radius * multiplier)
        shape.physicsBody?.fieldBitMask = randomInt32
        
        let force = SKFieldNode.radialGravityField()
        force.minimumRadius = 0
        force.strength = -0.01
        force.categoryBitMask = 4294967295 - randomInt32
        force.constraints = [.distance(SKRange(constantValue: 0), to: shape)]
        shape.addChild(force)
        
        return shape
    }
    
    func getPosition() -> SCNVector3 {
        // TODO: Pensar em um fator de escala para ficar bem  posicionado
        return SCNVector3(self.center.x, self.center.y, self.center.z!)
    }
    
    func getRawNode() -> SCNNode{
        
        let sphere = SCNSphere(radius: self.radius)
        sphere.materials.first?.diffuse.contents = self.color
        
        let node  =  SCNNode(geometry: sphere)
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
    var isChild: Bool!
    var multiplier: CGFloat = 50
    var radius: CGFloat!
    var center: Point!
    var color: UIColor!
    var id: String!
    
}

class NesteableStar: Star {
    
    var child: [Star]?
    
    internal init(radius: CGFloat?, center: Point?, color: UIColor?, child: [Star]?) {
        super.init(radius: radius, center: center, color: color)
        self.child = child
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

// TODO: Mover essas classes para outros arquivos

class Moon: NesteableStar{
    
    var asteroids: [Asteroid]!
    
}

class Asteroid: Star{
    
}

extension String {
    
    static func random(length: Int = 20) -> String {
        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString: String = ""
        
        for _ in 0..<length {
            let randomValue = arc4random_uniform(UInt32(base.count))
            randomString += "\(base[base.index(base.startIndex, offsetBy: Int(randomValue))])"
        }
        return randomString
    }
}
