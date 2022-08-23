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
    @IBOutlet weak var txtMessage: UITextView!
    
    @IBOutlet weak var lblNavName: UILabel!
    @IBOutlet weak var lblNavBack: UIButton!
    @IBOutlet weak var vwTopHeight: NSLayoutConstraint!
    
    var receiverName: String = ""
    var receiverId: String = ""
    var bookingId: String = ""
    var aryData = [[String:AnyObject]]()
    var isDispacherChat: Bool = false
    var isFromPush: Bool = false
    let socket = (UIApplication.shared.delegate as! AppDelegate).SManager.defaultSocket
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.getAllMessage()
        AppDelegate.shared.currentChatID = receiverId
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadScreen(_:)), name: NSNotification.Name(rawValue: "ReloadChatScreen"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        AppDelegate.shared.isChatVisible = true
        let topBarHeight = UIApplication.shared.statusBarFrame.size.height + (self.navigationController?.navigationBar.frame.height ?? 0.0)
        self.vwTopHeight.constant = topBarHeight
        
        UtilityClass.showACProgressHUD()
        self.socketMethods()
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
        self.lblNavName.text = receiverName
        txtMessage.delegate = self
        txtMessage.text = "Enter Message.."
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
                    UtilityClass.hideACProgressHUD()
                }
            }
            socket.connect()
        }
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
        let myJSON = ["sender_id" : Singletons.sharedInstance.strDriverID,
                      "receiver_id": receiverId,
                      "message" : self.txtMessage.text ?? "",
                      "sender_type" : "driver",
                      "receiver_type" : (isDispacherChat) ? "dispatcher" : "passenger",
                      "booking_id" : (isDispacherChat) ? "" : bookingId] as [String : Any]
        
        self.socket.emit(socketApiKeys.sendMessage, with: [myJSON], completion: nil)
        print ("\(socketApiKeys.sendMessage) : \(myJSON)")
        txtMessage.text = "Enter Message.."
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
    
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func btnSendAction(_ sender: Any) {
        if(self.txtMessage.text.trimmingCharacters(in: .whitespaces) != "" && self.txtMessage.text != "Enter Message.."){
            self.sendMessage()
        }else{
            UtilityClass.showAlert("Misssing".localized, message:  "Please enter message".localized, vc: self)
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
            txtMessage.text = "Enter Message.."
            txtMessage.textColor = UIColor.black
        }
    }
}

extension ChatVC {
    func getAllMessage() {
        
        var dictData = [String:AnyObject]()
        dictData["user_id"] = Singletons.sharedInstance.strDriverID as AnyObject
        dictData["booking_id"] = bookingId as AnyObject
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
            cell.lblMsgSender.text = dictData["message"] as? String ?? ""
            cell.lblDate.text = dictData["created_date"] as? String ?? ""
            return cell
        }else{
            let cell = tblData.dequeueReusableCell(withIdentifier: ReceiverCell.className) as! ReceiverCell
            cell.selectionStyle = .none
            cell.lblMsgReceiver.text = dictData["message"] as? String ?? ""
            cell.lblCompanyName.text = dictData["company_name"] as? String ?? ""
            cell.lblCompanyName.isHidden = (cell.lblCompanyName.text == "") ? true : false
            cell.lblDate.text = dictData["created_date"] as? String ?? ""
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