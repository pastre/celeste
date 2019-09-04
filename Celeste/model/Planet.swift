//
//  Planet.swift
//  Celeste
//
//  Created by Bruno Pastre on 21/08/19.
//  Copyright © 2019 Bruno Pastre. All rights reserved.
//

import Foundation
import SceneKit

class Planet: NesteableStar{
    init(radius: CGFloat?, center: Point?, color: UIColor?, child: [Star]?, orbits: [Orbit]){
        super.init(radius: radius, center: center, color: color, child: child)
        self.orbits = orbits
    }
    
    convenience init(from star: Star) {
        self.init(radius: star.radius, center: star.center, color: star.color, child: nil)
        self.id = star.id
        self.shapeName = star.shapeName
        self.scale = star.scale
    }
    
    override init(radius: CGFloat?, center: Point?, color: UIColor?, child: [Star]?){
        super.init(radius: radius, center: center, color: color, child: child)
        self.orbits = nil
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: Star.CodingKeys.self)
        self.radius = try CGFloat(container.decode(Float.self, forKey: .radius))
        self.orbits = try container.decode([Orbit].self, forKey: .orbits)

    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = try encoder.container(keyedBy: Star.CodingKeys.self)
        try container.encode(self.orbits, forKey: .orbits)
        
    }
    
    var orbits: [Orbit]?
    
    func getOrbiters() -> [Star]?  {
        return self.orbits?.map({ (orbit) -> Star in
            return orbit.orbiter
        })
    }
    
}
