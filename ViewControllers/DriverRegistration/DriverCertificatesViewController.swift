//
//  DriverCertificatesViewController.swift
//  TiCKTOC-Driver
//
//  Created by Excellent Webworld on 11/10/17.
//  Copyright © 2017 Excellent Webworld. All rights reserved.
//

import UIKit
import MobileCoreServices


class DriverCertificatesViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate,WWCalendarTimeSelectorProtocol  {

 

//    @IBOutlet var btnDone: UIButton!
    @IBOutlet weak var constraintHeightOfSmallView: NSLayoutConstraint! // 50
    @IBOutlet weak var constraintBottomOfButton: NSLayoutConstraint! // 128
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var lblHaveAnAccount: UILabel!
    
    @IBOutlet weak var btnNext: ThemeButton!
    
    let datePicker: UIDatePicker = UIDatePicker()
    
    var imagePicker = UIImagePickerController()
    var imagePicked = 0
    
    var userDefault = UserDefaults.standard
    
    var imgDriver = UIImage()
    var imgVehicle = UIImage()
    
    @IBOutlet weak var btnTermsSignUp: UIButton!
    @IBOutlet weak var txtTermsAndPrivacy: UITextView!

    var termsLink = "https://www.bookaridegy.com/TermsAndCondition"
    var PrivacyLink = "https://www.bookaridegy.com/PrivacyPolicy"

    //-------------------------------------------------------------
    // MARK: - Base Methods
    //-------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        giveShadow()
        
        if DeviceType.IS_IPHONE_4_OR_LESS || DeviceType.IS_IPAD {
            constraintHeightOfSmallView.constant = 40
            constraintBottomOfButton.constant = 80
        }
        
        imagePicker.delegate = self
        setupTextview()
/*
        imgDriverLicence.layer.cornerRadius = imgDriverLicence.frame.size.width / 2
        imgDriverLicence.layer.masksToBounds = true
        imgAccreditationCertifi.layer.cornerRadius = imgAccreditationCertifi.frame.size.width / 2
        imgAccreditationCertifi.layer.masksToBounds = true
        imgCarRegistration.layer.cornerRadius = imgCarRegistration.frame.size.width / 2
        imgCarRegistration.layer.masksToBounds = true
        imgVehicleInsurience.layer.cornerRadius = imgVehicleInsurience.frame.size.width / 2
        imgVehicleInsurience.layer.masksToBounds = true
*/
        
        
        
    }
    
    func setupTextview()
    {
        txtTermsAndPrivacy.text = "I agree with Terms & conditions and Privacy Policy"
                self.txtTermsAndPrivacy.hyperLink(originalText: "I agree with Terms & conditions and Privacy Policy",
                                                  linkTextsAndTypes: [("Terms & conditions"): termsLink,("Privacy Policy"): PrivacyLink])
                
                self.txtTermsAndPrivacy.delegate = self
                self.txtTermsAndPrivacy.textColor = .white
                self.txtTermsAndPrivacy.font = UIFont.regular(ofSize: 14)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       setLocalizable()
    }
    
 
    func setLocalizable()
    {
        self.title = "App Name".localized
        lblDriverLicence.text = "Driver Licence (Front & Back)".localized
        txtDriverLicence.placeholder =  "Select driver licence expiry date".localized
        lblAccreditation.text = "TIN Certificate".localized
//            "Revenue Licence".localized
        txtAccreditation.placeholder = "Select TIN Certificate expiry date".localized
//            "Select revenue licence expiry date".localized//Select Tin Certificate expiry day
        txtCarRegistraion.placeholder = "Vehicle Registration Document".localized
        txtVehicleInsurance.placeholder = "Select vehicle insurance/policy expiry date".localized
        lblVehicleInsurance.text = "Vehicle Insurance Policy/Certificate".localized
        btnNext.setTitle("Done".localized, for: .normal)
//        lblHaveAnAccount.text = "".localized
//        btnLogin.setTitle("".localized, for: .normal)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        btnNext.layer.cornerRadius = btnNext.frame.size.height/2
        btnNext.clipsToBounds = true
    }
   

    //-------------------------------------------------------------
    // MARK: - Outlets
    //-------------------------------------------------------------
    
    @IBOutlet var DriverLicenceView: UIView!    
    @IBOutlet var AccreditationView: UIView!
    @IBOutlet var carRegisView: UIView!
    @IBOutlet var VehicleInsuView: UIView!
    // ------------------------------------------------------------
    
    @IBOutlet weak var imgDriverLicence: UIImageView!
    @IBOutlet weak var imgDriverLicenceBack: UIImageView!
    @IBOutlet weak var imgAccreditationCertifi: UIImageView!
    @IBOutlet weak var imgCarRegistration: UIImageView!
    @IBOutlet weak var imgVehicleInsurience: UIImageView!
    
    // ------------------------------------------------------------
    
    @IBOutlet weak var lblDriverLicence: UILabel!
    @IBOutlet weak var lblAccreditation: UILabel!
    @IBOutlet weak var lblCarRegistraion: UILabel!
    @IBOutlet weak var lblVehicleInsurance: UILabel!
    
    @IBOutlet weak var txtDriverLicence: UITextField!
    @IBOutlet weak var txtAccreditation: UITextField!
    @IBOutlet weak var txtCarRegistraion: UITextField!
    @IBOutlet weak var txtVehicleInsurance: UITextField!
    
    // ------------------------------------------------------------
    @IBOutlet var btnDriverLicence: UIButton!
    @IBOutlet var btnDriverLicenceBack: UIButton!
    @IBOutlet var btnAccreditationCerti: UIButton!
    @IBOutlet var btnCarRegis: UIButton!
    @IBOutlet var btnVehicleInsu: UIButton!
    // ------------------------------------------------------------
    
    
    
    
    //-------------------------------------------------------------
    // MARK: - Actions
    //-------------------------------------------------------------
    
//    cellDetails.classView.layer.borderWidth = 1
//    cellDetails.classView.layer.masksToBounds = true
//    cellDetails.classView.layer.borderColor = UIColor.gray.cgColor
    
    
    
    @IBAction func btnDriverLicenceView(_ sender: UIButton) {
        
//        self.PickingImageFromGallery()
//        self.selectDate()
        
        let alert = UIAlertController(title: "Choose Photo".localized, message: nil, preferredStyle: .alert)
        
        let Gallery = UIAlertAction(title: "Select photo from gallery".localized
            , style: .default, handler: { ACTION in
            
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.mediaTypes = [kUTTypeImage as String]
//                UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
            
            self.imagePicked = sender.tag
            self.present(self.imagePicker, animated: true)
    
        })
        let Camera  = UIAlertAction(title: "Select photo from camera".localized, style: .default, handler: { ACTION in
            
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = UIImagePickerController.SourceType.camera
            self.imagePicker.cameraCaptureMode = .photo
 
            self.imagePicked = sender.tag
            self.present(self.imagePicker, animated: true)
                
           
        })
        let cancel = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)
        
        alert.addAction(Gallery)
        alert.addAction(Camera)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
   
   
    }
    @IBAction func btnDriverLicenceBackView(_ sender: UIButton) {
        
//        self.PickingImageFromGallery()
//        self.selectDate()
        
        let alert = UIAlertController(title: "Choose Photo".localized, message: nil, preferredStyle: .alert)
        
        let Gallery = UIAlertAction(title: "Select photo from gallery".localized
            , style: .default, handler: { ACTION in
            
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.mediaTypes = [kUTTypeImage as String]
//                UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
            
            self.imagePicked = sender.tag
            self.present(self.imagePicker, animated: true)
    
        })
        let Camera  = UIAlertAction(title: "Select photo from camera".localized, style: .default, handler: { ACTION in
            
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = UIImagePickerController.SourceType.camera
            self.imagePicker.cameraCaptureMode = .photo
 
            self.imagePicked = sender.tag
            self.present(self.imagePicker, animated: true)
                
           
        })
        let cancel = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)
        
        alert.addAction(Gallery)
        alert.addAction(Camera)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
   
   
    }
    
    @IBAction func btnClickTerms(_ sender : UIButton)
    {
        btnTermsSignUp.isSelected = !btnTermsSignUp.isSelected
    }
    
    @IBAction func btnAccreditationCertiView(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Choose Photo".localized
            , message: nil, preferredStyle: .alert)
        
        let Gallery = UIAlertAction(title: "Select photo from gallery".localized
            , style: .default, handler: { ACTION in
                //            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum){
                
                self.imagePicker.allowsEditing = false
                self.imagePicker.sourceType = .photoLibrary
                self.imagePicker.mediaTypes = [kUTTypeImage as String]
                //                    UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
                self.imagePicked = sender.tag
                self.present(self.imagePicker, animated: true)
                
                //            }
        })
        let Camera  = UIAlertAction(title: "Select photo from camera".localized ,style: .default, handler: { ACTION in
            
            
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = UIImagePickerController.SourceType.camera
            self.imagePicker.cameraCaptureMode = .photo
            
            
            self.imagePicked = sender.tag
            self.present(self.imagePicker, animated: true)
            
            
        })
        let Cancel = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)
        
        alert.addAction(Gallery)
        alert.addAction(Camera)
        alert.addAction(Cancel)
        self.present(alert, animated: true, completion: nil)
        
        
        
        
        //        alert()
    }
    
    @IBAction func btnCarRegisView(_ sender: UIButton) {
//        alert()
        
        let alert = UIAlertController(title: "Choose Photo".localized
, message: nil, preferredStyle: .alert)
        
        let Gallery = UIAlertAction(title: "Select photo from gallery".localized
, style: .default, handler: { ACTION in
            
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.mediaTypes = [kUTTypeImage as String]
//                UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
            
                self.imagePicked = sender.tag
                self.present(self.imagePicker, animated: true)
                
           
        })
        let Camera  = UIAlertAction(title: "Select photo from camera".localized
, style: .default, handler: { ACTION in
           
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = UIImagePickerController.SourceType.camera
            self.imagePicker.cameraCaptureMode = .photo
     
            self.imagePicked = sender.tag
            self.present(self.imagePicker, animated: true)
                
            
        })
        let cancel = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)
        
        alert.addAction(Gallery)
        alert.addAction(Camera)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func btnVehicleInsuView(_ sender: UIButton) {
//        alert()
        
        let alert = UIAlertController(title: "Choose Photo".localized
, message: nil, preferredStyle: .alert)
        
        let Gallery = UIAlertAction(title: "Select photo from gallery".localized
, style: .default, handler: { ACTION in
            
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.mediaTypes = [kUTTypeImage as String]
//                UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
            
            self.imagePicked = sender.tag
            self.present(self.imagePicker, animated: true)
        })
        let Camera  = UIAlertAction(title: "Select photo from camera".localized
, style: .default, handler: { ACTION in
            
            
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = UIImagePickerController.SourceType.camera
            self.imagePicker.cameraCaptureMode = .photo
            
            self.imagePicked = sender.tag
            self.present(self.imagePicker, animated: true)
        })
        let cancel = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)
        
        alert.addAction(Gallery)
        alert.addAction(Camera)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func alert()
    {
        let alert = UIAlertController(title: "App Name".localized, message: "This feature will comming soon.", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Dismiss".localized, style: .default, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }

    
    // ------------------------------------------------------------
    
    func PickingImageFromGallery()
    {
        let picker = UIImagePickerController()
        picker.delegate = self
        
        picker.allowsEditing = false
        picker.sourceType = .savedPhotosAlbum
        
        // picker.stopVideoCapture()
        picker.mediaTypes = [kUTTypeImage as String]
//            UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(picker, animated: true, completion: nil)
    }
    
    func PickingImageFromCamera()
    {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        
        present(picker, animated: true, completion: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let pickedImage  = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        let selector = WWCalendarTimeSelector.instantiate()
        
        // 2. You can then set delegate, and any customization options
        //        selector.delegate = self
        selector.optionTopPanelTitle = "Please add expiry date".localized
        
        // 3. Then you simply present it from your view controller when necessary!
        selector.delegate = self
        
        if pickedImage == nil
        {
            Utilities.showAlert("App Name".localized, message: "Please select Profile pic".localized, vc: (UIApplication.shared.keyWindow?.rootViewController)!)
        }
        else
        {
            if imagePicked == 1 {
                imgDriverLicence.image = pickedImage
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.present(selector, animated: true, completion: nil)
                }
            } else if imagePicked == 5 {
                imgDriverLicenceBack.image = pickedImage
               
            } else if imagePicked == 2 {
                imgAccreditationCertifi.image = pickedImage
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.present(selector, animated: true, completion: nil)
                }
            } else if imagePicked == 3 {
                imgCarRegistration.image = pickedImage
            } else if imagePicked == 4 {
                imgVehicleInsurience.image = pickedImage
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.present(selector, animated: true, completion: nil)
                }
            }
        }
        dismiss(animated: true)
       
//        UIView.animate(withDuration: 5.0, delay: 10.0, options: .transitionCurlUp, animations: {
//
//            self.Calendar()
//        }, completion: {_ in
//
//        })
        
//        let selector = WWCalendarTimeSelector.instantiate()
//
//
//        // 2. You can then set delegate, and any customization options
//        //        selector.delegate = self
//        selector.optionTopPanelTitle = "Please choose date"
//
//        // 3. Then you simply present it from your view controller when necessary!
//        self.present(selector, animated: true, completion: nil)
//        selector.delegate = self
//
        
//        Calendar()
        
        
        
        
//        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
//            imgDriverLicence.contentMode = .scaleToFill
//            imgDriverLicence.image = pickedImage
//
//        }
//        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func datePickerValueChanged(_ sender: UIDatePicker){
        
        // Create date formatter
        let dateFormatter: DateFormatter = DateFormatter()
        
        // Set date format
        dateFormatter.dateFormat = "yyyy/MM/dd"
        
        // Apply date format
        let selectedDate: String = dateFormatter.string(from: sender.date)
        
        txtDriverLicence.text = selectedDate
//        lblDriverLicence.isHidden = true
        datePicker.removeFromSuperview()
        print("Selected value \(selectedDate)")
    }
    
    
   
    //-------------------------------------------------------------
    // MARK: - Custom Methods
    //-------------------------------------------------------------

    func giveShadow()
    {
        DriverLicenceView.layer.borderWidth = 1
        DriverLicenceView.layer.masksToBounds = true
        DriverLicenceView.layer.borderColor = UIColor.gray.cgColor
        
        AccreditationView.layer.borderWidth = 1
        AccreditationView.layer.masksToBounds = true
        AccreditationView.layer.borderColor = UIColor.gray.cgColor
        
        carRegisView.layer.borderWidth = 1
        carRegisView.layer.masksToBounds = true
        carRegisView.layer.borderColor = UIColor.gray.cgColor
        
        VehicleInsuView.layer.borderWidth = 1
        VehicleInsuView.layer.masksToBounds = true
        VehicleInsuView.layer.borderColor = UIColor.gray.cgColor
        
        
//        DriverLicenceView.dropShadow(color: .gray, opacity: 1, offSet: CGSize(width: -1, height: 1), radius: 1, scale: true)
 //       AccreditationView.dropShadow(color: .gray, opacity: 1, offSet: CGSize(width: -1, height: 1), radius: 1, scale: true)
//        carRegisView.dropShadow(color: .gray, opacity: 1, offSet: CGSize(width: -1, height: 1), radius: 1, scale: true)
//        VehicleInsuView.dropShadow(color: .gray, opacity: 1, offSet: CGSize(width: -1, height: 1), radius: 1, scale: true)

    }
    
    func giveBorder(borderView: UIView) -> UIView
    {
        return borderView
    }
    
    @IBAction func btnNext(_ sender: Any) {
        
        if imgDriverLicence.image!.isEqualToImage(UIImage(named: "iconPlaceholderVehicle")!) {
            UtilityClass.showAlert("App Name".localized, message: "Please enter all document\'s detail.".localized, vc: self)
        } else if imgDriverLicenceBack.image!.isEqualToImage(UIImage(named: "iconPlaceholderVehicle")!) {
            UtilityClass.showAlert("App Name".localized, message: "Please enter all document\'s detail.".localized, vc: self)
        }else if imgCarRegistration.image!.isEqualToImage(UIImage(named: "iconPlaceholderVehicle")!) {
            UtilityClass.showAlert("App Name".localized, message: "Please enter all document\'s detail.".localized, vc: self)
        }else if imgVehicleInsurience.image!.isEqualToImage(UIImage(named: "iconPlaceholderVehicle")!) {
            
            UtilityClass.showAlert("App Name".localized, message: "Please enter all document\'s detail.".localized, vc: self)
            
        }
        else if (self.btnTermsSignUp.isSelected == false) {
            
            UtilityClass.showAlert("App Name".localized, message: "Please accept terms & condition and privacy policy".localized, vc: self)
            
        }
        else{
            getAllRegistrationData()
            self.webserviceForRegistration()
        }
        
        
      /*
         if imgDriverLicence.image == UIImage(named: "iconPlaceholderVehicle") {
            
            UtilityClass.showAlert("App Name".localized, message: "Please enter all document\'s detail.".localized, vc: self)
            
        }
        else if imgCarRegistration.image == UIImage(named: "iconPlaceholderVehicle") {
            
             UtilityClass.showAlert("App Name".localized, message: "Please enter all document\'s detail.".localized, vc: self)
            
        }
        else if imgVehicleInsurience.image == UIImage(named: "iconPlaceholderVehicle") {
            
            UtilityClass.showAlert("App Name".localized, message: "Please enter all document\'s detail.".localized, vc: self)

        }
        else if imgAccreditationCertifi.image == UIImage(named: "iconPlaceholderVehicle") {
            
            UtilityClass.showAlert("App Name".localized, message: "Please enter all document\'s detail.".localized, vc: self)
            
        }
        else
        {
            getAllRegistrationData()
            self.webserviceForRegistration()
        }
         */
        
    }
    
   
    let myDatePicker: UIDatePicker = UIDatePicker()
    func Calendar()
    {
        // make DatePicker
        
        
        // setting properties of the datePicker
        myDatePicker.frame = CGRect(x:0, y: 50,width: self.view.frame.width, height: 200)
        myDatePicker.timeZone = NSTimeZone.local
        myDatePicker.backgroundColor = UIColor.white
        myDatePicker.layer.cornerRadius = 5.0
        myDatePicker.layer.shadowOpacity = 0.5
        
        // add an event called when value is changed.
        myDatePicker.addTarget(self, action: #selector(self.onDidChangeDate(sender:)), for: .valueChanged)
        
        // add DataPicker to the view
        self.view.addSubview(myDatePicker)
    }
    
    // called when the date picker called.
    @objc internal func onDidChangeDate(sender: UIDatePicker){
        
        // date format
        let myDateFormatter: DateFormatter = DateFormatter()
        myDateFormatter.dateFormat = "yyyy/MM/dd"
        
        // get the date string applied date format
        let mySelectedDate: NSString = myDateFormatter.string(from: sender.date) as NSString
        
        
        if imagePicked == 1 {
            txtDriverLicence.text = mySelectedDate as String
//            lblDriverLicence.isHidden = true
            
        } else if imagePicked == 2 {
            txtAccreditation.text = mySelectedDate as String
//            lblAccreditation.isHidden = true
            
        }
//        else if imagePicked == 3 {
//            txtCarRegistraion.text = mySelectedDate as String
//
//        }
        else if imagePicked == 4 {
            txtVehicleInsurance.text = mySelectedDate as String
//            lblVehicleInsurance.isHidden = true
        }
        self.myDatePicker.removeFromSuperview()
    }
    
    // ------------------------------------------------------------
    
    var certiFicateDate = String()
    
    func WWCalendarTimeSelectorDone(_ selector: WWCalendarTimeSelector, date: Date)
    {
        let myDateFormatter: DateFormatter = DateFormatter()
        myDateFormatter.dateFormat = "yyyy/MM/dd"
        
        let finalDate = myDateFormatter.string(from: date)

        // get the date string applied date format
        let mySelectedDate = String(describing: finalDate)
        certiFicateDate = mySelectedDate
        
        if imagePicked == 1 {
            txtDriverLicence.text = mySelectedDate as String
//            lblDriverLicence.isHidden = true
            
        } else if imagePicked == 2 {
            txtAccreditation.text = mySelectedDate as String
//            lblAccreditation.isHidden = true
            
        }
//            else if imagePicked == 3 {
//            txtCarRegistraion.text = mySelectedDate as String
//
//        }
        else if imagePicked == 4 {
            txtVehicleInsurance.text = mySelectedDate as String
//            lblVehicleInsurance.isHidden = true
        }
        
        
        
    }
   
    //-------------------------------------------------------------
    // MARK: - Webservice Methods
    //-------------------------------------------------------------
    
    var dictData = [String:AnyObject]()
    
    func webserviceForRegistration()
    {
   
        webserviceForRegistrationForDriver(dictData as AnyObject, image1: imgDriverLicence.image!, image2: imgAccreditationCertifi.image!, image3: imgCarRegistration.image!, image4: imgVehicleInsurience.image!, image5: imgDriver, image6: imgVehicle,image7: imgDriverLicenceBack.image!) { (result, status) in
            
            
            // ------------------------------------------------------------
            
            if (status)
            {
                print(result)
                
                if ((result as! NSDictionary).object(forKey: "status") as! Int == 1)
                {
                    Singletons.sharedInstance.dictDriverProfile = NSMutableDictionary(dictionary: (result as! NSDictionary))
                    Singletons.sharedInstance.isDriverLoggedIN = true
                    
                    
                    Utilities.encodeDatafromDictionary(KEY: driverProfileKeys.kKeyDriverProfile, Param: Singletons.sharedInstance.dictDriverProfile)
//                    UserDefaults.standard.set(Singletons.sharedInstance.dictDriverProfile, forKey: driverProfileKeys.kKeyDriverProfile)
                    UserDefaults.standard.set(true, forKey: driverProfileKeys.kKeyIsDriverLoggedIN)
                    
                    let profileData = Singletons.sharedInstance.dictDriverProfile
                    
                    Singletons.sharedInstance.strDriverID = (profileData?.object(forKey: "profile") as! NSDictionary).object(forKey: "Id") as! String
                    
//                    let next = self.storyboard?.instantiateViewController(withIdentifier: "CustomSideMenuViewController") as! CustomSideMenuViewController
//                    self.navigationController?.pushViewController(next, animated: true)
                    
                    self.navigationController?.isNavigationBarHidden = true
                    self.performSegue(withIdentifier: "afterCompleteRegistration", sender: nil)
                    
                }
            }
            else
            {
              
                if let res = result as? String
                {
                    UtilityClass.showAlert("App Name".localized, message: res, vc: self)
                }
                else if result is NSDictionary
                {
                    UtilityClass.showAlert("App Name".localized, message: (((result as! [String:AnyObject])[GetResponseMessageKey()] as! NSArray).firstObject as! String), vc: self)//resDict.object(forKey: "message") as! String, vc: self)
                }
                else if let resAry = result as? NSArray {
                    UtilityClass.showAlert("App Name".localized, message: (resAry.object(at: 0) as! NSDictionary).object(forKey: GetResponseMessageKey()) as! String, vc: self)
                }
            }
            
        }
    }
//(lldb) po print(result)
//    {
//    message =     (
//    "Mobile Number already exists"
//    );
//    status = 0;
//    }

    
    
    func getAllRegistrationData()
    {
        if let mobileNo: String = (userDefault.object(forKey: RegistrationFinalKeys.kMobileNo) as? String)
        {
            dictData[RegistrationFinalKeys.kMobileNo] = mobileNo as AnyObject
        }
        if let email: String = userDefault.object(forKey: RegistrationFinalKeys.kEmail) as? String {
            dictData[RegistrationFinalKeys.kEmail] = email as AnyObject
        }
        if let password: String = (userDefault.object(forKey: RegistrationFinalKeys.kPassword) as? String)
        {
            dictData[RegistrationFinalKeys.kPassword] = password as AnyObject
        }
        if let firstname: String = (userDefault.object(forKey: RegistrationFinalKeys.kFirstname) as? String)
        {
            dictData[RegistrationFinalKeys.kFirstname] = firstname as AnyObject
        }
        if let lastname: String = (userDefault.object(forKey: RegistrationFinalKeys.kLastName) as? String)
        {
            dictData[RegistrationFinalKeys.kLastName] = lastname as AnyObject
        }
        if let gender: String = (userDefault.object(forKey: RegistrationFinalKeys.kGender) as? String)
        {
            dictData[RegistrationFinalKeys.kGender] = gender as AnyObject
        }
        
        
        if let address: String = (userDefault.object(forKey: RegistrationFinalKeys.kAddress) as? String)
        {
            dictData[RegistrationFinalKeys.kAddress] = address as AnyObject
        }
        
        
        if let BSB: String = userDefault.object(forKey: RegistrationFinalKeys.kBSB) as? String
        {
            dictData[RegistrationFinalKeys.kBSB] = BSB as AnyObject
        }
        if let BankName: String = userDefault.object(forKey: RegistrationFinalKeys.kBankName) as? String
        {
            dictData[RegistrationFinalKeys.kBankName] = BankName as AnyObject
        }
        if let BankAccountNo: String = userDefault.object(forKey: RegistrationFinalKeys.kBankAccountNo) as? String
        {
            dictData[RegistrationFinalKeys.kBankAccountNo] = BankAccountNo as AnyObject
        }
        if let bankHolederName: String = userDefault.object(forKey: RegistrationFinalKeys.kbankHolderName) as? String
        {
            dictData[RegistrationFinalKeys.kbankHolderName] = bankHolederName as AnyObject
        }
        
        
        
        
        if let vehicleRegistrationNumber: String = userDefault.object(forKey:
                                                                        RegistrationFinalKeys.kVehicleRegistrationNo) as? String
        {
            dictData[RegistrationFinalKeys.kVehicleRegistrationNo] = vehicleRegistrationNumber as AnyObject
        }
        if let vehicleCompanyModel: String = userDefault.object(forKey: RegistrationFinalKeys.kCompanyModel) as? String
        {
            dictData[RegistrationFinalKeys.kCompanyModel] = vehicleCompanyModel as AnyObject
        }
        
        
        if let vehicleClass: String = userDefault.object(forKey: RegistrationFinalKeys.kVehicleClass) as? String
        {
            dictData[RegistrationFinalKeys.kVehicleClass] = vehicleClass as AnyObject
        }
        if let vehicleModelName: String = userDefault.object(forKey: RegistrationFinalKeys.kVehicleModelName) as? String
        {
            dictData[RegistrationFinalKeys.kVehicleModelName] = vehicleModelName as AnyObject
        }
        if let passenger: String = userDefault.object(forKey: RegistrationFinalKeys.kNumberOfPasssenger) as? String
        {
            dictData[RegistrationFinalKeys.kNumberOfPasssenger] = passenger as AnyObject
        }
        
        if let vehicleColor: String = userDefault.object(forKey: RegistrationFinalKeys.kVehicleColor) as? String
        {
            dictData[RegistrationFinalKeys.kVehicleColor] = vehicleColor as AnyObject
        }
        //   }     let suburd: String = (userDefault.object(forKey: RegistrationFinalKeys.kSuburb) as? String)!
        //            dictData[RegistrationFinalKeys.kSuburb] = suburd as AnyObject
        
        if  let postcode: String = userDefault.object(forKey: RegistrationFinalKeys.kZipcode) as? String
        {
            dictData[RegistrationFinalKeys.kZipcode] = postcode as AnyObject
        }
        
        
        
        
        //
        
        //        message =     (
        //            "Please upload Vehicle Image",
        //            "Please enter no of passenger",
        //            "Please enter vehicle model name"
        //        );
        //        status = 0;
        
        
        //         let state: String = userDefault.object(forKey: RegistrationFinalKeys.kState) as! String
        //            dictData[RegistrationFinalKeys.kState] = state as AnyObject
        //
        //         let Country: String = userDefault.object(forKey: RegistrationFinalKeys.kCountry) as! String
        //            dictData[RegistrationFinalKeys.kCountry] = Country as AnyObject
        
        
        
        if let DOB: String = userDefault.object(forKey: RegistrationFinalKeys.kKeyDOB) as? String
        {
            dictData[RegistrationFinalKeys.kKeyDOB] = DOB as AnyObject
        }
        //
        //         let ABN: String = userDefault.object(forKey: RegistrationFinalKeys.kABN) as! String
        //            dictData[RegistrationFinalKeys.kABN] = ABN as AnyObject
        //
        //        let ServiceDescription = userDefault.object(forKey: RegistrationFinalKeys.kServiceDescription) as! String
        //            dictData[RegistrationFinalKeys.kServiceDescription] = ServiceDescription as AnyObject
        
        
        if let referralCode: String = userDefault.object(forKey: RegistrationFinalKeys.kReferralCode) as? String
        {
            dictData[RegistrationFinalKeys.kReferralCode] = referralCode as AnyObject
        }
        //        if let lat: String = userDefault.object(forKey: RegistrationFinalKeys.kLat) as? String {
        //             dictData[RegistrationFinalKeys.kLat] = lat as AnyObject
        //        } else {
        
        //        }
        
        //        if let lng: String = userDefault.object(forKey: RegistrationFinalKeys.kLng) as? String {
        //            dictData[RegistrationFinalKeys.kLng] = lng as AnyObject
        //        } else {
        
        //        }
        if self.navigationController?.children[(self.navigationController?.children.count ?? 0) - 1] is DriverRegistrationViewController {
            dictData[RegistrationFinalKeys.kLat] = "22.0236514" as AnyObject
            dictData[RegistrationFinalKeys.kLat] = "72.0236514" as AnyObject
        }
        
        
        //         let carModel: String = userDefault.object(forKey: profileKeys.kCarModel) as! String
        //            dictData[profileKeys.kCarModel] = carModel as AnyObject
        
        
        
        
        
        
        
        // --------------------
        
        if let driverDecodedImageData: NSData = NSKeyedUnarchiver.unarchiveObject(with: userDefault.object(forKey: RegistrationFinalKeys.kDriverImage) as! Data) as? NSData {
            let img: UIImage = UIImage(data: driverDecodedImageData as Data)!
            imgDriver = img
            
        }
        if let vehicleDecodedImageData: NSData = NSKeyedUnarchiver.unarchiveObject(with: userDefault.object(forKey: RegistrationFinalKeys.kVehicleImage) as! Data) as? NSData {
            let imgageVehicle: UIImage = UIImage(data: vehicleDecodedImageData as Data)!
            imgVehicle = imgageVehicle
        }
        
        //        let placesArray = NSKeyedUnarchiver.unarchiveObject(with: userDefault.object(forKey: RegistrationFinalKeys.kDriverImage) as! Data) as! NSData
        //        let image = UIImage(data: placesArray as Data)
        
        
        SetVehicleExpiryDates()
        
        
        dictData["DeviceType"] = "1" as AnyObject
        dictData["Token"] = Singletons.sharedInstance.deviceToken as AnyObject
    }
    
    func setPersonnelDetails()
    {
        
    }
    
    func SetVehicleExpiryDates()
    {
    
        let DriverLicenceExpiryDate = txtDriverLicence.text
        let CarRegistrationExpiryDate = txtCarRegistraion.text
        let AccreditationCertificateExpiryDate = txtAccreditation.text
//        lblAccreditation.isHidden = true
        let VehicleInsuranceCertificateExpiryDate = txtVehicleInsurance.text
        
//        lblDriverLicence.isHidden = true
//        lblVehicleInsurance.isHidden = true
        dictData[RegistrationFinalKeys.kDriverLicenceExpiryDate] = DriverLicenceExpiryDate as AnyObject
        dictData[RegistrationFinalKeys.kCarRegistrationExpiryDate] = CarRegistrationExpiryDate as AnyObject
        dictData[RegistrationFinalKeys.kAccreditationCertificateExpiryDate] = AccreditationCertificateExpiryDate as AnyObject
        dictData[RegistrationFinalKeys.kVehicleInsuranceCertificateExpiryDate] = VehicleInsuranceCertificateExpiryDate as AnyObject
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      
        if segue.destination is CustomSideMenuViewController {
            
        }
       
    }
  
    // ------------------------------------------------------------
}



//MARK: - TextView Delegate
extension DriverCertificatesViewController : UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let next = mainStoryboard.instantiateViewController(withIdentifier: "LegalWebPage") as! LegalWebPage
        next.headerName = "\(appName.kAPPName)"
        next.strURL = URL.absoluteString
//        next.isFromRegister = true
        next.navigationController?.isNavigationBarHidden = false
//        let myNavigationController = UINavigationController(rootViewController: next)
        self.navigationController?.pushViewController(next, animated: true)

        return false
    }
    
}

public extension UITextView {
    
    func hyperLink(originalText: String, linkTextsAndTypes: [String: String]) {
        
        let style = NSMutableParagraphStyle()
        style.alignment = .left
        
        let attributedOriginalText = NSMutableAttributedString(string: originalText)
        
        for linkTextAndType in linkTextsAndTypes {
            let linkRange = attributedOriginalText.mutableString.range(of: linkTextAndType.key)
            let fullRange = NSRange(location: 0, length: attributedOriginalText.length)
            attributedOriginalText.addAttribute(NSAttributedString.Key.link, value: linkTextAndType.value, range: linkRange)
            attributedOriginalText.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: fullRange)
            attributedOriginalText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: fullRange)
            attributedOriginalText.addAttribute(NSAttributedString.Key.font, value: UIFont.regular(ofSize: 14.0), range: fullRange)
        }
        
        self.linkTextAttributes = [
            kCTForegroundColorAttributeName: UIColor.blue,
            kCTUnderlineStyleAttributeName: NSUnderlineStyle.single.rawValue
        ] as [NSAttributedString.Key: Any]
        
        self.attributedText = attributedOriginalText
    }
}
