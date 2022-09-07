//
//  OfflineVC.swift
//  Curbside Delivery
//
//  Created by Tej P on 18/11/21.
//

import UIKit
//import Lottie

class OfflineVC: UIViewController {
    
    //MARK: - Variables
    @IBOutlet weak var lblOffline: UILabel!
    
    //MARK: - Life-Cycle methods
    override func viewWillAppear(_ animated: Bool) {
       
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepareView()
    }
    
    //MARK: - Custom methods
    func prepareView(){
        self.setupUI()
    }

    
    func setupUI(){
        //self.lblOffline.font = FontBook.regular.font(ofSize: 15)
    }
    
    //MARK: - IBOutlet Action methods
    @IBAction func btnRetryAction(_ sender: Any) {
        AppDelegate.shared.checkConnction()
    }
}
