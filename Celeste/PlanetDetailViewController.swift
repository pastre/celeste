//
//  PlanetDetailViewController.swift
//  Celeste
//
//  Created by Bruno Pastre on 02/09/19.
//  Copyright © 2019 Bruno Pastre. All rights reserved.
//

import UIKit

class PlanetDetailViewController: UIViewController, UITextViewDelegate {

    // MARK: - Constants
    
    static let PLACEHOLDER_COLOR = UIColor.gray
    static let TEXT_COLOR = UIColor.black
    static let NAME_PLACEHOLDER_TEXT = "Name"
    static let DESCRIPTION_PLACEHOLDER_TEXT = "Description"

    // MARK: - Atributes
    var isShowingKeyboard: Bool = false
    
    // MARK: - View declarations
    
    let contentView: UIView = {
        let view = UIView()
//        view.name
//        view.description = "contentView"
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    let nameTextView: UITextView = {
        let textView = UITextView()
//        textView.description = "nameTextView"
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 4
        textView.textAlignment = NSTextAlignment.left
        
        textView.textColor = PlanetDetailViewController.PLACEHOLDER_COLOR
        textView.text = PlanetDetailViewController.NAME_PLACEHOLDER_TEXT
        
        return textView
    }()
    
    let descriptionTextView: UITextView = {
        let textView = UITextView()
        
        textView.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 4
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        textView.textColor = PlanetDetailViewController.PLACEHOLDER_COLOR
        textView.text = PlanetDetailViewController.DESCRIPTION_PLACEHOLDER_TEXT
        
        return textView
    }()
    
    
    
    // MARK: - ViewController methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.nameTextView.delegate = self
        self.descriptionTextView.delegate = self
        self.view.backgroundColor = UIColor.clear
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.onTap(_:)))
        
        self.view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.moveContentUp), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.moveContentDown), name: UIResponder.keyboardWillHideNotification, object: nil)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupModalView()

    }
    
    
    func getButton(with name: String, action: Selector) -> UIButton{
        let button = UIButton()
        
        button.addTarget(self, action: action, for: .touchDown)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(name, for: .normal)
        
        return button
    }
    
    func setupModalView(){
        
        let CONTENT_MARGIN: CGFloat = 10
        
        self.view.addSubview(self.contentView)
        //        self.view.addSubview(self.nameTextView)
        //        self.view.addSubview(self.descriptionTextView)
        
        let okButton: UIButton = {
            let button = UIButton()
            
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(self, action: #selector(self.onOk(_:)), for: .touchDown)
            button.setTitle("Ok", for: .normal)
            button.tintColor = .blue
            button.setTitleColor(.blue, for: .normal)
            
            return button
        }()
        
        let cancelButton: UIButton = {
            let button = UIButton()
            
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(self, action: #selector(self.onOk(_:)), for: .touchDown)
            button.setTitle("Cancel", for: .normal)
            button.tintColor = .blue
            button.setTitleColor(.blue, for: .normal)
            
            return button
        }()
//        let cancelButton = self.getButton(with: "Cancel", action: #selector(self.onCancel(_:)))
        
        self.contentView.layer.cornerRadius = 8
        
        
        
        self.contentView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.contentView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        self.contentView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.7).isActive = true
        self.contentView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.4).isActive = true

        
        self.contentView.addSubview(self.nameTextView)
        self.contentView.addSubview(self.descriptionTextView)
        self.contentView.addSubview(okButton)
        self.contentView.addSubview(cancelButton)
        
        
//        buttonView.addSubview(cancelButton)
        
        let widthMult: CGFloat = 0.9
        
        self.descriptionTextView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor).isActive = true
        self.descriptionTextView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
        self.descriptionTextView.widthAnchor.constraint(equalTo: self.contentView.widthAnchor, multiplier: widthMult).isActive = true
        
//        self.descriptionTextView.topAnchor.constraint(equalTo: self.nameTextView.bottomAnchor, constant: CONTENT_MARGIN / 1).isActive = true
        self.descriptionTextView.bottomAnchor.constraint(equalTo: okButton.topAnchor, constant: -CONTENT_MARGIN ).isActive = true

        self.nameTextView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor).isActive = true
        self.nameTextView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: CONTENT_MARGIN).isActive = true
        self.nameTextView.widthAnchor.constraint(equalTo: self.contentView.widthAnchor, multiplier: widthMult).isActive = true
        self.nameTextView.heightAnchor.constraint(equalTo: self.contentView.heightAnchor, multiplier: 0.1).isActive = true
        
        self.nameTextView.bottomAnchor.constraint(equalTo: descriptionTextView.topAnchor, constant: -CONTENT_MARGIN ).isActive = true
        
        okButton.rightAnchor.constraint(equalTo: self.nameTextView.rightAnchor).isActive = true
        okButton.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -CONTENT_MARGIN / 2).isActive = true
        okButton.widthAnchor.constraint(equalTo: self.contentView.widthAnchor, multiplier: 0.3).isActive = true
        okButton.heightAnchor.constraint(equalTo: self.contentView.heightAnchor, multiplier: 0.1).isActive = true
        
        cancelButton.leftAnchor.constraint(equalTo: self.nameTextView.leftAnchor).isActive = true
        cancelButton.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -CONTENT_MARGIN / 2 ).isActive = true
        cancelButton.widthAnchor.constraint(equalTo: self.contentView.widthAnchor, multiplier: 0.3).isActive = true
        cancelButton.heightAnchor.constraint(equalTo: self.contentView.heightAnchor, multiplier: 0.1).isActive = true
        
        
        
//        okButton.widthAnchor.constraint(equalTo: buttonView.widthAnchor, multiplier: 1).isActive = true
//        okButton.heightAnchor.constraint(equalTo: buttonView.heightAnchor).isActive = true
//
//        cancelButton.rightAnchor.constraint(equalTo: buttonView.rightAnchor).isActive = true
//        cancelButton.centerYAnchor.constraint(equalTo: buttonView.centerYAnchor).isActive = true
//        cancelButton.widthAnchor.constraint(equalTo: buttonView.widthAnchor, multiplier: 0.3).isActive = true
//        cancelButton.heightAnchor.constraint(equalTo: buttonView.heightAnchor).isActive = true
//
//        self.nameTextView.bottomAnchor.constraint(equalTo: self.descriptionTextView.topAnchor, constant: CONTENT_MARGIN).isActive = true
        
        print("Modal is setup")
        
    }
    
    
    // MARK: - TextView delegates
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == PlanetDetailViewController.PLACEHOLDER_COLOR && (textView.text == PlanetDetailViewController.NAME_PLACEHOLDER_TEXT || textView.text == PlanetDetailViewController.DESCRIPTION_PLACEHOLDER_TEXT){
            textView.text = ""
            textView.textColor = PlanetDetailViewController.TEXT_COLOR
        }
        
        self.isShowingKeyboard = true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty{
            textView.textColor = PlanetDetailViewController.PLACEHOLDER_COLOR
            textView.text = PlanetDetailViewController.DESCRIPTION_PLACEHOLDER_TEXT
            if textView == self.nameTextView{
                textView.text = PlanetDetailViewController.NAME_PLACEHOLDER_TEXT
            }
        }
        
        self.isShowingKeyboard = false
    }
    
    // MARK: - Keyboard callbacks
    
    @objc func moveContentUp(_ notification: Notification){
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let height = keyboardFrame.cgRectValue.height
            self.contentView.transform = self.contentView.transform.translatedBy(x: 0, y: -height / 2)
        }
    }
    
    @objc func moveContentDown(_ notification: Notification){
        self.contentView.transform = .identity
    }
    
    // MARK: - Callbacks
    @objc func onTap(_ gesture: UITapGestureRecognizer){
    
        if self.isShowingKeyboard{
            self.view.endEditing(true)
            return
        }
        
        let location = gesture.location(in: self.view)
        if self.contentView.frame.contains(location){
            self.view.endEditing(true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func onOk(_ sender: UIButton){
        
    }
    
    @objc func onCancel(_ sender: UIButton){
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
