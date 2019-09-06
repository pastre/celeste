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
    case planet = "Planet Mode"
}

enum ContextMenuOption:String, CaseIterable{
    case createPlanet = "Create Planet"
    
    case editPlanet = "Edit Planet"
}

protocol ContextMenuDelegate {
    func onNewPlanetUpdated(planetNode: SCNNode)
    func onNewPlanetTextureChanged(to texture: UIImage?)
    func onNewPlanetScaleChanged(to scale: Float)
    
    func onSave()
    func onCancel()
}

class CreatePlanetContextMenu: MenuView, SCNNodeTransformer, WheelPickerDelegate, WheelPickerDataSource{
    
    
    var currentModel: SCNNode? {
        didSet{
            self.delegate?.onNewPlanetUpdated(planetNode: self.getNode())
            self.isDirty = true
        }
    }
    
    
    var currentShape: ShapeName! = .sun {
        didSet{
            self.delegate?.onNewPlanetUpdated(planetNode: self.getNode())
            self.isDirty = true

        }
    }
    
    var currentRadius: Float?{
        didSet{
            self.delegate?.onNewPlanetScaleChanged(to: self.getScale())
            self.isDirty = true

        }
    }
    
    var currentColor: UIColor?
    var isDirty: Bool = false
    
    lazy var planetPicker: WheelPicker = {
        let picker = WheelPicker()
        
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.delegate = self
        picker.dataSource = self
        picker.style = .styleFlat
        
        return picker
    }()
    
    
    lazy var colorPicker: ColorSlider = {
        let slider = ColorSlider(orientation: .horizontal, previewSide: .top)
        
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.layer.borderColor = UIColor.clear.cgColor
        slider.addTarget(self, action: #selector(self.onColorChanged(_:)), for: .valueChanged)
        slider.previewView?.removeFromSuperview()
        
        return slider
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

    
    static let instance = CreatePlanetContextMenu()
    
    var delegate: ContextMenuDelegate?
    var mode: ContextMenuMode!
    var isHidden: Bool!
    var color: UIColor!
    
    
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
    
    
    override private init(){
        super.init()
        self.isHidden = true
        self.mode = .planet
        
        self.setDefaults()
    }
    
    func setDefaults(){
        self.currentColor = UIColor.white
        self.currentShape = ShapeName.allCases.first
        self.currentRadius = 2.5
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
        var model: SCNNode?
        if let color = self.currentColor{
            model = PlanetTextureProvider.instance.getPlanet(named: self.currentShape!.rawValue, color: color)
        }
        
//        guard let model = PlanetProvider.instance.getPlanet(named: "gasGiant", color: self.currentColor ?? .purple) else { return nil }
        guard let aModel = model else { return nil}
        node.addChildNode(aModel)
        aModel.worldPosition = SCNVector3(0, 0, 0 )
        
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
        
        let sizeSlider: UIView = {
            let view = UIView()
            
            view.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(slider)
            view.addSubview(plusHintLabel)
            view.addSubview(minusHintLabel)
            
            minusHintLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            minusHintLabel.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            
            plusHintLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            plusHintLabel.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            
            slider.leftAnchor.constraint(equalTo: minusHintLabel.rightAnchor, constant: 20).isActive  = true
            slider.rightAnchor.constraint(equalTo: plusHintLabel.leftAnchor, constant: -20).isActive = true
            slider.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            slider.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
            
            self.delegate?.onNewPlanetUpdated(planetNode: self.getNode())
            
            return view
        }()
        
        
        let planetPickerSelectedIndicator = self.getCircularView()
        
        let planetOption = self.getOption(with: self.planetPicker)
        let colorOption = self.getOption(with: self.colorPicker, heightMult: 0.2)
        let sizeOption = self.getOption(with: sizeSlider)
        
        view.addSubview(planetOption)
        view.addSubview(colorOption)
        view.addSubview(sizeOption)
        view.addSubview(planetPickerSelectedIndicator)
        
        
        planetOption.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        colorOption.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        sizeOption.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        planetOption.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.95).isActive = true
        colorOption.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.95).isActive = true
        sizeOption.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.95).isActive = true
        
        planetOption.heightAnchor.constraint(equalTo: planetOption.widthAnchor, multiplier: 1/5.8).isActive = true
        colorOption.heightAnchor.constraint(equalTo: planetOption.widthAnchor, multiplier: 1/5.8).isActive = true
        sizeOption.heightAnchor.constraint(equalTo: planetOption.widthAnchor, multiplier: 1/5.8).isActive = true
        
        planetOption.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        colorOption.topAnchor.constraint(equalTo: planetOption.bottomAnchor, constant: 20).isActive = true
        sizeOption.topAnchor.constraint(equalTo: colorOption.bottomAnchor, constant: 20).isActive = true
        
        planetPickerSelectedIndicator.centerXAnchor.constraint(equalTo: planetOption.centerXAnchor).isActive = true
        planetPickerSelectedIndicator.centerYAnchor.constraint(equalTo: planetOption.centerYAnchor).isActive = true
        
        
        return super.getAsMenu(with: view)
    }

    
    
    @objc func onColorChanged(_ slider: ColorSlider){
        let color = slider.color
        let texture = kTEXTURE_TO_IMAGE[self.currentShape.rawValue]
        let maskedTexture = texture?.tint(tintColor: color)
        self.delegate?.onNewPlanetTextureChanged(to: maskedTexture)
        self.currentColor = color
//        self.del
       
    }
    
    
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
        
        self.currentShape = ShapeName.allCases[index]
        self.currentModel = SCNNode(geometry: SCNSphere(radius: 0.2))
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
   
    override func onCancel() {
        self.delegate?.onCancel()
    }
    
    override func onSave() {
        self.delegate?.onSave()
    }
}


