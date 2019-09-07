//
//  ContextMenu.swift
//  Celeste
//
//  Created by Bruno Pastre on 16/08/19.
//  Copyright © 2019 Bruno Pastre. All rights reserved.
//

import Foundation
import SceneKit


protocol MenuDelegate{
    
    func onSave(_ star: Star?)
    func onCancel(_ star: Star?)
    func onDelete(star: Star)
}

protocol ContextMenuDelegate: MenuDelegate {
    func onNewPlanetUpdated(planetNode: SCNNode)
    func onNewPlanetTextureChanged(to texture: UIImage?)
    func onNewPlanetScaleChanged(to scale: Float)
    
    
}

class CreatePlanetContextMenu: MenuView, SCNNodeTransformer, WheelPickerDelegate, WheelPickerDataSource{
    
    
    
    let PLACEHOLDER_COLOR = UIColor.white.withAlphaComponent(0.5)
    let TEXT_COLOR = UIColor.white
    let NAME_PLACEHOLDER_TEXT = "Name"
    let DESCRIPTION_PLACEHOLDER_TEXT = "Description"
    
    var description: String
    
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
    
    var currentRadius: Float? = 1{
        didSet{
            self.delegate?.onNewPlanetScaleChanged(to: self.getScale())
            self.isDirty = true
        }
    }
    
    var currentParent: ViewController?
    var currentStar: Star?{
        didSet{
            guard let star = self.currentStar else { return }
            
            self.currentName = star.name
            self.currentDescription = star.planetDescription
            
            self.currentRadius = Float(star.scale!)  * 10
            self.slider.value = Float(star.scale!)  * 10
            
            self.currentColor = star.color
            self.currentShape = star.shapeName
        }
    }
    var currentName: String?
    var currentDescription: String?
    
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
    var isHidden: Bool!
    var color: UIColor!
    
    
    func getScale() -> Float{
        return (self.currentRadius ?? 1) * 0.1
    }
    
    override private init(){
        self.description = "asd"
        super.init()
        
        self.isHidden = true
        
        
        self.setDefaults()
    }
    
    func setDefaults(){
        self.currentColor = UIColor.white
        self.currentShape = ShapeName.allCases.first
        self.currentRadius = 2.5
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
        
        guard let aModel = model else { return nil}
        node.addChildNode(aModel)
        aModel.worldPosition = SCNVector3(0, 0, 0 )
        
        return model
    }
    
    func getNode() -> SCNNode {
        let node =  getNewPlanetNode() ?? SCNNode()
        
        node.scale = SCNVector3(x: self.getScale(), y: self.getScale(), z: self.getScale())
        
        return node
        
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
    
    func getNameDescriptionView() -> UIView {
        let view: UIView = {
            let view = UIView()
            
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            view.clipsToBounds = false
            view.layer.cornerRadius = 8
            
            return view
        }()
        
        
        let nameTextView: UITextView = {
            let textView = UITextView()
            //        textView.description = "nameTextView"
            textView.backgroundColor = UIColor.clear
            textView.translatesAutoresizingMaskIntoConstraints = false
            textView.layer.borderColor = UIColor.clear.cgColor
            textView.textAlignment = NSTextAlignment.left
            
            if self.currentStar == nil || self.currentName == nil{
                textView.textColor = PLACEHOLDER_COLOR
                textView.text = NAME_PLACEHOLDER_TEXT
            } else {
                textView.textColor = TEXT_COLOR
                textView.text = self.currentName
            }
            
            textView.font = UIFont(name: textView.font?.fontName  ?? "Helvetica", size: 26)
            
            
            return textView
        }()
        
        let descriptionTextView: UITextView = {
            let textView = UITextView()
            
            textView.backgroundColor = UIColor.clear
            textView.layer.borderColor = UIColor.clear.cgColor
            textView.translatesAutoresizingMaskIntoConstraints = false
            textView.font = UIFont(name: textView.font?.fontName  ?? "Helvetica", size: 16)
            
            if self.currentDescription == ""  || self.currentDescription == nil {
                textView.textColor = PLACEHOLDER_COLOR
                textView.text = DESCRIPTION_PLACEHOLDER_TEXT
            } else {
                textView.textColor = TEXT_COLOR
                textView.text = self.currentDescription
            }
            
            return textView
        }()
        
        nameTextView.delegate = self.currentParent
        descriptionTextView.delegate = self.currentParent
        
        nameTextView.tag = 1
        
        
        let widthMult: CGFloat = 0.9
        let CONTENT_MARGIN: CGFloat = 10
        
        view.addSubview(nameTextView)
        view.addSubview(descriptionTextView)

        descriptionTextView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        descriptionTextView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        descriptionTextView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: widthMult).isActive = true
        descriptionTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -CONTENT_MARGIN ).isActive = true
    
        nameTextView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        nameTextView.topAnchor.constraint(equalTo: view.topAnchor, constant: CONTENT_MARGIN).isActive = true
        nameTextView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: widthMult).isActive = true
        nameTextView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.18).isActive = true
        
        nameTextView.bottomAnchor.constraint(equalTo: descriptionTextView.topAnchor, constant: -0 ).isActive = true
        
        return view
    }
    
    
    func getPlanetModifierView() -> UIView {
        
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
        
        return view
    }
    
    func getView() -> UIView{
        let view = UIView()
        let planetModifierView = self.getPlanetModifierView()
        let planetNameView = self.getNameDescriptionView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(planetModifierView)
        view.addSubview(planetNameView)
        
        planetNameView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        planetNameView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        planetNameView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.95).isActive = true
        planetNameView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3).isActive = true
        
        planetModifierView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        planetModifierView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        planetModifierView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1).isActive = true
        planetModifierView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.308).isActive = true
        
        if let star = self.currentStar{
            self.planetPicker.scroll(to: ShapeName.allCases.firstIndex(of: star.shapeName) ?? 0, true)
        }
        
        return super.getAsMenu(with: view, hasDelete: self.currentStar != nil)
    }

    @objc func onColorChanged(_ slider: ColorSlider){
        let color = slider.color
        let texture = kTEXTURE_TO_IMAGE[self.currentShape.rawValue]
        let maskedTexture = texture?.tint(tintColor: color)
        self.delegate?.onNewPlanetTextureChanged(to: maskedTexture)
        self.currentColor = color
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
        self.delegate?.onCancel(self.currentStar)
        self.currentStar = nil
    }
    
    override func onSave() {
        self.delegate?.onSave(self.currentStar)
        self.currentStar = nil
    }
    
    override func onDelete() {
        self.delegate?.onDelete(star: self.currentStar!)
        self.currentStar = nil
    }

}


