//
//  Extension+UIViewController.swift
//   TenTaxi-Driver
//
//  Created by Excelent iMac on 17/07/18.
//  Copyright © 2018 Excellent Webworld. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func FullHeightWithNavigationBarStatusBar(NavHeight:CGFloat) -> CGFloat {
        return UIApplication.shared.statusBarFrame.height + NavHeight
    }
    
    /// Convert Any data to String From Dictionary
    func convertAnyToStringFromDictionary(dictData: [String:AnyObject], shouldConvert paramString: String) -> String {
        
        let currentData = dictData
        
        if currentData[paramString] == nil {
            return ""
        }
        
        if ((currentData[paramString] as? String) != nil) {
            return String(currentData[paramString] as! String)
        } else if ((currentData[paramString] as? Int) != nil) {
            return String((currentData[paramString] as! Int))
        } else if ((currentData[paramString] as? Double) != nil) {
            return String(currentData[paramString] as! Double)
        } else if ((currentData[paramString] as? Float) != nil){
            return String(currentData[paramString] as! Float)
        }
        else {
            return ""
        }
    }
    
    /// Convert Any data to String From Dictionary
    func checkDictionaryHaveValue(dictData: [String:AnyObject], didHaveValue paramString: String, isNotHave: String) -> String {
        
        let currentData = dictData
        
        if currentData[paramString] == nil {
            return isNotHave
        }
        
        if ((currentData[paramString] as? String) != nil) {
            if String(currentData[paramString] as! String) == "" {
                return isNotHave
            }
            return String(currentData[paramString] as! String)
            
        } else if ((currentData[paramString] as? Int) != nil) {
            if String(currentData[paramString] as! Int) == "" {
                return isNotHave
            }
            return String((currentData[paramString] as! Int))
            
        } else if ((currentData[paramString] as? Double) != nil) {
            if String(currentData[paramString] as! Double) == "" {
                return isNotHave
            }
            return String(currentData[paramString] as! Double)
            
        } else if ((currentData[paramString] as? Float) != nil){
            if String(currentData[paramString] as! Float) == "" {
                return isNotHave
            }
            return String(currentData[paramString] as! Float)
        }
        else {
            return isNotHave
        }
    }
    
    
    /// Convert Seconds to Hours, Minutes and Seconds
    func ConvertSecondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
}


extension UIApplication {


public class func topViewController(_ base: UIViewController? = UIApplication.shared.windows.first?.rootViewController) -> UIViewController? {
    if let nav = base as? UINavigationController {
        return topViewController(nav.visibleViewController)
    }
    if let tab = base as? UITabBarController {
        if let selected = tab.selectedViewController {
            return topViewController(selected)
        }
    }
    if let presented = base?.presentedViewController {
        return topViewController(presented)
    }
    return base
}}
