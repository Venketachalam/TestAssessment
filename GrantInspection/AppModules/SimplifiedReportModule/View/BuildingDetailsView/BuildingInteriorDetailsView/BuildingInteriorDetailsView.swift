//
//  BuildingInteriorDetailsView.swift
//  GrantInspection
//
//  Created by Rajeswaran Thangaperumal on 29/08/2019.
//  Copyright © 2019 MBRHE. All rights reserved.
//

import UIKit

typealias simplifiedBuildingdata = (UserEnteredData:InspectionReportPayload,Error:String)

protocol PopReloadDelegate:class {
    func reloadAction(temp: String)
}
class BuildingInteriorDetailsView: UIView,UITextFieldDelegate {
    
    var delegatePopOver : PopReloadDelegate?

    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var serviceSelectionView: SelectionView!
    @IBOutlet weak var buildingHeaderStack: UIStackView!
    
    @IBOutlet weak var buildingStatusSelectionView: SelectionView!
    
    @IBOutlet weak var approximateCompletionSelection: SelectionView!
    
    @IBOutlet weak var buildingTypePicker: CustomImageButton!
    
    @IBOutlet weak var completeDatePicker: CustomImageButton!
    
    @IBOutlet weak var notesSelectionView: SelectionView!
    
    @IBOutlet weak var buildingNameTextField: UITextField!
    
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var buildingSizeTextField: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var saveAndCloseButton: MBRHERoundButtonView!
    @IBOutlet weak var addNewReportButton: UIButton!
    
    @IBOutlet weak var addSatellitePhotoButton: UIButton!
    
    @IBOutlet weak var addPhotoButton: UIButton!
    
    @IBOutlet weak var buildingElementView: BuildingElementView!
    
    @IBOutlet weak var noOfSatellitePhotosLabel: UILabel!
    
    @IBOutlet weak var noOfPhotosLabel: UILabel!
    
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var buildingNameTitleLbl: UILabel!
    @IBOutlet weak var approximateTitleLbl: UILabel!
    @IBOutlet weak var buildingTypeTitleLbl: UILabel!
    @IBOutlet weak var buildingElementsTitleLbl: UILabel!
    @IBOutlet weak var buildingStatusTitleLbl: UILabel!
    @IBOutlet weak var serviceTitleLbl: UILabel!
    @IBOutlet weak var buildingSizeTitleLbl: UILabel!
    @IBOutlet weak var notesTitleLbl: UILabel!
    @IBOutlet weak var addPhotosTitleLbl: UILabel!
    
    @IBOutlet weak var viewAttachedPhotosBtn: MBRHERoundButtonView!
    @IBOutlet weak var buildingTypeTextField: UITextField!
    
    @IBOutlet weak var buildingDetailsView: UIView!
    @IBOutlet weak var buildingElementsView: UIView!
    
    var facilityPickerValue = ""
    
    var isApproximateDateAvailable = false
    var facilityPayload: FacilityPayload!
    
    let report = InspectionReportPayload()
    
    var elementFacilities:[FacilityElementDetails]!
    
    var attachmentFacilities:[FacilityAttachments]!
    
    var numberOfPhotosInt:Int = 0
    
    var isDateSelected = false
    
    var isUnknowSelected = false
    
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
        
        buildingNameTextField.applyStyle()
        buildingSizeTextField.applyStyle()
    }
    
    private func setup() {
        
        Bundle.main.loadNibNamed("BuildingInteriorDetailsView", owner: self, options: nil)
        contentView.translatesAutoresizingMaskIntoConstraints = true
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        self.addSubview(self.contentView)
        addSelectionViewVaules()
        addPickerValues()
        setLayout()
        buildingNameTextField.placeholder = "building_name".ls
        buildingSizeTextField.placeholder = "building_Size_lbl".ls
        buildingNameTextField.delegate = self
        buildingSizeTextField.delegate = self
        
    }
    
    func setLayout(){
        
        if Common.currentLanguageArabic() {
            
            self.transform = Common.arabicTransform
            self.toArabicTransform()
            
            viewAttachedPhotosBtn.semanticContentAttribute = .forceRightToLeft
            viewAttachedPhotosBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
            
            saveButton.semanticContentAttribute = .forceRightToLeft
            saveButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 10)
           
            
            saveAndCloseButton.semanticContentAttribute = .forceRightToLeft
            saveAndCloseButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 10)
            
            addNewReportButton.semanticContentAttribute = .forceRightToLeft
            addNewReportButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
            addNewReportButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -10)
            
        }
        else
        {
           
            backButton.imageView?.transform = CGAffineTransform(rotationAngle: (180.0 * .pi) / 180.0)
            backButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -70, bottom: 0, right: 0)
            backButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)

            viewAttachedPhotosBtn.semanticContentAttribute = .forceLeftToRight
            viewAttachedPhotosBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
            
            saveButton.semanticContentAttribute = .forceLeftToRight
            saveButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
            
            saveAndCloseButton.semanticContentAttribute = .forceLeftToRight
            saveAndCloseButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
            
        }
        buildingNameTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
    }
    
    @objc func textFieldDidChange(textfield: UITextField) {
        
        if textfield.text?.count ?? 0 > 0
        {
            buildingNameTextField.layer.borderColor = UIColor.appBorderColor().cgColor
        }
    }
    
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
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.count ?? 0 > 0
        {
            Common.userDefaults.setBuildingName(name: textField.text ?? "")
        }
    }
        
    func getSelectedServiceID() -> Int {
        
        var seclectedOption = ""
        
        for sView in serviceSelectionView.stackView.subviews {
            if let button = sView as? UIButton,button.isSelected == true {
                seclectedOption = button.titleLabel?.text ?? ""
            }
        }
        
        if seclectedOption.count > 0 {
            let sValue = facilityPayload.facilityActions.filter({$0.actionName() == seclectedOption}).first
            return sValue?.fActionId ?? 0
        }
        
        return 0
    }
    
    func getSelectedBuildingType() -> Int {
        var seclectedOption = ""
        
        for sView in buildingStatusSelectionView.stackView.subviews {
            if let button = sView as? UIButton,button.isSelected == true {
                seclectedOption = button.titleLabel?.text ?? ""
            }
        }
        
        if seclectedOption.count > 0 {
            let sValue = facilityPayload.facilityConditions.filter({$0.conditionName() == seclectedOption}).first
            return sValue?.fConditionId ?? 0
        }
        
        return 0
    }
    
    func addSelectionViewVaules() {
        
        if Common.currentLanguageArabic()
        {
            self.buildingNameTextField.setRightPaddingPoints(10)
            self.buildingSizeTextField.setRightPaddingPoints(10)
        } else {
            self.buildingNameTextField.setLeftPaddingPoints(10)
            self.buildingSizeTextField.setLeftPaddingPoints(10)
        }
        
        var facilityConditions = ["bad".ls,"good".ls,"average".ls]
        var facilityActions = ["out_of_conditions".ls,"remove_and_replace".ls,"maintenance".ls,"good".ls]
        
        if let data = facilityPayload {
            facilityConditions = data.facilityConditions.map({$0.conditionName()})
            facilityActions = data.facilityActions.map({$0.actionName()})
            buildingElementView.setDataSource(elements: data.facilityElements, existingData:elementFacilities)
        }
        
        if Common.currentLanguageArabic()
        {
            serviceSelectionView.setSelectionData(titles: facilityConditions, selectedImage: #imageLiteral(resourceName: "radioRBx_S"), defaultImage: #imageLiteral(resourceName: "radio_normal_icon"), curentSelctionIndex: 0)
            approximateCompletionSelection.setSelectionData(titles: ["unknown_btn".ls], selectedImage: #imageLiteral(resourceName: "checkRBox_S"), defaultImage: #imageLiteral(resourceName: "checkBox"), curentSelctionIndex: 0)
            
        }
        else
        {
            serviceSelectionView.setSelectionData(titles: facilityConditions, selectedImage: #imageLiteral(resourceName: "radio_selected_icon"), defaultImage: #imageLiteral(resourceName: "radio_normal_icon"), curentSelctionIndex: 0)
            approximateCompletionSelection.setSelectionData(titles: ["unknown_btn".ls], selectedImage: #imageLiteral(resourceName: "checkBox_S"), defaultImage: #imageLiteral(resourceName: "checkBox"), curentSelctionIndex: 0)
        }
        
        
        if let button = approximateCompletionSelection.stackView.arrangedSubviews.first as? UIButton {
            button.addTarget(self, action: #selector(buildDateEstimationbtnClick), for: .touchUpInside)
        }
        
        if Common.currentLanguageArabic()
        {
            buildingStatusSelectionView.setSelectionData(titles: facilityConditions, selectedImage: #imageLiteral(resourceName: "radioRBx_S"), defaultImage: #imageLiteral(resourceName: "radio_normal_icon"), curentSelctionIndex: 0)
        }
        else
        {
            buildingStatusSelectionView.setSelectionData(titles: facilityConditions, selectedImage: #imageLiteral(resourceName: "radio_selected_icon"), defaultImage: #imageLiteral(resourceName: "radio_normal_icon"), curentSelctionIndex: 0)
        }
        
        
        notesSelectionView.setSelectionData(titles: facilityActions, curentSelctionIndex: 0)
        
        noOfSatellitePhotosLabel.attributedText = "number_of_Satelite_Photos".ls.getAttributeString(color: .darkGray).joinedString(string: "0 ".getUnderLineAttributeString(color: .red))
        buildingNameTitleLbl.text = "building_name".ls
        approximateTitleLbl.text = "completion_date_lbl".ls
        buildingTypeTitleLbl.text = "building_type_lbl".ls
        buildingElementsTitleLbl.text = "building_elements".ls
        buildingStatusTitleLbl.text = "building_status_lbl".ls
        serviceTitleLbl.text = "service_lbl".ls
        buildingSizeTitleLbl.text = "building_Size_lbl".ls
        notesTitleLbl.text = "notes".ls
        addPhotosTitleLbl.text = "addPhoto_lbl".ls
        backButton.setTitle("back_btn".ls, for: .normal)
        nextButton.setTitle("next_btn".ls, for: .normal)
        saveButton.setTitle("save_btn".ls, for: .normal)
        saveAndCloseButton.setTitle("save_and_close_btn".ls, for: .normal)
        addPhotoButton.setTitle("addaPhoto_lbl".ls, for: .normal)
        addNewReportButton.setTitle("add_New_Building_Btn".ls, for: .normal)
        noOfPhotosLabel.text = "number_of_Photos".ls
        addSatellitePhotoButton.setTitle("addSatellitePhoto_lbl".ls, for: .normal)
        viewAttachedPhotosBtn.setTitle("view_attached_photos".ls, for: .normal)
        
    }
    
    @objc func buildDateEstimationbtnClick(sender:UIButton)
    {
        if(sender.isSelected)
        {
            self.completeDatePicker.valueLabel.text = " "
            completeDatePicker.isUserInteractionEnabled = false
            completeDatePicker.alpha = 0.5
            
        }
        else
        {
            completeDatePicker.isUserInteractionEnabled = true
            completeDatePicker.alpha = 1.0
            
            if self.report.userFacility.approximateCompletionDate.count == 0
            {
                var approximateDate = Date()
                let dateFormatter=DateFormatter()
                
                dateFormatter.locale = Locale(identifier: "en_US")
                dateFormatter.dateFormat = "dd-MMM-yyyy"
                print ("err THe current date:\(self.report.userFacility.approximateCompletionDate)")
                
                approximateDate = dateFormatter.date(from: self.report.userFacility.approximateCompletionDate) ?? Date()
                print ("23323 Approximate Date is:\(approximateDate)")
                self.completeDatePicker.valueLabel.text = approximateDate.getExpectedFormat()
                
            }
            else{
                self.completeDatePicker.valueLabel.text = self.report.userFacility.approximateCompletionDate
            }
            
            //print("Facility Type id ississisis:",self.report.userFacility.facilityId)
        }
    }
    
    
    func changeTheNumberOfPhotosLabel(numberOfPhotos:Int)  {
        let numberofPhotosString = String(numberOfPhotos)
        
        noOfPhotosLabel.attributedText = "".getAttributeString(color: .darkGray).joinedString(string:"".getUnderLineAttributeString(color: .red))
        
        noOfPhotosLabel.attributedText = "number_of_Photos".ls.getAttributeString(color: .darkGray).joinedString(string:numberofPhotosString.getUnderLineAttributeString(color: .red))
    }
    
    func resettingPerviousValue()  {
        
        //print ("Resetting previous Value Called")
        self.buildingNameTextField.text = ""
        self.buildingSizeTextField.text = ""
        guard let facilityData = facilityPayload else { return  }
        self.buildingTypePicker.valueLabel.text = facilityData.facilityTypes.first?.facilityTypeName() ?? ""
        
        let Value = Date().getExpectedFormat()
        let selectedDate = Value.selectedStringToDateFormat(date: Value)
        
        self.completeDatePicker.valueLabel.text = selectedDate
        //print("Changed date is:.....",self.completeDatePicker.valueLabel.text!)
        var facilityConditions = ["bad".ls,"good".ls,"average".ls]
        var facilityActions = ["out_of_conditions".ls,"remove_and_replace".ls,"maintenance".ls,"good".ls]
        
        facilityConditions = facilityData.facilityConditions.map({$0.conditionName()})
        facilityActions = facilityData.facilityActions.map({$0.actionName()})
      
        var tempObj = [FacilityElementDetails]()
        for value in elementFacilities ?? [FacilityElementDetails]() {
            value.facilityElementCount = "0"
            tempObj.append(value)
        }
       // print("Current Facility Elements:",facilityData.facilityElements)
         var combineValue = [ElementDataSet]()
        for facilityAccess in facilityData.facilityElements
        {
            let currentFacilityName : String?
            if (Common.currentLanguageArabic()){
                currentFacilityName = facilityAccess.fElementName
            }
            else{
                currentFacilityName = facilityAccess.fElementNameEn
            }
            
            buildingElementView.structClassFor.elementID = facilityAccess.fElementId
            buildingElementView.structClassFor.elementName = currentFacilityName
            buildingElementView.structClassFor.elementCount = 0
            buildingElementView.structClassFor.elementCountID = 0
            
            combineValue.append(buildingElementView.structClassFor)
        }
        
        buildingElementView.elementSetDataSource = combineValue
     
        buildingElementView.collectionView .reloadData()
        
        if isUnknowSelected == true {
            guard let unknownButton = approximateCompletionSelection.stackView.arrangedSubviews.first as? UIButton else
            {
                return
            }
            unknownButton.isSelected = true
            completeDatePicker.isUserInteractionEnabled = false
            completeDatePicker.alpha = 0.5
            self.completeDatePicker.valueLabel.text = ""
        }
        

        
    }
    
    func setUnKnownSelected(isSelected:Bool)  {
        isUnknowSelected = isSelected
    }
    
    
    func setInterierBuildingViewData(data:UserFacility) {
        
        
        report.userFacility = data
        self.buildingNameTextField.text = data.buidingName()
        guard let facilityData = facilityPayload else { return  }
        
        print("Interior Type id ississisis:",self.report.userFacility.facilityId)
        
        
        if data.facilityTypeId.count > 0 {
            let buildingType = facilityData.facilityTypes.filter({$0.fTypeId == Int(data.facilityTypeId)}).first
            
            self.buildingTypePicker.valueLabel.text = buildingType?.facilityTypeName() ?? ""
            self.report.userFacility.facilityTypeId = "\(data.facilityTypeId)"
        }
        

        if (!self.report.userFacility.facilityId.isEmptyString() && !(isApproximateDateAvailable)) {
            
            if self.report.userFacility.facilityId.count > 0 && self.report.userFacility.approximateCompletionDate.count == 0
            {
                guard let unknownButton = approximateCompletionSelection.stackView.arrangedSubviews.first as? UIButton else
                {
                    return
                }
                unknownButton.isSelected = true
                completeDatePicker.isUserInteractionEnabled = false
                completeDatePicker.alpha = 0.5
                self.completeDatePicker.valueLabel.text = data.approximateCompletionDate.serverDateFormatToMedium()

            }
            else
            {
                completeDatePicker.isUserInteractionEnabled = true
                           completeDatePicker.alpha = 1.0
                           self.completeDatePicker.valueLabel.text = data.approximateCompletionDate.serverDateFormatToMedium()
                
            }
        }
        else
        {
            if let button = approximateCompletionSelection.stackView.arrangedSubviews.first as? UIButton {
                button.isSelected = true
                completeDatePicker.isUserInteractionEnabled = false
                completeDatePicker.alpha = 0.5
            }
            
        }
        self.buildingSizeTextField.text = data.buildingSizeSQF
        
        let sID = Int(data.serviceStatusId) ?? 0
        if data.serviceStatusId.count > 0  &&  sID > 0 && facilityData.facilityConditions.count > 0{
            
            let serviceValue = facilityData.facilityConditions.filter({$0.fConditionId == sID}).first!
            
            let selectedObject = facilityData.facilityConditions.index(where: { $0.conditionName() == serviceValue.conditionName() })
            for subView in self.serviceSelectionView.stackView.arrangedSubviews {
                if let button = subView as? UIButton {
                    if button.tag == selectedObject {
                        button.isSelected = true
                    } else {
                        button.isSelected = false
                    }
                    
                }
            }
        }
        
        let buildingStatusID = Int(data.buildingStatusId) ?? 0
        if data.buildingStatusId.count > 0 && buildingStatusID > 0{
            let buildingValue = facilityData.facilityConditions.filter({$0.fConditionId == buildingStatusID}).first!
            let buildingConditionObject = facilityData.facilityConditions.index(where: { $0.conditionName() == buildingValue.conditionName() })
            for subView in self.buildingStatusSelectionView.stackView.arrangedSubviews {
                if let button = subView as? UIButton {
                    if button.tag == buildingConditionObject {
                        button.isSelected = true
                    }
                    else
                    {
                        button.isSelected = false
                    }
                }
            }
        }
        
        let fActionID = Int(data.facilityActionId) ?? 0
        if data.facilityActionId.count > 0 && fActionID > 0 {
            let noteValue = facilityData.facilityActions.filter({$0.fActionId == fActionID}).first!
            let buildingConditionObject = facilityData.facilityActions.index(where: { $0.actionName() == noteValue.actionName() })
            for subView in self.notesSelectionView.stackView.arrangedSubviews {
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
    
    func addPickerValues() {
        var facilityTypes = ["Ceiling-bearing","Ceiling-bearing1","Ceiling-bearing2","Ceiling-bearing3"]
        
        if let data = facilityPayload
        {
            if Common.currentLanguageArabic()
            {
                facilityTypes = data.facilityTypes.map({$0.fTypeName})
            }else
            {
                facilityTypes = data.facilityTypes.map({$0.fTypeNameEn})
            }
            
        }
        
        
        buildingTypePicker.setButtonValue(rightImage: #imageLiteral(resourceName: "building_type_icon"), leftImage: #imageLiteral(resourceName: "gray_arrow_down"), value: facilityTypes.first ?? "", isDatePicker: false) { (isDate) in
            if !isDate {
                let alert = UIAlertController(style: .alert, title: "choose_building_btn".ls)
                let pickerValues = [facilityTypes]
                alert.addPickerView(values: pickerValues, action: { (_, _, index, data) in
                    
                    self.buildingTypePicker.valueLabel.text = pickerValues[index.column][index.row]
                    
                    guard let buildingTypeObj = self.facilityPayload else {
                        let selectedObj = facilityTypes[index.row]
                       // self.report.userFacility.facilityTypeId = String(index.row)
                        print("selcted type \(selectedObj)")
                        return
                    }
                    let selectedObj = buildingTypeObj.facilityTypes[index.row]
                    //self.report.userFacility.facilityTypeId = String(selectedObj.fTypeId)
                    print("Data is:\(selectedObj.fTypeId)")
                })
                
                alert.addAction(title: "ok_btn".ls, style: .cancel)
                alert.show()
            }
        }
        datePickerDataLoad()
    }
    
    func datePickerDataLoad(){
        var approximateDate = Date()
        
        if self.report.userFacility.approximateCompletionDate.count == 0 {
            guard let unknownButton = approximateCompletionSelection.stackView.arrangedSubviews.first as? UIButton else
            {
                return
            }
            let Value = Date().getExpectedFormat()
            let selectedDate = Value.selectedStringToDateFormat(date: Value)
            
            print ("Facility Id available is:......",report.userFacility.facilityId)
            
            if report.userFacility.facilityId.count == 0 {
                unknownButton.isSelected = false
                completeDatePicker.valueLabel.text = selectedDate
                self.report.userFacility.approximateCompletionDate = selectedDate
            }
            else
            {
                
            }
            
        }
        
        let dateFormatter=DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "dd-MMM-yyyy"
        print ("THe current date:\(self.report.userFacility.approximateCompletionDate)")
        approximateDate = dateFormatter.date(from: self.report.userFacility.approximateCompletionDate) ?? Date()
        print ("Approximate Date is:\(approximateDate)")
        
        var approxi = String()
        
        if self.report.userFacility.approximateCompletionDate.count == 0
        {
            approxi = ""
            completeDatePicker.alpha = 1.0
        }
        else
        {
            var approximateDate = Date()
            let dateFormatter=DateFormatter()
            
            dateFormatter.locale = Locale(identifier: "en_US")
            dateFormatter.dateFormat = "dd-MMM-yyyy"
            
            approximateDate = dateFormatter.date(from: self.report.userFacility.approximateCompletionDate) ?? Date()
            approxi = approximateDate.getExpectedFormat()
        }
        
        completeDatePicker.setButtonValue(rightImage: #imageLiteral(resourceName: "calender_icon"), leftImage: #imageLiteral(resourceName: "gray_arrow_down"), value: approxi, isDatePicker: true) { (isDate) in
            if isDate {
                let alert = UIAlertController(style: .alert, title: "select_Approximate_Complete_Date".ls)
                
                alert.addDatePicker(mode: .date, date: approximateDate, minimumDate: nil, maximumDate: nil) { date in
                    
                    self.completeDatePicker.valueLabel.text = date.getExpectedFormat()
                    
                    let Value=date.getExpectedFormat()
                    let selectedDate=Value.selectedStringToDateFormat(date: Value)
                    self.report.userFacility.approximateCompletionDate=selectedDate
                    approximateDate = date
                }
                alert.addAction(title: "ok_btn".ls, style: .cancel)
                alert.show()
            }
        }
    }
    
    
    @IBAction func nextButtonAction(sender: UIButton) {
        
    }
    
    
    func postbuildingdetailsEntered() -> ReportErrorHandle {
        
        let buildName = buildingNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? " "
        
        if buildName.count == 0{
            self.buildingNameTextField.layer.borderColor = UIColor.red.cgColor
            return ReportErrorHandle(dataObject: nil, error: "building_name_not_Available".ls)
        }
        if (Common.currentLanguageArabic()){
            report.userFacility.buildingNameArabic = buildName
            report.userFacility.buildingNameEnglish = buildName
        }else{
            report.userFacility.buildingNameEnglish = buildName
            report.userFacility.buildingNameArabic = buildName
        }
        
        if(!completeDatePicker.isUserInteractionEnabled)
        {
            self.report.userFacility.approximateCompletionDate = ""
        }
        else
        {
            let value = "".selectedStringToDateFormat(date:self.completeDatePicker.valueLabel.text ?? "")
            if value == ""
            {
//                if isDateSelected == false {
//                     self.report.userFacility.approximateCompletionDate  = ""
//                }else
//                {
                    self.report.userFacility.approximateCompletionDate  = self.completeDatePicker.valueLabel.text ?? ""
//                }
                
            }
            else
            {
                self.report.userFacility.approximateCompletionDate = value
            }
        }
        print("Date of completion:", self.report.userFacility.approximateCompletionDate)
        guard let facilitiesData = facilityPayload else {
            return ReportErrorHandle(dataObject: report, error: nil)
        }
        
        
        
        let buildingValue  = self.buildingTypePicker.valueLabel.text ?? ""
        let buildingType = facilitiesData.facilityTypes.filter({$0.facilityTypeName() == buildingValue}).first
        self.report.userFacility.facilityTypeId = "\(buildingType?.fTypeId ?? 0)"
        
        for subView in approximateCompletionSelection.stackView.arrangedSubviews {
            if let button = subView as? UIButton, button.isSelected == true {
                self.report.userFacility.approximateCompletionDate = ""
            }
        }
        for subView in serviceSelectionView.stackView.arrangedSubviews {
            if let button = subView as? UIButton, button.isSelected == true {
                let sValue = facilitiesData.facilityConditions[button.tag]
                self.report.userFacility.serviceStatusId=String(sValue.fConditionId)
                break
            }else if let button = subView as? UIButton, button.isSelected == false
            {
                self.report.userFacility.serviceStatusId = ""
            }
        }
        for subView in buildingStatusSelectionView.stackView.arrangedSubviews {
            if let button = subView as? UIButton, button.isSelected == true {
                let sValue = facilitiesData.facilityConditions[button.tag]
                self.report.userFacility.buildingStatusId=String(sValue.fConditionId)
                break
            }
            else if let button = subView as? UIButton, button.isSelected == false
            {
                self.report.userFacility.buildingStatusId = ""
            }
        }
        
        let buildingSize = buildingSizeTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? " "
        self.report.userFacility.buildingSizeSQF=buildingSize
        
        for subViewsAvailable in notesSelectionView.stackView.arrangedSubviews{
            if let button = subViewsAvailable as? UIButton, button.isSelected == true {
                let sValue = facilitiesData.facilityActions[button.tag]
                self.report.userFacility.facilityActionId=String(sValue.fActionId)
                break
            }else if let button = subViewsAvailable as? UIButton, button.isSelected == false
            {
                 self.report.userFacility.facilityActionId = ""
            }
        }
        
        let fID = report.userFacility.facilityId
        
        
        if buildingElementView.getSelectedElements(facilityID: fID).count > 0 {
            report.userFacility.facilityElementsList = buildingElementView.getSelectedElements(facilityID: fID)
        } else {
            report.userFacility.facilityElementsList = [FacilityElementDetails]()
        }
        return ReportErrorHandle(dataObject: report, error: "building_name_not_Available".ls)
        
    }
    
}


struct ReportErrorHandle {
    var dataObject: InspectionReportPayload?
    var error: String?
}




extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
