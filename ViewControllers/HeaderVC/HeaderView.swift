//
//  HeaderView.swift
//  TiCKTOC-Driver
//
//  Created by Excellent Webworld on 09/10/17.
//  Copyright © 2017 Excellent Webworld. All rights reserved.
//

import UIKit


protocol HeaderViewDelegate: NSObjectProtocol {
    func didSideMenuClicked()       //  Side Menu
    func didBackButtonClicked()     //  Back Button
    func didSignOutClicked()        //  SignOut
    func didSwitchOnOFFClicked(isOn : Bool)    //  Switch On/OFF
    func didCallClicked()           // Call Button
    func didCallSOS()
}


class HeaderView: UIView {
    
    
    weak var delegate: HeaderViewDelegate?
    
    override func draw(_ rect: CGRect) {
        
        btnSwitch.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        if UIApplication.shared.statusBarFrame.height == 20 {
            self.titleCenterConstraint.constant = 10
        }
        else {
            self.titleCenterConstraint.constant = 23
        }
        // Drawing code
    }
    
    //-------------------------------------------------------------
    // MARK: - Outlets
    //-------------------------------------------------------------
    //HeaderView 1
    @IBOutlet var imgHeaderImage: UIImageView!
    @IBOutlet var btnSwitch: UIButton!
    @IBOutlet var btnMenu: UIButton!
    @IBOutlet var btnBack: UIButton!
    @IBOutlet var btnSOS: UIButton!
    @IBOutlet var lblTitle: UILabel!

    @IBOutlet var viewSwitchIcon: UIView!
    @IBOutlet var viewCallIcon: UIView!
    @IBOutlet var viewSOSIcon: UIView!
    //    @IBOutlet var btnCall: UIButton!
    @IBOutlet var imgBottomLine: UIImageView!
    
    
    //HeaderView 2
    @IBOutlet var btnSignOut: UIButton!
    @IBOutlet var lblHeaderTitle: UILabel!    
    @IBOutlet var bottomView: UIView!
    
    @IBOutlet var titleCenterConstraint: NSLayoutConstraint!
    
    
    //-------------------------------------------------------------
    // MARK: - Actions
    //-------------------------------------------------------------
    
    class func headerView(withDelegate delegate: HeaderViewDelegate?) -> HeaderView
    {
        //        print("Hello")
        var arr: [Any] = Bundle.main.loadNibNamed("HeaderView", owner: self, options: nil)!
        let hView: HeaderView? = (arr[0] as? HeaderView)
        hView?.delegate = delegate
        if Singletons.sharedInstance.driverDuty == "1" {
            hView?.btnSwitch.setImage(UIImage(named: "iconSwitchOn"), for: .normal)
        }
        else
        {
            hView?.btnSwitch.setImage(UIImage(named: "iconSwitchOff"), for: .normal)
        }
        return hView!
    }
    
    
    //HeaderView 1
    @IBAction func btnSignOut(_ sender: UIButton)
    {
        delegate?.didSignOutClicked()
    }
    
    @IBAction func btnSwitch(_ sender: UIButton)
    {
        var message : String? = "message_turnDuty_on"
        if(Singletons.sharedInstance.driverDuty == "1")
        {
            message = "message_turnDuty_off"
        }
        print("\(sender.isSelected)")
        UtilityClass.showAlertWithCompletion(appName.kAPPName, message: message?.localized ?? "", okTitle: "OK", otherTitle: "Cancel", vc: self.topMostController() ?? UIViewController()) { (status) in
            if(status)
            {
                sender.isSelected = !sender.isSelected
                self.btnSwitch.isEnabled = false
                
                if (sender.isSelected)
                {
                    self.delegate?.didSwitchOnOFFClicked(isOn: true)
                }
                else
                {
                    self.delegate?.didSwitchOnOFFClicked(isOn: false)
                }
            }
        }
      
        
        
    }
    
    
    @IBAction func btnSOS(_ sender: UIButton) {
        delegate?.didCallSOS()
    }
    
    @IBAction func btnBack(_ sender: UIButton) {
        delegate?.didBackButtonClicked()
        
        
    }
    
    @IBAction func btnSideMenu(_ sender: UIButton) {
        
        delegate?.didSideMenuClicked()
    }
    
    @IBAction func btnCallHelpDesk(_ sender: Any) {
        
     delegate?.didCallClicked()
    }
    
    // ------------------------------------------------------------
    
    //HeaderView 2
    
    
    // ------------------------------------------------------------
    
    
    
    
    
    
}
