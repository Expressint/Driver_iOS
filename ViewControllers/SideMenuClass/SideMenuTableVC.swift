//
//  SideMenuTableVC.swift
//  Peppea User
//
//  Created by Excellent Webworld on 28/06/19.
//  Copyright © 2017 Excellent Webworld. All rights reserved.
//

import UIKit

class SideMenuCell: UITableViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    
}

let KEnglish : String = "EN"
let KSwiley : String = "SW"

class SideMenuTableVC: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var logoutTouchView: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var lblLogout: UILabel!
    @IBOutlet weak var tblDataHeight: NSLayoutConstraint!
    
    
    var aryItemNames = [String]()
    var aryItemIcons = [String]()
    
    var driverFullName = String()
    var driverImage = UIImage()
    var driverEmail = String()
    var strImagPath = String()
    var strSelectedLaungage = String()
    private var previousIndex: NSIndexPath?
    
    var arrMenuIcons = [String]()
    var arrMenuTitle = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.new, context: nil)
        
        strSelectedLaungage = KEnglish
        self.getDataFromSingleton()
        self.setProfileData()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        self.tableView.layer.removeAllAnimations()
        self.tblDataHeight.constant = self.tableView.contentSize.height
        UIView.animate(withDuration: 0.5) {
            self.updateViewConstraints()
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if((Localize.currentLanguage() == Languages.English.rawValue)){
            Localize.setCurrentLanguage(Languages.English.rawValue)
        }else{
            Localize.setCurrentLanguage(Languages.Spanish.rawValue)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeLanguage), name: Notification.Name(rawValue: LCLLanguageChangeNotification), object: nil)
        setLocalization()
    }
    
    @objc func changeLanguage(){
        self.setLocalization()
    }
    
    func getDataFromSingleton() {
        let profile =  NSMutableDictionary(dictionary: (Singletons.sharedInstance.dictDriverProfile.object(forKey: "profile") as! NSDictionary))
        
        driverFullName = "\(profile.object(forKey: "Firstname") as! String) \(profile.object(forKey: "Lastname") as! String)"
        driverEmail = profile.object(forKey: "Email") as! String
        strImagPath = profile.object(forKey: "Image") as! String
        
        tableView.reloadData()
        
    }
    func setLocalization() {
        arrMenuTitle = ["My Jobs".localized, "Hourly Bookings".localized, "My Earnings".localized,"Help".localized,"Invite Friend".localized, "Settings".localized, "Select Language".localized]
        arrMenuIcons = [kiconMyJobs,kiconMyJobs,kiconPaymentOption,kIconHelp,kiconInviteFriend,kiconSettings,kLocation]
        
        lblLogout.text = "Sign out".localized
        deleteButton.setTitle("Delete Account".localized, for: .normal)
        
        tableView.reloadData()
    }
    
    @objc func setProfileData() {
        imgProfile.layer.cornerRadius = imgProfile.frame.width / 2
        imgProfile.layer.masksToBounds = true
        imgProfile.layer.borderColor = ThemeAppMainColor.cgColor
        imgProfile.layer.borderWidth = 1.0
        lblName.text = driverFullName
        lblEmail.text = driverEmail
        imgProfile.sd_setImage(with: URL(string: strImagPath))
    }

    @IBAction func ProfileButtonTapped(_ sender: UIButton) {
//        sideMenuController?.toggle()
//        let profile = UIStoryboard(name: "Profile", bundle: nil)
//        let viewController = profile.instantiateViewController(withIdentifier: "EditDriverProfileVC") as! EditDriverProfileVC
//        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func LogoutButtonTapped(_ sender: UIButton) {
        let LogoutConfirmation = UIAlertController(title: "App Name".localized, message: "Are you sure you want to logout?".localized, preferredStyle: .alert)
        LogoutConfirmation.addAction(UIAlertAction(title: "Logout".localized, style: .destructive, handler: { (UIAlertAction) in
            self.webserviceOFSignOut()
        }))
        LogoutConfirmation.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil))
        self.present(LogoutConfirmation, animated: true, completion: nil)
    }
    
    @IBAction func deleteAccountAction() {
        showDeleteSheet()
    }

    func showDeleteSheet() {
        let refreshAlert = UIAlertController(title: "Delete Account".localized, message: "Are you sure you want to delete your account?".localized, preferredStyle: UIAlertController.Style.alert)

        refreshAlert.addAction(UIAlertAction(title: "Yes".localized, style: .default, handler: { (action: UIAlertAction!) in
            self.sideMenuController?.toggle()
            self.webserviceOFDeleteAccount()
        }))

        refreshAlert.addAction(UIAlertAction(title: "No".localized, style: .cancel, handler: { (action: UIAlertAction!) in
            self.sideMenuController?.toggle()
        }))

        present(refreshAlert, animated: true, completion: nil)
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
}

// MARK: - Table view data source
extension SideMenuTableVC: UITableViewDelegate, UITableViewDataSource {


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrMenuTitle.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellMenu = tableView.dequeueReusableCell(withIdentifier: "side_menu_cell", for: indexPath) as! SideMenuCell
        //cellMenu.setValues(menuItemArray[indexPath.row])
        cellMenu.iconImageView?.image = UIImage.init(named:  "\(arrMenuIcons[indexPath.row])")
        cellMenu.titleLabel.text = arrMenuTitle[indexPath.row].localized
        cellMenu.iconImageView?.tintColor = UIColor.black
        cellMenu.titleLabel.textColor = UIColor.black
        cellMenu.selectionStyle = .none
        return cellMenu
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //        if arrMenuTitle[indexPath.row] == "New Booking" {
        //            NotificationCenter.default.post(name: NotificationForBookingNewTrip, object: nil)
        //            sideMenuController?.toggle()
        //
        //        } ["My Jobs".localized,"My Earnings".localized,"Help".localized,"Invite Friend".localized]
        if arrMenuTitle[indexPath.row] == "My Jobs".localized {
            sideMenuController?.toggle()
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MyJobsViewController") as! MyJobsViewController
            self.navigationController?.pushViewController(viewController, animated: true)
        } else if arrMenuTitle[indexPath.row] == "Hourly Bookings".localized {
            sideMenuController?.toggle()
            let storyboard = UIStoryboard(name: "MyEarnings", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "TourTripHistoryVC") as! TourTripHistoryVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if arrMenuTitle[indexPath.row] == "My Earnings".localized {
            sideMenuController?.toggle()
            let storyboard = UIStoryboard(name: "MyEarnings", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "MyEarningsViewController") as! MyEarningsViewController
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        else if arrMenuTitle[indexPath.row] == "Help".localized {
            sideMenuController?.toggle()
            self.alertForHelpOptions()
        }
        else if arrMenuTitle[indexPath.row] == "Invite Friend".localized {
            sideMenuController?.toggle()
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "InviteDriverViewController") as! InviteDriverViewController
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        else if arrMenuTitle[indexPath.row] == "Settings".localized {
            sideMenuController?.toggle()
            let profile = UIStoryboard(name: "Profile", bundle: nil)
            let viewController = profile.instantiateViewController(withIdentifier: "EditDriverProfileVC") as! EditDriverProfileVC
            self.navigationController?.pushViewController(viewController, animated: true)
        }else if arrMenuTitle[indexPath.row] == "Select Language".localized {
            sideMenuController?.toggle()
            showSheetForLanguageChange()
        }
    }
    
    func alertForHelpOptions() {
        let reasonsVC = CancelAlertViewController(nibName: "CancelAlertViewController", bundle: nil)
        
        reasonsVC.isHelp = true
        reasonsVC.okPressedClosure = { (reason) in
            
        }
        reasonsVC.modalPresentationStyle = .overCurrentContext
        self.present(reasonsVC, animated: true)
    }
    
    func showSheetForLanguageChange() {
        let alert = UIAlertController(title: "Select Language".localized, message: "Please Select an Option".localized, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "English".localized, style: .default , handler:{ (UIAlertAction)in
            Localize.setCurrentLanguage(Languages.English.rawValue)
        }))
        
        alert.addAction(UIAlertAction(title: "Spanish".localized, style: .default , handler:{ (UIAlertAction)in
            Localize.setCurrentLanguage(Languages.Spanish.rawValue)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler:{ (UIAlertAction)in
            print("User click Cancel")
        }))
        
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
    }

}

extension UIImage {

    func imageWithSize(scaledToSize newSize: CGSize) -> UIImage {

        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }

}
