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

class ToursHomeVC: UIView {
    
    @IBOutlet weak var MapViewLoad: UIView!
    @IBOutlet weak var lbltripDuration: UILabel!
    @IBOutlet weak var btnArrived: UIButton!
    @IBOutlet weak var btnComplete: UIButton!
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var btnStart: UIButton!
    
    var mapView : GMSMapView!
    var originMarker = GMSMarker()
    var zoomLevel: Float = 17
    weak var delegate: ClassToursDelegate?
    var selectedRoute: Dictionary<String, AnyObject>!
    var overviewPolyline: Dictionary<String, AnyObject>!
    var originCoordinate: CLLocationCoordinate2D!
    var destinationCoordinate: CLLocationCoordinate2D!
    var driverMarker: GMSMarker!
    var arrivedRoutePath: GMSPath?
    let baseURLDirections = "https://maps.googleapis.com/maps/api/directions/json?"
    
    override func awakeFromNib() {
        LoadMapView()
    }
    
    //MARK: Button Actions
    
    @IBAction func btnArrivedAction(_ sender: UIButton) {
        btnStart.isHidden = false
        btnArrived.isHidden = true
    }
    
    @IBAction func btnStartAction(_ sender: UIButton) {
        btnStart.isHidden = true
        btnArrived.isHidden = true
        btnComplete.isHidden = false
    }
    
    @IBAction func BtnCompleteAction(_ sender: UIButton) {
        Utilities.showAlertWithCompletion(AppNAME, message: "Your trip has been completed", vc: self.topMostController() ?? UIViewController()) { success in
            self.removeFromSuperview()
            self.delegate?.closeToursPopup()
        }
    }
}

//MARK: Map View all Funcation
extension ToursHomeVC : GMSMapViewDelegate {
    
    func LoadMapView() {
        let camera = GMSCameraPosition.camera(withLatitude: Singletons.sharedInstance.latitude, longitude: Singletons.sharedInstance.longitude, zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: 0, width: self.MapViewLoad.frame.width, height: self.MapViewLoad.frame.height), camera: camera)
        self.mapView.delegate = self
        MapViewLoad.addSubview(mapView)
        
        let originalLoc: String = "23.0714,72.5168"
        let destiantionLoc: String = "23.1013,72.5407"
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
