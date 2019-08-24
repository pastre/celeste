//
//  ContextMenu.swift
//  Celeste
//
//  Created by Bruno Pastre on 16/08/19.
//  Copyright © 2019 Bruno Pastre. All rights reserved.
//

import Foundation
import SceneKit

enum ContextMenuMode:String, CaseIterable{
    case galaxy = "Galaxy Mode"
    case planet = "Planet  Mode"
}

enum ContextMenuOption:String, CaseIterable{
    case createPlanet = "Create Planet"
    
    case editPlanet = "Edit Planet"
}

protocol ContextMenuDelegate {
    func onOption(option: ContextMenuOption)
}

class ContextMenu: SCNNodeTransformer{
    
    
    lazy var picker3: WheelPicker = {
        let picker = WheelPicker()
        
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.delegate = self
        picker.dataSource = self
        
        return picker
    }()
    
    
    lazy var picker1: WheelPicker = {
        let picker = WheelPicker()
        
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.delegate = self
        picker.dataSource = self
        
        return picker
    }()

    
    let colors: [UIColor] = [#colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 1), #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1), #colorLiteral(red: 0.1921568662, green: 0.007843137719, blue: 0.09019608051, alpha: 1), #colorLiteral(red: 0.3176470697, green: 0.07450980693, blue: 0.02745098062, alpha: 1), #colorLiteral(red: 0.3098039329, green: 0.2039215714, blue: 0.03921568766, alpha: 1), #colorLiteral(red: 0.1294117719, green: 0.2156862766, blue: 0.06666667014, alpha: 1), #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1), #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1), #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1), ]
    
    static let instance = ContextMenu()
    var mode: ContextMenuMode!
    var isHidden: Bool!
    var color: UIColor!
    
    func setGalaxyMode(){
        
    }
    
    func setPlanetMode(){
        
    }
    
    func getOptions() -> [ContextMenuOption] {
        switch self.mode {
        
        case .galaxy?:
            return [.createPlanet]
        case .planet?:
            return [.editPlanet]
        default: break
        
        }
        
        return []
    }
    
    
    private init(){
        self.isHidden = true
        self.mode = .planet
    }
    
    func openContextMenu(mode: ContextMenuMode){
        switch mode {
        case .galaxy:
            //TODO
            self.color = #colorLiteral(red: 0.02779892646, green: 0.4870637059, blue: 0.4917319417, alpha: 1)
            
        case .planet:
            // TODO
            self.color = #colorLiteral(red: 0.4971322417, green: 0.1406211555, blue: 0.4916602969, alpha: 1)
            
        }
    }
    
    func onSelected(option: SCNNode, target: SCNNode){
        
    }
    
    func buildOption(option: ContextMenuOption) -> SCNNode{
        let ret = SCNNode()
        let text = SCNText(string: option.rawValue, extrusionDepth: 0.01)
        
        let background = SCNPlane(width: 0.1, height: 0.1)
        let bgMaterial = SCNMaterial()
        
        let backgroundNode = SCNNode(geometry: background)
        let labelNode = SCNNode(geometry: text)
        
        bgMaterial.isDoubleSided = true
        bgMaterial.writesToDepthBuffer = false
        bgMaterial.diffuse.contents = UIColor.black
        
        
        
        background.cornerRadius = 50
        background.firstMaterial = bgMaterial
        
        ret.addChildNode(backgroundNode)
        ret.addChildNode(labelNode)
        
        labelNode.scale = SCNVector3(0.008, 0.008, 0.008)
        
        let textHeight = (text.boundingBox.max - text.boundingBox.min).y * 0.008
        print("textHeight", textHeight)
        labelNode.position = SCNVector3(0.01, 0, 0)
        backgroundNode.position = SCNVector3(0, -textHeight, 0)
        backgroundNode.transform = SCNMatrix4Rotate(backgroundNode.transform, -Float.pi/2, 0, 0, 1)
        
        
        
        ret.name = "Opcao: \(option.rawValue)"
        return ret
    }
    
    func buildGalaxyMenu() -> SCNNode{
        let rootNode = SCNNode()
        let rotatedNode = SCNNode()
        let options = self.getOptions()
        
        var yInc: Double = 0
        
        for option in options{
            let optionNode = buildOption(option: option)
            optionNode.localTranslate(by: SCNVector3(0, yInc, 0))
            rotatedNode.addChildNode(optionNode)
            yInc += 0.3
        }
        
        rotatedNode.transform = SCNMatrix4Rotate(rotatedNode.transform, Float.pi, 0, 1, 0)
        rootNode.addChildNode(rotatedNode)
        rootNode.name = "Menu de Contexto"
        
        return rootNode
    }
    
    // MARK: - SCNNodeTransformDelegate methods
    
    func getPosition() -> SCNVector3 {
        return SCNVector3Zero
    }
    
    
    func getNode() -> SCNNode {
        return self.buildGalaxyMenu()
        
        //        let planeGeometry = SCNPlane(width: 0.2, height: 0.2)
        let planeGeometry = SCNCone(topRadius: 0.3, bottomRadius: 0.3, height: 0)
        let material = SCNMaterial()

        material.diffuse.contents = self.color
        
        material.isDoubleSided = true
        material.writesToDepthBuffer = false
        //        material.blendMode = .screen
        
        let planeNode = SCNNode(geometry: planeGeometry)
        planeNode.geometry?.firstMaterial = material
        
        
        return planeNode
    }
}

extension ContextMenu{
    
    
    
    func getSelector() -> UIView{
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.onTap(_:)))
        
        let imageView: UIImageView = {
            let img = UIImage(named: "planetContextMenuBg")
            let view = UIImageView(image: img)
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        
//        let picker2: WheelPicker = {
//            let picker = WheelPicker()
//
//            picker.translatesAutoresizingMaskIntoConstraints = false
//            picker.delegate = self
//            picker.dataSource = self
//
//            return picker
//        }()
        
        
        let slider: UISlider = {
           let ret = UISlider()
            ret.translatesAutoresizingMaskIntoConstraints = false
            ret.minimumValue = 1
            ret.maximumValue = 5
            ret.value = 3
            return ret
        }()
        
        
        view.addSubview(imageView)
        view.addSubview(picker1)
        view.addSubview(slider)
        view.addSubview(picker3)
        
        imageView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 293/414).isActive = true
        
        picker3.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        picker3.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        picker3.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -110).isActive = true
        picker3.heightAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 0.25).isActive = true

//
        slider.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        slider.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        slider.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30).isActive = true
        slider.heightAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 0.25).isActive = true
//        slider.widthAnchor.cons
        
        picker1.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        picker1.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        picker1.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -200).isActive = true
        picker1.heightAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 0.25).isActive = true
        
        gesture.name =  "ContextMenuGesture"
        view.addGestureRecognizer(gesture)
        
        return view
    }
    
    func getView() -> UIView{
        let view = UIView()
        
//        let firstLayer = self.
        
        return self.getSelector()
    }
    
    @objc func onTap(_ sender: UITapGestureRecognizer){
            print("caixa")
    }
    
}

extension ContextMenu: WheelPickerDelegate, WheelPickerDataSource{
    func numberOfItems(_ wheelPicker: WheelPicker) -> Int {
        if wheelPicker == self.picker1{
            return 100
        }
        
        return self.colors.count
    }
    
    
    func imageFor(_ wheelPicker: WheelPicker, at index: Int) -> UIImage {
        if wheelPicker == self.picker1{
            let rand = Int.random(in: 0...5)
            let img = UIImage(named: "planet\(rand)") ?? UIImage(named: "planet0")!
            
            return resizeImage(image: img, newWidth: 50) ?? UIImage(named: "planet1")!
        }
        
        guard let image = self.getImage(for: self.colors[index]) else {
            return UIImage(named: "add")!
        }
        
        return image
        
    }
    
    func getImage(for color: UIColor) -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 50, height: 50), false, 0.0)
        
        let context =  UIGraphicsGetCurrentContext()!
        
        context.saveGState()
        context.setFillColor(color.cgColor)
        context.fillEllipse(in: CGRect(x: 0, y: 0, width: 50, height: 50))
        
        context.restoreGState()
        
        let ret = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return ret
    }
    
    func wheelPicker(_ wheelPicker: WheelPicker, configureLabel label: UILabel, at index: Int) {
        label.textColor = UIColor.cyan
    }
   
}



func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage? {
    
    let scale = newWidth / image.size.width
    let newHeight = image.size.height * scale
    
    UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
    image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage
}

extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}

