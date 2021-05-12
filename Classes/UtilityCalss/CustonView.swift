//
//  CustonView.swift
//   TenTaxi-Driver
//
//  Created by Excellent Webworld on 03/01/18.
//  Copyright © 2018 Excellent Webworld. All rights reserved.
//

import UIKit

let AppRegularFont:String = "ProximaNova-Regular"
let AppBoldFont:String = "ProximaNova-Bold"
let AppSemiboldFont:String = "ProximaNova-Semibold"

let windowHeight: CGFloat = CGFloat(UIScreen.main.bounds.size.height)
let screenHeightDeveloper : Double = 568
let screenWidthDeveloper : Double = 320



extension UIView {
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
    
    func addShadow(shadowColor: UIColor, offSet: CGSize, opacity: Float, shadowRadius: CGFloat, cornerRadius: CGFloat, corners: UIRectCorner, fillColor: UIColor = .white) {
            
            let shadowLayer = CAShapeLayer()
            let size = CGSize(width: cornerRadius, height: cornerRadius)
            let cgPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: size).cgPath //1
            shadowLayer.path = cgPath //2
            shadowLayer.fillColor = fillColor.cgColor //3
            shadowLayer.shadowColor = shadowColor.cgColor //4
            shadowLayer.shadowPath = cgPath
            shadowLayer.shadowOffset = offSet //5
            shadowLayer.shadowOpacity = opacity
            shadowLayer.shadowRadius = shadowRadius
            self.layer.addSublayer(shadowLayer)
        }
}

class BoxView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        self.backgroundColor = ThemeColor.textFieldBg
        self.layer.cornerRadius = 8.0
        self.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        self.layer.borderWidth = 1.0
        self.layer.masksToBounds = true
    }
}
