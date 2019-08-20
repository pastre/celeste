//
//  ContextMenu.swift
//  Celeste
//
//  Created by Bruno Pastre on 16/08/19.
//  Copyright © 2019 Bruno Pastre. All rights reserved.
//

import Foundation
import SceneKit

enum ContextMenuMode: CaseIterable{
    case galaxy
    case planet
}

enum ContextMenuOption:String, CaseIterable{
    case createPlanet = "Create Planet"
}

protocol ContextMenuDelegate {
    func onOption(option: ContextMenuOption)
}

class ContextMenu: SCNNodeTransformer{
    func getPosition() -> SCNVector3 {
        return SCNVector3Zero
    }
    
    var color: UIColor!
    
    func getNode() -> SCNNode {
        let planeGeometry = SCNPlane(width: 0.2, height: 0.2)
//        let planeGeometry = SCNCone(topRadius: 0.1, bottomRadius: 0.3, height: 0.5)
        let material = SCNMaterial()
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    
    
        view.isUserInteractionEnabled = false
        view.backgroundColor = self.color
        
        material.diffuse.contents = view
        
        material.isDoubleSided = true
        material.writesToDepthBuffer = false
//        material.blendMode = .screen
        
        let planeNode = SCNNode(geometry: planeGeometry)
        planeNode.geometry?.firstMaterial = material
        

        return planeNode
    }
    
    
    static let instance = ContextMenu()
    var isHidden: Bool!
    
    private init(){
        self.isHidden = true
    }
    
    func openContextMenu(mode: ContextMenuMode){
        switch mode {
        case .galaxy:
            //TODO
            self.color = #colorLiteral(red: 0.02779892646, green: 0.4870637059, blue: 0.4917319417, alpha: 1)
            
        case .planet:
            // TODO
            self.color = #colorLiteral(red: 0.4971322417, green: 0.1406211555, blue: 0.4916602969, alpha: 1)
            
        }
    }
    
    func onSelected(option: SCNNode, target: SCNNode){
        
    }
}
