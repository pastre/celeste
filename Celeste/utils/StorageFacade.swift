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

    static let kGALAXY = "Galaxy"

    let userDefaults = UserDefaults.standard
    func getGalaxy() -> Galaxy? {
        if let galaxy = self.userDefaults.data(forKey: StorageFacade.kGALAXY){
            
        }
        
        return nil
    }
    
    
}

