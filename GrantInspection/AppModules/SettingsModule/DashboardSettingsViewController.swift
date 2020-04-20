//
//  DashboardSettingsViewController.swift
//  GrantInspection
//
//  Created by Mohammed Hassan on 26/09/19.
//  Copyright © 2019 MBRHE. All rights reserved.
//

import UIKit

class DashboardSettingsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var dashboardSettingsTableView: UITableView!
    var dashboardSettingsHeaderView = DashboardSettingsHeaderView()
    @IBOutlet weak var headerView: UIView!
    var settingsArr = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        
        
        dashboardSettingsTableView.layer.cornerRadius = 15.0
        dashboardSettingsTableView.layer.masksToBounds = true
        self.dashboardSettingsTableView.tableFooterView = UIView()
        
        dashboardSettingsTableView.register(UINib(nibName: "\(DashboardSettingsTableViewCell.self)", bundle: Bundle.main), forCellReuseIdentifier: DashboardSettingsTableViewCell.Identifier)
        setupUI()
    }
    
    func setupUI()
    {
        if Common.currentLanguageArabic()
        {
            self.view.transform  = Common.arabicTransform
            self.view.toArabicTransform()
            headerView.transform = Common.arabicTransform
          
            addMRHELeftMenuView()
        }
        else
        {
            self.view.transform  = Common.englishTransform
            self.view.toEnglishTransform()
            dashboardSettingsTableView.transform = Common.englishTransform
            dashboardSettingsHeaderView.transform = Common.englishTransform
            addMRHELeftMenuView()
        }
        dashboardSettingsTableView.separatorColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        
        
    }
    
    func addMRHEHeaderView(){
        let mrheHeaderView = MRHEHeaderView.getMRHEHeaderView()
        self.view.addSubview(mrheHeaderView)
    }
    
    func addMRHELeftMenuView(){
        
        let mrheMenuView = MBRHELeftMenuView.getMBRHELeftMenuView()
        self.view.addSubview(mrheMenuView)
        if Common.currentLanguageArabic()
        {
            mrheMenuView.transform = Common.arabicTransform
        }
        else
        {
            mrheMenuView.transform = Common.englishTransform
        }
        self.settingsArr = ["arabic_Language_lbl".ls]
    }
    
    //MARK: - UITableview Delegate Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsArr.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
        
        dashboardSettingsHeaderView = UINib(nibName: "DashboardSettingsHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! DashboardSettingsHeaderView
        dashboardSettingsHeaderView.frame = headerView.frame
        dashboardSettingsHeaderView.settingsTitleLbl.text = "settings_menu".ls
        
        if Common.currentLanguageArabic() {
            dashboardSettingsHeaderView.settingsTitleLbl.transform = Common.arabicTransform
            dashboardSettingsHeaderView.settingsTitleLbl.toArabicTransform()
            dashboardSettingsHeaderView.settingsTitleLbl.textAlignment = .right
        }
        
        headerView.addSubview(dashboardSettingsHeaderView)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DashboardSettingsTableViewCell.Identifier, for: indexPath) as? DashboardSettingsTableViewCell  else { return UITableViewCell()
            
        }
        cell.selectionStyle = .none
        if indexPath.row == 0 //language Setting
        {
            if Common.currentLanguageArabic()
            {
                cell.settingsSwitch.isOn = true
            }
            else
            {
                cell.settingsSwitch.isOn = false
                cell.settingsSwitch.set(offTint: UIColor(red: 168/255, green: 168/255, blue: 169/255, alpha: 1))
            }
            cell.settingsTextLbl.text = settingsArr[0]
            cell.settingsSwitch.tag = 0
            cell.updateBtn.isHidden = true

        }
        else
        {
            cell.settingsTextLbl.text = settingsArr[indexPath.row]
            cell.settingsSwitch.tag = indexPath.row
        }
        cell.settingsSwitch.onTintColor = Common.appThemeColor
        cell.settingsTextLbl.font = UIFont(name: "NeoSansArabic", size: 17)
        cell.settingsTextLbl.textColor = UIColor(red: 90/255, green: 90/255, blue: 90/255, alpha: 1)
        cell.settingsSwitch.addTarget(self, action: #selector(switchValueDidChange(_:)), for: .valueChanged)
        if Common.currentLanguageArabic()
        {
            cell.settingsTextLbl.semanticContentAttribute = .forceRightToLeft
        }
        return cell
    }
    
    //MARK: - Button Action
    @objc func switchValueDidChange(_ sender: UISwitch)
    {
        
        if sender.tag == 0 //language change
        {
            if sender.isOn
            {
                Localization.storeCurrentLanguage("ar")
                self.view.transform  = Common.arabicTransform
                headerView.transform = Common.arabicTransform
                self.view.toArabicTransform()
                addMRHELeftMenuView()

            }
            else
            {
                Localization.storeCurrentLanguage("en")
                self.view.transform  = Common.englishTransform
                self.view.toEnglishTransform()
                headerView.transform = Common.englishTransform
                dashboardSettingsTableView.transform = Common.englishTransform
                dashboardSettingsHeaderView.transform = Common.englishTransform
                addMRHELeftMenuView()
            }
            
            dashboardSettingsTableView.reloadData()
        }
        else
        {
            //remaining settings
        }
        
        dashboardSettingsHeaderView.settingsTitleLbl.text = "settings_menu".ls
    }
    
}

extension UISwitch {

    func set(offTint color: UIColor ) {
        let minSide = min(bounds.size.height, bounds.size.width)
        layer.cornerRadius = minSide / 2
        backgroundColor = color
        tintColor = color
    }
}
