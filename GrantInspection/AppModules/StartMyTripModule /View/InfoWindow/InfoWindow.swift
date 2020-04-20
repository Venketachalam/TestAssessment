//
//  ProjectInfoWindow.swift
//  Progress
//
//  Created by Muhammad Akhtar on 10/2/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import UIKit

class InfoWindow: UIView {

    @IBOutlet weak var statusView: MBRHEBorderView!
   
    
    @IBOutlet weak var requestNumberLabel: UILabel!
    
    @IBOutlet weak var applicationIdLabel: UILabel!
    
    @IBOutlet weak var customerNameLabel: UILabel!
    
    @IBOutlet weak var lanNumberLabel: UILabel!
    
    @IBOutlet weak var areaNameLabel: UILabel!
    
    @IBOutlet weak var detailsButton: UIButton!
    @IBOutlet weak var requestNumberStackview: UIStackView!
    
    @IBOutlet weak var idValueLbl: UILabel!
    
    @IBOutlet weak var applicationIdStackView: UIStackView!
    
    @IBOutlet weak var nameLbl: UILabel!
    
    @IBOutlet weak var customerNameStackView: UIStackView!
    
    @IBOutlet weak var laneNumberStackview: UIStackView!
    
    @IBOutlet weak var numberLbl: UILabel!
    
    @IBOutlet weak var areNameStackView: UIStackView!
    
    @IBOutlet weak var areaLbl: UILabel!
    
    
    
    let obj:ContractPaymentDetails = ContractPaymentDetails()
    
    class func getProjectInfoWindow() -> InfoWindow
    {
        return Bundle.main.loadNibNamed("InfoWindow", owner: self, options: nil)![0] as! InfoWindow
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Customize some properties
        if Common.currentLanguageArabic()
        {
            self.transform = Common.arabicTransform
            self.toArabicTransform()
           requestNumberStackview.transform = Common.arabicTransform
            requestNumberStackview.toArabicTransform()
            applicationIdStackView.transform = Common.arabicTransform
            applicationIdStackView.toArabicTransform()
            customerNameStackView.transform = Common.arabicTransform
            customerNameStackView.toArabicTransform()
            laneNumberStackview.transform = Common.arabicTransform
            laneNumberStackview.toArabicTransform()
            areNameStackView.transform = Common.arabicTransform
            areNameStackView.toArabicTransform()
        }
    }
    
    func setData(projectObj:Dashboard) {
        
        detailsButton.tag = Int(projectObj.applicationNo)
        requestNumberLabel.attributedText = "application_ID".ls.getAttributeString(color: .darkGray).joinedString(string: " # \(projectObj.applicationNo)".getAttributeString(color: .appBlueColor()))
        
       // applicationIdLabel.attributedText = "applicant_Id".ls.getAttributeString(color: .appBlueColor()).joinedString(string: " \(projectObj.applicantId)".getAttributeString(color: .darkGray))
        applicationIdLabel.text = "applicant_Id".ls
        applicationIdLabel.textColor = Common.appThemeColor
        idValueLbl.text = " \(projectObj.applicantId)"
        idValueLbl.textColor = .darkGray
        
        
//        customerNameLabel.attributedText = "customer_name".ls.getAttributeString(color: .appBlueColor()).joinedString(string:" \(projectObj.customerName)".getAttributeString(color: .darkGray))
        
        customerNameLabel.text = "customer_name".ls
        customerNameLabel.textColor = Common.appThemeColor
        nameLbl.text = " \(projectObj.customerName)"
        nameLbl.textColor = .darkGray
        
        
        lanNumberLabel.text = "land_no".ls
        lanNumberLabel.textColor = Common.appThemeColor
        if  Common.currentLanguageArabic()
        {
            numberLbl.text = "\(projectObj.plot.landNo) #"
        }
        else
        {
            numberLbl.text = "#\(projectObj.plot.landNo)"

        }
        numberLbl.textColor = .darkGray
                
//        lanNumberLabel.attributedText = "land_no".ls.getAttributeString(color: .appBlueColor()).joinedString(string: "#\(projectObj.plot.landNo)".getAttributeString(color: .darkGray))
        
        areaNameLabel.text = "area_name".ls
        areaNameLabel.textColor = Common.appThemeColor
        areaLbl.text = "\(projectObj.serviceRegion)"
        areaLbl.textColor = .darkGray
//        areaNameLabel.attributedText = "area_name".ls.getAttributeString(color: .appBlueColor()).joinedString(string: "\(projectObj.serviceRegion)".getAttributeString(color: .darkGray))
        statusView.backgroundColor = UIColor(hex: projectObj.colorTag)
    }
    
    
    
}
