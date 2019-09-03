//
//  Orbit.swift
//  Celeste
//
//  Created by Bruno Pastre on 21/08/19.
//  Copyright © 2019 Bruno Pastre. All rights reserved.
//

import Foundation
import SceneKit

class Orbit: SCNNodeTransformer, Encodable, Decodable{
    func getPosition() -> SCNVector3 {
        return SCNVector3Zero
    }
    
    func getNode() -> SCNNode {
        let rotationNode = SCNNode()
        let child = self.orbiter.getNode()
        
        
        return rotationNode
    }
    
    enum CodingKeys: String, CodingKey{
        case radius = "radius"
        case orbiter = "orbiter"
    }
    
    
    required init(decoder aDecoder: Decoder) throws {
        let container = try aDecoder.container(keyedBy: CodingKeys.self)
        
        self.radius = try CGFloat(container.decode(Float.self, forKey: .radius))
        self.orbiter = try container.decode(Star.self, forKey: .orbiter)
    }
    
    func encode(to encoder: Encoder) throws{
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.radius, forKey: .radius)
        try container.encode(self.orbiter, forKey: .orbiter)
        
    }
    
    internal init(radius: CGFloat?, orbiter: Star?) {
        self.radius = radius
        self.orbiter = orbiter
    }
    
    var radius: CGFloat!
    var orbiter: Star!
}
