 
//  AppDelegate.swift
//  TenTaxi-Driver
//  Created by Excellent Webworld on 09/10/17.
//  Copyright © 2017 Excellent Webworld. All rights reserved.


import UIKit
import SideMenuController
import IQKeyboardManagerSwift
import GooglePlaces
import GoogleMaps
import UserNotifications
import FirebaseMessaging
import SocketIO
import Firebase
import PhotosUI
import Alamofire
 

let googlApiKey = "AIzaSyCQ10cPN_q98K0PrDxvZx-aVYD05hiNB7g"
let googlPlacesApiKey = googlApiKey

@UIApplicationMain class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate, UNUserNotificationCenterDelegate,MessagingDelegate
{
    static var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    var window: UIWindow?
    let manager = CLLocationManager()
    var bgTask : UIBackgroundTaskIdentifier!
    
    var WaitingTime  = ""
    var WaitingTimeCount  : Double = 0
    var DistanceKiloMeter  = ""
    var Speed  = ""
    
    var isChatVisible: Bool = false
    var currentChatID: String = ""
    static var pushNotificationObj : NotificationObjectModel?
    static var pushNotificationType : String?
    
    var offlineStatue : Bool = false
    
    var RoadPickupTimer = Timer()
    let SManager = SocketManager(socketURL: URL(string: socketApiKeys.kSocketBaseURL)!,config: [.log(false), .compress,.version(.two)])
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
       
        //self.checkConnction()
        IQKeyboardManager.shared.enable = true
        UserDefaults.standard.set(false, forKey: kIsSocketEmited)
        UserDefaults.standard.set(false, forKey: kIsUpdateAvailable)
        UserDefaults.standard.synchronize()
        
        checkAndSetDefaultLanguage()
        
        SideMenuController.preferences.drawing.menuButtonImage = UIImage(named: "menu")
        SideMenuController.preferences.drawing.sidePanelPosition = .overCenterPanelLeft
        SideMenuController.preferences.drawing.sidePanelWidth = (window?.frame.width)! * 0.85
        SideMenuController.preferences.drawing.centerPanelShadow = true
        SideMenuController.preferences.animating.statusBarBehaviour = .showUnderlay
        UIApplication.shared.isIdleTimerDisabled = true
        
  
        GMSPlacesClient.provideAPIKey(googlPlacesApiKey)
        GMSServices.provideAPIKey(googlPlacesApiKey)
        
        manager.delegate = self
        manager.startUpdatingLocation()
        manager.requestAlwaysAuthorization()
        LocationManager.shared.start()
        
        if (UserDefaults.standard.object(forKey:  driverProfileKeys.kKeyDriverProfile) != nil)
        {
            self.setDataInSingletonClass()
        }
        else
        {
            Singletons.sharedInstance.isDriverLoggedIN = false
        }
        
        if UserDefaults.standard.object(forKey: "Passcode") as? String == nil {
            Singletons.sharedInstance.setPasscode = ""
        }
        else {
            Singletons.sharedInstance.setPasscode = UserDefaults.standard.object(forKey: "Passcode") as! String
        }
        
        
        // Push Notification Code
        
        let remoteNotif = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? NSDictionary
        
        if remoteNotif != nil
        {
            let key = remoteNotif?.object(forKey: "gcm.notification.type")!
            NSLog("\n Custom: \(String(describing: key))")
            self.pushAfterReceiveNotification(typeKey: key as! String, applicationObject: application)
        }
        else {
            //            let aps = remoteNotif!["aps" as NSString] as? [String:AnyObject]
            NSLog("//////////////////////////Normal launch")
            //            self.pushAfterReceiveNotification(typeKey: "")
            
        }
        //Default English set
        if UserDefaults.standard.value(forKey: "i18n_language") == nil {
            UserDefaults.standard.set("en", forKey: "i18n_language")
            UserDefaults.standard.synchronize()
        }

        UNUserNotificationCenter.current().delegate = self
        FirebaseApp.configure()
        registerForPushNotification()
        return true
    }
    
    func checkAndSetDefaultLanguage() {
        let currentLang = Localize.currentLanguage()
        Localize.setCurrentLanguage(currentLang)
    }
    
    func setDataInSingletonClass()
    {
        //        Singletons.sharedInstance.dictDriverProfile = NSMutableDictionary(dictionary:UserDefaults.standard.object(forKey:  driverProfileKeys.kKeyDriverProfile) as! NSDictionary)
        
        let DEcode = Utilities.decodeDictionaryfromData(KEY: driverProfileKeys.kKeyDriverProfile)
        if DEcode.count != 0
        {
            Singletons.sharedInstance.dictDriverProfile = DEcode
            Singletons.sharedInstance.strDriverID = ((Singletons.sharedInstance.dictDriverProfile.object(forKey: "profile") as! NSDictionary).object(forKey: "Vehicle") as! NSDictionary).object(forKey: "DriverId") as! String
            Singletons.sharedInstance.isDriverLoggedIN = UserDefaults.standard.object(forKey: driverProfileKeys.kKeyIsDriverLoggedIN) as? Bool
            
            if UserDefaults.standard.object(forKey: "DriverDuty") as? String == nil {
                
                Singletons.sharedInstance.driverDuty = "0"
            }
            else {
                Singletons.sharedInstance.driverDuty = UserDefaults.standard.object(forKey: "DriverDuty") as? String
            }
            
            
            if let passOn = UserDefaults.standard.object(forKey: "isPasscodeON") as? Bool {
                
                if passOn == false {
                    Singletons.sharedInstance.isPasscodeON = false
                }
                else {
                    Singletons.sharedInstance.isPasscodeON = true
                }
            }
            else
            {
                
                Singletons.sharedInstance.isPasscodeON = false
                UserDefaults.standard.set(Singletons.sharedInstance.isPasscodeON, forKey: "isPasscodeON")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            manager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location: CLLocation = locations.last!
        
        //        defaultLocation = location
        
        Singletons.sharedInstance.latitude = location.coordinate.latitude
        Singletons.sharedInstance.longitude = location.coordinate.longitude
        
        if locations.first != nil {
            //            print("location:: (location)")
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool // called when 'return' key pressed. return false to ignore.
    {
        textField.resignFirstResponder()
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print("App is in Background mode")
        SManager.defaultSocket.connect()
        SManager.defaultSocket.on(clientEvent: .connect) {data, ack in
            print ("socket connected")
        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        webserviceOfAppSetting()
        if let isSwitchOn = UserDefaults.standard.object(forKey: "isPasscodeON") as? Bool {
            Singletons.sharedInstance.isPasscodeON = isSwitchOn
        }
        let passCode = Singletons.sharedInstance.setPasscode
        
        if (passCode != "" && Singletons.sharedInstance.isPasscodeON) {
            
            let mainStoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewControlleripad = mainStoryboard.instantiateViewController(withIdentifier: "VerifyPasswordViewController") as! VerifyPasswordViewController
            initialViewControlleripad.isFromAppDelegate = true
            self.window?.rootViewController?.present(initialViewControlleripad, animated: true, completion: nil)
        }
        
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        if UIApplication.topViewController()!.isKind(of: LoginViewController.self) {
            if UserDefaults.standard.bool(forKey: kIsUpdateAvailable) == true {
                print("Update app...")
                if !UIApplication.topViewController()!.isKind(of: UIAlertController.self) {
                    
                    let alert = UIAlertController(title: "App Name".localized, message: UserDefaults.standard.string(forKey: kIsUpdateMessage) ?? "", preferredStyle: .alert)
                    let UPDATE = UIAlertAction(title: "Update".localized, style: .default, handler: { ACTION in
                        UIApplication.shared.open((NSURL(string: appName.kAPPUrl)! as URL), options: [:], completionHandler: { (status) in

                        })
                    })
                    let Cancel = UIAlertAction(title: "Register".localized, style: .default, handler: { ACTION in
                        NotificationCenter.default.post(name: Notification.Name("goToRegister"), object: nil, userInfo: nil)
                    })
                    alert.addAction(UPDATE)
                    alert.addAction(Cancel)
                    self.window?.rootViewController?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        //        SocketManager.disconnect()
    }
    
    func webserviceOfAppSetting() {
        let nsObject: AnyObject? = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as AnyObject
        let version = nsObject as! String
        
        var param = String()
        
        param = version + "/" + "IOSDriver" + "/" + Singletons.sharedInstance.strDriverID
        
        webserviceForAppSetting(param as AnyObject,showHud: false) { (result, status) in
            print(result)
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
                    self.webserviceOFSignOut()
                }
            }
        }
    }
    
    func webserviceOFSignOut()
    {
        let srtDriverID = Singletons.sharedInstance.strDriverID
        if (srtDriverID == "")
        {
            return
        }
        
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
                Utilities.findtopViewController()?.performSegue(withIdentifier: "SignOutFromSideMenu", sender: (Any).self)
                
            }
            else {
                print(result)
                if let res = result as? String {
                    UtilityClass.showAlert("App Name".localized, message: res, vc: Utilities.findtopViewController() ?? UIViewController())
                }
                else if let resDict = result as? NSDictionary {
                    UtilityClass.showAlert("App Name".localized, message: resDict.object(forKey: GetResponseMessageKey()) as! String, vc: Utilities.findtopViewController() ?? UIViewController())
                }
                else if let resAry = result as? NSArray {
                    UtilityClass.showAlert("App Name".localized, message: (resAry.object(at: 0) as! NSDictionary).object(forKey: GetResponseMessageKey()) as! String, vc:  Utilities.findtopViewController() ?? UIViewController())
                }
            }
        }
    }
    
    func signOutFromNotification() {
        NotificationCenter.default.post(name: UserSignOut, object: nil)
    }
    
    func navigateToLogin() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if #available(iOS 13.0, *) {
            let logInVC = storyboard.instantiateViewController(identifier: "LoginViewController") as! LoginViewController
            window?.rootViewController = UINavigationController(rootViewController: logInVC)
        }else{
            let logInVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            window?.rootViewController = UINavigationController(rootViewController: logInVC)
        }
    }
    
    // Push Notification Methods
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
       
     //   Messaging.messaging().apnsToken = deviceToken as Data
        Messaging.messaging().apnsToken = deviceToken
        
//        if let fcmToken = Messaging.messaging().fcmToken
//        {
//            Singletons.sharedInstance.deviceToken = fcmToken
//        }
//
//        #if targetEnvironment(simulator)
//            Singletons.sharedInstance.deviceToken = "11111111"
//        #endif
//        UserDefaults.standard.set(Singletons.sharedInstance.deviceToken, forKey: "Token")
//        UserDefaults.standard.synchronize()
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        Messaging.messaging().appDidReceiveMessage(userInfo)
        let key = (userInfo as NSDictionary).object(forKey: "gcm.notification.type")!
        
        if(application.applicationState == .background)
        {
            self.pushAfterReceiveNotification(typeKey: key as! String, applicationObject: application)
        }
        else
        {
            let data = ((userInfo["aps"]! as! [String : AnyObject])["alert"]!) as! [String : AnyObject]
            
            
            let alert = UIAlertController(title: "App Name".localized,
                                          message: data["title"] as? String,
                                          preferredStyle: UIAlertController.Style.alert)
            
            //vc will be the view controller on which you will present your alert as you cannot use self because this method is static.
            if((userInfo as! [String:AnyObject])["gcm.notification.type"]! as! String == "AcceptBookingRequestNotification")
            {
                alert.addAction(UIAlertAction(title: "Get Details", style: .default, handler: { (action) in
                    self.pushAfterReceiveNotification(typeKey: key as! String, applicationObject: application)
                }))
                
                alert.addAction(UIAlertAction(title: "Dismiss".localized, style: .destructive, handler: { (action) in
                    
                }))
                self.window?.rootViewController?.present(alert, animated: true, completion: nil)
            }
            else if ((userInfo as! [String:AnyObject])["gcm.notification.type"]! as! String == "Logout")
            {
                let navigationController = application.windows[0].rootViewController as! UINavigationController
                let viewControllers: [UIViewController] = navigationController.viewControllers
                for aViewController in viewControllers {
                    if aViewController is CustomSideMenuViewController {
                        
                        //                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        let homeVC = aViewController.children[0].children[0] as? HomeViewController
                        homeVC?.webserviceOFSignOut()
                        //                        }))
                        //                        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
        //        let data = ((userInfo["aps"]! as! [String : AnyObject])["alert"]!) as! [String : AnyObject]
        //  UtilityClass.showAlert(data["title"] as! String, message: data["body"] as! String, vc: (self.window?.rootViewController)!)
        print(userInfo)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Swift.Void) {
        let userInfo = response.notification.request.content.userInfo
        print("USER INFo : ",userInfo)
        
        if let mainDic = userInfo as? [String: Any]{
            
            let pushObj = NotificationObjectModel()
            if let bookingId = mainDic["gcm.notification.id"]{
                pushObj.booking_id = bookingId as? String ?? ""
            }
            if let sender = mainDic["gcm.notification.sender_id"]{
                pushObj.sender_id = sender as? String ?? ""
            }
            if let type = mainDic["gcm.notification.type"]{
                pushObj.type = type as? String ?? ""
            }
            if let title = mainDic["title"]{
                pushObj.title = title as? String ?? ""
            }
            if let text = mainDic["text"]{
                pushObj.text = text as? String ?? ""
            }
            
            AppDelegate.pushNotificationObj = pushObj
            AppDelegate.pushNotificationType = pushObj.type
          
            if pushObj.type == NotificationTypes.newMeassage.rawValue {
                if(!isChatVisible){
                    NotificationCenter.default.post(name: GoToChatScreen, object: nil)
                }else{
                    var DataDict: [String: AnyObject] = [:]
                    DataDict["booking_id"] = mainDic["gcm.notification.id"] as AnyObject
                    DataDict["receiver_Id"] = mainDic["gcm.notification.sender_id"] as AnyObject
                    let isDispacherChat = ("\(mainDic["gcm.notification.id"] as AnyObject)" == "" || "\(mainDic["gcm.notification.id"] as AnyObject)" == "0") ? true : false
                    DataDict["isDispacherChat"] = isDispacherChat as AnyObject
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ReloadChatScreen"), object: nil, userInfo: DataDict)
                }
            }
        }
        completionHandler()
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    
        print(#function, notification)
        let content = notification.request.content
        let userInfo = notification.request.content.userInfo
  
        if let mainDic = userInfo as? [String: Any]{
            
            let pushObj = NotificationObjectModel()
            if let bookingId = mainDic["gcm.notification.booking_id"]{
                pushObj.booking_id = bookingId as? String ?? ""
            }
            if let sender = mainDic["gcm.notification.sender_id"]{
                pushObj.sender_id = sender as? String ?? ""
            }
            if let type = mainDic["gcm.notification.type"]{
                pushObj.type = type as? String ?? ""
            }
            if let title = mainDic["title"]{
                pushObj.title = title as? String ?? ""
            }
            if let text = mainDic["text"]{
                pushObj.text = text as? String ?? ""
            }
            
            AppDelegate.pushNotificationObj = pushObj
            AppDelegate.pushNotificationType = pushObj.type
            
            if pushObj.type == NotificationTypes.newMeassage.rawValue {
                do {
                    if(isChatVisible){
                        let currentID = mainDic["gcm.notification.sender_id"] as? String ?? ""
                        if(currentID == AppDelegate.shared.currentChatID){
                            completionHandler([])
                        }
                    }
                }catch{
                    print("Error : detected")
                }
            }
            
            if pushObj.type == NotificationTypes.logout.rawValue {
                //self.webserviceOFSignOut()
                self.signOutFromNotification()
            }
            
        completionHandler([.alert,.sound])
        }
        
    }
    
    //-------------------------------------------------------------
    // MARK: - Push Notification Methods
    //-------------------------------------------------------------
    
    func registerForPushNotification() {
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {_ , _ in })
            Messaging.messaging().delegate = self
        } else {
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
        UIApplication.shared.registerForRemoteNotifications()
        
    }

    //-------------------------------------------------------------
    // MARK: - FireBase Methods
    //-------------------------------------------------------------
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        let token = Messaging.messaging().fcmToken
        Singletons.sharedInstance.deviceToken = token!
        #if targetEnvironment(simulator)
            Singletons.sharedInstance.deviceToken = "11111111"
        #endif
        UserDefaults.standard.set(Singletons.sharedInstance.deviceToken, forKey: "Token")
        print("FCM token: \(token ?? "")")
        
    }
    
    func pushAfterReceiveNotification(typeKey : String, applicationObject:UIApplication) {
        if (typeKey == "Logout") {
            let navigationController = applicationObject.windows[0].rootViewController as! UINavigationController
            let viewControllers: [UIViewController] = navigationController.viewControllers
            for aViewController in viewControllers {
                if aViewController is CustomSideMenuViewController {
                    let homeVC = aViewController.children[0].children[0] as? HomeViewController
                    homeVC?.webserviceOFSignOut()
                }
            }
        } else if(typeKey == "AddMoney")
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let navController = self.window?.rootViewController as? UINavigationController
                let notificationController: UIViewController? = navController?.storyboard?.instantiateViewController(withIdentifier: "WalletHistoryViewController")
                navController?.present(notificationController ?? UIViewController(), animated: true, completion: {
                    
                })
            }
        }
        else if(typeKey == "TransferMoney")
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let navController = self.window?.rootViewController as? UINavigationController
                let notificationController: UIViewController? = navController?.storyboard?.instantiateViewController(withIdentifier: "WalletHistoryViewController")
                navController?.present(notificationController ?? UIViewController(), animated: true, completion: {
                    
                })
            }
        }
            //        else if(typeKey == "Tickpay")
            //        {
            //            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            //                let tabbarvc = (((((((self.window?.rootViewController as! UINavigationController).viewControllers[1].children.last!) as! MenuController).navigationController)?.children.last) as! CustomSideMenuViewController).children[0] as! UINavigationController).children[0] as! TabbarController
            //
            //                tabbarvc.selectedIndex = 4
            //            }
            //        }
        else if(typeKey == "RejectDispatchJobRequest")
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                //                let navController = self.window?.rootViewController as? UINavigationController
                //                let notificationController: UIViewController? = navController?.storyboard?.instantiateViewController(withIdentifier: "PastJobsListVC")
                //                navController?.present(notificationController ?? UIViewController(), animated: true, completion: {
                //
                //                })
                //
                //                let tabBarTemp = (((self.window?.rootViewController as! UINavigationController).children.last as! CustomSideMenuViewController).children[0] as! UINavigationController).children[0] as! TabbarController
                //
                //                tabBarTemp.selectedIndex = 1
                //                let MyJob = tabBarTemp.children[1] as! MyJobsViewController
                //
                //                MyJob.btnPastJobsClicked(MyJob.btnPastJobs)
            }
        }
        else if(typeKey == "BookLaterDriverNotify")
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                //                let navController = self.window?.rootViewController as? UINavigationController
                //                let notificationController: UIViewController? = navController?.storyboard?.instantiateViewController(withIdentifier: "FutureBookingVC")
                //                navController?.present(notificationController ?? UIViewController(), animated: true, completion: {
                //
                
                //                    let tabbarvc = (((((((self.window?.rootViewController as! UINavigationController).viewControllers[1].children.last!) as! MenuController).navigationController)?.children.last) as! CustomSideMenuViewController).children[0] as! UINavigationController).children[0] as! TabbarController
                //                    Singletons.sharedInstance.isFromNotification = true
                //
                //                    tabbarvc.selectedIndex = 1
                //
                //                let tabBarTemp = (((self.window?.rootViewController as! UINavigationController).children.last as! CustomSideMenuViewController).children[0] as! UINavigationController).children[0] as! TabbarController
                //                 Singletons.sharedInstance.isFromNotification = true
                //                tabBarTemp.selectedIndex = 1
                //
                ////                }
                //            }
            }
            
        }
        
    }
    
    static func showAlert(title: String?, message: String?, actions: [UIAlertAction]? = nil) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if let array = actions {
            array.forEach { alertVC.addAction($0) }
        } else {
            alertVC.addAction(.init(title: "Ok", style: .cancel))
        }
        UIApplication.topViewController()?.present(alertVC, animated: true)
    }

    static func hasCameraAccess( result: @escaping (_ access: Bool) -> Void) {
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch authStatus {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { granted in
                DispatchQueue.main.sync {
                    result(granted)
                }
            }
        case .restricted:
            AppDelegate.showAlert(title: "Unable to access the Camera", message: "To enable access, go to Settings > Privacy > Camera and turn on Camera access for this app.")
            result(false)
        case .denied:
            AppDelegate.showAlert(title: "Unable to access the Camera", message: "To enable access, go to Settings > Privacy > Camera and turn on Camera access for this app.")
                result(false)

        case .authorized:
                 result(true)

        @unknown default:
                result(false)
        }
    }

    static func hasPhotoLibraryAccess( result: @escaping (_ access: Bool) -> Void) {
        let authStatus = PHPhotoLibrary.authorizationStatus()
        switch authStatus {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { granted in
                DispatchQueue.main.async {
                    result(granted == .authorized)
                }
            }
        case .restricted, .denied:
            AppDelegate.showAlert(title: "Unable to access the Photos", message: "To enable access, go to Settings > Privacy > Photos and turn on Photos access for this app.")
            DispatchQueue.main.async {
                result(false)
            }

        case .authorized:
            DispatchQueue.main.async {
                result(true)
            }
        default:
            DispatchQueue.main.async {
                result(true)
            }
        }
    }
    
    //MARK: - Network methods
    func checkConnction() {
       let manager = Alamofire.NetworkReachabilityManager(host: "www.google.com")
        manager?.stopListening()
        manager?.startListening()
        manager?.listener = { _ in
            if let isNetworkReachable = manager?.isReachable,
               isNetworkReachable == true {
                if(self.offlineStatue){
                    self.offlineStatue = false
                    AppDelegate.shared.hideOfflineVC()
                }
            } else {
                self.offlineStatue = true
                AppDelegate.shared.showOfflineVC()
            }
        }

    }
    
    func showOfflineVC(){
        let topVC = UIApplication.appTopViewController()
        if (topVC?.isKind(of: OfflineVC.self) ?? false){
            return
        }else{
            if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OfflineVC") as? OfflineVC {
                if let window = self.window, let rootViewController = window.rootViewController {
                    var currentController = rootViewController
                    while let presentedController = currentController.presentedViewController {
                        currentController = presentedController
                    }
                    currentController.modalPresentationStyle = .overCurrentContext
                    currentController.present(controller, animated: true, completion: {
                        controller.presentationController?.presentedView?.gestureRecognizers?[0].isEnabled = false
                    })
                }
            }
        }
    }
    
    func hideOfflineVC(){
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: {
            print("Action after dismiss...")
            if(self.SManager.defaultSocket.status == .disconnected) {
                self.SManager.defaultSocket.connect()
            }
        })
    }

}

extension UIApplication {
    class func appTopViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return appTopViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return appTopViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return appTopViewController(controller: presented)
        }
        return controller
    }
    
    class func getVisibleViewController(_ rootViewController: UIViewController) -> UIViewController? {

        if let presentedViewController = rootViewController.presentedViewController {
            return getVisibleViewController(presentedViewController)
        }

        if let navigationController = rootViewController as? UINavigationController {
            return navigationController.visibleViewController
        }

        if let tabBarController = rootViewController as? UITabBarController {
            return tabBarController.selectedViewController
        }

        return rootViewController
    }
}

func setLayoutForswahilLanguage()
{
    UserDefaults.standard.set("sw", forKey: "i18n_language")
    UserDefaults.standard.synchronize()
}
func setLayoutForenglishLanguage()
{
    UserDefaults.standard.set("en", forKey: "i18n_language")
    UserDefaults.standard.synchronize()
}

class NotificationObjectModel: Codable {
    var booking_id: String?
    var sender_id: String?
    var type: String?
    var title: String?
    var text: String?
}

enum NotificationTypes : String {
    case newMeassage = "Chat"
    case logout = "Logout"
    
}
