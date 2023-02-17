//
//  TourInvoiceVVC.swift
//  Book A Ride-Driver
//
//  Created by Yagnik on 30/01/23.
//  Copyright © 2023 Excellent Webworld. All rights reserved.
//

import UIKit
import FloatRatingView

class TourInvoiceVVC: ParentViewController {
    
    @IBOutlet weak var lblPickUpLoc: UILabel!
    @IBOutlet weak var lblDropOfLoc: UILabel!
    @IBOutlet weak var lblTotalTime: UILabel!
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var llTotalPrice: UILabel!
    @IBOutlet weak var llDateTime: UILabel!
    @IBOutlet weak var llServiceType: UILabel!
    @IBOutlet weak var lblVehicleInfo: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblPackageInfo: UILabel!
    
    @IBOutlet weak var lblNavName: UILabel!
    @IBOutlet weak var lblNavBack: UIButton!
    @IBOutlet weak var vwTopHeight: NSLayoutConstraint!
    
    @IBOutlet weak var giveRating: FloatRatingView!
    @IBOutlet weak var txtFeedbackFinal: UITextField!
    
    var ratingToDriver: Float = 0
    var dictCompleteTripData = NSDictionary()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let topBarHeight = UIApplication.shared.statusBarFrame.size.height + (self.navigationController?.navigationBar.frame.height ?? 0.0)
        self.vwTopHeight.constant = topBarHeight
        self.lblNavName.text = "Invoice".localized
        self.giveRating.delegate = self
    }
    
    func setupData() {
        self.lblPickUpLoc.text = self.dictCompleteTripData.object(forKey: "PickupLocation") as? String
        self.lblDropOfLoc.text = self.dictCompleteTripData.object(forKey: "DropoffLocation") as? String
        self.lblTotalTime.text = "\(self.dictCompleteTripData.object(forKey: "TripDuration") as? String ?? "0")".secondsToTimeFormate()
        self.lblDistance.text = "\(self.dictCompleteTripData.object(forKey: "TripDistance") as? String ?? "0") Km"
        self.llTotalPrice.text = "$\(self.dictCompleteTripData.object(forKey: "GrandTotal") as? String ?? "0")"
        self.lblPrice.text = "$\(self.dictCompleteTripData.object(forKey: "GrandTotal") as? String ?? "0")"
        self.llDateTime.text = self.dictCompleteTripData.object(forKey: "PickupDateTime") as? String
        self.llServiceType.text = "BookARide Tours"
        
        let vehicleInfo = self.dictCompleteTripData.object(forKey: "CarInfo") as? NSDictionary
        let packageInfo = self.dictCompleteTripData.object(forKey: "PackageInfo") as? NSDictionary
        
        self.lblVehicleInfo.text = vehicleInfo?.object(forKey: "Name") as? String ?? ""
        self.lblPackageInfo.text = "\(packageInfo?.object(forKey: "MinimumHours") as? String ?? "") Hr/\(packageInfo?.object(forKey: "MinimumKm") as? String ?? "") km $\(packageInfo?.object(forKey: "MinimumAmount") as? String ?? "")"
        
  
    }
    
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSubmitFinalRating(_ sender: UIButton) {
        var param = [String:AnyObject]()
        
        param["PassengerId"] = self.dictCompleteTripData.object(forKey: "PassengerId") as AnyObject as AnyObject
        param["DriverId"] = Singletons.sharedInstance.strDriverID as AnyObject
        param["BookingId"] = self.dictCompleteTripData.object(forKey: "Id") as AnyObject
        param["Rating"] = Float(giveRating.rating) as AnyObject
        param["Comment"] = txtFeedbackFinal.text as AnyObject
        
        webserviceForGiveRentalRating(param as AnyObject) { (result, status) in
            
            if (status) {
                self.txtFeedbackFinal.text = ""
                self.ratingToDriver = 0.0
                self.giveRating.rating = 0.0
                UtilityClass.showAlertWithCompletion("Success".localized, message: result.object(forKey: "message") as? String ?? "", vc: self) { (status) in
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
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

extension TourInvoiceVVC : FloatRatingViewDelegate {
    private func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating: Float) {
        giveRating.rating = Double(rating)
        ratingToDriver = Float(giveRating.rating)
    }
}
