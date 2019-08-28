//
//  Provider.swift
//  Celeste
//
//  Created by Bruno Pastre on 25/08/19.
//  Copyright © 2019 Bruno Pastre. All rights reserved.
//

import Foundation
import SceneKit

class ModelProvider{
    
    static let instance = ModelProvider()
    var models: [ModelOption]
    
    
    private init(){
        self.models = [ModelOption]()
        self.loadModels()
    }
    
    func loadModels(){
        
    }
    
    
}
