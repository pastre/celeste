//
//  StorageFacade.swift
//  Celeste
//
//  Created by Bruno Pastre on 02/09/19.
//  Copyright © 2019 Bruno Pastre. All rights reserved.
//

import Foundation


// Classe responsavel por buscar coisas no UserDefaults

class StorageFacade{

    enum StorageKeys: String{
        case kGALAXY = "kGALAXY"
    }

    let userDefaults = UserDefaults.standard
   
    func getGalaxy() -> Galaxy? {
        guard let galaxyData = self.userDefaults.object(forKey: StorageKeys.kGALAXY.rawValue) as? Data  else { return nil }
        
        let unpackedGalaxy = try? JSONDecoder().decode(Galaxy.self, from: galaxyData as! Data)
//        let galaxyString = String(data: galaxyData, encoding: .utf8)
        
        let dict = try! JSONSerialization.jsonObject(with: galaxyData, options: []) as! [String: Any]
        
        
        let planets = dict[Galaxy.CodingKeys.stars.rawValue] as! NSArray
        
        var retPlanets = [Planet]()
        
        for (i, planet) in planets.enumerated(){
            
            guard let planetDict = planet as? NSDictionary, let galaxy = unpackedGalaxy  else { continue }
            
            let star = galaxy.stars[i]
            let planet = Planet(from: star)
            
            if let orbits = planetDict["orbits"] as? NSArray{
                let orbitsData = try! JSONSerialization.data(withJSONObject: orbits, options: [])
                let newOrbits = try! JSONDecoder().decode([Orbit].self, from: orbitsData)
                
                planet.orbits = newOrbits
                
            } else {
                
                planet.orbits = nil
            }
            
            retPlanets.append(planet)
            
        }
        
        return Galaxy(stars: retPlanets)
        print("---------------------------")
        let planetJson = try! JSONSerialization.data(withJSONObject: planets, options: [])
        
        let truePlanets = [Planet]()
        
        
        return Galaxy(stars: truePlanets)
        
        
        
        
//        print("Data is", String(data: galaxyData as! Data, encoding: .utf8))
//
//        for (i, star) in (galaxy?.stars.enumerated()) ?? [].enumerated(){
//            galaxy?.stars[i] = Planet(from: star)
//        }
//
//
//        return galaxy
    }
    
    func updateGalaxy(to newGalaxy: Galaxy){
        
        let jsonData = try! JSONEncoder().encode(newGalaxy)
        self.userDefaults.set(jsonData, forKey: StorageKeys.kGALAXY.rawValue)
        
        print("[PERSISTANCE] Updated galaxy on UserDefaults!")
    }
    
    
}

