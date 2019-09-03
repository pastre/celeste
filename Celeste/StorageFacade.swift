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
        guard let galaxyData = self.userDefaults.object(forKey: StorageKeys.kGALAXY.rawValue)  else { return nil }
        let galaxy = try? JSONDecoder().decode(Galaxy.self, from: galaxyData as! Data)
        return galaxy
    }
    
    func updateGalaxy(to newGalaxy: Galaxy){
        
        let jsonData = try! JSONEncoder().encode(newGalaxy)
        self.userDefaults.set(jsonData, forKey: StorageKeys.kGALAXY.rawValue)
        
        print("[PERSISTANCE] Updated galaxy on UserDefaults!")
    }
    
    
}

