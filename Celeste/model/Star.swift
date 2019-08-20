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

class Orbit{
    internal init(radius: CGFloat?, star: Moon?) {
        self.radius = radius
        self.star = star
    }
    
    var radius: CGFloat!
    var star: Moon!
}

class Star: SCNNodeTransformer{
    
    func contains(point: CGPoint) -> Bool {
        return self.getNode().frame.contains(point)
    }
    
    internal init(radius: CGFloat?, center: Point?, color: UIColor?) {
        self.radius = radius
        self.center = center
        self.color = color
    }
    
    func getPosition() -> SCNVector3 {
        // TODO: Pensar em um fator de escala para ficar bem  posicionado
        return SCNVector3(self.center.x, self.center.y, self.center.z!)
    }
    
    func getNode() -> SCNNode{
        let sphere = SCNSphere(radius: self.radius)
        sphere.materials.first?.diffuse.contents = self.color
        
        let node  =  SCNNode(geometry: sphere)
        
        node.position = self.getPosition()
        
        return node
    }
    
    
    
    // Classe abstrata pra nois
    var radius: CGFloat!
    var center: Point!
    var color: UIColor!
    
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
class Planet: NesteableStar{
    init(radius: CGFloat?, center: Point?, color: UIColor?, child: [Star]?, orbits: [Orbit]){
        super.init(radius: radius, center: center, color: color, child: child)
        self.orbits = [Orbit]()
    }
    var orbits: [Orbit]?
}

class Moon: NesteableStar{
    
    var asteroids: [Asteroid]!
    
}

class Asteroid: Star{
    
}
