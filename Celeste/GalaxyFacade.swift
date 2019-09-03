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
    
    func deletePlanet(with node: SCNNode){
        
        self.galaxy.stars.removeAll { (s) -> Bool in
            s.id == node.name
        }
        
        self.storage.updateGalaxy(to: self.galaxy)
        
    }
    
    func sync(node: SCNNode){
        guard let nodeStar = self.galaxy.getStar(by: node) else { fatalError("NAO ACHOU A ESTRELA! FALHA NA CONSISTENCIA")}
        
        for star in self.galaxy.stars{
            if star == nodeStar{
                star.center = Point(position: node.position)
                star.scale = node.scale.x
            }
        }
        
    }
}
