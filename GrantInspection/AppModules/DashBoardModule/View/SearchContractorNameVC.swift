//
//  SearchContractorNameVC.swift
//  Progress
//
//  Created by Muhammad Akhtar on 11/20/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

protocol SearchNameVCDelegate {
    func selectedName(name: String)
}

class SearchContractorNameVC: UIViewController, UITableViewDelegate {

    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var txtFieldSearch: UITextField!
    private let disposeBag = DisposeBag()
    
    var nameList = [String]()
    var searchedNameList = Variable<[String]>([])
    var searchDelegate: SearchNameVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setTableView()
        nameList = ["Do any additional","setup after","loading the","the view."," can be recreated.","Dispose of any resources","Dispose of any resources","the view.","Dispose of any resources","Dispose of any resources"," can be recreated.","Dispose of any resources"]
        if nameList.count > 0 {
            self.txtFieldSearch.becomeFirstResponder()
        }
        searchedNameList.value = nameList
        txtFieldSearch.addTarget(self, action: #selector(searchRecordsAsPerText(_ :)), for: .editingChanged)
        
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.checkAction))
        self.bgView.addGestureRecognizer(gesture)
    }

   
    
    @objc func checkAction(sender : UITapGestureRecognizer) {
         self.dismiss(animated: false, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: -- Bind Table view ---
    func setTableView()  {
        
        searchedNameList.asObservable()
            .bind(to: tblView.rx.items(cellIdentifier: "Cell")){
                (_, name, cell) in
                if let cell = cell as? ContractorNameSearchCell {
                    cell.lblName.text = name
                }
            }
            .disposed(by: disposeBag)
        
        tblView.rx
            .modelSelected(String.self)
            .subscribe(onNext:  { name in
                //print(name)
                if let delegate = self.searchDelegate {
                    delegate.selectedName(name: name)
                }
                self.dismiss(animated: false, completion: nil)
            })
            .disposed(by: disposeBag)
    }
    
    
    
    @objc func searchRecordsAsPerText(_ textfield:UITextField) {
        searchedNameList.value.removeAll()
        let searchTxt = textfield.text
        
        if (searchTxt?.count)! > 0 {
          let filteredArray = nameList.filter { $0.contains(searchTxt as! String) }
            searchedNameList.value = filteredArray
        } else {
            searchedNameList.value = nameList
        }
    }
    
//    class func presentServiceView(_ completion: @escaping ((_ contractorName: String) -> Void)) {
//
//       
//    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
