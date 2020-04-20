//
//  NotificationListViewController.swift
//  GrantInspection
//
//  Created by Mohammed Hassan on 19/09/19.
//  Copyright © 2019 MBRHE. All rights reserved.
//

import UIKit

class NotificationListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var notificationTableView: UITableView!
    
    var notificationHeader = NotificationHeaderView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
         notificationTableView.register(UINib(nibName: "\(NotificationListTableViewCell.self)", bundle: Bundle.main), forCellReuseIdentifier: NotificationListTableViewCell.Identifier)
        
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 60))
        
         notificationHeader = UINib(nibName: "NotificationHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! NotificationHeaderView
        
        notificationHeader.frame = headerView.frame
        headerView.addSubview(notificationHeader)
  
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
          guard let cell = tableView.dequeueReusableCell(withIdentifier: NotificationListTableViewCell.Identifier, for: indexPath) as? NotificationListTableViewCell  else { return UITableViewCell() }
        
        
        return cell
        
    }
    

}
