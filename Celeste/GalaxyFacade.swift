//
//  GalaxyFacade.swift
//  Celeste
//
//  Created by Bruno Pastre on 02/09/19.
//  Copyright © 2019 Bruno Pastre. All rights reserved.
//

import Foundation
import SceneKit

class GalaxyFacade{
    
    static let instance = GalaxyFacade()
    let storage = StorageFacade()
    
    var galaxy: Galaxy!
    
    private init(){
        self.galaxy = self.storage.getGalaxy() ?? Galaxy(stars: [Star]())
    }
    
    func getCurrentGalaxy() -> Galaxy{
        return self.galaxy
    }
    
    func createPlanet(node: SCNNode, color: UIColor, shapeName: ShapeName, scaled scale: Float){
        
        let radius = node.boundingSphere.radius
        let position = node.worldPosition
       
        let newPlanet = Planet(radius: CGFloat(radius), center: Point(position: position), color: color, child: nil)
        newPlanet.shapeName = shapeName
        newPlanet.scale = scale
        self.galaxy.stars.append(newPlanet)
        
        self.storage.updateGalaxy(to: self.galaxy)
        
//        self.galaxy
    }
}
