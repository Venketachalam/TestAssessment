//
//  StartMyTripViewController.swift
//  Progress
//
//    Created by Hasnain Haider on 08/4/19.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import UIKit
import GoogleMaps
import RxSwift
import RxCocoa
import CoreLocation
import UserNotifications

class OLImageUploaderViewController: UIViewController, UNUserNotificationCenterDelegate{
  
  @IBOutlet weak var mainContainer: UIView!
  @IBOutlet weak var backView: MBRHEBorderView!
  @IBOutlet weak var backbtn: UIButton!
  @IBOutlet weak var retryAllBtn: UIButton!
  @IBOutlet weak var retryView: MBRHEBorderView!
  @IBOutlet weak var clearAllView: MBRHEBorderView!
  @IBOutlet weak var clearBtn: UIButton!
  
  var oLImageUploader : OLimageUploaderView = OLimageUploaderView()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setLayout()
 
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
   
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(true)
    
  }
  
  func setLayout(){
    addMRHEHeaderView()
    addMRHELeftMenuView()
    addOFImageIUploader()
  }
  
  
  func addOFImageIUploader(){
    
    oLImageUploader = OLimageUploaderView.getProjectInfoWindow()
    oLImageUploader.frame =  CGRect(x: 0, y: 0, width: self.mainContainer.frame.size.width, height: self.mainContainer.frame.size.height)
    manageControls()
    self.mainContainer.addSubview(oLImageUploader)

  }
  
  func manageControls(){
    
    if oLImageUploader.dataArray.count <= 0 {
      self.retryView.isHidden = true
      self.clearAllView.isHidden = true
    }else {
      self.clearAllView.isHidden = false
      self.retryView.isHidden = false
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func addMRHEHeaderView(){
    let mrheHeaderView = MRHEHeaderView.getMRHEHeaderView()
    self.view.addSubview(mrheHeaderView)
  }
  
  func addMRHELeftMenuView(){
    let mrheMenuView = MBRHELeftMenuView.getMBRHELeftMenuView()
    self.view.addSubview(mrheMenuView)
  }
  
  
  @IBAction func backPreseed(_ sender: Any) {
    self.navigationController?.popViewController(animated: true)
  }
  
  @IBAction func retryPressed(_ sender: Any) {
    
    if (CoreDataManager.sharedManager.fetch(status: "toDo")?.count)! > 0{
      oLImageUploader.retry()
      self.retryAllBtn.isUserInteractionEnabled = true
    }else {
      self.retryAllBtn.isUserInteractionEnabled = false
    }
  }
  
  @IBAction func clearPressed(_ sender: Any) {
    
    let refreshAlert = UIAlertController(title: "Confirmation".ls, message: "Are_you_sure_You_want_to_clear_the_images".ls, preferredStyle: UIAlertController.Style.alert)
    
    refreshAlert.addAction(UIAlertAction(title: "Yes".ls, style: .default, handler: { (action: UIAlertAction!) in
      
      self.oLImageUploader.viewModel.clearAll()
      self.manageControls()
      
    }))
    
    refreshAlert.addAction(UIAlertAction(title: "cancel_btn".ls, style: .cancel, handler: { (action: UIAlertAction!) in
      
    }))
    
    Common.appDelegate.window?.rootViewController?.present(refreshAlert, animated: true, completion: nil)
  }
  
  
  
  
}
