//
//  Galaxy.swift
//  Celeste
//
//  Created by Bruno Pastre on 16/08/19.
//  Copyright © 2019 Bruno Pastre. All rights reserved.
//

import Foundation
import SceneKit

class Galaxy{
    internal init(stars: [Star]?) {
        self.stars = stars
    }
    
    var stars: [Star]!
    
    func getScene() -> SCNNode{
        let ret = SCNNode()
        for i in self.stars{
            ret.addChildNode(i.getNode())
        }
        
        return ret
    }
    
    func getStar(by node: SCNNode) -> Star?{
        for star in self.stars{
            if star.getNode() == node{
                return star
            }
        }
        
        return nil
    }
    
}
