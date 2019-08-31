//
//  PlanetContextMenu.swift
//  Celeste
//
//  Created by Bruno Pastre on 23/08/19.
//  Copyright © 2019 Bruno Pastre. All rights reserved.
//

import Foundation
import SceneKit

protocol PlanetContextMenuDelegate{
    func onEdit()
    func onDelete(node: SCNNode)
    func onOrbit(source node: SCNNode)
    func onCopy()
    func onEnded()
}

class PlanetContextMenu: SCNNodeTransformer {
   
    var delegate: PlanetContextMenuDelegate?
    
    var latestSelection: UIView?
    
    lazy var editView = self.createIconOption(with: UIImage(named: "edit_icon"))
    lazy var orbitView = self.createIconOption(with: UIImage(named: "orbit_icon"))
    lazy var deleteView = self.createIconOption(with: UIImage(named: "delete_icon"))
    lazy var copyView = self.createIconOption(with: UIImage(named: "copy_icon"))
    
    func getPosition() -> SCNVector3 {
        return SCNVector3Zero
    }
    
    func getNode() -> SCNNode {
        let node = SCNNode()
        
        return node
    }
    
    func getEditOptionView() -> UIView{
        let viewSize: CGFloat = 50
        let view = UIView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = #colorLiteral(red: 0.4971322417, green: 0.1406211555, blue: 0.4916602969, alpha: 1)
        view.layer.borderColor = #colorLiteral(red: 0.6214697957, green: 0.3163355887, blue: 0.6099770069, alpha: 1)
        view.layer.borderWidth = 1
        view.layer.cornerRadius = viewSize / 2
        
        view.widthAnchor.constraint(equalToConstant: viewSize).isActive = true
        view.heightAnchor.constraint(equalToConstant: viewSize).isActive = true
        
        return view
    }
    
    
    func createIconOption(sized size: CGFloat = 50, with icon: UIImage?) -> UIView{
        let view = UIView()
        let imageView: UIImageView = {
            let imageView = UIImageView(image: icon)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            return imageView
        }()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageView)
        
        
        imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6).isActive = true
        imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.6).isActive = true
        
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        view.widthAnchor.constraint(equalToConstant: size).isActive = true
        view.heightAnchor.constraint(equalToConstant: size).isActive = true
        
        view.layer.borderWidth = 2
        view.layer.borderColor = #colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1)
        view.layer.cornerRadius = size/2
        
        view.backgroundColor = #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)
        
        return view
    }
    
    func getView()  -> UIView{
        let displayMenuView: UIView = {
            let view = UIView()
            
            view.translatesAutoresizingMaskIntoConstraints = false
            
            return view
        }()
        
        displayMenuView.addSubview(editView)
        displayMenuView.addSubview(orbitView)
        displayMenuView.addSubview(deleteView)
        displayMenuView.addSubview(copyView)
        
        editView.centerXAnchor.constraint(equalTo: displayMenuView.rightAnchor).isActive = true
        editView.centerYAnchor.constraint(equalTo: displayMenuView.topAnchor).isActive = true
        
        orbitView.centerXAnchor.constraint(equalTo: displayMenuView.leftAnchor).isActive = true
        orbitView.centerYAnchor.constraint(equalTo: displayMenuView.topAnchor).isActive = true
        
        deleteView.centerXAnchor.constraint(equalTo: displayMenuView.leftAnchor).isActive = true
        deleteView.centerYAnchor.constraint(equalTo: displayMenuView.bottomAnchor).isActive = true
        
        copyView.centerXAnchor.constraint(equalTo: displayMenuView.rightAnchor).isActive = true
        copyView.centerYAnchor.constraint(equalTo: displayMenuView.bottomAnchor).isActive = true
        
        return displayMenuView
        
    }
    
    func updateHighlightedIcon(at location: CGPoint?){
        if let point = location{
            let prev = self.latestSelection
            
            if point.x >= 0{
                if point.y >= 0{
                    // Bottom Right
                    self.latestSelection = copyView
                } else {
                    //  Top Right
                    self.latestSelection = editView
                }
            } else {
                if point.y >= 0{
                    // BL
                    self.latestSelection = deleteView
                } else {
                    // TL
                    self.latestSelection = orbitView
                }
            }
            
            if prev != latestSelection {
                 if let lastView = prev{
                    UIView.animate(withDuration: 0.3, animations: {
                        lastView.transform = .identity
                    }) { (_) in
                        lastView.transform = .identity
                    }
                    
                }
                
                UIView.animate(withDuration: 0.3, animations: {
                    self.latestSelection!.transform  = self.latestSelection!.transform.scaledBy(x: 1.5, y: 1.5)
                }) { (_) in
                    
                    let vib = UIImpactFeedbackGenerator()
                    vib.impactOccurred()

    //                self.latestSelection!.transform  = self.latestSelection!.transform.scaledBy(x: 1.5, y: 1.5)
                }
            }
        } else {
            
            if let lastView = self.latestSelection{
                UIView.animate(withDuration: 0.3, animations: {
                    lastView.transform = .identity
                }) { (_) in
                    lastView.transform = .identity
                    self.latestSelection = nil
                }
                
            }
        }
    }
    
    func onPanEnded(canceled: Bool, lastNode node: SCNNode){
        
        switch self.latestSelection{
            case self.editView:
                self.delegate?.onEdit()
            case self.copyView:
                self.delegate?.onCopy()
            case self.orbitView:
                self.delegate?.onOrbit(source: node)
            case self.deleteView:
                self.delegate?.onDelete(node: node)
            default:
                self.delegate?.onEnded()
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.latestSelection?.alpha = 0.1
            self.latestSelection?.transform = (self.latestSelection?.transform.scaledBy(x: 3, y: 3))!
        }) { (_) in
            self.latestSelection?.alpha = 1
            self.latestSelection?.transform = .identity
            self.latestSelection = nil
        }
        
    }
    
    static var instance = PlanetContextMenu()
    
    private init(){
    
    }
    

    
}
