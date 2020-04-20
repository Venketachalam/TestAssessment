//
//  TripInfoCell.swift
//  Progress
//
//  Created by Muhammad Akhtar on 10/28/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import UIKit
import RxSwift

class TripInfoCell: UITableViewCell {
    
    @IBOutlet weak var lblProjectOrderTitle: UILabel!
    @IBOutlet weak var lblProjectTitle: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblAppNo: UILabel!
    @IBOutlet weak var lblPaymentId: UILabel!
    @IBOutlet weak var btnMore: UIButton!
    @IBOutlet weak var lineView: MBRHEBorderView!
    
    @IBOutlet weak var requestNumberLabel: UILabel!
    @IBOutlet weak var lblPaymentIdLabel: UILabel!
    @IBOutlet weak var applicantIDLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var contentStackview: UIStackView!
    @IBOutlet weak var actionDateBtn: UIButton!
    
    let tripModelView = TripModelView()
    var disposeBag = DisposeBag()
    
    
    let alphabets = Array(arrayLiteral: "A","B","C","D","E","F","G","H","I","G","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z")
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.callButton.setTitle("callnow_btn_trip".ls, for: .normal)
        self.detailsLabel.text = "details_lbl".ls
        
        if Common.currentLanguageArabic()
        {
            self.transform = Common.arabicTransform
            contentStackview.transform = Common.arabicTransform
            contentStackview.toArabicTransform()
            callButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
            callButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        }
        else
        {
            
        }
        
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.disposeBag = DisposeBag()
    }
    func setData(obj: TripModel, indexValue: Int) {
       
        requestNumberLabel.attributedText = "file_number".ls.getAttributeString(color: .appBlueColor()).joinedString(string: " : \(obj.applicationNo)".getAttributeString(color: .darkGray))
        applicantIDLabel.attributedText = "applicant_Id".ls.getAttributeString(color: .appBlueColor()).joinedString(string: " \(obj.applicationId)".getAttributeString(color: .darkGray))
        actionDateBtn.setTitle(obj.time, for: .normal)        
        print("time: \(obj.time), AppNo: \(obj.applicationNo)")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setValues(details:Dashboard) {
        print(details)
        requestNumberLabel.attributedText = "file_number".ls.getAttributeString(color: .appBlueColor()).joinedString(string: " : \(details.applicationNo)".getAttributeString(color: .darkGray))
        applicantIDLabel.attributedText = "applicant_Id".ls.getAttributeString(color: .appBlueColor()).joinedString(string: " \(details.applicantId)".getAttributeString(color: .darkGray))
      //  actionDateBtn.setTitle(details.actionDate.serverDateFormatToNormal(), for: .normal)
        actionDateBtn.setTitle("-", for: .normal)
        
        
        if details.applicantMobileNo.isEmpty
        {
            self.callButton.isHidden = true
        }else
        {
            self.callButton.isHidden = false
        }
        
       
    }
    
    
}
