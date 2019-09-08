//
//  Extensions.swift
//  Celeste
//
//  Created by Bruno Pastre on 25/08/19.
//  Copyright © 2019 Bruno Pastre. All rights reserved.
//

import Foundation
import SceneKit




extension CGFloat{
    static func + (_ a: Float, _ b: CGFloat) -> CGFloat{
        return CGFloat(a) + b
    }
}

extension UIColor {
    
    class func randomColor(randomAlpha randomApha:Bool = false)->UIColor{
        
        let redValue = CGFloat(arc4random_uniform(255)) / 255.0;
        let greenValue = CGFloat(arc4random_uniform(255)) / 255.0;
        let blueValue = CGFloat(arc4random_uniform(255)) / 255.0;
        let alphaValue = randomApha ? CGFloat(arc4random_uniform(255)) / 255.0 : 1;
        
        return UIColor(red: redValue, green: greenValue, blue: blueValue, alpha: alphaValue)
        
    }
}

extension UIImage {
    func resizeImage(size: CGSize) -> UIImage? {
        
        UIGraphicsBeginImageContext(CGSize(width: size.width, height: size.height))
        self.draw(in: CGRect(x: 0, y: 5, width: size.width, height: size.height-5))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    
    //by lynfogeek on github
    func tint(tintColor: UIColor) -> UIImage {
        
        return modifiedImage { context, rect in
            // draw black background - workaround to preserve color of partially transparent pixels
            context.setBlendMode(.normal)
            UIColor.black.setFill()
            context.fill(rect)
            
            // draw original image
            context.setBlendMode(.normal)
            context.draw(self.cgImage!, in: rect)
            
            // tint image (loosing alpha) - the luminosity of the original image is preserved
            context.setBlendMode(.multiply)
            tintColor.setFill()
            context.fill(rect)
            
            // mask by alpha values of original image
            context.setBlendMode(.destinationIn)
            context.draw(self.cgImage!, in: rect)
        }
    }
    
    
    func fillAlpha(fillColor: UIColor) -> UIImage {
        
        return modifiedImage { context, rect in
            // draw tint color
            context.setBlendMode(.normal)
            fillColor.setFill()
            context.fill(rect)
            //            context.fillCGContextFillRect(context, rect)
            
            // mask by alpha values of original image
            context.setBlendMode(.destinationIn)
            context.draw(self.cgImage!, in: rect)
        }
    }
    
    private func modifiedImage( draw: (CGContext, CGRect) -> ()) -> UIImage {
        
        // using scale correctly preserves retina images
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let context: CGContext! = UIGraphicsGetCurrentContext()
        assert(context != nil)
        
        // correctly rotate image
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        
        draw(context, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
}

func rotateHue(with sourceCore: UIImage, rotatedByHue deltaHueRadians: CGFloat) -> UIImage {
    
    let rawImage = sourceCore
    let sourceCore = CIImage(cgImage: rawImage.cgImage!)
    
    // Apply a CIHueAdjust filter
    let hueAdjust = CIFilter(name: "CIHueAdjust")
    hueAdjust?.setDefaults()
    hueAdjust?.setValue(sourceCore, forKey: "inputImage")
    hueAdjust?.setValue(deltaHueRadians, forKey: "inputAngle")
    let resultCore = hueAdjust?.value(forKey: "outputImage") as? CIImage
    // Convert the filter output back into a UIImage.
    let context = CIContext(options: nil)
    let resultRef = context.createCGImage(resultCore!, from: (resultCore?.extent)!)
    let result = UIImage(cgImage: resultRef!)
    //CGImageRelease(resultRef)
    return result
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


extension CGPoint{
    static func - (_ a: CGPoint, _ b: CGPoint) -> CGPoint{
        return CGPoint(x: a.x - b.x, y: a.y - b.y)
    }
}

extension SCNGeometry {
    class func line(from vector1: SCNVector3, to vector2: SCNVector3) -> SCNGeometry {
        let indices: [Int32] = [0, 1]
        let source = SCNGeometrySource(vertices: [vector1, vector2])
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        return SCNGeometry(sources: [source], elements: [element])
    }
}


extension UITouch {
    /// Calculate the "progress" of a touch in a view with respect to an orientation.
    /// - parameter view: The view to be used as a frame of reference.
    /// - parameter orientation: The orientation with which to determine the return value.
    /// - returns: The percent across the `view` that the receiver's location is, relative to the `orientation`. Constrained to (0, 1).
    func progress(in view: UIView, withOrientation orientation: Orientation) -> CGFloat {
        let touchLocation = self.location(in: view)
        var progress: CGFloat = 0
        
        switch orientation {
        case .vertical:
            progress = touchLocation.y / view.bounds.height
        case .horizontal:
            progress = touchLocation.x / view.bounds.width
        }
        
        return (0.0..<1.0).clamp(progress)
    }
}


extension Range {
    /// Constrain a `Bound` value by `self`.
    /// Equivalent to max(lowerBound, min(upperBound, value)).
    /// - parameter value: The value to be clamped.
    func clamp(_ value: Bound) -> Bound {
        return lowerBound > value ? lowerBound
            : upperBound < value ? upperBound
            : value
    }
}

extension String {
    
    static func random(length: Int = 20) -> String {
        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString: String = ""
        
        for _ in 0..<length {
            let randomValue = arc4random_uniform(UInt32(base.count))
            randomString += "\(base[base.index(base.startIndex, offsetBy: Int(randomValue))])"
        }
        return randomString
    }
}
