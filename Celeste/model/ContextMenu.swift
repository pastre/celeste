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
    func onNewPlanetUpdated(planetNode: SCNNode)
    func onNewPlanetScaleChanged(to scale: Float)
}

class ContextMenu: SCNNodeTransformer{
    
    
    var currentModel: SCNNode? {
        didSet{
            self.delegate?.onNewPlanetUpdated(planetNode: self.getNode())
        }
    }
    
    
    var currentShape: ShapeName! = .sun {
        didSet{
            self.delegate?.onNewPlanetUpdated(planetNode: self.getNode())
        }
    }
    
    var currentColor: ShapeColor? = .blue {
        didSet{
            self.delegate?.onNewPlanetUpdated(planetNode: self.getNode())
        }
    }
    
    var currentRadius: Float? {
        didSet{
            self.delegate?.onNewPlanetScaleChanged(to: self.getScale())
        }
    }
    
    lazy var planetPicker: WheelPicker = {
        let picker = WheelPicker()
        
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.delegate = self
        picker.dataSource = self
        picker.style = .styleFlat
        
        return picker
    }()
    
    
    lazy var colorPicker: WheelPicker = {
        let picker = WheelPicker()
        
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.delegate = self
        picker.dataSource = self
        picker.style = .styleFlat
        
        return picker
    }()
    
    
    
    lazy var slider: UISlider = {
        let ret = UISlider()
        
        ret.translatesAutoresizingMaskIntoConstraints = false
        ret.minimumValue = 1
        ret.maximumValue = 5
        ret.value = 3
        ret.addTarget(self, action: #selector(self.onSliderChanged(_:)), for: .valueChanged)
        
        return ret
    }()

    
    static let instance = ContextMenu()
    
    var delegate: ContextMenuDelegate?
    var mode: ContextMenuMode!
    var isHidden: Bool!
    var color: UIColor!
    
    func setGalaxyMode(){
        
    }
    
    func setPlanetMode(){
        
    }
    
    func getScale() -> Float{
        return (self.currentRadius ?? 1) * 0.1
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
    
    func getNewPlanetNode() -> SCNNode? {
        let node = SCNNode()
        
        guard let model = PlanetProvider.instance.getPlanet(with: self.currentShape, color: self.currentColor ?? .purple) else { return nil  }
//        guard let model = PlanetProvider.instance.getPlanet(named: "gasGiant", color: self.currentColor ?? .purple) else { return nil }
        
        node.addChildNode(model)
        model.worldPosition = SCNVector3(0, 0, 0 )
        
//        let mult = (self.currentRadius ?? 1) * 0.1
//        model.scale = SCNVector3(x: mult, y: mult, z: mult)
        
        return model
    }
    
    func getNode() -> SCNNode {
        let node =  getNewPlanetNode() ?? SCNNode()
        
        node.scale = SCNVector3(x: self.getScale(), y: self.getScale(), z: self.getScale())
        
        return node
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
    
    @objc func onSliderChanged(_ sender: UISlider){
        self.currentRadius = sender.value
    }
}

extension ContextMenu{
    
    func getCircularView() -> UIView{
        let view = UIView()
        let viewWidth: CGFloat = 60
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.widthAnchor.constraint(equalToConstant: viewWidth).isActive = true
        view.heightAnchor.constraint(equalToConstant: viewWidth).isActive = true
        
        view.layer.cornerRadius = viewWidth / 2
        view.backgroundColor = UIColor.clear
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.cgColor
        
        return view
    }
    
    func getView() -> UIView{
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.onTap(_:)))
        
        let bgImageView: UIImageView = {
            let view = UIImageView(image: UIImage(named: "planetContextMenuBg"))
            
            view.translatesAutoresizingMaskIntoConstraints = false
            
            return view
        }()
        
        let plusHintLabel: UILabel = {
            let label = UILabel()
            
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = "+"
            label.textColor = UIColor.white
            
            return label
        }()
        
        let minusHintLabel: UILabel = {
            let label = UILabel()
            
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = "-"
            label.textColor = UIColor.white
            
            return label
        }()
        
        let planetPickerSelectedIndicator = self.getCircularView()
        let colorPickerSelectedIndicator = self.getCircularView()
        
        view.addSubview(bgImageView)
        view.addSubview(colorPicker)
        view.addSubview(slider)
        view.addSubview(planetPicker)
        view.addSubview(plusHintLabel)
        view.addSubview(minusHintLabel)
        view.addSubview(planetPickerSelectedIndicator)
        view.addSubview(colorPickerSelectedIndicator)
        
        bgImageView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        bgImageView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        bgImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        bgImageView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 293/414).isActive = true
        
        self.colorPicker.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        self.colorPicker.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        self.colorPicker.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -110).isActive = true
        self.colorPicker.heightAnchor.constraint(equalTo: bgImageView.heightAnchor, multiplier: 0.25).isActive = true

        self.slider.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self.slider.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30).isActive = true
        self.slider.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
        self.slider.heightAnchor.constraint(equalTo: bgImageView.heightAnchor, multiplier: 0.25).isActive = true
        
        self.planetPicker.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        self.planetPicker.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        self.planetPicker.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -200).isActive = true
        self.planetPicker.heightAnchor.constraint(equalTo: bgImageView.heightAnchor, multiplier: 0.25).isActive = true
        
        plusHintLabel.centerYAnchor.constraint(equalTo: slider.centerYAnchor).isActive = true
        plusHintLabel.leftAnchor.constraint(equalTo: slider.rightAnchor, constant: 10).isActive = true
        plusHintLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.05).isActive = true
        plusHintLabel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.05 ).isActive = true
        
        minusHintLabel.centerYAnchor.constraint(equalTo: slider.centerYAnchor).isActive = true
        minusHintLabel.rightAnchor.constraint(equalTo: slider.leftAnchor, constant: -10).isActive = true
        minusHintLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.05).isActive = true
        minusHintLabel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.05 ).isActive = true
        
        planetPickerSelectedIndicator.centerXAnchor.constraint(equalTo: planetPicker.centerXAnchor).isActive = true
        planetPickerSelectedIndicator.centerYAnchor.constraint(equalTo: planetPicker.centerYAnchor).isActive = true
        
        colorPickerSelectedIndicator.centerXAnchor.constraint(equalTo: colorPicker.centerXAnchor).isActive = true
        colorPickerSelectedIndicator.centerYAnchor.constraint(equalTo: colorPicker.centerYAnchor).isActive = true
        
        
        gesture.name =  "ContextMenuGesture"
        view.addGestureRecognizer(gesture)
        
        view.bringSubviewToFront(planetPicker)
        view.bringSubviewToFront(colorPicker)
        
        slider.tintColor = UIColor.gray
        slider.maximumTrackTintColor = UIColor.gray
        
        return view
    }
    
    
    @objc func onTap(_ sender: UITapGestureRecognizer){
            print("caixa")
    }
    
    
    
}

extension ContextMenu: WheelPickerDelegate, WheelPickerDataSource{
    
    
    
    func numberOfItems(_ wheelPicker: WheelPicker) -> Int {
        if wheelPicker == self.planetPicker{
            return ShapeName.allCases.count
        }
        
        return ShapeColor.allCases.count
    }
    
    func imageFor(_ wheelPicker: WheelPicker, at index: Int) -> UIImage {
        if wheelPicker == self.planetPicker{
            let imgIcon = "\(ShapeName.allCases[index])_icon"
            let img = UIImage(named: imgIcon)
            print("Image is", imgIcon)
            return resizeImage(image: img!, newWidth: 50) ?? UIImage(named: "1")!
        }
        
        let colors: [UIColor] = [#colorLiteral(red: 0.1725490196, green: 0.6039215686, blue: 1, alpha: 1), #colorLiteral(red: 0.4392156863, green: 0.7529411765, blue: 0.3098039216, alpha: 1), #colorLiteral(red: 0.9921568627, green: 0.7960784314, blue: 0.3568627451, alpha: 1), #colorLiteral(red: 0.9882352941, green: 0.5490196078, blue: 0.1960784314, alpha: 1), #colorLiteral(red: 0.9333333333, green: 0.2862745098, blue: 0.3411764706, alpha: 1), #colorLiteral(red: 0.7882352941, green: 0.03529411765, blue: 0.4352941176, alpha: 1), #colorLiteral(red: 0.631372549, green: 0.03921568627, blue: 0.7294117647, alpha: 1) ]
        
        guard let image = self.getImage(for: colors[index]) else {
            return UIImage(named: "add")!
        }
        
        return image
        
    }
    
    func wheelPicker(_ wheelPicker: WheelPicker, didSelectItemAt index: Int) {
        if wheelPicker == self.colorPicker{
            self.currentColor = ShapeColor.allCases[index]
        }else{
            self.currentShape = ShapeName.allCases[index]
            self.currentModel = SCNNode(geometry: SCNSphere(radius: 0.2))
        }
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


