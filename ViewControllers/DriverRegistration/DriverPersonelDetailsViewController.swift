//
//  DriverPersonelDetailsViewController.swift
//  TiCKTOC-Driver
//
//  Created by Excellent Webworld on 11/10/17.
//  Copyright © 2017 Excellent Webworld. All rights reserved.
//

import UIKit
import CoreLocation
import PhotosUI
import MobileCoreServices
import DropDown

class DriverPersonelDetailsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, UITextFieldDelegate  {
    
    @IBOutlet var btnNext: UIButton!
    
    let manager = CLLocationManager()
    
    var currentLocation = CLLocation()
    
    var strLatitude = Double()
    var strLongitude = Double()
    
    var userDefault =  UserDefaults.standard
    
     let datePicker = UIDatePicker()
    var companyID = String()
     var emailID = String()
    var aryCompanyIDS = [[String:AnyObject]]()
    var arrDistrictData = [[String:AnyObject]]()
    var arrDistrictMainData : [String] = []
    
//        let myDatePicker: UIDatePicker = UIDatePicker()

    //-------------------------------------------------------------
    // MARK: - Outlets
    //-------------------------------------------------------------
    
    @IBOutlet var btnMale: UIButton!
    @IBOutlet var btnFemale: UIButton!
    @IBOutlet var btnOthers: UIButton!
    @IBOutlet weak var viewGender: UIView!
    @IBOutlet weak var imgProfile: UIImageView!
    
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtDOB: UITextField!
    @IBOutlet weak var txtAddress: UITextField!
    @IBOutlet weak var txtDistrict: UITextField!
    @IBOutlet weak var txtPostCode: UITextField!
   
    @IBOutlet weak var txtInviteCode: UITextField!

    @IBOutlet weak var constraintHeightOfAllTextFields: NSLayoutConstraint!
    @IBOutlet weak var constraintHeightOfProfileImage: NSLayoutConstraint!
    
    @IBOutlet weak var lblMale: UILabel!
    @IBOutlet weak var lblFemale: UILabel!
    @IBOutlet weak var lblHaveAnAccount: UILabel!
    @IBOutlet weak var bntLogin: UIButton!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SetLocalizable()
        NotificationCenter.default.addObserver(self, selector: #selector(changeLanguage), name: Notification.Name(rawValue: LCLLanguageChangeNotification), object: nil)
        self.webserviceCallToGetDistrictList()
    }
    
    @objc func changeLanguage(){
        self.SetLocalizable()
    }
    
    func SetLocalizable()
    {
        self.title = "App Name".localized

        txtFirstName.placeholder = "First Name".localized
        txtLastName.placeholder = "Last Name".localized
        txtAddress.placeholder = "Address".localized
        txtDistrict.placeholder = "District".localized
        lblMale.text = "Male".localized
        lblFemale.text = "Female".localized
        txtInviteCode.placeholder = "Referral Code (Optional)".localized
        btnNext.setTitle("Next".localized, for: .normal)
    }
   

    
    //-------------------------------------------------------------
    // MARK: - Base Methods
    //-------------------------------------------------------------
    
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        imgProfile.layer.cornerRadius = imgProfile.frame.size.width / 2
        imgProfile.layer.masksToBounds = true
        btnNext.layer.cornerRadius = btnNext.frame.size.height/2
        btnNext.clipsToBounds = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.txtDistrict.delegate = self
        txtDistrict.inputView = UIView()
        txtDistrict.inputAccessoryView = UIView()
        txtDistrict.tintColor = .white
        
        if DeviceType.IS_IPHONE_4_OR_LESS || DeviceType.IS_IPAD {
            constraintHeightOfAllTextFields.constant = 35
            constraintHeightOfProfileImage.constant = 55
        }
        
        showDatePicker()
        txtDOB.delegate = self
        txtPostCode.delegate = self
        
        strLatitude = 0
        strLongitude = 0
        
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            
            if manager.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization))
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
        
        selectedMale()
    }

    func showDatePicker(){
        //Formate Date
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Date()
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        
        //done button & cancel button
        let doneButton = UIBarButtonItem(title: "Done".localized, style: .done, target: self, action: #selector(donedatePicker))//"donedatePicker"
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel".localized, style: .done, target: self, action: #selector(cancelDatePicker))
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        
        // add toolbar to textField
        txtDOB.inputAccessoryView = toolbar
        // add datepicker to textField
        txtDOB.inputView = datePicker
        
    }
    @objc func donedatePicker(){
        //For date formate
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        txtDOB.text = formatter.string(from: datePicker.date)
        //dismiss date picker dialog
        self.view.endEditing(true)
    }

    @objc func cancelDatePicker()
    {
        //cancel button dismiss datepicker dialog
        self.view.endEditing(true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func DistrictDropdownSetup() {
        let dropDown = DropDown()
        dropDown.anchorView = self.txtDistrict
        dropDown.dataSource = self.arrDistrictMainData
        dropDown.show()
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            self.txtDistrict.text = self.arrDistrictMainData[index]
            dropDown.hide()
        }
        dropDown.width = self.txtDistrict.frame.width
        self.view.endEditing(true)
    }
    
    //-------------------------------------------------------------
    // MARK: - Actions
    //-------------------------------------------------------------
    
 
    @IBAction func btnMale(_ sender: UIButton) {
        selectedMale()
    }
    @IBAction func btnFemale(_ sender: UIButton) {
        selectedFemale()
    }
//    @IBAction func btnOthers(_ sender: UIButton) {
//        selectedOthers()
//    }
    
    
    func selectedMale()
    {
        btnMale.setImage(UIImage(named: "iconRadioSelected"), for: .normal)
        btnFemale.setImage(UIImage(named: "iconRadioUnSelected"), for: .normal)
//        btnOthers.setImage(UIImage(named: "iconCheckMarkUnSelected"), for: .normal)
    }
    func selectedFemale()
    {
        btnMale.setImage(UIImage(named: "iconRadioUnSelected"), for: .normal)
        btnFemale.setImage(UIImage(named: "iconRadioSelected"), for: .normal)
//        btnOthers.setImage(UIImage(named: "iconCheckMarkUnSelected"), for: .normal)
    }
//    func selectedOthers()
//    {
//        btnMale.setImage(UIImage(named: "iconRadioUnSelected"), for: .normal)
//        btnFemale.setImage(UIImage(named: "iconRadioUnSelected"), for: .normal)
////        btnOthers.setImage(UIImage(named: "iconCheckMarkSelected"), for: .normal)
//    }
    
    @IBAction func btnNext(_ sender: Any)
    {
        let validator = checkFields()
        if validator.0 == true {
            setData()
        } else {
            let ValidationAlert = UIAlertController(title: "App Name".localized, message: validator.1, preferredStyle: UIAlertController.Style.alert)
            ValidationAlert.addAction(UIAlertAction(title: "Dismiss".localized, style: .cancel, handler: nil))
            self.present(ValidationAlert, animated: true, completion: nil)
        }
    }
    @IBAction func btnLogin(_ sender: Any)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        
        navigationController?.pushViewController(vc, animated: true)
//        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func TapToProfilePicture(_ sender: UITapGestureRecognizer) {
        
        UtilityClass.showAlertWithCompletion("Info Message!".localized, message: "Please take a clear passport sized picture!".localized, vc: self) { success in
            let alert = UIAlertController(title: "Choose Photo".localized, message: nil, preferredStyle: .alert)
            
            let Gallery = UIAlertAction(title: "Select photo from gallery".localized
                                        , style: .default, handler: { ACTION in
                self.PickingImageFromGallery()
            })
            let Camera  = UIAlertAction(title: "Select photo from camera".localized
                                        , style: .default, handler: { ACTION in
                self.PickingImageFromCamera()
            })
            let cancel = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)
            
            alert.addAction(Gallery)
            alert.addAction(Camera)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }
        
        
        
    }
    
    
    func PickingImageFromGallery()
    {
        
        PHPhotoLibrary.requestAuthorization { status in
            
            
            switch status {
            case .authorized:
                DispatchQueue.main.async {
                    let picker = UIImagePickerController()
                    picker.delegate = self
                    
                    picker.allowsEditing = false
                    picker.sourceType = .photoLibrary
                    picker.mediaTypes = [(kUTTypeImage as String)]
                    self.present(picker, animated: true, completion: nil)
                }
            case .limited:
                DispatchQueue.main.async {
                    let picker = UIImagePickerController()
                    picker.delegate = self
                    
                    picker.allowsEditing = false
                    picker.sourceType = .photoLibrary
                    picker.mediaTypes = [(kUTTypeImage as String)]
                    self.present(picker, animated: true, completion: nil)
                }
            case .restricted:
                break
            //                   showRestrictedAccessUI()
            
            case .denied:
                DispatchQueue.main.async {
                    
                    let alert = UIAlertController(title: "Photos", message: "Photo access is absolutely necessary to use this app", preferredStyle: .alert)
                    
                    // Add "OK" Button to alert, pressing it will bring you to the settings app
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    }))
                    
                    alert.addAction(UIAlertAction(title: "Will do later", style: .default, handler: { action in
                    }))
                    // Show the alert with animation
                    self.present(alert, animated: true)
                }
            //                   showAccessDeniedUI()
            
            case .notDetermined:
                break
                
            @unknown default:
                break
            }
        }
    }
    
    func PickingImageFromCamera()
    {
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            let alertController = UIAlertController(title: nil, message: "Device has no camera.", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "Alright", style: .default, handler: { (alert: UIAlertAction!) in
            })
            
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else
        {
            
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
                if response {
                    DispatchQueue.main.async {
                        let picker = UIImagePickerController()
                        
                        picker.delegate = self
                        picker.allowsEditing = false
                        picker.sourceType = .camera
                        picker.cameraCaptureMode = .photo
                        
                        self.present(picker, animated: true, completion: nil)
                    }
                } else {
                    DispatchQueue.main.async {
                        
                        let alert = UIAlertController(title: "Camera", message: "Camera access is absolutely necessary to use this app", preferredStyle: .alert)
                        
                        // Add "OK" Button to alert, pressing it will bri≥ng you to the settings app
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                        }))
                        
                        alert.addAction(UIAlertAction(title: "Will do later", style: .default, handler: { action in
                        }))
                        // Show the alert with animation
                        self.present(alert, animated: true)
                    }
                }
            }
        }
    }
    
    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
            imgProfile.contentMode = .scaleAspectFill
            imgProfile.image = pickedImage
            
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func saveAllDataInArray() -> NSMutableArray {
        
        let arrData = NSMutableArray()
        let dictData = NSMutableDictionary()
        
        dictData.setObject(txtFirstName.text!, forKey: RegistrationProfileKeys.kKeyFullName as NSCopying)
        dictData.setObject(txtDOB.text!, forKey: RegistrationProfileKeys.kKeyDOB as NSCopying)
        dictData.setObject(txtAddress.text!, forKey: RegistrationProfileKeys.kKeyAddress as NSCopying)
        dictData.setObject(txtDistrict.text!, forKey: RegistrationProfileKeys.kKeyDistrict as NSCopying)
        dictData.setObject(txtPostCode.text!, forKey: RegistrationProfileKeys.kKeyPostCode as NSCopying)
        dictData.setObject(txtInviteCode.text!, forKey: RegistrationProfileKeys.kKeyInviteCode as NSCopying)
        dictData.setObject(imgProfile.image!.pngData() as Any, forKey: RegistrationFinalKeys.kDriverImage as NSCopying)
        
        arrData.add(dictData)
        
        
        return arrData
  
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print(error)
        
    }
    
    func checkFields() -> (Bool,String)
    {
        var isValidate:Bool = true
        var ValidatorMessage:String = ""
        
//        let sb = Snackbar()
//        sb.createWithAction(text: "Upload Car Registration", actionTitle: "Dismiss".localized, action: { print("Button is push") })
        if imgProfile.image!.isEqualToImage(UIImage(named: "iconUsers") ?? UIImage()) {
            isValidate = false
            ValidatorMessage = "Choose Photo".localized
        }
       else if txtFirstName.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) == "" {
            isValidate = false
            ValidatorMessage = "Please enter user name".localized
//            sb.createWithAction(text: "Please enter user name".localized, actionTitle: "Dismiss".localized, action: { print("Button is push") })
        }
//        else if txtDOB.text == "" {
//            sb.createWithAction(text: "Enter Date of Birth", actionTitle: "Dismiss".localized, action: { print("Button is push") })
//        }
        else if txtAddress.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) == "" {
            isValidate = false
            ValidatorMessage = "Please enter address".localized
//             sb.createWithAction(text: , actionTitle: "Dismiss".localized, action: { print("Button is push") })
        }
        
        else if txtDistrict.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) == "" {
            isValidate = false
            ValidatorMessage = "Please enter district".localized
//             sb.createWithAction(text: , actionTitle: "Dismiss".localized, action: { print("Button is push") })
        }
      
//        else if txtPostCode.text == "" {
//            sb.createWithAction(text: "Enter Post Code", actionTitle: "Dismiss".localized, action: { print("Button is push") })
//        }
      
        else if imgProfile.image == UIImage(named: "iconProfileLocation") {
            isValidate = false
            ValidatorMessage = "Choose Photo".localized
//            sb.createWithAction(text: "Choose Photo".localized, actionTitle: "Dismiss".localized, action: { print("Button is push") })
        }
       
        
//        sb.show()
        return (isValidate,ValidatorMessage)
    }
    
    func setDataForProfile()
    {
//        txtEmail.text = userDefault.object(forKey: RegistrationFinalKeys.kEmail) as? String
//        aryCompanyIDS = userDefault.object(forKey: OTPCodeStruct.kCompanyList) as! [[String : AnyObject]]
//        thePicker.reloadAllComponents()
//
//
//        txtCompanyId.text = aryCompanyIDS[0]["CompanyName"] as? String
//        companyID = (aryCompanyIDS[0]["Id"] as? String)!
//        txtCity.text = aryCompanyIDS[0]["City"] as? String
//        txtState.text = aryCompanyIDS[0]["State"] as? String
//        txtCountry.text = aryCompanyIDS[0]["Country"] as? String
    }
    
    func setData()
    {
       
        
        let imageData: NSData = imgProfile.image!.pngData()! as NSData
        let myEncodedImageData: NSData = NSKeyedArchiver.archivedData(withRootObject: imageData) as NSData
        userDefault.set(myEncodedImageData, forKey: RegistrationFinalKeys.kDriverImage)
        
        let image = UIImage(data: imageData as Data)
        imgProfile.image = image
        
        userDefault.set(txtDOB.text, forKey: RegistrationFinalKeys.kKeyDOB)
        
        userDefault.set(txtFirstName.text, forKey: RegistrationFinalKeys.kFirstname)
        userDefault.set(txtLastName.text, forKey: RegistrationFinalKeys.kLastName)
        userDefault.set(txtAddress.text, forKey: RegistrationFinalKeys.kAddress)
        userDefault.set(txtDistrict.text, forKey: RegistrationFinalKeys.kDistrict)
        userDefault.set(txtInviteCode.text, forKey: RegistrationFinalKeys.kReferralCode)
        userDefault.set(strLatitude, forKey: RegistrationFinalKeys.kLat)
        userDefault.set(strLongitude, forKey: RegistrationFinalKeys.kLng)
        userDefault.set(txtPostCode.text, forKey: RegistrationFinalKeys.kZipcode)

        
        
        if (btnMale.currentImage?.isEqual(UIImage(named: "iconRadioSelected")))! {
            userDefault.set("Male", forKey: RegistrationFinalKeys.kGender)
        }
        else if (btnFemale.currentImage?.isEqual(UIImage(named: "iconRadioSelected")))! {
            userDefault.set("Female", forKey: RegistrationFinalKeys.kGender)
        }
        else if (btnOthers.currentImage?.isEqual(UIImage(named: "iconRadioSelected")))! {
            userDefault.set("Other", forKey: RegistrationFinalKeys.kGender)
        }
        else {
            userDefault.set("Male", forKey: RegistrationFinalKeys.kGender)
        }


        navigateToNext()
    }
  
    func navigateToNext()
    {
         UserDefaults.standard.set(2, forKey: savedDataForRegistration.kPageNumber)
        let driverVC = self.navigationController?.viewControllers.last as! DriverRegistrationViewController
        let x = self.view.frame.size.width * 2
        driverVC.scrollObj.setContentOffset(CGPoint(x:x, y:0), animated: true)
        driverVC.viewTwo.backgroundColor = ThemeAppMainColor
//        let driverVC = self.navigationController?.viewControllers.last as! DriverRegistrationViewController
        driverVC.viewDidLayoutSubviews()
//        driverVC.imgBank.image = UIImage.init(named: iconBankSelect)
//        if (self.saveAllDataInArray().count != 0)
//        {
//            UserDefaults.standard.set(self.saveAllDataInArray(), forKey: savedDataForRegistration.kKeyAllUserDetails)
//        }
       
    }
    
    // For Mobile Number
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == txtDistrict {
            return false
        }
        
        
        if textField == txtPostCode {
            let resText: String? = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
            
            if resText!.count >= 9 {
                return false
            }
            else {
                return true
            }
        }
        
        return true
    }
  
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
//        if textField == txtDOB
//        {
//            self.view.endEditing(true)
//            Calendar()
//            return false
//        }
        
        if textField == txtDistrict
        {
            self.view.endEditing(true)
            return true
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == txtDistrict {
            self.DistrictDropdownSetup()
        }
    }
    

    func Calendar()
    {
        // make DatePicker
        
        
        // setting properties of the datePicker
//        myDatePicker.frame = CGRect(x:0, y: 50,width: self.view.frame.width, height: 200)
//        myDatePicker.timeZone = NSTimeZone.local
//        myDatePicker.backgroundColor = UIColor.white
//        myDatePicker.layer.cornerRadius = 5.0
//        myDatePicker.layer.shadowOpacity = 0.5
//        myDatePicker.datePickerMode = .date
//        // add an event called when value is changed.
//        myDatePicker.addTarget(self, action: #selector(self.onDidChangeDate(sender:)), for: .valueChanged)
//
//        // add DataPicker to the view
//        self.view.addSubview(myDatePicker)
    }
    
    // called when the date picker called.
    internal func onDidChangeDate(sender: UIDatePicker){
        
        // date format
//        let myDateFormatter: DateFormatter = DateFormatter()
//        myDateFormatter.dateFormat = "yyyy/MM/dd"
//        
//        // get the date string applied date format
//        let mySelectedDate: NSString = myDateFormatter.string(from: sender.date) as NSString
//        txtDOB.text = mySelectedDate as String
//        
//        self.myDatePicker.removeFromSuperview()
    }
    
}

extension DriverPersonelDetailsViewController {
    func webserviceCallToGetDistrictList() {
        webserviceForDistrictList([] as AnyObject) { (data, status) in
            if(status)
            {
                self.arrDistrictData = (data as! NSDictionary).object(forKey: "details") as! [[String : AnyObject]]
                let count = self.arrDistrictData.count
                for i in (0 ..< count - 1){
                    self.arrDistrictMainData.append(self.arrDistrictData[i]["Name"] as? String ?? "")
                }
                print(self.arrDistrictMainData)
                
            } else  {
                if let res = data as? String {
                    UtilityClass.showAlert("App Name".localized, message: res, vc: self)
                }
                else if let resDict = data as? NSDictionary {
                    UtilityClass.showAlert("App Name".localized, message: resDict.object(forKey: GetResponseMessageKey()) as! String, vc: self)
                }
                else if let resAry = data as? NSArray {
                    UtilityClass.showAlert("App Name".localized, message: (resAry.object(at: 0) as! NSDictionary).object(forKey: GetResponseMessageKey()) as! String, vc: self)
                }
            }
        }
    }
}

