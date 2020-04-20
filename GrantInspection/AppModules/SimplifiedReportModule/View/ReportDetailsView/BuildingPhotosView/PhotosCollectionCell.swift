//
//  PhotosCollectionCell.swift
//  GrantInspection
//
//  Created by Rajeswaran Thangaperumal on 03/09/2019.
//  Copyright © 2019 MBRHE. All rights reserved.
//

import UIKit

class PhotosCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var borderView: MBRHEBorderView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    static let identifier = "PHOTO_CELL_ID"
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        // Initialization code
    }

//    override func prepareForReuse() {
//        self.imageView.image = nil
//    }
}
