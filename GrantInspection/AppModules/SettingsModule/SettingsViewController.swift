//
//  ContractDetailViewController.swift
//  Progress
//
//  Created by Muhammad Akhtar on 6/18/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

  @IBOutlet weak var switchBtn: UISwitch!
  @IBOutlet weak var headingLabel: UILabel!
  @IBOutlet weak var label1: UILabel!
  @IBOutlet weak var backBtn: UIButton!
  
  override func viewDidLoad() {
        super.viewDidLoad()

      addMRHEHeaderView()
      addMRHELeftMenuView()
      setLayout()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func setLayout(){
      
      if Common.userDefaults.getDebugMode(){
        switchBtn.isOn = true
      }else {
        switchBtn.isOn = false
      }
    }
  
  func addMRHEHeaderView(){
    let mrheHeaderView = MRHEHeaderView.getMRHEHeaderView()
    self.view.addSubview(mrheHeaderView)
  }
  
  func addMRHELeftMenuView(){
    let mrheMenuView = MBRHELeftMenuView.getMBRHELeftMenuView()
    self.view.addSubview(mrheMenuView)
  }
  
  @IBAction func switchPressed(_ sender: Any) {
    if switchBtn.isOn {
      Common.userDefaults.saveDebugMode(true)
      Common.setAPPKeyAndSeacretDebuggMode(true)
      APICommunicationURLs.setApplicationEnviroment(_domainType: .QA)
      switchBtn.onTintColor = UIColor(red: 36/255, green: 98/255, blue: 158/255, alpha: 1.0)
    }else {
      Common.setAPPKeyAndSeacretDebuggMode(false)
      Common.userDefaults.saveDebugMode(false)
      APICommunicationURLs.setApplicationEnviroment(_domainType: .Production)
      switchBtn.onTintColor = UIColor(red: 167/255, green: 167/255, blue: 167/255, alpha: 1.0)
    }
    
    Common.logout()
  }
  
  @IBAction func backBtnPressed(_ sender: Any) {
    self.navigationController?.popViewController(animated: false)
  }
  
}
