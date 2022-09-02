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

class MenuController: UIViewController, UITableViewDataSource, UITableViewDelegate
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
   // @IBOutlet weak var btnLiveHelp: UIButton!
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
      //  btnLiveHelp.underline()
        strSelectedLaungage = KEnglish
      
        arrMenuTitle = [kMyJobs,kPaymentOption,kHelp,kInviteFriend]
               
        arrMenuIcons = [kiconMyJobs,kiconPaymentOption,kIconHelp,kiconInviteFriend]
        /*
        arrMenuTitle = [kMyJobs,kPaymentOption,kWallet,kMyRating,kInviteFriend,kSettings,kLegal,kSupport,kLogout]
        
        arrMenuIcons = [kiconMyJobs,kiconPaymentOption,kiconWallet,kiconMyRating,kInviteFriend,kiconSettings,klegal
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
        
//        let colorTop =  UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0).cgColor//(red: 0, green: 0, blue: 0, alpha: 1.0).cgColor
//        let colorMiddle =  UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0).cgColor//UIColor(red: 36/255, green: 24/255, blue: 3/255, alpha: 0.5).cgColor
//        let colorBottom = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0).cgColor//UIColor(red: 64/255, green: 43/255, blue: 6/255, alpha: 0.8).cgColor
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
    @IBAction func btnLiveHelpAction(_ sender: Any) {
        //sideMenuController?.toggle()
        
       
    }
    
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
//        let decodeResults = Singletons.sharedInstance.dictDriverProfile
//        var strName = String()
//
//        if decodeResults!.count != 0
//        {
//            strName = ((decodeResults!).object(forKey: "profile") as! NSDictionary).object(forKey: "Fullname") as! String
//        }
//        var strReferralCode = String()
//
//        if let ReferralCode = (decodeResults?.object(forKey: "profile") as! NSDictionary).object(forKey: "ReferralCode") as? String {
//            strReferralCode = ReferralCode
//        }
//        let strContent = "\(strName)  \("has invited you to become a".localized) \("App Name".localized).\n \n\("For iOS Click Here : ".localized) \(appName.kAPPUrliOS) \n \n\("For Android Click Here : ".localized) \(appName.kAPPUrlAndroid)" //\n\n \("Your invite code is :".localized) \(strReferralCode)
//
//        let share = [strContent]
//
//        let activityViewController = UIActivityViewController(activityItems: share, applicationActivities: nil)
//        activityViewController.popoverPresentationController?.sourceView = self.view
//        self.present(activityViewController, animated: true, completion: nil)
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
    
    func webserviceOFDeleteAccount() {
        webserviceForDeleteAccount(Singletons.sharedInstance.strDriverID as AnyObject) { (result, status) in
            if (status) {
                self.webserviceOFSignOut()
            }
            else
            {
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
    
    //MARK: Button Action
    @IBAction func btnDeleteAction(_ sender: UIButton) {
        let refreshAlert = UIAlertController(title: "Delete Account", message: "Are you sure you want to delete your account?", preferredStyle: UIAlertController.Style.alert)

        refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            self.sideMenuController?.toggle()
            self.webserviceOFDeleteAccount()
        }))

        refreshAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
            self.sideMenuController?.toggle()
        }))

        present(refreshAlert, animated: true, completion: nil)
       
    }
    
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
        
        driverFullName = "\(profile.object(forKey: "Firstname") as! String) \(profile.object(forKey: "Lastname") as! String)" 
        driverMobileNo = profile.object(forKey: "Email") as! String
        strImagPath = profile.object(forKey: "Image") as! String
        
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
        if(arrMenuTitle[indexPath.row].localized == "SOS")
        {
            customCell.lblTitle.textColor = .red
        }
        else
        {
        customCell.imgDetail?.tintColor = UIColor.black
        customCell.lblTitle.textColor = UIColor.black
        }
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
        else if arrMenuTitle[indexPath.row] == kInviteFriend {
            self.InviteFriend()
            sideMenuController?.toggle()
        }
        else if arrMenuTitle[indexPath.row] == kHelp {
//            self.dialNumber(number: Singletons.sharedInstance.DispatchCall)
            self.alertForHelpOptions()
        }
    }
    
    func alertForHelpOptions()
    {
        let reasonsVC = CancelAlertViewController(nibName: "CancelAlertViewController", bundle: nil)
        
        reasonsVC.isHelp = true
        reasonsVC.okPressedClosure = { (reason) in
            
        }
        reasonsVC.modalPresentationStyle = .overCurrentContext
        self.present(reasonsVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        

    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        
        if(arrMenuTitle[indexPath.row].localized != "SOS")
        {
            let customCell = collectionView.cellForItem(at: indexPath) as! SideMenuCollectionViewCell
            customCell.imgDetail?.tintColor = UIColor.black
            customCell.lblTitle.textColor = UIColor.black
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let MenuWidth = sideMenuController?.sideViewController.view.frame.width
//        let CollectionCellWidth = (MenuWidth! - 95.0) / 2
        
        let CollectionCellWidth = (MenuWidth! - 80.0) / 2
        return CGSize(width: CollectionCellWidth, height: CollectionCellWidth)
    }
    func dialNumber(number : String) {

     if let url = URL(string: "tel://\(number)"),
       UIApplication.shared.canOpenURL(url) {
          if #available(iOS 10, *) {
            UIApplication.shared.open(url, options: [:], completionHandler:nil)
           } else {
               UIApplication.shared.openURL(url)
           }
       } else {
                // add error message here
       }
    }
}
class SideMenuCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imgDetail: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
}

