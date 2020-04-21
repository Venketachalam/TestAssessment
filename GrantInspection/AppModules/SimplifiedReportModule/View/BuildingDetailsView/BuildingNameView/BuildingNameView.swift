//
//  BuildingNameView.swift
//  GrantInspection
//
//  Created by Rajeswaran Thangaperumal on 02/09/2019.
//  Copyright © 2019 MBRHE. All rights reserved.
//

import UIKit

class BuildingNameView: UIView {

    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var buildingTitleLabel: UILabel!
    
    @IBOutlet weak var viewButton: UIButton!
    
    @IBOutlet weak var docImageView: UIImageView!
    
    @IBOutlet weak var buttonStackView: UIStackView!
    @IBOutlet weak var contentStackView: UIView!
    
    @IBOutlet weak var headerLabel: UILabel!
    
    @IBOutlet weak var deleteButton: UIButton!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
       self.contentStackView.borderWithCornerRadius()
        
    }
    
    private func setup() {
        Bundle.main.loadNibNamed("BuildingNameView", owner: self, options: nil)
        contentView.translatesAutoresizingMaskIntoConstraints = true
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        self.addSubview(self.contentView)
        viewButton.setTitle("view_btn".ls, for: .normal)
        editButton.setTitle("edit_btn".ls, for: .normal)
        headerLabel.text = "A_Simplified_report_lbl".ls
        deleteButton.setTitle("delete_btn".ls, for: .normal)
        setLayout()
    }
    
    
    func setLayout(){
        
        if Common.currentLanguageArabic() {
            print(editButton.imageEdgeInsets)
            self.transform = Common.arabicTransform
            self.toArabicTransform()
            self.viewButton.semanticContentAttribute = .forceLeftToRight
            self.viewButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
            
            self.deleteButton.semanticContentAttribute = .forceLeftToRight
            self.deleteButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
            
            self.editButton.semanticContentAttribute = .forceLeftToRight
            self.editButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        
        }
        else{
            print(editButton.imageEdgeInsets)
            self.transform = Common.englishTransform
            self.toEnglishTransform()
            
        }
    }

    
    func showEditReportView() {
        editButton.isHidden = false
        viewButton.isHidden = true
        docImageView.isHidden = true
        //docImageView.superview?.isHidden = true
        buildingTitleLabel.textColor = .black
        headerLabel.isHidden = true
    }
    
    func showSavedReportView(date: String) {
        editButton.isHidden = false
        viewButton.isHidden = false
        docImageView.isHidden = false
        //docImageView.superview?.isHidden = false
        if date.isEmptyString()
        {
            buildingTitleLabel.text = "simplified_report_lbl".ls
        }
        else
        {
            buildingTitleLabel.text = "simplified_report_lbl".ls + " - \(date)"
        }
        buildingTitleLabel.textColor = .darkGray
        headerLabel.isHidden = false
    }
    
}



