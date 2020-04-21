//
//  ContractDetailViewController.swift
//  Progress
//
//  Created by Muhammad Akhtar on 6/18/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import UIKit

class ContractDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var contractsTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addMRHEHeaderView()
        addMRHELeftMenuView()
        setLayout()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func setLayout(){
        
        self.contractsTableView.register(UINib(nibName: "ContractorDetailTableViewCell",bundle: nil), forCellReuseIdentifier: "ContractorDetailTableViewCell")
        self.contractsTableView.delegate = self
        self.contractsTableView.dataSource = self
        
    }
    
    func addMRHEHeaderView(){
        let mrheHeaderView = MRHEHeaderView.getMRHEHeaderView()
        self.view.addSubview(mrheHeaderView)
    }
    
    func addMRHELeftMenuView(){
        let mrheMenuView = MBRHELeftMenuView.getMBRHELeftMenuView()
        self.view.addSubview(mrheMenuView)
    }
    
    // MARK: - UITableViewDataSource and Delegates
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int)->Int {
        //print(housingRequestsResponse.payload.count)
        return 4
    }
    
    func numberOfSections(in tableView:UITableView)->Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 216
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContractorDetailTableViewCell", for: indexPath) as! ContractorDetailTableViewCell
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "ContarctListToPaymentScreen", sender: self)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
