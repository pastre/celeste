//
//  FloorPainting.swift
//  Celeste
//
//  Created by Bruno Pastre on 04/09/19.
//  Copyright © 2019 Bruno Pastre. All rights reserved.
//

import Foundation
import SceneKit

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

class FloorPaintingMenu: MenuView, SCNNodeTransformer, WheelPickerDataSource, WheelPickerDelegate{
   
    let colors: [UIColor] = [#colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1), #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1), #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1), #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)]
    
    func getView() -> UIView {
        
        let view: UIView  = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        let colorPicker: WheelPicker = {
           let picker = WheelPicker()
            
            picker.delegate = self
            picker.dataSource = self
            picker.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5474842317)
            picker.translatesAutoresizingMaskIntoConstraints = false
            
            return picker
        }()
        
        let okButton = super.getOKButton()
        let cancelButton = super.getCancelButton()
        
        view.addSubview(colorPicker)
        view.addSubview(okButton)
        view.addSubview(cancelButton)
        
        
        okButton.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        okButton.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        okButton.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        okButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.1).isActive = true
        
        cancelButton.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        cancelButton.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        cancelButton.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        cancelButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.1).isActive = true
        
        colorPicker.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        colorPicker.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        colorPicker.leftAnchor.constraint(equalTo: cancelButton.rightAnchor, constant: 10).isActive = true
        colorPicker.rightAnchor.constraint(equalTo: okButton.leftAnchor, constant: -10).isActive = true
        
        return view
    }
    
    // MARK: - WheelPickerDataSource methods
    
    
    func numberOfItems(_ wheelPicker: WheelPicker) -> Int {
        return self.colors.count
    }
    
    // MARK: - SCNNodeTransformer delegate implementations
    func getPosition() -> SCNVector3 {
        return SCNVector3Zero
    }
    
    func getNode() -> SCNNode {
        return SCNNode()
    }
    
    
}
