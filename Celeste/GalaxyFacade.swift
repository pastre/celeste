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
    
    func createPlanet(node: SCNNode, color: UIColor, shapeName: ShapeName, scaled scale: Float, name: String = "No name", description: String = "No description") -> Star{
        
        let radius = node.boundingSphere.radius
        let position = node.worldPosition
       
        let newPlanet = Planet(radius: CGFloat(radius), center: Point(position: position), color: color, child: nil)
        
        newPlanet.shapeName = shapeName
        newPlanet.scale = scale
        
        newPlanet.name = name
        newPlanet.planetDescription = description
        
        node.name = newPlanet.id
        
        self.galaxy.stars.append(newPlanet)
        
        print("[GALAXYFACADE] Created planet named", node.name)
        
        self.persistGalaxy()
        return newPlanet
        
//        self.galaxy
    }
    
//    func deletePlanet(with node: SCNNode){
//        assert(node.name != "")
//        self.galaxy.stars.removeAll { (s) -> Bool in
//            print("Nodename", node.name, "Starid", s.id)
//            return s.id == node.name
//        }
//
//        self.persistGalaxy()
//    }

    func delete(star: Star){
        self.galaxy.stars.removeAll { (s) -> Bool in
            
            return s.id == star.id
        }
        
        self.persistGalaxy()
    }
    
    func reloadAllOrbits(){
        
    }
    
    func createOrbit(around aroundNode: SCNNode, child childNode: SCNNode, with radius: CGFloat){
        print()
        
        
        guard  let childStar = self.galaxy.getStar(by: childNode) else {
            print("BROW BOLA FORA PRA CRIAR A ORBITA")
            return
        }
        
        let orbit = Orbit(radius: radius, orbiter: childStar)
        
        for (i, star) in self.galaxy.stars.enumerated(){
            
            if star.id == aroundNode.name {
                var asPlanet: Planet!
                if let planet = star as? Planet{
                    asPlanet = planet
                } else {
                    asPlanet = Planet(from: star)
                }
                
                if asPlanet.orbits == nil{
                    asPlanet.orbits = [Orbit]()
                }
                
                asPlanet.orbits?.append(orbit)
                
                self.galaxy.stars[i] = asPlanet
                break
            }
        }
        print("[GALAXYFACADE] Created orbit for", childNode.name, " around ", aroundNode.name)
        self.persistGalaxy()
        print()
    }
    
    func printPlanets(){
        for s in self.galaxy.stars{
            print(s.id)
        }
    }
    
    func sync(node: SCNNode, name newName: String?, description newDescription : String?){
        guard let nodeStar = self.galaxy.getStar(by: node) else {
            fatalError("[GALAXYFACADE] ---- FAILED TO SYNC MODEL! PLEASE FIX ME!")
            return
        }
        
        for star in self.galaxy.stars{
            if star == nodeStar{
                
                star.center = Point(position: node.position)
                star.scale = node.scale.x
                
                if let name = newName{
                    star.name = name
                }
                
                if let description = newDescription {
                    star.planetDescription = description
                }
                self.persistGalaxy()
                break
            }
        }
        
    }
    
    func updateOrbit(of node: SCNNode){
        for star in self.galaxy.stars{
            guard let planet = star as? Planet else { continue }
//            guard let orbits = planet.orbits else { continue}
            
            planet.orbits?.removeAll(where: { (orbit) -> Bool in
                orbit.orbiter.id == node.name
            })
            
            print("[GALAXYFACADE] Updated orbit for planet", node.name)
        }
        
//        self.sy
        self.persistGalaxy()
    }
    
    func persistGalaxy(){
        self.storage.updateGalaxy(to: self.galaxy)
    }
    
    func forceSync(from scene: SCNNode){
        
    }
}
