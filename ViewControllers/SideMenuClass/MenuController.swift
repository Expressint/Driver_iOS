//
//  MenuController.swift
//  TiCKTOC-Driver
//  Created by Excellent Webworld on 11/10/17.
//  Copyright © 2017 Excellent Webworld. All rights reserved.
//

import UIKit
import SideMenuController
import SDWebImage
import MapKit

let KEnglish : String = "EN"
let KSwiley : String = "SW"

class  MenuController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    
    var aryItemNames = [String]()
    var aryItemIcons = [String]()
    
    var driverFullName = String()
    var driverImage = UIImage()
    var driverMobileNo = String()
    var strImagPath = String()
    var strSelectedLaungage = String()
    private var previousIndex: NSIndexPath?
    
    
    var arrMenuIcons = [String]()
    var arrMenuTitle = [String]()
    
    // MARK: IBOutlets -
    @IBOutlet weak var CollectionView: UICollectionView!
    @IBOutlet weak var lblDriverName: UILabel!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var btnSignOut1: UIButton! {
        didSet {
            btnSignOut1.layer.borderColor = UIColor.black.cgColor
            btnSignOut1.layer.borderWidth = 1.0
            btnSignOut1.setTitleColor(UIColor.black, for: .normal)
            btnSignOut1.layer.cornerRadius = 20
            btnSignOut1.setTitle("Sign out".localized, for: .normal)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        strSelectedLaungage = KEnglish
      
        arrMenuTitle = [kMyJobs,kPaymentOption]
               
        arrMenuIcons = [kiconMyJobs,kiconPaymentOption]
        /*
        arrMenuTitle = [kMyJobs,kPaymentOption,kWallet,kMyRating,kInviteFriend,kSettings,kLegal,kSupport,kLogout]
        
        arrMenuIcons = [kiconMyJobs,kiconPaymentOption,kiconWallet,kiconMyRating,kiconInviteFriend,kiconSettings,klegal
            ,kiconSupport,kIconLogout]
        */
     /*
        aryItemNames = [kMyJobs,kPaymentOption,kWallet,kMyRating,kInviteFriend,kSettings,kLegal,kSupport,kLogout]
        
        aryItemIcons = [kiconMyJobs,kiconPaymentOption,kiconWallet,kiconMyRating,kiconInviteFriend,kiconSettings,klegal
            ,kiconSupport,kIconLogout]
        
        */
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(MenuController.setRating), name: NSNotification.Name(rawValue: "rating"), object: nil)
        self.getDataFromSingleton()
        self.setProfileData()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        giveGradientColor()
//        getDataFromSingleton() RJChange
    }
    
    func giveGradientColor() {
        
        let colorTop =  UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0).cgColor//(red: 0, green: 0, blue: 0, alpha: 1.0).cgColor
        let colorMiddle =  UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0).cgColor//UIColor(red: 36/255, green: 24/255, blue: 3/255, alpha: 0.5).cgColor
        let colorBottom = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0).cgColor//UIColor(red: 64/255, green: 43/255, blue: 6/255, alpha: 0.8).cgColor
        //
        //        let gradientLayer = CAGradientLayer()
        //        gradientLayer.colors = [ colorTop, colorMiddle, colorBottom]
        //        gradientLayer.locations = [ 0.0, 0.5, 1.0]
        //        gradientLayer.frame = self.view.bounds
        //        self.view.layer.insertSublayer(gradientLayer, at: 0)
        
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
        
    }
    
    @objc func setRating() {
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setProfileData() {
        imgProfile.layer.cornerRadius = imgProfile.frame.width / 2
        imgProfile.layer.masksToBounds = true
        imgProfile.layer.borderColor = ThemeAppMainColor.cgColor
        imgProfile.layer.borderWidth = 1.0
        lblDriverName.text = driverFullName
        lblEmail.text = driverMobileNo
        //            cellProfile.lblRating.text = Singletons.sharedInstance.strRating
        imgProfile.sd_setImage(with: URL(string: strImagPath))
    }
    
    //Mark: tableview method
    
    @IBOutlet var tableView: UITableView!
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if aryItemNames.count == 0 {
                return 0
            }
            return 1
        }
        else if section == 1 {
            return 1// return aryItemNames.count
        }
        else {
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        //        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        
        let cellProfile = tableView.dequeueReusableCell(withIdentifier: "SideMenuIDriverProfile") as! SideMenuTableViewCell
        let cellItemList = tableView.dequeueReusableCell(withIdentifier: "SideMenuItemsList") as! SideMenuTableViewCell
        
        cellProfile.selectionStyle = .none
        cellItemList.selectionStyle = .none
        tableView.separatorStyle = .none
        tableView.alwaysBounceVertical = false
        
        if indexPath.section == 0 {
            
            cellProfile.imgProfile.layer.cornerRadius = cellProfile.imgProfile.frame.width / 2
            cellProfile.imgProfile.layer.masksToBounds = true
            cellProfile.imgProfile.layer.borderColor = ThemeAppMainColor.cgColor
            cellProfile.imgProfile.layer.borderWidth = 1.0
            cellProfile.lblDriverName.text = driverFullName
            cellProfile.lblGmail.text = driverMobileNo
            //            cellProfile.lblRating.text = Singletons.sharedInstance.strRating
            cellProfile.imgProfile.sd_setImage(with: URL(string: strImagPath))
            cellProfile.btnUpdateProfile.addTarget(self, action: #selector(self.updateProfile), for: .touchUpInside)
//            cellProfile.lblLaungageName.layer.cornerRadius = 5
//            cellProfile.lblLaungageName.backgroundColor = ThemeAppMainColor
//            cellProfile.lblLaungageName.layer.borderColor = UIColor.black.cgColor
//            cellProfile.lblLaungageName.layer.borderWidth = 0.5
//
//            if let SelectedLanguage = UserDefaults.standard.value(forKey: "i18n_language") as? String {
//                if SelectedLanguage == "en" {
//                    cellProfile.lblLaungageName.text = "SW"
//                } else if SelectedLanguage == "sw" {
//                    cellProfile.lblLaungageName.text = "EN"
//                }
//            }
//            cellProfile.lblLaungageName.text = strSelectedLaungage
            
//            cellProfile.btnLaungageChange.addTarget(self, action: #selector(btnLaungageClicked(_:)), for: .touchUpInside)
            //            .layer.cornerRadius = btnHome.frame.size.height / 2
            //            btnMyJob.clipsToBounds = true
            //            btnMyJob.borderColor = UIColor.red
            return cellProfile
        }
        else if indexPath.section == 1 {
            //            cellItemList.lblItemNames.text = aryItemNames[indexPath.row]
            //            cellItemList.imgItems.image = UIImage(named: aryItemIcons[indexPath.row])
            
            cellItemList.lblMyJobs.text = "My Jobs".localized
            cellItemList.lblMyRaitng.text = "My Ratings".localized
            cellItemList.lblInviteFrnd.text = "Invite Friends".localized
//            cellItemList.lblTripToDestination.text = "Trip to Destination".localized
//            cellItemList.lblLegal.text = "Legal".localized
            cellItemList.lblSupport.text = "Setting".localized
            cellItemList.btnLogOut.setTitle("Log Out".localized, for: .normal)
            cellItemList.lblPaymentOption.text = "Payment Options".localized
            cellItemList.btnMyJob.addTarget(self, action: #selector(self.MyJob), for: .touchUpInside)
            //            cellItemList.btnMyJob.tag = indexPath.row
            cellItemList.btnPaymentOption.addTarget(self, action: #selector(self.PayMentOption), for: .touchUpInside)
            cellItemList.btnWallet.addTarget(self, action: #selector(self.Wallet), for: .touchUpInside)
            cellItemList.btnMyRating.addTarget(self, action: #selector(self.MyRating), for: .touchUpInside)
            cellItemList.btnInviteFriend.addTarget(self, action: #selector(self.InviteFriend), for: .touchUpInside)
//            cellItemList.btnTripToDestination.addTarget(self, action: #selector(self.setting), for: .touchUpInside)
//            cellItemList.btnLegal.addTarget(self, action: #selector(self.Legal), for: .touchUpInside)
            cellItemList.btnSupport.addTarget(self, action: #selector(self.updateProfile), for: .touchUpInside)
            cellItemList.btnLogOuts.addTarget(self, action: #selector(self.LogOut), for: .touchUpInside)
            
            cellItemList.btnMyJob.layer.shadowOpacity = 0.7
            cellItemList.btnMyJob.layer.shadowRadius = 15.0
            cellItemList.btnMyJob.layer.shadowColor = UIColor.black.cgColor
            cellItemList.btnPaymentOption.layer.shadowOpacity = 0.7
            cellItemList.btnPaymentOption.layer.shadowRadius = 15.0
            cellItemList.btnPaymentOption.layer.shadowColor = UIColor.black.cgColor
            cellItemList.btnWallet.layer.shadowOpacity = 0.7
            cellItemList.btnWallet.layer.shadowRadius = 15.0
            cellItemList.btnWallet.layer.shadowColor = UIColor.black.cgColor
            cellItemList.btnMyRating.layer.shadowOpacity = 0.7
            cellItemList.btnMyRating.layer.shadowRadius = 15.0
            cellItemList.btnMyRating.layer.shadowColor = UIColor.black.cgColor
            cellItemList.btnInviteFriend.layer.shadowOpacity = 0.7
            cellItemList.btnInviteFriend.layer.shadowRadius = 15.0
            cellItemList.btnInviteFriend.layer.shadowColor = UIColor.black.cgColor
//            cellItemList.btnTripToDestination.layer.shadowOpacity = 0.7
//            cellItemList.btnTripToDestination.layer.shadowRadius = 15.0
//            cellItemList.btnTripToDestination.layer.shadowColor = UIColor.black.cgColor
//            cellItemList.btnLegal.layer.shadowOpacity = 0.7
//            cellItemList.btnLegal.layer.shadowRadius = 15.0
//            cellItemList.btnLegal.layer.shadowColor = UIColor.black.cgColor
            cellItemList.btnSupport.layer.shadowOpacity = 0.7
            cellItemList.btnSupport.layer.shadowRadius = 15.0
            cellItemList.btnSupport.layer.shadowColor = UIColor.black.cgColor
            cellItemList.btnLogOuts.layer.cornerRadius = cellItemList.btnLogOuts.frame.size.height / 2
            cellItemList.btnLogOuts.clipsToBounds = true
            return cellItemList
        }
        else {
            return UITableViewCell()
        }
        
    }
    @objc func btnLaungageClicked(_ sender : UIButton)
    {
        
        //        sender.isSelected = !sender.isSelected
        
//        if strSelectedLaungage == KEnglish
//        {
//            strSelectedLaungage = KSwiley
//        }
//        else
//        {
//            strSelectedLaungage = KEnglish
//        }
//
//        self.tableView.reloadData()
        
        if let SelectedLanguage = UserDefaults.standard.value(forKey: "i18n_language") as? String {
            if SelectedLanguage == "en" {
                setLayoutForswahilLanguage()
                
            } else if SelectedLanguage == "sw" {
                setLayoutForenglishLanguage()
            }
        }
        self.navigationController?.loadViewIfNeeded()
        self.tableView.reloadData()
        NotificationCenter.default.post(name: NotificationChangeLanguage, object: nil)
        
    }
        
    @objc func MyJob() {
        //
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MyJobsViewController") as!    MyJobsViewController
        self.navigationController?.pushViewController(viewController, animated: true)
        
        //     sideMenuController?.performSegue(withIdentifier: "SegueSideMenuToMyJob", sender: self)
    }
    
    
    @objc func PayMentOption(){
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "WalletCardsVC") as! WalletCardsVC
        self.navigationController?.pushViewController(viewController, animated: true)
        
        
    }
    @objc func Wallet(){
        //        if(Singletons.sharedInstance.CardsVCHaveAryData.count == 0)
        //        {
        //            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "WalletViewController") as! WalletViewController
        //            self.navigationController?.pushViewController(viewController, animated: true)
        //            
        //        }
        //        else
        //        {
        //            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "WalletCardsVC") as! WalletCardsVC
        //            self.navigationController?.pushViewController(viewController, animated: true)
        //            
        //        }
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "WalletViewController") as! WalletViewController
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    @objc func MyRating(){
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MyRatingViewController") as! MyRatingViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    @objc func InviteFriend(){
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "InviteDriverViewController") as! InviteDriverViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    @objc func setting(){
        
        let storyboard = UIStoryboard(name: "TripToDestination", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "TripToDestinationViewController") as! TripToDestinationViewController

        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
    @objc func Legal(){
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "LegalViewController") as! LegalViewController
        self.navigationController?.pushViewController(viewController, animated: true)
   }
    
    @objc func  Support(){
        
//        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "webViewVC") as! webViewVC
//        viewController.headerName = "Support".localized
////        viewController.headerName = "\("App Name".localized) - Terms & Conditions"
//        viewController.strURL = WebSupport.SupportURL
////        "https://www.tantaxitanzania.com/front/termsconditions"
//        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    @objc func LogOut(){
        
//        self.webserviceOFSignOut()
        
    }
    //MARK: Button Action
    @IBAction func settingsClick(_ sender: UIButton) {
         let profile = UIStoryboard(name: "Profile", bundle: nil)
               let viewController = profile.instantiateViewController(withIdentifier: "EditDriverProfileVC") as! EditDriverProfileVC
               self.navigationController?.pushViewController(viewController, animated: true)
    }
    @IBAction func logoutClick(_ sender: UIButton) {
        let LogoutConfirmation = UIAlertController(title: "App Name".localized, message: "Are you sure you want to logout?".localized, preferredStyle: .alert)
               LogoutConfirmation.addAction(UIAlertAction(title: "Logout".localized, style: .destructive, handler: { (UIAlertAction) in
                   self.webserviceOFSignOut()
               }))
               LogoutConfirmation.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil))
               self.present(LogoutConfirmation, animated: true, completion: nil)
    }
    
    func webserviceOFSignOut()
    {
        let srtDriverID = Singletons.sharedInstance.strDriverID
        
        let param = srtDriverID + "/" + Singletons.sharedInstance.deviceToken
        
        webserviceForSignOut(param as AnyObject) { (result, status) in
            
            if (status) {
                print(result)
                
                let socket = (UIApplication.shared.delegate as! AppDelegate).SManager.defaultSocket
                
                socket.off(socketApiKeys.kReceiveBookingRequest)
                socket.off(socketApiKeys.kBookLaterDriverNotify)
                
                socket.off(socketApiKeys.kGetBookingDetailsAfterBookingRequestAccepted)
                socket.off(socketApiKeys.kAdvancedBookingInfo)
                
                socket.off(socketApiKeys.kReceiveMoneyNotify)
                socket.off(socketApiKeys.kAriveAdvancedBookingRequest)
                
                socket.off(socketApiKeys.kDriverCancelTripNotification)
                socket.off(socketApiKeys.kAdvancedBookingDriverCancelTripNotification)
                Singletons.sharedInstance.setPasscode = ""
                Singletons.sharedInstance.isPasscodeON = false
                socket.disconnect()
                
                for (key, value) in UserDefaults.standard.dictionaryRepresentation() {
                    print("\(key) = \(value) \n")
                    
                    if(key != "Token" && key != "i18n_language") {
                        UserDefaults.standard.removeObject(forKey: key)
                    }
                }
                UserDefaults.standard.set(false, forKey: "isTripDestinationShow")
                UserDefaults.standard.set(false, forKey: kIsSocketEmited)
                //  UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
                Singletons.sharedInstance.isDriverLoggedIN = false
                self.performSegue(withIdentifier: "SignOutFromSideMenu", sender: (Any).self)
                
            }
            else {
                print(result)
                if let res = result as? String {
                    UtilityClass.showAlert("App Name".localized, message: res, vc: self)
                }
                else if let resDict = result as? NSDictionary {
                    UtilityClass.showAlert("App Name".localized, message: resDict.object(forKey: GetResponseMessageKey()) as! String, vc: self)
                }
                else if let resAry = result as? NSArray {
                    UtilityClass.showAlert("App Name".localized, message: (resAry.object(at: 0) as! NSDictionary).object(forKey: GetResponseMessageKey()) as! String, vc: self)
                }
            }
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    //    //[kMyJobs,kPaymentOption,kWallet,kMyRating,kInviteFriend,kSettings,kLogout]
    //    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)  {
    //
    //        if indexPath.section == 1
    //        {
    //
    //            let strCellItemTitle = aryItemNames[indexPath.row]
    //
    //            if strCellItemTitle == kWallet
    //            {
    //                if(Singletons.sharedInstance.CardsVCHaveAryData.count == 0)
    //                {
    //                      let viewController = self.storyboard?.instantiateViewController(withIdentifier: "WalletAddCardsViewController") as! WalletAddCardsViewController
    //                    self.navigationController?.pushViewController(viewController, animated: true)
    //
    //                }
    //                else
    //                {
    //                    let viewController = self.storyboard?.instantiateViewController(withIdentifier: "WalletCardsVC") as! WalletCardsVC
    //                    self.navigationController?.pushViewController(viewController, animated: true)
    //
    //
    //                }
    //            }
    //            else if strCellItemTitle == kWallet
    //            {
    //
    //                //                self.moveToComingSoon()
    //                //                   UserDefaults.standard.set(Singletons.sharedInstance.isPasscodeON, forKey: "isPasscodeON")
    //
    //                if (Singletons.sharedInstance.isPasscodeON) {
    //                    //                    if Singletons.sharedInstance.setPasscode == "" {
    //                    //                        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SetPasscodeViewController") as! SetPasscodeViewController
    //                    //                        self.navigationController?.pushViewController(viewController, animated: true)
    //                    //                    }
    //                    //                    else {
    //                    //                        if (Singletons.sharedInstance.passwordFirstTime) {
    //                    //
    //                    //                            let next = self.storyboard?.instantiateViewController(withIdentifier: "WalletViewController") as! WalletViewController
    //                    //                            self.navigationController?.pushViewController(next, animated: true)
    //                    //                        }
    //                    //                        else {
    //                    let viewController = self.storyboard?.instantiateViewController(withIdentifier: "VerifyPasswordViewController") as! VerifyPasswordViewController
    //                    viewController.strStatusToNavigate = "wallet"
    //                    self.navigationController?.pushViewController(viewController, animated: true)
    //
    //                    //                        }
    //                }
    //
    //                else
    //                {
    //                    let next = self.storyboard?.instantiateViewController(withIdentifier: "WalletViewController") as! WalletViewController
    //                    self.navigationController?.pushViewController(next, animated: true)
    //                }
    //
    //
    //
    //
    //                //                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SetPasscodeViewController") as! SetPasscodeViewController
    //                //                self.navigationController?.pushViewController(viewController, animated: true)
    //                //
    //
    //                //                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "WalletViewController") as! WalletViewController
    //                //                self.navigationController?.pushViewController(viewController, animated: true)
    //
    //            }
    ////            else if indexPath.row == 2 {
    ////
    ////                if (Singletons.sharedInstance.isPasscodeON) {
    ////                    let tabbar =  ((((((self.navigationController?.children)?.last as! CustomSideMenuViewController).children[0]) as! UINavigationController).children[0]) as! TabbarController)
    ////                    tabbar.selectedIndex = 4
    ////                    let viewController = self.storyboard?.instantiateViewController(withIdentifier: "VerifyPasswordViewController") as! VerifyPasswordViewController
    ////                    self.present(viewController, animated: false, completion: nil)
    ////                    sideMenuController?.toggle()
    ////
    ////                }
    ////                else {
    ////                    let tabbar =  ((((((self.navigationController?.children)?.last as! CustomSideMenuViewController).children[0]) as! UINavigationController).children[0]) as! TabbarController)
    ////                    tabbar.selectedIndex = 4
    ////
    ////                    sideMenuController?.toggle()
    ////                }
    ////
    ////            }
    ////            else if indexPath.row == 2 {
    //////                 self.moveToComingSoon()
    ////
    ////                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "WeeklyEarningViewController") as! WeeklyEarningViewController
    ////                self.navigationController?.pushViewController(viewController, animated: true)
    ////            }
    ////            else if strCellItemTitle == kDriverNews {
    //////                self.moveToComingSoon()
    ////
    ////                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "DriverNewsViewController") as! DriverNewsViewController
    ////                self.navigationController?.pushViewController(viewController, animated: true)
    ////
    ////            }
    //           else if strCellItemTitle == kInviteFriend {
    //                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "InviteDriverViewController") as! InviteDriverViewController
    //                self.navigationController?.pushViewController(viewController, animated: true)
    //            }
    ////            else if strCellItemTitle == kChangePassword {
    ////
    ////                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ChangePasswordViewController") as! ChangePasswordViewController
    ////                self.navigationController?.pushViewController(viewController, animated: true)
    ////
    ////            }
    //            else if strCellItemTitle == kSettings {
    //
    //                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SettingPasscodeVC") as! SettingPasscodeVC
    //                self.navigationController?.pushViewController(viewController, animated: true)
    //
    //            }
    ////            else if strCellItemTitle == kMeter
    ////            {
    ////
    ////                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MeterViewController") as! MeterViewController
    ////                self.navigationController?.pushViewController(viewController, animated: true)
    ////            }
    ////            else if strCellItemTitle == kTripToDstination
    ////            {
//                    let storyboard = UIStoryboard(name: "TripToDestination", bundle: nil)
//                    let viewController = storyboard.instantiateViewController(withIdentifier: "TripToDestinationViewController") as! TripToDestinationViewController
    //
    ////                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "TripToDestinationViewController") as! TripToDestinationViewController
    ////                self.navigationController?.pushViewController(viewController, animated: true)
    ////
    ////            }
    ////            else if strCellItemTitle == kShareRide {
    ////                let viewController = storyboard?.instantiateViewController(withIdentifier: "ShareRideViewController") as! ShareRideViewController
    ////                self.navigationController?.pushViewController(viewController, animated: true)
    //                //            }//binal
    //
    //        }
    //
    //    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 180
        }
        else if indexPath.section == 1 {
            return 524//self.view.frame.size.height
        }
        else {
            return 524
        }
    }
    
   
    //-------------------------------------------------------------
    // MARK: - Custom Methods
    //-------------------------------------------------------------
    
    @objc func updateProfile()
    {
        let profile = UIStoryboard(name: "Profile", bundle: nil)
        let viewController = profile.instantiateViewController(withIdentifier: "EditDriverProfileVC") as! EditDriverProfileVC
        self.navigationController?.pushViewController(viewController, animated: true)
        //        self.sideMenuController?.embed(centerViewController: viewController)
    }
    func getDataFromSingleton()
    {
        let profile =  NSMutableDictionary(dictionary: (Singletons.sharedInstance.dictDriverProfile.object(forKey: "profile") as! NSDictionary))
        //         {
        
        
        //            NSMutableDictionary(Singletons.sharedInstance.dictDriverProfile.object(forKey: "profile") as NSDictionary).object(forKey: "profile")
        
        driverFullName = profile.object(forKey: "Fullname") as! String
        driverMobileNo = profile.object(forKey: "Email") as! String
        strImagPath = profile.object(forKey: "Image") as! String
        
        
        //        }
        //        if let profile =  NSMutableDictionary(dictionary: (Singletons.sharedInstance.dictDriverProfile.object(forKey: "profile") as NSDictionary).object(forKey: "profile") as) {
        //
        //
        //            //            NSMutableDictionary(Singletons.sharedInstance.dictDriverProfile.object(forKey: "profile") as NSDictionary).object(forKey: "profile")
        //
        //            driverFullName = profile.object(forKey: "Fullname") as! String
        //            driverMobileNo = profile.object(forKey: "MobileNo") as! String
        //
        //            strImagPath = profile.object(forKey: "Image") as! String
        //        }
        
        
        
        
        tableView.reloadData()
        
    }
    
    // ------------------------------------------------------------
    
    func moveToComingSoon() {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ComingSoonVC") as! ComingSoonVC
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    func settingsClick() {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SettingPasscodeVC") as! SettingPasscodeVC
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    //-------------------------------------------------------------
    // MARK: - Webservice Methods
    //-------------------------------------------------------------
    

    
    
    
}
// MARK: - UICollectionView DataSource & Delegate Methods

extension MenuController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrMenuTitle.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let customCell = self.CollectionView.dequeueReusableCell(withReuseIdentifier: "SideMenuCollectionViewCell", for: indexPath) as! SideMenuCollectionViewCell
        
        customCell.imgDetail?.image = UIImage.init(named:  "\(arrMenuIcons[indexPath.row])")
        customCell.lblTitle.text = arrMenuTitle[indexPath.row].localized
//        customCell.lblTitle.font = UIFont.regular(ofSize: 12.0)
        
        customCell.imgDetail?.tintColor = UIColor.black
        customCell.lblTitle.textColor = UIColor.black
        
        return customCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if arrMenuTitle[indexPath.row] == kMyJobs {
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MyJobsViewController") as! MyJobsViewController
            self.navigationController?.pushViewController(viewController, animated: true)
            sideMenuController?.toggle()
        }else if arrMenuTitle[indexPath.row] == kPaymentOption {
            let storyboard = UIStoryboard(name: "MyEarnings", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "MyEarningsViewController") as! MyEarningsViewController
            
            self.navigationController?.pushViewController(viewController, animated: true)
            sideMenuController?.toggle()
        }
        //        if arrMenuTitle[indexPath.row] == "New Booking" {
        //            NotificationCenter.default.post(name: NotificationForBookingNewTrip, object: nil)
        //            sideMenuController?.toggle()
        //
        //        }
        /* RJ Change
        if arrMenuTitle[indexPath.row] == "My Bookings"
        {
            NotificationCenter.default.post(name: OpenMyBooking, object: nil)
            sideMenuController?.toggle()
        }
        
        else if arrMenuTitle[indexPath.row] == "Payment Options" {
            NotificationCenter.default.post(name: OpenPaymentOption, object: nil)
            sideMenuController?.toggle()
        }
        else if arrMenuTitle[indexPath.row] == "Wallet" {
            NotificationCenter.default.post(name: OpenWallet, object: nil)
            sideMenuController?.toggle()
        }
        else if arrMenuTitle[indexPath.row] == "Favourites" {
            NotificationCenter.default.post(name: OpenFavourite, object: nil)
            sideMenuController?.toggle()
        }
        else if arrMenuTitle[indexPath.row] == "My Receipts" {
            NotificationCenter.default.post(name: OpenMyReceipt, object: nil)
            sideMenuController?.toggle()
        }
        else if arrMenuTitle[indexPath.row] == "Invite Friends" {
            NotificationCenter.default.post(name: OpenInviteFriend, object: nil)
            sideMenuController?.toggle()
        }
        else if arrMenuTitle[indexPath.row] == "My Ratings" {
            NotificationCenter.default.post(name: OpenFavourite, object: nil)
            sideMenuController?.toggle()
        }
        else if arrMenuTitle[indexPath.row] == "Previous Due" {
            NotificationCenter.default.post(name: OpenPastDues, object: nil)
            sideMenuController?.toggle()
        }
        else if arrMenuTitle[indexPath.row] == "Legal" {
            NotificationCenter.default.post(name: OpenSetting, object: nil)
            sideMenuController?.toggle()
        }
        else if arrMenuTitle[indexPath.row] == "Support" {
            UtilityClass.setCustomAlert(title: "Info Message".localized, message: "This feature is coming soon") { (index, title) in
            }
            return
            /* Rj Change
             NotificationCenter.default.post(name: OpenSupport, object: nil)
             sideMenuController?.toggle()
             */
        }
        else if arrMenuTitle[indexPath.row] == "Help" {
            
            UtilityClass.showAlert(appName, message: "This feature is coming soon", vc: self)
        } */
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        
//        let customCell = self.CollectionView.dequeueReusableCell(withReuseIdentifier: "SideMenuCollectionViewCell", for: indexPath) as! SideMenuCollectionViewCell
      
        /*
        let customCell = collectionView.cellForItem(at: indexPath) as! SideMenuCollectionViewCell
        customCell.imgDetail?.tintColor = themeYellowColor
        customCell.lblTitle.textColor = themeYellowColor
        
        */
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let customCell = collectionView.cellForItem(at: indexPath) as! SideMenuCollectionViewCell
        customCell.imgDetail?.tintColor = UIColor.black
        customCell.lblTitle.textColor = UIColor.black
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let MenuWidth = sideMenuController?.sideViewController.view.frame.width
//        let CollectionCellWidth = (MenuWidth! - 95.0) / 2
        
        let CollectionCellWidth = (MenuWidth! - 80.0) / 2
        return CGSize(width: CollectionCellWidth, height: CollectionCellWidth)
    }
}
class SideMenuCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imgDetail: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
}

/*
protocol delegateForTiCKPayVerifyStatus {
    
    func didRegisterCompleted()
}

//let KEnglish : String = "EN"
//let KSwiley : String = "SW"

class SideMenuTableViewController: UIViewController, delegateForTiCKPayVerifyStatus {
    
//    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var CollectionView: UICollectionView!
    
    @IBOutlet var lblLaungageName: UILabel!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblMobileNumber: UILabel!
    
    @IBOutlet weak var btnSignout: ThemeButton!
    
    @IBOutlet weak var btnSignOut1: UIButton! {
        didSet {
            btnSignOut1.layer.borderColor = UIColor.black.cgColor
            btnSignOut1.layer.borderWidth = 1.0
            btnSignOut1.setTitleColor(UIColor.black, for: .normal)
            btnSignOut1.layer.cornerRadius = 20
            btnSignOut1.setTitle("Sign out".localized, for: .normal)
        }
    }
    @IBOutlet weak var CollectionHeight: NSLayoutConstraint!
    
    var ProfileData = NSDictionary()
    
    var arrMenuIcons = [String]()
    var arrMenuTitle = [String]()
    var strSelectedLaungage = String()
    //-------------------------------------------------------------
    // MARK: - Base Methods
    //-------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.removeObserver(self, name: UpdateProfileNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.setProfileData), name: UpdateProfileNotification, object: nil)
        
        if let SelectedLanguage = UserDefaults.standard.value(forKey: "i18n_language") as? String {
            if SelectedLanguage == "en" {
                lblLaungageName.text = "SW"
            } else if SelectedLanguage == "sw" {
                 lblLaungageName.text = "EN"
            }
        }

        setProfileData()
        
        lblLaungageName.layer.cornerRadius = 5
        lblLaungageName.backgroundColor = themeYellowColor
        lblLaungageName.layer.borderColor = UIColor.black.cgColor
        lblLaungageName.layer.borderWidth = 0.5
        
        self.navigationController?.isNavigationBarHidden = false
        self.btnSignout.layer.cornerRadius = self.btnSignout.frame.size.height/2
        self.btnSignout.layer.masksToBounds = true
        self.btnSignout.setTitleColor(UIColor.black, for: .normal)
        
        //        giveGradientColor()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.SetRating), name: NSNotification.Name(rawValue: "rating"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(self.setNewBookingOnArray), name: NotificationForAddNewBooingOnSideMenu, object: nil)
//
//        if SingletonClass.sharedInstance.bookingId != "" {
//            setNewBookingOnArray()
//        }
        
        webserviceOfTickPayStatus()
        
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
         arrMenuIcons = ["icon_MyBookingUnselect","icon_UnSelectedWallet","img_mn_help_unselect","img_mn_receipt_unselect","ic_pay_unselect"]
//        arrMenuIcons = ["icon_MyBookingUnselect","icon_MyReceiptUnselect","icon_UnSelectedWallet","icon_InviteFriendUnselect","icon_FavouriteUnselect","icon_Legal","icon_Support"]
        
        //,"icon_PaymentOptionsUnselect","icon_UnSelectedWallet",,"icon_PaymentOptionsUnselect"
//                        "iconSettings","iconMyBooking","iconPackageHistory","iconLogOut"]
        
//        arrMenuTitle = ["My Booking","My Receipts","Invite Friends","My Ratings","Legal", "Support"]//"Favourites","Payment Options"
//                        "Settings","Become a \(appName) Driver","Package History","LogOut"]//,"Wallet"
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        UIApplication.shared.statusBarView?.backgroundColor = UIColor.clear
//        if UserDefaults.standard.value(forKey: "i18n_language") != nil {
//                        if let language = UserDefaults.standard.value(forKey: "i18n_language") as? String {
//                            if language == "sw" {
//                                setLayoutForswahilLanguage()
//                            }
//                            else {
//                                setLayoutForEnglishLanguage()
//                            }
//                        }
//                    }
         arrMenuTitle = ["My Bookings","Payment Options", "Help", "My Receipts", "Previous Due"]//"My Ratings","Legal", "Support"]//,"Payment Options"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
       setLocalition()
    }

    func setLocalition() {
        
    }
    
    @objc func setProfileData() {
        ProfileData = SingletonClass.sharedInstance.dictProfile
        
        self.imgProfile.layer.cornerRadius = self.imgProfile.frame.width / 2
        self.imgProfile.layer.borderWidth = 1.0
        self.imgProfile.layer.borderColor = UIColor.white.cgColor
        self.imgProfile.layer.masksToBounds = true
        
        self.imgProfile.sd_setShowActivityIndicatorView(true)
        self.imgProfile.sd_setIndicatorStyle(.whiteLarge)
        
        if SingletonClass.sharedInstance.isFromSocilaLogin {
            self.imgProfile.sd_setImage(with: URL(string: (WebserviceURLs.kImageBaseURL + (ProfileData.object(forKey: "Image") as! String)) ), completed: nil)
        } else {
            self.imgProfile.sd_setImage(with: URL(string: ((ProfileData.object(forKey: "Image") as! String))), completed: nil)
        }
        
       
//
        self.lblName.text = ProfileData.object(forKey: "Fullname") as? String
        
        self.lblMobileNumber.text = ProfileData.object(forKey: "Email") as? String
    }
    
    override func viewDidLayoutSubviews() {
//        self.CollectionHeight.constant = self.CollectionView.collectionViewLayout.collectionViewContentSize.height
    }
    

//    func setViewWillAppear() {
//                    if UserDefaults.standard.value(forKey: "i18n_language") != nil {
//                        if let language = UserDefaults.standard.value(forKey: "i18n_language") as? String {
//                            if language == "sw" {
//                                setLayoutForSwahilLanguage()
//                            }
//                            else {
//                                setLayoutForEnglishLanguage()
//                            }
//                        }
//                    }
//            }

        func setLayoutForswahilLanguage()
        {
            UserDefaults.standard.set("sw", forKey: "i18n_language")
            UserDefaults.standard.synchronize()
//            setLayoutForSwahilLanguage()
        }
    func setLayoutForenglishLanguage()
    {
        UserDefaults.standard.set("en", forKey: "i18n_language")
        UserDefaults.standard.synchronize()
//        setLayoutForSwahilLanguage()
//        setLayoutForEnglishLanguage()
    }
    @objc func SetRating() {
        self.CollectionView.reloadData()
    }
    
    @objc func setNewBookingOnArray() {
        
        if SingletonClass.sharedInstance.bookingId == "" {
            if (arrMenuTitle.contains("New Booking")) {
                arrMenuIcons.removeFirst()
                arrMenuTitle.removeFirst()
            }
        }
        
        if !(arrMenuTitle.contains("New Booking")) && SingletonClass.sharedInstance.bookingId != "" {
            arrMenuIcons.insert("icon_NewBookingUnselect", at: 0)
            arrMenuTitle.insert("New Booking", at: 0)
        }
        
        self.CollectionView.reloadData()
    }
    
    func giveGradientColor() {
        
        let colorTop =  UIColor(red: 0, green: 0, blue: 0, alpha: 1.0).cgColor
        let colorMiddle =  UIColor(red: 36/255, green: 24/255, blue: 3/255, alpha: 0.5).cgColor
        let colorBottom = UIColor(red: 64/255, green: 43/255, blue: 6/255, alpha: 0.8).cgColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [ colorTop, colorMiddle, colorBottom]
        gradientLayer.locations = [ 0.0, 0.5, 1.0]
        gradientLayer.frame = self.view.bounds
        self.view.layer.insertSublayer(gradientLayer, at: 0)
        
    }
    
    
    // MARK:- IBAction Methods
    
    @IBAction func btnSettings(_ sender: UIButton) {
        
        NotificationCenter.default.post(name: OpenEditProfile, object: nil)
        sideMenuController?.toggle()
    }
    
    
    @IBAction func btnLogoutAction(_ sender: UIButton) {
        RMUniversalAlert.show(in: self, withTitle:appName, message: "Are you sure you want to logout?".localized, cancelButtonTitle: nil, destructiveButtonTitle: nil, otherButtonTitles: ["Sign out".localized, "Cancel".localized], tap: {(alert, buttonIndex) in
            if (buttonIndex == 2) {
                
                let socket = (UIApplication.shared.delegate as! AppDelegate).SocketManager
                
                
                socket.off(SocketData.kReceiveGetEstimateFare)
                socket.off(SocketData.kNearByDriverList)
                socket.off(SocketData.kAskForTipsToPassengerForBookLater)
                socket.off(SocketData.kAskForTipsToPassenger)
                socket.off(SocketData.kAcceptBookingRequestNotification)
                socket.off(SocketData.kRejectBookingRequestNotification)
                socket.off(SocketData.kCancelTripByDriverNotficication)
                socket.off(SocketData.kPickupPassengerNotification)
                socket.off(SocketData.kBookingCompletedNotification)
                socket.off(SocketData.kAcceptAdvancedBookingRequestNotification)
                socket.off(SocketData.kRejectAdvancedBookingRequestNotification)
                socket.off(SocketData.kAdvancedBookingPickupPassengerNotification)
                socket.off(SocketData.kReceiveHoldingNotificationToPassenger)
                socket.off(SocketData.kAdvancedBookingTripHoldNotification)
                socket.off(SocketData.kReceiveDriverLocationToPassenger)
                socket.off(SocketData.kAdvancedBookingDetails)
                socket.off(SocketData.kInformPassengerForAdvancedTrip)
                socket.off(SocketData.kAcceptAdvancedBookingRequestNotify)
                //                Singletons.sharedInstance.isPasscodeON = false
                socket.disconnect()
                
                
                //                self.navigationController?.popToRootViewController(animated: true)
                
                (UIApplication.shared.delegate as! AppDelegate).GoToLogout()
            }
        })

        /*
        
        let socket = (UIApplication.shared.delegate as! AppDelegate).SocketManager
        
//        socket.off(SocketData.kPassengerCancelTripNotification)
//        socket.off(SocketData.kNearByDriverList)
//        socket.off(SocketData.kReceiveGetEstimateFare)
//        socket.off(SocketData.kAcceptBookingRequestNotification)
//        socket.off(SocketData.kRejectBookingRequestNotification)
//
//        socket.off(SocketData.kGetDriverLocation)
//        socket.off(SocketData.kPickupPassengerNotification)
//
//        socket.off(SocketData.kBookingDetails)
//        socket.off(SocketData.kAskForTipsToPassenger)
//
//
//        socket.off(SocketData.kAskForTipsToPassengerForBookLater)
//        socket.off(SocketData.kGetEstimateFare)
//
//        socket.off(SocketData.kReceiveMoneyNotify)
//        socket.off(SocketData.kAcceptAdvancedBookingRequestNotification)
//
//        socket.off(SocketData.kRejectAdvancedBookingRequestNotification)
//        socket.off(SocketData.kAcceptAdvancedBookingRequestNotify)
//
//        socket.off(SocketData.kAdvancedBookingPickupPassengerNotification)
//        socket.off(SocketData.kAdvancedBookingTripHoldNotification)
//        socket.off(SocketData.kAdvancedBookingDetails)
        
        socket.off(SocketData.kReceiveGetEstimateFare)
        socket.off(SocketData.kNearByDriverList)
        socket.off(SocketData.kAskForTipsToPassengerForBookLater)
        socket.off(SocketData.kAskForTipsToPassenger)
        socket.off(SocketData.kAcceptBookingRequestNotification)
        socket.off(SocketData.kRejectBookingRequestNotification)
        socket.off(SocketData.kCancelTripByDriverNotficication)
        socket.off(SocketData.kPickupPassengerNotification)
        socket.off(SocketData.kBookingCompletedNotification)
        socket.off(SocketData.kAcceptAdvancedBookingRequestNotification)
        socket.off(SocketData.kRejectAdvancedBookingRequestNotification)
        socket.off(SocketData.kAdvancedBookingPickupPassengerNotification)
        socket.off(SocketData.kReceiveHoldingNotificationToPassenger)
        socket.off(SocketData.kAdvancedBookingTripHoldNotification)
        socket.off(SocketData.kReceiveDriverLocationToPassenger)
        socket.off(SocketData.kAdvancedBookingDetails)
        socket.off(SocketData.kInformPassengerForAdvancedTrip)
        socket.off(SocketData.kAcceptAdvancedBookingRequestNotify)
        //                Singletons.sharedInstance.isPasscodeON = false
        socket.disconnect()
        
        for (key, value) in UserDefaults.standard.dictionaryRepresentation() {
            print("\(key) = \(value) \n")
            
            if key == "Token" {
                
            }
            else {
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
//        UserDefaults.standard.set(false, forKey: kIsSocketEmited)
//        UserDefaults.standard.synchronize()
        
        SingletonClass.sharedInstance.strPassengerID = ""
        UserDefaults.standard.removeObject(forKey: "profileData")
        SingletonClass.sharedInstance.isUserLoggedIN = false
        
        self.performSegue(withIdentifier: "unwindToContainerVC", sender: self)
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        
        UserDefaults.standard.removeObject(forKey: "Passcode")
        SingletonClass.sharedInstance.setPasscode = ""
        
        UserDefaults.standard.removeObject(forKey: "isPasscodeON")
        SingletonClass.sharedInstance.isPasscodeON = false
     */
    }
    
    @IBAction func btnLaungageClicked(_ sender: Any)
    {
        /* RJ Change
        if let SelectedLanguage = UserDefaults.standard.value(forKey: "i18n_language") as? String {
            if SelectedLanguage == "en" {
                setLayoutForswahilLanguage()
                lblLaungageName.text = "EN"
            } else if SelectedLanguage == "sw" {
                setLayoutForenglishLanguage()
                lblLaungageName.text = "SW"
            }

            self.navigationController?.loadViewIfNeeded()

            self.CollectionView.reloadData()
            (UIApplication.shared.delegate as! AppDelegate).isAlreadyLaunched = true
            NotificationCenter.default.post(name: OpenHome, object: nil)
            sideMenuController?.toggle()
        } */

//        if strSelectedLaungage == KEnglish
//        {
//            strSelectedLaungage = KSwiley
//
//            if UserDefaults.standard.value(forKey: "i18n_language") != nil {
//                if let language = UserDefaults.standard.value(forKey: "i18n_language") as? String {
//                        if language == "en"
//                        {
//                            setLayoutForswahilLanguage()
//
//                            print("Swahil")
//                    }
//                }
//            }
//        }
//        else
//        {
//            strSelectedLaungage = KEnglish
//            if UserDefaults.standard.value(forKey: "i18n_language") != nil {
//                if let language = UserDefaults.standard.value(forKey: "i18n_language") as? String {
//                    if language == "sw" {
////                        setLayoutForEnglishLanguage()
//                        setLayoutForenglishLanguage()
//                        print("English")
//                    }
//                }
//            }
//        }
//
//        lblLaungageName.text = strSelectedLaungage
    }
    
    // MARK: - Table view data source
    
    /*
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0
        {
            return 1
        }
        else
        {
            return arrMenuIcons.count
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if (indexPath.section == 0)
        {
            let cellHeader = tableView.dequeueReusableCell(withIdentifier: "MainHeaderTableViewCell") as! MainHeaderTableViewCell
            cellHeader.selectionStyle = .none
            cellHeader.imgProfile.layer.cornerRadius = cellHeader.imgProfile.frame.width / 2
            cellHeader.imgProfile.layer.borderWidth = 1.0
            cellHeader.imgProfile.layer.borderColor = UIColor.white.cgColor
            cellHeader.imgProfile.layer.masksToBounds = true
            
            cellHeader.imgProfile.sd_setImage(with: URL(string: ProfileData.object(forKey: "Image") as! String), completed: nil)
            cellHeader.lblName.text = ProfileData.object(forKey: "Fullname") as? String
            
            cellHeader.lblMobileNumber.text = ProfileData.object(forKey: "MobileNo") as? String
            cellHeader.lblRating.text = SingletonClass.sharedInstance.passengerRating
            
            return cellHeader
        }
        else
        {
            let cellMenu = tableView.dequeueReusableCell(withIdentifier: "ContentTableViewCell") as! ContentTableViewCell
            
            cellMenu.imgDetail?.image = UIImage.init(named:  "\(arrMenuIcons[indexPath.row])")
            cellMenu.selectionStyle = .none
            
            cellMenu.lblTitle.text = arrMenuTitle[indexPath.row]
            
            return cellMenu
        }
        
        
        // Configure the cell...
        
        //        return cellHeader
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            let next = self.storyboard?.instantiateViewController(withIdentifier: "EditProfileViewController") as! EditProfileViewController
            self.navigationController?.pushViewController(next, animated: true)
            
        }
        else if (indexPath.section == 1)
        {
            if arrMenuTitle[indexPath.row] == "New Booking" {
                NotificationCenter.default.post(name: NotificationForBookingNewTrip, object: nil)
                sideMenuController?.toggle()
                
            }
            if arrMenuTitle[indexPath.row] == "My Booking"
            {
                NotificationCenter.default.post(name: OpenMyBooking, object: nil)
                sideMenuController?.toggle()
            }
            
            if arrMenuTitle[indexPath.row] == "Payment Options" {
                NotificationCenter.default.post(name: OpenPaymentOption, object: nil)
                sideMenuController?.toggle()
            }
            else if arrMenuTitle[indexPath.row] == "Wallet" {
                NotificationCenter.default.post(name: OpenWallet, object: nil)
                sideMenuController?.toggle()
            }
            else if arrMenuTitle[indexPath.row] == "Favourites" {
                NotificationCenter.default.post(name: OpenFavourite, object: nil)
                sideMenuController?.toggle()
            }
            else if arrMenuTitle[indexPath.row] == "My Receipts" {
                NotificationCenter.default.post(name: OpenMyReceipt, object: nil)
                sideMenuController?.toggle()
            }
            else if arrMenuTitle[indexPath.row] == "Invite Friends" {
                NotificationCenter.default.post(name: OpenInviteFriend, object: nil)
                sideMenuController?.toggle()
            }
            else if arrMenuTitle[indexPath.row] == "Settings" {
                NotificationCenter.default.post(name: OpenSetting, object: nil)
                sideMenuController?.toggle()
            }
            else if arrMenuTitle[indexPath.row] == "Become a \(appName) Driver" {
                UIApplication.shared.openURL(NSURL(string: "https://itunes.apple.com/us/app/pick-n-go-driver/id1320783710?mt=8")! as URL)
            }
            else if arrMenuTitle[indexPath.row] == "Package History"
            {
                let next = self.storyboard?.instantiateViewController(withIdentifier: "PackageHistoryViewController") as! PackageHistoryViewController
                self.navigationController?.pushViewController(next, animated: true)
            }
            
            
            if (arrMenuTitle[indexPath.row] == "LogOut")
            {
                self.performSegue(withIdentifier: "unwindToContainerVC", sender: self)
                UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
                
                UserDefaults.standard.removeObject(forKey: "Passcode")
                SingletonClass.sharedInstance.setPasscode = ""
                
                UserDefaults.standard.removeObject(forKey: "isPasscodeON")
                SingletonClass.sharedInstance.isPasscodeON = false
                
            }
            //            else if (indexPath.row == arrMenuTitle.count - 2)
            //            {
            //                self.performSegue(withIdentifier: "pushToBlank", sender: self)
            //            }
        }
        
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section == 0)
        {
            return 130
        }
        else
        {
            return 42
        }
    }
    */
    
    
    func didRegisterCompleted() {
        
        webserviceOfTickPayStatus()
    }
    
    //-------------------------------------------------------------
    // MARK: - Custom Methods
    //-------------------------------------------------------------
    
    func navigateToTiCKPay() {
        //        webserviceOfTickPayStatus()
        /* RJ Change
        if self.varifyKey == 0 {
            let next = self.storyboard?.instantiateViewController(withIdentifier: "TickPayRegistrationViewController") as! TickPayRegistrationViewController
            next.delegateForVerifyStatus = self
            self.navigationController?.pushViewController(next, animated: true)
        }
            
        else if self.varifyKey == 1 {
            let next = self.storyboard?.instantiateViewController(withIdentifier: "TiCKPayNeedToVarifyViewController") as! TiCKPayNeedToVarifyViewController
            self.navigationController?.pushViewController(next, animated: true)
        }
            
        else if self.varifyKey == 2 {
            let next = self.storyboard?.instantiateViewController(withIdentifier: "PayViewController") as! PayViewController
            self.navigationController?.pushViewController(next, animated: true)
        }
         */
    }
    
    @IBAction func btnProfilePickClicked(_ sender: Any)
    {
//        let next = self.storyboard?.instantiateViewController(withIdentifier: "EditProfileViewController") as! EditProfileViewController
//        self.navigationController?.pushViewController(next, animated: true)
//        NotificationCenter.default.post(name: OpenEditProfile, object: nil)
//        sideMenuController?.toggle()
    }
    
    
    //-------------------------------------------------------------
    // MARK: - Webservice Methods
    //-------------------------------------------------------------
    
    var varifyKey = Int()
    func webserviceOfTickPayStatus() {
        
      /* RJ Change
         webserviceForTickpayApprovalStatus(SingletonClass.sharedInstance.strPassengerID as AnyObject) { (result, status) in
            
            if (status) {
                print(result)
                
                if let id = (result as! [String:AnyObject])["Verify"] as? String {
                    
                    //                    SingletonClass.sharedInstance.TiCKPayVarifyKey = Int(id)!
                    self.varifyKey = Int(id)!
                }
                else if let id = (result as! [String:AnyObject])["Verify"] as? Int {
                    
                    //                    SingletonClass.sharedInstance.TiCKPayVarifyKey = id
                    self.varifyKey = id
                }
                
            }
            else {
                print(result)
            }
        } */
    }
    
}


// MARK: - UICollectionView DataSource & Delegate Methods

extension MenuController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrMenuTitle.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let customCell = self.CollectionView.dequeueReusableCell(withReuseIdentifier: "SideMenuCollectionViewCell", for: indexPath) as! SideMenuCollectionViewCell
        
        customCell.imgDetail?.image = UIImage.init(named:  "\(arrMenuIcons[indexPath.row])")
        customCell.lblTitle.text = arrMenuTitle[indexPath.row].localized
//        customCell.lblTitle.font = UIFont.regular(ofSize: 12.0)
        
        customCell.imgDetail?.tintColor = UIColor.black
        customCell.lblTitle.textColor = UIColor.black
        
        return customCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //        if arrMenuTitle[indexPath.row] == "New Booking" {
        //            NotificationCenter.default.post(name: NotificationForBookingNewTrip, object: nil)
        //            sideMenuController?.toggle()
        //
        //        }
        if arrMenuTitle[indexPath.row] == "My Bookings"
        {
            NotificationCenter.default.post(name: OpenMyBooking, object: nil)
            sideMenuController?.toggle()
        }
        
        else if arrMenuTitle[indexPath.row] == "Payment Options" {
            NotificationCenter.default.post(name: OpenPaymentOption, object: nil)
            sideMenuController?.toggle()
        }
        else if arrMenuTitle[indexPath.row] == "Wallet" {
            NotificationCenter.default.post(name: OpenWallet, object: nil)
            sideMenuController?.toggle()
        }
        else if arrMenuTitle[indexPath.row] == "Favourites" {
            NotificationCenter.default.post(name: OpenFavourite, object: nil)
            sideMenuController?.toggle()
        }
        else if arrMenuTitle[indexPath.row] == "My Receipts" {
            NotificationCenter.default.post(name: OpenMyReceipt, object: nil)
            sideMenuController?.toggle()
        }
        else if arrMenuTitle[indexPath.row] == "Invite Friends" {
            NotificationCenter.default.post(name: OpenInviteFriend, object: nil)
            sideMenuController?.toggle()
        }
        else if arrMenuTitle[indexPath.row] == "My Ratings" {
            NotificationCenter.default.post(name: OpenFavourite, object: nil)
            sideMenuController?.toggle()
        }
        else if arrMenuTitle[indexPath.row] == "Previous Due" {
            NotificationCenter.default.post(name: OpenPastDues, object: nil)
            sideMenuController?.toggle()
        }
        else if arrMenuTitle[indexPath.row] == "Legal" {
            NotificationCenter.default.post(name: OpenSetting, object: nil)
            sideMenuController?.toggle()
        }
        else if arrMenuTitle[indexPath.row] == "Support" {
            UtilityClass.setCustomAlert(title: "Info Message".localized, message: "This feature is coming soon") { (index, title) in
            }
            return
            /* Rj Change
             NotificationCenter.default.post(name: OpenSupport, object: nil)
             sideMenuController?.toggle()
             */
        }
        else if arrMenuTitle[indexPath.row] == "Help" {
            
            UtilityClass.showAlert(appName, message: "This feature is coming soon", vc: self)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        
//        let customCell = self.CollectionView.dequeueReusableCell(withReuseIdentifier: "SideMenuCollectionViewCell", for: indexPath) as! SideMenuCollectionViewCell
        
        let customCell = collectionView.cellForItem(at: indexPath) as! SideMenuCollectionViewCell
        customCell.imgDetail?.tintColor = themeYellowColor
        customCell.lblTitle.textColor = themeYellowColor
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let customCell = collectionView.cellForItem(at: indexPath) as! SideMenuCollectionViewCell
        customCell.imgDetail?.tintColor = UIColor.black
        customCell.lblTitle.textColor = UIColor.black
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let MenuWidth = sideMenuController?.sideViewController.view.frame.width
//        let CollectionCellWidth = (MenuWidth! - 95.0) / 2
        
        let CollectionCellWidth = (MenuWidth! - 80.0) / 2
        return CGSize(width: CollectionCellWidth, height: CollectionCellWidth)
    }
}

*/
