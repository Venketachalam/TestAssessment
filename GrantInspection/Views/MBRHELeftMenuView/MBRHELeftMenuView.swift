//
//  MBRHELeftMenuView.swift
//  Progress
//
//  Created by Muhammad Akhtar on 9/26/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import UIKit

class MBRHELeftMenuView: UIView {

    @IBOutlet weak var dashboardView: UIView!
    @IBOutlet weak var btnDashboard: UIButton!
    @IBOutlet weak var chartView: UIView!
    @IBOutlet weak var btnchart: UIButton!
    @IBOutlet weak var tripView: UIView!
    @IBOutlet weak var btnTrip: UIButton!
    @IBOutlet weak var settingsView: UIView!
    @IBOutlet weak var settingsBtn: UIButton!
    @IBOutlet weak var imageUploader: UIButton!
    @IBOutlet weak var imageUpload: UIView!
    
    @IBOutlet weak var userPhotoBtn: UIButton!
    @IBOutlet weak var settingsLbl: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    var userNameString:String = ""
    
  
  @IBOutlet weak var mainPagelbl: UILabel!
  
  @IBOutlet weak var signoutLbl: UILabel!
    @IBOutlet weak var mainPageSideBarView: UIView!
    
    @IBOutlet weak var settingsSidebarView: UIView!
    class func getMBRHELeftMenuView() -> MBRHELeftMenuView
    {
        return Bundle.main.loadNibNamed("MBRHELeftMenuView", owner: self, options: nil)![0] as! MBRHELeftMenuView
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setLayout()
        self.frame = CGRect.init(x: 0, y: 0, width: 100, height: Int(Common.screenHeight))
        setFonts()
        enableDisableFeatures() // Enable/Disable Feature
        
        
    }
  
  
  func setLayout(){
    
    if Common.currentLanguageArabic() {
      self.transform = Common.arabicTransform
    }
    
    self.mainPagelbl.text = "home_menu".ls
    
//    let loggedUserName:String = Common.userDefaults.getSavedLoggedUserName()
//    self.userNameLabel.text = loggedUserName
    
    
    self.signoutLbl.text = "logout_menu".ls
    
//    if userPhotoBtn.currentImage == nil
//    {
        userPhotoBtn.setImage(UIImage(named: "profile_icon"), for: .normal)
//    }
    var environmentMode:String
    if Common.userDefaults.getDebugMode()
     {
        settingsView.isHidden = false
        settingsBtn.isHidden = false
        settingsLbl.text = "settings_menu".ls
        environmentMode = "QA"
     }
    else
    {
        environmentMode = "Prod"
    }
    let userlogininfo = Common.userDefaults.getSavedLoggedUserName(environment:environmentMode)
    let userName = userlogininfo["UserName"]
    self.userNameLabel.text = userName
  }
  
  
    func enableDisableFeatures(){
      
      if SharedResources.sharedInstance.appFeatureStatus.menu.is_dashboard == false {
        //btnDashboard.isUserInteractionEnabled = false
      }
      
      if SharedResources.sharedInstance.appFeatureStatus.menu.is_search_payments == false{
//        btnchart.isUserInteractionEnabled = false
//        self.btnchart.setImage(UIImage.init(named: "search_disable_icon"), for: .normal)
      }
      
      if SharedResources.sharedInstance.appFeatureStatus.menu.is_trip == false {
        btnTrip.isUserInteractionEnabled = false
        self.btnTrip.setImage(UIImage.init(named: "plan_disable_icon"), for: .normal)
      }
    }
  
    func setFonts() {
        
        let tag = SharedResources.sharedInstance.currentRootTag
        setTabColorWith(tag: tag)
    }
    
    @IBAction func btnLogOut_Action(_ sender: Any) {
        Common.showLogoutAlert(message: "Are_you_sure_want_to_logout".ls)
    }
    
    @IBAction func btnMenu_Action(_ sender: Any) {

        let tag = (sender as! UIButton).tag
                   self.setTabColorWith(tag: tag)
                   self.gotSelectedViewControllerWith(tag: tag)
                         SharedResources.sharedInstance.currentRootTag = tag
      
    }
    
     func setTabColorWith(tag:Int)  {
        if tag == 1
        {
            //dashboard Tap
            self.btnDashboard.setImage(UIImage.init(named: "dashboard_icon_gray"), for: .normal)
            self.dashboardView.backgroundColor = UIColor.white
            self.mainPageSideBarView.isHidden = false
            self.btnDashboard.tintColor = Common.appThemeColor

            
            self.btnTrip.setImage(UIImage.init(named: "navigatation_icon_gray"), for: .normal)
            self.tripView.backgroundColor = UIColor.white
          
            self.imageUploader.setImage(UIImage.init(named: "upload_images_icon_active"), for: .normal)
            self.imageUpload.backgroundColor = UIColor.white
          
            self.settingsBtn.setImage(UIImage.init(named: "setting_icon_unactive"), for: .normal)
            self.settingsView.backgroundColor = UIColor.white
            
        } else if tag == 2 {
            //Found Tap
            self.btnDashboard.setImage(UIImage.init(named: "dashboard_icon_gray"), for: .normal)
            self.dashboardView.backgroundColor = UIColor.white
            
            self.settingsBtn.setImage(UIImage.init(named: "setting_icon"), for: .normal)
            self.settingsView.backgroundColor = Common.appThemeColor
          
            self.imageUploader.setImage(UIImage.init(named: "upload_images_icon_active"), for: .normal)
            self.imageUpload.backgroundColor = UIColor.white
          
            self.btnTrip.setImage(UIImage.init(named: "navigatation_icon_gray"), for: .normal)
            self.tripView.backgroundColor = UIColor.white

            
        } else if tag == 3 {
            //Navigate trip Tap
           // self.btnDashboard.setImage(UIImage.init(named: "dashboard_icon_gray"), for: .normal)
          
            self.btnDashboard.setImage(UIImage.init(named:"dashboard_icon_white"), for: .normal)
            self.dashboardView.backgroundColor = UIColor.white
            self.mainPageSideBarView.backgroundColor = UIColor.white
            self.mainPageSideBarView.isHidden = true
            self.mainPagelbl.textColor = UIColor.lightGray

            self.imageUploader.setImage(UIImage.init(named: "upload_images_icon_active"), for: .highlighted)
            self.imageUpload.backgroundColor = UIColor.white
          
            self.settingsBtn.setImage(UIImage.init(named: "setting_icon_active"), for: .normal)
            self.settingsLbl.textColor = Common.appThemeColor
            self.settingsView.backgroundColor = UIColor.white
            self.settingsSidebarView.isHidden = false
            self.settingsSidebarView.backgroundColor = Common.appThemeColor
            settingsBtn.tintColor = Common.appThemeColor
            
            self.btnTrip.setImage(UIImage.init(named: "navigatation_icon_white"), for: .normal)
            self.tripView.backgroundColor = UIColor.white
            
        }else if tag == 4 {
          
          //Navigate trip Tap
          self.btnDashboard.setImage(UIImage.init(named: "dashboard_icon_gray"), for: .normal)
          self.dashboardView.backgroundColor = UIColor.white
          
          self.imageUploader.setImage(UIImage.init(named: "upload_images_icon_active"), for: .normal)
          self.imageUpload.backgroundColor = UIColor.white
          
          self.settingsBtn.setImage(UIImage.init(named: "setting_icon"), for: .normal)
          self.settingsView.backgroundColor = Common.appThemeColor
          
          self.btnTrip.setImage(UIImage.init(named: "navigatation_icon_gray"), for: .normal)
          self.tripView.backgroundColor = UIColor.white
          
        }else if tag == 5 {
          
          //Navigate trip Tap
          self.btnDashboard.setImage(UIImage.init(named: "dashboard_icon_gray"), for: .normal)
          self.dashboardView.backgroundColor = UIColor.white
          
          self.btnchart.setImage(UIImage.init(named: "Dashboard_dark"), for: .normal)
          self.chartView.backgroundColor = UIColor.white
          
          self.settingsBtn.setImage(UIImage.init(named: "setting_icon"), for: .normal)
          self.settingsView.backgroundColor = Common.appThemeColor
          
          self.imageUploader.setImage(UIImage.init(named: "upload_images_icon"), for: .normal)
          self.imageUpload.backgroundColor = Common.appThemeColor
          
          self.btnTrip.setImage(UIImage.init(named: "navigatation_icon_gray"), for: .normal)
          self.tripView.backgroundColor = UIColor.white
          
      }
    }
    
    func gotSelectedViewControllerWith(tag:Int){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var controller = UIViewController()
        
        if tag == 1 {
            //GoTo Dashboard
            let contractsService = ContractsService()
            let dashboardViewModel = DashboardViewModel(contractsService)
            controller = DashboardViewController.create(with: dashboardViewModel)
            
        }

        else if tag == 2 {
            //GoTo Trip View
            controller = storyboard.instantiateViewController(withIdentifier: "NotificationListViewController") as! NotificationListViewController
        }else if tag == 3 {
             controller = storyboard.instantiateViewController(withIdentifier: "DashboardSettingsViewController") as! DashboardSettingsViewController
         
        }else if tag == 4 {
          //GoTo Trip View
         // controller = storyboard.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
      }else if tag == 5 {
          //GoTo Image Uploader view
        controller = storyboard.instantiateViewController(withIdentifier: "OLImageUploader") as! OLImageUploaderViewController
  }
         
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.navigationBar.isHidden = true
        Common.appDelegate.window?.rootViewController = navigationController
        
    }
    
}
