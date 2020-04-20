//
//  BuildingElementGridCell.swift
//  GrantInspection
//
//  Created by Rajeswaran Thangaperumal on 03/09/2019.
//  Copyright © 2019 MBRHE. All rights reserved.
//

import UIKit

class BuildingElementGridCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var countLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    static let identifier = "BuildingElementGrid_Cell"

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setLayout()
    }

    func setLayout(){
        
        if Common.currentLanguageArabic() {
            self.transform = Common.arabicTransform
            self.toArabicTransform()
            nameLabel.textAlignment = .center
            countLabel.textAlignment = .center
        }
    }
}
