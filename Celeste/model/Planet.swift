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
    
    override init(radius: CGFloat?, center: Point?, color: UIColor?, child: [Star]?){
        super.init(radius: radius, center: center, color: color, child: child)
        self.orbits = nil
    }
    
    var orbits: [Orbit]?
    
    func getOrbiters() -> [Star]?  {
        return self.orbits?.map({ (orbit) -> Star in
            return orbit.orbiter
        })
    }
    
}
