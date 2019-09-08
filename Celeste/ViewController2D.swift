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
    
    lazy var backButton: UIView = {
        let view = UIView()
        let imageView = UIImageView(image: UIImage(named: "menu"))
        let label = UILabel()
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.onBackButton))
        
        view.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.backgroundColor = UIColor.clear
//        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        label.text = "Back"
        label.textColor = UIColor.white
        
        view.addGestureRecognizer(tap)
        view.addSubview(imageView)
        view.addSubview(label)
        
        imageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5).isActive = true
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 8/13).isActive = true
        
        label.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: 5).isActive = true
        label.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -5).isActive = true
        
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        label.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.8).isActive = true
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scene = Scene2D(size: view.bounds.size)
        scene.scaleMode = .aspectFill
        scene.setViewController(viewController: self)
        
        skview.presentScene(scene)
        
        panGesture.minimumNumberOfTouches = 2
        panGesture.maximumNumberOfTouches = 2
        panGesture.delegate = self
        pinchGesture.delegate = self
        rotationGesture.delegate = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        scene.removeAllChildren()
    }
    
    override func viewDidLayoutSubviews() {
        self.setupBackButton()
    }
    
    func setupBackButton(){
        self.view.addSubview(self.backButton)
        
        self.backButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant:  40).isActive = true
        self.backButton.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.backButton.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.03).isActive = true
        self.backButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.25).isActive = true
        
        self.backButton.layer.cornerRadius = self.backButton.frame.height / 2
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @IBAction func rotationGesture(_ sender: UIRotationGestureRecognizer) {
        scene.camera!.zRotation += sender.rotation
        for (_, planet) in scene.planets {
            planet.label.zRotation += sender.rotation
            planet.label.position.x = -40 * CGFloat(sin(scene.camera!.zRotation))
            planet.label.position.y = 40 * CGFloat(cos(planet.label.zRotation))
        }
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
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
//    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
//        return UIRectEdge.all
//    }

    
    @objc func onBackButton(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
}
