//
//  BuildingPhotoDetailsCell.swift
//  GrantInspection
//
//  Created by Rajeswaran Thangaperumal on 05/09/2019.
//  Copyright © 2019 MBRHE. All rights reserved.
//

import UIKit

class BuildingPhotoDetailsCell: UICollectionViewCell {
    
    static let identifier = "PHOTO_CELL_ID"

    
    @IBOutlet weak var photoThumbImgView: UIImageView!
    
    @IBOutlet weak var commentsLbl: UILabel!
    @IBOutlet weak var photoCommentsLabel: UILabel!
    @IBOutlet weak var photoViewCountLbl: UILabel!
    
    @IBOutlet weak var generateImg_Btn: UIButton!
    
    @IBOutlet weak var pdfGenerateBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        commentsLbl.text = "comments_lbl".ls
        
        photoViewCountLbl.isHidden = true
    }
    
    
    
}
