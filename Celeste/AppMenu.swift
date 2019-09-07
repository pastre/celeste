//
//  AppMenu.swift
//  Celeste
//
//  Created by Bruno Pastre on 07/09/19.
//  Copyright © 2019 Bruno Pastre. All rights reserved.
//

import Foundation
import UIKit

protocol AppMenuDelegate: MenuDelegate{
    func onChangeMode()
}

class AppMenu: MenuView {
    
    static let instance = AppMenu()
    
    var delegate: AppMenuDelegate?
    
    private override init() {
        super.init()
    }
    
    func getView()  -> UIView{
        let view = UIView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let mapOption = super.getButton(name: "Galaxy Map", icon: UIImage(named: "map"), action: #selector(self.onGalaxyMap(_:)))
        let aboutOption = super.getButton(name: "About", icon: UIImage(named: "information"), action: #selector(self.onAbout(_:)))
        let helpOption = super.getButton(name: "Close", icon: UIImage(named: "cancel"), action: #selector(self.onHelp(_:)))
        
        
        
        view.addSubview(mapOption)
        view.addSubview(aboutOption)
        view.addSubview(helpOption)
        
//        mapOption.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1).isActive = true
        aboutOption.heightAnchor.constraint(equalTo: mapOption.heightAnchor).isActive = true
        helpOption.heightAnchor.constraint(equalTo: mapOption.heightAnchor).isActive = true
        
        mapOption.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9).isActive = true
        aboutOption.widthAnchor.constraint(equalTo: mapOption.widthAnchor).isActive = true
        helpOption.widthAnchor.constraint(equalTo: mapOption.widthAnchor).isActive = true
        
        mapOption.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        aboutOption.centerXAnchor.constraint(equalTo: mapOption.centerXAnchor).isActive = true
        helpOption.centerXAnchor.constraint(equalTo: mapOption.centerXAnchor).isActive = true
        
        mapOption.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        
        helpOption.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        aboutOption.topAnchor.constraint(equalTo: mapOption.bottomAnchor, constant: 20).isActive = true
        aboutOption.bottomAnchor.constraint(equalTo: helpOption.topAnchor, constant: -20).isActive = true
        
        return view
    }
    
    @objc func onGalaxyMap(_ sender: UIButton){
        self.delegate?.onChangeMode()
    }
    
    @objc func onAbout(_ sender: UIButton){
        
    }
    
    @objc func onHelp(_ sender: UIButton){
        self.delegate?.onCancel(nil)
    }
}
