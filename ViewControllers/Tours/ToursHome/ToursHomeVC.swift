//
//  ToursHomeVC.swift
//  Book A Ride-Driver
//
//  Created by Admin on 17/01/23.
//  Copyright © 2023 Excellent Webworld. All rights reserved.
//

import UIKit
import GoogleMaps

protocol ClassToursDelegate: class {
    func closeToursPopup()
}

protocol CompleteRentalTripDelegate: class {
    func completeTripRental(TripData: NSDictionary)
}

protocol ChatWithPassengerDelegate: class {
    func gotoChat(ChatData: NSDictionary)
}

class ToursView: UIView {
    
    @IBOutlet weak var MapViewLoad: UIView!
    @IBOutlet weak var lbltripDuration: UILabel!
    @IBOutlet weak var btnArrived: UIButton!
    @IBOutlet weak var btnComplete: UIButton!
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var vwDuration: UIView!
    @IBOutlet weak var btnInfo: UIButton!
    
    var mapView : GMSMapView!
    var originMarker = GMSMarker()
    var zoomLevel: Float = 17
    weak var delegate: ClassToursDelegate?
    weak var delegate1: CompleteRentalTripDelegate?
    weak var delegate2: ChatWithPassengerDelegate?
    var selectedRoute: Dictionary<String, AnyObject>!
    var overviewPolyline: Dictionary<String, AnyObject>!
    var originCoordinate: CLLocationCoordinate2D!
    var destinationCoordinate: CLLocationCoordinate2D!
    var driverMarker: GMSMarker!
    var arrivedRoutePath: GMSPath?
    let baseURLDirections = "https://maps.googleapis.com/maps/api/directions/json?"
    let socket = (UIApplication.shared.delegate as! AppDelegate).SManager.defaultSocket
    
    var dictCurrentPassengerInfoData = NSDictionary()
    var dictCompleteTripData = NSDictionary()
    
    var dictCurrentBookingInfoData: NSDictionary!{
       didSet {
           self.setupBtns()
       }
    }
    
    var totalSecond = Int()
    var timer:Timer?
    
    var oldCoordinate: CLLocationCoordinate2D!
    let carMovement = ARCarMovement()
    var boolShouldTrackCamera = true
    var isCameraDisable: Bool = false
    
    var lastLocation: CLLocation?
    var totalDistance: CLLocationDistance = 0
    
    override func awakeFromNib() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            LocationManager.shared.delegate = self
            self.socketMethods()
            self.setupUI()
            //   self.setupBtns()
        }
        
        self.setLocalization()
        NotificationCenter.default.addObserver(self, selector: #selector(changeLanguage), name: Notification.Name(rawValue: LCLLanguageChangeNotification), object: nil)
    }
    
    @objc func changeLanguage(){
        self.setLocalization()
    }
    func setLocalization(){
        //self.lblServices.text = "Services".localized
        self.btnArrived.setTitle("Arrived at Pickup Location".localized, for: .normal)
        self.btnStart.setTitle("Start Trip".localized, for: .normal)
        self.btnComplete.setTitle("Complete Trip".localized, for: .normal)
        
    }
    
    override func layoutSubviews() {
        
    }
    
    func setupUI() {
        self.btnInfo.tintColor = NavBarBGColor
       // self.vwDuration.isHidden = true
    }
    
    func setupBtns() {
        
        let isArrived = self.dictCurrentBookingInfoData.object(forKey: "IsArrived") as? String
        let isStarted = self.dictCurrentBookingInfoData.object(forKey: "OnTheWay") as? String
        
        if(isArrived == "0"){
            self.LoadMapView(destinationLat: self.dictCurrentBookingInfoData.object(forKey: "PickupLat") as? String ?? "0.0", destinationLong: self.dictCurrentBookingInfoData.object(forKey: "PickupLng") as? String ?? "0.0")
            btnArrived.isHidden = false
            btnStart.isHidden = true
            btnComplete.isHidden = true
        } else if(isStarted == "0") {
            self.LoadMapView(destinationLat: self.dictCurrentBookingInfoData.object(forKey: "DropOffLat") as? String ?? "0.0", destinationLong: self.dictCurrentBookingInfoData.object(forKey: "DropOffLng") as? String ?? "0.0")
            btnArrived.isHidden = true
            btnStart.isHidden = false
            btnComplete.isHidden = true
        } else {
            self.LoadMapView(destinationLat: self.dictCurrentBookingInfoData.object(forKey: "DropOffLat") as? String ?? "0.0", destinationLong: self.dictCurrentBookingInfoData.object(forKey: "DropOffLng") as? String ?? "0.0")
            btnArrived.isHidden = true
            btnStart.isHidden = true
            btnComplete.isHidden = false
            
            self.vwDuration.isHidden = false
            let bookingTime = self.dictCurrentBookingInfoData.object(forKey: "PickupTime") as? String
           
            let date = Date()
            let df = DateFormatter()
            df.dateFormat = "HH:mm:ss"
            let currentTime = df.string(from: date)
            
            self.totalSecond = Int(Double(findDateDiff(time1Str: convertDate(strDate: bookingTime ?? ""), time2Str: currentTime)) ?? 0)
            self.startTimer()
        }
    }
    
    func convertDate(strDate: String) -> String{
        let PickDate = Double(strDate)
        guard let unixTimestamp1 = PickDate else { return "" }
        let date1 = Date(timeIntervalSince1970: TimeInterval(unixTimestamp1))
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "HH:mm:ss"
        let strDate1 = dateFormatter1.string(from: date1)
        return strDate1
    }
    
    func findDateDiff(time1Str: String, time2Str: String) -> String {
        let timeformatter = DateFormatter()
        timeformatter.dateFormat = "HH:mm:ss"
        guard let time1 = timeformatter.date(from: time1Str),let time2 = timeformatter.date(from: time2Str) else { return "" }
        let interval = time2.timeIntervalSince(time1)
        return "\(interval)"
    }
    
    func startTimer(){
        if(timer?.isValid != true){
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countdown), userInfo: nil, repeats: true)
        }
    }
    
    @objc func countdown() {
        var hours: Int
        var minutes: Int
        var seconds: Int

        totalSecond = totalSecond + 1
        hours = totalSecond / 3600
        minutes = (totalSecond % 3600) / 60
        seconds = (totalSecond % 3600) % 60
        self.lbltripDuration.text = "\("Trip Duration".localized) : \(String(format: "%02d:%02d:%02d", hours, minutes, seconds))"
        
        let packageInfo = self.dictCurrentBookingInfoData.object(forKey: "PackageInfo") as? NSDictionary
        let packageHours = Int(packageInfo?.object(forKey: "MinimumHours") as? String ?? "") ?? 0
        
        if(hours >= packageHours && minutes >= 0 && seconds > 0){
            vwDuration.backgroundColor = UIColor.red
        } else {
            vwDuration.backgroundColor = NavBarBGColor
        }
    }
    
    func showErrorMessage(_ message: String) {
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()

        let alertController = UIAlertController(title: "App Name".localized, message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Ok".localized, style: UIAlertAction.Style.cancel, handler: { _ in
            alertWindow.isHidden = true
        }))
        
        alertWindow.windowLevel = UIWindow.Level.alert + 1;
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
    //MARK: - Button Actions
    @IBAction func btnInfoAction(_ sender: Any) {
        let topVC = UIApplication.shared.keyWindow?.rootViewController
        let storyboard = UIStoryboard(name: "MyEarnings", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "TourPassengerInfoVC") as! TourPassengerInfoVC
        vc.delegate = self
        vc.dictCurrentBookingInfoData = self.dictCurrentBookingInfoData
        vc.dictCurrentPassengerInfoData = self.dictCurrentPassengerInfoData
        vc.modalPresentationStyle = .overCurrentContext
        let modalStyle: UIModalTransitionStyle = UIModalTransitionStyle.coverVertical
        vc.modalTransitionStyle = modalStyle
        topVC?.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func btnArrivedAction(_ sender: UIButton) {
        UtilityClass.showHUD()
        let myJSON = [socketApiKeys.kCurrentLat : "\(Singletons.sharedInstance.latitude ?? 0.0)",
                      socketApiKeys.kCurrentLong : "\(Singletons.sharedInstance.longitude ?? 0.0)",
                      socketApiKeys.kPickUpLat : self.dictCurrentBookingInfoData.object(forKey: "PickupLat") as? String ?? "",
                      socketApiKeys.kPickUpLong : self.dictCurrentBookingInfoData.object(forKey: "PickupLng") as? String ?? "",
                      socketApiKeys.kPassengerId : self.dictCurrentBookingInfoData.object(forKey: "PassengerId") as? String ?? "",
                      socketApiKeys.kBookingId : self.dictCurrentBookingInfoData.object(forKey: "Id") as? String ?? "",
                      profileKeys.kDriverId : Singletons.sharedInstance.strDriverID] as [String : Any]
        
        socket.emit(socketApiKeys.RentalDriverArrivedCheck, with: [myJSON], completion: nil)
        print ("RentalDriverArrivedCheck : \(myJSON)")
    }
    
    @IBAction func btnStartAction(_ sender: UIButton) {
        UtilityClass.showHUD()
        self.LoadMapView(destinationLat: self.dictCurrentBookingInfoData.object(forKey: "DropOffLat") as? String ?? "0.0", destinationLong: self.dictCurrentBookingInfoData.object(forKey: "DropOffLng") as? String ?? "0.0")
        
        let myJSON = [socketApiKeys.kBookingId : self.dictCurrentBookingInfoData.object(forKey: "Id") as? String ?? "",  profileKeys.kDriverId : Singletons.sharedInstance.strDriverID] as [String : Any]
        socket.emit(socketApiKeys.PickupRentalPassenger, with: [myJSON], completion: nil)
    }
    
    @IBAction func BtnCompleteAction(_ sender: UIButton) {
        self.timer?.invalidate()
        self.timer = nil
        self.webserviceForCompleteRentalTrip()
    }
}

//MARK: Map View all Funcation
extension ToursView : GMSMapViewDelegate {
    
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
    
    func LoadMapView(destinationLat: String, destinationLong: String) {
        let camera = GMSCameraPosition.camera(withLatitude: Singletons.sharedInstance.latitude, longitude: Singletons.sharedInstance.longitude, zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: 0, width: self.MapViewLoad.frame.width, height: self.MapViewLoad.frame.height), camera: camera)
        self.mapView.delegate = self
        MapViewLoad.addSubview(mapView)
        
        let dropOffLat = destinationLat
        let dropOffLong = destinationLong
        let originalLoc: String = "\(Singletons.sharedInstance.latitude ?? 0.0),\(Singletons.sharedInstance.longitude ?? 0.0)"
        let destiantionLoc: String = "\(dropOffLat),\(dropOffLong)"
        getDirectionsSeconMethod(origin: originalLoc, destination: destiantionLoc, waypoints: nil, travelMode: nil, completionHandler: nil)
    }
    
    func getDirectionsSeconMethod(origin: String!, destination: String!, waypoints: Array<String>!, travelMode: AnyObject!, completionHandler: ((_ status:   String, _ success: Bool) -> Void)?) {
        
        mapView.clear()
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            if let originLocation = origin {
                if let destinationLocation = destination {
                    var directionsURLString = self.baseURLDirections + "origin=" + originLocation + "&destination=" + destinationLocation + "&key=" + googlApiKey
                    print ("directionsURLString: \(directionsURLString)")
                    directionsURLString = directionsURLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                    let directionsURL = NSURL(string: directionsURLString)
                    DispatchQueue.main.async( execute: { () -> Void in
                        let directionsData = NSData(contentsOf: directionsURL! as URL)
                        
                        do{
                            let dictionary: Dictionary<String, AnyObject> = try JSONSerialization.jsonObject(with: directionsData! as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<String, AnyObject>
                            
                            let status = dictionary["status"] as! String
                            if status == "OK" {
                                self.selectedRoute = (dictionary["routes"] as! Array<Dictionary<String, AnyObject>>)[0]
                                self.overviewPolyline = self.selectedRoute["overview_polyline"] as? Dictionary<String, AnyObject>
                                
                                let legs = self.selectedRoute["legs"] as! Array<Dictionary<String, AnyObject>>
                                
                                let startLocationDictionary = legs[0]["start_location"] as! Dictionary<String, AnyObject>
                                self.originCoordinate = CLLocationCoordinate2DMake(startLocationDictionary["lat"] as! Double, startLocationDictionary["lng"] as! Double)
                                
                                let endLocationDictionary = legs[legs.count - 1]["end_location"] as! Dictionary<String, AnyObject>
                                self.destinationCoordinate = CLLocationCoordinate2DMake(endLocationDictionary["lat"] as! Double, endLocationDictionary["lng"] as! Double)
                                
                                _ = legs[0]["start_address"] as! String
                                let destinationAddress = legs[legs.count - 1]["end_address"] as! String
                                
                                if(self.driverMarker == nil) {
                                    self.driverMarker = GMSMarker(position: self.originCoordinate)
                                    self.driverMarker.icon = UIImage(named: Singletons.sharedInstance.strSetCar)
                                    self.driverMarker.map = self.mapView
                                }
                                
                                let destinationMarker = GMSMarker(position: self.destinationCoordinate)
                                destinationMarker.map = self.mapView
                                destinationMarker.icon = UIImage.init(named: "iconMapPin")
                                destinationMarker.title = destinationAddress
                                
                                var aryDistance = [Double]()
                                var finalDistance = Double()
                                
                                for i in 0..<legs.count {
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
                                //781600
                                print("aryDistance : \(aryDistance)")
                                let route = self.overviewPolyline["points"] as! String
                                self.arrivedRoutePath = GMSPath(fromEncodedPath: route)!
                                let path: GMSPath = GMSPath(fromEncodedPath: route)!
                                let routePolyline = GMSPolyline(path: path)
                                routePolyline.map = self.mapView
                                routePolyline.strokeColor = themeYellowColor
                                routePolyline.strokeWidth = 3.0
                                print("line draw : \(#line) function name : \(#function)")
                                
                               
                            } else {
                                print("OVER_QUERY_LIMIT Line number : \(#line) function name : \(#function)")
                            }
                        }
                        catch {
                            print("Catch Not able to get location due to free api key please restart app")
                        }
                    })
                } else {
                    print  ("Destination is nil.")
                }
            } else {
                print  ("Origin is nil")
            }
        }
    }
}

extension ToursView {
    
    func socketMethods() {
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
        self.socketOnForDriverArrivedCheck()
        self.socketOnForRentalStartTrip()
        self.socketOnForRentalStartTripError()
        self.socketOnForRentalTripCanceled()
        
    }
    
    func socketOnForDriverArrivedCheck() {
        self.socket.on(socketApiKeys.RentalDriverArrivedCheck, callback: { (data, ack) in
            print ("RentalDriverArrivedCheck :  \(data)")
            UtilityClass.hideHUD()
            self.btnStart.isHidden = false
            self.btnArrived.isHidden = true
            self.btnComplete.isHidden = true
        // self.showErrorMessage(((data as NSArray).object(at: 0) as! NSDictionary).object(forKey: GetResponseMessageKey()) as! String)
        })
    }
    
    func socketOnForRentalStartTrip() {
        self.socket.on(socketApiKeys.StartRentalTrip, callback: { (data, ack) in
            print ("StartRentalTrip :  \(data)")
            UtilityClass.hideHUD()
            let dict = ((data as NSArray).object(at: 0) as! NSDictionary)
            self.dictCurrentBookingInfoData = ((dict.object(forKey: "BookingInfo") as! NSArray).object(at: 0) as! NSDictionary)
            self.dictCurrentPassengerInfoData = (dict.object(forKey: "PassengerInfo") as! NSArray).object(at: 0) as! NSDictionary
      
            self.btnStart.isHidden = true
            self.btnArrived.isHidden = true
            self.btnComplete.isHidden = false
            
            self.vwDuration.isHidden = false
            let bookingTime = self.dictCurrentBookingInfoData.object(forKey: "PickupTime") as? String
           
            let date = Date()
            let df = DateFormatter()
            df.dateFormat = "HH:mm:ss"
            let currentTime = df.string(from: date)
            
            self.totalSecond = Int(Double(self.findDateDiff(time1Str: self.convertDate(strDate: bookingTime ?? ""), time2Str: currentTime)) ?? 0)
            self.startTimer()
        })
    }
    
    func socketOnForRentalStartTripError() {
        self.socket.on(socketApiKeys.StartRentalTripError, callback: { (data, ack) in
            UtilityClass.hideHUD()
            print ("StartRentalTripError :  \(data)")
            self.showErrorMessage(((data as NSArray).object(at: 0) as! NSDictionary).object(forKey: GetResponseMessageKey()) as! String)
        })
    }
    
    func socketOnForRentalTripCanceled() {
        self.socket.on(socketApiKeys.CancelRentalTripNotification, callback: { (data, ack) in
            print ("CancelRentalTripNotification :  \(data)")
   
            let alertWindow = UIWindow(frame: UIScreen.main.bounds)
            alertWindow.rootViewController = UIViewController()

            let alertController = UIAlertController(title: "App Name".localized, message: ((data as NSArray).object(at: 0) as! NSDictionary).object(forKey: GetResponseMessageKey()) as? String ?? "", preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "Ok".localized, style: UIAlertAction.Style.cancel, handler: { _ in
                alertWindow.isHidden = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.socket.off(socketApiKeys.RentalDriverArrivedCheck)
                    self.socket.off(socketApiKeys.StartRentalTrip)
                    self.socket.off(socketApiKeys.StartRentalTripError)
                    self.socket.off(socketApiKeys.CancelRentalTripNotification)
                    
                    self.removeFromSuperview()
                    self.delegate?.closeToursPopup()
                }
            }))
            
            alertWindow.windowLevel = UIWindow.Level.alert + 1;
            alertWindow.makeKeyAndVisible()
            alertWindow.rootViewController?.present(alertController, animated: true, completion: nil)
        })
    }
    
}

extension ToursView {
    func webserviceForCompleteRentalTrip() {
        UtilityClass.showHUD()
        var dictData = [String:Any]()
        dictData["BookingId"] =  self.dictCurrentBookingInfoData.object(forKey: "Id") as? String ?? ""
        dictData["DropoffLat"] =  "\(LocationManager.shared.mostRecentLocation?.coordinate.latitude ?? 0.0)"
        dictData["DropoffLong"] =  "\(LocationManager.shared.mostRecentLocation?.coordinate.longitude ?? 0.0)"
        
        let distance = self.totalDistance / 1000
        let formattedDistance = String(format: "%.2f", distance)
        dictData["distance"] = formattedDistance
        
        webserviceForCompletedTripRental(dictData as AnyObject) { (result, status) in
            UtilityClass.hideHUD()
            
            if (status) {
                self.totalDistance = 0
                self.lastLocation = nil
                UserDefaults.standard.removeObject(forKey: "rentalDistance")
                UserDefaults.standard.synchronize()

                let dict = (result as! NSDictionary).object(forKey: "data") as! NSDictionary
                self.dictCompleteTripData = dict
                self.delegate1?.completeTripRental(TripData: self.dictCompleteTripData)
               
                self.removeFromSuperview()
                self.delegate?.closeToursPopup()
                
                self.socket.off(socketApiKeys.RentalDriverArrivedCheck)
                self.socket.off(socketApiKeys.StartRentalTrip)
                self.socket.off(socketApiKeys.StartRentalTripError)
                self.socket.off(socketApiKeys.CancelRentalTripNotification)
            } else {
               // UtilityClass.showAlert("App Name".localized, message: "Please try again later.".localized, vc: self)
            }
        }
    }
}

extension ToursView: LocationManagerDelegate {
    func locationManager(_ manager: LocationManager, didUpdateLocation mostRecentLocation: CLLocation) {
        updateLocation()
        UpdateDriverLocation()
    }
    
    func UpdateDriverLocation() {
        let myJSON = [profileKeys.kDriverId : Singletons.sharedInstance.strDriverID,
                      socketApiKeys.kLat: LocationManager.shared.mostRecentLocation?.coordinate.latitude ?? 0.0,
                      socketApiKeys.kLong: LocationManager.shared.mostRecentLocation?.coordinate.longitude ?? 0.0,
                      socketApiKeys.kBookingId : self.dictCurrentBookingInfoData.object(forKey: "Id") as? String ?? ""] as [String : Any]
        socket.emit(socketApiKeys.RentalUpdateDriverLocation, with: [myJSON], completion: nil)
        print ("\(socketApiKeys.RentalUpdateDriverLocation) : \(myJSON)")
    }
    
    func updateLocation() {
        //Singletons.sharedInstance.tourBookingId = ""
        
        guard let location = LocationManager.shared.mostRecentLocation else {
            return
        }
        
        // Calculate distance
        let kmh = location.speed / 1000.0 * 60.0 * 60.0
        if Singletons.sharedInstance.tourBookingId != "" {
            if kmh >= 5 && self.lastLocation != nil {
                let distance = location.distance(from: self.lastLocation!)
                self.totalDistance += distance
                UserDefaults.standard.set(self.totalDistance, forKey: "rentalDistance")
                UserDefaults.standard.synchronize()
                print("Total distance traveled: \(self.totalDistance)m")
            } else {
                if let retrievedValue = UserDefaults.standard.object(forKey: "rentalDistance") {
                    self.totalDistance = retrievedValue as! CLLocationDistance
                }
            }
            self.lastLocation = location
        } else {
            self.totalDistance = 0
            self.lastLocation = nil
            UserDefaults.standard.removeObject(forKey: "rentalDistance")
            UserDefaults.standard.synchronize()
        }
        // Calculate distance comp

        if(driverMarker == nil || driverMarker!.map == nil) {
            setDriverMarker()
        }
        driverMarker.map = mapView
        
        if(kmh <= 2){
            return
        }
        
        if oldCoordinate != nil {
            CATransaction.begin()
            CATransaction.setValue(2, forKey: kCATransactionAnimationDuration)
        } else {
            oldCoordinate = location.coordinate
        }
        
        let bearing = getBearingBetweenTwoPoints(point1: CLLocationCoordinate2DMake(oldCoordinate.latitude, oldCoordinate.longitude), point2:CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude))
                 
        if(self.boolShouldTrackCamera) {
           // let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,longitude: location.coordinate.longitude,zoom: zoomLevel)
            let camera = GMSCameraPosition.camera(withTarget: CLLocationCoordinate2DMake(oldCoordinate.latitude, oldCoordinate.longitude), zoom: 17, bearing: bearing, viewingAngle: 45)
            mapView.animate(to: camera)
        }

        if let driverMarker = self.driverMarker {
            carMovement.ARCarMovement(marker: driverMarker, oldCoordinate: oldCoordinate ?? location.coordinate, newCoordinate: location.coordinate, mapView: mapView, bearing: 0)
        }
        if oldCoordinate != nil {
            CATransaction.commit()
        }
        oldCoordinate = location.coordinate
    }
    
    func setDriverMarker() {
        guard let location = LocationManager.shared.mostRecentLocation?.coordinate else {
            return
        }
        if(driverMarker == nil || driverMarker!.map == nil) {
            self.driverMarker = GMSMarker(position: location)
            self.driverMarker?.icon = UIImage(named:"dummyCar")
            self.driverMarker?.map = self.mapView
        } else {
            self.driverMarker?.position = location
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
}

extension ToursView: ChatWithPassengerprotocol {
    func gotoChat() {
        let strBookingID = "\(self.dictCurrentBookingInfoData.object(forKey: "Id") as AnyObject)"
        let setDriverId =  "\(self.dictCurrentPassengerInfoData.object(forKey: "Id") as AnyObject)"
        let DriverName = self.dictCurrentPassengerInfoData.object(forKey: "Fullname") as? String ?? ""
      
        var dictData : [String:String] = [:]
        dictData["BookingId"] = strBookingID
        dictData["PassengerId"] = setDriverId
        dictData["PassengerName"] = DriverName
        self.delegate2?.gotoChat(ChatData: dictData as NSDictionary)
       
        self.removeFromSuperview()
        self.delegate?.closeToursPopup()
        
        self.socket.off(socketApiKeys.RentalDriverArrivedCheck)
        self.socket.off(socketApiKeys.StartRentalTrip)
        self.socket.off(socketApiKeys.StartRentalTripError)
        self.socket.off(socketApiKeys.CancelRentalTripNotification)
        
    }
}
