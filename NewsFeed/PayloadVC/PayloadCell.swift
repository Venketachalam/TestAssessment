//
//  PayloadCell.swift
//  NewsFeed
//
//  Created by MAC on 8/14/19.
//  Copyright © 2019 Kuwy-Technology. All rights reserved.
//

import UIKit

class PayloadCell: UITableViewCell {
    @IBOutlet weak var bckView: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var contentImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 15
        self.bckView.layer.cornerRadius = 15
        self.contentView.layer.cornerRadius = 15
        self.bckView.addShadowdummy()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
extension UIView {
    func addShadowdummy(){
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 2.0
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.layer.cornerRadius = 15
}
}
