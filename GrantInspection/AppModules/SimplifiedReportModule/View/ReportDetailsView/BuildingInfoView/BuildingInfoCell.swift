//
//  BuildingInfoCell.swift
//  GrantInspection
//
//  Created by Rajeswaran Thangaperumal on 03/09/2019.
//  Copyright © 2019 MBRHE. All rights reserved.
//

import UIKit

class BuildingInfoCell: UITableViewCell {
    
    static let identifier = "BuildingInfoCell_ID"
    
    @IBOutlet weak var footerView: UIView!
    
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var buildingInfoView: BuildingInfoView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if Common.currentLanguageArabic()
        {
             self.transform = Common.arabicTransform
             self.toArabicTransform()
        }
        else
        {
            backButton.imageView?.transform = CGAffineTransform(rotationAngle: (180.0 * .pi) / 180.0)
            backButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -70, bottom: 0, right: 0)
            backButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        }
        backButton.setTitle("back_btn".ls, for: .normal)
        nextButton.setTitle("next_btn".ls, for: .normal)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        buildingInfoView.borderWithCornerRadius()
    }
    
    func setBuildingDetails(details:UserFacility,defaultFacilies:FacilityResponsePayload) {
        buildingInfoView.setBuildingData(data: details, defaultValues: defaultFacilies)
        buildingInfoView.setBuildingDatas()
    }
}
