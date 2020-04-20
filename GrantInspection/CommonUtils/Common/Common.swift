//
//  Common.swift
//  Progress
//
//  Created by Muhammad Akhtar on 6/3/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//


import UIKit
import AVFoundation
import NVActivityIndicatorView
import Toaster

open class Common: NSObject {
    
    static let appDelegate = UIApplication.shared.delegate as! AppDelegate
    static let userDefaults = UserDefaults.standard
    
    static var client_id = ""
    static var client_secret = ""
    
    // user login
    static let kLoggedIn        =    "loggedIn"
    static let loginUserFileName        =    "User_Model"
    static let screenWidth = UIScreen.main.bounds.size.width
    static let screenHeight = UIScreen.main.bounds.size.height
    static let mrheHeaderY = 24
    static let mrheProgressBarY = 128
    
    //for attachement section
    
    static var currentSectionIndex = 0
    
    //static let googleMapSDKKey = "AIzaSyDcrShRgXGyCvXRuRn0vAbGAA2Km4vWtsk" // evento account
    static let googleMapSDKKey = "AIzaSyAp2EjCCJCfEAUIW9p8GL-zYpycafpWHK0"
    
    static let appThemeColor = UIColor.init(red: 0/255, green: 97/255, blue: 158/255, alpha: 1.0)
    
    static let arabicTransform = CGAffineTransform(scaleX: -1.0, y: 1.0)
    
    static let englishTransform = CGAffineTransform(scaleX: 1, y: 1)
    
    static func deleteFileFromTemp(_ fileName : String){
        
        let fileManager = FileManager.default
        
        let filePath = (NSTemporaryDirectory() as NSString).appendingPathComponent(fileName)
        
        do {
            try fileManager.removeItem(atPath: filePath)
        }
            
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
        
    }
    
    static var availableResponseModalData = [Response]()
    
    static func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    static func setAPPKeyAndSeacretDebuggMode(_ isTest: Bool)
    {
        
        
        //    if isTest {
        //      client_id = "inspection-service"
        //      client_secret = "574ee52f-c160-41f7-b0ba-1261b20cac27"
        //
        //    }else{
        //      //Production
        //      client_id = "inspection-service"
        //      client_secret = "3bc06b23-0815-45ea-b145-5a5bab7a9609"
        //    }
        
        client_id = "inspection-service"
        client_secret = "3bc06b23-0815-45ea-b145-5a5bab7a9609"
        
        
    }
    
    static func isConnectedToNetwork() -> Bool {
        let status = Reach().connectionStatus()
        switch status {
        case .unknown, .offline:
            //print("Not connected")
            return false
        case .online(.wwan):
            //print("Connected via WWAN")
            return true
        case .online(.wiFi):
            //print("Connected via WiFi")
            return true
        }
    }
    
    static func isProjectAddedIntoTripArrayWith(paymentId:NSNumber) -> Bool {
        var isAdded = false
        
        let selectedTripObjectsArray = SharedResources.sharedInstance.selectedTripContracts
        if selectedTripObjectsArray.count > 0 {
            // Filter the list of selected array having the object with this payment id
            let paymentObj = selectedTripObjectsArray.filter{ $0.applicationNo == paymentId }.first
            if paymentObj != nil {
                isAdded = true
            }else{
                isAdded = false
            }
        } else {
            isAdded = false
        }
        
        return isAdded
    }
    
    static func isUserSessionActive() -> Bool {
        var isActive = false
        
        //        let currentDateTime = Date()
        //        let dateStr = Common.convertDateToString(date: currentDateTime)
        //        Common.userDefaults.setLoginUserTime(_time:dateStr)
        
        let refresh_expires_in = Common.userDefaults.fetchCurrentUserModel().refresh_expires_in//SharedResources.sharedInstance.currentUser.refresh_expires_in
        let savedTime = Common.userDefaults.getLoginUserTime()
        if savedTime == " " {
            return false
        }
        let userLogedInDate =  self.convertStringToDate(dateStr: savedTime )
        //let seconds = refresh_expires_in.doubleValue / 1000
        let seconds = refresh_expires_in.doubleValue
        //print(seconds.round())
        //for testing 120000
        //let seconds = 150000 / 1000
        let minutes = seconds / 60
        let expireDate = userLogedInDate.adding(minutes: Int(minutes))
        let currentDate = Date()
        
        if currentDate == expireDate{
            isActive = false
        } else if currentDate > expireDate {
            isActive = false
        } else if currentDate < expireDate {
            isActive = true
        }
        
        return isActive
    }
    
    static func convertDateToString(date:Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = formatter.string(from: date)
        return dateString
    }
    
    static func convertStringToDate(dateStr:String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from: dateStr)
        return date!
    }
    
    
    
    static func currentLanguageArabic () -> Bool {
        
        if Localization.currentLanguage() == "ar" {
            return true
        } else {
            return false
        }
    }
    
    static var languageCode: String {
        get {
            return Common.currentLanguageArabic() ? "ar": "en"
        }
    }
    
    
    static func dialNumber(number : String) {
        
        if let url = URL(string: "tel://\(number)"),
            UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:], completionHandler:nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        } else {
            // add error message here
        }
    }
    
    static func logout(){
        
        Common.deleteFileFromTemp(Common.loginUserFileName)
        Common.userDefaults.saveLogInStatus(isLogedIn: false)
       
        SharedResources.sharedInstance.contractsPayload.payload.dashboard.removeAll()
        SharedResources.sharedInstance.selectedTripContracts.removeAll()
        SharedResources.sharedInstance.contractsPayload.payload.pagination.page = 0
        SharedResources.sharedInstance.contractsPayload.payload.pagination.totalItems = 0
        SharedResources.sharedInstance.contractsPayload.payload.pagination.totalPages =  0
        
        SharedResources.sharedInstance.applicationNo = ""
        SharedResources.sharedInstance.plotNo =  ""
       Common.userDefaults.clearData()
        
//        Localization.storeCurrentLanguage("ar")
        
        //Set Default mode is QA and English
//        Localization.storeCurrentLanguage("en")
//        Common.setAPPKeyAndSeacretDebuggMode(true)
//        APICommunicationURLs.setApplicationEnviroment(_domainType: .QA)
//        Common.userDefaults.saveDebugMode(true)
        
        let loginService = LoginService()
        let loginControllerViewModel = LoginControllerViewModel(loginService)
        let loginController = LoginViewController.create(with: loginControllerViewModel)
        let navigationController = UINavigationController(rootViewController: loginController)
        navigationController.navigationBar.isHidden = true
        Common.appDelegate.window? = UIWindow(frame: UIScreen.main.bounds)
        Common.appDelegate.window?.rootViewController = navigationController
        Common.appDelegate.window?.makeKeyAndVisible()
        
        
    }
    
    static func randomString(length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
    static func smsReceviedSound(){
        
        // create a sound ID, in this case its the tweet sound.
        let systemSoundID: SystemSoundID = 1007
        
        // to play sound
        AudioServicesPlaySystemSound (systemSoundID)
    }
    
    static func showActivityIndicator(){
        hideActivityIndicator()
        DispatchQueue.main.async {
            //let window = UIApplication.shared.keyWindow!
            
            //let windowView = UIView(frame: window.bounds)
            let topVC = UIApplication.topViewController()?.view
            let frameToShow = CGRect(x: 0, y:0, width: 50,  height:50)
            let activityIndicatorView : NVActivityIndicatorView = NVActivityIndicatorView(frame: frameToShow)
            activityIndicatorView.tag = 1111
            activityIndicatorView.center = topVC?.center ?? CGPoint.zero
            activityIndicatorView.color = UIColor(red: 0/255, green: 97/255, blue: 158/255, alpha: 1.0)
            
            activityIndicatorView.type = NVActivityIndicatorType.ballBeat
            
            activityIndicatorView.startAnimating()
            
            topVC?.addSubview(activityIndicatorView)
            // windowView.addSubview(activityIndicatorView)
            //window.addSubview(windowView)
        }
        
    }
    
    static func hideActivityIndicator() {
        DispatchQueue.main.async {
            let view =  UIApplication.topViewController()?.view//UIApplication.shared.keyWindow!
            for sView in view?.subviews ?? [UIView()] where sView.tag == 1111 {
                sView.removeFromSuperview()
            }
        }
        
    }
    
    static func showToaster(message: String) {
        
        DispatchQueue.main.async {

            Toast(text:message, duration: Delay.short).show()
        }
        
    }
    
    static func showLogoutAlert(message:String){
       
        let refreshAlert = UIAlertController(title: "Confirmation".ls, message: message, preferredStyle: UIAlertController.Style.alert)
       
        refreshAlert.addAction(UIAlertAction(title: "logout_btn".ls, style: .destructive, handler: { (action: UIAlertAction!) in

            SharedResources.sharedInstance.searchActive = false
            Common.logout()
          
       }))
       
        refreshAlert.addAction(UIAlertAction(title: "cancel_btn".ls, style: .cancel, handler: { (action: UIAlertAction!) in
        // completionHandler(false)
       }))

       Common.appDelegate.window?.rootViewController?.present(refreshAlert, animated: true, completion: nil)
     }
    
    static func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
}
extension Date {
    func adding(minutes: Int) -> Date {
        return Calendar.current.date(byAdding: .minute, value: minutes, to: self)!
    }
}
