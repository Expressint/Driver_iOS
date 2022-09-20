//
//  MyEarningsViewController.swift
//  TEGO-Driver
//
//  Created by EWW082 on 25/03/19.
//  Copyright © 2019 Excellent Webworld. All rights reserved.
//

import UIKit
import IQDropDownTextField


class MyEarningsViewController: ParentViewController, IQDropDownTextFieldDelegate
{
    
    @IBOutlet weak var btnYearly: UIButton!
    @IBOutlet weak var btnCustomeDate: UIButton!
    @IBOutlet weak var btnMonth: UIButton!
    @IBOutlet weak var btnWeekly: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblTotalEarningTitle: UILabel!
    @IBOutlet weak var lblTotalEarningValue: UILabel!
    
    @IBOutlet weak var lblSelectYearTitle: UILabel!
    @IBOutlet weak var lblFromDateTitle: UILabel!
    @IBOutlet weak var lblToDateTitle: UILabel!
    
    
    @IBOutlet weak var viewFromToDate: UIView!
    @IBOutlet weak var viewYear: UIView!
    @IBOutlet weak var txtSelectYear: IQDropDownTextField!
    @IBOutlet weak var txtSelectFromDate: IQDropDownTextField!
    @IBOutlet weak var txtSelectToDate: IQDropDownTextField!
    
    @IBOutlet weak var lblTotalEarning: UILabel!
    @IBOutlet weak var lblTotalTripFare: UILabel!
    @IBOutlet weak var lblTotalTripDuration: UILabel!
    @IBOutlet weak var lblTotalDistance: UILabel!
    @IBOutlet weak var lblTotalTrips: UILabel!
    
    @IBOutlet weak var TitleTotalEarning: UILabel!
    @IBOutlet weak var TitleTripDuration: UILabel!
    @IBOutlet weak var TitleTripDistance: UILabel!
    @IBOutlet weak var TitleTotalTrip: UILabel!
    
    
    
    var arryear = [String]()
    
    var arrEarning = [[String : AnyObject]]()
    var result = [String:Any]()
    
    var selectedReportType = String()
    var selectedFromDate = Date()
    var selectedToDate = Date()
    var selectedYear = String()
    
    
    var selectedFromDatePAram = String()
    var selectedToDatePAram = String()
    

    
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let year = Calendar.current.component(.year, from: Date())
        
        self.lblToDateTitle.isHidden = true
        self.lblFromDateTitle.isHidden = true
        self.lblSelectYearTitle.isHidden = true
        arryear = ["\(year - 1)", "\(year)"]
        txtSelectYear.itemList = arryear
        
        txtSelectYear.isOptionalDropDown = true
        txtSelectToDate.dropDownMode = .datePicker
        txtSelectFromDate.dropDownMode = .datePicker
        
        txtSelectFromDate.datePicker.maximumDate = Date()
        txtSelectToDate.datePicker.maximumDate = Date()
        
        if #available(iOS 13.4, *) {
            txtSelectFromDate.datePicker.preferredDatePickerStyle = .wheels
            txtSelectToDate.datePicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
            
        }
        
        txtSelectToDate.delegate = self
        txtSelectFromDate.delegate = self
        
        
//        self.txtSelectFromDate.isUserInteractionEnabled = false
        self.txtSelectFromDate.alpha = 0.5
//        self.txtSelectToDate.isUserInteractionEnabled = false
        self.txtSelectToDate.alpha = 0.5
        
        self.viewYear.isHidden = true
        self.viewFromToDate.isHidden = true
        
        txtSelectYear.tag = 1
        txtSelectFromDate.tag = 2
        txtSelectToDate.tag = 3
        
        WeekSelected()
        
//        self.title = "My Earnings"
        setToolBarAction()
    
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        self.setLocalization()
    }
    
    func setLocalization() {
        self.headerView?.lblTitle.text = "My Earnings".localized
        
        self.btnWeekly.setTitle("Weekly".localized, for: .normal)
        self.btnMonth.setTitle("Monthly".localized, for: .normal)
        self.btnYearly.setTitle("Yearly".localized, for: .normal)
        self.btnCustomeDate.setTitle("Custom Date".localized, for: .normal)
        
        self.btnWeekly.titleLabel?.numberOfLines = 0
        self.btnMonth.titleLabel?.numberOfLines = 0
        self.btnYearly.titleLabel?.numberOfLines = 0
        self.btnCustomeDate.titleLabel?.numberOfLines = 0
        
        self.lblSelectYearTitle.text = "Select Year".localized
        self.txtSelectYear.placeholder = "Select Year".localized
        
        self.lblFromDateTitle.text = "From Date".localized
        self.txtSelectFromDate.placeholder = "From Date".localized
        
        self.lblToDateTitle.text = "To Date".localized
        self.txtSelectToDate.placeholder = "To Date".localized
        
        self.TitleTotalEarning.text = "Total Earnings".localized
        self.TitleTripDuration.text = "Total Trip Duration".localized
        self.TitleTripDistance.text = "Total Trip Distance".localized
        self.TitleTotalTrip.text = "Total Trips".localized
    }
    
    
    func setToolBarAction() {
        
        txtSelectYear.addDoneOnKeyboardWithTarget(self, action: #selector(self.doneButtonClicked(_:)))
        txtSelectFromDate.addDoneOnKeyboardWithTarget(self, action: #selector(self.doneButtonClicked(_:)))
        txtSelectToDate.addDoneOnKeyboardWithTarget(self, action: #selector(self.donSelectToDate(_:)))
    }
    
    @objc func doneButtonClicked(_ sender: UITextField) {
        
        if self.selectedReportType == "yearly" {
            if !Utilities.isEmpty(str: self.txtSelectYear.selectedItem) {
                webserviceForGettingEarningwise(self.selectedReportType)
                self.txtSelectYear.resignFirstResponder()
                self.txtSelectFromDate.resignFirstResponder()
                self.txtSelectToDate.resignFirstResponder()
            }
        }
        else if self.selectedReportType == "datewise" {
            txtSelectYear.resignFirstResponder()
            txtSelectFromDate.resignFirstResponder()
        }
    }
    
    @objc func donSelectToDate(_ sender: UITextField) {
        
//        if !Utilities.isEmpty(str: self.txtSelectYear.selectedItem) && !Utilities.isEmpty(str: self.txtSelectFromDate.selectedItem) && !Utilities.isEmpty(str: self.txtSelectToDate.selectedItem) {
            webserviceForGettingEarningwise(self.selectedReportType)
            self.txtSelectYear.resignFirstResponder()
            self.txtSelectFromDate.resignFirstResponder()
            self.txtSelectToDate.resignFirstResponder()
//        }
    }
    
    func textField(_ textField: IQDropDownTextField, didSelect date: Date?) {
        
        let dateFormatter = DateFormatter()
        //SJ_Change :
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss +zzzz"
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        _ = self.txtSelectYear.selectedItem
        let fromDate = self.txtSelectFromDate.selectedItem
        let toDate = self.txtSelectToDate.selectedItem
        
        if textField == txtSelectFromDate {
            
            self.selectedFromDate = date!
            self.txtSelectFromDate.selectedItem = dateFormatter.string(from: date!)
            
            if !Utilities.isEmpty(str: fromDate) {
                self.txtSelectToDate.isUserInteractionEnabled = true
                self.txtSelectToDate.alpha = 1
            }
            
            if !Utilities.isEmpty(str: toDate) {
                self.txtSelectToDate.setDate(date!, animated: true)
                self.selectedToDate = date!
            }
        } else {
            self.selectedToDate = date!
            self.txtSelectToDate.selectedItem = dateFormatter.string(from: date!)
        }
//        if !Utilities.isEmpty(str: year) && !Utilities.isEmpty(str: fromDate) && !Utilities.isEmpty(str: toDate)
//        {
//            webserviceForGettingEarningwise(self.selectedReportType)
//        }
    }
    
    func textField(_ textField: IQDropDownTextField, didSelectItem item: String?) {
        
        let year = self.txtSelectYear.selectedItem
        let fromDate = self.txtSelectFromDate.selectedItem
        let toDate = self.txtSelectToDate.selectedItem
        self.selectedYear = year!
        
        if !Utilities.isEmpty(str: year) {
            self.txtSelectFromDate.isUserInteractionEnabled = true
            self.txtSelectFromDate.alpha = 1
            
            if !Utilities.isEmpty(str: fromDate) {
                let selectedYear = Int(self.txtSelectYear.selectedItem!)
                let dateComponents = DateComponents(year: selectedYear)
                let calendar = Calendar.current
                let date = calendar.date(from: dateComponents)!
                self.txtSelectFromDate.setDate(date, animated: true)
                self.selectedFromDate = date
                if !Utilities.isEmpty(str: toDate) {
                    self.txtSelectToDate.setDate(date, animated: true)
                    self.selectedToDate = date
                }
            }
        }
        
//        if self.selectedReportType == "yearly" {
//            if !Utilities.isEmpty(str: self.txtSelectYear.selectedItem) {
//                webserviceForGettingEarningwise(self.selectedReportType)
//            }
//        }
//        else {
//            if !Utilities.isEmpty(str: self.txtSelectYear.selectedItem) && !Utilities.isEmpty(str: self.txtSelectFromDate.selectedItem) && !Utilities.isEmpty(str: self.txtSelectToDate.selectedItem) {
//                webserviceForGettingEarningwise(self.selectedReportType)
//            }
//        }
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
//        _ = self.txtSelectYear.selectedItem
        let fromDate = self.txtSelectFromDate.selectedItem
//        _ = self.txtSelectToDate.selectedItem
        
        if textField == txtSelectToDate {
            
            self.lblToDateTitle.isHidden = false
            if !Utilities.isEmpty(str: fromDate) {
                self.txtSelectToDate.datePicker.minimumDate = selectedFromDate
            }
        }
        
        if textField == txtSelectFromDate {
            
//            let selectedYear = Int(self.txtSelectYear.selectedItem!)
//            let dateComponents = DateComponents(year: selectedYear)
//            let calendar = Calendar.current
//            let date = calendar.date(from: dateComponents)!
//            self.txtSelectFromDate.datePicker.minimumDate = date
            
            self.lblFromDateTitle.isHidden = false
        }
        
        if textField == txtSelectYear {
            self.lblSelectYearTitle.isHidden = false
        }
    }
    
    @IBAction func btnYearlyClick(_ sender: UIButton) {
        yearSelected()
    }
    
    @IBAction func btnCustomeDateClick(_ sender: UIButton) {
        CustomDateSelected()
    }
    
    @IBAction func btnMonthClick(_ sender: UIButton) {
        MonthSelected()
    }
    
    @IBAction func btnWeeklyClick(_ sender: UIButton) {
        WeekSelected()
    }
    
    func WeekSelected() {
        
        self.viewYear.isHidden = true
        self.viewFromToDate.isHidden = true
        
        let startWeek = Date().startOfWeek
        let date = Date()
        print(startWeek ?? "not found start date")
        self.selectedFromDate = startWeek!
        self.selectedToDate = date
        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        let strTemp = inputFormatter.string(from: startWeek!)
        let strTempToDate = inputFormatter.string(from: date)
        
        let showDateToDate = inputFormatter.date(from: strTempToDate)
        inputFormatter.dateFormat = "yyyy-MM-dd"
        let resultStringToDate = inputFormatter.string(from: showDateToDate!)
        
        self.selectedFromDatePAram = strTemp.components(separatedBy: " ").first!
        self.selectedToDatePAram = resultStringToDate
        
        btnWeekly.isSelected = true
        btnYearly.isSelected = false
        btnCustomeDate.isSelected = false
        btnMonth.isSelected = false
        
        if btnWeekly.isSelected == true {
            self.selectedReportType = "weekly"
            btnWeekly.backgroundColor = NavBarBGColor //themeColors.themeBlueColor
            //btnDay.setTitleColor(.white, for: .normal)
            btnCustomeDate.backgroundColor = UIColor.lightGray
            //btnCustomeDate.setTitleColor(UIColor.darkGray, for: .normal)
            btnMonth.backgroundColor = UIColor.lightGray
            btnYearly.backgroundColor = UIColor.lightGray
            //btnMonth.setTitleColor(UIColor.darkGray, for: .normal)
            //            lblTotalEarningValue.text = "$1500.00"
        }
        
        self.webserviceForGettingEarningwise("weekly")
    }
    
    func yearSelected() {
        
        self.viewYear.isHidden = false
        self.viewFromToDate.isHidden = true
        
        btnWeekly.isSelected = false
        btnYearly.isSelected = true
        btnCustomeDate.isSelected = false
        btnMonth.isSelected = false
        
        if btnYearly.isSelected == true
        {
            self.selectedReportType = "yearly"
            btnYearly.backgroundColor = NavBarBGColor//themeColors.themeBlueColor
            //btnDay.setTitleColor(.white, for: .normal)
            btnCustomeDate.backgroundColor = UIColor.lightGray
            //btnCustomeDate.setTitleColor(UIColor.darkGray, for: .normal)
            btnMonth.backgroundColor = UIColor.lightGray
            btnWeekly.backgroundColor = UIColor.lightGray
            //btnMonth.setTitleColor(UIColor.darkGray, for: .normal)
            //            lblTotalEarningValue.text = "$1500.00"
        }
        
        self.arrEarning = []
        self.tableView.reloadData()
    }
    
    func CustomDateSelected()
    {
        self.viewYear.isHidden = true
        self.viewFromToDate.isHidden = false
        btnWeekly.isSelected = false
        btnCustomeDate.isSelected = true
        btnYearly.isSelected = false
        btnMonth.isSelected = false
        
        txtSelectToDate.selectedItem = ""
        txtSelectFromDate.selectedItem = ""
        lblFromDateTitle.isHidden = true
        lblToDateTitle.isHidden = true
        
        if btnCustomeDate.isSelected == true
        {
            self.selectedReportType = "datewise"
            btnCustomeDate.backgroundColor = NavBarBGColor//themeColors.themeBlueColor
            //            btnCustomeDate.setTitleColor(.white, for: .normal)
            btnYearly.backgroundColor = UIColor.lightGray
            //            btnDay.setTitleColor(UIColor.darkGray, for: .normal)
            btnMonth.backgroundColor = UIColor.lightGray
            //            btnMonth.setTitleColor(UIColor.darkGray, for: .normal)
            //            lblTotalEarningValue.text = "$2000.00"
            btnWeekly.backgroundColor = UIColor.lightGray
            //            self.webserviceForGettingEarningwise("monthly")
        }
        
        self.arrEarning = []
        self.tableView.reloadData()
        
    }
    
    func MonthSelected()
    {
        self.viewYear.isHidden = true
        self.viewFromToDate.isHidden = true
        
        let date = Date()
        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let strTemp = inputFormatter.string(from: date)
        
        let showDate = inputFormatter.date(from: strTemp)
        inputFormatter.dateFormat = "yyyy-MM-dd"
        let resultString = inputFormatter.string(from: showDate!)
        print(resultString)
        
        self.selectedFromDatePAram = resultString
        let lastDate = (strTemp.replacingOccurrences(of: ((strTemp.components(separatedBy: "-") as NSArray).lastObject as! String), with: "01"))
        self.selectedFromDatePAram = lastDate
        
        btnWeekly.isSelected = false
        btnMonth.isSelected = true
        btnYearly.isSelected = false
        btnCustomeDate.isSelected = false
        
        if btnMonth.isSelected == true
        {
            self.selectedReportType = "monthly"
            btnMonth.backgroundColor = NavBarBGColor//themeColors.themeBlueColor
            //            btnMonth.setTitleColor(.white, for: .normal)
            btnYearly.backgroundColor = UIColor.lightGray
            //            btnDay.setTitleColor(UIColor.darkGray, for: .normal)
            btnCustomeDate.backgroundColor = UIColor.lightGray
            btnWeekly.backgroundColor = UIColor.lightGray
            //            btnCustomeDate.setTitleColor(UIColor.darkGray, for: .normal)
            //            lblTotalEarningValue.text = "$2500.00"
            //            self.webserviceForGettingEarningwise("monthly")
        }
        self.webserviceForGettingEarningwise("monthly")
    }
    
    func webserviceForGettingEarningwise(_ ReportType : String)
    {
        /*
         "DriverId:6
         ReportType:yearly OR monthly OR weekly OR datewise
         FromDate:2019-05-01
         ToDate:2019-05-28
         Year:2019"
         */
        var dictData = [String : AnyObject]()
        
        dictData["DriverId"] = Singletons.sharedInstance.strDriverID as AnyObject
        dictData["ReportType"] = ReportType as AnyObject
        if ReportType == "monthly" || ReportType == "weekly" || ReportType == "datewise"
        {
            if ReportType == "datewise"
            {
//                let date = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" //+zzzz"
//                dateFormatter.dateFormat = "yyyy-MM-dd"
                let str1 = dateFormatter.string(from: self.selectedFromDate)
                let res = dateFormatter.string(from: self.selectedToDate)
                let str2 = res.replacingOccurrences(of: "00:00:00", with: "23:59:59")
                
                dictData["FromDate"] = str1 as AnyObject //self.selectedFromDate as AnyObject
                dictData["ToDate"] =  str2 as AnyObject //self.selectedToDate as AnyObject
            }
            else
            {
                dictData["FromDate"] = self.selectedFromDatePAram as AnyObject
                dictData["ToDate"] = self.selectedToDatePAram as AnyObject
            }
        }
        else {
            dictData["Year"] = self.selectedYear as AnyObject
        }
        webserviceForMyEarnings(dictData as AnyObject) { (result, status) in
            if status {
                print(result)
                self.lblTotalEarningValue.text = "\(currency) \((result["driver_earning"] as! String))"
                
                self.result = result as? [String:Any] ?? [:]
                self.arrEarning = result["details"] as! [[String : AnyObject]]
                
                self.lblTotalEarning.text = "\(currency) \(self.result["driver_earning"]!)"
                self.lblTotalTripFare.text = "\(currency) \(self.result["total_trip_fare"]!)"
                self.lblTotalTripDuration.text = "\(self.result["total_trip_duration"]!)"
                self.lblTotalDistance.text = "\(Double("\(self.result["total_trip_distance"]!)")?.rounded(toPlaces: 2) ?? 0)"
                self.lblTotalTrips.text = "\(self.result["trip_count"]!)"
                
                self.tableView.reloadData()
            }
            else {
                print(result)
            }
        }
        
      /*  webserviceForDriverEarningReport(dictData as AnyObject) { (result, status) in
            if status {
                print(result)
                self.lblTotalEarningValue.text = "\(currency) \((result["driver_earning"] as! String))"
                
                self.result = result as? [String:Any] ?? [:]
                self.arrEarning = result["details"] as! [[String : AnyObject]]
                
                self.lblTotalEarning.text = "\(currency) \(self.result["driver_earning"]!)"
                self.lblTotalTripFare.text = "\(currency) \(self.result["total_trip_fare"]!)"
                self.lblTotalTripDuration.text = "\(self.result["total_trip_duration"]!)"
                self.lblTotalDistance.text = "\(Double("\(self.result["total_trip_distance"]!)")?.rounded(toPlaces: 2) ?? 0)"
                self.lblTotalTrips.text = "\(self.result["trip_count"]!)"
                
                self.tableView.reloadData()
            }
            else {
                print(result)
            }
        } */
        
    }
}


extension MyEarningsViewController : UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.arrEarning.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "MyEarningsTableViewCell") as! MyEarningsTableViewCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyEarningsTableViewCell", for: indexPath) as! MyEarningsTableViewCell
        cell.selectionStyle = .none
        
        cell.lblBookingIDTitle.text = "Booking Ids".localized
        cell.lblPassengerNameTitle.text = "Passenger Name".localized
        cell.lblDateTimeTitle.text = "Date & Time".localized
        cell.lblPickupLocationTitle.text = "Trip Duration".localized
        cell.lblDropoffLocationTitle.text = "Trip Distance".localized
        cell.lblEarnTitle.text = "Earn".localized
        
        let dictData = self.arrEarning[indexPath.row]
        
        //        CompanyAmount = "11.27";
        //        CreatedDate = "06-06-2019 06:41:33";
        //        Date = "06-06-2019 06:41:33";
        //        DropTime = "06-06-2019 18:42:21";
        //        DropoffLocation = "Science City Road, Sola, Ahmedabad, 380060, Gujarat, India";
        //        Id = 1032;
        //        PassengerName = "Bhavesh Odedra 2";
        //        PickupLocation = "Science City Road, Sola, Ahmedabad, 380060, Gujarat, India";
        //        PickupTime = "06-06-2019 18:42:09";
        
        cell.lblBookingID.text = " \(dictData["Id"] as! String)"
        cell.lblPassengerName.text = " \(dictData["PassengerName"] as! String)"
        cell.lblPickupLocation.text = " \(dictData["TripDuration"] as! String)"
        cell.lblDropoffLocation.text = " \(Double(dictData["TripDistance"] as! String)?.rounded(toPlaces: 2) ?? 0)"
//        let dateAndTime = (dictData["CreatedDate"] as! String).convertDateString(inputFormat: .dateWithSecondsButDaysFirst, outputFormat: .TwelveHours)
        
        
        cell.lblDateTime.text = " \(dictData["Date"] as! String)"
        cell.lblEarn.text = " \(currency) \(Double(dictData["CompanyAmount"] as! String)?.rounded(toPlaces: 2) ?? 0)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension //170
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension Date
{
    var startOfWeek: Date? {
        let gregorian = Calendar(identifier: .gregorian)
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
        return gregorian.date(byAdding: .day, value: 1, to: sunday)
    }
    
    func startOfMonth() -> Date {
        let components = Calendar.current.dateComponents([.year, .month], from: self)
        return Calendar.current.date(from: components)!
        //        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: self))!//([.year, .month], from: Calendar.current.startOfDay(for: self))
    }
}
