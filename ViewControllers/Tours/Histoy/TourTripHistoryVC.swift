//
//  TourTripHistoryVC.swift
//  Book A Ride
//
//  Created by Yagnik on 17/02/23.
//  Copyright © 2023 Excellent Webworld. All rights reserved.
//

import UIKit
import SafariServices

class TourTripHistoryVC: ParentViewController {
    
    @IBOutlet weak var btnUpComing: UIButton!
    @IBOutlet weak var btnPastBooking: UIButton!
    @IBOutlet weak var tblData: UITableView!
    
    @IBOutlet weak var lblNavName: UILabel!
    @IBOutlet weak var lblNavBack: UIButton!
    @IBOutlet weak var vwTopHeight: NSLayoutConstraint!
    
    var selectedTyoe = "2"
    var currentPage = "1"
    var isPageEnd: Bool = false
    var aryData : [[String:AnyObject]] = [[:]]

    override func viewDidDisappear(_ animated: Bool) {
     //   self.RentalOffMethods()
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let topBarHeight = UIApplication.shared.statusBarFrame.size.height + (self.navigationController?.navigationBar.frame.height ?? 0.0)
        self.vwTopHeight.constant = topBarHeight
        self.lblNavName.text = "Hourly Bookings".localized
        
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.btnUpComing.setTitle("Pending Jobs".localized, for: .normal)
        self.btnPastBooking.setTitle("Past Jobs".localized, for: .normal)
        
        self.tblData.delegate = self
        self.tblData.dataSource = self
        self.tblData.separatorStyle = .none
        self.tblData.showsHorizontalScrollIndicator = false
        self.tblData.showsVerticalScrollIndicator = false
        
        self.registerNib()

      //  self.setNavBarWithBack(Title: "Hourly Bookings".localized, IsNeedRightButton: false)
        self.reloadTopView(index: selectedTyoe)
        self.APIForHistory(index: selectedTyoe)
    }
    
    func registerNib(){
        let nib = UINib(nibName: TourTripHistoryCell.className, bundle: nil)
        self.tblData.register(nib, forCellReuseIdentifier: TourTripHistoryCell.className)
    }
    
    func reloadTopView(index: String) {
        if index == "1" {
            self.btnUpComing.backgroundColor = themeYellowColor
            self.btnUpComing.setTitleColor(.white, for: .normal)
            self.btnPastBooking.backgroundColor = .lightGray
            self.btnPastBooking.setTitleColor(.darkGray, for: .normal)
        } else if index == "2" {
            self.btnUpComing.backgroundColor = .lightGray
            self.btnUpComing.setTitleColor(.darkGray, for: .normal)
            self.btnPastBooking.backgroundColor = themeYellowColor
            self.btnPastBooking.setTitleColor(.white, for: .normal)
        } else {
           
        }
        self.isPageEnd = false
        self.aryData = []
        self.currentPage = "1"
        self.APIForHistory(index: selectedTyoe)
    }
    
    func getReceipt(url: String) {
        let strContent = "Please download your receipt from the below link\n\n\(url)"
        let share = [strContent]
        let activityViewController = UIActivityViewController(activityItems: share as [Any], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func viewReceipt(receiptURL: String) {
        guard let url = URL(string: receiptURL) else {return}
        let svc = SFSafariViewController(url: url)
        present(svc, animated: true, completion: nil)
    }

    @IBAction func btnUpComingAction(_ sender: Any) {
        self.selectedTyoe = "1"
        self.reloadTopView(index: selectedTyoe)
    }
    
    @IBAction func btnPastBookingAction(_ sender: Any) {
        self.selectedTyoe = "2"
        self.reloadTopView(index: selectedTyoe)
    }
    
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}


extension TourTripHistoryVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.aryData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblData.dequeueReusableCell(withIdentifier: TourTripHistoryCell.className) as! TourTripHistoryCell
        cell.selectionStyle = .none
        
        cell.lblDriverName.text = self.aryData[indexPath.row]["PassengerName"] as? String ?? ""
        cell.lblOrderID.text = "\("Order Number/Booking Number".localized) :" + "\(self.aryData[indexPath.row]["Id"] as? String ?? "")"
        cell.lblPickUpLoc.text = self.aryData[indexPath.row]["PickupLocation"] as? String ?? ""
        cell.lblDropOffLoc.text = self.aryData[indexPath.row]["DropoffLocation"] as? String ?? ""
        
        cell.lblBookingDate.text = "\(self.aryData[indexPath.row]["CreatedDate"] as? String ?? "")".components(separatedBy: " ")[0]
        cell.lblPickUpDate.text = self.aryData[indexPath.row]["PickupDateTime"] as? String ?? ""
        cell.lblDropOffDate.text = self.aryData[indexPath.row]["DropoffDateTime"] as? String ?? ""
        cell.lblPaymentType.text = self.aryData[indexPath.row]["PaymentType"] as? String ?? ""
        cell.lblTripStatus.text = self.aryData[indexPath.row]["StatusName"] as? String ?? ""
        
        let packageInfo = self.aryData[indexPath.row]["PackageInfo"] as? NSDictionary
        cell.lblPackageName.text = "\(packageInfo?.object(forKey: "MinimumHours") as? String ?? "") Hr/\(packageInfo?.object(forKey: "MinimumKm") as? String ?? "") km $\(packageInfo?.object(forKey: "MinimumAmount") as? String ?? "")"
        cell.lblTotalDistance.text = "\(self.aryData[indexPath.row]["TripDistance"] as? String ?? "") km"
        cell.lblTotalDuration.text = "\(self.aryData[indexPath.row]["TripDuration"] as? String ?? "")".secondsToTimeFormate()
        cell.lblGrandTotal.text = "$\(self.aryData[indexPath.row]["GrandTotal"] as? String ?? "")"
        
        
        if selectedTyoe == "1" {
            cell.stackBtns.isHidden = true
            cell.stackgrandtotal.isHidden = true
            cell.stackDistance.isHidden = true
            cell.stackDuration.isHidden = true
            cell.stackDropOffDate.isHidden = true
            cell.btnOnTheWay.isHidden = (self.aryData[indexPath.row]["OnTheWay"] as? String ?? "" == "1") ? true : false
        } else if selectedTyoe == "2"{
            cell.btnOnTheWay.isHidden = true
            cell.stackBtns.isHidden = (self.aryData[indexPath.row]["StatusName"] as? String ?? "" == "Canceled") ? true : false
            cell.btnCancel.isHidden = true
            cell.btnPayment.isHidden = true
            cell.btnGetReceipt.isHidden = false
            cell.btnViewReceipt.isHidden = false
            cell.stackgrandtotal.isHidden = false
            cell.stackDistance.isHidden = false
            cell.stackDuration.isHidden = false
            cell.stackDropOffDate.isHidden = (self.aryData[indexPath.row]["StatusName"] as? String ?? "" == "Canceled") ? true : false

        } else {
            
        }
        
        cell.getReceiptTap = {
            self.getReceipt(url: self.aryData[indexPath.row]["ShareUrl"] as? String ?? "")
        }
        
        cell.viewReceiptTap = {
            self.viewReceipt(receiptURL: self.aryData[indexPath.row]["ShareUrl"] as? String ?? "")
        }
        
        cell.onTheWayTap = {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let tripID:[String: String] = ["id": self.aryData[indexPath.row]["Id"] as? String ?? ""]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "rentalOnTheWay"), object: nil, userInfo: tripID)
            }
            self.navigationController?.popViewController(animated: true)
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? TourTripHistoryCell {
            tableView.beginUpdates()
            cell.stackMain.isHidden = !cell.stackMain.isHidden
            tableView.endUpdates()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offsetY > contentHeight - scrollView.frame.size.height && !isPageEnd{
            var page = Int(currentPage)
            page! += 1
            currentPage = "\(page ?? 1)"
            APIForHistory(index: selectedTyoe)
        }
    }

}

extension TourTripHistoryVC {
    func APIForHistory(index: String) {
 
        var dictData = [String:AnyObject]()
        dictData["DriverId"] = Singletons.sharedInstance.strDriverID as AnyObject
        dictData["Status"] = selectedTyoe as AnyObject
        dictData["page_number"] = currentPage as AnyObject
      
        webserviceForRentalHistory(dictData as AnyObject) { (result, status) in
            if (status) {
                print(result)
                let dictData = result as? [String:AnyObject] ?? [:]
                let data = dictData["data"] as? [[String:AnyObject]] ?? []
                if data.count != 0 {
                    self.aryData.append(contentsOf: data)
                } else {
                    self.isPageEnd = true
                }
                self.tblData.reloadData()
            } else {
            }
        }
    }
}
