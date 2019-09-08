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
    let distanceMultiplier = CGFloat(125)
    let sizeMultiplier = CGFloat(25)
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
    var planets: [String: Planet]! = [:]
    
    func setViewController(viewController: ViewController2D){
        self.viewController = viewController
    }
    
    override func didMove(to view: SKView) {
        let camera = SKCameraNode()
        self.camera = camera
        let stars = GalaxyFacade.instance.galaxy.stars!
        if !stars.isEmpty {
            let firstPlanet = stars[0]
            camera.position = firstPlanet.get2DPosition()
        }
        camera.xScale = 5
        camera.yScale = 5
        camera.run(.scale(to: 1, duration: 1))
        addChild(camera)
        physicsWorld.gravity = .zero
        maximumDistanceToOrbit = distanceBetweenStars * 2
//        GalaxyFacade.instance.galaxy.stars = []
        updateStars()
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let point = touches.first!.location(in: self)
        firstTouchPosition = point
        let node = self.atPoint(point)
        if node.name != nil {
            selectedShape = node as? SKShapeNode
//            print("selectedShape.name")
//            print(selectedShape.name)
//            selectedShape.physicsBody?.isDynamic = false
            tempConstraints = selectedShape.constraints
            selectedShape.constraints = []
        }
//        let galaxy = GalaxyFacade.instance.galaxy.stars
//        print("galaxy: ")
//        print(galaxy)
//        for star in galaxy! {
//            print("star: ")
//            print(star)
//            let planet = star as! Planet
//            print("orbits: ")
//            print(planet.orbits)
//            print("getOrbiters: ")
//            print(planet.getOrbiters())
//        }
//        print()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchPosition = touches.first!.location(in: self)
        
        if selectedShape != nil {
            selectedShape.position = lastTouchPosition
        } else {
            camera?.position.x += firstTouchPosition.x - lastTouchPosition.x
            camera?.position.y += firstTouchPosition.y - lastTouchPosition.y
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let point = touches.first!.location(in: self)
//        updateHierarchy(point: point)
        selectedShape = nil
        firstTouchPosition = nil
        lastTouchPosition = nil
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        let point = touches.first!.location(in: self)
//        updateHierarchy(point: point)
        selectedShape = nil
        firstTouchPosition = nil
        lastTouchPosition = nil
    }
    
    func updateHierarchy(point: CGPoint) {
        if selectedShape != nil {
            let selectedPlanet = planets[selectedShape.name!]!
            print("selectedPlanet.getOrbiters()")
            print(selectedPlanet.getOrbiters())
            let orbiters = selectedPlanet.getOrbiters()
            let selectedPlanetHasChild = orbiters == nil || orbiters!.isEmpty ? false : true
            print("selectedPlanetHasChild")
            print(selectedPlanetHasChild)
            if !selectedPlanetHasChild {
                var closestPlanet: Planet!
                for star in GalaxyFacade.instance.galaxy.stars {
                    let planet = star as! Planet
                    if planet.id != selectedPlanet.id && closestPlanet == nil {
                        closestPlanet = planet
                    }
                    if closestPlanet != nil {
                        if distance(planet.get2DPosition(), point) < distance(closestPlanet.get2DPosition(), point) {
                            closestPlanet = planet
                        }
                    }
                }
                
                if closestPlanet != nil {
                    print("closestPlanet.id")
                    print(closestPlanet.id)
//                    let closestPlanetShape = planets[closestPlanet.id]!.shape!
                    
                    for star in GalaxyFacade.instance.galaxy.stars {
                        let planet = star as! Planet
                        
                        for (index, child) in (planet.getOrbiters() ?? []).enumerated() {
                            if child.id == selectedPlanet.id {
                                print("print(planet.orbits)")
                                print(planet.orbits)
                                print("index >= planet.orbits!.count")
                                print(index >= planet.orbits!.count)
                                let count = planet.orbits!.count
                                planet.orbits?.remove(at: index % count)
                            }
                        }
                    }
                    
                    if distance(closestPlanet.get2DPosition(), point) <= maximumDistanceToOrbit {
                        selectedPlanet.transformToChild(parentShape: closestPlanet.shape)
                        print("closestPlanet.orbits0")
                        print(closestPlanet.orbits)
                        GalaxyFacade.instance.createOrbit(around: closestPlanet.getNode(), child: selectedPlanet.getNode(), with: 0.2)
                        if closestPlanet.orbits == nil {
                            closestPlanet.orbits = []
                        }
                        closestPlanet.orbits?.append(Orbit(radius: CGFloat.random(in: 0...0.5), orbiter: selectedPlanet))
                        print("closestPlanet.orbits1")
                        print(closestPlanet.orbits)
//                        let parent = closestPlanet
////                        parent.child?.append(selectedPlanet)
//
//                        selectedShape.constraints = [.distance(SKRange(constantValue: distanceBetweenStars), to: closestPlanetShape)]
//                        if !selectedPlanet.isChild {
//                            selectedPlanet.isChild = true
//                            updateStarType(star: selectedPlanet)
//                        }
                    } else {
                        selectedPlanet.transformToParent()
                    }
//                    closestPlanet =
                }
//                selectedPlanet.center.x = point.x / distanceMultiplier
//                selectedPlanet.center.y = point.y / distanceMultiplier
            }
            selectedShape = nil
        }
        print()
        firstTouchPosition = nil
        lastTouchPosition = nil
    }
    
    func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return CGFloat(sqrt(xDist * xDist + yDist * yDist))
    }
    
    func updateStars() {
        for star in GalaxyFacade.instance.galaxy.stars {
            let planet = star as! Planet
            planet.isChild = false
            addChild(planet.get2DNode())
            planets[planet.id] = planet
        }
        for star in GalaxyFacade.instance.galaxy.stars {
            let planet = star as! Planet
            for child in planet.getOrbiters() ?? [] {
                planets[child.id]!.transformToChild(parentShape: planet.shape)
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if selectedShape != nil && lastTouchPosition != nil {
            selectedShape.position = lastTouchPosition
        }
    }
}
