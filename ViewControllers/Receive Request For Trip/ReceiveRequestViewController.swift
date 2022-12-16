//
//  ReceiveRequestViewController.swift
//  TiCKTOC-Driver
//
//  Created by Excellent Webworld on 06/11/17.
//  Copyright © 2017 Excellent Webworld. All rights reserved.
//

import UIKit
import SRCountdownTimer
import NVActivityIndicatorView
import MarqueeLabel
import AVFoundation

class ReceiveRequestViewController: UIViewController, SRCountdownTimerDelegate {
    
    //-------------------------------------------------------------
    // MARK: - Outlets
    //-------------------------------------------------------------
    
    @IBOutlet weak var viewRequestReceive: UIView!
    
    @IBOutlet weak var lblReceiveRequest: UILabel!
    
    @IBOutlet weak var lblMessage: UILabel!
    
    //@IBOutlet weak var lblGrandTotal: UILabel!
    @IBOutlet weak var lblPickUpLocationInfo: UILabel!
    @IBOutlet weak var lblPickupLocation: MarqueeLabel!
    @IBOutlet weak var lblDropoffLocationInfo: UILabel!
    @IBOutlet weak var lblDropoffLocation: MarqueeLabel!
    @IBOutlet weak var lblDropoffLocation2Info: UILabel!
    @IBOutlet weak var lblDropoffLocation2: MarqueeLabel!
    @IBOutlet weak var lblPaymentType: UILabel!
    @IBOutlet weak var lblBookingType: UILabel!
    
    //    @IBOutlet weak var lblFlightNumber: UILabel!
    //    @IBOutlet weak var lblNotes: UILabel!
    
    @IBOutlet weak var strackviewOfDropOffLocation2: UIStackView!
    @IBOutlet weak var strackviewOfDropOffLocation: UIStackView!
    
    //    @IBOutlet weak var stackViewNotes: UIStackView!
    
    @IBOutlet weak var btnReject: UIButton!
    @IBOutlet weak var btnAccepted: UIButton!
    @IBOutlet weak var viewDetails: UIView!
    
    @IBOutlet weak var viewCountdownTimer: SRCountdownTimer!
    //    @IBOutlet var constratintHorizontalSpaceBetweenButtonAndTimer: NSLayoutConstraint!
    
    var isAccept : Bool!
    var delegate: ReceiveRequestDelegate!
    
    var strPickupLocation = String()
    var strDropoffLocation = String()
    var strDropoffLocation2 = String()
    var strGrandTotal = String()
    var strEstimateFare = String()
    var strRequestMessage = String()
    var strFlightNumber = String()
    var strPaymentType: String = ""
    var strBookingType: String = "Book Now"
    var strNotes = String()
    
    
    //-------------------------------------------------------------
    // MARK: - Base Methods
    //-------------------------------------------------------------
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.strackviewOfDropOffLocation.isHidden = true
        self.strackviewOfDropOffLocation2.isHidden = true
        
        CountDownView()
        
        btnReject.layer.cornerRadius = 5
        btnReject.layer.masksToBounds = true
        
        btnAccepted.layer.cornerRadius = 5
        btnAccepted.layer.masksToBounds = true
        
        btnAccepted.layer.borderWidth = 1
        btnAccepted.layer.borderColor = ThemeAppMainColor.cgColor
        
        boolTimeEnd = false
        isAccept = false
        
        //        self.playSound()
        
        fillAllFields()
        
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setLocalization()
    }
    
    func setLocalization(){
        lblReceiveRequest.text = "Receive Request".localized
        lblMessage.text = "New booking request arrived".localized
        lblPickUpLocationInfo.text = "Pick up location".localized
        lblDropoffLocationInfo.text = "Drop off location".localized
        btnReject.setTitle("Reject".localized, for: .normal)
        btnAccepted.setTitle("Accept".localized, for: .normal)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func CountDownView() {
        
        viewCountdownTimer.labelFont = UIFont(name: "HelveticaNeue-Light", size: 30.0)
        //                    self.timerView.timerFinishingText = "End"
        viewCountdownTimer.lineWidth = 4
        viewCountdownTimer.lineColor = UIColor.black
        viewCountdownTimer.trailLineColor = ThemeAppMainColor
        viewCountdownTimer.labelTextColor = UIColor.black
        viewCountdownTimer.delegate = self
        viewCountdownTimer.start(beginingValue: 30, interval: 1)
        //        lblMessage.text = "New booking request arrived from \(appName.kAPPName)"
        
    }
    
    func fillAllFields() {
        
        self.lblBookingType.text = "Booking Type : \((self.strBookingType == "BookLater") ? "Book Later" : "Book Now")"
        
        viewDetails.isHidden = false
        //            print(strGrandTotal)
        //            print(strPickupLocation)
        //            print(strDropoffLocation)
        //            print(strFlightNumber)
        //            print(strNotes)
        //            if strGrandTotal != "0" {
        //                lblGrandTotal.text = "Grand Total : \(strGrandTotal) \(currency)"
        //            } else if strEstimateFare != "0" {
       // lblGrandTotal.text = "\("Estimate Fare".localized) : \(strEstimateFare) \(currency)"
        //            }
        
      //  self.lblPaymentType.text = "Payment Type : \(strPaymentType)"
        lblMessage.text = strRequestMessage
        lblPickupLocation.text = strPickupLocation
        lblDropoffLocation.text = strDropoffLocation
        if(strDropoffLocation2.trimmingCharacters(in: .whitespacesAndNewlines) .count == 0)
        {
            strackviewOfDropOffLocation2.isHidden = true
        }
        else
        {
            strackviewOfDropOffLocation2.isHidden = false
            lblDropoffLocation2Info.text = "Additional Dropoff Location".localized
            lblDropoffLocation2.text = strDropoffLocation2

        }
    }
    
    func timerDidEnd() {
        
        if (isAccept == false)
        {
            if (boolTimeEnd) {
                self.dismiss(animated: true, completion: nil)
            }
            else {
                print(#function)
                self.delegate.didRejectedRequest(RejectByDriver: false)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    
    //-------------------------------------------------------------
    // MARK: - Sound Implement Methods
    //-------------------------------------------------------------
    
    var audioPlayer:AVAudioPlayer!
    
    func playSound() {
        
        //        guard let url = Bundle.main.url(forResource: "\(RingToneSound)", withExtension: "mp3") else { return }
        //
        //        do {
        //            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        //            try AVAudioSession.sharedInstance().setActive(true)
        //
        //            //            audioPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
        //            audioPlayer = try AVAudioPlayer(contentsOf: url)
        //            audioPlayer.numberOfLoops = 4
        //            audioPlayer.play()
        //        }
        //        catch let error {
        //            print(error.localizedDescription)
        //        }
    }
    
    func stopSound() {
        
        //        guard let url = Bundle.main.url(forResource: "\(RingToneSound)", withExtension: "mp3") else { return }
        //
        //        do {
        //            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        //            try AVAudioSession.sharedInstance().setActive(true)
        //
        //            audioPlayer = try AVAudioPlayer(contentsOf: url)
        //            audioPlayer.stop()
        //        }
        //        catch let error {
        //            print(error.localizedDescription)
        //        }
    }
    
    
    
    //-------------------------------------------------------------
    // MARK: - Actions
    //-------------------------------------------------------------
    
    var boolTimeEnd = Bool()
    
    @IBAction func btnRejected(_ sender: UIButton) {
        if Connectivity.isConnectedToInternet() == false {
            UtilityClass.showAlert("App Name".localized, message: "messageNotConnectedToInternet".localized, vc: self)
            return
        }
        
        Singletons.sharedInstance.firstRequestIsAccepted = false
        isAccept = false
        boolTimeEnd = true
        delegate.didRejectedRequest(RejectByDriver: true)
        self.viewCountdownTimer.end()
        //        self.stopSound()
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func btnAcceped(_ sender: UIButton) {
        if Connectivity.isConnectedToInternet() == false {
            UtilityClass.showAlert("App Name".localized, message: "messageNotConnectedToInternet".localized, vc: self)
            return
        }
        
        Singletons.sharedInstance.firstRequestIsAccepted = false
        
        isAccept = true
        boolTimeEnd = true
        delegate.didAcceptedRequest()
        self.viewCountdownTimer.end()
        self.stopSound()
        self.dismiss(animated: true, completion: nil)
    }
    // ------------------------------------------------------------
    
    
    
    
}
