//
//  DashboardSettingsTableViewCell.swift
//  GrantInspection
//
//  Created by Mohammed Hassan on 26/09/19.
//  Copyright © 2019 MBRHE. All rights reserved.
//

import UIKit

class DashboardSettingsTableViewCell: UITableViewCell {
    @IBOutlet weak var settingsTextLbl: UILabel!
    
    @IBOutlet weak var updateBtn: CustomButton!
    
    @IBOutlet weak var settingsSwitch: UISwitch!
    static var Identifier = "DashboardSettingsCell"
    override func awakeFromNib() {
        super.awakeFromNib()
       
        if Common.currentLanguageArabic()
        {
            settingsTextLbl.transform = Common.arabicTransform
        }
        else
        {
            settingsTextLbl.transform = Common.englishTransform
        }
        updateBtn.type = .blue
        // Initialization code
    }

   
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
