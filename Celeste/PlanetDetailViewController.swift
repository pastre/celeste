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
        textView.layer.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        
        textView.textColor = PlanetDetailViewController.PLACEHOLDER_COLOR
        textView.text = PlanetDetailViewController.NAME_PLACEHOLDER_TEXT
        
        return textView
    }()
    
    let descriptionTextView: UITextView = {
        let textView = UITextView()
        
        textView.layer.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
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
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setupModalView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    
    func setupModalView(){
        
        let CONTENT_MARGIN: CGFloat = 20
        
        self.view.addSubview(self.contentView)
        //        self.view.addSubview(self.nameTextView)
        //        self.view.addSubview(self.descriptionTextView)
        
        
        self.contentView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.contentView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        self.contentView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8).isActive = true
        self.contentView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.6).isActive = true

        
        self.contentView.addSubview(self.nameTextView)
        self.contentView.addSubview(self.descriptionTextView)
        
        
        self.descriptionTextView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor).isActive = true
        self.descriptionTextView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -CONTENT_MARGIN).isActive = true
        self.descriptionTextView.widthAnchor.constraint(equalTo: self.contentView.widthAnchor, multiplier: 0.8).isActive = true
        self.descriptionTextView.heightAnchor.constraint(equalTo: self.contentView.heightAnchor, multiplier: 0.7).isActive = true
//
        self.nameTextView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor).isActive = true
        self.nameTextView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: CONTENT_MARGIN).isActive = true
        self.nameTextView.widthAnchor.constraint(equalTo: self.contentView.widthAnchor, multiplier: 0.8).isActive = true
        self.nameTextView.heightAnchor.constraint(equalTo: self.contentView.heightAnchor, multiplier: 0.1).isActive = true
        
        
        
//        self.nameTextView.bottomAnchor.constraint(equalTo: self.descriptionTextView.topAnchor, constant: CONTENT_MARGIN).isActive = true
        
    }
    
    
    // MARK: - TextView delegates
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == PlanetDetailViewController.PLACEHOLDER_COLOR && (textView.text == PlanetDetailViewController.NAME_PLACEHOLDER_TEXT || textView.text == PlanetDetailViewController.DESCRIPTION_PLACEHOLDER_TEXT){
            textView.text = ""
            textView.textColor = PlanetDetailViewController.TEXT_COLOR
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty{
            textView.textColor = PlanetDetailViewController.PLACEHOLDER_COLOR
            textView.text = PlanetDetailViewController.DESCRIPTION_PLACEHOLDER_TEXT
            if textView == self.nameTextView{
                textView.text = PlanetDetailViewController.NAME_PLACEHOLDER_TEXT
            }
        }
    }
    
    @objc func onTap(_ gesture: UITapGestureRecognizer){
        let location = gesture.location(in: self.view)
        if self.contentView.frame.contains(location){
            self.view.endEditing(true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
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
