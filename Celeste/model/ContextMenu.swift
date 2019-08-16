//
//  ContextMenu.swift
//  Celeste
//
//  Created by Bruno Pastre on 16/08/19.
//  Copyright © 2019 Bruno Pastre. All rights reserved.
//

import Foundation

enum ContextMenuOption: CaseIterable{
    case add
    
}

protocol ContextMenuDelegate{
    func onOptionSelected(option: ContextMenuOption)
}

class ContextMenu{
    
    static var instance = ContextMenu()
    
    var isHidden: Bool
    var currentTarget: Star?
    
    private init(){
        self.isHidden = true
    }
    
    func presentMenu(){
        guard let target = self.currentTarget else { return }
        let node = target.getNode()
        
        
    }
    
    func hideMenu(){
        
    }
    
    func updateMenuPresentation(target: Star?){
        if self.isHidden{
            self.currentTarget = target
            self.presentMenu()
        } else {
            self.currentTarget = nil
            self.hideMenu()
        }
        self.isHidden = !self.isHidden
    }
}
