//
//  NotesCustomCell.swift
//  Progress
//
//  Created by Muhammad Akhtar on 11/13/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import UIKit

class NotesCustomCell: UITableViewCell {

    @IBOutlet weak var lblRemarks: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(obj:String){
        self.lblRemarks.text = obj
    }
}
