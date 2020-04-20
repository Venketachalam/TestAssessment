//
//  FinalReportNotesCell.swift
//  GrantInspection
//
//  Created by Rajeswaran Thangaperumal on 03/09/2019.
//  Copyright © 2019 MBRHE. All rights reserved.
//

import UIKit

class FinalReportNotesCell: UITableViewCell {
    
    static let identifier = "NOTES_CELL_ID"
    
    @IBOutlet weak var conclusionLabel: UILabel!
    
    @IBOutlet weak var recommendationTitleLabel: UILabel!
    @IBOutlet weak var recommendationLabel: UILabel!
    
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var generatePdfButton: MBRHERoundButtonView!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var verticalExapnsion: UILabel!
    
    @IBOutlet weak var horizontalExapnsion: UILabel!
    
    @IBOutlet weak var possibilityExpansionLbl: UILabel!
    @IBOutlet weak var conclusionLbl: UILabel!
    @IBOutlet weak var verticalLbl: UILabel!
    @IBOutlet weak var horizontalLbl: UILabel!
    @IBOutlet weak var constructionTitleLabel: UILabel!
    @IBOutlet weak var constructionValueLabel: UILabel!
    @IBOutlet weak var houseStatusTitleLabel: UILabel!
    @IBOutlet weak var houseStatusValueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setLayout()
        possibilityExpansionLbl.text = "posibility_expansion_lbl".ls
        conclusionLbl.text = "conclusion_lbl".ls
        recommendationTitleLabel.text = "recommendation_lbl".ls
        backButton.setTitle("back_btn".ls, for: .normal)
        submitButton.setTitle("submit_report_btn".ls, for: .normal)
        verticalLbl.text = "vertical".ls
        horizontalLbl.text = "horizontal".ls
        generatePdfButton.setTitle("generate_Pdf_Btn".ls, for: .normal)
        constructionTitleLabel.text = "the_approximate_construction_lbl".ls
        houseStatusTitleLabel.text = "house_Status_lbl".ls
        if Common.currentLanguageArabic()
        {
            backButton.imageView?.transform = CGAffineTransform(rotationAngle: (-180.0 * .pi) / 90.0)
            backButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 0)
            backButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        }
        else
        {
            backButton.imageView?.transform = CGAffineTransform(rotationAngle: (180.0 * .pi) / 180.0)
            backButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -70, bottom: 0, right: 0)
            backButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.borderWithCornerRadius()
    }
    
    func setLayout(){
        
        if Common.currentLanguageArabic() {
            
            self.transform = Common.arabicTransform
            self.toArabicTransform()
        }
    }
    
    func setReportDetails(details:InspectionReportRespose,expansions:[FacilityExpansions],houseStatus:[HouseStatus]) {
        
        let hExpansionID = Int(details.expansionIdHor) ?? 0
        let vExpansionID = Int(details.expansionIdVart) ?? 0
        
        let houseStatusId = Int(details.houseStatusId) ?? 0
        
        
        if details.expansionIdHor.count > 0 && hExpansionID > 0 {
            let hExpanseObj = expansions.filter({$0.expansionType == 0}).filter({$0.expansionId == hExpansionID}).first
            horizontalExapnsion.text = hExpanseObj?.expansionNameValue()
        }
        if details.expansionIdVart.count > 0 && vExpansionID > 0 {
            let vExpanseObj = expansions.filter({$0.expansionType == 1}).filter({$0.expansionId == vExpansionID}).first
            verticalExapnsion.text = vExpanseObj?.expansionNameValue()
        }
        
        if details.houseStatusId.count > 0 && houseStatusId > 0 {
            let houseStatusObj = houseStatus.filter({$0.id == houseStatusId}).first
            print(houseStatusObj as Any)
            
            houseStatusValueLabel.text = houseStatusObj?.statusName()
        }
        
        
        constructionValueLabel.text = details.approximateConstructionSize
        conclusionLabel.text = details.remarks
        recommendationLabel.text = details.recommendation
    }
}
