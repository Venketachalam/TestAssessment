//
//  BuildingExteriorDetailsView.swift
//  GrantInspection
//
//  Created by Rajeswaran Thangaperumal on 30/08/2019.
//  Copyright © 2019 MBRHE. All rights reserved.
//

import UIKit

class BuildingExteriorDetailsView: UIView {
    
    @IBOutlet weak var contentView: UIView!
    
  @IBOutlet weak var subView: UIStackView!
  @IBOutlet weak var createSimplipifiedButton: UIButton!
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var houseStatusSelectionView: SelectionView!
    
    @IBOutlet weak var houseStatusInnerSelectionView: SelectionView!
    
    @IBOutlet weak var horizontalExpansionSelectionView: SelectionView!
    
    @IBOutlet weak var verticalExpansionSelectionView: SelectionView!
    
    @IBOutlet weak var recommendationnSelectionView: SelectionView!
    
    @IBOutlet weak var conclusionTextView: UITextView!
    
    @IBOutlet weak var recommendationTextView: UITextView!
    
    @IBOutlet weak var constructionSizeTextField: UITextField!
    
    
    @IBOutlet weak var borderView: MBRHEBorderView!
    
    @IBOutlet weak var horizontalExpanView: UIView!
    @IBOutlet weak var verticalExpnView: UIView!
    
    @IBOutlet weak var horiz_TitleHolderVw: UIView!
    
    
    @IBOutlet weak var horizonPossbleTitle: UILabel!
    @IBOutlet weak var verticalPossbleTitle: UILabel!
    
    @IBOutlet weak var houseStatusTitleLbl: UILabel!
    
    @IBOutlet weak var theApproximateConstructionTitleLbl: UILabel!
    
    @IBOutlet weak var conclusionTitleLbl: UILabel!
    
    @IBOutlet weak var recommentationTitleLbl: UILabel!
    
    let report = InspectionReportPayload()
    var reportDetails:FacilityResponsePayload!
    
    
    @IBOutlet weak var recommendHolderView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        houseStatusInnerSelectionView.isHidden = true

        horizontalExpansionSelectionView.borderWithCornerRadius()
        verticalExpansionSelectionView.borderWithCornerRadius()
        conclusionTextView.applyStyle()
        recommendationTextView.applyStyle()
        constructionSizeTextField.applyStyle()
        
    }
    
    private func setup() {
        Bundle.main.loadNibNamed("BuildingExteriorDetailsView", owner: self, options: nil)
        contentView.translatesAutoresizingMaskIntoConstraints = true
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        self.addSubview(self.contentView)
        setBuildingExteriorDetails()
        
        setLayout()
        constructionSizeTextField.placeholder = "construction_size_lbl".ls
        constructionSizeTextField.delegate = self
    }
    
    func setLayout(){
        
        if Common.currentLanguageArabic() {
            
            DispatchQueue.main.async {
               self.transform = Common.arabicTransform
               self.toArabicTransform()
                
                self.backButton.semanticContentAttribute = .forceRightToLeft
    
            }
            backButton.setTitleColor(Common.appThemeColor, for: .normal)
        }
        else
        {
            backButton.imageView?.transform = CGAffineTransform(rotationAngle: (180.0 * .pi) / 180.0)
            backButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -70, bottom: 0, right: 0)
            backButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
            backButton.setTitleColor(Common.appThemeColor, for: .normal)
        }
        backButton.setTitle("back_btn".ls, for: .normal)
        horizonPossbleTitle.text = "horizontal_expansion_lbl".ls
        verticalPossbleTitle.text = "vertical_expansion_lbl".ls
        houseStatusTitleLbl.text = "house_Status_lbl".ls
        theApproximateConstructionTitleLbl.text = "the_approximate_construction_lbl".ls
        conclusionTitleLbl.text = "conclusion_lbl".ls
        recommentationTitleLbl.text = "recommendation_lbl".ls
        createSimplipifiedButton.setTitle("create_simplified_report_lbl".ls, for: .normal)
    }
    
    
    
    func setBuildingExteriorDetails(facilities:FacilityResponsePayload?=nil) {

        if Common.currentLanguageArabic() {
            self.constructionSizeTextField.setRightPaddingPoints(10)
        } else {
            self.constructionSizeTextField.setLeftPaddingPoints(10)
        }
        
        var houseStatus = ["rented".ls,"deserted".ls,"occupied_by_the_citizen".ls]
               var expensionHorizontal = ["totally_allowd".ls,"not_allowed".ls,"partially_possible".ls]
               var expensionVertical = ["need_more_examination".ls,"totally_allowd".ls,"not_allowed".ls,"partially_possible".ls]
               var recommendations = ["out_of_conditions".ls,"remove_and_replace".ls,"maintenance".ls,"good".ls]

        if let value = facilities {
            reportDetails=value
            houseStatus=reportDetails.houseStatus.map({$0.statusName()})
            expensionHorizontal=reportDetails.expansions.filter({$0.expansionType==0}).map({$0.expansionNameValue()})
            expensionVertical=reportDetails.expansions.filter({$0.expansionType==1}).map({$0.expansionNameValue()})
            recommendations = reportDetails.facilityPayload.facilityActions.map({$0.actionName()})
        }
        
        
        if Common.currentLanguageArabic()
        {
             houseStatusSelectionView.setSelectionData(titles: houseStatus, selectedImage: #imageLiteral(resourceName: "checkRBox_S"), defaultImage: #imageLiteral(resourceName: "checkBox"), curentSelctionIndex: 0)
           
                    horizontalExpansionSelectionView.setSelectionData(titles: expensionHorizontal, selectedImage: #imageLiteral(resourceName: "checkRBox_S"), defaultImage: #imageLiteral(resourceName: "checkBox"), curentSelctionIndex: 0)
                    verticalExpansionSelectionView.setSelectionData(titles: expensionVertical, selectedImage: #imageLiteral(resourceName: "checkRBox_S"), defaultImage: #imageLiteral(resourceName: "checkBox"), curentSelctionIndex: 0)
        }
        else
        {
             houseStatusSelectionView.setSelectionData(titles: houseStatus, selectedImage: #imageLiteral(resourceName: "checkBox_S"), defaultImage: #imageLiteral(resourceName: "checkBox"), curentSelctionIndex: 0)
            
                    horizontalExpansionSelectionView.setSelectionData(titles: expensionHorizontal, selectedImage: #imageLiteral(resourceName: "checkBox_S"), defaultImage: #imageLiteral(resourceName: "checkBox"), curentSelctionIndex: 0)
                    verticalExpansionSelectionView.setSelectionData(titles: expensionVertical, selectedImage: #imageLiteral(resourceName: "checkBox_S"), defaultImage: #imageLiteral(resourceName: "checkBox"), curentSelctionIndex: 0)
        }
       
        recommendationnSelectionView.setSelectionData(titles: recommendations, curentSelctionIndex: 0)
    }
    
    
    func setBuildingReportDetails(details:InspectionReportRespose) {
        
      report.inspectionReport = details
      self.constructionSizeTextField.text = details.approximateConstructionSize
      self.conclusionTextView.text = details.remarks
      self.recommendationTextView.text = details.recommendation
        
       
        guard let facilityData = reportDetails else { return  }
       
        if details.houseStatusId.count > 0 && Int(details.houseStatusId) ?? 0 > 0 {
           
            let selectedObject = facilityData.houseStatus.index(where: { $0.id == Int(details.houseStatusId) })
            for subView in self.houseStatusSelectionView.stackView.arrangedSubviews {
                if let button = subView as? UIButton {
                    if button.tag == selectedObject {
                        button.isSelected = true
                    } else {
                        button.isSelected = false
                    }
                    
                }
            }
        }
        
        
        if details.expansionIdHor.count > 0 && Int(details.expansionIdHor) ?? 0 > 0 {
            let horizontalExpansion = facilityData.expansions.filter({$0.expansionType == 0 })
            
            let selectedObject = horizontalExpansion.index(where: { $0.expansionId == Int(details.expansionIdHor) })
            for subView in self.horizontalExpansionSelectionView.stackView.arrangedSubviews {
                if let button = subView as? UIButton {
                    if button.tag == selectedObject {
                        button.isSelected = true
                    } else {
                        button.isSelected = false
                    }
                    
                }
            }
        }
        
        if details.expansionIdVart.count > 0 && Int(details.expansionIdVart) ?? 0 > 0 {
            let verticalExpansion = facilityData.expansions.filter({$0.expansionType == 1 })
            
            let selectedObject = verticalExpansion.index(where: { $0.expansionId == Int(details.expansionIdVart) })
            for subView in self.verticalExpansionSelectionView.stackView.arrangedSubviews {
                if let button = subView as? UIButton {
                    if button.tag == selectedObject {
                        button.isSelected = true
                    } else {
                        button.isSelected = false
                    }
                    
                }
            }
        }
        
        
        if details.actionId.count > 0 && Int(details.actionId) ?? 0 > 0 {
           
            let buildingConditionObject = facilityData.facilityPayload.facilityActions.index(where: { $0.fActionId == Int(details.actionId)})
            for subView in self.recommendationnSelectionView.stackView.arrangedSubviews {
                if let button = subView as? UIButton {
                    if button.tag == buildingConditionObject {
                        button.isSelected = true
                        DispatchQueue.main.async {
                            button.applyStyle(color: UIColor.blueGradient())
                        }
                        
                    } else {
                        button.isSelected = false
                        button.applyStyle()
                    }
                    
                }
            }
        }
        
        
    }
    
    
    func exteriorBuildingDetailsPostData ()->ReportErrorHandle {
        

        guard let houseStatusData = reportDetails else{
            return ReportErrorHandle(dataObject: report, error: nil)
        }
        
                for subView in houseStatusSelectionView.stackView.arrangedSubviews {
                    if let button = subView as? UIButton, button.isSelected == true {
                        let indexSelected = houseStatusData.houseStatus[button.tag]
                        self.report.inspectionReport.houseStatusId=String(indexSelected.id)
                    }
                }
        
        for subView in horizontalExpansionSelectionView.stackView.arrangedSubviews {
            if let button = subView as? UIButton, button.isSelected == true {
                let selectedValue = houseStatusData.expansions.filter({$0.expansionType == 0})[button.tag]//houseStatusData.expansions[button.tag]
                self.report.inspectionReport.expansionIdHor = String(selectedValue.expansionId)
            }
        }
        
        for subView in verticalExpansionSelectionView.stackView.arrangedSubviews {
            if let button = subView as? UIButton, button.isSelected == true {
                let selectedValue = houseStatusData.expansions.filter({$0.expansionType == 1})[button.tag]
                self.report.inspectionReport.expansionIdVart = String(selectedValue.expansionId)
            }
        }
        
        for subView in recommendationnSelectionView.stackView.arrangedSubviews{
            if let button = subView as? UIButton, button.isSelected == true {
                let sValue = reportDetails.facilityPayload.facilityActions[button.tag]
                //self.report.userFacility.facilityActionId=String(sValue.fActionId)
                self.report.inspectionReport.actionId = "\(sValue.fActionId)"
            }
        }
        self.report.inspectionReport.remarks  =  conclusionTextView.text
        self.report.inspectionReport.recommendation  = recommendationTextView.text
        self.report.inspectionReport.approximateConstructionSize = constructionSizeTextField.text ?? ""
        return ReportErrorHandle(dataObject: report, error: nil)
    }
    
  
    struct ReportErrorHandle
    {
        var dataObject:InspectionReportPayload?
        var error:String?
    }
    
    
}


extension BuildingExteriorDetailsView:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        let text = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        let Regex = "[0-9a-z A-Zء-ي ]+$"
        let predicate = NSPredicate.init(format: "SELF MATCHES %@", Regex)
        if predicate.evaluate(with: text) || string == ""
        {
            return true
        }
        else
        {
            return false
        }

    }
}
