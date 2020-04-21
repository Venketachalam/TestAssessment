//
//  FilterCell.swift
//  Progress
//
//  Created by Muhammad Akhtar on 10/10/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import UIKit

class FilterCell: UITableViewCell {

    @IBOutlet weak var filterOptionsView: MBRHEBorderView!
    @IBOutlet weak var lblFilterTitle: UILabel!
    @IBOutlet weak var btnSelectedFilter: UILabel!
    @IBOutlet weak var lineView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setData(filterOBJ:Filters)
    {
        self.lblFilterTitle.text = String(format: "%@" + "days".ls, filterOBJ.label)
        self.filterOptionsView.backgroundColor = Common.hexStringToUIColor(hex: filterOBJ.colorTag)
        
        let tag = Int(filterOBJ.value)
        if tag == 0 || tag == 1 || tag == 2 {
            // Specific days
            self.filterOptionsView.borderWidth = 0.0
            self.lineView.isHidden = false
            self.lblFilterTitle.text = String(format: "%@" + "days".ls, filterOBJ.label)
        } else if tag == 3 {
            // All projects
            self.filterOptionsView.borderColor = UIColor.gray
            self.filterOptionsView.borderWidth = 1.0
            self.lineView.isHidden = true
            self.lblFilterTitle.text = String(format: "%@", filterOBJ.label)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
