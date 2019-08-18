//
//  VectorMath.swift
//  Celeste
//
//  Created by Bruno Pastre on 18/08/19.
//  Copyright © 2019 Bruno Pastre. All rights reserved.
//

import Foundation
import SceneKit

extension SCNVector3{
    static func +(_ a: SCNVector3, _ b: SCNVector3) -> SCNVector3{
        return SCNVector3(a.x + b.x, a.y + b.y, a.z + b.z)
    }
    
    static func -(_ a: SCNVector3, _ b: SCNVector3) -> SCNVector3{
        return SCNVector3(a.x - b.x, a.y - b.y, a.z - b.z)
    }
    
    static func *(_ a: SCNVector3, _ b: SCNVector3) -> SCNVector3{
        return SCNVector3(a.x * b.x, a.y * b.y, a.z * b.z)
    }
    
    
    static func ==(_ a: SCNVector3, _ b: SCNVector3) -> Bool{
        return (a.x == b.x && a.y == b.y && a.z == b.z)
    }
    
    
    
    func length() -> Float {
        return sqrtf(x * x + y * y + z * z)
    }
    
    func normalized() -> SCNVector3 {
        if self.length() == 0 {
            return self
        }
        
        return self / self.length()
    }
    
}

func / (left: SCNVector3, right: Float) -> SCNVector3 {
    return SCNVector3Make(left.x / right, left.y / right, left.z / right)
}
func * (left: SCNVector3, right: Float) -> SCNVector3 {
    return SCNVector3Make(left.x * right, left.y * right, left.z * right)
}

func + (left: Point, right: SCNVector3) -> SCNVector3{
    return SCNVector3(left.x + right.x, left.y + right.y, (left.z ?? 0.0) +  right.z)
}

func + (left: CGFloat, right: Float) -> Float{
    return Float(left) + right
}


