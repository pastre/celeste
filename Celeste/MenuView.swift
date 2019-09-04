//
//  MenuView.swift
//  Celeste
//
//  Created by Bruno Pastre on 04/09/19.
//  Copyright © 2019 Bruno Pastre. All rights reserved.
//

import Foundation
import UIKit


class MenuView {
    func getButton(title: String, action selector: Selector) -> UIButton{
        
        let button = UIButton()
        
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: selector , for: .touchDown)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5807052752)
        button.layer.cornerRadius = button.frame.width / 2
        
        return button
    }
    
    func getOKButton() -> UIButton{
        return self.getButton(title: "ok", action: #selector(self.onOk(_:)))
    }
    
    func getCancelButton()  -> UIButton{
        return self.getButton(title: "ok", action: #selector(self.onCancel(_:)))
    }
    
    @objc func onOk(_ sender: UIButton){
        // METODO EM BRANCO PARA AS SUBCLASSES IMPLEMENTAREM
    }
    
    @objc func onCancel(_ sender: UIButton){
        // METODO EM BRANCO PARA AS SUBCLASSES IMPLEMENTAREM
        
    }
}

