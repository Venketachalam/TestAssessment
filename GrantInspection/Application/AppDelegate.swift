//
//  AppDelegate.swift
//  Progress
//
//  Created by Muhammad Akhtar on 5/31/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import UIKit
import GoogleMaps
import IQKeyboardManagerSwift
import Firebase
import XCGLogger

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let appLog = XCGLogger.default // logged instance

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
    
        application.isStatusBarHidden = true
        SharedResources.sharedInstance.loadAllVariables(isFromAppDelegate: true)
        SharedResources.sharedInstance.isRefreshNeeded = true

        checkUserStatus()
        GMSServices.provideAPIKey(Common.googleMapSDKKey)
        IQKeyboardManager.shared.enable = true
        FirebaseApp.configure()
        configureAppLogger()
        return true
    }
    
    func checkUserStatus() {
        
        if  Common.userDefaults.getIsRemember() && Common.isUserSessionActive()  {
            let contractsService = ContractsService()
            let dashboardViewModel = DashboardViewModel(contractsService)
            let dashboardViewController = DashboardViewController.create(with: dashboardViewModel)
        
            let navigationController = UINavigationController(rootViewController: dashboardViewController)
            navigationController.navigationBar.isHidden = true
            window = UIWindow(frame: UIScreen.main.bounds)
            window?.rootViewController = navigationController
            window?.makeKeyAndVisible()
        } else {
            Common.userDefaults.saveDebugMode(false)
            let loginService = LoginService()
            let loginControllerViewModel = LoginControllerViewModel(loginService)
            let loginController = LoginViewController.create(with: loginControllerViewModel)
            let navigationController = UINavigationController(rootViewController: loginController)
            navigationController.navigationBar.isHidden = true
            window = UIWindow(frame: UIScreen.main.bounds)
            window?.rootViewController = navigationController
            window?.makeKeyAndVisible()
        }
        
    }
  
  
  func configureAppLogger(){
    
    appLog.setup(level: .debug, showThreadName: true, showLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: "Progress/General/", fileLevel: .debug)
    
    appLog.verbose("A verbose message, usually useful when working on a specific problem")
    appLog.debug("A debug message")
    appLog.info("An info message, probably useful to power users looking in console.app")
    appLog.warning("A warning message, may indicate a possible error")
    appLog.error("An error occurred, but it's recoverable, just info about what happened")
    appLog.severe("A severe error occurred, we are likely about to crash now")
    
  }
  

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    
    internal var shouldRotate = false
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        
        if shouldRotate {
            return .all
        }else{
            return [.landscapeLeft, .landscapeRight]
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
      // Called when the application is about to terminate. Save data if appropriate. See also  applicationDidEnterBackground:.
      // Saves changes in the application's managed object context before the application terminates.
      CoreDataManager.sharedManager.saveContext()
    }
    func application(_ application: UIApplication, shouldAllowExtensionPointIdentifier extensionPointIdentifier: UIApplication.ExtensionPointIdentifier) -> Bool {
        
        //print("KBBB___    ", UIApplicationExtensionPointIdentifier.keyboard)
        if extensionPointIdentifier == UIApplication.ExtensionPointIdentifier.keyboard {
            return false
        }
        return  true
    }

}

extension UIApplication {
    public var isSplitOrSlideOver: Bool {
        guard let w = self.delegate?.window, let window = w else { return false }
        return !window.frame.equalTo(window.screen.bounds)
    }
}

