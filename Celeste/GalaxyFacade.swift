//
//  GalaxyFacade.swift
//  Celeste
//
//  Created by Bruno Pastre on 02/09/19.
//  Copyright © 2019 Bruno Pastre. All rights reserved.
//

import Foundation

class GalaxyFacade{
    
    static let instance = GalaxyFacade()
    
    private init(){
        
    }
    
    func getCurrentGalaxy() -> Galaxy{
        
        
        return Galaxy(stars: [])
    }
}
