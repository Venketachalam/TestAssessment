//
//  BuildingPointCell.swift
//  GrantInspection
//
//  Created by Rajeswaran Thangaperumal on 15/09/2019.
//  Copyright © 2019 MBRHE. All rights reserved.
//

import UIKit

class BuildingPointCell: UITableViewCell {

    static let identifier = "BuildingPoint_cell_ID"
    
    
    @IBOutlet weak var buildingPtName: UILabel!
    
    @IBOutlet weak var editBtn: UIButton!
    
    @IBOutlet weak var stackVw: UIStackView!
    
    @IBOutlet weak var deleteBtn: UIButton!
    
    @IBOutlet weak var smallPointIndicatorImg: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        localizationSetup()
    }
    
    func localizationSetup()
    {
        editBtn.setTitle("edit_btn".ls, for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
