//
//  ViewController2D.swift
//  Celeste
//
//  Created by Filipe Souza on 17/08/19.
//  Copyright © 2019 Bruno Pastre. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController2D: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet weak var skview: SKView!
    @IBOutlet var panGesture: UIPanGestureRecognizer!
    @IBOutlet var pinchGesture: UIPinchGestureRecognizer!
    
    @IBOutlet var rotationGesture: UIRotationGestureRecognizer!
    var scene: Scene2D!
    var lastPosition = CGPoint()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scene = Scene2D(size: view.bounds.size)
        scene.scaleMode = .aspectFill
        scene.setViewController(viewController: self)
        
        skview.presentScene(scene)
        
        panGesture.minimumNumberOfTouches = 2
        panGesture.maximumNumberOfTouches = 2
        panGesture.delegate = self
//        panGesture.isEnabled = false
        
        pinchGesture.delegate = self
//        pinchGesture.isEnabled = false
        
        rotationGesture.delegate = self
//        rotationGesture.isEnabled = false
        
//        skview.showsFields = true
//        skview.showsPhysics = true
//        skview.showsFPS = true
        
//        skview.isMultipleTouchEnabled = true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @IBAction func rotationGesture(_ sender: UIRotationGestureRecognizer) {
        scene.camera!.zRotation += sender.rotation
        sender.rotation = 0
    }
    
    @IBAction func panGesture(_ sender: UIPanGestureRecognizer) {
        let position = sender.location(in: view)
        if sender.numberOfTouches < 2 {
            sender.state = .ended
            return
        }
        if sender.state != .began {
            scene.camera!.position.x -=
                (position.x - lastPosition.x) * scene.camera!.xScale * CGFloat(cos(scene.camera!.zRotation)) +
                (position.y - lastPosition.y) * scene.camera!.yScale * CGFloat(sin(scene.camera!.zRotation))
            scene.camera!.position.y +=
                (position.y - lastPosition.y) * scene.camera!.yScale * CGFloat(cos(scene.camera!.zRotation)) -
                (position.x - lastPosition.x) * scene.camera!.xScale * CGFloat(sin(scene.camera!.zRotation))
        }
        lastPosition = position
    }
    
    @IBAction func pinchGesture(_ sender: UIPinchGestureRecognizer) {
        if sender.state == .ended {
            if scene.camera!.xScale >= 5 {
                scene.camera!.run(.scale(to: 5, duration: 0.5))
            } else if scene.camera!.xScale < 0.5 {
                scene.camera!.run(.scale(to: 0.5, duration: 0.33))
            }
        }
        scene.camera!.xScale /= sender.scale
        scene.camera!.yScale /= sender.scale
        sender.scale = 1.0
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return UIRectEdge.all
    }

}
