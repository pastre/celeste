//
//  Galaxy.swift
//  Celeste
//
//  Created by Bruno Pastre on 16/08/19.
//  Copyright © 2019 Bruno Pastre. All rights reserved.
//

import Foundation
import SceneKit

class Galaxy: Encodable, Decodable{
    
    enum CodingKeys: String, CodingKey {
        case stars = "galaxyStars"
    }
    
    required init(from decoder: Decoder) throws {
        var container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.stars = try container.decode([Star].self, forKey: .stars)
    }
    
    
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
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.stars, forKey: .stars)
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
