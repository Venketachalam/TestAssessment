//
//  FindContractsViewController.swift
//  Progress
//
//  Created by Muhammad Akhtar on 6/11/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class FindContractsViewController: UIViewController, NVActivityIndicatorViewable, SearchNameVCDelegate ,UITextFieldDelegate{
    
    @IBOutlet weak var txtFieldLandNumber: UITextField!
    @IBOutlet weak var txtFieldApplicationNumber: UITextField!
    
    @IBOutlet weak var btnApplyFilter: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addMRHEHeaderView()
        addMRHELeftMenuView()
    
        self.btnApplyFilter.addTarget(self, action: #selector(filterApiCall), for: .touchUpInside)
        self.txtFieldLandNumber.delegate = self
        self.txtFieldApplicationNumber.delegate = self
    }
  
  override func viewWillAppear(_ animated: Bool) {
    SharedResources.sharedInstance.searchActive = true
  
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    
    //SharedResources.sharedInstance.searchActive = false
     // SharedResources.sharedInstance.contractsPayload.payload  =  [Payment]()
  }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func btnFindContracts_Tapped(_ sender: Any) {
        self.performSegue(withIdentifier: "FindToContractDetailVC", sender: self)
    }
    
    func addMRHEHeaderView(){
        let mrheHeaderView = MRHEHeaderView.getMRHEHeaderView()
        self.view.addSubview(mrheHeaderView)
    }
    
    func addMRHELeftMenuView(){
        let mrheMenuView = MBRHELeftMenuView.getMBRHELeftMenuView()
        self.view.addSubview(mrheMenuView)
    }

    func showActivityIndicator() {
      let size = CGSize(width: 70, height: 70)
      startAnimating(size, message: "",messageFont: nil, type: NVActivityIndicatorType.ballBeat, color: UIColor(red: 0/255, green: 97/255, blue: 158/255, alpha: 1.0),padding:10)
      
        
    }
   
    func selectedName(name: String) {
        //self.txtFieldContractorName.text = name
    }
    
    @objc func presentSearchView() {
        
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SerachNameVC") as? SearchContractorNameVC
        {
            vc.searchDelegate = self
            present(vc, animated: false, completion: nil)
        }
        
    }
    
    @objc func filterApiCall(){
   
    
         if(Common.isConnectedToNetwork() == true){
        let service = FilterService()
        
      var parameter = Dictionary<String, Any>()
      
      let applicationNumber = self.txtFieldApplicationNumber.text
      let plotNumber = self.txtFieldLandNumber.text
   
      SharedResources.sharedInstance.plotNo = plotNumber!
      SharedResources.sharedInstance.applicationNo = applicationNumber!
    
      
      
//      if !SharedResources.sharedInstance.applicationNo.isEmpty {
//        applicationNumber = SharedResources.sharedInstance.applicationNo
//      }
//
//      if !SharedResources.sharedInstance.plotNo.isEmpty {
//        plotNumber = SharedResources.sharedInstance.plotNo
//      }
      
      if (applicationNumber?.count)! > 0 &&  (plotNumber?.count)! > 0 {
        
        parameter = ["plotNo":plotNumber  ?? String(),
                         "applicationNo":applicationNumber ?? String(),
                         "page":"0",
                         "pageSize":"10"]
        
        } else if (plotNumber?.count)! > 0 {
            parameter = ["plotNo":plotNumber ?? String(),
                         "page":"0",
                         "pageSize":"10"]
        } else if (applicationNumber?.count)! > 0 {
            parameter = ["applicationNo":applicationNumber ?? String(),
                         "page":"0",
                         "pageSize":"10"]
        } else if (applicationNumber?.count)! == 0 &&  (plotNumber?.count)! == 0 {
        self.presentError("please_enter_Application_number_or_Land_number".ls)
            return
        }
        
        showActivityIndicator()
        service.getContractorPayments(dict: parameter as! Dictionary<String, String>, completion: {(contractorPaymentResponce:ContractsResponse?) in
            self.stopAnimating()
            guard let responce = contractorPaymentResponce else {
                return
            }
            self.stopAnimating()
            if responce.success {
                if responce.payload.dashboard.count > 0 {
                    //Clear Objects
                    SharedResources.sharedInstance.contractsPayload.payload.dashboard.removeAll()
                    SharedResources.sharedInstance.contractsPayload.payload.filters.removeAll()
                    //Add new Payment Object
                    SharedResources.sharedInstance.contractsPayload = responce
                    self.moveToDashboard()
                }else{
                    //self.presentError("No Payments founds. Please change you filter.")
                }
            } else {
              if !responce.message.isEmpty{
                Common.showToaster(message: responce.message)

              }else {
                Common.showToaster(message: "bad_Gateway".ls)

              }
            }
        })
        
        }
         else{
            Common.showToaster(message: "no_Internet".ls)

        }
    }

    func moveToDashboard() {
      
        let contractsService = ContractsService()
        let dashboardViewModel = DashboardViewModel(contractsService)
        let dashboardViewController = DashboardViewController.create(with: dashboardViewModel)
        let navigationController = UINavigationController(rootViewController: dashboardViewController)
        navigationController.navigationBar.isHidden = true
      
        Common.appDelegate.window = UIWindow(frame: UIScreen.main.bounds)
        Common.appDelegate.window?.rootViewController = navigationController
        Common.appDelegate.window?.makeKeyAndVisible()
    }
    
//
//
//  // UITextField Delegates
//  func textFieldDidBeginEditing(_ textField: UITextField) {
//    print("TextField did begin editing method called")
//  }
  func textFieldDidEndEditing(_ textField: UITextField) {
    filterApiCall()
  }
//  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//    print("TextField should begin editing method called")
//    return true;
//  }
//  func textFieldShouldClear(_ textField: UITextField) -> Bool {
//    print("TextField should clear method called")
//    return true;
//  }
//  func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
//    print("TextField should snd editing method called")
//    return true;
//  }
//  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//
//    if textField == self.txtFieldLandNumber {
//      SharedResources.sharedInstance.plotNo = self.txtFieldLandNumber.text!
//    }else if textField == self.txtFieldApplicationNumber {
//      SharedResources.sharedInstance.applicationNo = self.txtFieldApplicationNumber.text!
//    }
//
//
//    print("While entering the characters this method gets called")
//    return true;
//  }
//  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//    print("TextField should return method called")
//    textField.resignFirstResponder();
//    return true;
//  }
//
//
//  func textFieldDidBeginEditing(_ textField: UITextField) {    //delegate method
//
//  }
//
//  func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {  //delegate method
//    return false
//  }
//
//  func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
//
//
//    return true
//  }
//
//  func textFieldDidChange(_ textField: UITextField) {
//
//  }
//
//  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
//
//
//      return true
//  }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
