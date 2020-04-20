//
//  BuildingImageDetailsCell.swift
//  GrantInspection
//
//  Created by Rajeswaran Thangaperumal on 03/09/2019.
//  Copyright © 2019 MBRHE. All rights reserved.
//

import UIKit

class BuildingImageDetailsCell: UITableViewCell {
    
    @IBOutlet weak var buildingSateliteImageView: BuildingSatelliteView!
    @IBOutlet weak var buildingSiteImagesView: BuildingPhotosView!
    static let identifier = "BUILDING_IMAGES_CELL"
    
    var reqObj : Dashboard!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        buildingSateliteImageView.requestObject = reqObj
        print("callImg_det    ", reqObj)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.borderWithCornerRadius()
    }
    
}
