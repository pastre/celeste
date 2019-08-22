//
//  Point.swift
//  Celeste
//
//  Created by Bruno Pastre on 16/08/19.
//  Copyright © 2019 Bruno Pastre. All rights reserved.
//

import Foundation
import SceneKit


class Point: Equatable{
    static func == (lhs: Point, rhs: Point) -> Bool {
        return lhs.x == rhs.x  && lhs.y == rhs.y  && lhs.z == rhs.z
    }
    
    internal init(x: CGFloat?, y: CGFloat?, z: CGFloat?) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    var x: CGFloat!
    var y: CGFloat!
    var z: CGFloat?
    
    static var zero: Point = Point(x: 0, y: 0, z: 0)
}
