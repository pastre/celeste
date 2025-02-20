//
//  ContextMenuGestureRecognizer.swift
//  Celeste
//
//  Created by Bruno Pastre on 16/08/19.
//  Copyright © 2019 Bruno Pastre. All rights reserved.
//

import UIKit.UIGestureRecognizerSubclass

protocol ContextMenuGestureDelegate: UIGestureRecognizerDelegate{
    func onTriggered(_ gesture : ContextMenuGestureRecognizer)
//    func onMoved(_ gesture: ContextMenuGestureRecognizer)
}

class ContextMenuGestureRecognizer: UIPanGestureRecognizer {
    
    let CONTEXT_MENU_TIMER_THRESHOLD: Double = 0.5
    var timer: Timer!
    var hasTriggered: Bool! = false
    var parentView: UIView!
    var startLocation: CGPoint!
    
    
    func startTimer(){
        self.timer = Timer.scheduledTimer(withTimeInterval: CONTEXT_MENU_TIMER_THRESHOLD, repeats: false, block: { (_) in
//            self.state = .tri
            guard let delegate = self.delegate as? ContextMenuGestureDelegate else { return }
            delegate.onTriggered(self)
            self.hasTriggered = true
            self.timer.invalidate()
        })
        
    }
    
    func restartTimer(){
        
        self.stopTimer()
        self.hasTriggered = false
        
        let newLocation = self.location(in: self.view)
        
        if self.startLocation == nil {self.startLocation = newLocation}
        
        let distance = newLocation.distance(self.startLocation)
        
        if distance > 50{
            self.startTimer()
        }
        
    }
    
    func stopTimer(){
        self.timer.invalidate()
    }
    
    override var state: UIGestureRecognizer.State{
        didSet{
            if self.state == .began{
                self.startTimer()
            } else if self.state == .changed{
                if self.hasTriggered {
                    self.stopTimer()
                }
            } else if self.state != .possible{
                self.stopTimer()
                self.hasTriggered = false
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        self.state = .began
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        
    }
    
}

