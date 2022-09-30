//
//  LegalWebView.swift
//  TanTaxi-Driver
//
//  Created by excellent Mac Mini on 30/10/18.
//  Copyright © 2018 Excellent Webworld. All rights reserved.
//

import UIKit
import WebKit

class LegalWebPage: ParentViewController, WKUIDelegate, WKNavigationDelegate {

    
    var headerName = String()
    var strURL = String()
    @IBOutlet var TopConstraint: NSLayoutConstraint!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.headerView?.lblTitle.text = "Support".localized
        self.headerView?.btnWhatsapp.isHidden = true
        if headerName != "" {
            headerView?.lblTitle.text = headerName
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView.uiDelegate = self
        self.webView.navigationDelegate = self
        
        let NavBarHeight = UIApplication.shared.statusBarFrame.height + (self.navigationController?.navigationBar.frame.height)!
        if UIApplication.shared.statusBarFrame.height != 20 {
            self.TopConstraint.constant = NavBarHeight
        }
        else {
            self.TopConstraint.constant =  NavBarHeight
        }
        
        UtilityClass.showACProgressHUD()
        //
//        strURL = "https://www.tantaxitanzania.com/web/front/termsconditions"
        
        //        let requestURL = URL(string: url)
        //        let request = URLRequest(url: requestURL! as URL)
        //        webView.loadRequest(request)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
       
        
        let url = strURL
        
        let requestURL = URL(string: url)
        let request = URLRequest(url: requestURL! as URL)
        webView.load(request)
        
    }
    
    // MARK: - Outlets
    @IBOutlet var webView: WKWebView!
    
    
    @IBAction func btnBack(_ sender: UIButton) {
//        self.navigationController?.popToViewController(LegalViewController, animated: true)
    }
    
    
    // MARK: - WKWebView Navigation delegate method
//    func webViewDidFinishLoad(_ webView: UIWebView)
//    {
//        UtilityClass.hideACProgressHUD()
//    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        UtilityClass.hideACProgressHUD()
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        UtilityClass.hideACProgressHUD()
    }
}

class termsConditionWebviewVc: ParentViewController, WKNavigationDelegate, WKUIDelegate  {
    

    var headerName = String()
    var strURL = String()
    
    // MARK: - Outlets
    @IBOutlet weak var webView:WKWebView!
    
    @IBOutlet var TopConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let NavBarHeight = UIApplication.shared.statusBarFrame.height + (self.navigationController?.navigationBar.frame.height)!
        if UIApplication.shared.statusBarFrame.height != 20 {
            self.TopConstraint.constant = NavBarHeight
        }
        else {
            self.TopConstraint.constant =  NavBarHeight
        }
        UtilityClass.showACProgressHUD()
        webView.navigationDelegate = self
        //
//        strURL = "https://www.tantaxitanzania.com/web/front/termsconditions"
    }
    
    @IBAction func btnBack(_ sender: UIButton) {
       

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if headerName != "" {
            headerView?.lblTitle.text = headerName
        }
        
        let url = strURL
        
        let requestURL = URL(string: url)
        let request = URLRequest(url: requestURL! as URL)
        webView.load(request)
        
    }
    
    
    // MARK: - WKWebView Navigation delegate method
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        UtilityClass.hideACProgressHUD()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        UtilityClass.hideACProgressHUD()
    }
    
}
