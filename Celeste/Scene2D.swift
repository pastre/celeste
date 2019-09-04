//
//  Scene2D.swift
//  Celeste
//
//  Created by Filipe Souza on 17/08/19.
//  Copyright © 2019 Bruno Pastre. All rights reserved.
//

import UIKit
import SpriteKit

class Scene2D: SKScene {
    var viewController: ViewController2D!
    var galaxy: Galaxy!
    let multiplier = CGFloat(50)
    var circles: [SKShapeNode] = []
    var selectedShape: SKShapeNode!
    var teste: Bool = true
    
    func setViewController(viewController: ViewController2D){
        self.viewController = viewController
    }
    
    override func didMove(to view: SKView) {
        let camera = SKCameraNode()
        self.camera = camera
        camera.position = CGPoint(x: frame.width/2, y: frame.height/2)
        addChild(camera)
        physicsWorld.gravity = .zero
        physicsWorld.speed = 0.5
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        let boundary = SKShapeNode(rect: frame)
        boundary.strokeColor = .black
        addChild(boundary)
//        updateStars()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let point = touches.first!.location(in: self)
        let node = self.atPoint(point)
        if node.name == "circle" {
            selectedShape = node as? SKShapeNode
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let point = touches.first!.location(in: self)
        if selectedShape != nil {
            selectedShape.position = point
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        selectedShape = nil
    }
    
//    func updateStars() {
//        for star in Model.shared.galaxy.stars {
//            updateStar(star: star, parent: nil, level: 1.0)
//        }
//    }
    
    func updateStar(star: Star, parent: SKShapeNode!, level: CGFloat) {
        let circle = SKShapeNode(circleOfRadius: star.radius * multiplier)
        circle.strokeColor = star.color
        circle.fillColor = star.color
        circle.name = "circle"
        circle.physicsBody = SKPhysicsBody(circleOfRadius: star.radius * multiplier)
        let distance = CGFloat(200)
        circle.position = CGPoint(x: frame.width/2 + CGFloat.random(in: -distance...distance), y: frame.height/2 + CGFloat.random(in: -distance...distance))
        let uint32 = UInt32.random(in: 0...4294967295)
        circle.physicsBody?.fieldBitMask = uint32
        addChild(circle)
        
//        circle.physicsBody?.usesPreciseCollisionDetection = true
//        circle.physicsBody?.allowsRotation = false
//        circle.physicsBody?.restitution = 0.0
//        circle.physicsBody?.linearDamping = 0.5
        
        if parent != nil {
            let force = SKFieldNode.radialGravityField()
            force.minimumRadius = 0
            force.strength = -0.1
            force.categoryBitMask = 4294967295 - uint32
            force.constraints = [.distance(SKRange(constantValue: 0), to: circle)]
            circle.addChild(force)
            circle.constraints = [.distance(SKRange(constantValue: 300.0 * star.radius), to: parent)]
        } else {
            circle.physicsBody?.isDynamic = false
        }
        
        if let nested = star as? NesteableStar{
            if let children = nested.child {
                for child in children {
                    updateStar(star: child, parent: circle, level: level + 1)
                }
            }
        }
    }
}
