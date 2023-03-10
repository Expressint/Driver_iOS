//
//  ChatVC.swift
//  KeepusPostd
//
//  Created by Tej P on 20/07/22.
//  Copyright © 2022 Nathan Osume. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import SDWebImage

class ChatVC: ParentViewController {
    
    @IBOutlet weak var tblData: UITableView!
    @IBOutlet weak var constraintBottomOfChatBG: NSLayoutConstraint!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var btnSendImage: UIButton!
    @IBOutlet weak var txtMessage: UITextView!
    
    @IBOutlet weak var lblNavName: UILabel!
    @IBOutlet weak var lblNavBack: UIButton!
    @IBOutlet weak var vwTopHeight: NSLayoutConstraint!
    
    @IBOutlet weak var vwIsTyping: UIView!
    @IBOutlet weak var lblTyping: UILabel!
    var timer: Timer?
    
    var receiverName: String = ""
    var receiverId: String = ""
    var bookingId: String = ""
    var bookingType: String = ""
    var aryData = [[String:AnyObject]]()
    var isDispacherChat: Bool = false
    var isFromPush: Bool = false
    let socket = (UIApplication.shared.delegate as! AppDelegate).SManager.defaultSocket
    private var imagePicker: ImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.socketMethods()
        self.setupUI()
        self.getAllMessage()
        AppDelegate.shared.currentChatID = receiverId
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadScreen(_:)), name: NSNotification.Name(rawValue: "ReloadChatScreen"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.btnSendImage.isHidden = (isDispacherChat) ? false : true
        self.vwIsTyping.isHidden = true
        
        AppDelegate.shared.isChatVisible = true
        let topBarHeight = UIApplication.shared.statusBarFrame.size.height + (self.navigationController?.navigationBar.frame.height ?? 0.0)
        self.vwTopHeight.constant = topBarHeight
        
        self.setupKeyboard(false)
        self.hideKeyboard()
        self.registerForKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AppDelegate.shared.isChatVisible = false
        AppDelegate.shared.currentChatID = ""
        self.setupKeyboard(true)
        self.deregisterFromKeyboardNotifications()
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.enable = true
    }
    
    @objc func reloadScreen(_ notification: NSNotification) {
        self.bookingId = notification.userInfo?["booking_id"] as? String ?? ""
        self.receiverId = notification.userInfo?["receiver_Id"] as? String ?? ""
        self.isDispacherChat = notification.userInfo?["isDispacherChat"] as? Bool ?? false
        AppDelegate.shared.currentChatID = receiverId
        self.isFromPush = true
        self.getAllMessage()
    }
    
    func setupUI(){
        self.imagePicker = ImagePickerController(presentationController: self, delegate: self)
        self.lblNavName.text = receiverName
        
        txtMessage.delegate = self
        txtMessage.text = "Enter Message..".localized
        txtMessage.textColor = UIColor.black
        
        self.tblData.delegate = self
        self.tblData.dataSource = self
        self.tblData.separatorStyle = .none
        self.tblData.showsVerticalScrollIndicator = false
        self.tblData.showsHorizontalScrollIndicator = false
        
        self.registerNib()
        self.tblData.reloadData()
    }
    
    func setupHeader(name: String, receiverID: String) {
        self.lblNavName.text = name
        self.receiverId = receiverID
    //    AppDelegate.shared.currentChatID = receiverId
    }
    
    func registerNib(){
        let nib = UINib(nibName: SenderCell.className, bundle: nil)
        self.tblData.register(nib, forCellReuseIdentifier: SenderCell.className)
        let nib2 = UINib(nibName: ReceiverCell.className, bundle: nil)
        self.tblData.register(nib2, forCellReuseIdentifier: ReceiverCell.className)
    }
    
    func socketMethods()
    {
        if(self.socket.status == .connected) {
            self.connectDriverForChat()
            self.socketOnForReceiveMessage()
            self.socketOnForStartTyping()
            self.socketOnForStopTyping()
            UtilityClass.hideACProgressHUD()
        }else{
            var isSocketConnected = Bool()
            socket.on(clientEvent: .disconnect) { (data, ack) in
                print ("socket? is disconnected please reconnect")
            }
            
            socket.on(clientEvent: .reconnect) { (data, ack) in
                print ("socket? is reconnected")
            }
            
            socket.on(clientEvent: .connect) { data, ack in
                
               print("socket? connected")
                
                if self.socket.status != .connected {
                    print("socket?.status != .connected")
                }
                
                if (isSocketConnected == false) {
                    isSocketConnected = true
                    self.connectDriverForChat()
                    self.socketOnForReceiveMessage()
                    self.socketOnForStartTyping()
                    self.socketOnForStopTyping()
                }
            }
            socket.connect()
        }
    }
    
    func socketOnForStartTyping() {
        self.socket.on(socketApiKeys.starTyping, callback: { (data, ack) in
            print ("response is : \(data)")
            
            let dictData = (data as NSArray).object(at: 0) as! [String : AnyObject]
            let senderType = dictData["sender_type"] as? String ?? ""
            let senderTName = dictData["sender_fullname"] as? String ?? self.receiverName
            
            if(self.isDispacherChat){
                if(senderType == "dispatcher"){
                    //self.lblTyping.text = "\(self.receiverName) is typing..."
                    self.lblTyping.text = "\(senderTName) is typing..."
                    self.vwIsTyping.isHidden = false
                    self.scrollToBottom()
                }
            }else{
                if(senderType != "dispatcher"){
                    //self.lblTyping.text = "\(self.receiverName) is typing..."
                    self.lblTyping.text = "\(senderTName) is typing..."
                    self.vwIsTyping.isHidden = false
                    self.scrollToBottom()
                }
            }
        })
    }
    
    func socketOnForStopTyping() {
        self.socket.on(socketApiKeys.stopTyping, callback: { (data, ack) in
            print ("response is : \(data)")
            
            let dictData = (data as NSArray).object(at: 0) as! [String : AnyObject]
            let senderType = dictData["sender_type"] as? String ?? ""
            if(self.isDispacherChat){
                if(senderType == "dispatcher"){
                    self.vwIsTyping.isHidden = true
                    self.scrollToBottom()
                }
            }else{
                if(senderType != "dispatcher"){
                    self.vwIsTyping.isHidden = true
                    self.scrollToBottom()
                }
            }
        })
    }
    
    func emitForStartTyping(){
        let myJSON = ["sender_id" : Singletons.sharedInstance.strDriverID,
                      "receiver_id": receiverId,
                      "message" : self.txtMessage.text ?? "",
                      "sender_type" : "driver",
                      "receiver_type" : (isDispacherChat) ? "dispatcher" : "passenger"] as [String : Any]
        
        self.socket.emit(socketApiKeys.DriverTyping, with: [myJSON], completion: nil)
        print ("\(socketApiKeys.DriverTyping) : \(myJSON)")
    }
    
    func emitForStopTyping(){
        let myJSON = ["sender_id" : Singletons.sharedInstance.strDriverID,
                      "receiver_id": self.receiverId,
                      "message" : self.txtMessage.text ?? "",
                      "sender_type" : "driver",
                      "receiver_type" : (self.isDispacherChat) ? "dispatcher" : "passenger"] as [String : Any]
        
        self.socket.emit(socketApiKeys.DriverStopTyping, with: [myJSON], completion: nil)
        print ("\(socketApiKeys.DriverStopTyping) : \(myJSON)")
    }

    func socketOnForReceiveMessage() {
        self.socket.on(socketApiKeys.receiveMessage, callback: { (data, ack) in
            print ("Chat response is : \(data)")
            let dictData = (data as NSArray).object(at: 0) as! [String : AnyObject]
            let senderId = dictData["sender_id"] as? String ?? ""
            
            if(senderId == self.receiverId || senderId == Singletons.sharedInstance.strDriverID){
              //  AppDelegate.shared.currentChatID = senderId
                self.aryData.append(dictData)
                self.tblData.reloadData()
                self.scrollToBottom()
            }
        })
    }
    
    func scrollToBottom(){
        DispatchQueue.main.async {
            if self.aryData.count > 1 {
                let indexPath = IndexPath(row: self.aryData.count-1, section: 0)
                self.tblData.scrollToRow(at: indexPath, at: .bottom, animated: false)
            }
        }
    }
    
    func connectDriverForChat() {
        let myJSON = ["DriverId" : Singletons.sharedInstance.strDriverID] as [String : Any]
        
        self.socket.emit(socketApiKeys.connectDriverForChat, with: [myJSON], completion: nil)
        print ("\(socketApiKeys.connectDriverForChat) : \(myJSON)")
    }
    
    func sendMessage() {
        self.emitForStopTyping()
        let myJSON = ["sender_id" : Singletons.sharedInstance.strDriverID,
                      "receiver_id": receiverId,
                      "message" : self.txtMessage.text ?? "",
                      "msg_type" : "text",
                      "imageUrl" : "",
                      "sender_type" : "driver",
                      "receiver_type" : (isDispacherChat) ? "dispatcher" : "passenger",
                      "booking_id" : (isDispacherChat) ? "" : bookingId,
                      "booking_type": (isDispacherChat) ? "" : bookingType] as [String : Any]
        
        self.socket.emit(socketApiKeys.sendMessage, with: [myJSON], completion: nil)
        print ("\(socketApiKeys.sendMessage) : \(myJSON)")
        txtMessage.text = "Enter Message..".localized
        txtMessage.textColor = UIColor.black
        self.view.endEditing(true)
    }
    
    func sendImgMessage(strUrl: String) {
        let myJSON = ["sender_id" : Singletons.sharedInstance.strDriverID,
                      "receiver_id": receiverId,
                      "message" : "",
                      "msg_type" : "image",
                      "imageUrl" : strUrl,
                      "sender_type" : "driver",
                      "receiver_type" : (isDispacherChat) ? "dispatcher" : "passenger",
                      "booking_id" : (isDispacherChat) ? "" : bookingId,
                      "booking_type": (isDispacherChat) ? "" : bookingType] as [String : Any]
        
        self.socket.emit(socketApiKeys.sendMessage, with: [myJSON], completion: nil)
        print ("\(socketApiKeys.sendMessage) : \(myJSON)")
        txtMessage.text = "Enter Message..".localized
        txtMessage.textColor = UIColor.black
        self.view.endEditing(true)
    }
    
    func convertDate(strDate: String) -> String{
        let PickDate = Double(strDate)
        guard let unixTimestamp1 = PickDate else { return "" }
        let date1 = Date(timeIntervalSince1970: TimeInterval(unixTimestamp1))
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "yyyy/MM/dd  HH:mm"
        let strDate1 = dateFormatter1.string(from: date1)
        return strDate1
    }
    
    func openImage(strImage: String) {
        let NextPage = self.storyboard?.instantiateViewController(withIdentifier: "ChatImageViewVC") as! ChatImageViewVC
        NextPage.strUrl = strImage
        NextPage.modalPresentationStyle = .formSheet
        self.present(NextPage, animated: true, completion: nil)
    }
    
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func btnSendAction(_ sender: Any) {
        if(self.txtMessage.text.trimmingCharacters(in: .whitespaces) != "" && self.txtMessage.text != "Enter Message..".localized){
            self.sendMessage()
        }else{
            UtilityClass.showAlert("Missing".localized, message:  "Please enter message".localized, vc: self)
        }
    }
    
    @IBAction func btnImgSendAction(_ sender: UIButton) {
        self.imagePicker.present(from: sender)
    }
    
}

// MARK: - Image Picker Delegate
extension ChatVC: ImagePickerControllerDelegate {
    func imagePicker(didSelectImage image: UIImage?) {
        if let unWappedImage = image {
            print(unWappedImage)
            
            let imageData: Data? = unWappedImage.jpegData(compressionQuality: 0.5)
            let imageStr = imageData?.base64EncodedString(options: .lineLength64Characters) ?? ""
            self.sendImgMessage(strUrl: imageStr)
        }
    }
}

extension ChatVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if txtMessage.textColor == UIColor.black {
            txtMessage.text = nil
            txtMessage.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if txtMessage.text.isEmpty {
            txtMessage.text = "Enter Message..".localized
            txtMessage.textColor = UIColor.black
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { (timer) in
            self.emitForStopTyping()
        })
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.emitForStartTyping()
    }
}

extension ChatVC {
    func getAllMessage() {
        
        var dictData = [String:AnyObject]()
        dictData["user_id"] = Singletons.sharedInstance.strDriverID as AnyObject
        dictData["booking_id"] = bookingId as AnyObject
        dictData["booking_type"] = bookingType as AnyObject
        dictData["receiver_id"] = receiverId as AnyObject
        
        UtilityClass.showACProgressHUD()
        webserviceForChatHistory(dictData as AnyObject) { (result, status) in
            UtilityClass.hideACProgressHUD()
            if (status) {
                self.aryData = (result as! NSDictionary).object(forKey: "message") as! [[String:AnyObject]]
                
                let ReceiverData = (result as! NSDictionary).object(forKey: "receiver_data") as! [String:AnyObject]
                let name = ReceiverData["Fullname"] as? String
                let id = ReceiverData["Id"] as? String
                if self.isFromPush {
                    self.setupHeader(name: name ?? "", receiverID: id ?? "")
                }
                
                print(self.aryData)
                if(self.aryData.count > 0){
                    self.tblData.reloadData()
                    self.scrollToBottom()
                }
                
            } else {
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
    
    func sendMessageAPI(image: UIImage? = UIImage()) {
    }
}

//MARK: - tableview datasource and delegate
extension ChatVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.aryData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dictData = aryData[indexPath.row] as [String:AnyObject]
        
        let senderId = dictData["sender_id"] as? String
        if(senderId == Singletons.sharedInstance.strDriverID){
            let cell = tblData.dequeueReusableCell(withIdentifier: SenderCell.className) as! SenderCell
            cell.selectionStyle = .none
            
            cell.vWMessage.isHidden = false
            cell.vwImg.isHidden = false
            let type = dictData["msg_type"] as? String ?? ""
            
            if(type == "image"){
                cell.vWMessage.isHidden = true
                
                let urlLogo = dictData["image"] as? String ?? ""
                cell.imgMsg.sd_imageIndicator = SDWebImageActivityIndicator.white
                cell.imgMsg.sd_setImage(with: URL(string: urlLogo), placeholderImage: UIImage(named: "iconPicture"), options: [.continueInBackground], progress: nil, completed: { (image, error, cache, url) in
                    if (error == nil) {
                        cell.imgMsg.image = image
                    }
                })
                cell.lblImgDate.text = self.convertDate(strDate: dictData["created_at"] as? String ?? "")
                
                cell.btnImgAction = {
                    print("sender called")
                    let url = dictData["image"] as? String ?? ""
                    self.openImage(strImage: url)
                }
                
            }else{
                cell.vwImg.isHidden = true
                cell.lblMsgSender.text = dictData["message"] as? String ?? ""
                cell.lblDate.text = self.convertDate(strDate: dictData["created_at"] as? String ?? "")
            }
            return cell
        }else{
            let cell = tblData.dequeueReusableCell(withIdentifier: ReceiverCell.className) as! ReceiverCell
            cell.selectionStyle = .none
            
            cell.vWMessage.isHidden = false
            cell.vwImg.isHidden = false
            let type = dictData["msg_type"] as? String ?? ""
            
            if(type == "image"){
                
                cell.vWMessage.isHidden = true
                
                let urlLogo = dictData["image"] as? String ?? ""
                cell.imgMsg.sd_imageIndicator = SDWebImageActivityIndicator.white
                cell.imgMsg.sd_setImage(with: URL(string: urlLogo), placeholderImage: UIImage(named: "iconPicture"), options: [.continueInBackground], progress: nil, completed: { (image, error, cache, url) in
                    if (error == nil) {
                        cell.imgMsg.image = image
                    }
                })
                cell.lblImgDate.text = self.convertDate(strDate: dictData["created_at"] as? String ?? "")
                cell.lblImgCompanyName.text = dictData["company_name"] as? String ?? ""
                cell.lblImgCompanyName.isHidden = (cell.lblImgCompanyName.text == "") ? true : false
                
                cell.btnImgAction = {
                    print("sender called")
                    let url = dictData["image"] as? String ?? ""
                    self.openImage(strImage: url)
                }
            }else{
                cell.vwImg.isHidden = true
                cell.lblMsgReceiver.text = dictData["message"] as? String ?? ""
                cell.lblCompanyName.text = dictData["company_name"] as? String ?? ""
                cell.lblCompanyName.isHidden = (cell.lblCompanyName.text == "") ? true : false
                cell.lblDate.text = self.convertDate(strDate: dictData["created_at"] as? String ?? "")
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

extension ChatVC {
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func hideKeyboard(){
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboards))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboards(){
        view.endEditing(true)
    }
    
    func setupKeyboard(_ enable: Bool) {
        IQKeyboardManager.shared.enable = enable
        IQKeyboardManager.shared.enableAutoToolbar = enable
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = !enable
        IQKeyboardManager.shared.previousNextDisplayMode = .alwaysShow
    }
    
    @objc func keyboardWillBeHidden(notification: NSNotification){
        constraintBottomOfChatBG.constant = 10
        self.animateConstraintWithDuration()
    }
    
    @objc func keyboardWasShown(notification: NSNotification){
        let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size
        if #available(iOS 11.0, *) {
            DispatchQueue.main.async {
                if self.aryData.count != 0 {
                    self.tblData.layoutIfNeeded()
                    let indexpath = IndexPath(row: self.aryData.count - 1, section: 0)
                    self.tblData.scrollToRow(at: indexpath , at: .top, animated: false)
                }
            }
            constraintBottomOfChatBG.constant = keyboardSize!.height - view.safeAreaInsets.bottom
        } else {
            DispatchQueue.main.async {
                if self.aryData.count != 0 {
                    self.tblData.layoutIfNeeded()
                    let indexpath = IndexPath(row: self.aryData.count - 1, section: 0)
                    self.tblData.scrollToRow(at: indexpath , at: .top, animated: false)
                }
            }
            constraintBottomOfChatBG.constant = keyboardSize!.height - 10
        }
        self.animateConstraintWithDuration()
    }
    
    func deregisterFromKeyboardNotifications(){
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func animateConstraintWithDuration(duration: TimeInterval = 0.5) {
        UIView.animate(withDuration: duration, animations: { [weak self] in
            self?.loadViewIfNeeded() ?? ()
        })
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
