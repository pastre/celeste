//
//  ContextMenuGestureRecognizer.swift
//  Celeste
//
//  Created by Bruno Pastre on 16/08/19.
//  Copyright © 2019 Bruno Pastre. All rights reserved.
//

import UIKit.UIGestureRecognizerSubclass

protocol ContextMenuGestureDelegate: UIGestureRecognizerDelegate{
    func onTriggered()
}

class ContextMenuGestureRecognizer: UIPanGestureRecognizer {
    
    let CONTEXT_MENU_TIMER_THRESHOLD: Double = 1
    var timer: Timer!
    var hasTriggered: Bool! = false
    
    func startTimer(){
        self.timer = Timer.scheduledTimer(withTimeInterval: CONTEXT_MENU_TIMER_THRESHOLD, repeats: false, block: { (_) in
//            self.state = .tri
            guard let delegate = self.delegate as? ContextMenuGestureDelegate else { return }
            delegate.onTriggered()
            self.hasTriggered = true
            self.timer.invalidate()
        })
        
    }
    
    func stopTimer(){
        self.timer.invalidate()
    }
    
    override var state: UIGestureRecognizer.State{
        didSet{
            if self.state == .began{
                self.startTimer()
            } else if state != .changed{
//            } else {
                self.stopTimer()
                self.hasTriggered = false
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        self.state = .began
    }
//    override var delegate: ContextMenuGestureDelegate?
}
