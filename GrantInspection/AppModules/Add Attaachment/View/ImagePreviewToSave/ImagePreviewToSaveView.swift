//
//  ImagePreviewToSaveView.swift
//  GrantInspection
//
//  Created by Mohammed Hassan on 17/09/19.
//  Copyright © 2019 MBRHE. All rights reserved.
//

import UIKit

class ImagePreviewToSaveView: UIView {

    @IBOutlet weak var imageFromPreview: UIImageView!
    @IBOutlet weak var outerViewForImage: UIView!
    @IBOutlet weak var buildingTypeView: UIView!
     @IBOutlet weak var commentTextBox: UITextView!
    @IBOutlet weak var buildingTypeLabel: UILabel!
    @IBOutlet weak var buildingTitleLabel: UILabel!
     @IBOutlet weak var commentTitleLabel: UILabel!
   
    @IBOutlet weak var backButton: MBRHERoundButtonView!
    
    @IBOutlet weak var saveButton: MBRHERoundButtonView!
    
    
    override func awakeFromNib() {
        self.commentTextBox.layoutIfNeeded()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
       
    }
}
