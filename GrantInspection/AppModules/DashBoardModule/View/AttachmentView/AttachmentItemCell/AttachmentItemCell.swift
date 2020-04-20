//
//  AttachmentItemCell.swift
//  Progress
//
//  Created by Muhammad Akhtar on 11/6/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import UIKit

class AttachmentItemCell: UICollectionViewCell {

    @IBOutlet weak var imageViewAttachmentType: UIImageView!
    @IBOutlet weak var lblAttachmentName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        if Common.currentLanguageArabic() {
            lblAttachmentName.transform = Common.arabicTransform
            lblAttachmentName.toArabicTransform()
            imageViewAttachmentType.transform = Common.arabicTransform
            imageViewAttachmentType.toArabicTransform()
        }
    }
    
    func setDataWith(obj:AttachmentItemModel) {
        self.lblAttachmentName.text = obj.attachmentName
        if obj.fileExtension == "png" {
            self.imageViewAttachmentType.image = UIImage.init(named: "png_icon")
        } else if obj.fileExtension == "pdf" {
            self.imageViewAttachmentType.image = UIImage.init(named: "pdf_icon")
        } else if obj.fileExtension == "jpeg" {
            self.imageViewAttachmentType.image = UIImage.init(named: "jpg_icon")
        }
       
    }
    
}
