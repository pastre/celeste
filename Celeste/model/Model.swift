//
//  Model.swift
//  Celeste
//
//  Created by Filipe Souza on 19/08/19.
//  Copyright © 2019 Bruno Pastre. All rights reserved.
//

import Foundation

class Model {
    static let shared = Model()
    
    let galaxy: Galaxy = Galaxy(stars: [
        NesteableStar(radius: 0.5 * 1, center: Point(x: 2, y: 2, z: 2), color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), child: [
            NesteableStar(radius: 0.5 * 0.5, center: Point(x: 1, y: 1, z: 1), color: #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1), child: []),
            NesteableStar(radius: 0.5 * 0.5, center: Point(x: 1, y: 1, z: 1), color: #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1), child: []),
            NesteableStar(radius: 0.5 * 0.5, center: Point(x: 1, y: 1, z: 1), color: #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1), child: []),
            NesteableStar(radius: 0.5 * 0.5, center: Point(x: 1, y: -1, z: 0), color: #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1), child: []),
            NesteableStar(radius: 0.5 * 0.5, center: Point(x: 1, y: 1, z: 1), color: #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1), child: []),
            NesteableStar(radius: 0.5 * 0.5, center: Point(x: 1, y: 1, z: 1), color: #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1), child: [])
        ]),
        NesteableStar(radius: 0.5 * 1, center: Point(x: 2, y: 2, z: 2), color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), child: [
            NesteableStar(radius: 0.5 * 0.5, center: Point(x: 1, y: 1, z: 1), color: #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1), child: []),
            NesteableStar(radius: 0.5 * 0.5, center: Point(x: 1, y: 1, z: 1), color: #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1), child: []),
            NesteableStar(radius: 0.5 * 0.5, center: Point(x: 1, y: 1, z: 1), color: #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1), child: []),
            NesteableStar(radius: 0.5 * 0.5, center: Point(x: 1, y: -1, z: 0), color: #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1), child: []),
            NesteableStar(radius: 0.5 * 0.5, center: Point(x: 1, y: 1, z: 1), color: #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1), child: []),
            NesteableStar(radius: 0.5 * 0.5, center: Point(x: 1, y: 1, z: 1), color: #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1), child: [])
        ])
    ])
    
    private init() {}
    
}
