//
//  ContentViewController.swift
//  TiCKTOC-Driver
//
//  Created by Excellent Webworld on 11/10/17.
//  Copyright © 2017 Excellent Webworld. All rights reserved.
//

import UIKit
import SideMenuController
import GooglePlaces
//import GooglePlacePicker
import GoogleMaps
import CoreLocation
import SocketIO
import SRCountdownTimer
import NVActivityIndicatorView
import MarqueeLabel
import Alamofire
import UserNotifications
import AVFoundation

//-------------------------------------------------------------
// MARK: - Protocol
//-------------------------------------------------------------

@objc protocol ReceiveRequestDelegate {
    func didAcceptedRequest()
    func didRejectedRequest(RejectByDriver: Bool)
}

protocol CompleterTripInfoDelegate {
    func didRatingCompleted()
}

protocol addCardFromHomeVCDelegate {
    func didAddCardFromHomeVC()
}

protocol deleagateGoToChat
{
    func btndeleagateGoToChat()
}
// ------------------------------------------------------------

class HomeViewController: ParentViewController, CLLocationManagerDelegate,ARCarMovementDelegate, SRCountdownTimerDelegate, ReceiveRequestDelegate,GMSMapViewDelegate,CompleterTripInfoDelegate,UITabBarControllerDelegate, delegateRatingIsSubmitSuccessfully,delegateWaitforTip, deleagateGoToChat
{
    func delegateResultTip() {
        Singletons.sharedInstance.bookingId = ""
    }
    
    
    var WaitingCounter = 0
    var WaitingHoldTimer = Timer()
//    let toursView: [Any] = Bundle.main.loadNibNamed("ToursHomeView", owner: HomeViewController.self, options: nil)!
    //-------------------------------------------------------------
    // MARK: - Outlets
    //-------------------------------------------------------------
    //button
    @IBOutlet weak var btnDirection: UIButton!
    @IBOutlet weak var btnCurrentlocation: UIButton!
    @IBOutlet weak var btnStartTrip: UIButton!
    @IBOutlet weak var btnReached: UIButton!
    //view
    @IBOutlet weak var BottomButtonView: UIView!
    @IBOutlet var subMapView: UIView!
    @IBOutlet var viewLocationDetails: UIView!
    //    @IBOutlet weak var StartTripView: UIView!
    //label
    @IBOutlet weak var lblPickUpLocation: MarqueeLabel!
    @IBOutlet var lblLocationOnMap: MarqueeLabel!
    
    @IBOutlet weak var lblEstimatedTimeNew: UILabel!
    @IBOutlet weak var lblEstimatedDistanceNew: UILabel!
    @IBOutlet weak var stackEstimatedView: UIStackView!
    @IBOutlet weak var stackEstimatedViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var viewOFHome: UIView!
    @IBOutlet weak var btnMyJob: UIButton!
    @IBOutlet weak var btnHome: UIButton!
    var isSocketConnected = Bool()
    var isAlreadyPopView = Bool()
    var boolShouldTrackCamera = true
    
    
    var arrivedRoutePath: GMSPath?

    @IBOutlet weak var stackViewOfWaitingTime: UIView!
    @IBOutlet weak var stackViewOfStartTrip: UIView!
    @IBOutlet weak var stackViewOfCompleteTrip: UIView!
    @IBOutlet weak var stackViewOfCancelTrip: UIView!
    //-------------------------------------------------------------
    // MARK: - Global Decelaration
    //-------------------------------------------------------------
    
    @IBOutlet weak var viewRound: UIView!
    @IBOutlet weak var viewRoundForHome: UIView!
    
    var switchControl = UISwitch()
    var moveMent: ARCarMovement!
    var window: UIWindow?
    
    static let numberFormatter: NumberFormatter =  {
        let mf = NumberFormatter()
        mf.minimumFractionDigits = 0
        mf.maximumFractionDigits = 0
        return mf
    }()
    
    var SosTimer: Timer?
    var SosTimerCount: Int = 10
    
    @IBOutlet var btnPassengerInfo: UIButton!
    
    @IBOutlet var btnDirectionFourBTN: UIButton!
    @IBOutlet var btnCancelTrip: UIButton!
    
    @IBOutlet var constrainLocationViewBottom: NSLayoutConstraint?
    let socket = (UIApplication.shared.delegate as! AppDelegate).SManager.defaultSocket
    
    @IBOutlet var viewHomeMyJobsBTN: UIView!
    @IBOutlet var TopCurrentContraint: NSLayoutConstraint!
    
    
    let baseURLDirections = "https://maps.googleapis.com/maps/api/directions/json?"
    var oldCoordinate: CLLocationCoordinate2D!
    var placesClient: GMSPlacesClient!
    let manager = CLLocationManager()
    var mapView : GMSMapView!
    var originMarker = GMSMarker()
    var zoomLevel: Float = 17
    var defaultLocation = CLLocation()
    var aryPassengerData = NSArray()
    {
        didSet
        {
            var count = 0

            if let countAry = (((aryPassengerData.firstObject as? NSDictionary)?["BookingInfo"] as? NSArray)?.count)
            {
                count = countAry
            }
            else if let countDict = (((aryPassengerData.firstObject as? NSDictionary)?["BookingInfo"] as? NSDictionary)?.count)
            {
                count = countDict
            }
            DispatchQueue.main.async {
                self.headerView?.viewSOSIcon.isHidden = count == 0 ? true : false
            }
        }
    }
    var bookingID = String()
    var advanceBookingID = String()
    var toursBookingId = ""
    var toursBookingType = ""
    var driverID = String()
    @IBOutlet var btnMeter : UIButton!
    
    var strSpeed = String()
    
    var selectedRoute: Dictionary<String, AnyObject>!
    var overviewPolyline: Dictionary<String, AnyObject>!
    
    var originCoordinate: CLLocationCoordinate2D!
    var destinationCoordinate: CLLocationCoordinate2D!
    var arrLocationHistory = [CLLocation]()
    
    var sumOfFinalDistance = Double()
    var dictCompleteTripData = NSDictionary()
    
    weak var delegateOfRequest: ReceiveRequestDelegate!
    
    var strPickupLocation = String()
    var strDropoffLocation = String()
    var strDropoffLocation2 = String()
    var strPassengerName = String()
    var strPassengerMobileNo = String()
    
    var aryBookingData = NSArray()
    
    var driverMarker: GMSMarker!
    var isAdvanceBooking = Bool()
    var isNowBooking = Bool()
    
    var startLocation: CLLocation!
    var lastLocation: CLLocation!
    var startDate: Date!
    var traveledDistance: Double = 0
    
    var isCameraDisable: Bool = false
    var isCarStopped: Bool = false
    var carStoppedTimer: Bool = false
    
    lazy var geocoder = CLGeocoder()
    
    //MARK:- Holding Button
    
    @IBOutlet weak var btnCompleteTrip: UIButton!
    @IBOutlet weak var btnWaiting: UIButton!
    @IBOutlet weak var btnWaiting2 : UIButton!
    @IBOutlet weak var btnShowWaiting : UIButton!
    
    //-------------------------------------------------------------
    // MARK: - Base Methods
    //-------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.socketMethods()
        
        self.hideEstimatedView()
        self.btnReached.titleLabel?.numberOfLines = 0
        self.btnWaiting2.titleLabel?.numberOfLines = 0
        self.btnShowWaiting.titleLabel?.numberOfLines = 0
        
       
        
        btnMyJob.layer.cornerRadius = btnHome.frame.size.height - 30
        btnMyJob.clipsToBounds = true
        btnHome.layer.cornerRadius = btnHome.frame.size.height - 30
        btnHome.clipsToBounds = true
        btnMyJob.borderColor = UIColor.black// UIColor.init(red: 228/255, green: 132/255, blue: 40/255, alpha: 1.0)
        btnHome.borderColor = UIColor.black//.init(red: 228/255, green: 132/255, blue: 40/255, alpha: 1.0)
        btnCurrentlocation.layer.cornerRadius = 5
        btnCurrentlocation.layer.masksToBounds = true
        //        viewLocationDetails.layer.cornerRadius = 5
        //        btnHome.b
        self.hideEstimatedView()
        BottomButtonView.isHidden = true
        //        StartTripView.isHidden = true
        btnStartTrip.isHidden = true
        viewHomeMyJobsBTN.isHidden = false
        self.constrainLocationViewBottom?.priority = UILayoutPriority(rawValue: 600)
        isAdvanceBooking = false
        self.advanceBookingID = ""
        Singletons.sharedInstance.isFirstTimeDidupdateLocation = true;
        moveMent = ARCarMovement()
        moveMent.delegate = self
        
        viewOFHome.layer.cornerRadius = viewRound.frame.size.height / 2
        viewOFHome.clipsToBounds = true
        viewRound.layer.cornerRadius = viewRound.frame.size.height / 2
        viewRound.clipsToBounds = true
        
        Utilities.setCornerRadiusButton(button: btnStartTrip, borderColor: UIColor.black, bgColor: ThemeAppMainColor, textColor: UIColor.black)
        Utilities.setCornerRadiusButton(button: btnReached, borderColor: UIColor.black, bgColor: ThemeAppMainColor, textColor: UIColor.black)
        Utilities.setCornerRadiusButton(button: btnPassengerInfo, borderColor: UIColor.black, bgColor: UIColor.white, textColor: .black)
        Utilities.setCornerRadiusButton(button: btnCancelTrip, borderColor: UIColor.black, bgColor: UIColor.white, textColor: .black)
        Utilities.setCornerRadiusButton(button: btnDirectionFourBTN, borderColor: UIColor.black, bgColor: UIColor.white, textColor: .black)
        Utilities.setCornerRadiusButton(button: btnCompleteTrip, borderColor: UIColor.black, bgColor: ThemeAppMainColor, textColor: .black)
        Utilities.setCornerRadiusButton(button: btnDirection, borderColor: UIColor.black, bgColor: UIColor.white, textColor: .black)
        Utilities.setCornerRadiusButton(button: btnWaiting, borderColor: UIColor.black, bgColor: ThemeAppMainColor, textColor: .black)
        Utilities.setCornerRadiusButton(button: btnWaiting2, borderColor: UIColor.black, bgColor: ThemeAppMainColor, textColor: .black)
        Utilities.setCornerRadiusButton(button: btnShowWaiting, borderColor: UIColor.black, bgColor: UIColor.white, textColor: UIColor(red: 170/255, green: 53/255, blue: 58/255, alpha: 1.0))
        
        NotificationCenter.default.addObserver(self, selector: #selector(btnHoldWaiting(_:)), name: NSNotification.Name(rawValue: "HoldCurrentTrip"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(btnCompleteTrip(_:)), name: NSNotification.Name(rawValue: "endTrip"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.webserviceOfRunningTripTrack), name: NotificationTrackRunningTrip, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.setLocalization), name: NotificationChangeLanguage, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.setLocalization), name: NotificationChangeLanguage, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.goChatScreen), name: GoToChatScreen, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.goChatWithDispatcher), name: GoToDispatcherChatScreen, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.signOutUser), name: UserSignOut, object: nil)
        
        setCar()
        
        if(SingletonsForMeter.sharedInstance.arrCarModels.count == 0)
        {
            self.webserviceCallToGetFare()
        }
        UtilityClass.showACProgressHUD()
        
        self.tabBarController?.delegate = self
        
        let profile: NSMutableDictionary = NSMutableDictionary(dictionary: (Singletons.sharedInstance.dictDriverProfile.object(forKey: "profile") as? NSDictionary)!)
        let Vehicle: NSMutableDictionary = NSMutableDictionary(dictionary: profile.object(forKey: "Vehicle") as! NSDictionary)
        
        
        let stringOFVehicleModel: String = Vehicle.object(forKey: "VehicleModel") as! String
        
        let stringToArrayOFVehicleModel = stringOFVehicleModel.components(separatedBy: ",")
        
        Singletons.sharedInstance.arrVehicleClass = NSMutableArray(array: stringToArrayOFVehicleModel.map { Int($0)!})
        
        driverID = Vehicle.object(forKey: "DriverId") as! String
        
        placesClient = GMSPlacesClient.shared()
        
        manager.delegate = self
        
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            
//            if (manager.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization)) || manager.responds(to: #selector(CLLocationManager.requestAlwaysAuthorization)))
//            {
//                if manager.location != nil
//                {
                    manager.startUpdatingLocation()
                    manager.desiredAccuracy = kCLLocationAccuracyBest
                    manager.activityType = .automotiveNavigation
                    manager.startMonitoringSignificantLocationChanges()
                    manager.allowsBackgroundLocationUpdates = true
                    //                    manager.distanceFilter = //
//                }
//            }
        }
        
        
        let camera = GMSCameraPosition.camera(withLatitude: defaultLocation.coordinate.latitude, longitude: defaultLocation.coordinate.longitude, zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - 40), camera: camera)
        self.mapView.delegate = self
        mapView.isHidden = true
        subMapView.addSubview(mapView)
        
        getCurrentPlace()
        
        //        if let reqAccepted: Bool = UserDefaults.standard.bool(forKey: tripStatus.kisRequestAccepted) as? Bool {
        //            Singletons.sharedInstance.isRequestAccepted = reqAccepted
        //        }
        
        //        if let holdingTrip: Bool = UserDefaults.standard.bool(forKey: holdTripStatus.kIsTripisHolding) as? Bool {
        //            Singletons.sharedInstance.isTripHolding = holdingTrip
        //        }
        
        if Singletons.sharedInstance.isTripHolding {
            self.btnWaiting.isSelected = true
            //            btnWaiting.setTitle("Stop Waiting".localized,for: .normal)
        }
        else {
            self.btnWaiting.isSelected = false
            //            btnWaiting.setTitle("Hold Trip".localized,for: .normal)
        }
        
        //TODO: uncomment in production
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.checkCurrentTrip()
        }
        
        runTimer()
        
        if (Singletons.sharedInstance.driverDuty == "0")
        {
           // UtilityClass.showAlert("", message: "message_getOnline".localized, vc: self)
        }
        
        self.checkForNotification()
        
    }
    override func viewDidLayoutSubviews() {
        self.headerView?.lblTitle.text = "Home".localized
        btnWaiting.setTitle("Hold Trip".localized, for: .normal)
        btnWaiting.setTitle("Stop waiting".localized, for: .selected)
        //        viewRoundForHome.layer.cornerRadius = viewRound.frame.size.height / 2
        //        viewRoundForHome.clipsToBounds = true
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        self.isAlreadyPopView = false
    }
    var timerForUpdateCurrentLocation = Timer()
    
    func checkForNotification(){
        if(AppDelegate.pushNotificationObj != nil){
            if(AppDelegate.pushNotificationType == NotificationTypes.newMeassage.rawValue){
                self.ChatScreen()
            }
        }
    }
    
    func ChatScreen() {
        let bookingID = AppDelegate.pushNotificationObj?.booking_id ?? ""
        let senderID = AppDelegate.pushNotificationObj?.sender_id ?? ""
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
        viewController.receiverName = ""
        viewController.bookingId = bookingID
        viewController.receiverId = senderID
        viewController.isFromPush = true
        viewController.isDispacherChat = (bookingID == "0" || bookingID == "") ? true : false
        self.navigationController?.pushViewController(viewController, animated: true)
        
        AppDelegate.pushNotificationObj = nil
        AppDelegate.pushNotificationType = nil
    }
    
    @objc func goChatScreen() {
        self.ChatScreen()
    }
    
    
    
    func hideEstimatedView() {
        self.stackEstimatedView.isHidden = true
        self.stackEstimatedViewHeight.constant = 0
        self.view.updateConstraintsIfNeeded()
    }
    
    func showEstimatedView() {
        self.stackEstimatedView.isHidden = false
        self.stackEstimatedViewHeight.constant = 36
        self.view.updateConstraintsIfNeeded()
    }
    
    func runTimer() {
        timerForUpdateCurrentLocation = Timer.scheduledTimer(timeInterval: 7, target: self,   selector: (#selector(self.updateCurrentLocationLabel)), userInfo: nil, repeats: true)
    }
    
    @objc func updateCurrentLocationLabel() {
        
        if defaultLocation.coordinate.latitude != 0 && defaultLocation.coordinate.longitude != 0 {
            getAddressForLatLng(latitude: "\(defaultLocation.coordinate.latitude)", Longintude: "\(defaultLocation.coordinate.longitude)")
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return true
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController)
    {
        print(viewController)
        if(viewController.isKind(of: PayViewController.self))
        {
            if(Singletons.sharedInstance.isPasscodeON)
            {
                if Singletons.sharedInstance.setPasscode == ""
                {
                    let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SetPasscodeViewController") as! SetPasscodeViewController
                    viewController.modalPresentationStyle = .formSheet
                    self.present(viewController, animated: false, completion: nil)
                }
                else
                {
                    let viewController = self.storyboard?.instantiateViewController(withIdentifier: "VerifyPasswordViewController") as! VerifyPasswordViewController
                    self.present(viewController, animated: false, completion: nil)
                }
            }
            
        }
    }
    
    // MARK:-
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(true)
        
        self.navigationController?.isNavigationBarHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(changeLanguage), name: Notification.Name(rawValue: LCLLanguageChangeNotification), object: nil)
        setLocalization()
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
//            self.openToursVC()
//        }
        
        self.checkCurrentTrip()
    }
    
    @objc func changeLanguage(){
        self.setLocalization()
    }
    
    @objc func setLocalization()
    {
        self.headerView?.lblTitle.text = "Home".localized
        let image = (Localize.currentLanguage() == Languages.English.rawValue) ? "ic_DispatcherChat" : "ic_DispatcherChat_es"
        self.headerView?.btnWhatsapp.setBackgroundImage(UIImage(named: image), for: .normal)
        
        self.lblPickUpLocation.text = "Current Location".localized
        
        btnWaiting.setTitle("Hold Trip".localized, for: .normal)
        btnWaiting.setTitle("Stop waiting".localized, for: .selected)
        //        btnHome.setTitle("Home".localized, for: .normal)
        //        btnMyJob.setTitle("My Job".localized, for: .normal)
        
        if(btnStartTrip.titleLabel?.text == "conductor fuera" || btnStartTrip.titleLabel?.text == "Driver Outside"){
            btnStartTrip.setTitle("Driver Outside".localized, for: .normal)
        }else{
            btnStartTrip.setTitle("Start Trip".localized, for: .normal)
        }
        
        
        btnPassengerInfo.setTitle("Passenger Info".localized, for: .normal)
        btnCancelTrip.setTitle("Cancel Trip".localized, for: .normal)
        btnDirectionFourBTN.setTitle("Direction".localized, for: .normal)
        
        btnCompleteTrip.setTitle("Complete Trip".localized, for: .normal)
        btnDirection.setTitle("Direction".localized, for: .normal)
        btnReached.setTitle("Complete First Stop".localized, for: .normal)
        
        self.btnWaiting2.setTitle("Stop Waiting Time".localized, for: .selected)
        self.btnWaiting2.setTitle("Start Waiting Time".localized, for: .normal)
       // self.btnShowWaiting.setTitle("Waiting Time ".localized, for: .normal)
        
        let title = "Waiting Time ".localized + App_Delegate.WaitingTime
        self.btnShowWaiting.setTitle(title, for: .normal)
        
    }
    
    @IBAction func btnSidemenuClicked(_ sender: Any)
    {
        sideMenuController?.toggle()
    }
    
    @objc func btnRightSideClicked(_ sender:Any)
    {
        //        if sender.isOn
        //        {
        //            webserviceForChangeDutyStatus()
        //            print("on")
        //        } else{
        //            webserviceForChangeDutyStatus()
        //            print("off")
        //        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // print ("\(#function) -- \(self)")
        Singletons.sharedInstance.isFromNotification = true
        
        for view in self.view.subviews {
            if let SubView = view as? ToursView {
                self.closeToursPopup()
                SubView.removeFromSuperview()
            }
        }
        
    }
    
    // ------------------------------------------------------------
    //MARK:- Location delegate methods
    // ------------------------------------------------------------
    
    var driverIDTimer : String!
    var passengerIDTimer : String!
    var timerToGetDriverLocation : Timer!
    
    func sendPassengerIDAndDriverIDToGetLocation(driverID : String , passengerID: String) {
        
        driverIDTimer = driverID
        passengerIDTimer = passengerID
        if timerToGetDriverLocation == nil {
            timerToGetDriverLocation = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(HomeViewController.getDriverLocation), userInfo: nil, repeats: true)
        }
    }
    
    func stopTimer() {
        if timerToGetDriverLocation != nil {
            timerToGetDriverLocation.invalidate()
            timerToGetDriverLocation = nil
        }
    }
    
    @objc func getDriverLocation()
    {
        let BookingInfo : NSDictionary!
        
        if(self.aryPassengerData.count == 0)
        {
            return
        }
        
        if((((self.aryPassengerData as NSArray).object(at: 0) as? NSDictionary)?.object(forKey: "BookingInfo") as? NSDictionary) == nil)
        {
            BookingInfo = (((self.aryPassengerData as NSArray).object(at: 0) as? NSDictionary)?.object(forKey: "BookingInfo") as? NSArray)?.object(at: 0) as? NSDictionary
        }
        else
        {
            BookingInfo = (((self.aryPassengerData as NSArray).object(at: 0) as? NSDictionary)?.object(forKey: "BookingInfo") as? NSDictionary) //.object(at: 0) as! NSDictionary
        }
        
        let strPassengerID = BookingInfo.object(forKey: "PassengerId") as? String ?? "\(BookingInfo.object(forKey: "PassengerId") as? Int ?? 0)"
        //        let driverID = BookingInfo.object(forKey: "PassengerId") as! String
        
       
        var myJSON : [String : Any] = [:]
        let Id = BookingInfo.object(forKey: "Id") as? String ?? ""
        let IntId = BookingInfo.object(forKey: "Id") as? Int ?? 0
        
        let currentBookingStatus = BookingInfo.object(forKey: "Status") as? String ?? ""
      
        if(currentBookingStatus == "pending" || currentBookingStatus == "accepted"){
            myJSON = ["PassengerId" : strPassengerID,
                      "DriverId" : driverID ,
                      "Lat" : Singletons.sharedInstance.latitude ?? 0.0,
                      "Long" :Singletons.sharedInstance.longitude ?? 0.0,
                      "BookingId" : (Id != "") ? Id : IntId,
                      "BookingType" : Singletons.sharedInstance.strBookingType] as [String : Any]
        } else {
            myJSON = ["PassengerId" : strPassengerID,
                      "DriverId" : driverID ,
                      "Lat" : Singletons.sharedInstance.latitude ?? 0.0,
                      "Long" :Singletons.sharedInstance.longitude ?? 0.0,
                      "BookingId" : (Id != "") ? Id : IntId,
                      "BookingType" : Singletons.sharedInstance.strBookingType] as [String : Any]
        }
 
        socket.emit(socketApiKeys.kSendDriverLocationRequestByPassenger , with: [myJSON], completion: nil)
        print(myJSON)
        
        if (self.arrivedRoutePath != nil && !(GMSGeometryIsLocationOnPathTolerance(self.driverMarker.position, self.arrivedRoutePath!, true, 100)))
        {
            self.reRoute(DriverCordinate: defaultLocation.coordinate)
        }
        print("\(socketApiKeys.kSendDriverLocationRequestByPassenger) \(myJSON)")
    }
    
    @objc func timerAction() {
        WaitingCounter += 1
        
        if(WaitingCounter == Singletons.sharedInstance.WaitingTimeNotify) {
            self.carStoppedTimer = false
            WaitingCounter = 0
            WaitingHoldTimer.invalidate()
            
            if(!self.stackViewOfWaitingTime.isHidden  && !App_Delegate.RoadPickupTimer.isValid && (self.bookingID != "" || self.advanceBookingID != "" || self.toursBookingId != "")){
                UtilityClass.showAlertWithCompletion("", message: "Please start waiting time, If you're on hold during the trip.".localized, vc: self, completionHandler: { (status) in
                   
                })
                
                var myJSON : [String : Any] = [:]
                myJSON = ["booking_type" : (self.isAdvanceBooking) ? "BookLater" : "BookNow",
                          "booking_id" : (self.bookingID != "") ? self.bookingID : self.advanceBookingID] as [String : Any]
                self.socket.emit(socketApiKeys.KWaitingTimeToDispatchere, with: [myJSON], completion: nil)
                
            }
        }
    }

    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location: CLLocation = locations.last!
        let kmh = location.speed / 1000.0 * 60.0 * 60.0
    
        if(kmh <= 5.0  && !self.stackViewOfWaitingTime.isHidden  && !App_Delegate.RoadPickupTimer.isValid && (self.bookingID != "" || self.advanceBookingID != "")){
            print("Speed : \(kmh)")
            if(WaitingHoldTimer.isValid == false){
                WaitingHoldTimer.invalidate()
                WaitingHoldTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
            }
            
        }else{
            if(WaitingHoldTimer.isValid == true){
                WaitingCounter = 0
                WaitingHoldTimer.invalidate()
                btnDirection.setTitle("Direction".localized, for: .normal)
            }
        }
        
        
//        if(kmh <= 0.0){
//            self.isCarStopped = true
//            if(self.carStoppedTimer == false && !self.stackViewOfWaitingTime.isHidden){
//                self.carStoppedTimer = true
//                DispatchQueue.main.asyncAfter(deadline: .now() + 180) {
//                    if(self.carStoppedTimer && (self.bookingID != "" || self.advanceBookingID != "") && !self.stackViewOfWaitingTime.isHidden && !App_Delegate.RoadPickupTimer.isValid && kmh <= 0.0){
//
//                        self.isCarStopped = false
//                        self.carStoppedTimer = false
//                        UtilityClass.showAlertWithCompletion("", message: "Please start waiting time, If you're on hold during the trip.".localized, vc: self, completionHandler: { (status) in
//
//                        })
//
//                        var myJSON : [String : Any] = [:]
//                        myJSON = ["booking_type" : (self.isAdvanceBooking) ? "BookLater" : "BookNow",
//                                  "booking_id" : (self.bookingID != "") ? self.bookingID : self.advanceBookingID] as [String : Any]
//                        self.socket.emit(socketApiKeys.KWaitingTimeToDispatchere, with: [myJSON], completion: nil)
//                    }
//                }
//            }
//        }
        
        let state = UIApplication.shared.applicationState
        if state == .background {
            print("The location we are getting in background mode is \(location)")
        }
        defaultLocation = location
        
        //        if(Singletons.sharedInstance.isFirstTimeDidupdateLocation == true)
        //        {

        //            Singletons.sharedInstance.isFirstTimeDidupdateLocation = false
        //        }
        
        arrLocationHistory.append(location)
        //        userDefault.set(NSKeyedArchiver.archivedData(withRootObject: arrLocationHistory), forKey: "locationHistory")
        
        
        Singletons.sharedInstance.latitude = defaultLocation.coordinate.latitude
        Singletons.sharedInstance.longitude = defaultLocation.coordinate.longitude
        
        
        if(Singletons.sharedInstance.isRequestAccepted)
        {
            
            if(oldCoordinate == nil)
            {
                oldCoordinate = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
                
//                let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,longitude: location.coordinate.longitude,zoom: zoomLevel)
//                mapView.animate(to: camera)
            }
            
            if(driverMarker == nil)
            {
                driverMarker = GMSMarker(position: oldCoordinate)
                driverMarker.icon = UIImage(named: Singletons.sharedInstance.strSetCar)
                driverMarker.map = mapView
            }
            
            driverMarker.map = mapView
            
            //            calculateDistance()
            
            let newCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(CLLocationDegrees(Singletons.sharedInstance.latitude), CLLocationDegrees(Singletons.sharedInstance.longitude))
            if oldCoordinate != nil {
                CATransaction.begin()
                CATransaction.setValue(2, forKey: kCATransactionAnimationDuration)
            }
            
            let bearing = getBearingBetweenTwoPoints(point1: CLLocationCoordinate2DMake(oldCoordinate.latitude, oldCoordinate.longitude), point2:CLLocationCoordinate2DMake(newCoordinate.latitude, newCoordinate.longitude))
                                                     
            if(self.boolShouldTrackCamera) {
               // let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,longitude: location.coordinate.longitude,zoom: zoomLevel)
                let camera = GMSCameraPosition.camera(withTarget: CLLocationCoordinate2DMake(oldCoordinate.latitude, oldCoordinate.longitude), zoom: zoomLevel, bearing: bearing, viewingAngle: 45)
                mapView.animate(to: camera)
            }
            
            self.moveMent.ARCarMovement(marker: driverMarker, oldCoordinate: oldCoordinate, newCoordinate: newCoordinate, mapView: mapView, bearing: 0)
            oldCoordinate = newCoordinate
           
            if oldCoordinate != nil {
                CATransaction.commit()
            }
            
        } else{
            if(self.boolShouldTrackCamera) {
                let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,longitude: location.coordinate.longitude,zoom: zoomLevel)
                mapView.animate(to: camera)
            }
        }
        
        // To track Meter
        if(Singletons.sharedInstance.MeterStatus != meterStatus.kIsMeterStop && Singletons.sharedInstance.MeterStatus != "")
        {
            if startLocation == nil {
                startLocation = locations.first
            } else if let location = locations.last {
                
                if(SingletonsForMeter.sharedInstance.isMeterOnHold == false)
                {
                    traveledDistance += lastLocation.distance(from: location)
                    print("Traveled Distance:",  traveledDistance)
                    Singletons.sharedInstance.distanceTravelledThroughMeter = (traveledDistance/1000)
                    
                    //                    print("Straight Distance:", startLocation.distance(from: locations.last!))
                    if(SingletonsForMeter.sharedInstance.arrCarModels.count != 0)
                    {
                        self.calculateDistanceAndPrice()
                    }
                }
                else
                {
                    lastLocation = defaultLocation
                    startLocation = defaultLocation
                    
                    print("meter is on hold")
                    
                    
                    //                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateWaitingTime"), object: nil)
                }
                
            }
            lastLocation = locations.last
            
            // To get Speed
            
            //        if(location.speed > 0) {
            var kmh = location.speed / 1000.0 * 60.0 * 60.0
            print("Spped : \(kmh)")
            if(kmh < 0){
                kmh = 0
            }
            if let speed = HomeViewController.numberFormatter.string(from: NSNumber(value: kmh)) {
                strSpeed = "\(speed)"
                SingletonsForMeter.sharedInstance.strSpeed = strSpeed
                // This code is commented Because of Auto Hold Trip Functionality is not Required
                //                if (kmh < 5 && Singletons.sharedInstance.MeterStatus == meterStatus.kIsMeterStart)
                //                {
                //                    Singletons.sharedInstance.MeterStatus = meterStatus.kIsMeterOnHolding
                //                    self.btnHoldWaiting((self.btnWaiting)!)
                //                }
                //                else if (kmh > 5)
                //                {
                //                    Singletons.sharedInstance.MeterStatus = meterStatus.kIsMeterStart
                //                    self.btnHoldWaiting((self.btnWaiting)!)
                //                }
                
            }
            else
            {
                SingletonsForMeter.sharedInstance.strSpeed = "0.0 km/hr"
            }
            
        }
        else
        {
            traveledDistance = 0;
        }
        
        
        //        }
        //        else {
        // This code is commented Because of Auto Hold Trip Functionality is not Required
        //            strSpeed = "\(0.0)"
        //            if (Singletons.sharedInstance.MeterStatus == meterStatus.kIsMeterStart && Singletons.sharedInstance.MeterStatus != "")
        //            {
        //                Singletons.sharedInstance.MeterStatus = meterStatus.kIsMeterOnHolding
        //                self.btnHoldWaiting((self.btnWaiting)!)
        //            }
        //        }
        
        //
        
        if mapView.isHidden
        {
            mapView.isHidden = false
            self.view.bringSubviewToFront(self.viewLocationDetails)
            self.view.bringSubviewToFront(self.btnCurrentlocation)
            self.view.bringSubviewToFront(self.btnMeter)
            subMapView.bringSubviewToFront(mapView)
            //            self.mapView.settings.rotateGestures = false
            //            self.mapView.settings.tiltGestures = false
           
//            if(socket.status != .connected){
//                self.socketMethods()
//            }
        }
        else
        {
            if(oldCoordinate == nil)
            {
                oldCoordinate = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
            }
            
            if(driverMarker == nil)
            {
                driverMarker = GMSMarker(position: oldCoordinate)
                driverMarker.icon = UIImage(named: Singletons.sharedInstance.strSetCar)
                driverMarker.map = mapView
            }
            
            if(!Singletons.sharedInstance.isRequestAccepted)
            {
                
                let newCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(CLLocationDegrees(Singletons.sharedInstance.latitude), CLLocationDegrees(Singletons.sharedInstance.longitude))
                self.moveMent.ARCarMovement(marker: driverMarker, oldCoordinate: oldCoordinate, newCoordinate: newCoordinate, mapView: mapView, bearing: 45)
                oldCoordinate = newCoordinate
                //Tej's code
//                let newCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(CLLocationDegrees(Singletons.sharedInstance.latitude), CLLocationDegrees(Singletons.sharedInstance.longitude))
//                if oldCoordinate != nil {
//                    CATransaction.begin()
//                    CATransaction.setValue(2, forKey: kCATransactionAnimationDuration)
//                }
//                if(self.boolShouldTrackCamera) {
//                    let camera = GMSCameraPosition.camera(withLatitude: newCoordinate.latitude, longitude: newCoordinate.longitude, zoom: zoomLevel)
//                    mapView.animate(to: camera)
//                }
//                self.moveMent.ARCarMovement(marker: driverMarker, oldCoordinate: oldCoordinate, newCoordinate: newCoordinate, mapView: mapView, bearing: Float(Singletons.sharedInstance.floatBearing))
//                if oldCoordinate != nil {
//                    CATransaction.commit()
//                }
//                oldCoordinate = newCoordinate
                //Tej's code
            }
            if (Singletons.sharedInstance.driverDuty == "1") {
                if(self.bookingID.trimmingCharacters(in: .whitespacesAndNewlines) == "" && self.advanceBookingID.trimmingCharacters(in: .whitespacesAndNewlines) == "") {
                    self.UpdateDriverLocation()
                } else if (self.bookingID.trimmingCharacters(in: .whitespacesAndNewlines) != "" || self.advanceBookingID.trimmingCharacters(in: .whitespacesAndNewlines) != "") {
                    self.getDriverLocation()
                }
            }
        }
    }
    
    
    func degreesToRadians(degrees: Double) -> Double { return degrees * .pi / 180.0 }
    func radiansToDegrees(radians: Double) -> Double { return radians * 180.0 / .pi }

    func getBearingBetweenTwoPoints(point1 : CLLocationCoordinate2D, point2 : CLLocationCoordinate2D) -> Double {

        let lat1 = degreesToRadians(degrees: point1.latitude)
        let lon1 = degreesToRadians(degrees: point1.longitude)

        let lat2 = degreesToRadians(degrees: point2.latitude)
        let lon2 = degreesToRadians(degrees: point2.longitude)

        let dLon = lon2 - lon1

        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)

        return radiansToDegrees(radians: radiansBearing)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        
        if(newLocation.speed > 0) {
            let kmh = newLocation.speed / 1000.0 * 60.0 * 60.0
            
            if let speed = HomeViewController.numberFormatter.string(from: NSNumber(value: kmh)) {
                strSpeed = "\(speed)"
                SingletonsForMeter.sharedInstance.strSpeed = strSpeed
                
                // This code is commented Because of Auto Hold Trip Functionality is not Required
                //                if (kmh < 5)
                //                {
                //                    Singletons.sharedInstance.MeterStatus = meterStatus.kIsMeterOnHolding
                //                    self.btnHoldWaiting((self.btnWaiting)!)
                //                }
                //                else if (kmh > 5)
                //                {
                //                    self.btnHoldWaiting((self.btnWaiting)!)
                //                }
                
            }
        }
        else {
            strSpeed = "\(newLocation.speed)"
            SingletonsForMeter.sharedInstance.strSpeed = strSpeed
            // This code is commented Because of Auto Hold Trip Functionality is not Required
            //            if (Singletons.sharedInstance.MeterStatus != meterStatus.kIsMeterOnHolding)
            //            {
            //                Singletons.sharedInstance.MeterStatus = meterStatus.kIsMeterOnHolding
            //                self.btnHoldWaiting((self.btnWaiting)!)
            //            }
        }
        
    }
    
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted: break
        case .denied:
            mapView.isHidden = false
        case .notDetermined: break
        case .authorizedAlways:
            manager.startUpdatingLocation()
            
        case .authorizedWhenInUse:
            manager.startUpdatingLocation()
            
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // print (error)
        if (error as? CLError)?.code == .denied {
            manager.stopUpdatingLocation()
            manager.stopMonitoringSignificantLocationChanges()
        }
    }
    
    // ------------------------------------------------------------
    
    
    func calculateDistance()
    {
        
        let decoded  = UserDefaults.standard.object(forKey: "locationHistory") as! Data
        let decodedTeams = NSKeyedUnarchiver.unarchiveObject(with: decoded)! as! [CLLocation]
        //
        print("location history is \(String(describing: decodedTeams.count))")
        
        for i in 0..<decodedTeams.count
        {
            let location0 = decodedTeams[i]
            //            var location1 : CLLocation!
            //            if(decodedTeams.count - 1 > i)
            //            {
            //                location1 = decodedTeams[i+1]
            //            }
            
            if startLocation == nil {
                startLocation = location0
            } else
            {
                let location = location0
                
                traveledDistance += lastLocation.distance(from: location)
                print("Traveled Distance:",  traveledDistance/1000)
                
            }
            lastLocation = location0
        }
    }
    
    var nameLabel = String()
    var addressLabel = String()
    
    
    func getCurrentPlace()
    {
        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            if error != nil {
                // print ("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            self.nameLabel = "No current place"
            self.addressLabel = ""
            
            if let placeLikelihoodList = placeLikelihoodList {
                let place = placeLikelihoodList.likelihoods.first?.place
                if let place = place {
                    self.nameLabel = place.name ?? ""
                    self.addressLabel = (place.formattedAddress?.components(separatedBy: ", ").joined(separator: "\n"))!
                }
            }
            
            if let placeLikelihoodList = placeLikelihoodList {
                for likelihood in placeLikelihoodList.likelihoods {
                    let place = likelihood.place
                    
                    self.lblLocationOnMap.text = place.formattedAddress
                    
                }
            }
        })
        
    }
    @IBAction func btnMyJob(_ sender: UIButton) {
        sender.LoadButtonAnimation()
        performSegue(withIdentifier: "segueToMyJob", sender: self)
    }
    
    // ------------------------------------------------------------
    //-------------------------------------------------------------
    // MARK: - Socket Methods
    //-------------------------------------------------------------
    
    var strTempBookingId = String()
    var bookingIDTemp = String()

    func socketMethods()
    {
        if(socket.status == .connected){
            self.methodsAfterConnectingToSocket()
        } else {
            socket.connect()
        }
        
        socket.on(clientEvent: .disconnect) { (data, ack) in
            print ("socket is disconnected please reconnect")
        }
        
        socket.on(clientEvent: .reconnect) { (data, ack) in
            print ("socket is reconnected please reconnect")
        }
        
        socket.on(clientEvent: .connect) {data, ack in
            print ("socket connected")
            self.methodsAfterConnectingToSocket()
        }
    }
    
    func methodsAfterConnectingToSocket() {
        self.socketOnForGetDriverLocation()
        self.socketCallForReceivingBookingRequest()                 // ReceiveBookingRequest
        self.UpdateDriverLocation()                                 // UpdateDriverLocation
        self.ReceiveBookLaterBookingRequest()                       // AriveAdvancedBookingRequest
        self.CancelBookLaterTripByCancelNotification()      // AdvancedBookingDriverCancelTripNotification
        self.GetBookingDetailsAfterBookingRequestAccepted()         // BookingInfo
        self.GetAdvanceBookingDetailsAfterBookingRequestAccepted()  // AdvancedBookingInfo
        self.cancelTripByPassenger()                                // DriverCancelTripNotification
        self.NewBookLaterRequestArrivedNotification()   // AdvancedBookingDriverCancelTripNotification
        self.getNotificationForReceiveMoneyNotify()     // ReceiveMoneyNotify
        self.onSessionError()// SessionError
        self.onUpdateDropoffLocation()
        self.getTimeOfStartTrip()                       // StartTripTimeError
        self.getNotificationforReceiveTip()
        self.getNotificationforReceiveTipForBookLater()
        self.checkIfDriverIsInPickupLocationRadius()
        self.onSOS()
        self.onAdvancedBookingPickupPassengerNotification() // AdvancedBookingPickupPassengerNotification
        // Tours
        self.onNewRequestTours()
        self.onGettingRentalBookingInfo()
    }
    
    func socketOnForGetDriverLocation() {
        self.socket.on(socketApiKeys.kGetDriverLocation, callback: { (data, ack) in
            print ("kGetDriverLocation is :  \(data)")
            
            let estimatedTime = ((data as NSArray).object(at: 0) as! NSDictionary).object(forKey: "duration") as? String ?? ""
            let estimatedDistance = ((data as NSArray).object(at: 0) as! NSDictionary).object(forKey: "distance") as? String ?? ""
            self.lblEstimatedTimeNew.text =  "Estimated Time : ".localized + estimatedTime
            self.lblEstimatedDistanceNew.text = "Estimated Distance : ".localized + estimatedDistance
        })
    }
    
    func socketCallForReceivingBookingRequest()
    {
        self.socket.on(socketApiKeys.kReceiveBookingRequest, callback: { (data, ack) in
            // print ("data is \(data)")
            print ("kReceiveBookingRequest : \(data)")
            
            
            if(self.aryPassengerData.count != 0 && Singletons.sharedInstance.bookingId != "")
            {
                if let BookingID = ((data as NSArray).object(at: 0)as? NSDictionary)?.object(forKey: "BookingId") as? String
                {
                    self.BookingRejected(isTripOnGoing: true, bookingID: BookingID)
                }
                return
            }
            
            self.isAdvanceBooking = false
            self.advanceBookingID = ""
            self.isNowBooking = true
            self.playSound(strName: "\(RingToneSound)")
            
            self.bookingID = ((data as NSArray).object(at: 0) as! NSDictionary).object(forKey: "BookingId") as! String
            if let rideType = ((data as NSArray).object(at: 0) as! NSDictionary).object(forKey: "RideType") as? String {
                self.bookingIDTemp = self.bookingID

                Singletons.sharedInstance.strRideTypeFromAcceptRequest = rideType
                
                //                if rideType == "ShareRide" {
                Singletons.sharedInstance.passengerType = "BookNow"
                
                if Singletons.sharedInstance.bookingId == "" {
                    Singletons.sharedInstance.bookingId = self.bookingID
                    Singletons.sharedInstance.isPending = 0
                }
                else {
                    Singletons.sharedInstance.bookingIdTemp = self.bookingID
                }
                
                let next = self.storyboard?.instantiateViewController(withIdentifier: "ReceiveRequestViewController") as! ReceiveRequestViewController
                next.delegate = self
                next.strGrandTotal = "0"
                if let grandTotal = ((data as NSArray).object(at: 0) as! NSDictionary).object(forKey: "EstimateFare") as? String {
                    if grandTotal == "" {
                        next.strEstimateFare = "0"
                    }
                    else {
                        next.strEstimateFare = grandTotal
                    }
                }
                else {
                    next.strEstimateFare = "0"
                }
                //                    if let grandTotal = ((data as NSArray).object(at: 0) as! NSDictionary).object(forKey: "GrandTotal") as? String {
                //                        if grandTotal == "" {
                //                            next.strGrandTotal = "0"
                //                        }
                //                        else {
                //                            next.strGrandTotal = grandTotal
                //                        }
                //                    }
                //                    else {
                //                        next.strGrandTotal = "0"
                //                    }
                if let PickupLocation = ((data as NSArray).object(at: 0) as! NSDictionary).object(forKey: "PickupLocation") as? String {
                    next.strPickupLocation = PickupLocation
                }
                
                if let DropoffLocation = ((data as NSArray).object(at: 0) as! NSDictionary).object(forKey: "DropoffLocation") as? String {
                    next.strDropoffLocation = DropoffLocation
                }
                
                
                if let DropoffLocation2 = ((data as NSArray).object(at: 0) as! NSDictionary).object(forKey: "DropoffLocation2") as? String {
                    next.strDropoffLocation2 = DropoffLocation2
                }
                
                if let RequestMessage = ((data as NSArray).object(at: 0) as! NSDictionary).object(forKey: GetResponseMessageKey()) as? String {
                    next.strRequestMessage = RequestMessage
                }
                
                if let PaymentType = ((data as NSArray).object(at: 0) as! NSDictionary).object(forKey: "PaymentType") as? String {
                    next.strPaymentType = PaymentType
                }
                
                if let bookingType = ((data as NSArray).object(at: 0) as! NSDictionary).object(forKey: "BookingType") as? String {
                    next.strBookingType = bookingType
                }
                
                self.addLocalNotification()
                (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.present(next, animated: true, completion: nil)
                
                return
                //                }
            }
            
            if let bookingType = ((data as NSArray).object(at: 0) as! NSDictionary).object(forKey: "BookingType") as? String {
                
                Singletons.sharedInstance.passengerType = bookingType
                Singletons.sharedInstance.strBookingType = bookingType
            }
            
            if Singletons.sharedInstance.firstRequestIsAccepted == true {
                
                self.strTempBookingId = ((data as NSArray).object(at: 0) as! NSDictionary).object(forKey: "BookingId") as! String
                
                self.BookingRejected()
                return
            }
            
            //            self.isAdvanceBooking = false
            //            self.isNowBooking = true
            //            self.bookingID = ((data as NSArray).object(at: 0) as! NSDictionary).object(forKey: "BookingId") as! String
            
            Singletons.sharedInstance.isPending = 1
            
           
            
            //            if Singletons.sharedInstance.bookingId == "" {
            //                Singletons.sharedInstance.bookingId = self.bookingID
            //                Singletons.sharedInstance.isPending = 0
            //            }
            //            else {
            //                Singletons.sharedInstance.bookingIdTemp = self.bookingID
            //            }
            
            if Singletons.sharedInstance.bookingId == "" {
                Singletons.sharedInstance.bookingId = self.bookingID
                Singletons.sharedInstance.isPending = 0
            }
            else {
                Singletons.sharedInstance.bookingIdTemp = self.bookingID
            }
            
            let next = self.storyboard?.instantiateViewController(withIdentifier: "ReceiveRequestViewController") as! ReceiveRequestViewController
            next.delegate = self
            
            if let grandTotal = ((data as NSArray).object(at: 0) as! NSDictionary).object(forKey: "GrandTotal") as? String {
                if grandTotal == "" {
                    next.strGrandTotal = "0"
                }
                else {
                    next.strGrandTotal = grandTotal
                }
            }
            else {
                next.strGrandTotal = "0"
            }
            
            if let PickupLocation = ((data as NSArray).object(at: 0) as! NSDictionary).object(forKey: "PickupLocation") as? String {
                next.strPickupLocation = PickupLocation
            }
            
            if let DropoffLocation = ((data as NSArray).object(at: 0) as! NSDictionary).object(forKey: "DropoffLocation") as? String {
                next.strDropoffLocation = DropoffLocation
            }
            
            
            
            self.addLocalNotification()
            
            
            
            
            (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.present(next, animated: true, completion: {
                Singletons.sharedInstance.firstRequestIsAccepted = true
                //                    self.stopSound()
            })
            
        })
    }
    
    
    func UpdateDriverLocation()
    {
        //        let nsObject: AnyObject? = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as AnyObject
#if targetEnvironment(simulator)
        Singletons.sharedInstance.deviceToken = "11111111"
#endif
        
        print(aryCurrentBookingData)
        
        if driverID == Singletons.sharedInstance.strDriverID
        {
            let myJSON = [profileKeys.kDriverId : driverID,
                          socketApiKeys.kLat: defaultLocation.coordinate.latitude,
                          socketApiKeys.kLong: defaultLocation.coordinate.longitude,
                          "Token": Singletons.sharedInstance.deviceToken] as [String : Any]
            socket.emit(socketApiKeys.kUpdateDriverLocation, with: [myJSON], completion: nil)
            print ("\(socketApiKeys.kUpdateDriverLocation) : \(myJSON)")
        }
        
        
    }
    
    
    func socketEmitForSOS()
    {
        let alertController = UIAlertController(title: "SOS".localized, message: "Are you sure you want to trigger SOS?", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Cancel \(SosTimerCount)".localized, style: .default, handler: {
            action in
            self.SosTimer?.invalidate()
            self.SosTimer = nil
            self.SosTimerCount = 10
            self.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(okAction)
        present(alertController, animated: true) {
            self.SosTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.countDownTimer), userInfo: nil, repeats: true)
        }
    }
    
    @objc func countDownTimer() {
        SosTimerCount -= 1
        
        let alertController = presentedViewController as! UIAlertController
        let okAction = alertController.actions.first
        
        if SosTimerCount == 0 {
            self.SosTimer?.invalidate()
            self.SosTimer = nil
            self.SosTimerCount = 10
            
            let myJSON = ["UserId" : driverID,
                          socketApiKeys.kBookingId: Singletons.sharedInstance.strBookingType == "BookLater" ? advanceBookingID : bookingID,
                          socketApiKeys.kBookingType : Singletons.sharedInstance.strBookingType == "BookLater" ? "AdvanceBooking" : "Booking",
                          socketApiKeys.kUserType: "Driver", "Token": Singletons.sharedInstance.deviceToken,socketApiKeys.kLat: defaultLocation.coordinate.latitude, "Lng": defaultLocation.coordinate.longitude] as [String : Any]
                
            socket.emit(socketApiKeys.SOS, with: [myJSON], completion: nil)
            print ("\(socketApiKeys.SOS) : \(myJSON)")
            
            self.dismiss(animated: true, completion: nil)
        } else {
            okAction?.setValue("Cancel \(SosTimerCount)", forKey: "title")
        }
    }
    
    
    
    func onSOS() {
        
        self.socket.on("SOS", callback: { (data, ack) in
            print ("SOS Driver Notify : \(data)")
            let msg = (data as NSArray)
            UtilityClass.showAlert("", message: (msg.object(at: 0) as! NSDictionary).object(forKey: GetResponseMessageKey()) as? String ?? "", vc: self)
        })
        
    }
    
    // ------------------------------------------------------------
    
    func onSessionError() {
        
        self.socket.on("SessionError", callback: { (data, ack) in
            
            //            UtilityClass.showAlertWithCompletion("Multiple login", message: "Please Re-Login", vc: self, completionHandler: { ACTION in
            
            self.webserviceOFSignOut()
            //            })
            
        })
        
    }
    
    func NewBookLaterRequestArrivedNotification() {
        
        self.socket.on(socketApiKeys.kBookLaterDriverNotify, callback: { (data, ack) in
            
            print ("Book Later Driver Notify : \(data)")
            
            let msg = (data as NSArray)
            
            //            UtilityClass.showAlert("Future Booking Request Arrived.", message: (msg.object(at: 0) as! NSDictionary).object(forKey: "message") as! String, vc: self)
            
            let alert = UIAlertController(title: "App Name".localized,
                                          message: (msg.object(at: 0) as! NSDictionary).object(forKey: GetResponseMessageKey()) as? String,
                                          preferredStyle: UIAlertController.Style.alert)
            
            let okAction = UIAlertAction(title: "OK".localized, style: .default, handler: { (action) in
                
                Singletons.sharedInstance.isFromNotification = true
                self.tabBarController?.selectedIndex = 1
                
                //                let myJobs = (self.navigationController?.children[0] as! TabbarController).children.last as! MyJobsViewController
                
                //                myJobs.btnFutureBookingClicked(myJobs.btnFutureBooking)
                
                let viewCount = self.parent?.children.count
                
                if viewCount == 3
                {
                    if let VC = self.parent?.children[2] as? MyJobsViewController
                    {
                        print("called it after book later offline to online on the same page")
                        if let vcFuture = VC.children[0] as? FutureBookingVC
                        {
                            vcFuture.webserviceOFFurureBooking()
                        }
                        VC.btnFutureBookingClicked(VC.btnFutureBooking)
                    }
                    else
                    {
                        print("called it after book later offline to online from home page")
                        let ViewController = self.storyboard?.instantiateViewController(withIdentifier: "MyJobsViewController") as? MyJobsViewController
                        self.navigationController?.pushViewController(ViewController!, animated: true)
                    }
                }
                else if viewCount == nil
                {
                    if UIApplication.shared.windows[0].rootViewController?.children[1].children.count == 1
                    {
                        print("called it after book later offline to online from Sidemenu")
                        //                        _ = (UIApplication.shared.windows[0].rootViewController?.children[1].children[0] as? MyJobsViewController)
                        let MyjobVC = ((UIApplication.shared.windows[0].rootViewController)?.children[1].children[0].children[0]) as? FutureBookingVC
                        MyjobVC?.webserviceOFFurureBooking()
                        //                        VC?.btnFutureBookingClicked(VC?.btnFutureBooking)
                        
                    }
                    else
                    {
                        //                        if let navController = (UIApplication.shared.windows[0].rootViewController as! SSASideMenu).children[1] as? UINavigationController
                        //                        {
                        //
                        //                            print("called it after book later offline to online undefinite")
                        //                            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MyJobsViewController") as? MyJobsViewController
                        //                            navController.pushViewController(viewController!, animated: true)
                        //                        }
                    }
                }
                else
                {
                    
                    //                    print("called it after book later offline to online undefinite also")
                    //                    if let ViewController = self.storyboard?.instantiateViewController(withIdentifier: "MyJobsViewController") as? MyJobsViewController
                    //                    {
                    //                        self.navigationController?.pushViewController(ViewController, animated: true)
                    //                    }
                    if viewCount == 2
                    {
                        if let VC = self.parent?.children[1] as? MyJobsViewController
                        {
                            print("called it after book later offline to online on the same page")
                            if let vcFuture = VC.children[2] as? FutureBookingVC
                            {
                                vcFuture.webserviceOFFurureBooking()
                            }
                            VC.btnFutureBookingClicked(VC.btnFutureBooking)
                        }
                    }
                    else
                    {
                        print("called it after book later offline to online undefinite also")
                        if let ViewController = self.storyboard?.instantiateViewController(withIdentifier: "MyJobsViewController") as? MyJobsViewController
                        {
                            self.navigationController?.pushViewController(ViewController, animated: true)
                            //                            if let vcFuture = ViewController.children[0] as? FutureBookingViewController
                            //                            {
                            //                                vcFuture.webserviceOFFurureBooking(showHud: true)
                            //                            }
                            //                            ViewController.btnFutureBookingClicked(ViewController.btnFutureBooking)
                        }
                    }
                }
            })
            
            
            let cancelAction = UIAlertAction(title: "Dismiss".localized,
                                             style: .destructive, handler: nil)
            
            alert.addAction(cancelAction)
            alert.addAction(okAction)
            if(self.presentedViewController != nil)
            {
                self.dismiss(animated: true, completion: nil)
            }
            //vc will be the view controller on which you will present your alert as you cannot use self because this method is static.
            self.present(alert, animated: true, completion: nil)
        })
    }
    
    //-------------------------------------------------------------
    // MARK: - Check time of booking
    //-------------------------------------------------------------
    
    var isFirstTimeFromPndingJobs = true
    
    
    func getTimeOfStartTrip()
    {
        self.socket.on(socketApiKeys.kStartTripTimeError, callback: { (data, ack) in
            
            print("getTimeOfStartTrip() : \(data)")
            if((((data as NSArray).object(at: 0) as! NSDictionary)).object(forKey: "status") as! Int == 1)
            {
                //                 self.btnStartTripAction()
                
                self.advanceBookingID = ((data as NSArray).object(at: 0) as! NSDictionary).object(forKey: "BookingId") as! String
                
                
                //                if (self.isFirstTimeFromPndingJobs) {
                //                    self.BottomButtonView.isHidden = false
                //                    self.StartTripView.isHidden = true
                //                }
                //                else {
                //                    self.BottomButtonView.isHidden = true
                //                    self.StartTripView.isHidden = false
                //                }
                //
                //                self.isFirstTimeFromPndingJobs.toggleForBookLaterStartFromPendinfJobs()
                //                self.btnStartTrip.isHidden = true
                
                
                
                let aryAdvancePassengerData = self.aryPassengerData //as? NSArray else {
                //
                //                    print("Error")
                //                    return
                //                }
                
                if aryAdvancePassengerData.count != 0 {
                    
                    if let indexOfData = aryAdvancePassengerData.object(at: 0) as? NSDictionary, let advenceBookingInfo = indexOfData.object(forKey: "BookingInfo") as? NSDictionary {
                        Singletons.sharedInstance.startedTripLatitude = Double(advenceBookingInfo.object(forKey: "PickupLat") as! String)!
                        Singletons.sharedInstance.startedTripLongitude = Double(advenceBookingInfo.object(forKey: "PickupLng") as! String)!
                    }
                    else if let indexOfData = aryAdvancePassengerData.object(at: 0) as? NSDictionary, let advenceBookingInfo = indexOfData.object(forKey: "BookingInfo") as? NSArray, let aryDataofPassenger = advenceBookingInfo.object(at: 0) as? NSDictionary {
                        
                        Singletons.sharedInstance.startedTripLatitude = Double(aryDataofPassenger.object(forKey: "PickupLat") as! String)!
                        Singletons.sharedInstance.startedTripLongitude = Double(aryDataofPassenger.object(forKey: "PickupLng") as! String)!
                    }
                    else {
                        return
                    }
                } else {
                    return
                }
                
                //                ((self.aryPassengerData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "BookingInfo") as? NSDictionary
                
                //                self.btnStartTripAction()
                
                self.mapView.clear()
                self.driverMarker = nil
                self.UpdateDriverLocation()
                
                Singletons.sharedInstance.isRequestAccepted = true
                Singletons.sharedInstance.isTripContinue = true
                
                UserDefaults.standard.set(Singletons.sharedInstance.isRequestAccepted, forKey: tripStatus.kisRequestAccepted)
                UserDefaults.standard.set(Singletons.sharedInstance.isTripContinue, forKey: tripStatus.kisTripContinue)
                
                //                self.BottomButtonView.isHidden = true
                //                self.StartTripView.isHidden = false
                //                self.btnStartTrip.isHidden = false
                self.viewLocationDetails.isHidden = false
                self.constrainLocationViewBottom?.priority = UILayoutPriority(rawValue: 800)
                Singletons.sharedInstance.MeterStatus = meterStatus.kIsMeterStart
                
                self.pickupPassengerFromLocation()
                
                // ontheway == 1 and status == accepted = travelling to pick passenger
                //ontheway == 1 and status == travelling = start trip
                if let onTheWay = ((((self.aryPassengerData as NSArray)[0] as? NSDictionary)?["BookingInfo"] as? NSDictionary)?["OnTheWay"] as? String), let status = ((((self.aryPassengerData as NSArray)[0] as? NSDictionary)?["BookingInfo"] as? NSDictionary)?["Status"] as? String)
                {
                    
                    if (onTheWay == "1" && status.lowercased() == "travelling")
                    {
                        self.btnStartTripAction()
                    }
                    else  if (onTheWay == "1" && status.lowercased() == "accepted")
                    {
                        if(Singletons.sharedInstance.strBookingType != "BookLater"){
                            self.stackViewOfStartTrip.isHidden = false
                        }
                    }
                }
            }
            else
            {
                //                self.btnCompleteTrip.isHidden = true
                UtilityClass.showAlert("App Name".localized, message: (((data as NSArray).object(at: 0) as! NSDictionary)).object(forKey: GetResponseMessageKey()) as! String, vc: self)
            }
        })
    }
    
    
    //-------------------------------------------------------------
    // MARK: - Get Booking Details After Booking Request Accepted
    //-------------------------------------------------------------
    func GetBookingDetailsAfterBookingRequestAccepted() {
        
        self.socket.on(socketApiKeys.kGetBookingDetailsAfterBookingRequestAccepted, callback: { (data, ack) in
            
            print("GetBookingDetailsAfterBookingRequestAccepted() : \(data)")
            
//            self.headerView?.viewSOSIcon.isHidden = false
            if let PassengerType = ((data as NSArray).object(at: 0) as! NSDictionary).object(forKey: "BookingType") as? String {
                
                Singletons.sharedInstance.passengerType = PassengerType
            }
            
            Singletons.sharedInstance.isRequestAccepted = true
            UserDefaults.standard.set(Singletons.sharedInstance.isRequestAccepted, forKey: tripStatus.kisRequestAccepted)
            
            //            DispatchQueue.main.async {
            
            //            if !(Singletons.sharedInstance.isBookNowOrBookLater) {
            self.methodAfterDidAcceptBooking(data: data as NSArray)
            
            //            }
            
            UtilityClass.hideACProgressHUD()
            
            //            }
        })
    }
    
    func zoomoutCamera(PickupLat: CLLocationDegrees, PickupLng: CLLocationDegrees, DropOffLat : String, DropOffLon: String)
    {
        let bounds = GMSCoordinateBounds(coordinate: CLLocationCoordinate2D(latitude: Double(PickupLat), longitude: Double(PickupLng)), coordinate: CLLocationCoordinate2D(latitude: (Double(DropOffLat) ?? Double(0)), longitude: (Double(DropOffLon) ?? Double(0))))
        let update = GMSCameraUpdate.fit(bounds, withPadding: CGFloat(40))
        self.mapView.animate(with: update)
        self.mapView.moveCamera(update)
    }
    
    func methodAfterDidAcceptBooking(data : NSArray) {
        
        let getBookingAndPassengerInfo = self.getBookingAndPassengerInfo(data: data)
        
        //        DispatchQueue.main.async {
        
        //            DispatchQueue.main.asyncAfter(deadline: .now()) { // change 2 to desired number of seconds
        self.showEstimatedView()
        self.BottomButtonView.isHidden = false
        
        self.btnStartTrip.isHidden = false
        self.btnStartTrip.layoutIfNeeded()
        self.BottomButtonView.layoutIfNeeded()
        self.viewHomeMyJobsBTN.isHidden = true
        
        self.stackViewOfCompleteTrip.isHidden = true
        self.stackViewOfStartTrip.isHidden = false
        self.stackViewOfCancelTrip.isHidden = false
        self.stackViewOfWaitingTime.isHidden = true
        //                self.viewLocationDetails.isHidden = true
        self.constrainLocationViewBottom?.priority = UILayoutPriority(rawValue: 800)

        let BookingInfo = getBookingAndPassengerInfo.0
        let PassengerInfo = getBookingAndPassengerInfo.1
        
        if let isArrived = BookingInfo.object(forKey: "IsArrived") as? String {
            if(isArrived == "0" || isArrived == "")
            {
                self.btnStartTrip.setTitle("Driver Outside".localized, for: .normal)
            }
            else
            {
                self.btnStartTrip.setTitle("Start Trip".localized, for: .normal)
            }
        }
        
        if let paymentType = BookingInfo.object(forKey: "PaymentType") as? String {
            Singletons.sharedInstance.passengerPaymentType = paymentType
        }
        
        if let passengerType = BookingInfo.object(forKey: "PassengerType") as? String {
            Singletons.sharedInstance.passengerType = passengerType
        }
        if let pasengerFlightNumber = BookingInfo.object(forKey: "FlightNumber") as? String {
            Singletons.sharedInstance.pasengerFlightNumber = pasengerFlightNumber
        }
        if let passengerNote = BookingInfo.object(forKey: "Notes") as? String {
            Singletons.sharedInstance.passengerNote = passengerNote
        }
        
        
        let strBookingAry = data
        if let strBookingFirstDict = strBookingAry.firstObject as? NSDictionary {
            if let strBookingType = strBookingFirstDict.object(forKey: "BookingType") as? String {
                Singletons.sharedInstance.strBookingType = strBookingType
            }
            else {
                Singletons.sharedInstance.strBookingType = "BookLater"
            }
        }
        //        else {
        //            Singletons.sharedInstance.strBookingType = "BookLater"
        //        }
        
        
        if(Singletons.sharedInstance.strBookingType == "BookLater")
        {
            let strID = BookingInfo.object(forKey: "Id") as AnyObject
            self.advanceBookingID = String(describing: strID)
        }else{
            let strID = BookingInfo.object(forKey: "Id") as AnyObject
            self.bookingID = String(describing: strID)
        }
        
        let DropOffLat = BookingInfo.object(forKey: "PickupLat") as! String
        let DropOffLon = BookingInfo.object(forKey: "PickupLng") as! String
        
        //        self.lblLocationOnMap.text = BookingInfo.object(forKey: "PickupLocation") as? String
        self.strPickupLocation = BookingInfo.object(forKey: "PickupLocation") as! String
        self.strDropoffLocation = BookingInfo.object(forKey: "DropoffLocation") as! String
        self.strPassengerName = PassengerInfo.object(forKey: "Fullname") as! String
        //        var imgURL = String()
        
        self.strPassengerMobileNo = PassengerInfo.object(forKey: "MobileNo") as! String
        //        imgURL = PassengerInfo.object(forKey: "Image") as! String
        
        let PickupLat = self.defaultLocation.coordinate.latitude
        let PickupLng = self.defaultLocation.coordinate.longitude
        
        let dummyLatitude = Double(PickupLat) - Double(DropOffLat)!
        let dummyLongitude = Double(PickupLng) - Double(DropOffLon)!
        
        let waypointLatitude = self.defaultLocation.coordinate.latitude - dummyLatitude
        let waypointSetLongitude = self.defaultLocation.coordinate.longitude - dummyLongitude
        
        let originalLoc: String = "\(PickupLat),\(PickupLng)"
        let destiantionLoc: String = "\(DropOffLat),\(DropOffLon)"
        
        zoomoutCamera(PickupLat: PickupLat, PickupLng: PickupLng, DropOffLat: DropOffLat, DropOffLon: DropOffLon)
        
        Singletons.sharedInstance.bookingId = self.bookingID
        self.getDirectionsSeconMethod(origin: originalLoc, destination: destiantionLoc, waypoints: ["\(waypointLatitude),\(waypointSetLongitude)"], travelMode: nil, completionHandler: nil)
        
        //        let next = self.storyboard?.instantiateViewController(withIdentifier: "PassengerInfoViewController") as! PassengerInfoViewController
        //        next.strPickupLocation = self.strPickupLocation
        //        next.strDropoffLocation = self.strDropoffLocation
        //        next.imgURL = imgURL
        //        if((PassengerInfo.object(forKey: "FlightNumber")) != nil)
        //        {
        //            next.strFlightNumber = PassengerInfo.object(forKey: "FlightNumber") as! String
        //        }
        //        if((PassengerInfo.object(forKey: "Notes")) != nil)
        //        {
        //            next.strNotes = PassengerInfo.object(forKey: "Notes") as! String
        //        }
        //        next.strPassengerName =  self.strPassengerName
        //        next.strPassengerMobileNumber =  self.strPassengerMobileNo
        //                (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.present(next, animated: true, completion: nil)
        //        self.present(next, animated: true, completion: nil)
        
    }
    
    
    func getBookingAndPassengerInfo(data : NSArray) -> (NSMutableDictionary,NSMutableDictionary)
    {
        self.aryBookingData = data as NSArray
        Singletons.sharedInstance.aryPassengerInfo = data as NSArray
        
//        UserDefaults.standard.set(data, forKey: "BookNowInformation")
//        UserDefaults.standard.synchronize()
        
        self.aryPassengerData = NSArray(array: data)
        //
        var BookingInfo = NSMutableDictionary()
        var PassengerInfo = NSMutableDictionary()
        
        if Singletons.sharedInstance.latitude != nil
        {
            oldCoordinate = CLLocationCoordinate2DMake(Singletons.sharedInstance.latitude ,Singletons.sharedInstance.longitude)
            
            if((((self.aryPassengerData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "BookingInfo") as? NSDictionary) == nil)
            {
                // print ("Yes its  array ")
                BookingInfo = NSMutableDictionary(dictionary: (((self.aryPassengerData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "BookingInfo") as! NSArray).object(at: 0) as! NSDictionary)
                
                let PassengerType = BookingInfo.object(forKey: "PassengerType") as? String
                
                if PassengerType == "" || PassengerType == nil{
                    Singletons.sharedInstance.passengerType = ""
                }
                else
                {
                    Singletons.sharedInstance.passengerType = PassengerType!
                }
                
                
                if Singletons.sharedInstance.passengerType == "other" || Singletons.sharedInstance.passengerType == "others" {
                    
                    let Fullname = BookingInfo.object(forKey: "PassengerName")
                    let FlightNumber = BookingInfo.object(forKey: "FlightNumber")
                    let PaymentType = BookingInfo.object(forKey: "PaymentType")
                    let Notes = BookingInfo.object(forKey: "Notes")
                    
                    var MobileNo = String()
                    if let mobileNumber = BookingInfo.object(forKey: "MobileNo") as? String {
                        
                        if mobileNumber == "" {
                            
                            if let contacoNo = BookingInfo.object(forKey: "PassengerContact") as? String {
                                MobileNo = contacoNo
                            }
                            else {
                                MobileNo = ""
                            }
                        }
                        else {
                            MobileNo = mobileNumber
                        }
                    }
                    
                    var dictPassengerInfo = [String:AnyObject]()
                    dictPassengerInfo["Fullname"] = Fullname as AnyObject
                    dictPassengerInfo["MobileNo"] = MobileNo as AnyObject
                    dictPassengerInfo["PassengerType"] = PassengerType as AnyObject
                    dictPassengerInfo["FlightNumber"] = FlightNumber as AnyObject
                    dictPassengerInfo["PaymentType"] = PaymentType as AnyObject
                    dictPassengerInfo["Notes"] = Notes as AnyObject
                    
                    PassengerInfo = NSMutableDictionary(dictionary: dictPassengerInfo)
                    
                }
                else {
                    PassengerInfo = NSMutableDictionary(dictionary: (((self.aryPassengerData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "PassengerInfo") as! NSArray).object(at: 0) as! NSDictionary)
                    PassengerInfo.setObject(BookingInfo.object(forKey: "Notes") ?? "", forKey: "Notes" as NSCopying)
                }
                
                
                // ----------------------------------------------------------------------
            }
            else
            {
                // print ("Yes its dictionary")
                BookingInfo = NSMutableDictionary(dictionary: (((self.aryPassengerData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "BookingInfo") as! NSDictionary))  //.object(at: 0) as! NSDictionary
                
                
                let PassengerType = self.dictCurrentBookingInfoData.object(forKey: "PassengerType") as? String
                
                if PassengerType == "" || PassengerType == nil{
                    Singletons.sharedInstance.passengerType = ""
                }
                else {
                    Singletons.sharedInstance.passengerType = PassengerType!
                }
                
                
                if Singletons.sharedInstance.passengerType == "other" || Singletons.sharedInstance.passengerType == "others" {
                    
                    let Fullname = BookingInfo.object(forKey: "PassengerName")
                    
                    let FlightNumber = BookingInfo.object(forKey: "FlightNumber")
                    let PaymentType = BookingInfo.object(forKey: "PaymentType")
                    let Notes = BookingInfo.object(forKey: "Notes")
                    
                    var MobileNo = String()
                    if let mobileNumber = BookingInfo.object(forKey: "MobileNo") as? String {
                        
                        if mobileNumber == "" {
                            
                            if let contacoNo = BookingInfo.object(forKey: "PassengerContact") as? String {
                                MobileNo = contacoNo
                            }
                            else {
                                MobileNo = ""
                            }
                        }
                        else {
                            MobileNo = mobileNumber
                        }
                    }
                    
                    var dictPassengerInfo = [String:AnyObject]()
                    dictPassengerInfo["Fullname"] = Fullname as AnyObject
                    dictPassengerInfo["MobileNo"] = MobileNo as AnyObject
                    dictPassengerInfo["PassengerType"] = PassengerType as AnyObject
                    dictPassengerInfo["FlightNumber"] = FlightNumber as AnyObject
                    dictPassengerInfo["PaymentType"] = PaymentType as AnyObject
                    dictPassengerInfo["Notes"] = Notes as AnyObject
                    
                    PassengerInfo = NSMutableDictionary(dictionary: dictPassengerInfo)
                    
                }
                else {
                    PassengerInfo = NSMutableDictionary(dictionary: ((self.aryPassengerData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "PassengerInfo")  as! NSDictionary)
                    PassengerInfo.setObject(BookingInfo.object(forKey: "Notes") ?? "", forKey: "Notes" as NSCopying)
                }
                
            }
            return (BookingInfo,PassengerInfo)
        }
        else
        {
            //            webserviceOfCurrentBooking()
            //            self.getBookingAndPassengerInfo(data: data)
            return (BookingInfo,PassengerInfo)
        }
    }
    
    func PickupPassengerByDriverInBookLaterRequest() {
        
        let myJSON = [socketApiKeys.kBookingId : advanceBookingID,  profileKeys.kDriverId : driverID] as [String : Any]
        socket.emit(socketApiKeys.kAdvancedBookingPickupPassenger, with: [myJSON], completion: nil)
    }
    
    func AdvancedStartHoldTrip() {
        let myJSON = [socketApiKeys.kBookingId : advanceBookingID, socketApiKeys.kBookingType : "BookLater"] as [String : Any]
        socket.emit(socketApiKeys.kAdvancedBookingStartHoldTrip, with: [myJSON], completion: nil)
    }
    
    func AdvancedEndHoldTrip() {
        let myJSON = [socketApiKeys.kBookingId : advanceBookingID, socketApiKeys.kBookingType : "BookLater"] as [String : Any]
        socket.emit(socketApiKeys.kAdvancedBookingEndHoldTrip, with: [myJSON], completion: nil)
    }
    
    
    func StartHoldTrip() {
        let myJSON = [socketApiKeys.kBookingId : bookingID, socketApiKeys.kBookingType : "BookNow"] as [String : Any]
        socket.emit(socketApiKeys.kStartHoldTrip, with: [myJSON], completion: nil)
    }
    
    func EndHoldTrip() {
        let myJSON = [socketApiKeys.kBookingId : bookingID, socketApiKeys.kBookingType : "BookNow"] as [String : Any]
        socket.emit(socketApiKeys.kEndHoldTrip, with: [myJSON], completion: nil)
    }
    
    func CompletedBookLaterTrip() {
        
        let BookingInfo : NSDictionary!
        if((((self.aryPassengerData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "BookingInfo") as? NSDictionary) == nil)
        {
            BookingInfo = (((self.aryPassengerData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "BookingInfo") as! NSArray).object(at: 0) as? NSDictionary
        }
        else
        {
            BookingInfo = (((self.aryPassengerData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "BookingInfo") as! NSDictionary) //.object(at: 0) as! NSDictionary
        }
        
        let strPassengerID = BookingInfo.object(forKey: "PassengerId") as! String
        
        if (Singletons.sharedInstance.advanceBookingIdTemp != "") {
            advanceBookingID = Singletons.sharedInstance.advanceBookingId
        }
        
        let myJSON = ["PassengerId" : strPassengerID, socketApiKeys.kBookingId : advanceBookingID,  profileKeys.kDriverId : driverID] as [String : Any]
        socket.emit(socketApiKeys.kAdvancedBookingCompleteTrip, with: [myJSON], completion: nil)
    }
    
    func GetAdvanceBookingDetailsAfterBookingRequestAccepted() {
        
        self.socket.on(socketApiKeys.kAdvancedBookingInfo, callback: { (data, ack) in
            print ("GetAdvanceBookingDetails is :  \(data)")
            
            Singletons.sharedInstance.isRequestAccepted = true
            UserDefaults.standard.set(Singletons.sharedInstance.isRequestAccepted, forKey: tripStatus.kisRequestAccepted)
            
            DispatchQueue.main.async {
//                self.headerView?.viewSOSIcon.isHidden = false
                // print ("GetAdvanceBookingDetailsAfterBookingRequestAccepted()")
                
                //                if !(Singletons.sharedInstance.isBookNowOrBookLater) {
                //                    self.methodAfterDidAcceptBookingLaterRequest(data: data as NSArray)
                self.isAdvanceBooking = true
                self.methodAfterDidAcceptBooking(data: data as NSArray)
                //                }
                
                UtilityClass.hideACProgressHUD()
                
            }
            
        })
        
    }
    
    func getNotificationForReceiveMoneyNotify() {
        
        self.socket.on(socketApiKeys.kReceiveMoneyNotify, callback: { (data, ack) in
            
            print("ReceiveMoneyNotify: \(data)")
//            self.headerView?.viewSOSIcon.isHidden = true
            UtilityClass.showAlert("App Name".localized, message: ((data as NSArray).object(at: 0) as! NSDictionary).object(forKey: GetResponseMessageKey()) as! String, vc: self)
            
        })
    }
    
    func onAdvancedBookingPickupPassengerNotification() {
        
        self.socket.on(socketApiKeys.kAdvancedBookingPickupPassengerNotification, callback: { (data, ack) in
            print(#function,": \(data)")
        })
        
    }
    
    func btndeleagateGoToChat() {

        let getBookingAndPassengerInfo = self.getBookingAndPassengerInfo(data: self.aryPassengerData)
        let BookingInfo = getBookingAndPassengerInfo.0
        let PassengerInfo = getBookingAndPassengerInfo.1
        
        let strBookingID = BookingInfo.object(forKey: "Id") as AnyObject
        let setDriverId = PassengerInfo.object(forKey: "Id") as AnyObject
        let DriverName = PassengerInfo.object(forKey: "Fullname") as? String ?? ""
      
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
        viewController.receiverName = DriverName
        viewController.bookingId = "\(strBookingID)"
        viewController.receiverId = "\(setDriverId)"
        self.navigationController?.pushViewController(viewController, animated: true)
        
//        let next = self.storyboard?.instantiateViewController(withIdentifier: "WalletTopUpVC") as! WalletTopUpVC
//        self.navigationController?.pushViewController(next, animated: true)
    }
    
    @objc func goChatWithDispatcher() {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
        viewController.receiverName = Singletons.sharedInstance.DispatchName
        viewController.bookingId = ""
        viewController.isDispacherChat = true
        viewController.receiverId = Singletons.sharedInstance.DispatchId
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func methodAfterDidAcceptBookingLaterRequest(data: NSArray)
    {
        
        // print ("methodAfterDidAcceptBookingLaterRequest")
        self.aryPassengerData = NSArray(array: data)
        
        self.showEstimatedView()
        self.BottomButtonView.isHidden = false
        self.btnStartTrip.isHidden = false
        self.aryBookingData = data as NSArray
        Singletons.sharedInstance.aryPassengerInfo = data as NSArray
        self.viewHomeMyJobsBTN.isHidden = true
        //                self.viewLocationDetails.isHidden = true
        self.constrainLocationViewBottom?.priority = UILayoutPriority(rawValue: 800)
        self.isAdvanceBooking = true
        
        let getBookingAndPassengerInfo = self.getBookingAndPassengerInfo(data: data)
        
        let BookingInfo = getBookingAndPassengerInfo.0
        let PassengerInfo = getBookingAndPassengerInfo.1
        
        if let paymentType = BookingInfo.object(forKey: "PaymentType") as? String {
            Singletons.sharedInstance.passengerPaymentType = paymentType
        }
        
        let strBookingAry = data //as? NSArray {
        if let strBookingFirstDict = strBookingAry.firstObject as? NSDictionary {
            if let strBookingType = strBookingFirstDict.object(forKey: "BookingType") as? String {
                Singletons.sharedInstance.strBookingType = strBookingType
            }
            else {
                Singletons.sharedInstance.strBookingType = "BookLater"
            }
        }
        else {
            Singletons.sharedInstance.strBookingType = "BookLater"
        }
        //        }
        //        else {
        //            Singletons.sharedInstance.strBookingType = "BookLater"
        //        }
        
        //        if let bookingType = BookingInfo.object(forKey: "BookingType") {
        //            Singletons.sharedInstance.strBookingType = bookingType as! String
        //        }
        
        if let passengerType = BookingInfo.object(forKey: "PassengerType") as? String {
            Singletons.sharedInstance.passengerType = passengerType
        }
        if let strDropoffLocation2 = BookingInfo.object(forKey: "DropoffLocation2") as? String {
            self.strDropoffLocation2 = strDropoffLocation2
        }
        if let pasengerFlightNumber = BookingInfo.object(forKey: "FlightNumber") as? String {
            Singletons.sharedInstance.pasengerFlightNumber = pasengerFlightNumber
        }
        if let passengerNote = BookingInfo.object(forKey: "Notes") as? String {
            Singletons.sharedInstance.passengerNote = passengerNote
        }
        
        
        let DropOffLat = BookingInfo.object(forKey: "PickupLat") as! String
        let DropOffLon = BookingInfo.object(forKey: "PickupLng") as! String
        let strID = BookingInfo.object(forKey: "Id") as AnyObject
        
        self.advanceBookingID = String(describing: strID)
        
        //        self.lblLocationOnMap.text = BookingInfo.object(forKey: "PickupLocation") as? String
        self.strPickupLocation = BookingInfo.object(forKey: "PickupLocation") as! String
        self.strDropoffLocation = BookingInfo.object(forKey: "DropoffLocation") as! String
        
        self.mapView.clear()
        
        self.strPassengerName = PassengerInfo.object(forKey: "Fullname") as! String
        self.strPassengerMobileNo = PassengerInfo.object(forKey: "MobileNo") as! String
        //         imgURL = PassengerInfo.object(forKey: "Image") as! String
        let PickupLat = self.defaultLocation.coordinate.latitude
        let PickupLng = self.defaultLocation.coordinate.longitude
        
        let dummyLatitude = Double(PickupLat) - Double(DropOffLat)!
        let dummyLongitude = Double(PickupLng) - Double(DropOffLon)!
        
        let waypointLatitude = self.defaultLocation.coordinate.latitude - dummyLatitude
        let waypointSetLongitude = self.defaultLocation.coordinate.longitude - dummyLongitude
        
        let originalLoc: String = "\(PickupLat),\(PickupLng)"
        let destiantionLoc: String = "\(DropOffLat),\(DropOffLon)"
        
        zoomoutCamera(PickupLat: PickupLat, PickupLng: PickupLng, DropOffLat: DropOffLat, DropOffLon: DropOffLon)
        self.getDirectionsSeconMethod(origin: originalLoc, destination: destiantionLoc, waypoints: ["\(waypointLatitude),\(waypointSetLongitude)"], travelMode: nil, completionHandler: nil)
        
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
        
        let next = self.storyboard?.instantiateViewController(withIdentifier: "PassengerInfoViewController") as! PassengerInfoViewController
        next.homeVC = self
        next.strPickupLocation = self.strPickupLocation
        next.strDropoffLocation = self.strDropoffLocation
        next.strDropoffLocation2 = self.strDropoffLocation2
        if((PassengerInfo.object(forKey: "FlightNumber")) != nil)
        {
            next.strFlightNumber = PassengerInfo.object(forKey: "FlightNumber") as! String
        }
        if((PassengerInfo.object(forKey: "Notes")) != nil)
        {
            next.strNotes = PassengerInfo.object(forKey: "Notes") as! String
        }
        next.strPassengerName =  self.strPassengerName
        next.strPassengerMobileNumber =  self.strPassengerMobileNo
        next.isDiscountApplied = (BookingInfo.object(forKey: "PromoCode") as? String ?? "" != "") ? true : false
        
        //        (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.present(next, animated: true, completion: nil)
        //        self.present(next, animated: true, completion: nil)
        
    }
    
    //-------------------------------------------------------------
    // MARK: - Accept and Reject Request
    //-------------------------------------------------------------
    
    
    func didAcceptedRequest() {
        
        manager.startUpdatingLocation()
        if self.driverID != "" && self.defaultLocation.coordinate.latitude != 0 && self.defaultLocation.coordinate.longitude != 0 {
            self.UpdateDriverLocation()
        }
        
        Singletons.sharedInstance.isPending = 0
        UpdateDriverLocation()
        UtilityClass.showACProgressHUD()
        self.stopSound()
        Singletons.sharedInstance.isPickUPPasenger = false
        
        if(toursBookingId != ""){
            if(toursBookingType == "Rental Book Later") {
                self.toursBookingType = ""
                self.toursBookingId = ""
                UtilityClass.hideACProgressHUD()
                print("Rental Book Later...")
            } else {
                self.TourBookingAcceped()
            }
        } else if isAdvanceBooking {
            self.AcceptBookLaterBookingRequest()
        } else {
            BookingAcceped()
        }

    }
    
    func didRejectedRequest(RejectByDriver: Bool = true) {
        
        self.stopSound()
        
        if self.toursBookingId != "" {
            TourBookingRejected(isRejectByDriver: RejectByDriver)
        } else if isAdvanceBooking {
            self.RejectBookLaterBookingRequest(isRejectByDriver: RejectByDriver)
        } else {
            BookingRejected(isRejectByDriver: RejectByDriver)
        }
    }
    
    //-------------------------------------------------------------
    // MARK: - Accept Book Later Request
    //-------------------------------------------------------------
    
    func AcceptBookLaterBookingRequest() {
        
        //        self.resetMapView()
        //        self.mapView.selectedMarker = nil
        
        if Singletons.sharedInstance.advanceBookingIdTemp != "" {
            Singletons.sharedInstance.isPending = 1
        }
        else if Singletons.sharedInstance.bookingId != "" {
            Singletons.sharedInstance.isPending = 1
        }
        else if bookingID != "" {
            Singletons.sharedInstance.isPending = 1
        }
        
        if (Singletons.sharedInstance.oldBookingType.isBookNow) {
            Singletons.sharedInstance.oldBookingType.isBookLater = false
        }
        else {
            Singletons.sharedInstance.oldBookingType.isBookLater = true
        }
        
        UtilityClass.hideACProgressHUD()
        
        let myJSON = [socketApiKeys.kBookingId : advanceBookingID,  profileKeys.kDriverId : driverID, "Lat" : defaultLocation.coordinate.latitude,"Long" : defaultLocation.coordinate.longitude, "Pending": Singletons.sharedInstance.isPending] as [String : Any]
        socket.emit(socketApiKeys.kAcceptAdvancedBookingRequest, with: [myJSON], completion: nil)
        
        //New Code
        let myJSON1 = ["DriverId" : Singletons.sharedInstance.strDriverID, socketApiKeys.kBookingId : advanceBookingID] as [String : Any]
        socket.emit("NotifyPassengerForAdvancedTrip", with: [myJSON1], completion: nil)
        Singletons.sharedInstance.strBookingType = "BookLater"
        //New Code Comp
        
        GetAdvanceBookingDetailsAfterBookingRequestAccepted()
        Singletons.sharedInstance.strBookingType = "BookLater"
        
        playSound(strName: "RequestConfirm")
        
        if !(Singletons.sharedInstance.isBookNowOrBookLater){
            self.resetMapView()
        }
    }
    
    func getSocketCallforGetingTip(_ driverID : String , _ bookingID : String )
    {
        let myJSON = [profileKeys.kDriverId : driverID, socketApiKeys.kBookingId : bookingID ] as [String : Any]
        self.socket.emit(socketApiKeys.kAskForTips, with: [myJSON], completion: nil)
        print ("kAskForTips : \(myJSON)")
    }
    
    func getSocketCallforGetingTipForBooklater(_ driverID : String , _ bookingID : String )
    {
        let myJSON = [profileKeys.kDriverId : driverID, socketApiKeys.kBookingId : bookingID ] as [String : Any]
        self.socket.emit(socketApiKeys.kAskForTipsForBookLater, with: [myJSON], completion: nil)
        print ("kAskForTipsForBookLater : \(myJSON)")
    }
    
    func getNotificationforReceiveTipForBookLater()
    {
        
        self.socket.on(socketApiKeys.kReceiveTipsToDriverForBookLater, callback: { (data, ack) in
            
            print ("kReceiveTipsToDriverForBookLater : \(data)")
            if let VC = self.gettopMostViewController() as? WaitForTipViewController
            {
                VC.dismiss(animated: true, completion: nil)
            }
            
            let msg = (data as NSArray)
            
            let alert = UIAlertController(title: "App Name".localized,
                                          message: (msg.object(at: 0) as! NSDictionary).object(forKey: GetResponseMessageKey()) as? String,
                                          preferredStyle: UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: "OK".localized, style: .default, handler: { (action) in
                //                Utilities.showActivityIndicator()
                
                //                if SingletonClass.sharedInstance.passengerPaymentType == "cash" || SingletonClass.sharedInstance.passengerPaymentType == "Cash"
                //                {
                //
                //                self.completeTripFinalSubmit()
                self.getLastAddressForLatLng(DropOffAddress: (self.lastLocation != nil) ? self.lastLocation : self.defaultLocation)
                Appdelegate.WaitingTimeCount = 0
                Appdelegate.WaitingTime = "00:00:00"
                //                }
                //                else
                //                {
                //                    //                self.completeTripButtonAction()
                //                    self.completeTripFinalSubmit()
                //                    Appdelegate.WaitingTimeCount = 0
                //                    Appdelegate.WaitingTime = "00:00:00"
                //                }
                //                self.dismiss(animated: true, completion: nil)
            })
            alert.addAction(okAction)
            //            Utilities.presentPopupOverScreen(alert)
            //            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion:
            //            )
            
            
            let alertWindow = UIWindow(frame: UIScreen.main.bounds)
            alertWindow.rootViewController = UIViewController()
            alertWindow.windowLevel = UIWindow.Level.alert + 1;
            alertWindow.makeKeyAndVisible()
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                alertWindow.rootViewController?.present(alert, animated: true, completion: {
                    
                    //                    self.completeTripFinalSubmit()
                    //                    Appdelegate.WaitingTimeCount = 0
                    //                    Appdelegate.WaitingTime = "00:00:00"
                    
                    
                })
            }
            //
            //            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: {
            //
            //            })
            
        })
    }
    
    func gettopMostViewController() -> UIViewController?
    {
        
        return Utilities.findtopViewController()
        
    }
    
    func findtopViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController?
    {
        
        if let navigationController = controller as? UINavigationController {
            
            return findtopViewController(controller: navigationController.visibleViewController)
            
        }
        
        if let tabController = controller as? UITabBarController {
            
            if let selected = tabController.selectedViewController {
                
                return findtopViewController(controller: selected)
                
            }
            
        }
        
        if let presented = controller?.presentedViewController {
            return findtopViewController(controller: presented)
        }
        
        return controller
        
    }
    func getNotificationforReceiveTip()
    {

        self.socket.on(socketApiKeys.kReceiveTipsToDriver, callback: { (data, ack) in
            
            print ("kReceiveTipsToDriver : \(data)")
            
            if let VC = self.gettopMostViewController() as? WaitForTipViewController
            {
                VC.dismiss(animated: true, completion: nil)
            }
            
            let msg = (data as NSArray)
            
            let alert = UIAlertController(title: "App Name".localized,
                                          message: (msg.object(at: 0) as! NSDictionary).object(forKey: GetResponseMessageKey()) as? String,
                                          preferredStyle: UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: "OK".localized, style: .default, handler: { (action) in
                UtilityClass.showACProgressHUD()
                
                //                if SingletonClass.sharedInstance.passengerPaymentType == "cash" || SingletonClass.sharedInstance.passengerPaymentType == "Cash"
                //                {
                //
                //                self.completeTripFinalSubmit()
                self.getLastAddressForLatLng(DropOffAddress: (self.lastLocation != nil) ? self.lastLocation : self.defaultLocation)
                Appdelegate.WaitingTimeCount = 0
                Appdelegate.WaitingTime = "00:00:00"
                //                }
                //                else
                //                {
                //                    //                self.completeTripButtonAction()
                //                    self.completeTripFinalSubmit()
                //                    Appdelegate.WaitingTimeCount = 0
                //                    Appdelegate.WaitingTime = "00:00:00"
                //                }
                //                self.dismiss(animated: true, completion: nil)
            })
            alert.addAction(okAction)
            //            Utilities.presentPopupOverScreen(alert)
            
            //            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: {
            //                self.completeTripFinalSubmit()
            //                Appdelegate.WaitingTimeCount = 0
            //                Appdelegate.WaitingTime = "00:00:00"
            //            })
            
            let alertWindow = UIWindow(frame: UIScreen.main.bounds)
            alertWindow.rootViewController = UIViewController()
            alertWindow.windowLevel = UIWindow.Level.alert + 1;
            alertWindow.makeKeyAndVisible()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                alertWindow.rootViewController?.present(alert, animated: true, completion: {
                    //                    self.completeTripFinalSubmit()
                    //                    Appdelegate.WaitingTimeCount = 0
                    //                    Appdelegate.WaitingTime = "00:00:00"
                })
            }
            
        })
    }
    // ------------------------------------------------------------
    //-------------------------------------------------------------
    // MARK: - Receive Book Later Request
    //-------------------------------------------------------------
    func ReceiveBookLaterBookingRequest() {
        
        self.socket.on(socketApiKeys.kAriveAdvancedBookingRequest, callback: { (data, ack) in
            print ("ReceiveBookLater is \(data)")
            
            self.advanceBookingID = ((data as NSArray).object(at: 0) as! NSDictionary).object(forKey: "BookingId") as! String
            
            if(self.aryPassengerData.count != 0 || Singletons.sharedInstance.bookingId != "")
            {
                let myJSON = [socketApiKeys.kBookingId : self.advanceBookingID,  profileKeys.kDriverId : self.driverID] as [String : Any]
                self.socket.emit(socketApiKeys.kForwardAdvancedBookingRequestToAnother, with: [myJSON], completion: nil)
                return
            }
            
            self.isAdvanceBooking = true
            self.isNowBooking = false
            self.playSound(strName: "\(RingToneSound)")
            
            Singletons.sharedInstance.isPending = 1
            
            if Singletons.sharedInstance.advanceBookingId == "" {
                Singletons.sharedInstance.advanceBookingId = self.advanceBookingID
                
                if Singletons.sharedInstance.bookingId == "" {
                    Singletons.sharedInstance.isPending = 0
                }
            }
            else {
                Singletons.sharedInstance.advanceBookingIdTemp = self.advanceBookingID
            }
            
            if Singletons.sharedInstance.bookingId == "" {
                Singletons.sharedInstance.bookingId = self.advanceBookingID
                Singletons.sharedInstance.isPending = 0
            }
            else {
                Singletons.sharedInstance.bookingIdTemp = self.advanceBookingID
            }
            let next = self.storyboard?.instantiateViewController(withIdentifier: "ReceiveRequestViewController") as! ReceiveRequestViewController
            next.delegate = self
            
            if let grandTotal = ((data as NSArray).object(at: 0) as! NSDictionary).object(forKey: "GrandTotal") as? String {
                if grandTotal == "" {
                    next.strGrandTotal = "0"
                }
                else {
                    next.strGrandTotal = grandTotal
                }
            }
            else {
                next.strGrandTotal = "0"
            }
            if let PickupLocation = ((data as NSArray).object(at: 0) as! NSDictionary).object(forKey: "PickupLocation") as? String {
                next.strPickupLocation = PickupLocation
            }
            
            if let DropoffLocation = ((data as NSArray).object(at: 0) as! NSDictionary).object(forKey: "DropoffLocation") as? String {
                next.strDropoffLocation = DropoffLocation
            }
            
            if let bookingType = ((data as NSArray).object(at: 0) as! NSDictionary).object(forKey: "BookingType") as? String {
                next.strBookingType = bookingType
            }
            
            (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.present(next, animated: true, completion: nil)
            
            //            self.performSegue(withIdentifier: "segueReceiveRequest", sender: nil)
        })
    }
    
    //
    //-------------------------------------------------------------
    // MARK: - Update Drop Location
    //-------------------------------------------------------------
    
    
    func onUpdateDropoffLocation() {
        
        self.socket.on(socketApiKeys.kUpdateDropoffLocation) { (data, ack) in
            print(#function,": \(data)")
            
            if let aryData = data as? [[String:Any]] {
                if aryData.count != 0 {
                    if let dictData = aryData.first {
                        Singletons.sharedInstance.bookingId = "\(dictData["BookingId"]!)"
                        
                        let messages = "\(dictData["message"]!)"
                        let newAddress = "\(dictData["newAddress"]!)"
                        let finalMsg = "\(messages) \n \n New Address : \(newAddress)"
                        let alert = UIAlertController(title: appName.kAPPName, message: finalMsg, preferredStyle: .alert)
                        let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                            self.webserviceOfRunningTripTrack()
                        }
                        
                        alert.addAction(ok)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    //
    //-------------------------------------------------------------
    // MARK: - Accept Booking Request
    //-------------------------------------------------------------
    
    func BookingAcceped() {
        
        if Singletons.sharedInstance.bookingIdTemp != "" {
            Singletons.sharedInstance.isPending = 1
        }
        else if Singletons.sharedInstance.advanceBookingId != "" {
            Singletons.sharedInstance.isPending = 1
        }
        else if advanceBookingID != "" {
            Singletons.sharedInstance.isPending = 1
        }
        //        else if Singletons.sharedInstance.bookingId != "" {
        //            Singletons.sharedInstance.isPending = 1
        //        }
        
        
        if (Singletons.sharedInstance.oldBookingType.isBookLater)
        {
            Singletons.sharedInstance.oldBookingType.isBookNow = false
        }
        else
        {
            Singletons.sharedInstance.oldBookingType.isBookNow = true
        }
        
        
        if bookingID == "" || driverID == "" {
            UtilityClass.showAlert("App Name".localized, message: "Booking ID or Driver ID", vc: self)
        }
        else
        {
            let myJSON = [socketApiKeys.kBookingId : bookingID,  profileKeys.kDriverId : driverID, "Lat" : defaultLocation.coordinate.latitude,"Long": defaultLocation.coordinate.longitude, "Pending": Singletons.sharedInstance.isPending] as [String : Any]
            socket.emit(socketApiKeys.kAcceptBookingRequest, with: [myJSON], completion: nil)
            print("AcceptBookingRequest :  \(myJSON)")
            //            UtilityClass.hideACProgressHUD()
            //            GetBookingDetailsAfterBookingRequestAccepted()
            
            //            if !(Singletons.sharedInstance.isBookNowOrBookLater) {
            //
            //                self.resetMapView()
            //            }
        }
    }
    
    func TourBookingAcceped() {
        Singletons.sharedInstance.isPending = 1
        
        let myJSON = [socketApiKeys.kBookingId : toursBookingId,  profileKeys.kDriverId : driverID, "Lat" : defaultLocation.coordinate.latitude,"Long": defaultLocation.coordinate.longitude, "Pending": Singletons.sharedInstance.isPending] as [String : Any]
        socket.emit(socketApiKeys.AcceptRentalBooking, with: [myJSON], completion: nil)
        print("AcceptRentalBooking :  \(myJSON)")
    }

    
    //
    //-------------------------------------------------------------
    // MARK: - Reject Booking Request
    //-------------------------------------------------------------
    func TourBookingRejected(isRejectByDriver: Bool = false, isTripOnGoing : Bool = false, bookingID : String = "") {
        if(isTripOnGoing){
            let myJSON = [socketApiKeys.kBookingId : bookingID,  profileKeys.kDriverId : driverID, profileKeys.kRejectBy: (isRejectByDriver) ? "Manual" : "background"] as [String : Any]
            socket.emit(socketApiKeys.ForwardRentalBookingRequestToAnother, with: [myJSON], completion: nil)
        } else {
           if (Singletons.sharedInstance.firstRequestIsAccepted && self.strTempBookingId.count != 0){
                let myJSON = [socketApiKeys.kBookingId : self.toursBookingId,  profileKeys.kDriverId : driverID, profileKeys.kRejectBy: (isRejectByDriver) ? "Manual" : "Auto"] as [String : Any]
                socket.emit(socketApiKeys.ForwardRentalBookingRequestToAnother, with: [myJSON], completion: nil)
                Singletons.sharedInstance.firstRequestIsAccepted = false
                
            } else {
                let myJSON = [socketApiKeys.kBookingId : self.toursBookingId,  profileKeys.kDriverId : driverID, profileKeys.kRejectBy: (isRejectByDriver) ? "Manual" : "Auto"] as [String : Any]
                socket.emit(socketApiKeys.ForwardRentalBookingRequestToAnother, with: [myJSON], completion: nil)
                Singletons.sharedInstance.firstRequestIsAccepted = false
            }
            self.toursBookingId = ""
            self.toursBookingType = ""
            Singletons.sharedInstance.tourBookingId = ""
        }
    }
    
    func BookingRejected(isRejectByDriver: Bool = false, isTripOnGoing : Bool = false, bookingID : String = "") {
        if(isTripOnGoing){
            let myJSON = [socketApiKeys.kBookingId : bookingID,  profileKeys.kDriverId : driverID, profileKeys.kRejectBy: (isRejectByDriver) ? "Manual" : "background"] as [String : Any]
            socket.emit(socketApiKeys.kRejectBookingRequest, with: [myJSON], completion: nil)
        }
        else {
            
            if (Singletons.sharedInstance.firstRequestIsAccepted && self.strTempBookingId.count != 0){
                let myJSON = [socketApiKeys.kBookingId : strTempBookingId,  profileKeys.kDriverId : driverID, profileKeys.kRejectBy: (isRejectByDriver) ? "Manual" : "Auto"] as [String : Any]
                socket.emit(socketApiKeys.kRejectBookingRequest, with: [myJSON], completion: nil)
                Singletons.sharedInstance.firstRequestIsAccepted = false
                
            }
            else
            {
                let myJSON = [socketApiKeys.kBookingId : bookingIDTemp,  profileKeys.kDriverId : driverID, profileKeys.kRejectBy: (isRejectByDriver) ? "Manual" : "Auto"] as [String : Any]
                socket.emit(socketApiKeys.kRejectBookingRequest, with: [myJSON], completion: nil)
                Singletons.sharedInstance.firstRequestIsAccepted = false
            }
            Singletons.sharedInstance.bookingId = ""
        }
    }
    
    func RejectBookLaterBookingRequest(isRejectByDriver: Bool = false) {
        
        if (Singletons.sharedInstance.advanceBookingIdTemp != "") {
            advanceBookingID = Singletons.sharedInstance.advanceBookingIdTemp
        }
        
        let myJSON = [socketApiKeys.kBookingId : advanceBookingID,  profileKeys.kDriverId : driverID, profileKeys.kRejectBy: (isRejectByDriver) ? "Manual" : "Auto"] as [String : Any]
        socket.emit(socketApiKeys.kForwardAdvancedBookingRequestToAnother, with: [myJSON], completion: nil)
        
        Singletons.sharedInstance.bookingId = ""
    }
    
    
    //-------------------------------------------------------------
    // MARK: - Cancel Trip
    //-------------------------------------------------------------
    
    
    func cancelTripByPassenger() {
        
        //        if isAdvanceBooking == true {
        //
        //            self.CancelBookLaterTripByCancelNotification()
        //
        //        }
        //        else {
        self.socket.on(socketApiKeys.kDriverCancelTripNotification, callback: { (data, ack) in
            print ("Cancel request regular by passenger: \(data)")
            self.bookingID = ""
            
            //                if let bookingData = (((data as NSArray).object(at: 0) as! NSDictionary).object(forKey: "BookingInfo") as! [[String:AnyObject]])[0]["Id"] {
            //
            //                }
            
            //            if !(Singletons.sharedInstance.isBookNowOrBookLater) {
//            self.headerView?.viewSOSIcon.isHidden = true
            UtilityClass.showAlert("App Name".localized, message: (((data as NSArray).object(at: 0) as! NSDictionary)).object(forKey: GetResponseMessageKey()) as! String, vc: self )//((UIApplication.shared.delegate as! AppDelegate).window?.rootViewController)!)
            self.resetMapView()
            Singletons.sharedInstance.bookingId = ""
            if self.driverMarker != nil {
                self.driverMarker.title = ""
            }
            self.aryPassengerData = NSArray()
            self.aryCurrentBookingData = NSMutableArray()

            
            Singletons.sharedInstance.isRequestAccepted = false
            Singletons.sharedInstance.isTripContinue = false
            UserDefaults.standard.set(Singletons.sharedInstance.isTripContinue, forKey: tripStatus.kisTripContinue)
            UserDefaults.standard.set(Singletons.sharedInstance.isRequestAccepted, forKey: tripStatus.kisRequestAccepted)
            self.setCarAfterTrip()
            //            }
            
        })
    }
    
    //    }
    
    func CancelBookLaterTripByCancelNotification() {
        
        self.socket.on(socketApiKeys.kAdvancedBookingDriverCancelTripNotification, callback: { (data, ack) in
            print ("Cancel request Later by passenger:  \(data)")
            
            if !(Singletons.sharedInstance.isBookNowOrBookLater) {
                self.bookingID = ""
                let alert = UIAlertController(title: "App Name".localized, message: ((data as NSArray).object(at: 0) as! NSDictionary).object(forKey: GetResponseMessageKey()) as? String, preferredStyle: .alert)
                let OK = UIAlertAction(title: "OK".localized, style: .default, handler: { ACTION in
                    
                    self.resetMapView()
                    Singletons.sharedInstance.isRequestAccepted = false
                    Singletons.sharedInstance.isTripContinue = false
                    
                    UserDefaults.standard.set(Singletons.sharedInstance.isTripContinue, forKey: tripStatus.kisTripContinue)
                    UserDefaults.standard.set(Singletons.sharedInstance.isRequestAccepted, forKey: tripStatus.kisRequestAccepted)
                    self.aryPassengerData = NSArray()
                    self.setCarAfterTrip()
                })
                
                alert.addAction(OK)
                self.present(alert, animated: true, completion: nil)
            }
            else {
                print(data)
                self.bookingID = ""
                let aryCurrentData = data //as? NSArray {
                if let dictFirstObjectIsDict = (aryCurrentData as? NSArray)?.object(at: 0) as? NSDictionary {
                    if let dictBookinInfoIsDictData = dictFirstObjectIsDict.object(forKey: "BookingInfo") as? NSArray {
                        if let passengerDataAdvance = dictBookinInfoIsDictData.object(at: 0) as? NSDictionary {
                            if let nameOfPassenger = passengerDataAdvance.object(forKey: "PassengerName") as? String {
                                
                                self.aryPassengerData = NSArray() // NSArray()
                                let alert = UIAlertController(title: "App Name".localized, message: "\(dictFirstObjectIsDict.object(forKey: GetResponseMessageKey()) as? String ?? "Trip has been canceled by passenger.".localized) \(nameOfPassenger)", preferredStyle: .alert)
                                let OK = UIAlertAction(title: "OK", style: .default, handler: { ACTION in
                                    
                                })
                                alert.addAction(OK)
                                self.presentedViewController?.present(alert, animated: true, completion: nil)
                            }
                        }
                        //}
                    }
                }
            }
        })
    }
    
    
    //-------------------------------------------------------------
    // MARK: - Set Car icon
    //-------------------------------------------------------------
    
    
    func setCarAfterTrip()
    {
        // print ("setCarAfterTrip")
        
        self.originCoordinate = CLLocationCoordinate2DMake(defaultLocation.coordinate.latitude, defaultLocation.coordinate.longitude)
        App_Delegate.RoadPickupTimer.invalidate()
        arrivedRoutePath = nil
        driverMarker = nil
        Singletons.sharedInstance.isRequestAccepted = false
        
    }
    
    //-------------------------------------------------------------
    // MARK: - Button Action
    //-------------------------------------------------------------
    
    @IBAction func btnCurrentLocation(_ sender: UIButton) {
        sender.LoadButtonAnimation()
        if Connectivity.isConnectedToInternet() == false {
            UtilityClass.showAlert("App Name".localized, message: "messageNotConnectedToInternet".localized, vc: self)
            return
        }
        self.boolShouldTrackCamera = true
        mapView.animate(toLocation: CLLocationCoordinate2D(latitude: defaultLocation.coordinate.latitude, longitude: defaultLocation.coordinate.longitude))
        mapView.animate(toZoom: zoomLevel)
        
    }
    
    
    @IBAction func btnReached(_ sender: UIButton) {
        sender.LoadButtonAnimation()
        
        
        let BookingInfo : NSDictionary!
        
        if((((self.aryPassengerData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "BookingInfo") as? NSDictionary) == nil)
        {
            // print ("Yes its  array ")
            BookingInfo = (((self.aryPassengerData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "BookingInfo") as! NSArray).object(at: 0) as? NSDictionary
        }
        else
        {
            // print (Yes its dictionary")
            BookingInfo = (((self.aryPassengerData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "BookingInfo") as! NSDictionary) //.object(at: 0) as! NSDictionary
        }
        var currentCount = String()
        if let DropLocationCount = BookingInfo["CurrentCount"] as? String
        {
            currentCount = DropLocationCount
        }
        else if let DropLocationCount = BookingInfo["CurrentCount"] as? Int
        {
            currentCount = "\(DropLocationCount)"
        }
        
        
        if let strBookingID = BookingInfo["Id"] as? String
        {
            strTempBookingId = strBookingID
        }
        else if let IntbookingID = BookingInfo["Id"] as? Int
        {
            strTempBookingId = "\(IntbookingID)"
        }
        if(currentCount == "0")
        {
            webserviceOfSubmitMultipleDropoff(bookingId: strTempBookingId, dropOffCount: "1", skip: "1", bookingType: (isAdvanceBooking) ? "BookLater" : "BookNow")
        }
        else
        {
            webserviceOfSubmitMultipleDropoff(bookingId: strTempBookingId, dropOffCount: "2", skip: "0", bookingType: (isAdvanceBooking) ? "BookLater" : "BookNow")
        }
        
        /*  aryBookingDropoffsData = aryBookingDropoffsData.filter{($0["Status"] as! String) == ""}
         
         if aryBookingDropoffsData.count != 0 {
         filteredBookingDropoffs = aryBookingDropoffsData.first!
         strTempBookingId = "\(filteredBookingDropoffs["BookingId"]!)"
         strTempDropOffCount = "\(filteredBookingDropoffs["DropoffCount"]!)"
         
         if sender.tag == 1 {
         webserviceOfSubmitMultipleDropoff(bookingId: strTempBookingId, dropOffCount: strTempDropOffCount, skip: "1")
         } else {
         webserviceOfSubmitMultipleDropoff(bookingId: strTempBookingId, dropOffCount: strTempDropOffCount, skip: "0")
         }
         }
         else {
         btnReached.isHidden = true
         }*/
    }
    
    @IBAction func btnStartTrip(_ sender: UIButton) {
        
        if Connectivity.isConnectedToInternet() == false {
            UtilityClass.showAlert("App Name".localized, message: "messageNotConnectedToInternet".localized, vc: self)
            return
        }
        
        if(Singletons.sharedInstance.driverDuty != "1") {
          //  UtilityClass.showAlert("App Name".localized, message: "message_getOnline".localized, vc: self)
            return
        } else if self.btnWaiting.isSelected == true {
            UtilityClass.showAlert("App Name".localized, message: "message_StopWaitingTime".localized, vc: self)
            return
        }
        
        Singletons.sharedInstance.isBookNowOrBookLater = true
        Singletons.sharedInstance.firstRequestIsAccepted = false
        
        Singletons.sharedInstance.isPickUPPasenger = true
        
        Singletons.sharedInstance.isPending = 0
        
        UpdateDriverLocation()
        
        if isAdvanceBooking == true {
            
            if advanceBookingID == "" || driverID == "" {
                
                UtilityClass.showAlert("App Name".localized, message: "Booking ID or Driver ID", vc: self)
                
            }
            else {
                sender.LoadButtonAnimation()
                if(self.btnStartTrip.title(for: .normal) == "Driver Outside".localized)
                {
                    driverClickedArrived()
                }
                else
                {
                    self.startTrip()
                    self.btnStartTripAction()
                }
            }
        }
        else {
            
            if bookingID == "" || driverID == "" {
                
                UtilityClass.showAlert("App Name".localized, message: "Booking ID or Driver ID", vc: self)
                
            }
            else {
                sender.LoadButtonAnimation()
                if(self.btnStartTrip.title(for: .normal) == "Driver Outside".localized)
                {
                    driverClickedArrived()
                }
                else
                {
                    self.startTrip()
                    self.btnStartTripAction()
                }
            }
        }
    }
    
    func driverClickedArrived()
    {
        //        btnStartTrip.setTitle("Start Trip", for: .normal)
        //        Singletons.sharedInstance.isRequestAccepted = true
        
        
        
        if Singletons.sharedInstance.bookingId == "" {
            Singletons.sharedInstance.bookingId = bookingID
        }
        let BookingInfo : NSDictionary!
        
        if((((self.aryPassengerData as NSArray).object(at: 0) as? NSDictionary)?.object(forKey: "BookingInfo") as? NSDictionary) == nil)
        {
            // print ("Yes its  array ")
            BookingInfo = (((self.aryPassengerData as NSArray).object(at: 0) as? NSDictionary)?.object(forKey: "BookingInfo") as? NSArray)?.object(at: 0) as? NSDictionary
        }
        else
        {
            // print (Yes its dictionary")
            BookingInfo = (((self.aryPassengerData as NSArray).object(at: 0) as? NSDictionary)?.object(forKey: "BookingInfo") as? NSDictionary) //.object(at: 0) as! NSDictionary
        }
        
        let myJSON = [socketApiKeys.kCurrentLat : "\(self.defaultLocation.coordinate.latitude)",
                      socketApiKeys.kCurrentLong : "\(self.defaultLocation.coordinate.longitude)",
                      socketApiKeys.kPickUpLat : BookingInfo.object(forKey: "PickupLat") ?? "",
                      socketApiKeys.kPickUpLong : BookingInfo.object(forKey: "PickupLng") ?? "",
                      socketApiKeys.kBookingType : Singletons.sharedInstance.strBookingType,
                      socketApiKeys.kPassengerId : BookingInfo.object(forKey: "PassengerId") ?? "",
                      socketApiKeys.kBookingId : BookingInfo.object(forKey: "Id") ?? "",
                      profileKeys.kDriverId : driverID] as [String : Any]
        socket.emit(socketApiKeys.kDriverArrivedCheck, with: [myJSON], completion: nil)
        print ("driverClickedArrived : \(myJSON)")
        
        
    }
    
    func checkIfDriverIsInPickupLocationRadius() {
        
        self.socket.on(socketApiKeys.kDriverArrivedCheck, callback: { (data, ack) in
            print (#function, data)
            if let isArrived = (data.first as? [String:Any])?["IsArrived"] as? String
            {
                if(isArrived == "1") {
                    self.btnStartTrip.setTitle("Start Trip".localized, for: .normal)
                }
                else
                {
                    if let strMessage = (data.first as? [String:Any])?[GetResponseMessageKey()] as? String {
                        UtilityClass.showAlert(appName.kAPPName, message: strMessage, vc: self)
                    }
                }
            }
        })
    }
    
    @IBAction func btnCancelTrip(_ sender: UIButton) {
        sender.LoadButtonAnimation()
        if Connectivity.isConnectedToInternet() == false {
            UtilityClass.showAlert("App Name".localized, message: "messageNotConnectedToInternet".localized, vc: self)
            return
        }
        
        if(Singletons.sharedInstance.driverDuty != "1") {
          //  UtilityClass.showAlert("App Name".localized, message: "message_getOnline".localized, vc: self)
            return
        } else if self.btnWaiting.isSelected == true {
            UtilityClass.showAlert("App Name".localized, message: "message_StopWaitingTime".localized, vc: self)
            return
        }
        
        let CancelTripAlert = UIAlertController(title: "App Name".localized, message: "message_cancelTrip".localized, preferredStyle: .alert)
        CancelTripAlert.addAction(UIAlertAction(title: "Yes".localized, style: .default , handler: { (UIAlertAction) in
            self.cancelTrip()
        }))
        CancelTripAlert.addAction(UIAlertAction(title: "No".localized, style: .cancel, handler:   nil))
        
        self.present(CancelTripAlert, animated: true, completion: nil)
        
    }
    
    func cancelTrip()
    {
        var dictParam = [String: AnyObject]()
        dictParam["DriverId"] = driverID as AnyObject
        if(Singletons.sharedInstance.bookingId == "" || self.bookingID.count == 0)
        {
            if (Singletons.sharedInstance.advanceBookingIdTemp != "") {
                self.advanceBookingID = Singletons.sharedInstance.advanceBookingIdTemp
            }
            
            Singletons.sharedInstance.bookingId = self.advanceBookingID
        }
        //        if Singletons.sharedInstance.bookingId == "" {
        //            Singletons.sharedInstance.bookingId = self.bookingID
        //        }
        
        if self.bookingID != "" {
            Singletons.sharedInstance.bookingId = self.bookingID
        }
        
        if Singletons.sharedInstance.strBookingType == "BookLater" {
            dictParam["BookingId"] = advanceBookingID as AnyObject
        } else {
            dictParam["BookingId"] = self.bookingID as AnyObject
        }
        
        
        dictParam["BookingType"] = Singletons.sharedInstance.strBookingType as AnyObject
        if ( Singletons.sharedInstance.strBookingType == "")
        {
            dictParam["BookingType"] = "BookNow" as AnyObject//Singletons.sharedInstance.isBookNowOrBookLater = false
        }
        
        webserviceForCancelTrip(dictParam as AnyObject) { (result, status) in
            if (status) {
                print(result)
                self.bookingID = ""
                Singletons.sharedInstance.bookingId = ""
                Singletons.sharedInstance.bookingIdTemp = ""
                self.aryPassengerData = NSArray()
                self.aryCurrentBookingData = NSMutableArray()
                if self.driverMarker != nil {
                    self.driverMarker.title = ""
                }
                
                Singletons.sharedInstance.isBookNowOrBookLater = false
                //needToCheck
                UtilityClass.showAlert("App Name".localized, message: "Trip has been cancelled.".localized, vc: self )
                self.resetMapView()
                //                if result is NSDictionary {
                //                                        UtilityClass.showAlert(appName.kAPPName, message: resDict.object(forKey: "message") as! String, vc: self)
                //                }
                
            }
            else {
                
                UtilityClass.showAlertWithCompletion("App Name".localized, message: "Please try again later.".localized, vc: self, completionHandler: { (status) in
                    self.webserviceOfCurrentBooking()
                })
                
                //                "Please cancel trip again"
                
                //                if let res = result as? String {
                //                    UtilityClass.showAlert("App Name".localized, message: res, vc: self)
                //                }
                //                else if let resDict = result as? NSDictionary {
                //                    UtilityClass.showAlert("App Name".localized, message: resDict.object(forKey: "message") as! String, vc: self)
                //                }
                //                else if let resAry = result as? NSArray {
                //                    UtilityClass.showAlert(appName.kAPPName, message: (resAry.object(at: 0) as! NSDictionary).object(forKey: "message") as! String, vc: self)
                //                }
            }
        }
    }
    
    func btnStartTripAction() {
        if Connectivity.isConnectedToInternet() == false {
            UtilityClass.showAlert("App Name".localized, message: "messageNotConnectedToInternet".localized, vc: self)
            return
        }
        
        self.mapView.clear()
        self.driverMarker = nil
        UpdateDriverLocation()
        
        Singletons.sharedInstance.isRequestAccepted = true
        Singletons.sharedInstance.isTripContinue = true
        
        UserDefaults.standard.set(Singletons.sharedInstance.isRequestAccepted, forKey: tripStatus.kisRequestAccepted)
        UserDefaults.standard.set(Singletons.sharedInstance.isTripContinue, forKey: tripStatus.kisTripContinue)
        
        
        if isAdvanceBooking == true {
            self.btnReached.isHidden = true
   
       //     self.showEstimatedView()
            self.hideEstimatedView()
            BottomButtonView.isHidden = false
            //            StartTripView.isHidden = false
            //            self.btnStartTrip.isHidden = true

            self.stackViewOfCompleteTrip.isHidden = false
            self.stackViewOfCancelTrip.isHidden = true
            self.stackViewOfStartTrip.isHidden = true
            self.stackViewOfWaitingTime.isHidden = false
            
            let BookingInfo : NSDictionary!
            if((((self.aryPassengerData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "BookingInfo") as? NSDictionary) == nil)
            {
                // print ("Yes its  array ")
                BookingInfo = (((self.aryPassengerData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "BookingInfo") as! NSArray).object(at: 0) as? NSDictionary
            }
            else
            {
                // print (Yes its dictionary")
                BookingInfo = (((self.aryPassengerData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "BookingInfo") as! NSDictionary) //.object(at: 0) as! NSDictionary
            }
            
            var currentCount = String()
            if let DropLocationCount = BookingInfo["CurrentCount"] as? String
            {
                currentCount = DropLocationCount
            }
            else if let DropLocationCount = BookingInfo["CurrentCount"] as? Int
            {
                currentCount = "\(DropLocationCount)"
            }
            
            self.btnReached.isHidden = true
            if(currentCount == "0" && (BookingInfo["DropoffLocation2"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines).count != 0)
            {
                self.btnReached.isHidden = false
                self.btnCompleteTrip.isHidden = true
            }
            
            //            self.viewLocationDetails.isHidden = false
            self.constrainLocationViewBottom?.priority = UILayoutPriority(rawValue: 800)
            self.pickupPassengerFromLocation()
            
            //            self.view.bringSubviewToFront(StartTripView)
            
        }
        else {
      //      self.showEstimatedView()
            self.hideEstimatedView()
            BottomButtonView.isHidden = false
            //            StartTripView.isHidden = false
            //            self.btnStartTrip.isHidden = true
            self.stackViewOfWaitingTime.isHidden = false
            self.stackViewOfCompleteTrip.isHidden = false
            self.stackViewOfCancelTrip.isHidden = true
            self.stackViewOfStartTrip.isHidden = true
            
            let BookingInfo : NSDictionary!
            if((((self.aryPassengerData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "BookingInfo") as? NSDictionary) == nil)
            {
                // print ("Yes its  array ")
                BookingInfo = (((self.aryPassengerData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "BookingInfo") as! NSArray).object(at: 0) as? NSDictionary
            }
            else
            {
                // print (Yes its dictionary")
                BookingInfo = (((self.aryPassengerData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "BookingInfo") as! NSDictionary) //.object(at: 0) as! NSDictionary
            }
            
            var currentCount = String()
            if let DropLocationCount = BookingInfo["CurrentCount"] as? String
            {
                currentCount = DropLocationCount
            }
            else if let DropLocationCount = BookingInfo["CurrentCount"] as? Int
            {
                currentCount = "\(DropLocationCount)"
            }
            
            self.btnReached.isHidden = true
            if(currentCount == "0" && (BookingInfo["DropoffLocation2"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines).count != 0)
            {
                self.btnReached.isHidden = false
                self.btnCompleteTrip.isHidden = true
            }
            
            self.viewLocationDetails.isHidden = false
            self.constrainLocationViewBottom?.priority = UILayoutPriority(rawValue: 800)
            //            self.view.bringSubviewToFront(StartTripView)
            self.pickupPassengerFromLocation()
        }
        self.constrainLocationViewBottom?.priority = UILayoutPriority(rawValue: 800)
        Singletons.sharedInstance.MeterStatus = meterStatus.kIsMeterStart
        
    }
    
    func startTrip() {
        
        if Singletons.sharedInstance.bookingId == "" {
            Singletons.sharedInstance.bookingId = bookingID
        }
        
        
        if isAdvanceBooking
        {
            PickupPassengerByDriverInBookLaterRequest()
        }
        else
        {
            let myJSON = [socketApiKeys.kBookingId : Singletons.sharedInstance.bookingId,  profileKeys.kDriverId : driverID] as [String : Any]
            socket.emit(socketApiKeys.kPickupPassengerByDriver, with: [myJSON], completion: nil)
        }
    }
    
    @IBAction func btnShowPassengerInfo(_ sender: UIButton) {
        sender.LoadButtonAnimation()
        
        let data: NSArray = self.aryBookingData
        print(data)
   
//        UserDefaults.standard.set(data, forKey: "BookNowInformation")
//        UserDefaults.standard.synchronize()
        
        self.aryPassengerData = NSArray(array: data)
        
        self.showEstimatedView()
        self.BottomButtonView.isHidden = false
        self.btnStartTrip.isHidden = false
        let getPassengerInfo = getBookingAndPassengerInfo(data: self.aryPassengerData)
        
        let BookingInfo = getPassengerInfo.0
        let PassengerInfo = getPassengerInfo.1
        var imgURL = String()
        
        //        self.lblLocationOnMap.text = BookingInfo.object(forKey: "PickupLocation") as? String
        self.strPickupLocation = BookingInfo.object(forKey: "PickupLocation") as! String
        self.strDropoffLocation = BookingInfo.object(forKey: "DropoffLocation") as! String
        self.strPassengerName = PassengerInfo.object(forKey: "Fullname") as! String
        self.strPassengerMobileNo = PassengerInfo.object(forKey: "MobileNo") as! String
        
        if let img =  PassengerInfo.object(forKey: "Image") as? String {
            imgURL = img
        }
        else {
            imgURL = ""
        }
        
        if let PassengerType = BookingInfo.object(forKey: "PassengerType") as? String {
            Singletons.sharedInstance.passengerType = PassengerType
        }
        if Singletons.sharedInstance.passengerType == "other" || Singletons.sharedInstance.passengerType == "others" {
            
            if let contactNumber = BookingInfo.object(forKey: "PassengerContact") as? String {
                
                self.strPassengerMobileNo = contactNumber
            }
        }
        
        if let strDropoffLocation2 = BookingInfo.object(forKey: "DropoffLocation2") as? String {
            self.strDropoffLocation2 = strDropoffLocation2
        }
        
        let PaymentType = BookingInfo.object(forKey: "PaymentType") as? String ?? ""
        
        let next = self.storyboard?.instantiateViewController(withIdentifier: "PassengerInfoViewController") as! PassengerInfoViewController
        next.homeVC = self
        next.delegate = self
        next.strPickupLocation = self.strPickupLocation
        next.strDropoffLocation = self.strDropoffLocation
        next.strDropoffLocation2 = self.strDropoffLocation2
        next.paymentType = PaymentType
        next.imgURL = imgURL
        next.isDiscountApplied = (BookingInfo.object(forKey: "PromoCode") as? String ?? "" != "") ? true : false
        
        if((PassengerInfo.object(forKey: "FlightNumber")) != nil)
        {
            next.strFlightNumber = PassengerInfo.object(forKey: "FlightNumber") as! String
        }
        if((PassengerInfo.object(forKey: "Notes")) != nil)
        {
            next.strNotes = PassengerInfo.object(forKey: "Notes") as! String
        }
        next.strPassengerName =  self.strPassengerName
        next.strPassengerMobileNumber =  self.strPassengerMobileNo
        //        (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.present(next, animated: true, completion: nil)
        self.present(next, animated: true, completion: nil)
    }
    
    
    //MARK:- Local Notification
    
    func addLocalNotification()
    {
        let state: UIApplication.State = UIApplication.shared.applicationState // or use  let state =  UIApplication.sharedApplication().applicationState
        
        if state == .background {
            
            let center = UNUserNotificationCenter.current()
            let options: UNAuthorizationOptions = [.alert,.sound];
            center.requestAuthorization(options: options) {
                (granted, error) in
                if !granted {
                    print("Something went wrong")
                }
            }
            center.getNotificationSettings { (settings) in
                if settings.authorizationStatus != .authorized {
                    // Notifications not allowed
                }
            }
            let content = UNMutableNotificationContent()
            content.title = "Booking Request"
            content.body = "You have a new booking request"
            content.sound = UNNotificationSound.default
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1,
                                                            repeats: false)
            
            let identifier = "localNotification"
            
            let request = UNNotificationRequest(identifier: identifier,
                                                content: content, trigger: trigger)
            
            center.add(request) { (error:Error?) in
                
                if error != nil {
                    print(error?.localizedDescription ?? "")
                }
                print("Notification Register Success")
            }
            
        }
    }
    
    
    //MARK:- Play Audio
    var audioPlayer:AVAudioPlayer!
    
    func playSound(strName : String) {
        
        guard let url = Bundle.main.url(forResource: strName, withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.numberOfLoops = 1
            audioPlayer.play()
        }
        catch let error {
            print(error.localizedDescription)
        }
    }
    
    func stopSound() {
        
        //        guard let url = Bundle.main.url(forResource: "\(RingToneSound)", withExtension: "mp3") else { return }
        //
        //        do {
        //            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
        //            try AVAudioSession.sharedInstance().setActive(true)
        //
        //            audioPlayer = try AVAudioPlayer(contentsOf: url)
        audioPlayer?.stop()
        //        }
        //        catch let error {
        //            print(error.localizedDescription)
        //        }
    }
    
    @objc func enableButton() {
        self.btnCompleteTrip.isEnabled = true
    }
    
    var tollFee = String()
    
    func setPaddingView(txtField: UITextField){
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 18))
        label.text = "\(currency)"
        
        let paddingView: UIView = UIView.init(frame: CGRect(x: 0, y: 0, width: 45, height: 18))
        txtField.leftViewMode = .always
        txtField.addSubview(label)
        txtField.leftView = paddingView
    }
    
    @IBAction func btnCompleteTrip(_ sender: UIButton)
    {
        self.bookingID = ""
        sender.LoadButtonAnimation()
        if Connectivity.isConnectedToInternet() == false {
            UtilityClass.showAlert("App Name".localized, message: "messageNotConnectedToInternet".localized, vc: self)
            return
        }
        
        if(Singletons.sharedInstance.driverDuty != "1") {
        //    UtilityClass.showAlert("App Name".localized, message: "message_getOnline".localized, vc: self)
            return
        } else if self.btnWaiting.isSelected == true {
            UtilityClass.showAlert("App Name".localized, message: "message_StopWaitingTime".localized, vc: self)
            return
        }
        
        
        Singletons.sharedInstance.isBookNowOrBookLater = false
        
        tollFee = "0.00"
        
        //        if (Singletons.sharedInstance.isTripHolding == false)
        //        {
        //        if(Singletons.sharedInstance.strBookingType == "")
        //        {
        //
        //            //1. Create the alert controller.
        //            let alert = UIAlertController(title: "Toll Fee", message: "Enter toll fee if any", preferredStyle: .alert)
        //
        //            //2. Add the text field. You can configure it however you need.
        //            alert.addTextField { (textField) in
        //                textField.placeholder = "0.00"
        //                textField.keyboardType = .decimalPad
        //                self.setPaddingView(txtField: textField)
        //
        //            }
        //
        //            // 3. Grab the value from the text field, and print it when the user clicks OK.
        //            alert.addAction(UIAlertAction(title: "YES", style: .default, handler: { [weak alert] (_) in
        //                let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
        //                self.tollFee = (textField?.text)!
        //                print("Text field: \(String(describing: textField?.text))")
        //
        //                if Singletons.sharedInstance.passengerPaymentType == "cash" || Singletons.sharedInstance.passengerPaymentType == "Cash" {
        //
        //                    self.completeTripButtonAction()
        //
        //                }
        //                else {
        //
        //                    self.completeTripButtonAction()
        //                }
        //            }))
        //
        //
        //            // 3. Grab the value from the text field, and print it when the user clicks OK.
        //            alert.addAction(UIAlertAction(title: "NO", style: .destructive, handler: { [] (_) in
        //                if Singletons.sharedInstance.passengerPaymentType == "cash" || Singletons.sharedInstance.passengerPaymentType == "Cash" {
        //
        //                    self.completeTripButtonAction()
        //
        //                }
        //                else {
        //
        //                    self.completeTripButtonAction()
        //                }
        //            }))
        //
        //            // 4. Present the alert.
        //            self.present(alert, animated: true, completion: nil)
        //
        //        }
        //        else
        //        {
        //            self.completeTripButtonAction()
        //
        //        }
        
        
        let BookingInfo : NSDictionary!
        
        if((((self.aryPassengerData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "BookingInfo") as? NSDictionary) == nil)
        {
            // print ("Yes its  array ")
            BookingInfo = (((self.aryPassengerData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "BookingInfo") as! NSArray).object(at: 0) as? NSDictionary
        }
        else
        {
            // print (Yes its dictionary")
            BookingInfo = (((self.aryPassengerData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "BookingInfo") as! NSDictionary) //.object(at: 0) as! NSDictionary
        }
        var currentCount = String()
        if let DropLocationCount = BookingInfo["CurrentCount"] as? String
        {
            currentCount = DropLocationCount
        }
        else if let DropLocationCount = BookingInfo["CurrentCount"] as? Int
        {
            currentCount = "\(DropLocationCount)"
        }
        if let strBookingID = BookingInfo["Id"] as? String
        {
            strTempBookingId = strBookingID
        }
        else if let IntbookingID = BookingInfo["Id"] as? Int
        {
            strTempBookingId = "\(IntbookingID)"
        }
        
        if(currentCount == "0" && (BookingInfo["DropoffLocation2"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines).count != 0)
        {
            if(btnReached.isHidden == true)
            {
                webserviceOfSubmitMultipleDropoff(bookingId: strTempBookingId, dropOffCount: "2", skip: "0", bookingType: (isAdvanceBooking) ? "BookLater" : "BookNow", isFromComplete: true)
            }
            else
            {
                webserviceOfSubmitMultipleDropoff(bookingId: strTempBookingId, dropOffCount: "1", skip: "0", bookingType: (isAdvanceBooking) ? "BookLater" : "BookNow", isFromComplete: true)
            }
        }
        else
        {
            self.completeTripButtonAction()
        }
        
        Singletons.sharedInstance.MeterStatus = meterStatus.kIsMeterStop
        
        //        }
        //        else
        //        {
        //            UtilityClass.showAlert("Hold Trip Active", message: "Please stop holding trip", vc: self)
        //        }
    }
    
    func completeTripButtonAction()
    {
        
        //        self.btnCompleteTrip.isEnabled = false
        //        Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(HomeViewController.enableButton), userInfo: nil, repeats: false)
        //
        //        //        if Singletons.sharedInstance.isTripHolding == true
        //        //        {
        //        //            UtilityClass.showAlert("Hold Trip Active", message: "Please stop holding trip", vc: self)
        //        //
        //        //        }
        //        //        else
        //        //        {
        //
        //        DispatchQueue.main.async
        //            {
        //
        //                self.webserviceCallToGetDistanceByBackend()
        //
        //        }
        
        //        self.webserviceCallToGetDistanceByBackend()
        //        self.btnCompleteTrip.isEnabled = false
        //        Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(HomeViewController.enableButton), userInfo: nil, repeats: false)
        
        //        if Singletons.sharedInstance.isTripHolding == true
        //        {
        //            UtilityClass.showAlert("Hold Trip Active", message: "Please stop holding trip", vc: self)
        //
        //        }
        //        else
        //        {
        //1. Create the alert controller.
        /*      let alert = UIAlertController(title: "Tip".localized, message: "Want to ask about Tips?".localized, preferredStyle: .alert)
         alert.addAction(UIAlertAction(title: "Yes".localized, style: .default, handler: { [weak alert] (_) in
         
         
         //                        Utilities.showActivityIndicator()
         
         if self.driverID == Singletons.sharedInstance.strDriverID
         {
         if self.isAdvanceBooking
         {
         self.getSocketCallforGetingTipForBooklater(self.driverID, self.advanceBookingID)
         }
         else
         {
         self.getSocketCallforGetingTip(self.driverID, self.bookingID)
         
         }
         let ViewController = self.storyboard?.instantiateViewController(withIdentifier: "WaitForTipViewController") as? WaitForTipViewController
         ViewController?.delegateWaitingTimeTip = self
         //                ViewController?.arrBookingRequestData = (data as? [[String : AnyObject]])!
         
         
         let alertWindow = UIWindow(frame: UIScreen.main.bounds)
         alertWindow.rootViewController = UIViewController()
         alertWindow.windowLevel = UIWindow.Level.alert + 1;
         alertWindow.makeKeyAndVisible()
         alertWindow.rootViewController?.present(ViewController!, animated: true, completion: {
         //                    SingletonClass.sharedInstance.firstRequestIsAccepted = true
         })
         }
         
         //                        DispatchQueue.main.asyncAfter(deadline: .now() + 40.0, execute:
         //                            {
         //                                Utilities.showActivityIndicator()
         //                                if SingletonClass.sharedInstance.passengerPaymentType == "cash" || SingletonClass.sharedInstance.passengerPaymentType == "Cash"
         //                                {
         //
         //                                    self.completeTripFinalSubmit()
         //                                    Appdelegate.WaitingTimeCount = 0
         //                                    Appdelegate.WaitingTime = "00:00:00"
         //                                }
         //                                else
         //                                {
         //                                    //                self.completeTripButtonAction()
         //                                    self.completeTripFinalSubmit()
         //                                    Appdelegate.WaitingTimeCount = 0
         //                                    Appdelegate.WaitingTime = "00:00:00"
         //                                }
         //                        })
         
         }))
         alert.addAction(UIAlertAction(title: "No".localized, style: .destructive, handler: { [] (_) in
         */
        UtilityClass.showACProgressHUD()
        if Singletons.sharedInstance.passengerPaymentType == "cash" || Singletons.sharedInstance.passengerPaymentType == "Cash" {
            
            //                self.completeTripButtonAction()
            //                self.completeTripFinalSubmit()
            self.getLastAddressForLatLng(DropOffAddress: (self.lastLocation != nil) ? self.lastLocation : self.defaultLocation)
            Appdelegate.WaitingTimeCount = 0
            Appdelegate.WaitingTime = "00:00:00"
            
            self.tollFee = "0"
            
        }
        else
        {
            //                self.completeTripButtonAction()
            //                self.completeTripFinalSubmit()
            self.getLastAddressForLatLng(DropOffAddress: (self.lastLocation != nil) ? self.lastLocation : self.defaultLocation)
            Appdelegate.WaitingTimeCount = 0
            Appdelegate.WaitingTime = "00:00:00"
            self.tollFee = "0"
        }
        //        }))
        
        //        self.present(alert, animated: true, completion: nil)
        
        
        //        }
    }
    
    func completeTripFinalSubmit(LastAddress:String) {
        
        //        if sumOfFinalDistance != 0 {
        
        var dictOFParam = [String:AnyObject]()
        dictOFParam["Lat"] = "\(Singletons.sharedInstance.latitude ?? 0)" as AnyObject
        dictOFParam["Long"] = "\(Singletons.sharedInstance.longitude ?? 0)" as AnyObject
        let tollfee = self.tollFee.replacingOccurrences(of: "\(currency)", with: "")
        dictOFParam["TripDistance"] = Singletons.sharedInstance.distanceTravelledThroughMeter as AnyObject //App_Delegate.DistanceKiloMeter as AnyObject//sumOfFinalDistance as AnyObject
        dictOFParam["NightFareApplicable"] = 0 as AnyObject
        dictOFParam["PromoCode"] = "" as AnyObject
        dictOFParam["PaymentType"] = Singletons.sharedInstance.passengerPaymentType as AnyObject
        dictOFParam["PaymentStatus"] = "" as AnyObject
        dictOFParam["TransactionId"] = "" as AnyObject
        dictOFParam["TollFee"] = tollfee as AnyObject
        dictOFParam["WaitingTime"] = App_Delegate.WaitingTime as AnyObject
        dictOFParam["Pending"] = Singletons.sharedInstance.isPending as AnyObject
//        let pickupCordinate = "\(Singletons.sharedInstance.startedTripLatitude),\(Singletons.sharedInstance.startedTripLongitude)"
//        let destinationCordinate = "\(self.defaultLocation.coordinate.latitude),\(self.defaultLocation.coordinate.longitude)"
//        if(App_Delegate.DistanceKiloMeter == "")
//        {
//            dictOFParam["lat"] = "\(pickupCordinate)" as AnyObject
//            dictOFParam["long"] = "\(destinationCordinate)" as AnyObject
//        }
        
        dictOFParam["DropoffLocation"] = LastAddress as AnyObject
        UtilityClass.hideACProgressHUD()
        
        if isAdvanceBooking {
            
            if bookingID != "" {
                
                if (Singletons.sharedInstance.bookingIdTemp != "") {
                    Singletons.sharedInstance.bookingId = Singletons.sharedInstance.bookingIdTemp
                }
                
                if Singletons.sharedInstance.bookingId == "" && advanceBookingID != "" {
                    
                    dictOFParam["BookingId"] = advanceBookingID as AnyObject
                    webserviceCallForAdvanceCompleteTrip(dictOFParam: dictOFParam as AnyObject)
                    
                }
                else {
                    dictOFParam["BookingId"] = Singletons.sharedInstance.bookingId as AnyObject // bookingID as AnyObject
                    webserviceCallForCompleteTrip(dictOFParam: dictOFParam as AnyObject)
                }
                
            }
            else {
                
                if (Singletons.sharedInstance.advanceBookingIdTemp != "") {
                    advanceBookingID = Singletons.sharedInstance.advanceBookingId
                }
                dictOFParam["BookingId"] = advanceBookingID as AnyObject
                
                webserviceCallForAdvanceCompleteTrip(dictOFParam: dictOFParam as AnyObject)
            }
            
            
            
            
            //
            //                if (Singletons.sharedInstance.oldBookingType.isBookNow) {
            //                    dictOFParam["BookingId"] = Singletons.sharedInstance.bookingId as AnyObject // bookingID as AnyObject
            //
            //                    webserviceCallForCompleteTrip(dictOFParam: dictOFParam as AnyObject)
            //                }
            //                else {
            //                    if (Singletons.sharedInstance.advanceBookingIdTemp != "") {
            //                        advanceBookingID = Singletons.sharedInstance.advanceBookingId
            //                    }
            //
            //                    dictOFParam["BookingId"] = advanceBookingID as AnyObject
            //
            //                    webserviceCallForAdvanceCompleteTrip(dictOFParam: dictOFParam as AnyObject)
            //                }
            
            //                if (Singletons.sharedInstance.advanceBookingIdTemp != "") {
            //                    advanceBookingID = Singletons.sharedInstance.advanceBookingId
            //                }
            //
            //                dictOFParam["BookingId"] = advanceBookingID as AnyObject
            //
            //                webserviceCallForAdvanceCompleteTrip(dictOFParam: dictOFParam as AnyObject)
        }
        else
        {
            
            if advanceBookingID != "" {
                if (Singletons.sharedInstance.advanceBookingIdTemp != "") {
                    advanceBookingID = Singletons.sharedInstance.advanceBookingId
                }
                
                dictOFParam["BookingId"] = advanceBookingID as AnyObject
                webserviceCallForAdvanceCompleteTrip(dictOFParam: dictOFParam as AnyObject)
            }
            else {
                
                if Singletons.sharedInstance.bookingId == "" {
                    if (Singletons.sharedInstance.bookingIdTemp != "") {
                        Singletons.sharedInstance.bookingId = Singletons.sharedInstance.bookingIdTemp
                    }
                }
                
                dictOFParam["BookingId"] = Singletons.sharedInstance.bookingId as AnyObject // bookingID as AnyObject
                webserviceCallForCompleteTrip(dictOFParam: dictOFParam as AnyObject)
            }
            
            
            //                if (Singletons.sharedInstance.oldBookingType.isBookNow) {
            //
            //                    dictOFParam["BookingId"] = Singletons.sharedInstance.bookingId as AnyObject // bookingID as AnyObject
            //                    webserviceCallForCompleteTrip(dictOFParam: dictOFParam as AnyObject)
            //                }
            //                else {
            //                    if (Singletons.sharedInstance.advanceBookingIdTemp != "") {
            //                        advanceBookingID = Singletons.sharedInstance.advanceBookingId
            //                    }
            //
            //                    dictOFParam["BookingId"] = advanceBookingID as AnyObject
            //
            //                    webserviceCallForAdvanceCompleteTrip(dictOFParam: dictOFParam as AnyObject)
            //                }
            
            
            //                dictOFParam["BookingId"] = Singletons.sharedInstance.bookingId as AnyObject // bookingID as AnyObject
            //                webserviceCallForCompleteTrip(dictOFParam: dictOFParam as AnyObject)
        }
        
        //        }
    }
    
    
    //=========================================================
    
    func webserviceCallToGetDistanceByBackend()
    {
        let url = "\(WebserviceURLs.kBaseURL)FindDistance"
        let pickupCordinate = "\(Singletons.sharedInstance.startedTripLatitude),\(Singletons.sharedInstance.startedTripLongitude)"
        let destinationCordinate = "\(self.defaultLocation.coordinate.latitude),\(self.defaultLocation.coordinate.longitude)"
        
        var dictParams = [String:AnyObject]()
        dictParams["PickupLocation"] = pickupCordinate as AnyObject
        dictParams["DropoffLocation"] = destinationCordinate as AnyObject
        
        
        //        if UIDevice.current.name == "Rahul's iPhone" {
        //
        //            dictParams["DropoffLocation"] = "23.08327370,72.54679840" as AnyObject
        //        }
        let headerTemp: [String:String] = ["key":"Book$951951"]
        
        Alamofire.request(url, method: .post, parameters: dictParams, encoding: URLEncoding.default, headers: headerTemp)
            .validate()
            .responseJSON
        { (response) in
            
            
            if let JSON = response.result.value
            {
                
                if (JSON as AnyObject).object(forKey:("status")) as! Bool == false
                {
                    //                        completion(JSON as AnyObject, false)
                    self.webserviceCallToGetDistanceByBackend()
                    UtilityClass.hideACProgressHUD()
                    
                }
                else
                {
                    //                        completion(JSON as AnyObject, true)
                    self.sumOfFinalDistance = (JSON as AnyObject).object(forKey:("distance")) as! Double
                    DispatchQueue.main.async {
                        //                                        UtilityClass.hideACProgressHUD()
                        //                            self.completeTripFinalSubmit()
                        self.getLastAddressForLatLng(DropOffAddress: (self.lastLocation != nil) ? self.lastLocation : self.defaultLocation)
                        
                        //                            print("Function: \(#function), line: \(#line)")
                        
                    }
                    UtilityClass.hideACProgressHUD()
                    App_Delegate.WaitingTimeCount = 0
                    NotificationCenter.default.removeObserver("endTrip")
                    
                }
            }
            else
            {
                UtilityClass.hideACProgressHUD()
                self.webserviceCallToGetDistanceByBackend()
                
                //                    completion(response.error?.localizedDescription as AnyObject, false)
            }
            
        }
    }
    //MARK:- ResetMap View
    func resetMapView()
    {
        self.mapView.clear()
        
        self.hideEstimatedView()
        self.BottomButtonView.isHidden = true
        //        self.StartTripView.isHidden = true
        self.btnStartTrip.isHidden = true
        self.sumOfFinalDistance = 0
        
        self.constrainLocationViewBottom?.priority = UILayoutPriority(rawValue: 600)
        
    }
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        if (gesture){
            print("dragged")
            self.boolShouldTrackCamera = false
            if(isCameraDisable == false){
                DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
                    self.boolShouldTrackCamera = true
                    self.isCameraDisable = false
                }
            }
            self.isCameraDisable = true
        }
    }
    
    // Holding Button
    @IBAction func btnHoldWaiting(_ sender: UIButton) {
        sender.LoadButtonAnimation()
        if isAdvanceBooking {
            if advanceBookingID == "" {
                UtilityClass.showAlert("App Name".localized, message: "Booking Id".localized, vc: self)
            }
            else {
                //                if self.btnWaiting.currentTitle == "Hold Trip".localized {
                if self.btnWaiting.isSelected == false {
                    self.btnWaiting.isSelected = true
                    //                    btnWaiting.setTitle("Stop Waiting".localized,for: .normal)
                    Singletons.sharedInstance.isTripHolding = true
                    UserDefaults.standard.set(Singletons.sharedInstance.isTripHolding, forKey: holdTripStatus.kIsTripisHolding)
                    self.AdvancedStartHoldTrip()
                    if (!App_Delegate.RoadPickupTimer.isValid)
                    {
                        App_Delegate.RoadPickupTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector:  #selector(HomeViewController.updateTime), userInfo: nil, repeats: true)
                    }
                    
                } else if self.btnWaiting.isSelected == true {
                    //                } else if self.btnWaiting.currentTitle == "Stop Waiting".localized {
                    self.btnWaiting.isSelected = false
                    //                    btnWaiting.setTitle("Hold Trip".localized,for: .normal)
                    Singletons.sharedInstance.isTripHolding = false
                    UserDefaults.standard.set(Singletons.sharedInstance.isTripHolding, forKey: holdTripStatus.kIsTripisHolding)
                    self.AdvancedEndHoldTrip()
                    App_Delegate.RoadPickupTimer.invalidate()
                }
                
                // This code is commented in because of Hold Functionality
                //                if Singletons.sharedInstance.MeterStatus == meterStatus.kIsMeterOnHolding
                //                {
                //
                //                    btnWaiting.setTitle("Stop Waiting".localized,for: .normal)
                //
                //                    Singletons.sharedInstance.isTripHolding = true
                //                    UserDefaults.standard.set(Singletons.sharedInstance.isTripHolding, forKey: holdTripStatus.kIsTripisHolding)
                //                    self.AdvancedStartHoldTrip()
                //                    if (!App_Delegate.RoadPickupTimer.isValid())
                //                    {
                //                        App_Delegate.RoadPickupTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector:  #selector(HomeViewController.updateTime), userInfo: nil, repeats: true)
                //                    }
                //
                //                }
                //                else
                //                {
                //
                //                    btnWaiting.setTitle("Hold Trip".localized,for: .normal)
                //                    Singletons.sharedInstance.isTripHolding = false
                //                    UserDefaults.standard.set(Singletons.sharedInstance.isTripHolding, forKey: holdTripStatus.kIsTripisHolding)
                //                    self.AdvancedEndHoldTrip()
                //                    App_Delegate.RoadPickupTimer.invalidate()
                //
                //                }
                
                //                if btnWaiting.currentTitle == "Hold (Waiting)"
                //                {
                //
                //                    btnWaiting.setTitle("Stop (Waiting)",for: .normal)
                //
                //                    Singletons.sharedInstance.isTripHolding = true
                //                    UserDefaults.standard.set(Singletons.sharedInstance.isTripHolding, forKey: holdTripStatus.kIsTripisHolding)
                //                    Singletons.sharedInstance.MeterStatus = meterStatus.kIsMeterOnHolding
                //                    //                    self.StartHoldTrip()
                //
                //                }
                //                else if btnWaiting.currentTitle == "Stop (Waiting)" {
                //
                //                    btnWaiting.setTitle("Hold (Waiting)",for: .normal)
                //                    Singletons.sharedInstance.MeterStatus = meterStatus.kIsMeterStart
                //                    Singletons.sharedInstance.isTripHolding = false
                //                    UserDefaults.standard.set(Singletons.sharedInstance.isTripHolding, forKey: holdTripStatus.kIsTripisHolding)
                //                    //                    self.EndHoldTrip()
                //
                //                }
                
            }
            
        }
        else
        {
            
            if bookingID == "" && Singletons.sharedInstance.isRequestAccepted == true
            {
                UtilityClass.showAlert("App Name".localized, message: "Booking Id".localized, vc: self)
            }
            else
            {
                //                if self.btnWaiting.currentTitle == "Hold Trip".localized {
                if self.btnWaiting.isSelected == false {
                    //                    btnWaiting.setTitle("Stop Waiting".localized,for: .normal)
                    self.btnWaiting.isSelected = true
                    Singletons.sharedInstance.isTripHolding = true
                    UserDefaults.standard.set(Singletons.sharedInstance.isTripHolding, forKey: holdTripStatus.kIsTripisHolding)
                    self.StartHoldTrip()
                    if (!App_Delegate.RoadPickupTimer.isValid)
                    {
                        App_Delegate.RoadPickupTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector:  #selector(HomeViewController.updateTime), userInfo: nil, repeats: true)
                    }
                } else if self.btnWaiting.isSelected == true {
                    //                } else if self.btnWaiting.currentTitle == "Stop Waiting".localized {
                    //                    btnWaiting.setTitle("Hold Trip".localized,for: .normal)
                    self.btnWaiting.isSelected = false
                    //
                    Singletons.sharedInstance.isTripHolding = false
                    UserDefaults.standard.set(Singletons.sharedInstance.isTripHolding, forKey: holdTripStatus.kIsTripisHolding)
                    self.EndHoldTrip()
                    App_Delegate.RoadPickupTimer.invalidate()
                }
                
                // This code is commented in because of Hold Functionality
                //                if Singletons.sharedInstance.MeterStatus == meterStatus.kIsMeterOnHolding
                //                {
                //                    btnWaiting.setTitle("Stop Waiting".localized,for: .normal)
                //
                //                    Singletons.sharedInstance.isTripHolding = true
                //                    UserDefaults.standard.set(Singletons.sharedInstance.isTripHolding, forKey: holdTripStatus.kIsTripisHolding)
                //                    self.StartHoldTrip()
                //                    if (!App_Delegate.RoadPickupTimer.isValid())
                //                    {
                //                        App_Delegate.RoadPickupTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector:  #selector(HomeViewController.updateTime), userInfo: nil, repeats: true)
                //                    }
                //                }
                //                else
                //                {
                //                    btnWaiting.setTitle("Hold Trip".localized,for: .normal)
                //
                //                    Singletons.sharedInstance.isTripHolding = false
                //                    UserDefaults.standard.set(Singletons.sharedInstance.isTripHolding, forKey: holdTripStatus.kIsTripisHolding)
                //                    self.EndHoldTrip()
                //                    App_Delegate.RoadPickupTimer.invalidate()
                //                }
                
                
                SingletonsForMeter.sharedInstance.isMeterOnHold = sender.isSelected
                
                if(sender.isSelected)
                {
                    Singletons.sharedInstance.MeterStatus = meterStatus.kIsMeterOnHolding
                }
                else
                {
                    Singletons.sharedInstance.MeterStatus = meterStatus.kIsMeterStart
                }
                
                //                sender.isSelected = !sender.isSelected
            }
        }
        self.btnWaiting2.isSelected = self.btnWaiting.isSelected
        NotificationCenter.default.removeObserver("HoldCurrentTrip")
    }
    
    @IBOutlet weak var btnRejectRequest: UIButton!
    @IBOutlet weak var btnAcceptRequest: UIButton!
    
    @IBAction func btnAcceptRequest(_ sender: UIButton) {
        sender.LoadButtonAnimation()
        if Connectivity.isConnectedToInternet() == false {
            UtilityClass.showAlert("App Name".localized, message: "messageNotConnectedToInternet".localized, vc: self)
            return
        }
        
        Singletons.sharedInstance.isPickUPPasenger = false
        
        //        self.resetMapView()
        manager.startUpdatingLocation()
        if isAdvanceBooking {
            self.AcceptBookLaterBookingRequest()
        }
        else {
            self.BookingAcceped()
        }
        
    }
    
    @IBAction func btnRejectRequest(_ sender: UIButton) {
        sender.LoadButtonAnimation()
        if Connectivity.isConnectedToInternet() == false {
            UtilityClass.showAlert("App Name".localized, message: "messageNotConnectedToInternet".localized, vc: self)
            return
        }
        
        if isAdvanceBooking {
            self.RejectBookLaterBookingRequest()
        }
        else {
            self.BookingRejected()
        }
        
    }
    
    @IBAction func btnPassengerInfoOK(_ sender: UIButton) {
        sender.LoadButtonAnimation()
    }
    
    func pickupPassengerFromLocation() {
        
        let BookingInfo : NSDictionary!
        
        if((((self.aryPassengerData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "BookingInfo") as? NSDictionary) == nil)
        {
            // print ("Yes its  array ")
            BookingInfo = (((self.aryPassengerData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "BookingInfo") as! NSArray).object(at: 0) as? NSDictionary
        }
        else
        {
            // print (Yes its dictionary")
            BookingInfo = (((self.aryPassengerData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "BookingInfo") as! NSDictionary) //.object(at: 0) as! NSDictionary
        }
        
        // ------------------------------------------------------------
        
        //        SingletonsForMeter.sharedInstance.vehicleModelID = (Int(BookingInfo.object(forKey: "ModelId") as! NSNumber))
        
        var VehicleID = String()
        
        if let vehId = BookingInfo.object(forKey: "ModelId") as? String {
            VehicleID = vehId
        }
        else if let vehId = BookingInfo.object(forKey: "ModelId") as? Int {
            VehicleID = "\(vehId)"
        }
        
        SingletonsForMeter.sharedInstance.vehicleModelID = Int(VehicleID)!
        
//        let DropOffLat = BookingInfo.object(forKey: "DropOffLat") as! String
//        let DropOffLon = BookingInfo.object(forKey: "DropOffLon") as! String
        
        let dropLocation2 = BookingInfo["DropoffLocation2"] as? String ?? ""
        let currentcount = Int(BookingInfo["CurrentCount"] as? String ?? "") ?? 0
        let DropOffLat = (dropLocation2.trimmingCharacters(in: .whitespacesAndNewlines) != "" && currentcount > 0) ? BookingInfo.object(forKey: "DropOffLat2") as? String ?? "" : BookingInfo.object(forKey: "DropOffLat") as? String ?? ""
        let DropOffLon = (dropLocation2.trimmingCharacters(in: .whitespacesAndNewlines) != "" && currentcount > 0) ? BookingInfo.object(forKey: "DropOffLon2") as? String ?? "" : BookingInfo.object(forKey: "DropOffLon") as? String ?? ""
        
//                Singletons.sharedInstance.startedTripLatitude = Double(BookingInfo.object(forKey: "PickupLat") as! String)!
//                Singletons.sharedInstance.startedTripLongitude = Double(BookingInfo.object(forKey: "PickupLng") as! String)!
        
        Singletons.sharedInstance.startedTripLatitude = self.defaultLocation.coordinate.latitude//Double(BookingInfo.object(forKey: "PickupLat") as! String)!
        Singletons.sharedInstance.startedTripLongitude = self.defaultLocation.coordinate.longitude//Double(BookingInfo.object(forKey: "PickupLng") as! String)!
        
        
        //        self.lblLocationOnMap.text = BookingInfo.object(forKey: "DropoffLocation") as? String
        
        let PickupLat = self.defaultLocation.coordinate.latitude
        let PickupLng = self.defaultLocation.coordinate.longitude
        
        let dummyLatitude = Double(PickupLat) - (Double(DropOffLat) ?? Double(0))
        let dummyLongitude = Double(PickupLng) - (Double(DropOffLon) ?? Double(0))
        
        let waypointLatitude = self.defaultLocation.coordinate.latitude - dummyLatitude
        let waypointSetLongitude = self.defaultLocation.coordinate.longitude - dummyLongitude
        
        let originalLoc: String = "\(PickupLat),\(PickupLng)"
        let destiantionLoc: String = "\(DropOffLat),\(DropOffLon)"
        
        zoomoutCamera(PickupLat: PickupLat, PickupLng: PickupLng, DropOffLat: DropOffLat, DropOffLon: DropOffLon)
        
        self.getDirectionsSeconMethod(origin: originalLoc, destination: destiantionLoc, waypoints: ["\(waypointLatitude),\(waypointSetLongitude)"], travelMode: nil, completionHandler: nil)
        
    }
    
    func getDistanceForPickupPassengerFromLocation() {
        
        var BookingInfo = NSDictionary()
        
        if let aryPsgData = self.aryPassengerData as? NSArray {
            if let psgData = aryPsgData.firstObject as? NSDictionary {
                
                let bInfo = psgData.object(forKey: "BookingInfo") as? NSDictionary
                
                if bInfo == nil {
                    // print ("Yes its  array ")
                    
                    if let aryBInfo = psgData.object(forKey: "BookingInfo") as? NSArray {
                        if let firstObjDict = aryBInfo.firstObject as? NSDictionary {
                            BookingInfo = firstObjDict
                        }
                        else {
                            return
                        }
                    }
                    else {
                        return
                    }
                }
                else {
                    // print (Yes its dictionary")
                    
                    let bInfo = psgData.object(forKey: "BookingInfo") as? NSDictionary
                    
                    if bInfo != nil {
                        BookingInfo = psgData.object(forKey: "BookingInfo") as! NSDictionary
                    }
                    else {
                        return
                    }
                }
                
                // ------------------------------------------------------------
                
                //        SingletonsForMeter.sharedInstance.vehicleModelID = (Int(BookingInfo.object(forKey: "ModelId") as! NSNumber))
                
                var VehicleID = String()
                
                if let vehId = BookingInfo.object(forKey: "ModelId") as? String {
                    VehicleID = vehId
                }
                else if let vehId = BookingInfo.object(forKey: "ModelId") as? Int {
                    VehicleID = "\(vehId)"
                }
                
                SingletonsForMeter.sharedInstance.vehicleModelID = Int(VehicleID)!
                
                let DropOffLat = BookingInfo.object(forKey: "PickupLat") as! String
                let DropOffLon = BookingInfo.object(forKey: "PickupLng") as! String
                
                Singletons.sharedInstance.startedTripLatitude = Double(BookingInfo.object(forKey: "PickupLat") as! String)!
                Singletons.sharedInstance.startedTripLongitude = Double(BookingInfo.object(forKey: "PickupLng") as! String)!
                
                //                self.lblLocationOnMap.text = BookingInfo.object(forKey: "DropoffLocation") as? String
                
                let PickupLat = self.defaultLocation.coordinate.latitude
                let PickupLng = self.defaultLocation.coordinate.longitude
                
                let dummyLatitude = Double(PickupLat) - Double(DropOffLat)!
                let dummyLongitude = Double(PickupLng) - Double(DropOffLon)!
                
                let waypointLatitude = self.defaultLocation.coordinate.latitude - dummyLatitude
                let waypointSetLongitude = self.defaultLocation.coordinate.longitude - dummyLongitude
                
                
                let originalLoc: String = "\(PickupLat),\(PickupLng)"
                let destiantionLoc: String = "\(DropOffLat),\(DropOffLon)"
                
                
                //        self.getDirectionsSeconMethod(origin: originalLoc, destination: destiantionLoc, waypoints: ["\(waypointLatitude),\(waypointSetLongitude)"], travelMode: nil, completionHandler: nil)
                //
                self.getPassengerLocationDistance(origin: originalLoc, destination: destiantionLoc, waypoints: ["\(waypointLatitude),\(waypointSetLongitude)"], travelMode: nil, completionHandler: nil)
            }
        }
        
        
    }
    
    //-------------------------------------------------------------
    // MARK: - Prepare For Segue
    //-------------------------------------------------------------
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ReceiveRequestViewController {
            destination.delegate = self
        }
        else if let moveToPassenger = segue.destination as? PassengerInfoViewController {
            
            moveToPassenger.strPickupLocation = self.strPickupLocation
            moveToPassenger.strDropoffLocation = self.strDropoffLocation
            moveToPassenger.homeVC = self
            moveToPassenger.strPassengerName =  self.strPassengerName
            moveToPassenger.strPassengerMobileNumber =  self.strPassengerMobileNo
        }
        else if let moveToTripInfo = segue.destination as? RatingViewController {
            
            moveToTripInfo.delegate = self
            
            let getBookingAndPassengerInfo = self.getBookingAndPassengerInfo(data: self.aryPassengerData)
            
            let PassengerInfo = getBookingAndPassengerInfo.1
            
            //            if isAdvanceBooking {
            //                if bookingID == "" {
            //                     moveToTripInfo.strBookingType = "BookLater"
            //                }
            //            }
            //            else {
            //                if advanceBookingID == "" {
            //
            //                }
            //            }
            
            if (Singletons.sharedInstance.oldBookingType.isBookLater || (isAdvanceBooking == true && bookingID == "") ) {
                moveToTripInfo.strBookingType = "BookLater"
            }
            else {
                moveToTripInfo.strBookingType = "BookNow"
            }
            
            
            //           moveToTripInfo.strBookingType = "BookNow"
            //            if(isAdvanceBooking)
            //            {
            //                moveToTripInfo.strBookingType = "BookLater"
            //            }
            //
            moveToTripInfo.dictData = self.dictCompleteTripData
            moveToTripInfo.dictPassengerInfo = PassengerInfo
        }
        else if let moveToMeter = segue.destination as? MeterViewController {
            
            moveToMeter.isFromHome = true
        }
    }
    
    
    //-------------------------------------------------------------
    // MARK: - ARCar Movement Delegate Method
    //-------------------------------------------------------------
    func ARCarMovementMoved(_ Marker: GMSMarker) {
        
        self.driverMarker = nil
        driverMarker = Marker
        driverMarker.map = mapView
    }
    
    
    //-------------------------------------------------------------
    // MARK: - Route on Map Methods
    //-------------------------------------------------------------
    
    func getDirectionsSeconMethod(origin: String!, destination: String!, waypoints: Array<String>!, travelMode: AnyObject!, completionHandler: ((_ status:   String, _ success: Bool) -> Void)?) {
        
        UtilityClass.hideACProgressHUD()
        mapView.clear()
        DispatchQueue.main.async {
            UtilityClass.showACProgressHUD()
            //            print("Function: \(#function), line: \(#line)")
            
        }
        
        //        UtilityClass.showAlert(appName.kAPPName, message: "Map View Called", vc: self)
        
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            
            if let originLocation = origin {
                //                if let destinationLocation = destination {
                //                    var directionsURLString = self.baseURLDirections + "origin=" + originLocation + "&destination=" + destinationLocation + "&key=" + googlApiKey
                //                    if let routeWaypoints = waypoints {
                //                        directionsURLString += "&waypoints=optimize:true"
                //
                //                        for waypoint in routeWaypoints {
                //                            directionsURLString += "|" + waypoint
                //                        }
                //                    }
                //                    print ("directionsURLString: \(directionsURLString)")
                //                    //                    directionsURLString = directionsURLString.addingPercentEscapes(using: String.Encoding.utf8)!
                //                    directionsURLString = directionsURLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                //                    let directionsURL = NSURL(string: directionsURLString)
                
                if let destinationLocation = destination {
                    var directionsURLString = self.baseURLDirections + "origin=" + originLocation + "&destination=" + destinationLocation + "&key=" + googlApiKey//kGoogleAPIKEY
                    //                        if let routeWaypoints = waypoints {
                    //                            directionsURLString += "&waypoints=optimize:true"
                    //
                    //                            for waypoint in routeWaypoints {
                    //                                directionsURLString += "|" + waypoint
                    //                            }
                    //                        }
                    print ("directionsURLString: \(directionsURLString)")
                    //                    directionsURLString = directionsURLString.addingPercentEscapes(using: String.Encoding.utf8)!
                    directionsURLString = directionsURLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                    let directionsURL = NSURL(string: directionsURLString)
                    DispatchQueue.main.async( execute: { () -> Void in
                        let directionsData = NSData(contentsOf: directionsURL! as URL)
                        
                        //                        if directionsData == nil {
                        //                            self.pickupPassengerFromLocation()
                        //                        }
                        
                        do{
                            let dictionary: Dictionary<String, AnyObject> = try JSONSerialization.jsonObject(with: directionsData! as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<String, AnyObject>
                            
                            let status = dictionary["status"] as! String
                            
                            if status == "OK" {
                                self.selectedRoute = (dictionary["routes"] as! Array<Dictionary<String, AnyObject>>)[0]
                                self.overviewPolyline = self.selectedRoute["overview_polyline"] as! Dictionary<String, AnyObject>
                                
                                let legs = self.selectedRoute["legs"] as! Array<Dictionary<String, AnyObject>>
                                
                                let startLocationDictionary = legs[0]["start_location"] as! Dictionary<String, AnyObject>
                                self.originCoordinate = CLLocationCoordinate2DMake(startLocationDictionary["lat"] as! Double, startLocationDictionary["lng"] as! Double)
                                
                                let endLocationDictionary = legs[legs.count - 1]["end_location"] as! Dictionary<String, AnyObject>
                                self.destinationCoordinate = CLLocationCoordinate2DMake(endLocationDictionary["lat"] as! Double, endLocationDictionary["lng"] as! Double)
                                
                                _ = legs[0]["start_address"] as! String
                                let destinationAddress = legs[legs.count - 1]["end_address"] as! String
                                
                                
                                if(self.driverMarker == nil) {
                                    self.driverMarker = GMSMarker(position: self.originCoordinate)
                                    //                                    self.driverMarker.position = self.originCoordinate
                                    self.driverMarker.icon = UIImage(named: Singletons.sharedInstance.strSetCar)
                                    //                                        self.driverMarker.map = self.mapView
                                }
                                
                                self.driverMarker.icon = UIImage(named: Singletons.sharedInstance.strSetCar)
                                //                                }
                                //                                 else
                                //                                {
                                //                                    let originMarker = GMSMarker(position: self.originCoordinate)
                                //                                    originMarker.map = self.mapView
                                //                                    originMarker.icon = UIImage(named: Singletons.sharedInstance.strSetCar)
                                //                                    originMarker.title = originAddress
                                //                                }
                                
                                let destinationMarker = GMSMarker(position: self.destinationCoordinate)
                                destinationMarker.map = self.mapView
                                destinationMarker.icon = UIImage.init(named: "iconMapPin")
                                destinationMarker.title = destinationAddress
                                
                                var aryDistance = [Double]()
                                var finalDistance = Double()
                                
                                for i in 0..<legs.count
                                {
                                    let legsData = legs[i]
                                    let distanceKey = legsData["distance"] as! Dictionary<String, AnyObject>
                                    let distance = distanceKey["text"] as! String
                                    let stringDistance = distance.components(separatedBy: " ")
                                    
                                    //                                    print("stringDistance : \(stringDistance)")
                                    
                                    if stringDistance[1] == "m" {
                                        finalDistance += Double(stringDistance[0])! / 1000
                                    }
                                    else {
                                        finalDistance += Double(stringDistance[0].replacingOccurrences(of: ",", with: ""))!
                                    }
                                    aryDistance.append(finalDistance)
                                }
                                
                                
                                print("aryDistance : \(aryDistance)")
                                
                                if finalDistance == 0 {
                                    //                                    UtilityClass.showAlert(appName.kAPPName, message: "Distance is 0 by not countable distance", vc: self)
                                    
                                }
                                else {
                                    self.sumOfFinalDistance = finalDistance
                                }
                                
                                let route = self.overviewPolyline["points"] as! String
                                self.arrivedRoutePath = GMSPath(fromEncodedPath: route)!
                                let path: GMSPath = GMSPath(fromEncodedPath: route)!
                                let routePolyline = GMSPolyline(path: path)
                                routePolyline.map = self.mapView
                                routePolyline.strokeColor = themeYellowColor// UIColor.init(red: 44, green: 134, blue: 200, alpha: 1.0)
                                routePolyline.strokeWidth = 3.0
                                //                                UtilityClass.hideACProgressHUD()
                                print("line draw : \(#line) function name : \(#function)")
                            }
                            else {
                                DispatchQueue.main.async {
                                    UtilityClass.hideACProgressHUD()
                                    //                                    print("Function: \(#function), line: \(#line)")
                                    
                                }
                                //                                (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.dismiss(animated: true, completion: {
                                //
                                //                                    //                                    UtilityClass.showAlert(appName.kAPPName, message: "Not able to get location due to free api key please restart app", vc: self)
                                //                                })
                                //
                                
                                //                                self.pickupPassengerFromLocation()
                                // UtilityClass.showAlert(appName.kAPPName, message: "OVER_QUERY_LIMIT", vc: self)
                                print("OVER_QUERY_LIMIT Line number : \(#line) function name : \(#function)")
                                
                                UtilityClass.hideACProgressHUD()
                                
                                //completionHandler(status: status, success: false)
                            }
                        }
                        catch {
                            print("Catch Not able to get location due to free api key please restart app")
                            //                            UtilityClass.showAlert(appName.kAPPName, message: "Not able to get location due to free api key please restart app", vc: self)
                            // completionHandler(status: "", success: false)
                            //                            self.pickupPassengerFromLocation()
                            DispatchQueue.main.async {
                                UtilityClass.hideACProgressHUD()
                                //                                print("Function: \(#function), line: \(#line)")
                                
                            }
                        }
                        
                        DispatchQueue.main.async {
                            UtilityClass.hideACProgressHUD()
                            //                            print("Function: \(#function), line: \(#line)")
                        }
                    })
                }
                else {
                    print  ("Destination is nil.")
                    //                    UtilityClass.showAlert(appName.kAPPName, message: "Destination is nil.", vc: self)
                    DispatchQueue.main.async {
                        UtilityClass.hideACProgressHUD()
                        //                        print("Function: \(#function), line: \(#line)")
                        
                    }
                    //completionHandler(status: "Destination is nil.", success: false)
                }
            }
            else {
                print  ("Origin is nil")
                //                UtilityClass.showAlert(appName.kAPPName, message: "Origin is nil.", vc: self)
                DispatchQueue.main.async {
                    UtilityClass.hideACProgressHUD()
                    //                    print("Function: \(#function), line: \(#line)")
                    
                }
                //completionHandler(status: "Origin is nil", success: false)
            }
            
        }
        
    }
    
    func getDirectionsCompleteTripInfo(origin: String!, destination: String!, waypoints: Array<String>!, travelMode: AnyObject!, completionHandler: ((_ status:   String, _ success: Bool) -> Void)?) {
        
        
        DispatchQueue.main.async {
            UtilityClass.showACProgressHUD()
            //            print("Function: \(#function), line: \(#line)")
            
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            
            if let originLocation = origin {
                if let destinationLocation = destination {
                    var directionsURLString = self.baseURLDirections + "origin=" + originLocation + "&destination=" + destinationLocation
                    //                    if let routeWaypoints = waypoints {
                    //                        directionsURLString += "&waypoints=optimize:true"
                    //
                    //                        for waypoint in routeWaypoints {
                    //                            directionsURLString += "|" + waypoint
                    //                        }
                    //                    }
                    //                    print ("directionsURLString: \(directionsURLString)")
                    //                    directionsURLString = directionsURLString.addingPercentEscapes(using: String.Encoding.utf8)!
                    directionsURLString = directionsURLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                    let directionsURL = NSURL(string: directionsURLString)
                    DispatchQueue.main.async( execute: { () -> Void in
                        let directionsData = NSData(contentsOf: directionsURL! as URL)
                        
                        if directionsURL != nil {
                            
                            do{
                                let dictionary: Dictionary<String, AnyObject> = try JSONSerialization.jsonObject(with: directionsData! as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<String, AnyObject>
                                
                                let status = dictionary["status"] as! String
                                
                                if status == "OK" {
                                    self.selectedRoute = (dictionary["routes"] as! Array<Dictionary<String, AnyObject>>)[0]
                                    self.overviewPolyline = self.selectedRoute["overview_polyline"] as! Dictionary<String, AnyObject>
                                    
                                    let legs = self.selectedRoute["legs"] as! Array<Dictionary<String, AnyObject>>
                                    
                                    let startLocationDictionary = legs[0]["start_location"] as! Dictionary<String, AnyObject>
                                    self.originCoordinate = CLLocationCoordinate2DMake(startLocationDictionary["lat"] as! Double, startLocationDictionary["lng"] as! Double)
                                    
                                    let endLocationDictionary = legs[legs.count - 1]["end_location"] as! Dictionary<String, AnyObject>
                                    self.destinationCoordinate = CLLocationCoordinate2DMake(endLocationDictionary["lat"] as! Double, endLocationDictionary["lng"] as! Double)
                                    
                                    var aryDistance = [String]()
                                    var finalDistance = Double()
                                    
                                    for i in 0..<legs.count
                                    {
                                        let legsData = legs[i]
                                        let distanceKey = legsData["distance"] as! Dictionary<String, AnyObject>
                                        let distance = distanceKey["text"] as! String
                                        let stringDistance = distance.components(separatedBy: " ")
                                        
                                        if stringDistance[1] == "m" {
                                            finalDistance += Double(stringDistance[0])! / 1000
                                        }
                                        else {
                                            finalDistance += Double(stringDistance[0].replacingOccurrences(of: ",", with: ""))!
                                        }
                                        aryDistance.append(distance)
                                    }
                                    
                                    if finalDistance == 0 {
                                        UtilityClass.showAlert("App Name".localized, message: "Distance is 0 by not countable distance", vc: self)
                                        
                                    }
                                    else {
                                        self.sumOfFinalDistance = finalDistance
                                        DispatchQueue.main.async {
                                            //                                        UtilityClass.hideACProgressHUD()
                                            //                                            self.completeTripFinalSubmit()
                                            self.getLastAddressForLatLng(DropOffAddress: (self.lastLocation != nil) ? self.lastLocation : self.defaultLocation)
                                            //                                            print("Function: \(#function), line: \(#line)")
                                            
                                        }
                                        
                                    }
                                    
                                }
                                else {
                                    
                                    (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.dismiss(animated: true, completion: {
                                        
                                        //                                    UtilityClass.showAlert(appName.kAPPName, message: "Not able to get location due to free api key please restart app", vc: self)
                                        DispatchQueue.main.async {
                                            UtilityClass.hideACProgressHUD()
                                            //                                            print("Function: \(#function), line: \(#line)")
                                            
                                        }
                                    })
                                    
                                    //
                                    //                                UtilityClass.showAlert(appName.kAPPName, message: "OVER_QUERY_LIMIT", vc: self)
                                    print("OVER_QUERY_LIMIT Line number : \(#line) function name : \(#function)")
                                    //                                    self.pickupPassengerFromLocation()
                                    DispatchQueue.main.async {
                                        UtilityClass.hideACProgressHUD()
                                        //                                        print("Function: \(#function), line: \(#line)")
                                        
                                    }
                                    
                                }
                            }
                            catch {
                                //                            print("Catch Not able to get location due to free api key please restart app")
                                //                            UtilityClass.showAlert(appName.kAPPName, message: "Not able to get location due to free api key please restart app", vc: self)
                                print("Function: \(#function), line: \(#line) Not able to get location due to free api key please restart app")
                                //                                self.pickupPassengerFromLocation()
                                
                            }
                        }
                        
                    })
                }
                else {
                    print  ("Destination is nil.")
                    UtilityClass.showAlert("App Name".localized, message: "Destination is nil.", vc: self)
                    DispatchQueue.main.async {
                        DispatchQueue.main.async {
                            UtilityClass.hideACProgressHUD()
                            //                            print("Function: \(#function), line: \(#line)")
                            
                        }
                        //                        print("Function: \(#function), line: \(#line)")
                        
                    }
                }
            }
            else {
                print  ("Origin is nil")
                UtilityClass.showAlert("App Name".localized, message: "Origin is nil.", vc: self)
                DispatchQueue.main.async {
                    UtilityClass.hideACProgressHUD()
                    //                    print("Function: \(#function), line: \(#line)")
                    
                }
            }
        }
    }
    
    // Get Passenger Location Distance
    func getPassengerLocationDistance(origin: String!, destination: String!, waypoints: Array<String>!, travelMode: AnyObject!, completionHandler: ((_ status:   String, _ success: Bool) -> Void)?) {
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            
            if let originLocation = origin {
                if let destinationLocation = destination {
                    var directionsURLString = self.baseURLDirections + "origin=" + originLocation + "&destination=" + destinationLocation
                    //                    if let routeWaypoints = waypoints {
                    //                        directionsURLString += "&waypoints=optimize:true"
                    //
                    //                        for waypoint in routeWaypoints {
                    //                            directionsURLString += "|" + waypoint
                    //                        }
                    //                    }
                    
                    directionsURLString = directionsURLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                    let directionsURL = NSURL(string: directionsURLString)
                    DispatchQueue.main.async( execute: { () -> Void in
                        let directionsData = NSData(contentsOf: directionsURL! as URL)
                        
                        if directionsData != nil {
                            do{
                                let dictionary: Dictionary<String, AnyObject> = try JSONSerialization.jsonObject(with: directionsData! as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<String, AnyObject>
                                
                                let status = dictionary["status"] as! String
                                
                                if status == "OK" {
                                    self.selectedRoute = (dictionary["routes"] as! Array<Dictionary<String, AnyObject>>)[0]
                                    self.overviewPolyline = self.selectedRoute["overview_polyline"] as! Dictionary<String, AnyObject>
                                    
                                    let legs = self.selectedRoute["legs"] as! Array<Dictionary<String, AnyObject>>
                                    
                                    let startLocationDictionary = legs[0]["start_location"] as! Dictionary<String, AnyObject>
                                    self.originCoordinate = CLLocationCoordinate2DMake(startLocationDictionary["lat"] as! Double, startLocationDictionary["lng"] as! Double)
                                    
                                    let endLocationDictionary = legs[legs.count - 1]["end_location"] as! Dictionary<String, AnyObject>
                                    self.destinationCoordinate = CLLocationCoordinate2DMake(endLocationDictionary["lat"] as! Double, endLocationDictionary["lng"] as! Double)
                                    
                                    var aryDistance = [Double]()
                                    var finalDistance = Double()
                                    
                                    for i in 0..<legs.count
                                    {
                                        let legsData = legs[i]
                                        let distanceKey = legsData["distance"] as! Dictionary<String, AnyObject>
                                        let distance = distanceKey["text"] as! String
                                        let stringDistance = distance.components(separatedBy: " ")
                                        
                                        if stringDistance[1] == "m" {
                                            finalDistance += Double(stringDistance[0])! / 1000
                                        }
                                        else {
                                            finalDistance += Double(stringDistance[0].replacingOccurrences(of: ",", with: ""))!
                                        }
                                        aryDistance.append(finalDistance)
                                    }
                                    
                                    if aryDistance.count != 0 {
                                        
                                        if self.driverMarker != nil {
                                            if aryDistance.count == 1 {
                                                self.driverMarker.title = "Distance: \(aryDistance.first!) M"
                                            }
                                            else if aryDistance.reduce(0,+) <= 1 {
                                                self.driverMarker.title = "Distance: \(aryDistance.reduce(0,+)) M"
                                            } else {
                                                self.driverMarker.title = "Distance: \(aryDistance.reduce(0,+)) KM"
                                            }
                                        }
                                    }
                                }
                                else {
                                    
                                    //                                    self.getDistanceForPickupPassengerFromLocation()
                                    //                            self.getPassengerLocationDistance(origin: origin, destination: destination, waypoints: waypoints, travelMode: travelMode, completionHandler: completionHandler)
                                    
                                }
                            }
                            catch {
                                //                                self.getDistanceForPickupPassengerFromLocation()
                                //                          self.getPassengerLocationDistance(origin: origin, destination: destination, waypoints: waypoints, travelMode: travelMode, completionHandler: completionHandler)
                                
                            }
                        }
                        
                        
                    })
                }
                else {
                    print  ("Destination is nil.")
                    //                    self.getDistanceForPickupPassengerFromLocation()
                    //                self.getPassengerLocationDistance(origin: origin, destination: destination, waypoints: waypoints, travelMode: travelMode, completionHandler: completionHandler)
                }
            }
            else {
                print  ("Origin is nil")
                //                self.getDistanceForPickupPassengerFromLocation()
                //                self.getPassengerLocationDistance(origin: origin, destination: destination, waypoints: waypoints, travelMode: travelMode, completionHandler: completionHandler)
            }
        }
    }
    
    func reRoute(DriverCordinate: CLLocationCoordinate2D)
    {
        self.mapView.clear()

        if self.driverMarker == nil {
            self.driverMarker = GMSMarker(position: DriverCordinate)
            driverMarker.tracksViewChanges = false
            self.driverMarker.map = self.mapView
            self.driverMarker.icon = UIImage(named: "dummyCar")
        }

        if(Singletons.sharedInstance.dictDriverProfile.count != 0) {
            
            var dropOffCoordinate = CLLocationCoordinate2D()
            var dictDataOfBookingInfo = NSDictionary()
            
           if let dictDataOfBookingInfo2 = (((self.aryPassengerData as NSArray).object(at: 0) as? NSDictionary)?.object(forKey: "BookingInfo") as? NSArray)?.firstObject as? NSDictionary
            {
               dictDataOfBookingInfo = dictDataOfBookingInfo2
           }
            else if let dictDataOfBookingInfo2 = ((self.aryPassengerData as NSArray).object(at: 0) as? NSDictionary)?.object(forKey: "BookingInfo") as? NSDictionary
            {
                dictDataOfBookingInfo = dictDataOfBookingInfo2
            }
            
            let status = (dictDataOfBookingInfo.object(forKey: "Status") as? String ?? "")
            let dropSecondLat = Double("\(dictDataOfBookingInfo.object(forKey: "DropOffLat2") as? String ?? "")")
            let dropSecondLng = Double("\(dictDataOfBookingInfo.object(forKey: "DropOffLon2") as? String ?? "")")

            if ((status == "pending" || status == "accepted") && Singletons.sharedInstance.isTripContinue == false)
            {
                let pickupLat = Double("\(dictDataOfBookingInfo.object(forKey: "PickupLat") as? String ?? "")")
                let pickupLng = Double("\(dictDataOfBookingInfo.object(forKey: "PickupLng") as? String ?? "")")
                
                dropOffCoordinate = CLLocationCoordinate2D(latitude: pickupLat ?? 0.0, longitude: pickupLng ?? 0.0)
            }
            else if(Singletons.sharedInstance.isTripContinue == true && self.btnReached.isHidden == false && (dropSecondLat != 0.0 && dropSecondLng != 0.0))
            {
                let dropFirstLat = Double("\(dictDataOfBookingInfo.object(forKey: "DropOffLat") as? String ?? "")")
                let dropFirstLng = Double("\(dictDataOfBookingInfo.object(forKey: "DropOffLon") as? String ?? "")")
                
                dropOffCoordinate = CLLocationCoordinate2D(latitude: dropFirstLat ?? 0.0, longitude: dropFirstLng ?? 0.0)
            }
            else if (dropSecondLat != 0.0 && dropSecondLng != 0.0)
            {
                let dropFirstLat = Double("\(dictDataOfBookingInfo.object(forKey: "DropOffLat2") as? String ?? "")")
                let dropFirstLng = Double("\(dictDataOfBookingInfo.object(forKey: "DropOffLon2") as? String ?? "")")
                
                dropOffCoordinate = CLLocationCoordinate2D(latitude: dropFirstLat ?? 0.0, longitude: dropFirstLng ?? 0.0)

            }
            else
            {
                let dropFirstLat = Double("\(dictDataOfBookingInfo.object(forKey: "DropOffLat") as? String ?? "")")
                let dropFirstLng = Double("\(dictDataOfBookingInfo.object(forKey: "DropOffLon") as? String ?? "")")
                
                dropOffCoordinate = CLLocationCoordinate2D(latitude: dropFirstLat ?? 0.0, longitude: dropFirstLng ?? 0.0)

            }
            let PickupLat = DriverCordinate.latitude  // Double("\(strLat )")
            let PickupLng = DriverCordinate.longitude // Double("\(strLng )")

            let DropOffLat = dropOffCoordinate.latitude
            let DropOffLon = dropOffCoordinate.longitude
            
//            let tempLat = Double("\(aryFilterData.first?["PickupLat"]! ?? "0")")
//            let tempLon = Double("\(aryFilterData.first?["PickupLng"]! ?? "0")")

            let originalLoc: String = "\(PickupLat ),\(PickupLng)"
            var destiantionLoc: String = "\(DropOffLat ),\(DropOffLon)"

            if !Singletons.sharedInstance.isTripContinue {
                destiantionLoc = "\(DropOffLat),\(DropOffLon)"
            }
            

            let bounds = GMSCoordinateBounds(coordinate: CLLocationCoordinate2D(latitude: PickupLat , longitude: PickupLng ), coordinate: CLLocationCoordinate2D(latitude: DropOffLat, longitude: DropOffLon))
            let update = GMSCameraUpdate.fit(bounds, withPadding: CGFloat(zoomLevel))

            self.mapView.animate(with: update)
            self.mapView.moveCamera(update)

            DispatchQueue.main.async {
                self.getDirectionsSeconMethod(origin: originalLoc, destination: destiantionLoc, waypoints: nil, travelMode: nil, completionHandler: nil)
                    
//                if Singletons.sharedInstance.isTripContinue {
//                    self.getPassengerLocationDistance(origin: originalLoc, destination: destiantionLoc, waypoints: nil, travelMode: nil, completionHandler: nil)
//                } else {
//                    self.getPassengerLocationDistance(origin: originalLoc, destination: destiantionLoc, waypoints: nil, travelMode: nil, completionHandler: nil)
//                }
            }
        }

        // ***********************************************
        // ***********************************************
    }
    
    // ----------------------------------------------------------------------
    //-------------------------------------------------------------
    // MARK: - Set Car
    //-------------------------------------------------------------
    
    
    func setCar()
    {
        let profile: NSMutableDictionary = NSMutableDictionary(dictionary: (Singletons.sharedInstance.dictDriverProfile.object(forKey: "profile") as? NSDictionary)!)
        let Vehicle: NSMutableDictionary = NSMutableDictionary(dictionary: profile.object(forKey: "Vehicle") as! NSDictionary)
        let VehicleName = Vehicle.object(forKey: "VehicleClass") as! String
        
        if VehicleName.range(of:"First Class") != nil
        {
            print("First Class")
            //Singletons.sharedInstance.strSetCar = "imgFirstClass"
        }
        else if (VehicleName.range(of:"Business Class") != nil) {
            print("First Class")
            // Singletons.sharedInstance.strSetCar = "imgBusinessClass"
            
        }
        else if (VehicleName.range(of:"Economy") != nil) {
            print("First Class")
            // Singletons.sharedInstance.strSetCar = "imgEconomy"
            
        }
        else if (VehicleName.range(of:"Taxi") != nil) {
            print("First Class")
            // Singletons.sharedInstance.strSetCar = "imgTaxi"
            
        }
        else if (VehicleName.range(of:"LUX-VAN") != nil) {
            print("First Class")
            // Singletons.sharedInstance.strSetCar = "imgLUXVAN"
            
        }
        else if (VehicleName.range(of:"Disability") != nil) {
            print("First Class")
            //Singletons.sharedInstance.strSetCar = "imgDisability"
            
        }
        Singletons.sharedInstance.strSetCar = "imgTaxi"//"dummyCar"
        
        print(VehicleName)
    }
    
    func markerCarIconName(modelId: Int) -> String {
        
        var CarModel = String()
        
        switch modelId {
        case 1:
            CarModel = "imgBusinessClass"
            return CarModel
        case 2:
            CarModel = "imgDisability"
            return CarModel
        case 3:
            CarModel = "imgTaxi"
            return CarModel
        case 4:
            CarModel = "imgFirstClass"
            return CarModel
        case 5:
            CarModel = "imgLUXVAN"
            return CarModel
        case 6:
            CarModel = "imgEconomy"
            return CarModel
        default:
            CarModel = Singletons.sharedInstance.strSetCar
            return CarModel
        }
        
    }
    
    func didRatingIsSubmitSuccessfully() {
        
        if driverID != "" {
            UpdateDriverLocation()
        }
        
        if (Singletons.sharedInstance.isPending == 1) {
            webserviceOfCurrentBooking()
        }
        
        Singletons.sharedInstance.bookingIdTemp = ""
        Singletons.sharedInstance.advanceBookingIdTemp = ""
        Singletons.sharedInstance.bookingId = ""
        Singletons.sharedInstance.advanceBookingId = ""
        if self.driverMarker != nil {
            self.driverMarker.title = ""
        }
        bookingID = ""
        advanceBookingID = ""
        self.aryPassengerData = NSArray()
        self.aryCurrentBookingData = NSMutableArray()
        
        
    }
    
    //-------------------------------------------------------------
    // MARK: - Setup Current Location
    //-------------------------------------------------------------
    
    let baseUrlForGetAddress = "https://maps.googleapis.com/maps/api/geocode/json?"
    let apikey = googlPlacesApiKey
    
    
    func getAddressForLatLng(latitude:String, Longintude:String) {
        //        self.StartingPointLatitude = Double(latitude)!
        //        self.StartingPointLongitude = Double(Longintude)!
        
        let location = CLLocation(latitude: Double(latitude)!, longitude: Double(Longintude)!)
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            self.processResponse(withPlacemarks: placemarks, error: error)
        }
        
    }
    
    private func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
        // Update View
        if let error = error {
            print("Unable to Reverse Geocode Location (\(error))")
            //            lblStartPoint.text = "Unable to Find Address for Location"
            
        } else {
            if let placemarks = placemarks, let placemark = placemarks.first {
                var addressString:String = ""
                if let Address = placemark.addressDictionary as? [String:Any] {
                    addressString =  (Address["FormattedAddressLines"] as! [String]).joined(separator: ", ")
                }
                else {
                    if let SubLocality = placemark.subLocality, let City = placemark.locality, let State = placemark.administrativeArea, let Postalcode = placemark.postalCode , let country = placemark.country {
                        addressString = "\(SubLocality), \(City), \(State) \(Postalcode), \(country)"
                    }
                }
                self.lblLocationOnMap.text = addressString
            } else {
                //                lblStartPoint.text = "No Address Found"
            }
        }
    }
    
    
    func getLastAddressForLatLng(DropOffAddress:CLLocation) {
        //        self.StartingPointLatitude = Double(latitude)!
        //        self.StartingPointLongitude = Double(Longintude)!
        
        //        let location = CLLocation(latitude: Double(latitude)!, longitude: Double(Longintude)!)
        geocoder.reverseGeocodeLocation(DropOffAddress) { (placemarks, error) in
            self.processDropOffLocationResponse(withPlacemarks: placemarks, error: error)
        }
        
    }
    
    private func processDropOffLocationResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
        // Update View
        if let error = error {
            print("Unable to Reverse Geocode Location (\(error))")
            //            lblStartPoint.text = "Unable to Find Address for Location"
            
        } else {
            if let placemarks = placemarks, let placemark = placemarks.first {
                var addressString:String = ""
                if let Address = placemark.addressDictionary as? [String:Any] {
                    addressString =  (Address["FormattedAddressLines"] as! [String]).joined(separator: ", ")
                }
                else {
                    if let SubLocality = placemark.subLocality, let City = placemark.locality, let State = placemark.administrativeArea, let Postalcode = placemark.postalCode , let country = placemark.country {
                        addressString = "\(SubLocality), \(City), \(State) \(Postalcode), \(country)"
                    }
                }
                print("Got DropOff location:- \(addressString)")
                self.completeTripFinalSubmit(LastAddress: addressString)
            } else {
                //                lblStartPoint.text = "No Address Found"
            }
        }
    }
    
    
    
    
    //    func getAddressForLatLng(latitude: String, longitude: String) {
    //
    //
    //        let url = NSURL(string: "\(baseUrlForGetAddress)latlng=\(latitude),\(longitude)&key=\(apikey)")
    //        do {
    //            let data = NSData(contentsOf: url! as URL)
    //            if data != nil {
    //                if let json = try! JSONSerialization.jsonObject(with: data! as Data, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary {
    //                    if let result = json["results"] as? [[String:AnyObject]] {
    //                        if result.count > 0 {
    //                            if let address = result[0]["address_components"] as? [[String:AnyObject]] {
    //
    //                                if address.count > 1 {
    //
    //                                    var streetNumber = String()
    //                                    var streetStreet = String()
    //                                    var streetCity = String()
    //                                    var streetState = String()
    //
    //                                    for i in 0..<address.count {
    //
    //                                        if i == 0 {
    //                                            if let number = address[i]["short_name"] as? String {
    //                                                streetNumber = number
    //                                            }
    //                                        }
    //                                        else if i == 1 {
    //                                            if let street = address[i]["short_name"] as? String {
    //                                                streetStreet = street
    //                                            }
    //                                        }
    //                                        else if i == 2 {
    //                                            if let city = address[i]["short_name"] as? String {
    //                                                streetCity = city
    //                                            }
    //                                        }
    //                                        else if i == 3 {
    //                                            if let state = address[i]["short_name"] as? String {
    //                                                streetState = state
    //                                            }
    //                                        }
    //                                        else if i == 4 {
    //                                            if let city = address[i]["short_name"] as? String {
    //                                                streetCity = city
    //                                            }
    //                                        }
    //                                    }
    //
    //                                    print("\n\(streetNumber) \(streetStreet), \(streetCity), \(streetState)")
    //
    //                                    self.lblLocationOnMap.text = "\(streetNumber) \(streetStreet), \(streetCity), \(streetState)"
    //
    //                                }
    //                            }
    //                        }
    //                    }
    //                }
    //
    //            }
    //        }
    //        catch {
    //            print("Not Geting Address")
    //        }
    //    }
    
    
    var dictCurrentBookingInfoData = NSDictionary()
    var dictCurrentPassengerInfoData = NSDictionary()
    var aryCurrentBookingData = NSMutableArray()
    
    var checkBookingType = String()
    
    //-------------------------------------------------------------
    // MARK: - Webservice Methods For Check Current Booking
    //-------------------------------------------------------------
    func webserviceOfCurrentBooking() {
        
        if let Token = UserDefaults.standard.object(forKey: "Token") as? String {
            Singletons.sharedInstance.deviceToken = Token
        }
        
        if self.driverID != "" && self.defaultLocation.coordinate.latitude != 0 && self.defaultLocation.coordinate.longitude != 0 {
            self.UpdateDriverLocation()
        }
        
        let param = Singletons.sharedInstance.strDriverID + "/" + Singletons.sharedInstance.deviceToken
        webserviceForCurrentBooking(param as AnyObject) { (result, status) in
            
            if (status) {
                Singletons.sharedInstance.driverDuty = "1"
                UserDefaults.standard.set(Singletons.sharedInstance.driverDuty, forKey: "DriverDuty")
                self.headerView?.btnSwitch.isSelected = true
                self.headerView?.btnSwitch.setImage(UIImage(named: "iconSwitchOn"), for: .normal)
                self.resetMapView()
                
                
                let resultData = (result as! NSDictionary)
                
                if let shareRide = resultData["share_ride"] as? String {
                    if shareRide == "1" {
                        Singletons.sharedInstance.isShareRideOn = true
                    } else {
                        Singletons.sharedInstance.isShareRideOn = false
                    }
                } else if let shareRide = resultData["share_ride"] as? Int {
                    if shareRide == 1 {
                        Singletons.sharedInstance.isShareRideOn = true
                    } else {
                        Singletons.sharedInstance.isShareRideOn = false
                    }
                }
                
                Singletons.sharedInstance.strCurrentBalance = Double(resultData.object(forKey: "balance") as! String)!
                var rating = String()
                if let ratingTemp = resultData.object(forKey: "rating") as? String
                {
                    if (ratingTemp == "")
                    {
                        rating = "0.0"
                    }
                    else
                    {
                        rating = ratingTemp
                    }
                }
                
                Singletons.sharedInstance.strRating = rating
                let nc = NotificationCenter.default
                nc.post(name: Notification.Name("rating"), object: nil)
                
                self.aryCurrentBookingData.removeAllObjects()
                self.aryCurrentBookingData.add(resultData)
                
                
                if let loginStatus = (self.aryCurrentBookingData.object(at: 0) as! NSDictionary).object(forKey: "login") as? Bool {
                    
                    if (loginStatus) {
                        
                    }
                    else {
                        //                        UtilityClass.showAlertWithCompletion("Multiple login", message: "Please Re-Login", vc: self, completionHandler: { ACTION in
                        
                        self.webserviceOFSignOut()
                        //                        })
                    }
                }
                
                var bookingType = String()
                
                if let strBookingTypeFromCurrentBooking = (result as! NSDictionary).object(forKey: "BookingType") as? String {
                    bookingType = strBookingTypeFromCurrentBooking
                }
                else {
                    bookingType = ""
                }
                //                let bookingType = (result as! NSDictionary).object(forKey: "BookingType") as! String // (self.aryCurrentBookingData.object(at: 0) as! NSDictionary).object(forKey: "BookingType") as! String
                
                Singletons.sharedInstance.strBookingType = bookingType
                //((self.aryCurrentBookingData.object(at: 0) as! [String: AnyObject])["BookingInfo"] as! [String : AnyObject])["BookingType"]! as! String
                
                if(Singletons.sharedInstance.strBookingType == "")
                {
                    Singletons.sharedInstance.strBookingType = bookingType
                }
                
                self.dictCurrentBookingInfoData = ((resultData).object(forKey: "BookingInfo") as! NSDictionary)
                
                var currentCount = String()
                if let DropLocationCount = self.dictCurrentBookingInfoData["CurrentCount"] as? String
                {
                    currentCount = DropLocationCount
                }
                else if let DropLocationCount = self.dictCurrentBookingInfoData["CurrentCount"] as? Int
                {
                    currentCount = "\(DropLocationCount)"
                }
                
                self.btnReached.isHidden = true
                
                if(currentCount == "0" && (self.dictCurrentBookingInfoData["DropoffLocation2"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines).count != 0)
                {
                    self.btnReached.isHidden = false
                }
                let statusOfRequest = self.dictCurrentBookingInfoData.object(forKey: "Status") as! String
                
                let PassengerType = self.dictCurrentBookingInfoData.object(forKey: "PassengerType") as? String
                
                if PassengerType == "" || PassengerType == nil{
                    Singletons.sharedInstance.passengerType = ""
                }
                else {
                    Singletons.sharedInstance.passengerType = PassengerType!
                }
                if(self.dictCurrentBookingInfoData.object(forKey: "PaymentType") as! String == "cash")
                {
                    Singletons.sharedInstance.passengerPaymentType = self.dictCurrentBookingInfoData.object(forKey: "PaymentType") as! String
                }
                
                
                DispatchQueue.main.async {
                    UtilityClass.showHUD()
                    
                }
                
                
                if bookingType != "" {
                    self.aryPassengerData = self.aryCurrentBookingData

                    Singletons.sharedInstance.isBookNowOrBookLater = true
                    
                    if bookingType == "BookNow"
                    {
                        if statusOfRequest == "accepted"
                        {
                            
                            self.bookingID = self.dictCurrentBookingInfoData.object(forKey: "Id") as! String
                            self.driverID = Singletons.sharedInstance.strDriverID
                            Singletons.sharedInstance.isRequestAccepted = true
                            
                            Singletons.sharedInstance.isPickUPPasenger = false
                            
                            self.bookingTypeIsBookNow()
                            
                        }
                        else if statusOfRequest == "traveling" {
                            
                            self.bookingID = self.dictCurrentBookingInfoData.object(forKey: "Id") as! String
                            self.driverID = Singletons.sharedInstance.strDriverID
                            
                            Singletons.sharedInstance.isPickUPPasenger = true
                            
                            self.btnStartTripAction()
                        }
                        
                        Singletons.sharedInstance.bookingId = self.bookingID
                        
                        if (Singletons.sharedInstance.oldBookingType.isBookLater) {
                            Singletons.sharedInstance.oldBookingType.isBookNow = false
                        } else {
                            Singletons.sharedInstance.oldBookingType.isBookNow = true
                        }
                    }
                    else if bookingType == "BookLater" {
                        
                        self.isAdvanceBooking = true
                        
                        if statusOfRequest == "accepted" {
                            
                            self.advanceBookingID = self.dictCurrentBookingInfoData.object(forKey: "Id") as! String
                            self.driverID = Singletons.sharedInstance.strDriverID
                            Singletons.sharedInstance.isRequestAccepted = true
        
                            Singletons.sharedInstance.isPickUPPasenger = false
                            
                            self.bookingTypeIsBookNow()
                            
                        }
                        else if statusOfRequest == "traveling" {
                            
                            self.advanceBookingID = self.dictCurrentBookingInfoData.object(forKey: "Id") as! String
                            self.driverID = Singletons.sharedInstance.strDriverID
                            
                            Singletons.sharedInstance.isPickUPPasenger = true
                            
                            self.btnStartTripAction()
                        }
                        
                        if (Singletons.sharedInstance.oldBookingType.isBookNow) {
                            Singletons.sharedInstance.oldBookingType.isBookLater = false
                        }
                        else {
                            Singletons.sharedInstance.oldBookingType.isBookLater = true
                        }
                    }
                }
                self.webserviceOFGetAllCards()
            }
            else
            {
                
                if let res = result as? String
                {
                    UtilityClass.showAlert("App Name".localized, message: res, vc: self)
                }
                else if result is NSDictionary
                {
                    let resultData = (result as! NSDictionary)
                    Singletons.sharedInstance.dictTripDestinationLocation["location"] = resultData["location"] as AnyObject
                    Singletons.sharedInstance.dictTripDestinationLocation["trip_to_destin"] = resultData["trip_to_destin"] as AnyObject
                    
                    //                    Singletons.sharedInstance.strCurrentBalance = Double(resultData.object(forKey: "balance") as! String)!//cresh
                    
                    if let shareRide = resultData["share_ride"] as? String {
                        if shareRide == "1" {
                            Singletons.sharedInstance.isShareRideOn = true
                        } else {
                            Singletons.sharedInstance.isShareRideOn = false
                        }
                    } else if let shareRide = resultData["share_ride"] as? Int {
                        if shareRide == 1 {
                            Singletons.sharedInstance.isShareRideOn = true
                        } else {
                            Singletons.sharedInstance.isShareRideOn = false
                        }
                    }
                    
                    var rating = String()
                    if let ratingTemp = resultData.object(forKey: "rating") as? String
                    {
                        if (ratingTemp == "")
                        {
                            rating = "0.0"
                        }
                        else
                        {
                            rating = ratingTemp
                        }
                    }
                    
                    Singletons.sharedInstance.strRating = rating
                    let nc = NotificationCenter.default
                    nc.post(name: Notification.Name("rating"), object: nil)
                    self.aryCurrentBookingData.add(resultData)
                    
//                    self.aryPassengerData = self.aryCurrentBookingData
                    
                    if let loginStatus = (self.aryCurrentBookingData.object(at: 0) as! NSDictionary).object(forKey: "login") as? Bool {
                        
                        if (loginStatus) {
                            
                        }
                        else {
                            //                            UtilityClass.showAlertWithCompletion("Multiple login", message: "Please Re-Login", vc: self, completionHandler: { ACTION in
                            
                            self.webserviceOFSignOut()
                            //                            })
                        }
                    }
                    
                    self.webserviceOFGetAllCards()
                }
                else if let resAry = result as? NSArray {
                    UtilityClass.showAlert("App Name".localized, message: (resAry.object(at: 0) as! NSDictionary).object(forKey: GetResponseMessageKey()) as! String, vc: self)
                }
                
            }
            
        }
        
    }
    
    //-------------------------------------------------------------
    // MARK: - Webservice Methods For Completeing Current Booking
    //-------------------------------------------------------------
    
    func webserviceCallForCompleteTrip(dictOFParam : AnyObject) {
        
        webserviceForCompletedTripSuccessfully(dictOFParam as AnyObject) { (result, status) in
            
            if (status) {
                self.dictCompleteTripData = (result as! NSDictionary)
                
                self.resetMapView()
//                self.headerView?.viewSOSIcon.isHidden = true
                Singletons.sharedInstance.isRequestAccepted = false
                Singletons.sharedInstance.isTripContinue = false
                Singletons.sharedInstance.bookingIdTemp = ""
                Singletons.sharedInstance.advanceBookingIdTemp = ""
                
                if let paymentType = (self.dictCompleteTripData.object(forKey: "details") as! NSDictionary).object(forKey: "PaymentType") as? String {
                    Singletons.sharedInstance.passengerPaymentType = paymentType
                }
                
                if Singletons.sharedInstance.passengerPaymentType == "cash" || Singletons.sharedInstance.passengerPaymentType == "Cash" {
                    
                    
                    self.playSound(strName: "\(RingToneSound)")
                    
                    let dictCash = (result as! NSDictionary).object(forKey: "details") as! [String:AnyObject]
                    let Amount = "\(dictCash["GrandTotal"] as AnyObject)"
                    let msg = "Please Collect Money From Passenger".localized + " : $\(Amount)"
                    
                    
                    UtilityClass.showAlertWithCompletion("Alert! This is a cash job".localized, message: msg, vc: self, completionHandler: { ACTION in
                        
                        DispatchQueue.main.async {
                            self.stopSound()
                        }
                        //  self.completeTripButtonAction()
                        
                        UserDefaults.standard.set(Singletons.sharedInstance.isRequestAccepted, forKey: tripStatus.kisRequestAccepted)
                        UserDefaults.standard.set(Singletons.sharedInstance.isTripContinue, forKey: tripStatus.kisTripContinue)
                        
                        
                        if let TripToDesting = self.dictCompleteTripData.value(forKey: "trip_to_destin") as? Int {
                            if (TripToDesting == 1) {
                                Singletons.sharedInstance.dictTripDestinationLocation["location"] = self.dictCompleteTripData.value(forKey: "location") as AnyObject
                                Singletons.sharedInstance.dictTripDestinationLocation["trip_to_destin"] = 0 as AnyObject
                                
                                self.userDefault.set(false, forKey: "buttonSelected")
                                self.userDefault.synchronize()
                            }
                        }
                        
                        DispatchQueue.main.async {
                            
                            self.setCarAfterTrip()
                            self.completeTripInfo()
                        }
                    })
                }
                else
                {
                    
                    let paymentStatus = self.checkDictionaryHaveValue(dictData: self.dictCompleteTripData as! [String : AnyObject], didHaveValue: "payment_status", isNotHave: "")
                    let paymentMessage = self.checkDictionaryHaveValue(dictData: self.dictCompleteTripData as! [String : AnyObject], didHaveValue: "payment_message", isNotHave: "")
                    
                    print("paymentStatus: \(paymentStatus)")
                    print("paymentMessage: \(paymentMessage)")
                    
                    if paymentStatus != "" {
                        
                        if paymentStatus == "1" {
                            
                            //                            let alert = UIAlertController(title: "Alert", message: paymentMessage, preferredStyle: .alert)
                            //                            let OK = UIAlertAction(title: "OK", style: .default, handler: nil)
                            //                            let Cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                            //                            alert.addAction(OK)
                            //                            alert.addAction(Cancel)
                            //                            self.present(alert, animated: true, completion: nil)
                            
                            let alert = UIAlertController(title: "App Name".localized, message: paymentMessage, preferredStyle: UIAlertController.Style.alert)
                            
                            alert.setValue(NSAttributedString(string: alert.title!, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 21, weight: UIFont.Weight.medium), NSAttributedString.Key.foregroundColor : UIColor.red]), forKey: "attributedTitle")
                            
                            alert.setValue(NSAttributedString(string: alert.message!, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium), NSAttributedString.Key.foregroundColor : UIColor.red]), forKey: "attributedMessage")
                            
                            //        alert.setValuesForKeys([NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue).rawValue: UIColor.red])
                            
                            alert.addAction(UIAlertAction(title: "OK".localized, style: UIAlertAction.Style.default, handler: { ACTION in
                                DispatchQueue.main.async {
                                    self.setCarAfterTrip()
                                    self.completeTripInfo()
                                }
                            }))
                            
                            self.present(alert, animated: true, completion: nil)
                            
                            
                            //                            (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.present(next, animated: true, completion: nil)
                        } else {
                            DispatchQueue.main.async {
                                self.setCarAfterTrip()
                                self.completeTripInfo()
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.setCarAfterTrip()
                            self.completeTripInfo()
                        }
                    }
                    
                }
            }
            else {
                UtilityClass.showAlertWithCompletion("App Name".localized, message: "Please try again later.".localized, vc: self, completionHandler: { (status) in
                    self.webserviceOfCurrentBooking()
                })
                
                //                "Please complete trip again"
                
                //                if let res: String = result as? String {
                //                    UtilityClass.showAlert("App Name".localized, message: res, vc: self)
                //                }
                //                else if let resDict = result as? NSDictionary {
                //
                //                    if let msgIsArray = resDict.object(forKey: "message") as? NSArray {
                //                        UtilityClass.showAlert("App Name".localized, message: msgIsArray.firstObject as! String, vc: self)
                //                    } else {
                //                        UtilityClass.showAlert("App Name".localized, message: resDict.object(forKey: "message") as! String, vc: self)
                //                    }
                //
                //
                //                }
                //                else if let resAry = result as? NSArray {
                //                    UtilityClass.showAlert("App Name".localized, message: (resAry.object(at: 0) as! NSDictionary).object(forKey: "message") as! String, vc: self)
                //                }
                
            }
        }
    }
    // ----------------------------------------------------
    // MARK: - Webservice For Submit Multiple Dropoff
    // ----------------------------------------------------
    
    func webserviceOfSubmitMultipleDropoff(bookingId: String, dropOffCount: String, skip: String, bookingType: String, isFromComplete: Bool = false) {
        
        var param = [String: String]()
        param["BookingId"] = bookingId
        param["booking_type"] = bookingType
        param["DropoffCount"] = dropOffCount
        //        param["Skip"] = skip
        param["TripDistance"] = "\(Singletons.sharedInstance.distanceTravelledThroughMeter)"
//        if isFromComplete {
        param["Lat"] = "\(Singletons.sharedInstance.latitude ?? 0)"
        param["Long"] = "\(Singletons.sharedInstance.longitude ?? 0)"
//        }
        
        webserviceForSubmitMultipleDropoff(dictParams: param as AnyObject) { (result, status) in
            //            self.updateCurrentLocationLabel()
            print("SubmitMultipleDropoff: \n \(result)")
            
            if status {
                self.btnCompleteTrip.isHidden = false
                var tempAryBookingDropoffsData = [[String:Any]]()
                
                if let resDetails = (result as! [String:Any])["details"] as? [[String:Any]] {
                    tempAryBookingDropoffsData = resDetails
                }
                
                if isFromComplete {
                    self.completeTripButtonAction()
                }
                else
                {
                    let DropOffLat = "\(tempAryBookingDropoffsData.last?["DropOffLat"] ?? "0")"
                    let DropOffLon = "\(tempAryBookingDropoffsData.last?["DropOffLon"] ?? "0")"
                    
                    let PickupLat = self.defaultLocation.coordinate.latitude
                    let PickupLng = self.defaultLocation.coordinate.longitude
                    
                    let dummyLatitude = Double(PickupLat) - Double(DropOffLat)!
                    let dummyLongitude = Double(PickupLng) - Double(DropOffLon)!
                    
                    let waypointLatitude = self.defaultLocation.coordinate.latitude - dummyLatitude
                    let waypointSetLongitude = self.defaultLocation.coordinate.longitude - dummyLongitude
                    
                    let originalLoc: String = "\(PickupLat),\(PickupLng)"
                    let destiantionLoc: String = "\(DropOffLat),\(DropOffLon)"
                    
                    self.zoomoutCamera(PickupLat: PickupLat, PickupLng: PickupLng, DropOffLat: DropOffLat, DropOffLon: DropOffLon)
                    
                    self.getDirectionsSeconMethod(origin: originalLoc, destination: destiantionLoc, waypoints: ["\(waypointLatitude),\(waypointSetLongitude)"], travelMode: nil, completionHandler: nil)
                    
                    self.btnReached.isHidden = true
                }
            } else {
                UtilityClass.showAlertOfAPIResponse(param: result, vc: self)
            }
        }
    }
    
    //-------------------------------------------------------------
    // MARK: - Webservice Methods For Completeing Advance Booking
    //-------------------------------------------------------------
    
    func webserviceCallForAdvanceCompleteTrip(dictOFParam : AnyObject)
    {
        webserviceForCompletedAdvanceTripSuccessfully(dictOFParam as AnyObject) { (result, status) in
            
            if (status) {
                
                self.dictCompleteTripData = (result as! NSDictionary)
                
                self.resetMapView()
                
                Singletons.sharedInstance.oldBookingType.isBookNow = false
                Singletons.sharedInstance.oldBookingType.isBookLater = false
                
//                self.headerView?.viewSOSIcon.isHidden = true
                Singletons.sharedInstance.isRequestAccepted = false
                Singletons.sharedInstance.isTripContinue = false
                UserDefaults.standard.set(Singletons.sharedInstance.isTripContinue, forKey: tripStatus.kisTripContinue)
                UserDefaults.standard.set(Singletons.sharedInstance.isRequestAccepted, forKey: tripStatus.kisRequestAccepted)
                
                let paymentStatus = self.checkDictionaryHaveValue(dictData: self.dictCompleteTripData as! [String : AnyObject], didHaveValue: "payment_status", isNotHave: "")
                let paymentMessage = self.checkDictionaryHaveValue(dictData: self.dictCompleteTripData as! [String : AnyObject], didHaveValue: "payment_message", isNotHave: "")
                
                print("paymentStatus: \(paymentStatus)")
                print("paymentMessage: \(paymentMessage)")
                
                if paymentStatus != "" {
                    
                    if paymentStatus == "1" {
                        
                        let alert = UIAlertController(title: "Warning!", message: paymentMessage, preferredStyle: UIAlertController.Style.alert)
                        
                        alert.setValue(NSAttributedString(string: alert.title!, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 21, weight: UIFont.Weight.medium), NSAttributedString.Key.foregroundColor : UIColor.red]), forKey: "attributedTitle")
                        
                        alert.setValue(NSAttributedString(string: alert.message!, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium), NSAttributedString.Key.foregroundColor : UIColor.red]), forKey: "attributedMessage")
                        
                        //        alert.setValuesForKeys([NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue).rawValue: UIColor.red])
                        
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { ACTION in
                            DispatchQueue.main.async {
                                self.setCarAfterTrip()
                                self.completeTripInfo()
                            }
                        }))
                        
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                    else {
                        DispatchQueue.main.async {
                            self.setCarAfterTrip()
                            self.completeTripInfo()
                        }
                    }
                }
                else {
                    DispatchQueue.main.async {
                        self.setCarAfterTrip()
                        self.completeTripInfo()
                    }
                }
                
                //                self.setCarAfterTrip()
                //                self.completeTripInfo()
                
            }
            else {
                
                if let res: String = result as? String {
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
    
    //-------------------------------------------------------------
    // MARK: - Webservice Methods For Getting List of Sards
    //-------------------------------------------------------------
    
    func webserviceOFGetAllCards() {
        
        webserviceForCardListingInWallet(Singletons.sharedInstance.strDriverID as AnyObject) { (result, status) in
            
            if (status) {
                print(result)
                Singletons.sharedInstance.CardsVCHaveAryData = (result as! NSDictionary).object(forKey: "cards") as! [[String:AnyObject]]
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
    
    //-------------------------------------------------------------
    // MARK: - Webservice Methods Sign Out
    //-------------------------------------------------------------
    
    @objc func signOutUser() {
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
        UserDefaults.standard.set(false, forKey: driverProfileKeys.kKeyIsDriverLoggedIN)
        UserDefaults.standard.set(false, forKey: kIsSocketEmited)
        //  UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        Singletons.sharedInstance.isDriverLoggedIN = false
        AppDelegate.shared.navigateToLogin()
    }
    
    func webserviceOFSignOut()
    {
        let srtDriverID = Singletons.sharedInstance.strDriverID
        
        let param = srtDriverID + "/" + Singletons.sharedInstance.deviceToken
        
        webserviceForSignOut(param as AnyObject) { (result, status) in
            
            if (status) {
                print(result)
                
                let socket = (UIApplication.shared.delegate as! AppDelegate).SManager.defaultSocket
                
                Utilities.removeUserDefaultsValue()
                socket.off(socketApiKeys.kReceiveBookingRequest)
                socket.off(socketApiKeys.kBookLaterDriverNotify)
                
                socket.off(socketApiKeys.kGetBookingDetailsAfterBookingRequestAccepted)
                socket.off(socketApiKeys.kAdvancedBookingInfo)
                
                socket.off(socketApiKeys.kReceiveMoneyNotify)
                socket.off(socketApiKeys.kAriveAdvancedBookingRequest)
                
                socket.off(socketApiKeys.kDriverCancelTripNotification)
                socket.off(socketApiKeys.kAdvancedBookingDriverCancelTripNotification)
                
                socket.disconnect()
                Singletons.sharedInstance.isDriverLoggedIN = false
                UserDefaults.standard.set(false, forKey: "isTripDestinationShow")
                UserDefaults.standard.set(false, forKey: driverProfileKeys.kKeyIsDriverLoggedIN)
                UserDefaults.standard.set(false, forKey: kIsSocketEmited)
                
                Utilities.showAlertWithCompletion(AppNAME, message: "Your session has been expired, please try to login again.".localized, vc: ((UIApplication.shared.delegate as! AppDelegate).window?.rootViewController)!, completionHandler: { (status) in
                    AppDelegate.shared.navigateToLogin()
                })
                
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
    
    //-------------------------------------------------------------
    // MARK: - Webservice Methods Running Trip Track
    //-------------------------------------------------------------
    
    @objc func webserviceOfRunningTripTrack() {
        
        webserviceForTrackRunningTrip(Singletons.sharedInstance.bookingId as AnyObject, bookingType: (isAdvanceBooking) ? "BookLater" : "BookNow") { (result, status) in
            
            if (status) {
                
                self.aryCurrentBookingData.removeAllObjects()
                self.resetMapView()
                let resultData = (result as! NSDictionary)
                
                if let shareRide = resultData["share_ride"] as? String {
                    if shareRide == "1" {
                        Singletons.sharedInstance.isShareRideOn = true
                    } else {
                        Singletons.sharedInstance.isShareRideOn = false
                    }
                } else if let shareRide = resultData["share_ride"] as? Int {
                    if shareRide == 1 {
                        Singletons.sharedInstance.isShareRideOn = true
                    } else {
                        Singletons.sharedInstance.isShareRideOn = false
                    }
                }
                
                
                self.aryCurrentBookingData.add(resultData)
                
                self.aryPassengerData = self.aryCurrentBookingData
                
                if let loginStatus = (self.aryCurrentBookingData.object(at: 0) as! NSDictionary).object(forKey: "login") as? Bool {
                    
                    if (loginStatus) {
                        
                    }
                    else {
                        //                        UtilityClass.showAlertWithCompletion("Multiple login", message: "Please Re-Login", vc: self, completionHandler: { ACTION in
                        
                        self.webserviceOFSignOut()
                        //                        })
                    }
                }
                
                var bookingType = String()
                
                if let strBookingTypeFromCurrentBooking = (result as! NSDictionary).object(forKey: "BookingType") as? String {
                    bookingType = strBookingTypeFromCurrentBooking
                }
                else {
                    bookingType = ""
                }
                //                let bookingType = (result as! NSDictionary).object(forKey: "BookingType") as! String // (self.aryCurrentBookingData.object(at: 0) as! NSDictionary).object(forKey: "BookingType") as! String
                
                Singletons.sharedInstance.strBookingType = bookingType
                //((self.aryCurrentBookingData.object(at: 0) as! [String: AnyObject])["BookingInfo"] as! [String : AnyObject])["BookingType"]! as! String
                
                if(Singletons.sharedInstance.strBookingType == "")
                {
                    Singletons.sharedInstance.strBookingType = bookingType
                }
                
                if let aryBooking = (resultData).object(forKey: "BookingInfo") as? NSArray {
                    self.dictCurrentBookingInfoData = aryBooking.object(at: 0) as! NSDictionary
                }
                else if let dictBooking = (resultData).object(forKey: "BookingInfo") as? NSDictionary {
                    self.dictCurrentBookingInfoData = dictBooking
                }
                
                
                let statusOfRequest = self.dictCurrentBookingInfoData.object(forKey: "Status") as! String
                
                let PassengerType = self.dictCurrentBookingInfoData.object(forKey: "PassengerType") as? String
                
                if PassengerType == "" || PassengerType == nil{
                    Singletons.sharedInstance.passengerType = ""
                }
                else {
                    Singletons.sharedInstance.passengerType = PassengerType!
                }
                if(self.dictCurrentBookingInfoData.object(forKey: "PaymentType") as! String == "cash")
                {
                    Singletons.sharedInstance.passengerPaymentType = self.dictCurrentBookingInfoData.object(forKey: "PaymentType") as! String
                }
                
                
                DispatchQueue.main.async {
                    UtilityClass.showHUD()
                    
                }
                
                
                if bookingType != "" {
                    Singletons.sharedInstance.isBookNowOrBookLater = true
                    
                    if bookingType == "BookNow"
                    {
                        if statusOfRequest == "accepted"
                        {
                            
                            self.bookingID = self.dictCurrentBookingInfoData.object(forKey: "Id") as! String
                            self.driverID = Singletons.sharedInstance.strDriverID
                            Singletons.sharedInstance.isRequestAccepted = true
                            self.bookingTypeIsBookNow()
                            
                        }
                        else if statusOfRequest == "traveling" {
                            
                            self.bookingID = self.dictCurrentBookingInfoData.object(forKey: "Id") as! String
                            self.driverID = Singletons.sharedInstance.strDriverID
                            
                            self.btnStartTripAction()
                        }
                        
                        Singletons.sharedInstance.bookingId = self.bookingID
                        
                        if (Singletons.sharedInstance.oldBookingType.isBookLater) {
                            Singletons.sharedInstance.oldBookingType.isBookNow = false
                        }
                        else {
                            Singletons.sharedInstance.oldBookingType.isBookNow = true
                        }
                    }
                    else if bookingType == "BookLater" {
                        
                        self.isAdvanceBooking = true
                        
                        if statusOfRequest == "accepted" {
                            
                            self.advanceBookingID = self.dictCurrentBookingInfoData.object(forKey: "Id") as! String
                            self.driverID = Singletons.sharedInstance.strDriverID
                            Singletons.sharedInstance.isRequestAccepted = true
                            
                            self.bookingtypeBookLater()
                            
                        }
                        else if statusOfRequest == "traveling" {
                            
                            self.advanceBookingID = self.dictCurrentBookingInfoData.object(forKey: "Id") as! String
                            self.driverID = Singletons.sharedInstance.strDriverID
                            
                            self.btnStartTripAction()
                        }
                        
                        if (Singletons.sharedInstance.oldBookingType.isBookNow) {
                            Singletons.sharedInstance.oldBookingType.isBookLater = false
                        }
                        else {
                            Singletons.sharedInstance.oldBookingType.isBookLater = true
                        }
                    }
                }
                self.webserviceOFGetAllCards()
            }
            else
            {
                
                if let res = result as? String
                {
                    UtilityClass.showAlert("App Name".localized, message: res, vc: self)
                }
                else if result is NSDictionary
                {
                    let resultData = (result as! NSDictionary)
                    Singletons.sharedInstance.dictTripDestinationLocation["location"] = resultData["location"] as AnyObject
                    Singletons.sharedInstance.dictTripDestinationLocation["trip_to_destin"] = resultData["trip_to_destin"] as AnyObject
                    
                    Singletons.sharedInstance.strCurrentBalance = (Double(resultData.object(forKey: "balance") as? String ?? "0.0")) ?? Double(0.0)
                    
                    if let shareRide = resultData["share_ride"] as? String {
                        if shareRide == "1" {
                            Singletons.sharedInstance.isShareRideOn = true
                        } else {
                            Singletons.sharedInstance.isShareRideOn = false
                        }
                    } else if let shareRide = resultData["share_ride"] as? Int {
                        if shareRide == 1 {
                            Singletons.sharedInstance.isShareRideOn = true
                        } else {
                            Singletons.sharedInstance.isShareRideOn = false
                        }
                    }
                    
                    var rating = String()
                    if let ratingTemp = resultData.object(forKey: "rating") as? String
                    {
                        if (ratingTemp == "")
                        {
                            rating = "0.0"
                        }
                        else
                        {
                            rating = ratingTemp
                        }
                    }
                    
                    Singletons.sharedInstance.strRating = rating
                    let nc = NotificationCenter.default
                    nc.post(name: Notification.Name("rating"), object: nil)
                    self.aryCurrentBookingData.add(resultData)
                    
                    self.aryPassengerData = self.aryCurrentBookingData
                    
                    if let loginStatus = (self.aryCurrentBookingData.object(at: 0) as! NSDictionary).object(forKey: "login") as? Bool {
                        
                        if (loginStatus) {
                            
                        }
                        else {
                            //                            UtilityClass.showAlertWithCompletion("Multiple login", message: "Please Re-Login", vc: self, completionHandler: { ACTION in
                            
                            self.webserviceOFSignOut()
                            //                            })
                        }
                    }
                    
                    self.webserviceOFGetAllCards()
                }
                else if let resAry = result as? NSArray {
                    UtilityClass.showAlert("App Name".localized, message: (resAry.object(at: 0) as! NSDictionary).object(forKey: GetResponseMessageKey()) as! String, vc: self)
                }
                
            }
            
        }
    }
    
    
    
    //-------------------------------------------------------------
    // MARK: - Trip Bookings
    //-------------------------------------------------------------
    
    @IBAction func btnRoadPickUp(_ sender: UIButton)
    {
        sender.LoadButtonAnimation()
        //        self.performSegue(withIdentifier: "segueToTRoadPickup", sender: nil)
        
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MeterViewController") as! MeterViewController
        viewController.strVehicleName = strVehicleName
        viewController.baseFare = baseFare
        
        
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    func bookingTypeIsBookNow() {
        
        methodAfterDidAcceptBooking(data: aryCurrentBookingData)
    }
    
    func bookingtypeBookLater() {
        methodAfterDidAcceptBookingLaterRequest(data: aryCurrentBookingData)
    }
    
    func bookingStatusAccepted() {
        
        btnStartTripAction()
    }
    
    func bookingStatusTraveling() {
        
        btnStartTripAction()
    }
    
    @IBAction func getDirections(_ sender: UIButton) {
        sender.LoadButtonAnimation()
        if Connectivity.isConnectedToInternet() == false {
            UtilityClass.showAlert("App Name".localized, message: "messageNotConnectedToInternet".localized, vc: self)
            return
        }
        
        let BookingInfo : NSDictionary!
        
        if((((self.aryPassengerData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "BookingInfo") as? NSDictionary) == nil) {
            
            BookingInfo = (((self.aryPassengerData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "BookingInfo") as! NSArray).object(at: 0) as! NSDictionary
        }
        else {
            
            BookingInfo = (((self.aryPassengerData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "BookingInfo") as! NSDictionary) //.object(at: 0) as! NSDictionary
        }
        
        
        // ------------------------------------------------------------
        var DropOffLat = BookingInfo.object(forKey: "PickupLat") as! String
        var DropOffLon = BookingInfo.object(forKey: "PickupLng") as! String
        
        if(Singletons.sharedInstance.isTripContinue == true) {
            
            let secondLoc = BookingInfo.object(forKey: "DropOffLat2") as? String ?? ""
            
            if(btnReached.isHidden == true &&  secondLoc != "0"){
                DropOffLat = BookingInfo.object(forKey: "DropOffLat2") as! String
                DropOffLon = BookingInfo.object(forKey: "DropOffLon2") as! String
            }else{
                DropOffLat = BookingInfo.object(forKey: "DropOffLat") as! String
                DropOffLon = BookingInfo.object(forKey: "DropOffLon") as! String
            }
        }
        
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            UIApplication.shared.open(NSURL(string:
                                                "comgooglemaps://?saddr=&daddr=\(String(describing: Float(DropOffLat)!)),\(String(describing: Float(DropOffLon)!))&directionsmode=driving")! as URL, options: [:], completionHandler: { (status) in
            })
        }
        else {
            
            NSLog("Can't use com.google.maps://");
            UtilityClass.showAlert("App Name".localized, message: "Please install Google Maps.".localized, vc: self)
        }
    }
    
    
    func didRatingCompleted() {
        resetMapView()
        driverMarker = nil
        self.performSegue(withIdentifier: "seguePresentRatings", sender: nil)
    }
    
    func completeTripInfo() {
        self.bookingID = ""
        UtilityClass.hideACProgressHUD()
        App_Delegate.WaitingTime = "00:00:00"
        App_Delegate.WaitingTimeCount = 0
        
        let title = "Waiting Time ".localized + App_Delegate.WaitingTime
        self.btnShowWaiting.setTitle(title, for: .normal)
        
        let next = self.storyboard?.instantiateViewController(withIdentifier: "TripInfoCompletedTripVC") as! TripInfoCompletedTripVC
        next.dictData = self.dictCompleteTripData
        next.delegate = self
        DispatchQueue.main.async {
            //              self.stopSound()
            self.btnCurrentLocation(self.btnCurrentlocation)
            
        }
        (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.present(next, animated: true, completion: nil)
    }
    
    func completeRentalTripInfo() {
        let next = self.storyboard?.instantiateViewController(withIdentifier: "TripInfoCompletedTripVC") as! TripInfoCompletedTripVC
        next.dictData = self.dictCompleteTripData
        next.delegate = self
        DispatchQueue.main.async {
            self.btnCurrentLocation(self.btnCurrentlocation)
        }
        (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.present(next, animated: true, completion: nil)
    }
    
    
    //MARK: - Meter Setup -
    
    var waitingTime = Double()
    var baseFare = Double()
    var minKM = Double()
    var perKMCharge = Double()
    var waitingChargePerMinute = Double()
    var bookingFee = Double()
    var strVehicleName = String()
    var strWaitingTime = String()
    //    var counter = 0.0
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    func getStringFrom(seconds: Int) -> String {
        
        return seconds < 10 ? "0\(seconds)" : "\(seconds)"
    }
    
    @objc func updateTime()
    {
        
        
        //        print("Function: \(#function), line: \(#line), Waiting Time Count: \(App_Delegate.WaitingTimeCount)")
        if(SingletonsForMeter.sharedInstance.isMeterOnHold == false)
        {
            App_Delegate.WaitingTimeCount = App_Delegate.WaitingTimeCount + 1.0
        }
        //  print("Function: \(#function), line: \(#line), Waiting Time Count: \(App_Delegate.WaitingTimeCount)")
        
        
        let (h,m,s) = secondsToHoursMinutesSeconds(seconds: Int(App_Delegate.WaitingTimeCount))
        
        App_Delegate.WaitingTime = "\(getStringFrom(seconds: h)):\(getStringFrom(seconds: m)):\(getStringFrom(seconds: s))"
        let meterVC = self.navigationController?.viewControllers.last as? MeterViewController
        
        let title = "Waiting Time ".localized + App_Delegate.WaitingTime
        self.btnShowWaiting.setTitle(title, for: .normal)
        meterVC?.updateTime()
        self.calculateDistanceAndPrice()
    }
    
    func webserviceCallToGetFare()
    {
        webserviceForGetTaxiModelPricing("" as AnyObject) { (result, status) in
            if(status)
            {
                if ((result as AnyObject)["model_cat1"] != nil)
                {
                    SingletonsForMeter.sharedInstance.arrCarModels = (result["model_cat1"] as? AnyObject as! [[String:AnyObject]])
                }
                else
                {
                    UtilityClass.showAlert("App Name".localized, message: "Something went wrong!".localized, vc: self)
                }
                
                if ((result as AnyObject)["meter_model"] != nil)
                {
                    SingletonsForMeter.sharedInstance.arrMeterCarModels = (result["meter_model"] as? AnyObject as! [[String:AnyObject]])
                }
                else
                {
                    UtilityClass.showAlert("App Name".localized, message: "Something went wrong!".localized, vc: self)
                }
                
            }
            else
            {
                UtilityClass.showAlert("App Name".localized, message: "Something went wrong!".localized, vc: self)
            }
        }
    }
    
    
    
    
    func calculateDistanceAndPrice()
    {
        var vehicleID = Int()
        
        for i in 0..<SingletonsForMeter.sharedInstance.arrCarModels.count
        {
            if ((SingletonsForMeter.sharedInstance.arrCarModels[i]["Id"] as! NSString).integerValue == SingletonsForMeter.sharedInstance.vehicleModelID)
            {
                vehicleID = i
                
            }
        }
        
        
        let dictdata = SingletonsForMeter.sharedInstance.arrCarModels[vehicleID]
        SingletonsForMeter.sharedInstance.strVehicleName = dictdata["Name"] as! String
        SingletonsForMeter.sharedInstance.baseFare = (dictdata["BaseFare"]! as! NSString).doubleValue
        SingletonsForMeter.sharedInstance.minKM = (dictdata["MinKm"]! as! NSString).doubleValue
        SingletonsForMeter.sharedInstance.perKMCharge = (dictdata["AbovePerKmCharge"]! as! NSString).doubleValue
        SingletonsForMeter.sharedInstance.waitingChargePerMinute = (dictdata["WaitingTimePerMinuteCharge"]! as! NSString).doubleValue
        SingletonsForMeter.sharedInstance.bookingFee = (dictdata["BookingFee"]! as! NSString).doubleValue
        
        SingletonsForMeter.sharedInstance.total = 0.0
        
        if(Singletons.sharedInstance.distanceTravelledThroughMeter <= minKM)
        {
            SingletonsForMeter.sharedInstance.total = baseFare + bookingFee
        }
        else
        {
            SingletonsForMeter.sharedInstance.total = ((Singletons.sharedInstance.distanceTravelledThroughMeter - minKM) * SingletonsForMeter.sharedInstance.perKMCharge) + SingletonsForMeter.sharedInstance.baseFare +  SingletonsForMeter.sharedInstance.bookingFee
        }
        
        
        SingletonsForMeter.sharedInstance.waitingMinutes = String()
        SingletonsForMeter.sharedInstance.waitingMinutes  = "0.0"
        
        if App_Delegate.WaitingTime != "" {
        }
        else {
            App_Delegate.WaitingTime = "00:00:00"
        }
        
        if (App_Delegate.WaitingTime.count != 0)
        {
            SingletonsForMeter.sharedInstance.waitingMinutes = (App_Delegate.WaitingTime.components(separatedBy: ":")[1])
            
            if (SingletonsForMeter.sharedInstance.waitingMinutes != "")
            {
                SingletonsForMeter.sharedInstance.total = SingletonsForMeter.sharedInstance.total + (Double(SingletonsForMeter.sharedInstance.waitingMinutes)! * waitingChargePerMinute)
            }
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateDistanceInMeters"), object: nil)
    }
    
}


//MARK: --- Tours Code
extension HomeViewController : UIViewControllerTransitioningDelegate, ClassToursDelegate, CompleteRentalTripDelegate {

    func checkCurrentTrip() {
        if(Singletons.sharedInstance.currentTripType == "2"){
            self.getRentalCurrentBookingData()
        } else {
            self.webserviceOfCurrentBooking()
        }
    }
    
    func getRentalCurrentBookingData() {
        UtilityClass.showHUD()
        var dictData = [String:Any]()
        dictData["DriverId"] =  Singletons.sharedInstance.strDriverID
    
        webserviceOfRentalCurrentBooking(dictData as AnyObject) { result, success in
            UtilityClass.hideHUD()
            if(success) {
                let resultData = (result as! NSDictionary)
                self.aryCurrentBookingData.removeAllObjects()
                self.aryCurrentBookingData.add(resultData)
                
                var bookingType = ""
                if let strBookingTypeFromCurrentBooking = (result as! NSDictionary).object(forKey: "BookingType") as? String {
                    bookingType = strBookingTypeFromCurrentBooking
                }
                Singletons.sharedInstance.strBookingType = bookingType
                if(bookingType == ""){
                    return
                }
                
                self.dictCurrentBookingInfoData = ((resultData).object(forKey: "BookingInfo") as! NSDictionary)
                self.dictCurrentPassengerInfoData = ((resultData).object(forKey: "PassengerInfo") as! NSDictionary)
                
                self.toursBookingId = self.dictCurrentBookingInfoData.object(forKey: "Id") as! String
                Singletons.sharedInstance.tourBookingId = self.toursBookingId
                
                self.openToursVC(BookingInFo: self.dictCurrentBookingInfoData, PassengerInfo: self.dictCurrentPassengerInfoData)
            }
        }
    }
   
    func openToursVC(BookingInFo: NSDictionary, PassengerInfo: NSDictionary) {
        
        for view in self.view.subviews {
            if let noticeSubView = view as? ToursView {
               return
            }
        }
        
        let customView: ToursView = UIView.fromNib()
        customView.delegate = self
        customView.delegate1 = self
        customView.dictCurrentBookingInfoData = BookingInFo
        customView.dictCurrentPassengerInfoData = PassengerInfo
        self.view.addSubview(customView)
        viewLocationDetails.isHidden = true
        customView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            customView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customView.topAnchor.constraint(equalTo: headerView!.bottomAnchor),
            customView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func closeToursPopup() {
        viewLocationDetails.isHidden = false
        
        self.toursBookingId = ""
        Singletons.sharedInstance.tourBookingId = ""
        Singletons.sharedInstance.isRequestAccepted = false
    }
    
    func completeTripRental(TripData: NSDictionary) {
        let paymentType = TripData.object(forKey: "PaymentType") as? String ?? ""
        if paymentType.lowercased() == "cash" {
            self.playSound(strName: "\(RingToneSound)")
            self.dictCompleteTripData = TripData
            let Amount = TripData.object(forKey: "GrandTotal") as? String ?? ""
            let msg = "Please Collect Money From Passenger".localized + " : $\(Amount)"
            UtilityClass.showAlertWithCompletion("Alert! This is a cash job".localized, message: msg, vc: self, completionHandler: { ACTION in
                DispatchQueue.main.async {
                    self.stopSound()
                    self.goTonvoice(tripData: TripData)
                }
            })
            
        } else if paymentType.lowercased() == "card" {
            self.goTonvoice(tripData: TripData)
        } else {
            
        }
    }
    
    func goTonvoice(tripData: NSDictionary) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "TourInvoiceVVC") as! TourInvoiceVVC
        viewController.dictCompleteTripData = tripData
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func onNewRequestTours()
    {
        self.socket.on(socketApiKeys.NewRequestForTour, callback: { (data, ack) in
            print ("NewRequestForTour : \(data)")
            
            if(self.aryPassengerData.count != 0 && Singletons.sharedInstance.tourBookingId != "")
            {
                if let BookingID = ((data as NSArray).object(at: 0)as? NSDictionary)?.object(forKey: "BookingId") as? String
                {
                    self.TourBookingRejected(isTripOnGoing: true, bookingID: BookingID)
                } 
                return
            }

            self.playSound(strName: "\(RingToneSound)")
            self.toursBookingId = ((data as NSArray).object(at: 0) as! NSDictionary).object(forKey: "BookingId") as! String
            Singletons.sharedInstance.tourBookingId = self.toursBookingId
            self.toursBookingType = ((data as NSArray).object(at: 0) as! NSDictionary).object(forKey: "BookingType") as? String ?? ""
            
            let next = self.storyboard?.instantiateViewController(withIdentifier: "ReceiveRequestViewController") as! ReceiveRequestViewController
            next.delegate = self
            next.strGrandTotal = "0"
            if let grandTotal = ((data as NSArray).object(at: 0) as! NSDictionary).object(forKey: "EstimateFare") as? String {
                next.strEstimateFare = (grandTotal == "") ? "0" : grandTotal
            } else {
                next.strEstimateFare = "0"
            }

            if let PickupLocation = ((data as NSArray).object(at: 0) as! NSDictionary).object(forKey: "PickupLocation") as? String {
                next.strPickupLocation = PickupLocation
            }
            
            if let DropoffLocation = ((data as NSArray).object(at: 0) as! NSDictionary).object(forKey: "DropoffLocation") as? String {
                next.strDropoffLocation = DropoffLocation
            }
            
            if let RequestMessage = ((data as NSArray).object(at: 0) as! NSDictionary).object(forKey: GetResponseMessageKey()) as? String {
                next.strRequestMessage = RequestMessage
            }
            
            if let PaymentType = ((data as NSArray).object(at: 0) as! NSDictionary).object(forKey: "PaymentType") as? String {
                next.strPaymentType = PaymentType
            }
            
            if let bookingType = ((data as NSArray).object(at: 0) as! NSDictionary).object(forKey: "BookingType") as? String {
                next.strBookingType = bookingType
            }
            
             (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.present(next, animated: true, completion: nil)
        })
    }
    
    func onGettingRentalBookingInfo() {
        self.socket.on(socketApiKeys.RentalBookingInfo, callback: { (data, ack) in
            
            print("RentalBookingInfo : \(data)")
            UtilityClass.hideACProgressHUD()
            
            if let PassengerType = ((data as NSArray).object(at: 0) as! NSDictionary).object(forKey: "BookingType") as? String {
                    Singletons.sharedInstance.passengerType = PassengerType
            }
            Singletons.sharedInstance.isRequestAccepted = true
            UserDefaults.standard.set(Singletons.sharedInstance.isRequestAccepted, forKey: tripStatus.kisRequestAccepted)
           
            let getBookingAndPassengerInfo = self.getBookingAndPassengerInfo(data: data as NSArray)
            let BookingInfo = getBookingAndPassengerInfo.0
            let PassengerInfo = getBookingAndPassengerInfo.1
            print(BookingInfo)
            print(PassengerInfo)
            //let isArrived = BookingInfo.object(forKey: "IsArrived") as? String
            self.openToursVC(BookingInFo: BookingInfo, PassengerInfo: PassengerInfo)
        })
    }
    
}
         

extension UIView {
    class func fromNib<T: UIView>() -> T {
        return Bundle(for: T.self).loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
}
