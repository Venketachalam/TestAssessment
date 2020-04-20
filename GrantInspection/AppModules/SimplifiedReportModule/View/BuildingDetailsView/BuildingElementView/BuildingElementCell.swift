//
//  BuildingElementCell.swift
//  GrantInspection
//
//  Created by Rajeswaran Thangaperumal on 29/08/2019.
//  Copyright © 2019 MBRHE. All rights reserved.
//

import UIKit

class BuildingElementCell: UICollectionViewCell {

     static var Identifier = "BuildingDetailsCell"
    
    
    @IBOutlet weak var lblView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var  steeperView: CustomStepper!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setLayout()
    }
    
    func setValue(title:String,value:Int) {
        titleLabel.text = title
        steeperView.valueLabel.text = String(format: "%02d", value)
    }

    
    func setLayout(){
        
        if Common.currentLanguageArabic() {
            
            self.lblView.transform = Common.arabicTransform
            self.lblView.toArabicTransform()
        }
    }
}
