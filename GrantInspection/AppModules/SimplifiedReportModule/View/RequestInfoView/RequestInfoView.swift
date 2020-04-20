//
//  RequestInfoView.swift
//  GrantInspection
//
//  Created by Rajeswaran Thangaperumal on 28/08/2019.
//  Copyright © 2019 MBRHE. All rights reserved.
//

import UIKit

struct RequestInfo {
    var applicationNo: String
    var applicantID: String
    var customerName: String
    var lanNo: String
    var duraton: String
    var areaName: String
    var plotArea: String
    
}

class RequestInfoView: UIView {
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var applicationIDLabel: UILabel!
    
    @IBOutlet weak var customerNameLabel: UILabel!
    
    @IBOutlet weak var landNumberLabel: UILabel!
    
    @IBOutlet weak var durationLabel: UILabel!
    
    @IBOutlet weak var areaNameLabel: UILabel!
    
    @IBOutlet weak var plotAreaLabel: UILabel!
    
    
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
            
            self.transform = Common.arabicTransform
            self.toArabicTransform()
        }
    }
    
    private func setup() {
        Bundle.main.loadNibNamed("RequestInfoView", owner: self, options: nil)
        contentView.translatesAutoresizingMaskIntoConstraints = true
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        self.addSubview(self.contentView)
        defaultLabelSetup()
        
        setLayout()
    }
    

    
    func defaultLabelSetup() {
        applicationIDLabel.attributedText = "application_ID".ls.getAttributeString(color: .appBlueColor())
        customerNameLabel.attributedText = "customer_name".ls.getAttributeString(color: .appBlueColor())
        landNumberLabel.attributedText = "land_no".ls.getAttributeString(color: .appBlueColor())
        durationLabel.attributedText = "duration".ls.getAttributeString(color: .appBlueColor())
        areaNameLabel.attributedText = "area_name".ls.getAttributeString(color: .appBlueColor())
        plotAreaLabel.attributedText = "plot_area_lbl".ls.getAttributeString(color: .appBlueColor())
        
        
    }
    
    func setRequestDetails(details:RequestInfo) {
        applicationIDLabel.attributedText = "application_ID".ls.getAttributeString(color: .appBlueColor()).joinedString(string: " \(details.applicantID)".getAttributeString(color: .darkGray))
        customerNameLabel.attributedText = "customer_name".ls.getAttributeString(color: .appBlueColor()).joinedString(string: " \(details.customerName)".getAttributeString(color: .darkGray))
        
        var detailsOfLandNoString = String()
        var areaNameString = String()
        var plotAreaString = String()
        
        
        if details.lanNo.isEmpty {
            detailsOfLandNoString = " -"
        }else
        {
            detailsOfLandNoString = details.lanNo
        }
        
        if details.areaName.isEmpty {
            areaNameString = " -"
        } else {
            areaNameString = details.areaName
        }
        
        if details.plotArea.isEmpty {
            plotAreaString = " -"
        }else {
            plotAreaString = details.plotArea
        }
        
        
        landNumberLabel.attributedText = "land_no".ls.getAttributeString(color: .appBlueColor()).joinedString(string: " \(detailsOfLandNoString)".getAttributeString(color: .darkGray))
        durationLabel.attributedText = "duration".ls.getAttributeString(color: .appBlueColor()).joinedString(string: "\( details.duraton)".getAttributeString(color: .darkGray))
        areaNameLabel.attributedText = "area_name".ls.getAttributeString(color: .appBlueColor()).joinedString(string: "\(areaNameString)".getAttributeString(color: .darkGray))
        plotAreaLabel.attributedText = "plot_area_lbl".ls.getAttributeString(color: .appBlueColor()).joinedString(string: " \(plotAreaString)".getAttributeString(color: .darkGray))
       
        
    }
    
}
