//
//  VectorMath.swift
//  Celeste
//
//  Created by Bruno Pastre on 18/08/19.
//  Copyright © 2019 Bruno Pastre. All rights reserved.
//

import Foundation
import SceneKit


extension CGPoint{
    func distance(_ b: CGPoint) -> CGFloat {
        let a = self
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return CGFloat(sqrt(xDist * xDist + yDist * yDist))
    }
    
}

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
    
    func versor() -> SCNVector3{
        return SCNVector3(self.x > 0 ? 1 : -1, self.y > 0 ? 1 : -1, self.z > 0 ? 1 : -1)
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
    
    func absolute() -> SCNVector3{
        return SCNVector3(self.x * self.x > 0 ? 1 : -1, self.y * self.y > 0 ? 1 : -1, self.z * self.z > 0 ? 1 : -1)
    }
    
    func pointing(at direction: SCNVector3) -> SCNVector3{
        return SCNVector3(self.x * (direction.x > 0 ? 1 : -1), self.y * (direction.y > 0 ? 1 : -1), self.z * (direction.z > 0 ? 1 : -1))
    }
    
    func distance(to position: SCNVector3) -> Float{
        let dist = self - position
        return dist.length()
    }
    
    func angle(with vector: SCNVector3) -> Float{
        let dotProduct = (self.x * vector.x) + (self.y * vector.y) + (self.z * vector.z)
        let denominador = self.length() * vector.length()
        
        print(dotProduct, denominador)
        
        return dotProduct / denominador
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


