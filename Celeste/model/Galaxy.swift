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
    
    func getStars() -> [Star]{
        
        var stars: [Star] = [Star]()
        
        for star in self.stars{
            if let nest = star as? NesteableStar{
                stars.append(contentsOf: nest.getChild())
            }
        }
        
        return stars

    }
    
    func getStar(by position: SCNVector3) -> Star?{
        
        let stars = self.getStars()
        for star in stars{
            print(star.getPosition(), position)
            if star.getPosition() == position {
                return star
            }
        }
        
        return nil
    }

    
    
    func getStar(by node: SCNNode) -> Star?{
        let stars = self.getStars()
        for star in stars{
            print(star.getNode(), node)
            if star.getNode() == node {
                return star
            }
        }
        
        return nil
    }
    
}
