//
//  DashboardViewController.swift
//  Progress
//
//  Created Hasnain Haider on 3/19/19.
//  Copyright © 2018 MBRHE. All rights reserved.
//
import Foundation
import UIKit

class ChartViewController: UIViewController{

  
  
  override func viewDidLoad() {
    super.viewDidLoad()
  
    addMRHEHeaderView()
  addMRHELeftMenuView()
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
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
  
  
}
