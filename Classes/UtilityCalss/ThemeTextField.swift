//  ThemeTextField.swift
//  TanTaxi User
//  Created by EWW-iMac Old on 03/10/18.
//  Copyright © 2018 Excellent Webworld. All rights reserved.

import UIKit

class ThemeTextField: UITextField {
    
    @IBInspectable public var isLeftViewNeeded: Bool = false
    @IBInspectable public var LeftImage: UIImage = UIImage()
    @IBInspectable public var isBorderNeeded: Bool = false
    
    var btnSecureText = UIButton()
    var iconClick:Bool = true {
        didSet {
            self.btnSecureText.isSelected  = self.iconClick
        }
    }
    
    
    
    override func awakeFromNib()
    {
        self.font = UIFont.init(name: CustomeFontProximaNovaRegular, size: 14)
        self.textColor = UIColor.black
        self.backgroundColor = UIColor.init(white: 1, alpha: 0.8)
        self.setValue(UIColor.black , forKeyPath: "placeholderLabel.textColor")
            self.layer.cornerRadius = 2
            self.layer.shadowRadius = 3.0
            self.layer.shadowColor = UIColor.black.withAlphaComponent(0.6).cgColor
            self.layer.shadowOffset = CGSize (width: 1.0, height: 1.0)
            self.layer.shadowOpacity = 1.0
        
        if isLeftViewNeeded == true {
            self.SetLeftViewImage(Image: LeftImage)
        }
        else {
            let LeftView = UIView(frame: CGRect(x: 0, y: 0, width: 10.0, height: 20.0)) //RJ Change width change 20 to 10
            LeftView.backgroundColor = UIColor.clear
            
            self.leftView = LeftView
            self.leftViewMode = .always
        }
        
        if isBorderNeeded == true {
            let border = CALayer()
            let width = CGFloat(1.0)
            border.borderColor = UIColor.lightGray.cgColor
            border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: UIScreen.main.bounds.width - 20.0 , height: self.frame.size.height)
            
            border.borderWidth = width
            self.layer.addSublayer(border)
            self.layer.masksToBounds = true
        }
        
        if self.tag == AppTextfieldTags.SecureTextTag {
            self.btnSecureText = UIButton(frame: CGRect(x: 5, y: 5, width: 20.0, height: 20.0))
            let LeftView = UIView(frame: CGRect(x: 0, y: 0, width: 30.0, height: 30.0))
            LeftView.backgroundColor = UIColor.clear
            btnSecureText.backgroundColor = UIColor.clear
            btnSecureText.setImage(UIImage(named: "hide"), for: .selected)
            btnSecureText.setImage(UIImage(named: "show"), for: .normal)
            btnSecureText.addTarget(self, action: #selector(self.iconAction), for: .touchUpInside)
            LeftView.addSubview(btnSecureText)
            self.iconClick = true
            
            self.rightView = LeftView
            self.rightViewMode = .always
        }
    }
    
    //MARK:- Action Methods
    
    @objc func iconAction() {
        if(iconClick == true) {
            self.isSecureTextEntry = false
        } else {
            self.isSecureTextEntry = true
        }
        iconClick = !iconClick
    }
}
//
extension UITextField {
    
    func SetLeftViewImage(Image:UIImage) {
        let LeftView = UIView(frame: CGRect(x: 0, y: 0, width: 30.0, height: 30.0))
        LeftView.backgroundColor = UIColor.clear
        
        let imageView = UIImageView(frame: CGRect(x: 5.0, y: 5.0, width: 20, height: 20));
        imageView.backgroundColor = UIColor.clear
        imageView.image = Image
        imageView.contentMode = .scaleAspectFit
        LeftView.addSubview(imageView)
        
        self.leftView = LeftView
        self.leftViewMode = .always
    }
}
//MARK:- UIFont

extension UIFont {
//    class func regular(ofSize size: CGFloat) -> UIFont {
//        return UIFont(name:  AppRegularFont, size: manageFont(font: size))!
//    }
//    class func semiBold(ofSize size: CGFloat) -> UIFont {
//        return UIFont(name: AppSemiboldFont, size: manageFont(font: size))!
//    }
//    class func bold(ofSize size: CGFloat) -> UIFont {
//        return UIFont(name: AppBoldFont, size: manageFont(font: size))!
//    }
//    
//    private class func manageFont(font : CGFloat) -> CGFloat {
//        let cal  = windowHeight * font
//        print(CGFloat(cal / CGFloat(screenHeightDeveloper)))
//        return CGFloat(cal / CGFloat(screenHeightDeveloper))
//    }
    
}
