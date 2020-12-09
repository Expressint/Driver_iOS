//
//  webViewVC.swift
//  TiCKTOC-Driver
//
//  Created by Excelent iMac on 02/12/17.
//  Copyright © 2017 Excellent Webworld. All rights reserved.
//

import UIKit
import WebKit

class webPageVC: ParentViewController, WKUIDelegate , WKNavigationDelegate {

    var headerName = String()
    var strURL = String()
    
    @IBOutlet var TopWebConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.TopWebConstraint.constant = UIApplication.shared.statusBarFrame.height + (self.navigationController?.navigationBar.frame.height)!
        
        self.WebPageView.uiDelegate = self
        self.WebPageView.navigationDelegate = self
         UtilityClass.showACProgressHUD()
//
//         strURL = "https://www.tantaxitanzania.com/web/front/privacypolicy"

        let requestURL = URL(string: strURL)!
        let request = URLRequest(url: requestURL as URL)
        WebPageView.load(request)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if headerName != "" {
            headerView?.lblTitle.text = headerName
        }
        
        let url = strURL
        
        let requestURL = URL(string: url)
        let request = URLRequest(url: requestURL! as URL)
        WebPageView.load(request)
        
    }
    
    // MARK: - Outlets
    @IBOutlet var WebPageView: WKWebView!
    
    // MARK: - WKWebView delegate method

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        UtilityClass.hideACProgressHUD()
    }

}
