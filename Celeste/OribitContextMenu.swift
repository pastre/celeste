//
//  OribitContextMenu.swift
//  Celeste
//
//  Created by Bruno Pastre on 29/08/19.
//  Copyright © 2019 Bruno Pastre. All rights reserved.
//

import Foundation
import ARKit

//class OrbitContextMenu: SCNNodeTransformer{
//    
//    func getPosition() -> SCNVector3 {
//        return SCNVector3Zero
//    }
//    
//    func getNode() -> SCNNode {
//        defer { self.needsDrawing = false}
//        guard let src = self.sourceNode, let target = self.targetNode else {
//            let node = SCNNode()
//            node.name = "ClearOrbit"
//            return node
//        }
//        
//        let line = SCNGeometry.line(from: src.worldPosition, to: target.worldPosition)
//        let lineNode = SCNNode(geometry: line)
//        lineNode.position = SCNVector3Zero
//        return lineNode
//    }
//    
//    var needsDrawing: Bool! = false
//    
//    var lineNode: SCNNode?
//    var sourceNode: SCNNode?
//    var targetNode: SCNNode?
//    
//    static let instance = OrbitContextMenu()
//    
//    private init() {
//        
//    }
//    
//    
//    func getOrbitIndicator() -> SCNNode{
////        let geometry = SCNSphere(radius: 0.01)
//        let geometry = SCNCylinder(radius: 0.01, height: 1)
//        let targetNode = SCNNode(geometry: geometry)
//        let ret = SCNNode()
//        
//        ret.addChildNode(targetNode)
//        targetNode.eulerAngles.y = -Float.pi / 2
//        ret.position = SCNVector3Zero
//        
//        return ret
//    }
//    
//}
