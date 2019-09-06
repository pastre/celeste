//////
//////  PlanetDetailViewController.swift
//////  Celeste
//////
//////  Created by Bruno Pastre on 02/09/19.
//////  Copyright © 2019 Bruno Pastre. All rights reserved.
//////
////
////import SceneKit
////import UIKit
////
//class PlanetDetailViewController: UIViewController, UITextViewDelegate {
//
//    // MARK: - Constants
//    
//    static let PLACEHOLDER_COLOR = UIColor.gray
//    static let TEXT_COLOR = UIColor.black
//    static let NAME_PLACEHOLDER_TEXT = "Name"
//    static let DESCRIPTION_PLACEHOLDER_TEXT = "Description"
//
//    // MARK: - Atributes
//    var isShowingKeyboard: Bool = false
//    var sceneViewController: ViewController?
//    // MARK: - View declarations
//    
//    let contentView: UIView = {
//        let view = UIView()
////        view.name
////        view.description = "contentView"
//        view.backgroundColor = UIColor.white
//        view.translatesAutoresizingMaskIntoConstraints = false
//        
//        return view
//    }()
//    
//    
//    
//    // MARK: - ViewController methods
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        self.view.backgroundColor = UIColor.clear
//        
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.onTap(_:)))
//        
//        self.view.addGestureRecognizer(tapGesture)
//        
//        NotificationCenter.default.addObserver(self, selector: #selector(self.moveContentUp), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(self.moveContentDown), name: UIResponder.keyboardWillHideNotification, object: nil)
//        // Do any additional setup after loading the view.
//    }
//    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        
//    }
//    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        self.setupModalView()
//
//    }
//    
//    
//    func getButton(with name: String, action: Selector) -> UIButton{
//        let button = UIButton()
//        
//        button.addTarget(self, action: action, for: .touchDown)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.setTitle(name, for: .normal)
//        
//        return button
//    }
//    
//    func setupModalView(){
//        
//        let CONTENT_MARGIN: CGFloat = 10
//        
//        self.view.addSubview(self.contentView)
//        //        self.view.addSubview(self.nameTextView)
//        //        self.view.addSubview(self.descriptionTextView)
//        
//        let okButton: UIButton = {
//            let button = UIButton()
//            
//            button.translatesAutoresizingMaskIntoConstraints = false
//            button.addTarget(self, action: #selector(self.onOk(_:)), for: .touchDown)
//            button.setTitle("Ok", for: .normal)
//            button.tintColor = .blue
//            button.setTitleColor(.blue, for: .normal)
//            
//            return button
//        }()
//        
//        let cancelButton: UIButton = {
//            let button = UIButton()
//            
//            button.translatesAutoresizingMaskIntoConstraints = false
//            button.addTarget(self, action: #selector(self.onOk(_:)), for: .touchDown)
//            button.setTitle("Cancel", for: .normal)
//            button.tintColor = .blue
//            button.setTitleColor(.blue, for: .normal)
//            
//            return button
//        }()
////        let cancelButton = self.getButton(with: "Cancel", action: #selector(self.onCancel(_:)))
//        
//        self.contentView.layer.cornerRadius = 8
//        
//        
//        
//        self.contentView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
//        self.contentView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
//        self.contentView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.7).isActive = true
//        self.contentView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.4).isActive = true
//
//        self.contentView.addSubview(okButton)
//        self.contentView.addSubview(cancelButton)
//        
//        
////        buttonView.addSubview(cancelButton)
//        
//        let widthMult: CGFloat = 0.9
//        
//       
//        
//        okButton.rightAnchor.constraint(equalTo: self.nameTextView.rightAnchor).isActive = true
//        okButton.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -CONTENT_MARGIN / 2).isActive = true
//        okButton.widthAnchor.constraint(equalTo: self.contentView.widthAnchor, multiplier: 0.3).isActive = true
//        okButton.heightAnchor.constraint(equalTo: self.contentView.heightAnchor, multiplier: 0.1).isActive = true
//        
//        cancelButton.leftAnchor.constraint(equalTo: self.nameTextView.leftAnchor).isActive = true
//        cancelButton.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -CONTENT_MARGIN / 2 ).isActive = true
//        cancelButton.widthAnchor.constraint(equalTo: self.contentView.widthAnchor, multiplier: 0.3).isActive = true
//        cancelButton.heightAnchor.constraint(equalTo: self.contentView.heightAnchor, multiplier: 0.1).isActive = true
//        
//        
//        
////        okButton.widthAnchor.constraint(equalTo: buttonView.widthAnchor, multiplier: 1).isActive = true
////        okButton.heightAnchor.constraint(equalTo: buttonView.heightAnchor).isActive = true
////
////        cancelButton.rightAnchor.constraint(equalTo: buttonView.rightAnchor).isActive = true
////        cancelButton.centerYAnchor.constraint(equalTo: buttonView.centerYAnchor).isActive = true
////        cancelButton.widthAnchor.constraint(equalTo: buttonView.widthAnchor, multiplier: 0.3).isActive = true
////        cancelButton.heightAnchor.constraint(equalTo: buttonView.heightAnchor).isActive = true
////
////        self.nameTextView.bottomAnchor.constraint(equalTo: self.descriptionTextView.topAnchor, constant: CONTENT_MARGIN).isActive = true
//        
//        print("Modal is setup")
//        
//    }
//    
//    
//    // MARK: - TextView delegates
//    
//    func textViewDidBeginEditing(_ textView: UITextView) {
//        if textView.textColor == PlanetDetailViewController.PLACEHOLDER_COLOR && (textView.text == PlanetDetailViewController.NAME_PLACEHOLDER_TEXT || textView.text == PlanetDetailViewController.DESCRIPTION_PLACEHOLDER_TEXT){
//            textView.text = ""
//            textView.textColor = PlanetDetailViewController.TEXT_COLOR
//        }
//        
//        self.isShowingKeyboard = true
//    }
//    
//    func textViewDidEndEditing(_ textView: UITextView) {
//        if textView.text.isEmpty{
//            textView.textColor = PlanetDetailViewController.PLACEHOLDER_COLOR
//            textView.text = PlanetDetailViewController.DESCRIPTION_PLACEHOLDER_TEXT
//            if textView == self.nameTextView{
//                textView.text = PlanetDetailViewController.NAME_PLACEHOLDER_TEXT
//            }
//        }
//        
//        self.isShowingKeyboard = false
//    }
//    
//    // MARK: - Keyboard callbacks
//    
//    @objc func moveContentUp(_ notification: Notification){
//        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
//            let height = keyboardFrame.cgRectValue.height
//            self.contentView.transform = self.contentView.transform.translatedBy(x: 0, y: -height / 2)
//        }
//    }
//    
//    @objc func moveContentDown(_ notification: Notification){
//        self.contentView.transform = .identity
//    }
//    
//    // MARK: - Callbacks
//    @objc func onTap(_ gesture: UITapGestureRecognizer){
//    
//        if self.isShowingKeyboard{
//            self.view.endEditing(true)
//            return
//        }
//        
//        let location = gesture.location(in: self.view)
//        if self.contentView.frame.contains(location){
//            self.view.endEditing(true)
//        } else {
//            self.dismiss(animated: true, completion: nil)
//        }
//    }
//    
//    @objc func onOk(_ sender: UIButton){
//        guard let _ = self.sceneViewController?.sceneView.scene, let node = self.sceneViewController?.tappedNode, let radius = node.geometry?.boundingSphere.radius else { return }
//        
//        if let currentText = node.childNode(withName: "planetName", recursively: true){
//            currentText.removeFromParentNode()
//        }
//        
//        if self.nameTextView.text.isEmpty { return }
//        
//        let text = SCNText(string: self.nameTextView.text, extrusionDepth: 1)
//        let textNode = SCNNode(geometry: text)
//        textNode.name = "planetName"
//        
//        
//        node.addChildNode(textNode)
//        node.eulerAngles = SCNVector3(0, 0, 0)
//        
//        textNode.position = SCNVector3Zero
//        textNode.position = SCNVector3(0, -(radius + 0.2), 0)
//        textNode.scale = SCNVector3(0.01, 0.01, 0.01)
//        
//        self.dismiss(animated: true, completion: nil)
//    }
//    
//    @objc func onCancel(_ sender: UIButton){
//        self.dismiss(animated: true, completion: nil)
//    }
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//    }
//    */
//
//}
