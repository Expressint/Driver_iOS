//////
////  InviteDriverViewController.swift
////  TiCKTOC-Driver
////
////  Created by Excellent Webworld on 14/10/17.
////  Copyright © 2017 Excellent Webworld. All rights reserved.
//

import UIKit
import MessageUI
import Social
import SDWebImage

class InviteDriverViewController : ParentViewController,MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate {

    
    @IBOutlet var lblReferalAmount: UILabel!
    @IBOutlet var lblYourReferalCode: UILabel!
    @IBOutlet weak var btnPassenger: UIButton!
    @IBOutlet weak var btnDriver: UIButton!
    var driverFullName = String()
    var strReferralCode = String()
    var strReferralMoney = String()
    var selectedIndex: Int = 0

    @IBOutlet weak var btnFaceBook: UIButton!
    //-------------------------------------------------------------
    // FIXME:- Base Methods
    //-------------------------------------------------------------

    @IBOutlet var viewBottom: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.btnPassenger.isSelected = true

//        if DeviceType.IS_IPHONE_4_OR_LESS || DeviceType.IS_IPAD {
//            constraintTopOfView.constant = 44
//            constraintTopOfShareVia.constant = 10
//        }

        self.btnFaceBook.cornerRadius = self.view.frame.size.height / 2
        self.btnFaceBook.clipsToBounds = true
        let profileData = Singletons.sharedInstance.dictDriverProfile
        if let ReferalAmount = profileData?.object(forKey: "ReferralAmount") as? Double {
             lblReferalAmount.text = "\("Referral Amount".localized) \(ReferalAmount) \(currency)"
        }
        
//        lblReferalAmount.text = "\("Referral Amount".localized) \((profileData?.object(forKey: "profile") as! NSDictionary).object(forKey: "ReferralAmount") as! Double) \(currency)"

        //
        //        if let RefarMoney = (profileData?.object(forKey: "profile") as! NSDictionary).object(forKey: "ReferralAmount") as? Double {
        //            strReferralMoney = String(RefarMoney)
        //            lblReferralMoney.text = "\(currency) \(strReferralMoney)"
        //        }
        //
        if let imgProfile = (profileData?.object(forKey: "profile") as! NSDictionary).object(forKey: "Image") as? String {
            
            imgProfilePick.sd_setImage(with: URL(string: imgProfile), completed: nil)
        }

        // border
        viewBottom.layer.borderWidth = 1.0
        viewBottom.layer.borderColor = UIColor.clear.cgColor
        
        // shadow
        viewBottom.layer.shadowColor = UIColor.gray.cgColor
        viewBottom.layer.shadowOffset = CGSize(width: 3, height: 3)
        viewBottom.layer.shadowOpacity = 0.7
        viewBottom.layer.shadowRadius = 4.0
        
        imgProfilePick.layer.cornerRadius = imgProfilePick.frame.width / 2
        imgProfilePick.layer.masksToBounds = true
        imgProfilePick.layer.borderColor = ThemeAppMainColor.cgColor
        imgProfilePick.layer.borderWidth = 1.0
        
//        headerView?.btnBack.addTarget(self, action: #selector(self.nevigateToBack), for: .touchUpInside)//binal

//        imgProfilePick.layer.cornerRadius = imgProfilePick.frame.width / 2
//        imgProfilePick.layer.masksToBounds = true
//        imgProfilePick.layer.borderWidth = 1.0
//        imgProfilePick.layer.borderColor = UIColor.black.cgColor

        // Do any additional setup after loading the view.
    }
   // @IBOutlet weak var lblWhenAFrindRidesWithYourCode: UILabel!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setLocalization()
        
    }
    @IBOutlet weak var btnShare: UIButton!
    
    @IBOutlet weak var lblShareYourInviteCode: UILabel!
    
    func setLocalization()
    {
         let profileData = Singletons.sharedInstance.dictDriverProfile
        if let ReferralCode = (profileData?.object(forKey: "profile") as! NSDictionary).object(forKey: "ReferralCode") as? String {
            strReferralCode = ReferralCode
            
            lblShareYourInviteCode.text = "Your Referral Code : ".localized + strReferralCode
            let yourCode = "Your Referral Code : ".localized + strReferralCode
            lblYourReferalCode.text = yourCode
        }
        
      
        //"Your Referral Code : ".localized + strReferralCode
        
//        lblReferalAmount.text = "\("Referral Amount".localized) \((profileData?.object(forKey: "profile") as! NSDictionary).object(forKey: "ReferralAmount") as! Double) \(currency)"
      //  lblWhenAFrindRidesWithYourCode.text = "When a friend rides with your code".localized
        lblShareYourInviteCode.text =   "Share Your Invite Code".localized
        btnShare.setTitle("SHARE".localized, for: .normal)
  
        self.headerView?.lblTitle.text = "Invite Friends".localized
        self.headerView?.btnWhatsapp.isHidden = true
        
        

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    //-------------------------------------------------------------
    // MARK: - Outlets
    //-------------------------------------------------------------
//
    @IBOutlet var imgProfilePick: UIImageView!
  //  @IBOutlet weak var lblReferralCode: UILabel!
//    @IBOutlet weak var lblReferralMoney: UILabel!
//
//    @IBOutlet weak var constraintTopOfView: NSLayoutConstraint! // 64
//    @IBOutlet weak var constraintTopOfShareVia: NSLayoutConstraint! // 20


    //-------------------------------------------------------------
    // MARK: - Custom Methods
    //-------------------------------------------------------------
    func nevigateToBack()
    {
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: TabbarController.self) {
                self.sideMenuController?.embed(centerViewController: controller)
                break
            }
        }
    }

    //-------------------------------------------------------------
    // MARK: - Actions
    //-------------------------------------------------------------
    @IBAction func btnMoreOption(_ sender: UIButton) {
        
        let decodeResults = Singletons.sharedInstance.dictDriverProfile
        var strName = String()

        if decodeResults!.count != 0
        {
            strName = ((decodeResults!).object(forKey: "profile") as! NSDictionary).object(forKey: "Fullname") as! String
        }
//        let referralCode = ((decodeResults!).object(forKey: "profile") as! NSDictionary).object(forKey: "ReferralCode") as? String ?? ""
//        let strInvitation = "Your Referral Code is : ".localized + referralCode
        
        let strContent = "\(strName)  \("has invited you to become a".localized) \("App Name".localized).\n \n \("For iOS Click Here : ".localized) \(appName.kAPPUrl) \n \n\("For Android Click Here : ".localized) \(appName.kAPPUrlAndroid) \n\n \("Your invite code is :".localized) \(strReferralCode)"

        let share = [strContent]
        
        let activityViewController = UIActivityViewController(activityItems: share, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
        
    }
    
    @IBAction func btnFacebook(_ sender: UIButton) {


        let fbController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)

        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook) {
            let completionHandler: SLComposeViewControllerCompletionHandler = {(_ result: SLComposeViewControllerResult) -> Void in
                
                fbController?.dismiss(animated: true, completion: {
                    switch result {
                    case .done:
                        print("Posted.")
                    case .cancelled:
                        fallthrough
                    default:
                        print("Cancelled.")
                    }
                })
              
               
            }
            fbController?.setInitialText("Check out this article.")
            fbController?.completionHandler = completionHandler
//            self.present(fbController!, animated: true) { _ in }
            self.present(fbController!, animated: true, completion: nil)
        }
        else {
            if let fbSignInDialog = SLComposeViewController(forServiceType: SLServiceTypeFacebook) {
                //                fbSignInDialog.setInitialText(codeToSend())
//                self.present(fbSignInDialog, animated: false) { _ in }
                self.present(fbSignInDialog, animated: true, completion: nil)
            }
            else {
                UtilityClass.showAlert("App Name".localized, message: "Please install Facebook app", vc: self)
            }
        }

    }

    @IBAction func btnTwitter(_ sender: UIButton) {


        let TWController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)

        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
            let completionHandler: SLComposeViewControllerCompletionHandler = {(_ result: SLComposeViewControllerResult) -> Void in
                //                TWController?.dismiss(animated: true) { _ in }
                TWController?.dismiss(animated: true, completion: {
                    switch result {
                    case .done:
                        print("Posted.")
                    case .cancelled:
                        fallthrough
                    default:
                        print("Cancelled.")
                    }
                })
            }
            TWController?.setInitialText("Check out this article.")
            TWController?.completionHandler = completionHandler
//            self.present(TWController!, animated: true) { _ in }
                self.present(TWController!, animated: true, completion: nil)
        }
        else {
            if let twitterSignInDialog = SLComposeViewController(forServiceType: SLServiceTypeTwitter) {

                //                twitterSignInDialog.setInitialText(codeToSend())

                if twitterSignInDialog.serviceType == SLServiceTypeTwitter {
                    self.present(twitterSignInDialog, animated: false)
                }
                else {
                    UtilityClass.showAlert("App Name".localized, message: "Please install Twitter app", vc: self)
                }

            }
            else {
                UtilityClass.showAlert("App Name".localized, message: "Please install Twitter app", vc: self)
            }

        }
    }

    @IBAction func btnEmail(_ sender: UIButton) {

        let emailTitle = ""

        //Driver name has invited you to become a TiCKTOC Driver.
        let toRecipents = [""]
        let mc: MFMailComposeViewController = MFMailComposeViewController()
        mc.mailComposeDelegate = self
        mc.setSubject(emailTitle)
        //        mc.setMessageBody(codeToSend(), isHTML: false)
        mc.setToRecipients(toRecipents)

        self.present(mc, animated: true, completion: nil)

    }

    @IBAction func btnWhatsApp(_ sender: UIButton) {

        //        let urlStringEncoded = codeToSend().addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        //        let url  = NSURL(string: "whatsapp://send?text=\(urlStringEncoded!)")
        //
        //        if UIApplication.shared.canOpenURL(url! as URL)
        //        {
        //            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
        //        } else {
        //
        //            UtilityClass.showAlert(appName.kAPPName, message: "Please install WhatsApp app", vc: self)
        //
        //        }
    }

    @IBAction func btnSMS(_ sender: UIButton) {

        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            //            controller.body = codeToSend()
            controller.recipients = [""]
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnShareClicked(_ sender: Any) {
        reloadData()
    }
    
    @IBAction func btnDriverClicked(_ sender: Any) {
        selectedIndex = 1
        self.btnDriver.isSelected = true
        self.btnPassenger.isSelected = false
    }
  
    @IBAction func btnPassengerClicked(_ sender: Any) {
        selectedIndex = 0
        self.btnDriver.isSelected = false
        self.btnPassenger.isSelected = true
    }
   
    func reloadData(){
        if(selectedIndex == -1){
            UtilityClass.showAlert("Missing".localized, message: "Please select app type", vc: self)
        }else if(selectedIndex == 0) {
            let decodeResults = Singletons.sharedInstance.dictDriverProfile
            var strName = String()
            
            if decodeResults!.count != 0
            {
                strName = ((decodeResults!).object(forKey: "profile") as! NSDictionary).object(forKey: "Fullname") as! String
            }
          
            if let ReferralCode = (decodeResults?.object(forKey: "profile") as! NSDictionary).object(forKey: "ReferralCode") as? String {
                strReferralCode = ReferralCode
            }
            let strContent = "\(strName)  \("has invited you to become a".localized) \("Share App Name Passenger".localized).\n \n\("For iOS Click Here : ".localized) \(appName.appURLiOS) \n \n\("For Android Click Here : ".localized) \(appName.appURLAndroid)\n\n \("Your invite code is :".localized) \(strReferralCode)"
            
            let share = [strContent]
            
            let activityViewController = UIActivityViewController(activityItems: share, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)

        }else{
            
            let decodeResults = Singletons.sharedInstance.dictDriverProfile
            var strName = String()
            
            if decodeResults!.count != 0
            {
                strName = ((decodeResults!).object(forKey: "profile") as! NSDictionary).object(forKey: "Fullname") as! String
            }
          
            if let ReferralCode = (decodeResults?.object(forKey: "profile") as! NSDictionary).object(forKey: "ReferralCode") as? String {
                strReferralCode = ReferralCode
            }
         
            let strContent = "\(strName) \("has invited you to become a".localized) \("Share App Name Driver".localized).\n \n\("For iOS Click Here : ".localized) \(appName.kAPPUrliOS) \n \n\("For Android Click Here : ".localized) \(appName.kAPPUrlAndroid)\n\n \("Your Referral Code :".localized) \(strReferralCode)"
            
            let share = [strContent]
            
            let activityViewController = UIActivityViewController(activityItems: share, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        }
    }

    //-------------------------------------------------------------
    // MARK: - Custom Methods
    //-------------------------------------------------------------

    func mailComposeController(_ controller:MFMailComposeViewController, didFinishWith result:MFMailComposeResult, error:Error?) {
        switch result {
        case MFMailComposeResult.cancelled:
            print("Mail cancelled")
            UtilityClass.showAlert("App Name".localized, message: "Mail cancelled", vc: self)
        case MFMailComposeResult.saved:
            print("Mail saved")
            UtilityClass.showAlert("App Name".localized, message: "Mail saved", vc: self)
        case MFMailComposeResult.sent:
            print("Mail sent")
            UtilityClass.showAlert("App Name".localized, message: "Mail sent", vc: self)
        case MFMailComposeResult.failed:
            print("Mail sent failure: \(String(describing: error?.localizedDescription))")
            UtilityClass.showAlert("App Name".localized, message: "Mail sent failure: \(String(describing: error?.localizedDescription))", vc: self)
            break
        }
        self.dismiss(animated: true, completion: nil)
    }

    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        //... handle sms screen actions
        switch result {
        case MessageComposeResult.cancelled:
            print("Mail cancelled")
            UtilityClass.showAlert("App Name".localized, message: "Message cancelled", vc: self)
        case MessageComposeResult.sent:
            print("Mail sent")
            UtilityClass.showAlert("App Name".localized, message: "Message sent", vc: self)
        case MessageComposeResult.failed:
            print("Mail sent failure")
            break
        }
        self.dismiss(animated: true, completion: nil)
    }

//
        func codeToSend() -> String
        {
    //        let profile =  NSMutableDictionary(dictionary: (Singletons.sharedInstance.dictDriverProfile.object(forKey: "profile") as! NSDictionary))
    //        let driverFullName = profile.object(forKey: "Fullname") as! String
            let messageBody = "\(driverFullName) has invited you to become a \("App Name".localized) Driver"
            let androidLink = "Android click \("")"
            let iosLink = "iOS click \(appName.kAPPUrl)"
            let yourInviteCode = "Your invite code is: \(strReferralCode)"
            let urlOfTick = ""//"www.ticktoc.net www.facebook.com/ticktoc.net"
    
            let urlString = "\(messageBody) \n \(androidLink) \n \(iosLink) \n \(yourInviteCode) \n \(urlOfTick)" as String
            return urlString
        }

}
