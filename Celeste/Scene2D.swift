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
    let distanceBetweenStars = CGFloat(75)
    var maximumDistanceToOrbit: CGFloat!
    var circles: [SKShapeNode] = []
    var selectedShape: SKShapeNode!
    var teste: Bool = true
    var firstTouchPosition: CGPoint!
    var lastTouchPosition: CGPoint!
    var lastTouch: UITouch!
    var tempConstraints: [SKConstraint]!
    var starsShapes: [SKShapeNode] = []
    
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
        maximumDistanceToOrbit = distanceBetweenStars * 1.5
        updateStars()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let point = touches.first!.location(in: self)
        lastTouchPosition = point
        let node = self.atPoint(point)
        if node.name != nil {
            selectedShape = node as? SKShapeNode
            tempConstraints = selectedShape.constraints
            selectedShape.constraints = []
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let point = touches.first!.location(in: self)
        
        if selectedShape != nil {
            selectedShape.position = point
        } else {
            camera?.position.x += lastTouchPosition.x - point.x
            camera?.position.y += lastTouchPosition.y - point.y
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let point = touches.first!.location(in: self)
        updateHierarchy(point: point)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        let point = touches.first!.location(in: self)
        updateHierarchy(point: point)
    }
    
    func updateHierarchy(point: CGPoint) {
        if selectedShape != nil {
            var selectedStar: Star!
            var selectedStarHasChild: Bool!
            for star in Model.shared.galaxy.stars {
                if let nested = star as? NesteableStar {
                    if let children = nested.child {
                        for child in children {
                            if child.id == selectedShape.name {
                                selectedStar = child
                            }
                        }
                    }
                }
                if star.id == selectedShape.name {
                    selectedStar = star
                }
            }
            
            if let nested = selectedStar as? NesteableStar {
                if let children = nested.child {
                    selectedStarHasChild = children.isEmpty ? false : true
                }
            }
            
            if !selectedStarHasChild {
                var closestStar: Star!
                for star in Model.shared.galaxy.stars {
                    
                    if star.id != selectedStar.id && closestStar == nil {
                        closestStar = star
                    }
                    if closestStar != nil {
                        if distance(star.get2DPosition(), point) < distance(closestStar.get2DPosition(), point) && selectedStar.id != star.id{
                            closestStar = star
                        }
                    }
                }
                
                var closestStarShape: SKShapeNode!
                for shape in starsShapes {
                    if shape.name == closestStar.id {
                        closestStarShape = shape
                    }
                }
                
                for (index, star) in Model.shared.galaxy.stars.enumerated() {
                    if star.id == selectedStar.id {
                        Model.shared.galaxy.stars.remove(at: index)
                    }
                    var nesteableStar = star as! NesteableStar
                    for (index, child) in nesteableStar.child!.enumerated() {
                        if child.id == selectedStar.id {
                            nesteableStar.child!.remove(at: index)
                        }
                    }
                }
                
                if distance(closestStar.get2DPosition(), point) < maximumDistanceToOrbit {
                    let parent = closestStar as! NesteableStar
                    parent.child?.append(selectedStar)
                    selectedShape.constraints = [.distance(SKRange(constantValue: distanceBetweenStars), to: closestStarShape)]
                    if !selectedStar.isChild {
                        updateStarType(shape: selectedShape, isChild: true)
                        selectedStar.isChild = true
                    }
                } else {
                    selectedShape.constraints = []
                    Model.shared.galaxy.stars.append(selectedStar)
                    if selectedStar.isChild {
                        updateStarType(shape: selectedShape, isChild: false)
                        selectedStar.isChild = false
                    }
                }
                closestStar = nil
                closestStarShape = nil
            }
            selectedStar.center.x = point.x
            selectedStar.center.y = point.y
        }
        selectedShape = nil
    }
    
    func updateStarType(shape: SKShapeNode, isChild: Bool) {
        if isChild {
            shape.run(.scale(by: 0.5, duration: 0.25))
            shape.physicsBody?.isDynamic = true
        } else {
            shape.run(.scale(by: 2, duration: 0.25))
            shape.physicsBody?.isDynamic = false
        }
    }
    
    func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return CGFloat(sqrt(xDist * xDist + yDist * yDist))
    }
    
    func updateStars() {
        for star in Model.shared.galaxy.stars {
            updateStar(star: star, parent: nil, level: 1.0)
        }
    }
    
    func updateStar(star: Star, parent: SKShapeNode!, level: CGFloat) {
        let shape = star.get2DNode()
        addChild(shape)
        starsShapes.append(shape)
        
        if parent != nil {
            shape.constraints = [.distance(SKRange(constantValue: distanceBetweenStars), to: parent)]
            star.isChild = true
        } else {
            shape.physicsBody?.isDynamic = false
            star.isChild = false
        }
        
        if let nested = star as? NesteableStar{
            if let children = nested.child {
                for child in children {
                    updateStar(star: child, parent: shape, level: level + 1)
                }
            }
        }
    }
}
