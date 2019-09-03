//
//  Point.swift
//  Celeste
//
//  Created by Bruno Pastre on 16/08/19.
//  Copyright © 2019 Bruno Pastre. All rights reserved.
//

import Foundation
import SceneKit


class Point: Equatable, Encodable, Decodable{
    static func == (lhs: Point, rhs: Point) -> Bool {
        return lhs.x == rhs.x  && lhs.y == rhs.y  && lhs.z == rhs.z
    }
    
    enum CodingKeys: String, CodingKey{
        case x = "x"
        case y = "y"
        case z = "z"
    }
    
    func encode(to encoder: Encoder) throws{
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(x, forKey: .x)
        try container.encode(y, forKey: .y)
        try container.encode(z, forKey: .z)
        
    }
    
    required init(decoder aDecoder: Decoder) throws {
        let container = try aDecoder.container(keyedBy: CodingKeys.self)
        
        self.x = try CGFloat(container.decode(Float.self, forKey: .x))
        self.y = try CGFloat(container.decode(Float.self, forKey: .y))
        self.z = try CGFloat(container.decode(Float.self, forKey: .z))
        
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
