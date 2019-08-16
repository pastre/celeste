//
//  ContextMenu.swift
//  Celeste
//
//  Created by Bruno Pastre on 16/08/19.
//  Copyright © 2019 Bruno Pastre. All rights reserved.
//

import Foundation

enum ContextMenuOption:String, CaseIterable{
    case createPlanet = "Create Planet"
}

protocol ContextMenuDelegate {
    func onOption(option: ContextMenuOption)
}

class ContextMenu{
    
    static let instance = ContextMenu()
    var isHidden: Bool!
    
    private init(){
        self.isHidden = true
    }
    
    
}
