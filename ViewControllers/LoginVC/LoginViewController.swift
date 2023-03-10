 //
 //  LoginViewController.swift
 //  TiCKTOC-Driver
 //
 //  Created by Excellent Webworld on 12/10/17.
 //  Copyright © 2017 Excellent Webworld. All rights reserved.
 //
 
 import UIKit
 import CoreLocation
import DropDown
 //import ACFloatingTextfield_Swift
 
 class LoginViewController: UIViewController, CLLocationManagerDelegate,UITextFieldDelegate {
    
    var manager = CLLocationManager()
    var currentLocation = CLLocation()
    var strLatitude = Double()
    var strLongitude = Double()
    var strEmailForForgotPassword = String()
    //-------------------------------------------------------------
    // MARK: - Outlets
    //-------------------------------------------------------------
    
    //textFiled
    @IBOutlet weak var txtMobile: ThemeTextField!
    @IBOutlet weak var txtPassword: ThemeTextField!
    
    @IBOutlet weak var lblDonTHaveAnyAccount: UILabel!
    //view
    @IBOutlet weak var viewLogin: UIView!
    //    @IBOutlet weak var viewMain: UIView!
    //view
    @IBOutlet weak var btnForgotPassWord: UIButton!
    @IBOutlet var btnSignIn: UIButton!
     @IBOutlet var btnSignUp: UIButton!
     @IBOutlet weak var segmentLang: UISegmentedControl!
     @IBOutlet weak var btnSelectLanguage: UIButton!
     @IBOutlet weak var btnEnglish: UIButton!
     
    //    @IBOutlet weak var constraintHeightOfLogo: NSLayoutConstraint! // 140
    //    @IBOutlet weak var constraintHeightOfTextFields: NSLayoutConstraint! // 50
    //    @IBOutlet weak var constraintTopOfLogo: NSLayoutConstraint! // 60
    
    
    //-------------------------------------------------------------
    // MARK: - Base Methods
    //-------------------------------------------------------------
    
    func setLocalization() {
        self.txtMobile.placeholder = "Email/Mobile Number".localized
        self.txtPassword.placeholder = "Password".localized
        self.btnForgotPassWord.setTitle("Forgot Password".localized, for: .normal)
        self.btnSignIn.setTitle("Sign In".localized, for: .normal)
        self.btnSignUp.setTitle("Sign Up".localized, for: .normal)
        self.btnSignUp.underline(text: "Sign Up".localized)
        self.lblDonTHaveAnyAccount.text = "Don't have an Account?".localized
        //btnSelectLanguage.setTitle("Select Language".localized, for: .normal)
    }
    
    override func loadView() {
        super.loadView()
          self.webserviceOfAppSetting()

//        txtMobile.text = "3698523698"
//            txtPassword.text = "12345678"
    
//            Utilities.setStatusBarColor(color: UIColor.clear)
    
//            if Connectivity.isConnectedToInternet()
//            {
//                print("Yes! internet is available.")
//                self.webserviceOfAppSetting()
                // do some tasks..
//            }
//            else
//            {
//                UtilityClass.showAlertWithCompletion(appName.kAPPName, message: "Sorry! Not connected to internet".localized, vc: self) { (status) in
//                    self.navigationController?.popViewController(animated: false)
//                }
////                UtilityClass.showAlert(appName.kAPPName, message: "Sorry! Not connected to internet".localized, vc: self)
//                return
//            }
        
//            if Connectivity.isConnectedToInternet()
//            {
//                print("Yes! internet is available.")
//                // do some tasks..
//            }
//            else {
//                UtilityClass.showAlert(appName.kAPPName, message: "Sorry! Not connected to internet".localized, vc: self)
//            }
    
//            webserviceOfAppSetting()
    //
        }
     
     @objc func changeLanguage(){
         self.setLocalization()
     }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
       
        btnSelectLanguage.titleLabel?.numberOfLines = 0
        
        manager.delegate = self
        txtMobile.delegate = self
        txtPassword.delegate = self
    
        btnForgotPassWord.setTitleColor(ThemeAppTextColor, for: .normal)
        btnSignUp.setTitleColor(ThemeAppTextColor, for: .normal)
        lblDonTHaveAnyAccount.textColor = ThemeAppTextColor
        
//        txtMobile.text = "9898989898"//"1111111111"
//        txtPassword.text = "12345678"
        
        Utilities.setStatusBarColor(color: UIColor.clear)
      
        //
        
//        btnSignUp.layer.cornerRadius = 3.0
//        btnSignUp.layer.borderColor = ThemeAppTextColor.cgColor
//        btnSignUp.layer.borderWidth = 1.0
//        btnSignUp.clipsToBounds = true
        //
        //        if DeviceType.IS_IPHONE_4_OR_LESS || DeviceType.IS_IPAD {
        //            constraintHeightOfLogo.constant = 120
        //            constraintHeightOfTextFields.constant = 35
        //            constraintTopOfLogo.constant = 40
        //        }
        //        self.viewMain.isHidden = false
        checkPass()
        
        strLatitude = 0.0
        strLongitude = 0.0
        
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            
            if manager.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization)) || manager.responds(to: #selector(CLLocationManager.requestAlwaysAuthorization))
            {
                if manager.location != nil
                {
                    currentLocation = manager.location!
                    strLatitude = currentLocation.coordinate.latitude
                    strLongitude = currentLocation.coordinate.longitude
                }
                manager.startUpdatingLocation()
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("goToRegister"), object: nil)

        // Do any additional setup after loading the view.
    }
     
     
     @IBAction func btnSelectLangAction(_ sender: Any) {
        // self.SelectLangDropdownSetup()
         
         self.btnSelectLanguage.isSelected = true
         self.btnEnglish.isSelected = false
         Localize.setCurrentLanguage(Languages.Spanish.rawValue)
         
         self.btnSelectLanguage.layer.borderColor = UIColor(hex: "02A64D").cgColor
         self.btnSelectLanguage.backgroundColor = UIColor(hex: "02A64D")
         self.btnSelectLanguage.layer.borderWidth = 1
         self.btnSelectLanguage.layer.cornerRadius = 5
         
         self.btnEnglish.layer.borderColor = UIColor.white.cgColor
         self.btnEnglish.backgroundColor = UIColor.clear
         self.btnEnglish.layer.borderWidth = 1
         self.btnEnglish.layer.cornerRadius = 5
     }
     
     @IBAction func btnEnglishAction(_ sender: Any) {
        // self.SelectLangDropdownSetup()
         
         self.btnSelectLanguage.isSelected = false
         self.btnEnglish.isSelected = true
         Localize.setCurrentLanguage(Languages.English.rawValue)
         
         self.btnEnglish.layer.borderColor = UIColor(hex: "02A64D").cgColor
         self.btnEnglish.backgroundColor = UIColor(hex: "02A64D")
         self.btnEnglish.layer.borderWidth = 1
         self.btnEnglish.layer.cornerRadius = 5
         
         self.btnSelectLanguage.layer.borderColor = UIColor.white.cgColor
         self.btnSelectLanguage.backgroundColor = UIColor.clear
         self.btnSelectLanguage.layer.borderWidth = 1
         self.btnSelectLanguage.layer.cornerRadius = 5
         
     }
     
     
     @objc func indexChanged(_ sender: UISegmentedControl) {
//         if segmentLang.selectedSegmentIndex == 0 {
//             Localize.setCurrentLanguage(Languages.English.rawValue)
//         } else if segmentLang.selectedSegmentIndex == 1 {
//             Localize.setCurrentLanguage(Languages.Spanish.rawValue)
//         }
     }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        
        if((Localize.currentLanguage() == Languages.English.rawValue)){
            self.btnEnglishAction(self.btnEnglish)
        }else{
            self.btnSelectLangAction(self.btnSelectLanguage)
        }
        
//        segmentLang.setTitleColor(.white)
//        segmentLang.selectedSegmentIndex = (Localize.currentLanguage() == Languages.English.rawValue) ? 0 : 1
//        segmentLang.addTarget(self, action: #selector(indexChanged(_:)), for: .valueChanged)
        NotificationCenter.default.addObserver(self, selector: #selector(changeLanguage), name: Notification.Name(rawValue: LCLLanguageChangeNotification), object: nil)
        
        self.setLocalization()
//        self.title = "Ingia".localized
        
        self.checkForAppUpdate()
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
//        btnSignUp.layer.cornerRadius = btnSignUp.frame.size.height - 50
//        btnSignUp.clipsToBounds = true
//        
        btnSignIn.layer.cornerRadius = btnSignIn.frame.size.height/2
        btnSignIn.clipsToBounds = true
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
     
     @objc func methodOfReceivedNotification(notification: Notification) {
         self.gotoRegister()
     }
    
     func checkForAppUpdate() {
         if UserDefaults.standard.bool(forKey: kIsUpdateAvailable) == true {
             print("Update app...")
             if !UIApplication.topViewController()!.isKind(of: UIAlertController.self) {
                 
                 let alert = UIAlertController(title: "App Name".localized, message: UserDefaults.standard.string(forKey: kIsUpdateMessage) ?? "", preferredStyle: .alert)
                 let UPDATE = UIAlertAction(title: "Update".localized, style: .default, handler: { ACTION in
                     UIApplication.shared.open((NSURL(string: appName.kAPPUrl)! as URL), options: [:], completionHandler: { (status) in

                     })
                 })
                 let Cancel = UIAlertAction(title: "Register".localized, style: .default, handler: { ACTION in
                     self.gotoRegister()
                 })
                 alert.addAction(UPDATE)
                 alert.addAction(Cancel)
                 self.present(alert, animated: true, completion: nil)
             }
         }
     }
    
    //-------------------------------------------------------------
    // MARK: - Actions
    //-------------------------------------------------------------
    
    @IBAction func btnSignIn(_ sender: UIButton) {
        //        CustomSideMenuViewController
        
        if (validateAllFields()) {
            webserviceForLoginDrivers()
        }        
    }
    
    @IBAction func btnForgotPassword(_ sender: UIButton) {
        
        //1. Create the alert controller.
//        let alert = UIAlertController(title: "Forgot Password?".localized, message: "Please enter email".localized, preferredStyle: .alert)
//
//        //2. Add the text field. You can configure it however you need.
//        alert.addTextField { (textField) in
//            textField.placeholder = "Email".localized
//        }
//
//        // 3. Grab the value from the text field, and print it when the user clicks OK.
//        alert.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: { [weak alert] (_) in
//            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
//            print("Text field: \(String(describing: textField?.text))")
//
//            self.strEmailForForgotPassword = (textField?.text)!
//
//            if self.strEmailForForgotPassword == "" {
//                NotificationCenter.default.post(name: Notification.Name("checkForgotPassword"), object: nil)
//            }
//            else {
//                self.webserviceForgotPassword()
//            }
//
//        }))
//
//        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .default, handler: { [weak alert] (_) in
//
//        }))
//
//        // 4. Present the alert.
//        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func btnFaceBook(_ sender: UIButton) {
    }
    
    @IBAction func btnSignUP(_ sender: UIButton) {
        self.gotoRegister()
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "SegueToRegisterVc" {
//            if let RegisterPage = segue.destination as? Regin
//        }
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//    }
    
    @IBAction func btnGoogle(_ sender: UIButton) {
        
    }
    
    func checkPass() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.showAlertForPasswordWrong), name: Notification.Name("checkForgotPassword"), object: nil)
    }
     
     func gotoRegister() {
         if (CLLocationManager.locationServicesEnabled() == false || CLLocationManager.authorizationStatus() == .denied) {
             self.showAlertIfDenied()
         } else {
             
             let RegisterStory = UIStoryboard(name: "Registration", bundle:  nil)
             let SignUpPages = RegisterStory.instantiateViewController(withIdentifier: "DriverRegistrationViewController") as! DriverRegistrationViewController
             SignUpPages.CurrentLocation = self.currentLocation
             self.navigationController?.pushViewController(SignUpPages, animated: true)
         }
     }
     
    
    @objc func showAlertForPasswordWrong() {
        
        UtilityClass.showAlert("App Name".localized, message: "Please enter mobile number".localized, vc: self)
        
    }
    
    // ------------------------------------------------------------
    
    //-------------------------------------------------------------
    // MARK: - Custom Methods
    //-------------------------------------------------------------
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
            print(#function)
            self.currentLocation =  locations.last!
            self.strLatitude = currentLocation.coordinate.latitude
            self.strLongitude = currentLocation.coordinate.longitude
            self.manager.stopUpdatingLocation()
    }
     
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            print("User still thinking granting location access!")
//            self.showAlertIfDenied()
            break
            
        case .denied:
            self.showAlertIfDenied()
            print("User denied location access request!!")
           break
            
        case .authorizedWhenInUse:
            manager.startUpdatingLocation()
          
            break
            
        case .authorizedAlways:
            manager.startUpdatingLocation()
            break
            
        default:
            break
        }
    }
    
    
    func showAlertIfDenied() {
        if (CLLocationManager.locationServicesEnabled() == false || CLLocationManager.authorizationStatus() == .denied) {
            let alert = UIAlertController(title: appName.kAPPName, message: "You have denied location permission. Turn it on from the device settings", preferredStyle: .alert)
            let action = UIAlertAction.init(title: "Ok", style: .default, handler: { (action) in
                if !CLLocationManager.locationServicesEnabled() {

                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                        return
                    }
                    if UIApplication.shared.canOpenURL(settingsUrl)  {
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                            })
                        }
                        else  {
                            UIApplication.shared.openURL(settingsUrl)
                        }
                    }
                }
                else {
                    //This will opne particular app location settings
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, completionHandler: { (success) in
                    })
               }
            })
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // ------------------------------------------------------------
    @IBAction func unwindToVC(segue: UIStoryboardSegue) {
    }
    
    
    //-------------------------------------------------------------
    // MARK: - Webservice Methods
    //-------------------------------------------------------------
    
    var dictData = [String:AnyObject]()
    
    func webserviceForLoginDrivers()
    {
        self.view.endEditing(true)
        dictData["Username"] = txtMobile.text as AnyObject
        dictData["Password"] = txtPassword.text as AnyObject
        
//        if strLatitude == 0 {
//            dictData["Lat"] = "23.0012356" as AnyObject
//        } else {
            dictData["Lat"] = strLatitude as AnyObject
//        }
        
//        if strLongitude == 0 {
//            dictData["Lng"] = "72.0012341" as AnyObject
//        } else {
            dictData["Lng"] = strLongitude as AnyObject
//        }
        dictData["Token"] = Singletons.sharedInstance.deviceToken as AnyObject
        dictData["DeviceType"] = "1" as AnyObject
        
        
        webserviceForDriverLogin(dictParams: dictData as AnyObject) { (result, status) in
            
            if (status)
            {
                print(result)
                
                if ((result as! NSDictionary).object(forKey: "status") as! Int == 1)
                {
                    Singletons.sharedInstance.dictDriverProfile = NSMutableDictionary(dictionary: (result as! NSDictionary).object(forKey: "driver") as! NSDictionary)
                    Singletons.sharedInstance.isDriverLoggedIN = true
                    Utilities.encodeDatafromDictionary(KEY: driverProfileKeys.kKeyDriverProfile, Param: Singletons.sharedInstance.dictDriverProfile)
//                                        UserDefaults.standard.set(Singletons.sharedInstance.dictDriverProfile, forKey: driverProfileKeys.kKeyDriverProfile)
                                        UserDefaults.standard.set(true, forKey: driverProfileKeys.kKeyIsDriverLoggedIN)
                    
                    Singletons.sharedInstance.strDriverID = ((Singletons.sharedInstance.dictDriverProfile.object(forKey: "profile") as! NSDictionary).object(forKey: "Vehicle") as! NSDictionary).object(forKey: "DriverId") as! String
                    
                    Singletons.sharedInstance.driverDuty = ((Singletons.sharedInstance.dictDriverProfile.object(forKey: "profile") as! NSDictionary).object(forKey: "DriverDuty") as! String)
                    //                    Singletons.sharedInstance.showTickPayRegistrationSceeen =
                    
                    let profileData = Singletons.sharedInstance.dictDriverProfile
                    
                    if let currentBalance = (profileData?.object(forKey: "profile") as! NSDictionary).object(forKey: "Balance") as? Double
                    {
                        Singletons.sharedInstance.strCurrentBalance = currentBalance
                    }
                    let next = self.storyboard?.instantiateViewController(withIdentifier: "CustomSideMenuViewController") as! CustomSideMenuViewController
                    self.navigationController?.pushViewController(next, animated: true)
                    
                }
                
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
    
    // ------------------------------------------------------------
    
    func webserviceForgotPassword()
    {
        var params = [String:AnyObject]()
        params[RegistrationFinalKeys.kEmail] = strEmailForForgotPassword as AnyObject
        
        webserviceForForgotPassword(params as AnyObject) { (result, status) in
            
            if (status) {
                
                print(result)
                let alert = UIAlertController(title: "App Name".localized, message: result.object(forKey: GetResponseMessageKey()) as? String, preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK".localized, style: .default, handler: nil)
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
                
            } else {
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
     
     @IBAction func unwindToLoginVC(segue: UIStoryboardSegue) {

        }
    // ----------------------------------------------------------------------
    
    func webserviceOfAppSetting() {
        //        version : 1.0.0 , (app_type : AndroidPassenger , AndroidDriver , IOSPassenger , IOSDriver)
        
        
        let nsObject: AnyObject? = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as AnyObject
        let version = nsObject as! String
        
        var param = String()
        
        param = version + "/" + "IOSDriver" + "/" + Singletons.sharedInstance.strDriverID

        webserviceForAppSetting(param as AnyObject) { (result, status) in
            
            if(status) {
                print(result)
 
//                Singletons.sharedInstance.helpLineNumber = result["DispatchCall"] as? String ?? ""
                Singletons.sharedInstance.currentTripType = result["CurrentlyRunningTrip"] as? String ?? "4"
                Singletons.sharedInstance.PP = result["PrivacyPolicy"] as? String ?? ""
                Singletons.sharedInstance.TC = result["TermsAndCondition"] as? String ?? ""
                Singletons.sharedInstance.DispatchCall = result["DispatchCall"] as? String ?? ""
                Singletons.sharedInstance.DispatchWhatsapp = result["DispatchWhatsapp"] as? String ?? ""
                Singletons.sharedInstance.isShowFeatureBookingTab = result["is_show_feature_booking_tab"] as? Int ?? 0
                Singletons.sharedInstance.WaitingTimeNotify = result["WaitingTimeNotify"] as? Int ?? 180
                
                let dispatcherInfo =  result["dispatcher_detail"] as? [String:Any]
                Singletons.sharedInstance.DispatchName = dispatcherInfo?["Fullname"] as? String ?? ""
                Singletons.sharedInstance.DispatchId = dispatcherInfo?["Id"] as? String ?? ""
                
                if let dictData = result["driver"] as? [String:Any], let profile = dictData["profile"] as? [String:Any]
                {
                    var status = String()
                    if let strStatus = profile["Status"] as? String
                    {
                        status = strStatus
                    }
                    else if let intStatus = profile["Status"] as? Int
                    {
                        status = "\(intStatus)"
                    }
                    
                    if(status == "0")
                    {
                        Appdelegate.webserviceOFSignOut()
                    }
                }
                
                if ((result as! NSDictionary).object(forKey: "update") as? Bool) != nil {
                    
                    UserDefaults.standard.set(true, forKey: kIsUpdateAvailable)
                    UserDefaults.standard.set((result as! NSDictionary).object(forKey: GetResponseMessageKey()) as! String, forKey: kIsUpdateMessage)
                    UserDefaults.standard.synchronize()
                    
                    let alert = UIAlertController(title: "App Name".localized, message: (result as! NSDictionary).object(forKey: GetResponseMessageKey()) as? String, preferredStyle: .alert)
                    let UPDATE = UIAlertAction(title: "Update".localized, style: .default, handler: { ACTION in
                        UIApplication.shared.canOpenURL(URL(string: appName.kAPPUrl) ?? URL(fileURLWithPath: ""))//openURL(NSURL(string: appName.kAPPUrl)! as URL)
                    })
                    let Cancel = UIAlertAction(title: "Cancel".localized, style: .default, handler: { ACTION in
                        
                        if(Singletons.sharedInstance.isDriverLoggedIN)
                        {
                            let next = self.storyboard?.instantiateViewController(withIdentifier: "CustomSideMenuViewController") as! CustomSideMenuViewController
                            self.navigationController?.pushViewController(next, animated: true)
                        }
                    })
                    alert.addAction(UPDATE)
                    alert.addAction(Cancel)
                    self.present(alert, animated: true, completion: nil)
                }
                else
                {
                    
                    UserDefaults.standard.set(false, forKey: kIsUpdateAvailable)
                    UserDefaults.standard.set("", forKey: kIsUpdateMessage)
                    UserDefaults.standard.synchronize()
                   
                    if(Singletons.sharedInstance.isDriverLoggedIN)
                    {
                        let next = self.storyboard?.instantiateViewController(withIdentifier: "CustomSideMenuViewController") as! CustomSideMenuViewController
                        self.navigationController?.pushViewController(next, animated: false)
                    }
//                    if(Singletons.sharedInstance.isDriverLoggedIN)
//                    {
//                        let next = self.storyboard?.instantiateViewController(withIdentifier: "CustomSideMenuViewController") as! CustomSideMenuViewController
//                        self.navigationController?.pushViewController(next, animated: true)
//                    }
                    
                }
                
                //                if(SingletonClass.sharedInstance.isUserLoggedIN)
                //                {
                //                    self.performSegue(withIdentifier: "segueToHomeVC", sender: nil)
                //                }//bhaveshbhai
                
                
            }
            else {
                print(result)
                /*
                 {
                 "status": false,
                 "update": false,
                 "maintenance": true,
                 "message": "Server under maintenance, please try again after some time"
                 }
                 */
                
                if let res = result as? String {
                    UtilityClass.showAlert("App Name".localized, message: res, vc: self)
                }
                else if let update = (result as! NSDictionary).object(forKey: "update") as? Bool {
                    
                    if (update) {
                        
                        UserDefaults.standard.set(true, forKey: kIsUpdateAvailable)
                        UserDefaults.standard.set((result as! NSDictionary).object(forKey: GetResponseMessageKey()) as! String, forKey: kIsUpdateMessage)
                        UserDefaults.standard.synchronize()
                        //                        UtilityClass.showAlert(appName.kAPPName, message: (result as! NSDictionary).object(forKey: "message") as! String, vc: self)
                        
//                        UtilityClass.showAlertWithCompletion("App Name".localized, message: (result as! NSDictionary).object(forKey: GetResponseMessageKey()) as! String, vc: self, completionHandler: { ACTION in
//                            UIApplication.shared.open((NSURL(string: appName.kAPPUrl)! as URL), options: [:], completionHandler: { (status) in
//
//                            })
//                        })
                        
                        let alert = UIAlertController(title: "App Name".localized, message: (result as! NSDictionary).object(forKey: GetResponseMessageKey()) as? String ?? "", preferredStyle: .alert)
                        let UPDATE = UIAlertAction(title: "Update".localized, style: .default, handler: { ACTION in
                            UIApplication.shared.open((NSURL(string: appName.kAPPUrl)! as URL), options: [:], completionHandler: { (status) in

                            })
                        })
                        let Cancel = UIAlertAction(title: "Register".localized, style: .default, handler: { ACTION in
                            self.gotoRegister()
                        })
                        alert.addAction(UPDATE)
                        alert.addAction(Cancel)
                        self.present(alert, animated: true, completion: nil)
                    }
                    else {
                        
                        UserDefaults.standard.set(false, forKey: kIsUpdateAvailable)
                        UserDefaults.standard.set("", forKey: kIsUpdateMessage)
                        UserDefaults.standard.synchronize()
                        
                        UtilityClass.showAlert("App Name".localized, message: (result as! NSDictionary).object(forKey: GetResponseMessageKey()) as! String, vc: self)
                    }
                    
                }
                /*
                 {
                 "status": false,
                 "update": true,
                 "message": "Ticktoc app new version available, please upgrade your application"
                 }
                 */
                //                if let res = result as? String {
                //                    UtilityClass.showAlert(appName.kAPPName, message: res, vc: self)
                //                }
                //                else if let resDict = result as? NSDictionary {
                //                    UtilityClass.showAlert(appName.kAPPName, message: resDict.object(forKey: "message") as! String, vc: self)
                //                }
                //                else if let resAry = result as? NSArray {
                //                    UtilityClass.showAlert(appName.kAPPName, message: (resAry.object(at: 0) as! NSDictionary).object(forKey: "message") as! String, vc: self)
                //                }
            }
        }
    }
     
     
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (string == " ") {
            return false
        }
        return true
    }
    //-------------------------------------------------------------
    // MARK: - Validation Methods
    //-------------------------------------------------------------
    
    func validateAllFields() -> Bool
    {
        //        let isEmailAddressValid = isValidEmailAddress(emailID: txtEmailAddress.text!)
        //        let providePassword = txtPassword.text
        
        //        let isPasswordValid = isPwdLenth(password: providePassword!)
        
        
        if txtMobile.text!.count == 0
        {
            UtilityClass.showAlert("App Name".localized, message: "Please enter mobile number".localized, vc: self)
            return false
        }
//        else if txtMobile.text!.count != 10 {
//            UtilityClass.showAlert("App Name".localized, message: "Please enter valid phone number.", vc: self)
//            return false
//        }
        else if txtPassword.text!.count == 0 {
            UtilityClass.showAlert("App Name".localized, message: "Please enter password".localized, vc: self)
            return false
        } else if self.strLatitude == 0.0 && self.strLongitude == 0.0 {
            self.showAlertIfDenied()
        }
        
        
//        else if txtPassword.text!.count <= 5 {
//            UtilityClass.showAlert(appName.kAPPName, message: "Password should be more than 5 characters", vc: self)
//            return false
//        }
        
        
        return true
    }
    
    func isValidEmailAddress(emailID: String) -> Bool
    {
        var returnValue = true
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z)-9.-]+\\.[A-Za-z]{2,3}"
        
        do{
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let nsString = emailID as NSString
            let results = regex.matches(in: emailID, range: NSRange(location: 0, length: nsString.length))
            
            if results.count == 0
            {
                returnValue = false
            }
        }
        catch _ as NSError
        {
            returnValue = false
        }
        
        return returnValue
    }
    
    
 }
