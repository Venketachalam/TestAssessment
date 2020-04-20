//
//  ProjectSearchView.swift
//  Progress
//
//  Created by Muhammad Akhtar on 10/4/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import UIKit

class ProjectSearchView: UIView, SearchNameVCDelegate,UITextFieldDelegate {

  @IBOutlet weak var txtFieldLandNumber: UITextField!
  @IBOutlet weak var txtFieldApplicationNumber: UITextField!
    
  @IBOutlet weak var filterYourProject: UILabel!
  @IBOutlet weak var btnApplyFilter: UIButton!
  @IBOutlet weak var clearButton: UIButton!
  @IBOutlet weak var landNoLbl: UILabel!
  @IBOutlet weak var applicationNoLbl: UILabel!
  
  
  class func getProjectSearchView() -> ProjectSearchView
    {
        return Bundle.main.loadNibNamed("ProjectSearchView", owner: self, options: nil)![0] as! ProjectSearchView
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setLayout()
    }

  
    func setLayout(){
    
      self.landNoLbl.text = "customer_number".ls
      self.applicationNoLbl.text = "file_number".ls
      self.filterYourProject.text = "filter_projects_lbl".ls
      self.btnApplyFilter.setTitle("apply_btn".ls, for: .normal)
      self.clearButton.setTitle("clear_btn".ls, for: .normal)
        txtFieldApplicationNumber.placeholder = "application_number_placeHolder".ls
        txtFieldLandNumber.placeholder = "application_id_placeHolder".ls
        
        
        
    }
    
    
  
    func selectedName(name: String) {
        //self.txtFieldContractorName.text = name
    }
    
    @objc func presentSearchView() {
        
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SerachNameVC") as? SearchContractorNameVC
        {
            vc.searchDelegate = self
            Common.appDelegate.window?.rootViewController?.present(vc, animated: false, completion: nil)
        }
        
    }
    
}
