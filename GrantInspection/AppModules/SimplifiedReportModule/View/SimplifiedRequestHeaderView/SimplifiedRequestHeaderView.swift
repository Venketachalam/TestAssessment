//
//  SimplifiedRequestHeaderView.swift
//  GrantInspection
//
//  Created by Rajeswaran Thangaperumal on 28/08/2019.
//  Copyright © 2019 MBRHE. All rights reserved.
//

import UIKit

//protocol SimplifiedVCprotocol {
//    func backAction()
//}

class SimplifiedRequestHeaderView: UIView {
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var houseStatusLabel: UILabel!
    
    @IBOutlet weak var requestInformationLabel: UILabel!
    
    @IBOutlet weak var addNewBuildingButton: UIButton!
    
    @IBOutlet weak var addNewBuildingButtonConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var requestSummaryView: RequestInfoView!
    
    @IBOutlet weak var backButton: UIButton!
    
     @IBOutlet weak var addSatellitePhotoButton: UIButton!

    @IBOutlet weak var backButtonView: UIView!
    
    @IBOutlet weak var headingView: UIView!
    @IBOutlet weak var subHeadingView: UIView!
    @IBOutlet weak var addNewBuildView: UIView!
    
    @IBOutlet weak var toPrint: UIButton!
    
    @IBOutlet weak var reqInfoView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setLayout(){
        
        toPrint.setTitle("view_pdf_btn".ls, for: .normal)
        toPrint.isHidden = true
        if Common.currentLanguageArabic() {
            
            self.transform = Common.arabicTransform
            self.toArabicTransform()
            
            reqInfoView.transform = Common.arabicTransform
            reqInfoView.toArabicTransform()
            backButtonView.transform = Common.arabicTransform
            backButton.titleLabel?.transform = Common.arabicTransform
            backButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
       
            
            addNewBuildingButton.semanticContentAttribute = .forceRightToLeft
            addNewBuildingButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
            addNewBuildingButton.isUserInteractionEnabled = true
        }
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addNewBuildingButton.makeCircel()
        addNewBuildingButton.appyStyleWithImage()
    }
    
    private func setup()
    {
        Bundle.main.loadNibNamed("SimplifiedRequestHeaderView", owner: self, options: nil)
        contentView.translatesAutoresizingMaskIntoConstraints = true
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        self.addSubview(self.contentView)
        localizationSetup()
        setLayout()
    }
    
    func localizationSetup() {
        houseStatusLabel.text = "create_ reporthousestatus_lbl".ls
        requestInformationLabel.text = "request_information_lbl".ls
        addNewBuildingButton.setTitle("add_Building_btn".ls, for: .normal)
        backButton.setTitle("back_btn".ls, for: .normal)
        addSatellitePhotoButton.setTitle("addSatellitePhoto_lbl".ls, for: .normal)
        toPrint.setTitle("generate_Pdf_Btn".ls, for: .normal)
    }

    @IBAction func backBtnClick(_ sender: Any) {

    }
    
}

