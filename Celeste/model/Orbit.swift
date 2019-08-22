//
//  Orbit.swift
//  Celeste
//
//  Created by Bruno Pastre on 21/08/19.
//  Copyright © 2019 Bruno Pastre. All rights reserved.
//

import Foundation
import SceneKit

class Orbit: SCNNodeTransformer{
    func getPosition() -> SCNVector3 {
        return SCNVector3Zero
    }
    
    func getNode() -> SCNNode {
        let rotationNode = SCNNode()
        let child = self.orbiter.getNode()
        
        
        return rotationNode
    }
    
    internal init(radius: CGFloat?, orbiter: Star?) {
        self.radius = radius
        self.orbiter = orbiter
    }
    
    var radius: CGFloat!
    var orbiter: Star!
}
