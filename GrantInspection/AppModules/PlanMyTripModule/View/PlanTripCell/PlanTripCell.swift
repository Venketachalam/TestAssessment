//
//  PlanTripCell.swift
//  Progress
//
//  Created by Muhammad Akhtar on 10/1/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import UIKit

class PlanTripCell: UICollectionViewCell {

    @IBOutlet weak var containerView: MBRHEBorderView!
    @IBOutlet weak var statusView: MBRHEBorderView!
    @IBOutlet weak var lblContractNumberTitle: UILabel!
    @IBOutlet weak var lblContractNumber: UILabel!
    @IBOutlet weak var lblProjectId: UILabel!
    
    @IBOutlet weak var lblLastvisitTitle: UILabel!
    @IBOutlet weak var lblLastVisit: UILabel!
    @IBOutlet weak var lblDateTitle: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblAmmountTitle: UILabel!
    @IBOutlet weak var lblAmmount: UILabel!
    @IBOutlet weak var lblTotalBillPaymentTitle: UILabel!
    @IBOutlet weak var lblTotalBillPayment: UILabel!
    @IBOutlet weak var LblBillRetentionTitle: UILabel!
    @IBOutlet weak var LblBillRetention: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    func setData(projectObj:Dashboard) {
      

        self.statusView.backgroundColor = Common.hexStringToUIColor(hex: projectObj.colorTag)
        
        if (projectObj.isObjectSelected) {
            self.containerView.borderWidth  = 1.0
            self.containerView.borderColor = Common.appThemeColor
        } else {
            self.containerView.borderWidth  = 0.0
            self.containerView.borderColor = UIColor.clear
//            self.btnAddToTrip.setImage(UIImage.init(named: "add_white_icon"), for: .normal)
//            self.btnAddToTrip.backgroundColor = UIColor.init(red: 20/255, green: 193/255, blue: 139/255, alpha: 1.0)
        }
    }

}
