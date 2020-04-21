//
//  RequestDetailsView.swift
//  GrantInspection
//
//  Created by Rajeswaran Thangaperumal on 28/08/2019.
//  Copyright © 2019 MBRHE. All rights reserved.
//

import UIKit

protocol RequestDetailsViewDelegate {
    func createReportAction()
    func backAction()
}

class RequestDetailsView: UIView {
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var createReportButton: UIButton!
    
    @IBOutlet weak var requestStatusIndicatorView: UIView!
    
    @IBOutlet weak var requestNumberLabel: UILabel!
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var topHeadingView: UIView!
    
     @IBOutlet weak var infoView: RequestInfoView!
    
    @IBOutlet weak var backButtonView: UIView!

    var delegate: RequestDetailsViewDelegate!

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
   
    func setLayout(){
        
        if Common.currentLanguageArabic() {
            
            self.topHeadingView.transform = Common.arabicTransform
            self.topHeadingView.toArabicTransform()
            self.backButtonView.transform = Common.arabicTransform
            backButton.titleLabel?.transform = Common.arabicTransform
            backButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
            createReportButton.semanticContentAttribute = .forceLeftToRight
            createReportButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
         
            
        }
        else {
            
            createReportButton.semanticContentAttribute = .forceRightToLeft
            createReportButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        }
    }
    
   private func setup() {
       Bundle.main.loadNibNamed("RequestDetailsView", owner: self, options: nil)
       contentView.translatesAutoresizingMaskIntoConstraints = true
       contentView.frame = self.bounds
       contentView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
       self.addSubview(self.contentView)
       defaultLabelSetup()
       setLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        //createReportButton.makeCircel()
        requestStatusIndicatorView.makeCircel()
        createReportButton.appyStyleWithImage()
    }
    
    func defaultLabelSetup() {
        requestNumberLabel.attributedText = "application_ID".ls.getAttributeString(color: .black)
        createReportButton.setTitle("create _report_lbl".ls, for: .normal)
        backButton.setTitle("back_btn".ls, for: .normal)

        
    }
    
    func setRequestDetails(details:RequestInfo,indicatorColor:String) {

        infoView.setRequestDetails(details: details)
        requestNumberLabel.attributedText = "application_ID".ls.getAttributeString(color: .black).joinedString(string: " #\(details.applicantID)".getAttributeString(color: .appBlueColor()))
        requestStatusIndicatorView.backgroundColor = UIColor(hex: indicatorColor)
        self.layoutIfNeeded()
    }
    
    @IBAction func createReportButtonAction(sender: UIButton) {
        if let _ = delegate {
            delegate.createReportAction()
        }
    }
    
    @IBAction func backButtonAction(sender: UIButton) {
        if let _ = delegate {
            delegate.backAction()
        }
    }
}



