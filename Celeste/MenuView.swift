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
    
    func getOptionBg() -> UIImageView{
        
        let imageView = UIImageView(image: UIImage(named: "menuOptionBg"))
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        
        return imageView
    }
    
    func getActioBarOptionBg() -> UIView {
        let imageView = UIImageView(image: UIImage(named: "bottomOption"))
        
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }
    
    func getButton(name: String, icon: UIImage?, action selector: Selector) -> UIView{
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
       
        button.isUserInteractionEnabled = true
        
        let bg = self.getActioBarOptionBg()
        
        bg.translatesAutoresizingMaskIntoConstraints = false
        
        button.setImage(icon, for: .normal)
        button.setTitle(name, for: .normal)
        //button.
        button.addTarget(self, action: selector, for: .touchDown)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        bg.addSubview(button)
        
        button.centerYAnchor.constraint(equalTo: bg.centerYAnchor).isActive = true
        button.centerXAnchor.constraint(equalTo: bg.centerXAnchor).isActive = true
        
        button.heightAnchor.constraint(equalTo: bg.heightAnchor).isActive = true
        button.widthAnchor.constraint(equalTo: bg.widthAnchor).isActive = true
        
        return bg
    }
    
    func getOption(with contentView: UIView, heightMult: CGFloat = 1) -> UIView {
        
        let view = UIView()
        let bg = self.getOptionBg()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(bg)
        view.addSubview(contentView)
        
        bg.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        bg.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        bg.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        bg.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        
        contentView.centerXAnchor.constraint(equalTo: bg.centerXAnchor ).isActive = true
        contentView.centerYAnchor.constraint(equalTo: bg.centerYAnchor ).isActive = true
        contentView.heightAnchor.constraint(equalTo: bg.heightAnchor, multiplier: heightMult ).isActive = true
        contentView.widthAnchor.constraint(equalTo: bg.widthAnchor, multiplier: 0.9).isActive = true
        
        return view
    }
    
    func getAsMenu(with content: UIView, hasDelete: Bool = false) -> UIView{
        let view = UIView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let cancelOption = self.getButton(name: "Cancel", icon: UIImage(named: "cancel"), action: #selector(self.onCancelCallback))
        let confirmOption = self.getButton(name: "Save", icon: UIImage(named: "confirm"), action: #selector(self.onSaveCallback))
//        let deleteOption = hasDelete ? self.getButton(name: "Delete", icon: UIImage(named: "delete"), action: #selector(self.onDelete(_:))) : nil
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.onCancelCallback(_:)))//        bg.addGestureRecognizer(tap)
        
        let actionBarView: UIView = {
            let view = UIView()

            view.translatesAutoresizingMaskIntoConstraints = false
            
            view.addSubview(cancelOption)
            view.addSubview(confirmOption)

            cancelOption.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.28).isActive = true
            confirmOption.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.28).isActive = true


            cancelOption.heightAnchor.constraint(equalTo: cancelOption.widthAnchor, multiplier: 1/3.78).isActive = true
            confirmOption.heightAnchor.constraint(equalTo: cancelOption.widthAnchor, multiplier: 1/3.78).isActive = true


            cancelOption.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            confirmOption.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

            cancelOption.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true

            confirmOption.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            
            return view
        }()
//
//        view.addSubview(cancelOption)
//        view.addSubview(confirmOption)
//        cancelOption.addGestureRecognizer(tap)
        
//        actionBarView.addGestureRecognizer(tap)
//        actionBarView.backgroundColor = UIColor.blue
        
        view.addSubview(content)
        view.addSubview(actionBarView)
        
        actionBarView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        content.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        actionBarView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.95).isActive = true
        content.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1).isActive = true
        
        
        actionBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        content.bottomAnchor.constraint(equalTo: actionBarView.topAnchor, constant: -35).isActive = true
        
        actionBarView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.08).isActive = true
        content.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5).isActive = true
        
        return view
    }
    
    @objc func onCancelCallback(_ sender: UIButton){
        print("Cancel callback")
        self.onCancel()
    }
    
    @objc func onSaveCallback(_ sender: UIButton){
        print("Save callback")
        self.onSave()
    }
    
    @objc func onDelete(_ sender: UIButton){
        
    }
    
    func onCancel(){
        // metodo abstrato para as subclasses implementarem
    }
    
    func onSave(){
        // metodo abstrato para as subclasses implementarem
    }
    
 
    
    
}

