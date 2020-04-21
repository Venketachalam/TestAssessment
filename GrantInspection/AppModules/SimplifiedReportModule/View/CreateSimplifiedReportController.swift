//
//  CreateSimplifiedReportController.swift
//  GrantInspection
//
//  Created by Rajeswaran Thangaperumal on 28/08/2019.
//  Copyright © 2019 MBRHE. All rights reserved.
//

import UIKit
import RxSwift

enum ReportStatus {
    case createNew    // 1. If have no faclity or Click the Add New button
    case list         // 2. List out all building details
    case edit         // 3. Click the edit Button Expand the Building details
    case view         // 4. View the Building Details with elements image
    case final        // 5. Report last form view
    case completed    // 6. Show the Simplified report with Edit and view button
    case none
    case editFromReport
    case saveFromReport
    //  case saveandCloseReport
}

protocol ReportDataDelegate : class {
   // func didSelectTag(tags: [FacilityAttachments],reportFacility:[UserFacility])
    
     func shareReportDataInfo  (summary:RequestSummary,report:InspectionReportRespose,faclities:[UserFacility],defaultFaclities:FacilityResponsePayload)
    
}



class CreateSimplifiedReportController: UIViewController,UIScrollViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var buildingInfoDelegate: ReportDataDelegate!

    
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var backButton: UIButton!
    
    var requestDetails: RequestSummary!
    
    var viewModel: SimplifiedReportViewModule!
    
    private let disposeBag = DisposeBag()
    
    private var facilitiesData: FacilityResponsePayload!
    
    var reportDetails: InspectionReportRespose!
    var reportFacilities: [UserFacility]!
    var attachmentFacilitiesList:[FacilityAttachments]!
    
    let imagePicker = UIImagePickerController()
    
    var facilityDeleteModuleRequestToAPI:FacilityDeleteModule!
    
    var currentStatus : ReportStatus = .none {
        didSet {
            self.reloadtableView(state: currentStatus)
        }
    }
    
    var requestObject: Dashboard!
    var cellCount = 0
    var currentCellTag = 0
    var isFromDashBorad = false
    var isFromPhotoUpdate = false
    var deletedPopupView = DeletePopupView()
    var isEditOpen: Bool = false
    
    var isFromStartMyTrip = Bool()
    var isSaveOnly:Bool = false
    var isSaveAndClose:Bool = false
    
    
    var isResetNeeded:Bool = false
    var isDisable:Bool = false
    var confirmPopupView = ConfirmationPopUpView()
    var savedCell = BuildingDetailsCell()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewSetup()
        
        setupApiCall()
        imagePicker.delegate = self
        
        setLayout()
        self.changeCreateButtonState(isHidden: true)
        
        nextButton.setTitle("next_btn".ls, for: .normal)
        backButton.setTitle("back_btn".ls, for: .normal)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.tableHeaderView?.frame.size.height = self.tableView.frame.size.width * 0.3
    }
    
    deinit {
        print ("Controller deintialised")
    }
    override func viewWillAppear(_ animated: Bool) {
        isDisable = false
        super.viewWillAppear(animated)
    }
    func setupApiCall()  {
        viewModel = SimplifiedReportViewModule(ReportService())
        viewModelConfiguration(viewModel: viewModel)
        facilityDeleteModuleRequestToAPI = FacilityDeleteModule(FacilityDeleteService())
        addinspectionApiObservers()
        addGetFacilityObserverse()
    }
    
    func refreshedAPICallFromImagesUpload(currentTag:Int)  {
        // viewModel = SimplifiedReportViewModule(ReportService())
        setupApiCall()
        if let vM = viewModel {
            if let report = reportDetails{
                self.currentCellTag = currentTag
                getReportFaciliesData(viewModel: vM, reportId: report.inspectionReportId)
                isFromPhotoUpdate = true
            }
        }
    }
    
    func setLayout(){
        
        if Common.currentLanguageArabic()
        {
            if isFromStartMyTrip == false {
                self.view.transform = Common.arabicTransform
                self.view.toArabicTransform()
                self.bottomView.transform = Common.arabicTransform
                
                
                
                backButton.semanticContentAttribute = .forceRightToLeft
                
                
            }
            
        }
        else{
            backButton.imageView?.transform = CGAffineTransform(rotationAngle: (180.0 * .pi) / 180.0)
            backButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -70, bottom: 0, right: 0)
            backButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        }
    }
    
    private func tableViewSetup() {
        
        let requestHeader = SimplifiedRequestHeaderView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 0))
        requestHeader.addNewBuildingButton.addTarget(self, action: #selector(createNewReportAction(sender:)), for: .touchUpInside)
        requestHeader.backButton.addTarget(self, action: #selector(backButtonAction(sender:)), for: .touchUpInside)
        requestHeader.toPrint.isHidden = true
        requestHeader.addSatellitePhotoButton.addTarget(self, action: #selector(satelliteButtonAction(sender:)), for: .touchUpInside)
        tableView.tableHeaderView = requestHeader
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        if let _ = reportDetails {
            requestHeader.houseStatusLabel.text = "reporthousestatus_lbl".ls
            requestHeader.backButton.tag = 11
            isFromDashBorad = true
        } else {
            requestHeader.houseStatusLabel.text = "create_ reporthousestatus_lbl".ls
        }
        
        tableView.dataSource = self
        tableView.register(UINib(nibName: "\(BuildingDetailsCell.self)", bundle: Bundle.main), forCellReuseIdentifier: BuildingDetailsCell.Identifier)
        setRequestDetailsOnView(requestView: requestHeader)
        
    }
    
    func setRequestDetailsOnView(requestView:SimplifiedRequestHeaderView) {
        if let  details  = requestDetails {
            let infoView = RequestInfo(applicationNo: details.applicationNo, applicantID: details.applicationNo, customerName: details.customerName, lanNo: requestDetails.landNo, duraton: details.duration, areaName: details.serviceRegion, plotArea: details.servicePlotArea)
            requestView.requestSummaryView.setRequestDetails(details: infoView)
        }
    }
    
    
    func reloadtableView(state:ReportStatus) {
        switch state {
        case .list,.createNew :
            DispatchQueue.main.async {
                
                self.changeCreateButtonState(isHidden: false)
                self.changeStelliteImageStatus(isHidden: true)
                self.tableViewMoveTo(top: 0)
                self.changeBottomViewVisibleState(visible: true)
            }
        case .final,.completed,.edit :
            
            DispatchQueue.main.async {
                
                self.changeStelliteImageStatus(isHidden: true)
                if state == .final {
                    self.changeStelliteImageStatus(isHidden: false)
                }
                
                if state != .edit {
                    self.tableViewMoveTo(top: 0)
                    
                    self.changeCreateButtonState(isHidden: true)
                    self.changeBottomViewVisibleState(visible: false)
                } else {
                    self.changeBottomViewVisibleState(visible: true)
                }
                
            }
            
        case .editFromReport :
            DispatchQueue.main.async {
                if self.tableView == nil
                {
                    print("tableview not set")
                }else
                {
                    self.tableViewMoveTo(top: 0)
                    self.changeBottomViewVisibleState(visible: true)
                }
                
                
            }
            
        default:
            break
        }
        
    }
    
    
    //MARK:- ViewModel Configuration
    func viewModelConfiguration(viewModel:SimplifiedReportViewModule) {
        
        Common.showActivityIndicator()
        
        
        viewModel.output.facilityResultObservable
            .subscribe(onNext: { [unowned self](response) in
                Common.hideActivityIndicator()
                if self.validateFacilityData(data: response.payload) {
                    self.facilitiesData = response.payload
                    if let report = self.reportDetails {
                        self.getReportFaciliesData(viewModel: viewModel, reportId: report.inspectionReportId)
                    }else {
                        self.getReportDetails(vM: viewModel)
                    }
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
                
                
            }) .disposed(by: disposeBag)
        
        viewModel.output.errorsObservable
            .subscribe(onNext: {  (error) in
                
                Common.hideActivityIndicator()
                let errorMessage = (error as NSError).domain
                if !errorMessage.isEmpty{
                    
                    Common.showToaster(message: errorMessage)
                }else {
                    
                    Common.showToaster(message: "bad_Gateway".ls)
                }
                
                
            })
            .disposed(by: disposeBag)
        
        
    }
    
    
    
    private func validateFacilityData(data: FacilityResponsePayload) -> Bool {
        if data.facilityPayload.facilityActions.count == 0 {
            return false
        }
        if data.facilityPayload.facilityTypes.count == 0 {
            return false
        }
        if data.facilityPayload.facilityElements.count == 0 {
            return false
        }
        if data.facilityPayload.facilityConditions.count == 0 {
            return false
        }
        if data.expansions.count == 0 {
            return false
        }
        if data.houseStatus.count == 0 {
            return false
        }
        return true
    }
    
    //MARK:- Get Reoprt details from Api
    func getReportDetails(vM:SimplifiedReportViewModule) {
        
        guard let inputDetails = requestObject else { return  }
        Common.showActivityIndicator()
        vM.input.getReportRequest.onNext(inputDetails)
        vM.output.getReportResultObservable.subscribe { [weak self](response) in
            Common.hideActivityIndicator()
            
            if let value = response.element,value.success == true {
                if value.payload.inspectionReportId.count > 0 {
                    self?.reportDetails = value.payload
                    self?.getReportFaciliesData(viewModel: vM, reportId: value.payload.inspectionReportId)
                }else {
                    self?.changeCreateButtonState(isHidden: false)
                }
            }
        }.disposed(by: disposeBag)
        
    }
    
    private func addGetFacilityObserverse() {
        guard let _ = viewModel else { return  }
        viewModel.output.reportFacilitiesResultObservable.subscribe { [weak self](response) in
            Common.hideActivityIndicator()
            switch response {
            case .next:
                if let value = response.element,value.success == true {
                    
                    self?.reportFacilities = value.payload.userFacility
                    
                    self?.reportFacilities = self?.reportFacilities.sorted(by: { $0.facilityId < $1.facilityId })  // Tableview data Ascen/decend order
                    print(self?.reportFacilities as Any)
                    
                    //     print("self?.reportFacilities    ", self?.reportFacilities.count)
                    //   print("Final Current Status:    ", self?.currentStatus)
                    
                    if self?.currentStatus == ReportStatus.none  {
                        self?.currentStatus = .completed
                    } else if self?.currentStatus == .edit || self?.currentStatus == .createNew {
                        if (self!.isSaveOnly){
                            //     self?.currentStatus = .edit
                            
                            // let indexPath = IndexPath(item: self!.currentCellTag, section: 0)
                            //  self?.tableView.reloadRows(at: [indexPath], with: .none)
                            
                            //                                            self?.attachmentFacilitiesList = self?.reportFacilities[self!.currentCellTag].facilityAttachmentsList
                            //                                           if let cell = self?.tableView.cellForRow(at: IndexPath(row: self!.currentCellTag, section: 0)) as? BuildingDetailsCell{
                            //                                            self?.addActionObservers(cell: cell)
                            //                                            }
                            
                            let btn = UIButton()
                            
                            let lastrowIndex = self?.tableView.numberOfRows(inSection: 0)
                            if self?.isEditOpen == true{

                                // btn.tag = self?.currentCellTag ?? 0
                                if ((lastrowIndex ?? 0) - 1 ) > self?.currentCellTag ?? 0
                                {
                                    btn.tag = lastrowIndex ?? 0
                                }
                                else{
                                    btn.tag = self?.currentCellTag ?? 0
                                }
                            }else
                            {
                                if ((lastrowIndex ?? 0) - 1 ) > self?.currentCellTag ?? 0
                                {
                                    btn.tag = 0
                                }
                                else{
                                    btn.tag = self?.currentCellTag ?? 0
                                }
                            }
                            
                           // btn.tag = self?.currentCellTag ?? 0
                            self?.editAction(sender: btn)
                            
                        }
                        else if (self!.isSaveAndClose){
                            self!.isSaveAndClose = false
                            self?.currentStatus = .list
                        }
                        else if (self!.isResetNeeded){
                            self?.changeCreateButtonState(isHidden: true)
                            self!.isResetNeeded = false
                            self?.currentStatus = .createNew
                            let lastRowIndex = self?.tableView.numberOfRows(inSection: self!.tableView.numberOfSections-1)
                            if(lastRowIndex != 0)
                            {
                                self?.editscrollAtIndex(index: lastRowIndex!-1)
                            }
                            else
                            {
                                
                            }
                        }
                        else
                        {
                            if self?.isFromPhotoUpdate ?? false {
                                self?.isFromPhotoUpdate = false
                                let btn = UIButton()
                                btn.tag = self?.currentCellTag ?? 0
                                self?.editAction(sender: btn)
                            }else {
                                self?.currentStatus = .list
                            }
                        }
                    }
                    else if self?.currentStatus == .list {
                        //Venkat
                        //  self?.currentStatus = .editFromReport
                        if (self!.isSaveOnly){
                            self?.currentStatus = .edit
                        }else if (self!.isResetNeeded){
                            //  self!.isResetNeeded = false
                            self?.changeCreateButtonState(isHidden: true)
                            self!.isResetNeeded = false
                            self?.currentStatus = .createNew
                            let lastRowIndex = self?.tableView.numberOfRows(inSection: self!.tableView.numberOfSections-1)
                            if(lastRowIndex != 0)
                            {
                                self?.editscrollAtIndex(index: lastRowIndex!-1)
                            }
                            else
                            {
                                
                            }
                        }
                        else{
                            self?.currentStatus = .list
                        }
                        
                    }else if self?.currentStatus == .editFromReport{
                        self?.currentStatus = .editFromReport
                    }else if self?.currentStatus == .saveFromReport{
                        self?.currentStatus = .list
                        // self?.currentStatus = .editFromReport
                    }
                    else if self?.currentStatus != .completed{
                        self?.currentStatus = .completed
                    }
                }else {
                    
                }
            case .error,.completed:
                break
            }
            
        }.disposed(by: disposeBag)
    }
    //MARK:- Get Report Facilities List
    func getReportFaciliesData(viewModel:SimplifiedReportViewModule,reportId:String) {
        
        Common.showActivityIndicator()
        viewModel.input.reportID.onNext(reportId)
        
    }
    
    
    func apiCallForCreateNewReport(requestDetails:Dashboard,userFacility:UserFacility) {
        let requestParam = InspectionInputReportRequestPayload()
        requestParam.payload.inspectionReport.applicationNumber = "\(requestDetails.applicationNo)"
        requestParam.payload.inspectionReport.applicantId = "\(requestDetails.applicantId)"
        requestParam.payload.inspectionReport.serviceTypeId = requestDetails.serviceTypeId
        requestParam.payload.inspectionReport.plotNumber = requestDetails.plot.landNo
        requestParam.payload.inspectionReport.lattitude = requestDetails.plot.latitude
        requestParam.payload.inspectionReport.longitude = requestDetails.plot.longitude
        requestParam.payload.inspectionReport.createdDate = Date().getToServerFormat()
        
        requestParam.payload.userFacility = userFacility
        makeInspctionReportPostApi(report: requestParam)
    }
    
    
    func setReportObject(inspection: InspectionReportRequestPayload) {
        if let _ = reportDetails {
            
        } else {
            reportDetails = InspectionReportRespose()
            reportDetails.inspectionReportId = inspection.payload.inspectionReport.inspectionReportId
            reportDetails.applicationNumber = inspection.payload.inspectionReport.applicationNumber
            reportDetails.applicantId = inspection.payload.inspectionReport.applicantId
            reportDetails.serviceTypeId = inspection.payload.inspectionReport.serviceTypeId
            self.currentStatus = .edit
            self.saveAction(sender: UIButton())
        }
        
        
    }
    
    private func addinspectionApiObservers() {
        viewModel.output.reportPostResponseObservable.subscribe { [weak self](response) in
            Common.hideActivityIndicator()
            print ("Observer Change")
            switch response {
            case .next:
                if let value = response.element,value.success == true {
                    
                    //print("post report response :\(response.element)")
                    self?.setReportObject(inspection: value)
                    if let VM = self?.viewModel {
                        if self?.currentStatus == .final {
                            self?.currentStatus = .completed
                            self?.getReportDetails(vM: VM)
                            
                        }
                        else {
                            
                            self?.getReportFaciliesData(viewModel: VM , reportId: value.payload.inspectionReport.inspectionReportId)
                            
                        }
                    }
                    
                }
            case .error,.completed:
                break
            }
            
        }.disposed(by: disposeBag)
    }
    
    //MARK:- Update/Create post inspection report
    func makeInspctionReportPostApi(report:InspectionInputReportRequestPayload) {
        
        Common.showActivityIndicator()
        viewModel.input.postReportRequest.onNext(report)
        
    }
    
    func updateReportData(requestDetails:Dashboard,updatedData:InspectionReportPayload) {
        let requestParam = InspectionInputReportRequestPayload()
        
        
        requestParam.payload.inspectionReport = updatedData.inspectionReport
        requestParam.payload.userFacility = updatedData.userFacility
        requestParam.payload.inspectionReport.inspectionReportId = reportDetails.inspectionReportId
        requestParam.payload.userFacility.facilityId = updatedData.userFacility.facilityId
        requestParam.payload.userFacility.inspectionReportId = reportDetails.inspectionReportId
        requestParam.payload.inspectionReport.applicationNumber = "\(requestDetails.applicationNo)"
        requestParam.payload.inspectionReport.applicantId = "\(requestDetails.applicantId)"
        requestParam.payload.inspectionReport.serviceTypeId = requestDetails.serviceTypeId
        requestParam.payload.inspectionReport.plotNumber = requestDetails.plot.landNo
        requestParam.payload.inspectionReport.lattitude = requestDetails.plot.latitude
        requestParam.payload.inspectionReport.longitude = requestDetails.plot.longitude
        requestParam.payload.inspectionReport.updatedDate = Date().getToServerFormat()
        if updatedData.inspectionReport.createdDate.count > 0 {
            requestParam.payload.inspectionReport.createdDate = "".selectedStringToDateFormat(date: updatedData.inspectionReport.createdDate.serverDateFormatToNormal())//
        }
        makeInspctionReportPostApi(report: requestParam)
        
    }
    
    //MARK:- Button Actions
    @IBAction func createNewReportAction(sender: UIButton) {
        
        
        guard let _ = facilitiesData else { return  }
        print("Current Status:",currentStatus)
        print("Inter")
        
        let totalRows = tableView.numberOfRows(inSection: tableView.numberOfSections-1)
        print ("Total Rows:",totalRows)
        
        if (totalRows>0) && (currentStatus != .list){
            
            //            if let _ = reportDetails {
            //                if sender.isSelected {
            //                    // // print ("First Entry")
            //                    isResetNeeded = true
            //                    changeCreateButtonState(isHidden: true)
            //                    currentStatus = .createNew
            //                    let lastRowIndex = tableView.numberOfRows(inSection: tableView.numberOfSections-1)
            //                    if(lastRowIndex != 0)
            //                    {
            //                        self.editscrollAtIndex(index: lastRowIndex-1)
            //                    }
            //                    else
            //                    {
            //
            //                    }
            //                }
            //            } else {
            //                isResetNeeded = true
            //                changeCreateButtonState(isHidden: true)
            //                currentStatus = .createNew
            //                let lastRowIndex = tableView.numberOfRows(inSection: tableView.numberOfSections-1)
            //                if(lastRowIndex != 0)
            //                {
            //                    self.editscrollAtIndex(index: lastRowIndex-1)
            //                }
            //                else
            //                {
            //
            //                }
            //            }
            isResetNeeded = true
            let lastRowIndex = tableView.numberOfRows(inSection: tableView.numberOfSections-1)
            currentCellTag = lastRowIndex-1
            //currentCellTag = lastRowIndex
            saveAction(sender:sender)
            
        }else{
            isResetNeeded = false
            changeCreateButtonState(isHidden: true)
            currentStatus = .createNew
            let lastRowIndex = tableView.numberOfRows(inSection: tableView.numberOfSections-1)
            if lastRowIndex != 0
            {
                currentCellTag = lastRowIndex - 1
            }else{
                currentCellTag = 0
           }
            if(lastRowIndex != 0)
            {
                 currentCellTag = lastRowIndex
                self.editscrollAtIndex(index: currentCellTag)
            }
            else
            {
                
            }
        }
        
        //      }
    }
    
    
    func editscrollAtIndex(index:Int) {
        print("Indexxxxx",index)
        
        //        if(isResetNeeded)
        //        {
        //            isResetNeeded = false
        //        }
        
        //        DispatchQueue.main.asyncAfter(deadline: .now()+0.01, execute: {
        //            print("**********reloadddd")
        //            self.tableView.reloadData()
        //        })
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
            print("*************scrollToRow")
            
            self.tableView.scrollToRow(at: IndexPath(row: index, section: 0), at:.top, animated: true)
        })
        
    }
    
    
    
    @IBAction func saveAction(sender: UIButton) {
        
        print("Current Tag:",currentCellTag)
        
        
        if deletedPopupView.alpha == 1
        {
            self.cancelFacilityAction()
        }
        sender.isUserInteractionEnabled = false
        
        if currentStatus == .editFromReport {
            currentStatus = .saveFromReport
        }
        print("Sender Clicked:",sender.titleLabel?.text)
        
        print("Current Tag:",currentCellTag)
        
        
        
        if(isResetNeeded && currentStatus == .createNew && (sender.titleLabel?.text != "save_btn".ls) && (sender.titleLabel?.text != "save_and_close_btn".ls)){
            sender.tag = currentCellTag
            //            isResetNeeded = false
        }
        
        
        if let cell = tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as? BuildingDetailsCell {
            
            let reporDetails = InspectionReportPayload()
            
            if (sender.titleLabel?.text == "save_btn".ls){
                isSaveOnly = true
                isSaveAndClose = false
                
                cell.buildingInteriorView.saveAndCloseButton.isUserInteractionEnabled = false
                
                //    cell.buildingInteriorView.addNewReportButton.isUserInteractionEnabled = false
                
            }
            else if(sender.titleLabel?.text == "save_and_close_btn".ls){
                isSaveOnly = false
                isSaveAndClose = true
                cell.buildingInteriorView.saveButton.isUserInteractionEnabled = false
            }
            else  {
                isSaveOnly = false
                isSaveAndClose = false
                
                cell.buildingInteriorView.saveButton.isUserInteractionEnabled = false
                
                //   cell.buildingInteriorView.addNewReportButton.isUserInteractionEnabled = false
            }
            
            guard let faclity = cell.getBuildingInterierViewData() else {
                cell.buildingInteriorView.saveAndCloseButton.isUserInteractionEnabled = true
                cell.buildingInteriorView.saveButton.isUserInteractionEnabled = true
                cell.buildingInteriorView.addNewReportButton.isUserInteractionEnabled = true
                
                moveTobuildingNameposition()
                return
            }
            
            if currentStatus == .createNew {
                faclity.facilityId = ""
            }
            
            
            guard let report = cell.getBuildingExterierViewData() else {
                return
            }
            guard let _ = reportDetails else {
                
                if let requestValue = requestObject {
                    apiCallForCreateNewReport(requestDetails: requestValue, userFacility: faclity)
                }
                return
            }
            if report.applicationNumber.count == 0 || report.applicantId.count == 0 || report.serviceTypeId.count == 0 {return}
            reporDetails.userFacility = faclity
            
            // print("Ctag:",currentCellTag)
            // print("Stag:",sender.tag)
            
            if reportFacilities.count > sender.tag {
                reporDetails.userFacility.facilityId = reportFacilities[sender.tag].facilityId
            }
            reporDetails.inspectionReport = report
            if let requestObjAvailable = requestObject
            {
                // print ("Update report Called")
                updateReportData(requestDetails: requestObjAvailable, updatedData: reporDetails)
                
                DispatchQueue.main.asyncAfter(deadline: .now()+2.0, execute: {
                    print("save action \(self.currentCellTag)")
                    UIView.performWithoutAnimation {
                         self.tableView.reloadData()
                         self.scrollToBottom()
                    }
                    //self.scrollAtIndex(index: self.currentCellTag)
                })
            }
            
        }
        resetUserdefaults()
    }
    
    func resetUserdefaults()
    {
        Common.userDefaults.removeObject(forKey: "buildingName")
        Common.userDefaults.removeObject(forKey: "notes")
    }
    
    @IBAction func nextAction(sender: UIButton) {
        
        print("Current Tag:",currentCellTag)
        
        print("Row \(tableView.numberOfRows(inSection: 0))")
        
        let lastRowIndex = tableView.numberOfRows(inSection: 0)
        
        //currentCellTag = lastRowIndex-1
        
        if currentStatus == .edit
        {
            if let cell = tableView.cellForRow(at: IndexPath(row: currentCellTag, section: 0)) as? BuildingDetailsCell
            {
                
            }
            else{
                scrollToBottom()
                if Common.userDefaults.getNotes() != nil
                {
                    displayPopup()
                    return
                }
            }
        }
        
        
        if currentStatus == .createNew || currentStatus == .editFromReport || currentStatus == .saveFromReport && currentCellTag >= 0
        {
            print("next action \(self.currentCellTag)")
            if lastRowIndex != 0 && currentStatus == .createNew
            {
                currentCellTag = lastRowIndex - 1
                
                if let cell = tableView.cellForRow(at: IndexPath(row: currentCellTag, section: 0)) as? BuildingDetailsCell
                {
                if (cell.buildingInteriorView.buildingNameTextField.text?.count ?? 0) > 0
                {
                    displayPopup()
                    return
                }else
                {
                    isEditOpen = true
                }
                }
            }
            
            if let cell = tableView.cellForRow(at: IndexPath(row: currentCellTag, section: 0)) as? BuildingDetailsCell
            {
                if let DEtails = self.reportFacilities,DEtails.count < currentCellTag
                {
                    
                    guard let attachementList = reportFacilities else {return}
                    
                    for facilityAccess in self.reportFacilities[currentCellTag].facilityElementsList
                    {
                        print(" element Id \(facilityAccess.facilityElementId)")
                        for index in 0...8
                        {
                            if  String(cell.buildingInteriorView.buildingElementView.elementSetDataSource[index].elementID ?? 0) == self.reportFacilities[currentCellTag].facilityElementsList[index].facilityElementId
                            {
                                if  String(cell.buildingInteriorView.buildingElementView.elementSetDataSource[index].elementCount ?? 0) != self.reportFacilities[currentCellTag].facilityElementsList[index].facilityElementCount
                                {
                                    print("report Facilities \(self.reportFacilities[currentCellTag])")
                                    displayPopup()
                                    return
                                }
                                
                            }
                        }
                    }
                    
                    for subView in cell.buildingInteriorView.serviceSelectionView.stackView.arrangedSubviews {
                        if let button = subView as? UIButton, button.isSelected == true {
                            
                            let sValue = String(facilitiesData.facilityPayload.facilityConditions[button.tag].fConditionId)
                            
                            if sValue != self.reportFacilities[currentCellTag].serviceStatusId
                            {
                                displayPopup()
                                return
                            }
                        }
                    }
                    
                    for subView in cell.buildingInteriorView.buildingStatusSelectionView.stackView.arrangedSubviews {
                        if let button = subView as? UIButton, button.isSelected == true {
                            
                            let sValue = String(facilitiesData.facilityPayload.facilityConditions[button.tag].fConditionId)
                            
                            if sValue != self.reportFacilities[currentCellTag].buildingStatusId
                            {
                                displayPopup()
                                return
                            }
                        }
                    }
                    
                    for subView in cell.buildingInteriorView.notesSelectionView.stackView.arrangedSubviews {
                        if let button = subView as? UIButton, button.isSelected == true {
                            
                            let sValue = String(facilitiesData.facilityPayload.facilityActions[button.tag].fActionId)
                            
                            if sValue != self.reportFacilities[currentCellTag].facilityActionId
                            {
                                displayPopup()
                                return
                            }
                        }
                    }
                    if cell.buildingInteriorView.buildingNameTextField.text != DEtails[currentCellTag].buildingNameEnglish || cell.buildingInteriorView.completeDatePicker.valueLabel.text != DEtails[currentCellTag].approximateCompletionDate || cell.buildingInteriorView.buildingSizeTextField.text != DEtails[currentCellTag].buildingSizeSQF || cell.buildingInteriorView.report.userFacility.facilityTypeId != DEtails[currentCellTag].facilityTypeId || cell.buildingInteriorView.report.userFacility.facilityActionId != DEtails[currentCellTag].facilityActionId
                    {
                        print("report Facilities \(self.reportFacilities[currentCellTag])")
                        displayPopup()
                        return
                    }
                    
                }
                else
                {
                    
                    if (cell.buildingInteriorView.buildingNameTextField.text?.count ?? 0) > 0
                    {
                        displayPopup()
                        return
                    }else
                    {
                        isEditOpen = true
                    }
                    
                }
            }
            else{
                currentCellTag = lastRowIndex-1
                displayPopup()
                return
            }
        }
        if currentStatus == .edit  && currentCellTag >= 0
        {
            
            if let cell = tableView.cellForRow(at: IndexPath(row: currentCellTag, section: 0)) as? BuildingDetailsCell
            {
                
                let va = cell.buildingInteriorView.buildingElementView.helloSequence.subscribe { event in
                    print("event triggersdcc\(event)")
                }
                
                if let DEtails = self.reportFacilities
                {
                    
                    guard let attachementList = reportFacilities else {return}
                    
                    let v = self.reportFacilities[currentCellTag].facilityElementsList.sorted(by: {$0.facilityElementCountId < $1.facilityElementCountId})
                    
                    print("V values \(v)")
                    
                    for facilityAccess in self.reportFacilities[currentCellTag].facilityElementsList
                    {
                        print(" element Id \(facilityAccess.facilityElementId)")
                        
                        for index in 0...8
                        {
                            
                            if  String(cell.buildingInteriorView.buildingElementView.elementSetDataSource[index].elementCountID ?? 0) == v[index].facilityElementCountId
                            {
                                if  String(cell.buildingInteriorView.buildingElementView.elementSetDataSource[index].elementCount ?? 0) != v[index].facilityElementCount
                                                               {
                                                                   print("enter report Facilities \(self.reportFacilities[currentCellTag])")
                                                                   displayPopup()
                                                                   return
                                                                 }
                            }
                         

                            if  String(cell.buildingInteriorView.buildingElementView.elementSetDataSource[index].elementID ?? 0) == self.reportFacilities[currentCellTag].facilityElementsList[index].facilityElementId
                            {
                                if  String(cell.buildingInteriorView.buildingElementView.elementSetDataSource[index].elementCount ?? 0) != self.reportFacilities[currentCellTag].facilityElementsList[index].facilityElementCount
                                {
                                    print("report Facilities \(self.reportFacilities[currentCellTag])")
                                    displayPopup()
                                    return
                                }
                            }
                        }
                    }
                    
                    for subView in cell.buildingInteriorView.serviceSelectionView.stackView.arrangedSubviews {
                        if let button = subView as? UIButton, button.isSelected == true {
                            
                            let sValue = String(facilitiesData.facilityPayload.facilityConditions[button.tag].fConditionId)
                            
                            if sValue != self.reportFacilities[currentCellTag].serviceStatusId
                            {
                                displayPopup()
                                return
                            }
                        }
                    }
                    
                    for subView in cell.buildingInteriorView.buildingStatusSelectionView.stackView.arrangedSubviews {
                        if let button = subView as? UIButton, button.isSelected == true {
                            
                            let sValue = String(facilitiesData.facilityPayload.facilityConditions[button.tag].fConditionId)
                            
                            if sValue != self.reportFacilities[currentCellTag].buildingStatusId
                            {
                                displayPopup()
                                return
                            }
                        }
                    }
                    
                    for subView in cell.buildingInteriorView.notesSelectionView.stackView.arrangedSubviews {
                        if let button = subView as? UIButton, button.isSelected == true {
                            
                            let sValue = String(facilitiesData.facilityPayload.facilityActions[button.tag].fActionId)
                            
                            if sValue != self.reportFacilities[currentCellTag].facilityActionId
                            {
                                displayPopup()
                                return
                            }
                        }
                    }
                    if cell.buildingInteriorView.buildingNameTextField.text != DEtails[currentCellTag].buildingNameEnglish || cell.buildingInteriorView.completeDatePicker.valueLabel.text != DEtails[currentCellTag].approximateCompletionDate || cell.buildingInteriorView.buildingSizeTextField.text != DEtails[currentCellTag].buildingSizeSQF || cell.buildingInteriorView.report.userFacility.facilityTypeId != DEtails[currentCellTag].facilityTypeId || cell.buildingInteriorView.report.userFacility.facilityActionId != DEtails[currentCellTag].facilityActionId
                    {
                        print("report Facilities \(self.reportFacilities[currentCellTag])")
                        displayPopup()
                        return
                    }
                    
                }
            }
            else
            {
                
                
                let rows = currentCellTag
                
                let section = 0
                let row = currentCellTag
                let indexPaths = IndexPath(row: row, section: section)
                
                print("number of rowas \(self.tableView(self.tableView, numberOfRowsInSection: 0))")
                
                let viewcell = self.tableView.cellForRow(at: IndexPath(row: currentCellTag, section: 0)) as? BuildingDetailsCell
                
                print("viewcell  llllll \(viewcell as Any)")
                
                self.scrollToBottom()
              //  self.tableView.addParallaxImage()
                //self.tableViewMoveTo(top: 0)
            }
            
        }
        if currentCellTag >= 0
        {
            isEditOpen = true
        }
        if let facilities = self.reportFacilities,facilities.count > 0 {
            tableViewMoveTo(top: 0)
            currentStatus = .final
        }
        else {
            Common.showToaster(message: "please_save_building_first_for_to_proceed _next_toast".ls)
            return
        }
        
    }
    
    func scrollToBottom()  {
        tableView.beginUpdates()
        tableView.setContentOffset(CGPoint.zero, animated: false)
        tableView.endUpdates()
        //        let point = CGPoint(x: 0, y: self.tableView.contentSize.height + self.tableView.contentInset.top - self.tableView.frame.height)
        //        if point.y >= 0{
        //            self.tableView.setContentOffset(point, animated: true)
        //        }
    }
    
    func displayPopup()
    {
        confirmPopupView = UINib(nibName: "ConfirmationPopUpView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ConfirmationPopUpView
        
        confirmPopupView.saveBtn.tag = currentCellTag
        confirmPopupView.saveBtn.addTarget(self, action: #selector(okAction(sender:)), for: .touchUpInside)
        confirmPopupView.discardBtn.addTarget(self, action: #selector(discardAction(sender:)), for: .touchUpInside)
        
        confirmPopupView.saveBtn.setTitle("pop_Save_Btn".ls, for: .normal)
        confirmPopupView.discardBtn.setTitle("discard_btn".ls, for: .normal)
        confirmPopupView.tileLbl.text = "confirmationPopUp_Title".ls
        
        if Common.currentLanguageArabic() {
            confirmPopupView.saveBtn.titleLabel?.transform = Common.arabicTransform
            confirmPopupView.saveBtn.titleLabel?.toArabicTransform()
            confirmPopupView.tileLbl.transform = Common.arabicTransform
            confirmPopupView.tileLbl.toArabicTransform()
            confirmPopupView.discardBtn.titleLabel?.transform = Common.arabicTransform
            confirmPopupView.discardBtn.titleLabel?.toArabicTransform()
        }
        
        confirmPopupView.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            
            self.confirmPopupView.frame = UIScreen.main.bounds
            self.confirmPopupView.alpha = 1
            self.parent?.parent?.view.addSubview(self.confirmPopupView)
            
        }, completion: nil)
    }
    
    @IBAction func discardAction(sender: UIButton)
    {
        UIView.animate(withDuration: 0.5, animations: {
            self.confirmPopupView.alpha = 0.0
        }) { (completion) in
            self.confirmPopupView .removeFromSuperview()
        }
        if currentCellTag >= 0
        {
            isEditOpen = true
            tableViewMoveTo(top: 0)
            currentStatus = .final
        }
        
    }
    
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print("scrollViewWillBeginDragging")
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("scrollViewDidScroll scrollViewDidScroll")
        
    }
    
    @objc func cancelPopupAction() {
        
        UIView.animate(withDuration: 0.5, animations: {
            self.confirmPopupView.alpha = 0.0
        }) { (completion) in
            self.confirmPopupView .removeFromSuperview()
        }
    }
    
    @IBAction func okAction(sender: UIButton)
    {
        if confirmPopupView.alpha == 1
        {
            self.cancelPopupAction()
        }
        sender.isUserInteractionEnabled = false
        
        if currentStatus == .editFromReport {
            currentStatus = .saveFromReport
        }
        print("Sender Clicked:",sender.titleLabel?.text)
        
        print("Current Tag:",currentCellTag)
        
        
        if(isResetNeeded && currentStatus == .createNew && (sender.titleLabel?.text != "save_btn".ls) && (sender.titleLabel?.text != "save_and_close_btn".ls)){
            sender.tag = currentCellTag
            //            isResetNeeded = false
        }
        
        
        if let cell = tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as? BuildingDetailsCell {
            
            let reporDetails = InspectionReportPayload()
            
            if (sender.titleLabel?.text == "save_btn".ls){
                isSaveOnly = true
                isSaveAndClose = false
                
                cell.buildingInteriorView.saveAndCloseButton.isUserInteractionEnabled = false
                
                //    cell.buildingInteriorView.addNewReportButton.isUserInteractionEnabled = false
                
            }
            else if(sender.titleLabel?.text == "save_and_close_btn".ls){
                isSaveOnly = false
                isSaveAndClose = true
                cell.buildingInteriorView.saveButton.isUserInteractionEnabled = false
            }
            else  {
                isSaveOnly = false
                isSaveAndClose = false
                
                cell.buildingInteriorView.saveButton.isUserInteractionEnabled = false
                
                //   cell.buildingInteriorView.addNewReportButton.isUserInteractionEnabled = false
            }
            
            guard let faclity = cell.getBuildingInterierViewData() else {
                cell.buildingInteriorView.saveAndCloseButton.isUserInteractionEnabled = true
                cell.buildingInteriorView.saveButton.isUserInteractionEnabled = true
                cell.buildingInteriorView.addNewReportButton.isUserInteractionEnabled = true
                
                moveTobuildingNameposition()
                return
            }
            
            if currentStatus == .createNew {
                faclity.facilityId = ""
            }
            
            
            guard let report = cell.getBuildingExterierViewData() else {
                return
            }
            guard let _ = reportDetails else {
                
                if let requestValue = requestObject {
                    apiCallForCreateNewReport(requestDetails: requestValue, userFacility: faclity)
                }
                return
            }
            if report.applicationNumber.count == 0 || report.applicantId.count == 0 || report.serviceTypeId.count == 0 {return}
            reporDetails.userFacility = faclity
            
            // print("Ctag:",currentCellTag)
            // print("Stag:",sender.tag)
            
            if reportFacilities.count > sender.tag {
                reporDetails.userFacility.facilityId = reportFacilities[sender.tag].facilityId
            }
            reporDetails.inspectionReport = report
            if let requestObjAvailable = requestObject
            {
                // print ("Update report Called")
                updateReportData(requestDetails: requestObjAvailable, updatedData: reporDetails)
                
                resetUserdefaults()
                DispatchQueue.main.asyncAfter(deadline: .now()+2.2) {
                    if self.currentCellTag >= 0
                    {
                        self.tableViewMoveTo(top: 0)
                        self.currentStatus = .final
                    }
                }
            }
            
            
        }
        UIView.animate(withDuration: 0.5, animations: {
            self.confirmPopupView.alpha = 0.0
        }) { (completion) in
            self.confirmPopupView .removeFromSuperview()
        }
    }
    
    @IBAction func deleteAction(sender: UIButton)
    {
        currentCellTag = sender.tag
        
        
        deletedPopupView = UINib(nibName: "DeletePopupView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! DeletePopupView
        deletedPopupView.deleteButton.tag = currentCellTag
        deletedPopupView.deleteButton.addTarget(self, action: #selector(deleteFacilityAction), for: .touchUpInside)
        deletedPopupView.cancelButton.addTarget(self, action: #selector(cancelFacilityAction), for: .touchUpInside)
        
        deletedPopupView.deleteButton.setTitle("delete_btn".ls, for: .normal)
        deletedPopupView.cancelButton.setTitle("cancel_btn".ls, for: .normal)
        deletedPopupView.titleLabelForDelete.text = "are_you_sure_want￼_delete_facility_lbl".ls
        
        if Common.currentLanguageArabic() {
            deletedPopupView.deleteButton.titleLabel?.transform = Common.arabicTransform
            deletedPopupView.deleteButton.titleLabel?.toArabicTransform()
            deletedPopupView.titleLabelForDelete.transform = Common.arabicTransform
            deletedPopupView.titleLabelForDelete.toArabicTransform()
            deletedPopupView.cancelButton.titleLabel?.transform = Common.arabicTransform
            deletedPopupView.cancelButton.titleLabel?.toArabicTransform()
        }
        
        deletedPopupView.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            
            self.deletedPopupView.frame = UIScreen.main.bounds
            self.deletedPopupView.alpha = 1
            self.parent?.parent?.view.addSubview(self.deletedPopupView)
            
            
        }, completion: nil)
        
    }
    
    @objc func cancelFacilityAction() {
        
        UIView.animate(withDuration: 0.5, animations: {
            self.deletedPopupView.alpha = 0.0
        }) { (completion) in
            self.deletedPopupView .removeFromSuperview()
        }
    }
    
    @objc func deleteFacilityAction() {
        
        self.cancelFacilityAction()
        
        let facilityIDString = self.reportFacilities[currentCellTag].facilityId
        
        Common.showActivityIndicator()
        facilityDeleteModuleRequestToAPI.inputFacilityDelete.facilityIdInput.onNext(facilityIDString)
        facilityDeleteModuleRequestToAPI.outputFacilityDelete.facilityDeleteSummaryResultObservable.subscribe{[weak self](response) in
            Common.hideActivityIndicator()
            if let value = response.element,value.success == true {
                
                if let report = self?.reportFacilities,report.count>0
                {
                    if self?.reportFacilities[self?.currentCellTag ?? 0].facilityId == facilityIDString
                    {
                        if let attachmentData = self?.attachmentFacilitiesList
                        {
                            if(attachmentData.count) > 0{
                                self?.attachmentFacilitiesList.removeAll()
                            }
                        }
                        self?.reportFacilities.remove(at: self?.currentCellTag ?? 0)
                        
                    }
                    DispatchQueue.main.async {
                        
                        self?.tableView.reloadData()
                        Common.showToaster(message: response.element!.message)
                    }
                }
                
            }
            
        }.disposed(by: disposeBag)
        
    }
    
    @IBAction func editAction(sender: UIButton) {
        
        currentCellTag = sender.tag
        isEditOpen = true
        print("General Edit")
        print("currentStatus    ", currentStatus)
        
        if currentStatus == .completed {
            self.currentStatus = .list
            return
        }
        
        self.currentStatus = .edit
        print("after currentStatus   ", currentStatus)
        
        self.changeBottomViewVisibleState(visible: true)
        if self.currentCellTag < self.reportFacilities.count
        {
            self.attachmentFacilitiesList = self.reportFacilities[self.currentCellTag].facilityAttachmentsList
        }
        scrollAtIndex(index: sender.tag)
    }
    
    
    func scrollAtIndex(index:Int) {
        
        if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? BuildingDetailsCell {
            DispatchQueue.main.async {
                
                self.tableView.reloadData()
                self.tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .top, animated: true)
                cell.showBuildingInteriorView()
            }
        }
    }
    @IBAction func satelliteButtonAction(sender: UIButton) {
        satellitePhotoAction(sender: sender)
    }
    
    @IBAction func viewAction(sender: UIButton) {
        
        let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "SimplifiedReportDetailsViewController") as? SimplifiedReportDetailsViewController
        
        
        nextVC!.requestObject = requestObject
        nextVC?.delegateFromImages = self
        nextVC?.updateReportDataDelegate = self
        nextVC?.setValuesToReportOverView(summary: requestDetails, report: reportDetails, faclities: reportFacilities, defaultFaclities: facilitiesData)
        nextVC?.attachmentFaclitiesList = attachmentFacilitiesList
        self.navigationController?.pushViewController(nextVC!, animated: true)
        
    }
    
    
    
    @IBAction func satellitePhotoAction(sender: UIButton) {
        
        if requestObject.plot.latitude.isEmpty && requestObject.plot.longitude.isEmpty
        {
            Common.showToaster(message: "please_add_the_coordinates_to_draw_the_building_points".ls)
            return
        }
        
        let satelliteVC = self.storyboard?.instantiateViewController(withIdentifier: "AddSatellitePhotoController") as! AddSatellitePhotoController
        
        satelliteVC.requestObject = requestObject
        
        self.parent?.navigationController?.pushViewController(satelliteVC, animated: true)
        
    }
    
    //    MARK: Site Images uploaded
    
    @IBAction func addPhotoAction(sender: UIButton) {
        
        if currentStatus == .createNew
        {
            Common.showToaster(message: "please_save_building_to_upload_the_image.".ls)
            return
        }
        
        let points = sender.convert(CGPoint.zero, to: self.view)
        let popoverContentController = self.storyboard?.instantiateViewController(withIdentifier: "ImageGalleryPopOverViewController") as? ImageGalleryPopOverViewController
        popoverContentController?.modalPresentationStyle = .popover
        
        if let popoverPresentationController = popoverContentController?.popoverPresentationController {
            popoverPresentationController.permittedArrowDirections = .left
            popoverContentController?.preferredContentSize = CGSize(width: 300, height: 135)
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = CGRect(x: points.x + sender.frame.size.width, y: points.y + (sender.frame.size.height / 2) , width: 0, height: 0)
            popoverPresentationController.delegate = self
            popoverContentController?.delegatePopOver = self
            if let popoverController = popoverContentController {
                present(popoverController, animated: true, completion: nil)
            }
        }
        
    }
    
    
    
    
    
    func navigateToAddPhotoViewController(imageType:imageTypeForUploading,pickedImage:UIImage)  {
        
        DispatchQueue.main.async {
            if let photoVC = self.storyboard?.instantiateViewController(withIdentifier: "AddPhotoViewController") as? AddPhotoViewController {
                photoVC.delegate = self
                photoVC.inspectionParms = self.reportDetails
                photoVC.userFaclityParms = self.reportFacilities
                photoVC.currentTag = self.currentCellTag
                photoVC.imageType = imageType
                photoVC.imageSelectedFromPicker = pickedImage
                self.parent?.navigationController?.pushViewController(photoVC, animated: true)
            }
        }
        
    }
    
    func importPhotosFromGallery() {
        
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.modalPresentationStyle = .overCurrentContext
        imagePicker.modalTransitionStyle = .crossDissolve
        let rootVC = UIApplication.shared.keyWindow!.rootViewController
        rootVC?.present(imagePicker, animated: true, completion: nil)
    }
    
    
    func mocetoParticularEdit()
    {
        
        
        if currentStatus == .completed {
            self.currentStatus = .list
            return
        }
        
        self.currentStatus = .edit
        
        self.changeBottomViewVisibleState(visible: true)
        if currentCellTag < self.reportFacilities.count
        {
            self.attachmentFacilitiesList = self.reportFacilities[self.currentCellTag].facilityAttachmentsList

        }
        
        scrollAtIndex(index: self.currentCellTag)
    }
    
    func callParticularIndex(index:Int)
    {
        
        if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? BuildingDetailsCell {
            
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
                self.tableView.reloadData()
                self.tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .top, animated: true)
                cell.showBuildingInteriorView()
            })
        }
        
    }
    
    //    MARK: Back button Action
    
    @IBAction func backButtonAction(sender: UIButton) {
        
        if  self.currentStatus == .list
        {
            self.currentStatus = .completed
            self.tableViewMoveTo(top: 0)
            return
        }
        if sender.tag == 11
        {
            if self.currentStatus == .edit
            {
                self.currentStatus = .list
                self.tableViewMoveTo(top: 0)
                return
            }
            else if self.currentStatus == .final
            {
                self.currentStatus = .list
                self.tableViewMoveTo(top: 0)
                return
            }else if self.currentStatus == .editFromReport
            {
                 buildingInfoDelegate.shareReportDataInfo(summary: requestDetails, report: reportDetails, faclities: reportFacilities, defaultFaclities: facilitiesData)
                self.navigationController?.popViewController(animated: true)
                return
            }
            if isFromDashBorad {
                if let parentVC = self.parent {
                    if parentVC.parent is StartMyTripViewController {
                        let vc = parentVC.parent as? StartMyTripViewController
                        vc?.tripInfoView.isHidden = false
                        vc?.backAcnView.isHidden = false
                    }
                    parentVC.remove()
                }
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }else {
            if self.currentStatus == .edit || self.currentStatus == .createNew || self.currentStatus == .editFromReport {
                
                if currentStatus == .edit && currentCellTag != nil && isEditOpen == true
                {
                    mocetoParticularEdit()
                }else if currentStatus == .editFromReport
                {
        buildingInfoDelegate.shareReportDataInfo(summary: requestDetails, report: reportDetails, faclities: reportFacilities, defaultFaclities: facilitiesData)
                         
                     //    selectDelegate.didSelectTag(tags: self.attachmentFacilitiesList,reportFacility: reportFacilities)
                         
                         self.navigationController?.popViewController(animated: true)
                         return
                    
                    
                    return
                }
                
                self.currentStatus = .list
                
                DispatchQueue.main.async {
                    
                    self.changeCreateButtonState(isHidden: false)
                    self.changeStelliteImageStatus(isHidden: true)
                    self.changeBottomViewVisibleState(visible: true)
                }
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
                    self.changeCreateButtonState(isHidden: false)
                    self.tableView.reloadData()
                }
            }
            else if self.currentStatus == .final
            {
                if  isEditOpen == true
                {
                    mocetoParticularEdit()
                    tableView.reloadData()
                }
                else
                {
                    self.currentStatus = .list
                    self.tableViewMoveTo(top: 0)
                }
            }
            else if self.currentStatus == .completed
            {
                self.navigationController?.popViewController(animated: true)
            }
            else
            {
                self.navigationController?.popViewController(animated: true)
            }
            
        }
        
        
    }
    
    
    
    
    @IBAction func createReportWithDataAction(sender: UIButton) {
        
        if let cell = tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as? BuildingDetailsCell {
            
            
            let reporDetails = InspectionReportPayload()
            guard let report = cell.getBuildingExterierViewData() else {
                return
            }
            if let facilities = reportFacilities.first {
                
                reporDetails.userFacility = facilities
                if facilities.approximateCompletionDate.count > 0 {
                    let dateVal =  "".selectedStringToDateFormat(date: facilities.approximateCompletionDate.serverDateFormatToMedium())
                    reporDetails.userFacility.approximateCompletionDate = dateVal
                }
                reporDetails.inspectionReport = report
                
                updateReportData(requestDetails: requestObject, updatedData: reporDetails)
            }
        }
    }
    
    func tableViewMoveTo(top:CGFloat) {
        
        UIView.animate (withDuration: 0.1, animations: {
            var value:CGPoint = .zero
            if top > 0 {
                self.tableView.reloadData()
                value = CGPoint(x: self.tableView.contentOffset.x, y: top)
            }
            self.tableView.contentOffset = value
        }) {(_) in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
    }
    
    func moveTobuildingNameposition()
    {
        let indexPath:IndexPath = IndexPath(row: 0, section: 0)
        self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
    
    func changeCreateButtonState(isHidden:Bool) {
        
        if let headerView = tableView.tableHeaderView as? SimplifiedRequestHeaderView {
            if isHidden {
                tableView.tableHeaderView?.frame.size.height = (self.tableView.frame.size.width * 0.3)
            } else  {
                tableView.tableHeaderView?.frame.size.height = (self.tableView.frame.size.width * 0.42)
            }
            headerView.addNewBuildingButton.isUserInteractionEnabled = true
            headerView.addNewBuildingButton.superview?.isHidden = isHidden
        }
    }
    
    func changeBottomViewVisibleState(visible: Bool) {
        DispatchQueue.main.async {
            self.bottomView.isHidden = !visible
            self.tableView.layoutIfNeeded()
            self.view.layoutSubviews()
        }
    }
    
    
    func changeStelliteImageStatus(isHidden:Bool)
    {
        guard let headerView = tableView.tableHeaderView as? SimplifiedRequestHeaderView else {
            return
        }
        headerView.addSatellitePhotoButton.isHidden = isHidden
    }
    
    func addActionObservers(cell:BuildingDetailsCell) {
        
        cell.buildingInteriorView.saveButton.addTarget(self, action: #selector(saveAction(sender:)), for: .touchUpInside)
        cell.buildingInteriorView.saveAndCloseButton.addTarget(self, action: #selector(saveAction(sender:)), for: .touchUpInside)
        cell.buildingInteriorView.addNewReportButton.addTarget(self, action: #selector(createNewReportAction(sender:)), for: .touchUpInside)
        cell.buildingNameView.editButton.addTarget(self, action: #selector(editAction(sender:)), for: .touchUpInside)
        cell.buildingNameView.deleteButton.addTarget(self, action: #selector(deleteAction(sender:)), for: .touchUpInside)
        cell.buildingInteriorView.addSatellitePhotoButton.addTarget(self, action: #selector(satellitePhotoAction(sender:)), for: .touchUpInside)
        cell.buildingInteriorView.addPhotoButton.addTarget(self, action: #selector(addPhotoAction(sender:)), for: .touchUpInside)
        
        cell.buildingNameView.viewButton.addTarget(self, action: #selector(viewAction(sender:)), for: .touchUpInside)
        
        cell.buildingInteriorView.noOfPhotosLabel.isHidden = true
        cell.buildingInteriorView.noOfPhotosLabel.isUserInteractionEnabled = true
        addGestureToView(view:  cell.buildingInteriorView.noOfPhotosLabel)
        
        cell.buildingExteriorView.createSimplipifiedButton.addTarget(self, action: #selector(createReportWithDataAction(sender:)), for: .touchUpInside)
        cell.buildingInteriorView.nextButton.addTarget(self, action: #selector(nextAction(sender:)), for: .touchUpInside)
        
        cell.buildingInteriorView.backButton.addTarget(self, action: #selector(backButtonAction(sender:)), for: .touchUpInside)
        cell.buildingExteriorView.backButton.addTarget(self, action: #selector(backButtonAction(sender:)), for: .touchUpInside)
         cell.buildingInteriorView.viewAttachedPhotosBtn.addTarget(self, action: #selector(viewAttachedPhotosBtn(sender:)), for: .touchUpInside)
        
        guard let attachementList = attachmentFacilitiesList else {return}
        if attachementList.count == 0 {
            cell.buildingInteriorView.viewAttachedPhotosBtn.alpha =  0
            cell.buildingInteriorView.viewAttachedPhotosBtn.isUserInteractionEnabled = false
        }else
        {
            cell.buildingInteriorView.viewAttachedPhotosBtn.alpha =  1
            cell.buildingInteriorView.viewAttachedPhotosBtn.isUserInteractionEnabled = true
        }
        
        //                    if self.reportFacilities[currentCellTag].facilityAttachmentsList.count > 0 {
        //                       cell.buildingInteriorView.viewAttachedPhotosBtn.alpha = 1
        //                   }else
        //                   {
        //                       cell.buildingInteriorView.viewAttachedPhotosBtn.alpha = 0
        //                   }
        
        
        
       
        
        //  cell.buildingInteriorView.saveAndCloseButton.addTarget(self, action: #selector(createNewReportAction(sender:)), for: .touchUpInside)
        
        cell.buildingInteriorView.saveButton.isUserInteractionEnabled = true
        cell.buildingInteriorView.saveAndCloseButton.isUserInteractionEnabled = true
        cell.buildingInteriorView.addNewReportButton.isUserInteractionEnabled = true
        
        
    }
    
    
    func addGestureToView(view: UIView) {
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        
        guard let attachementList = attachmentFacilitiesList else {return}
        if attachementList.count > 0 {
            presentPopUpView(type: .Photo,photoCount:self.attachmentFacilitiesList.count, facilitiesAttachmentList: self.attachmentFacilitiesList)
        }
    }
    
    @IBAction func viewAttachedPhotosBtn(sender: UIButton) {
        attachmentFacilitiesList = self.reportFacilities[sender.tag].facilityAttachmentsList
        print("attachmentFacilitiesList  \(self.attachmentFacilitiesList)")

        guard let attachementList = attachmentFacilitiesList else {return}
        if attachementList.count > 0 {
            presentPopUpView(type: .Photo,photoCount:self.attachmentFacilitiesList.count, facilitiesAttachmentList: self.attachmentFacilitiesList)
        }
        
    }
    
    private func presentPopUpView(type:PopUpType,photoCount: Int, facilitiesAttachmentList:[FacilityAttachments]) {
        
        guard let popVc = self.storyboard?.instantiateViewController(withIdentifier: "SimplifiedReportPopController") as? SimplifiedReportPopController else { return }
        popVc.modalPresentationStyle = .overCurrentContext
        popVc.modalTransitionStyle = .crossDissolve
        popVc.type = type
        popVc.delegateForRefresh = self
        popVc.currentCellTag = currentCellTag
        popVc.totalPhotosCount = photoCount
        popVc.attachmentFaclitiesList = facilitiesAttachmentList
        popVc.currentCellTag = currentCellTag
        popVc.popupFrom = .Edit
        let rootVC = UIApplication.shared.keyWindow!.rootViewController
        rootVC?.present(popVc, animated: true, completion: nil)
    }
    
}

extension CreateSimplifiedReportController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return getNoRows()
    }
    
    private func getNoRows() -> Int {
        guard let data = reportFacilities else {
            if currentStatus == .createNew {
                return 1
            }
            return 0
            
        }
        
        if currentStatus == .createNew && (data.first?.buidingName().count ?? 0) > 0{
            return data.count + 1
        } else if currentStatus == .final || currentStatus == .completed {
            return 1
        }else if data.count == 0 && currentStatus == .createNew {
            return 1
        } else {
            return data.count
        }
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BuildingDetailsCell.Identifier, for: indexPath) as? BuildingDetailsCell  else { return UITableViewCell() }
        
        print("tableview loop")
        print("******* current Cell Tag \(currentCellTag)")
        var rows = self.tableView.numberOfRows(inSection: 0)
        
        if let faclity = facilitiesData {
            //            print("Current cell indexPath:",indexPath.row)
            cell.setFacilitiesData(data: faclity)
            if let faclitiObject = reportFacilities,faclitiObject.count > indexPath.row {
                
                cell.setFacilitiesData(data: faclity, faclities: faclitiObject[indexPath.row])
            }
        }
        if let reportObject = reportDetails {
            
            cell.buildingInteriorView.report.inspectionReport = reportObject
            cell.buildingExteriorView.setBuildingReportDetails(details: reportObject)
            if let faclitiObject = reportFacilities, faclitiObject.count > indexPath.row {
                cell.setBuildingDetails(report: reportObject, faclities: faclitiObject[indexPath.row])
            }
            else
            {
                //                guard let faclitiObject = reportFacilities,let dataValues = faclitiObject[indexPath.row]  else{return UITableViewCell()}
                //                if let faclitiObject = reportFacilities,faclitiObject.count == indexPath.row ,(faclitiObject.last?.buidingName().count ?? 0) < 0 {
                //                 //   let currentReport = faclitiObject[indexPath.row]
                //                  //  print("Data is:current")
                //                  //  if (currentReport.buidingName().count ) < 0{
                //                if(cell.buildingInteriorView.isHidden == false){
                //                cell.buildingInteriorView.resettingPerviousValue()}
                //              //  }
                //                }
            }
        }
        
        cell.buildingNameView.deleteButton.isHidden = true
        switch currentStatus {
        case .list:
            cell.showBuildingHeaderView(index: indexPath.row)
            cell.showBuildingNameView()
            cell.buildingNameView.deleteButton.isHidden = false
            
        case .createNew :
            
            cell.buildingInteriorView.viewAttachedPhotosBtn.alpha = 0
            if let reportFacility = reportFacilities,(reportFacility.first?.buidingName().count ?? 0) > 0 {
                if reportFacilities.count == indexPath.row {
                    if let attachmentData = self.attachmentFacilitiesList{
                        if(attachmentData.count) > 0{
                            self.attachmentFacilitiesList.removeAll()
                        }
                    }
                    print("First Entry")
                    cell.buildingInteriorView.setUnKnownSelected(isSelected: true)
                    
                    cell.buildingInteriorView.resettingPerviousValue()
                    
                    cell.showBuildingInteriorView()
                    
                    //   cell.buildingInteriorView.addNewReportButton.isUserInteractionEnabled = false
                    cell.buildingInteriorView.addNewReportButton.isUserInteractionEnabled = true
                    
                } else {
                    if let attachmentData = self.attachmentFacilitiesList{
                        if(attachmentData.count) > 0{
                            self.attachmentFacilitiesList.removeAll()
                        }
                    }
                    cell.buildingInteriorView.viewAttachedPhotosBtn.tag = indexPath.row
                    cell.buildingInteriorView.viewAttachedPhotosBtn.alpha = 0
                    //  cell.buildingInteriorView.addNewReportButton.isHidden = false
                    cell.buildingInteriorView.addNewReportButton.isUserInteractionEnabled = true
                    
                    cell.showBuildingNameView()
                }
                
            } else {
                
                cell.buildingInteriorView.setUnKnownSelected(isSelected: true)
                cell.buildingInteriorView.resettingPerviousValue()
                
                cell.showBuildingInteriorView()
                
                // cell.buildingInteriorView.addNewReportButton.isUserInteractionEnabled = false
                cell.buildingInteriorView.addNewReportButton.isUserInteractionEnabled = true
                
            }
            
        case .edit  :
            
            if currentCellTag == indexPath.row {
                //  cell.buildingInteriorView.addNewReportButton.isHidden = false
                cell.buildingInteriorView.addNewReportButton.isUserInteractionEnabled = true
                //                cell.buildingInteriorView.saveButton.isUserInteractionEnabled = true
                //        cell.buildingInteriorView.saveAndCloseButton.isUserInteractionEnabled = true
                cell.showBuildingInteriorView()
            }
            else {
                cell.showBuildingNameView()
                //    cell.showBuildingHeaderView(index: indexPath.row)
            }
        case .editFromReport:
            
            self.attachmentFacilitiesList = self.reportFacilities[indexPath.row].facilityAttachmentsList
            cell.buildingInteriorView.viewAttachedPhotosBtn.tag = indexPath.row

            if currentCellTag == indexPath.row {
                //  cell.buildingInteriorView.addNewReportButton.isHidden = false
                cell.buildingInteriorView.addNewReportButton.isUserInteractionEnabled = true
                
                cell.showBuildingInteriorView()
                cell.buildingInteriorView.viewAttachedPhotosBtn.addTarget(self, action: #selector(viewAttachedPhotosBtn(sender:)), for: .touchUpInside)
            } else {
                cell.showBuildingHeaderView(index: indexPath.row)
            }
            
        case .final :
            cell.showBuildingExteriorView()
        case .completed :
            cell.showCompletedReportView()
            
        default:
            break
        }
        
        cell.buildingInteriorView.saveButton.tag = indexPath.row
        cell.buildingInteriorView.addNewReportButton.tag = indexPath.row
        cell.buildingInteriorView.saveAndCloseButton.tag = indexPath.row
        cell.buildingInteriorView.viewAttachedPhotosBtn.tag = indexPath.row

        cell.buildingInteriorView.buildingNameTextField.layer.borderColor = UIColor.appBorderColor().cgColor
        
        if let report = reportFacilities, report.count == 0 {
            cell.buildingNameView.viewButton.isHidden = true
        }
        
        cell.buildingNameView.editButton.tag = indexPath.row
        cell.buildingNameView.deleteButton.tag = indexPath.row
        addActionObservers(cell: cell)
        cell.layoutIfNeeded()
        
        return cell
    }
    
}


//MARK:- Custom Protocols
extension CreateSimplifiedReportController : PageRefreshDelegate {
    
    func refreshPage(currentCellTag: Int) {
        
        DispatchQueue.main.async {
            
            if let cell = self.tableView.cellForRow(at: IndexPath(row: currentCellTag, section: 0)) as? BuildingDetailsCell {
                
                if self.attachmentFacilitiesList != nil
                {
                    let attachmentCount:Int = self.attachmentFacilitiesList.count + 1
                    
                    let numberofPhotosString = String(attachmentCount)
                    
                    cell.buildingInteriorView.numberOfPhotosInt = attachmentCount
                    cell.buildingInteriorView.noOfPhotosLabel.attributedText = "number_of_Photos".ls.getAttributeString(color: .darkGray).joinedString(string:numberofPhotosString.getUnderLineAttributeString(color: .red))
                }else
                {
                    let numberofPhotosString = "1"
                    
                    cell.buildingInteriorView.numberOfPhotosInt = 1
                    cell.buildingInteriorView.noOfPhotosLabel.attributedText = "number_of_Photos".ls.getAttributeString(color: .darkGray).joinedString(string:numberofPhotosString.getUnderLineAttributeString(color: .red))
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.3, execute: {
                    self.refreshedAPICallFromImagesUpload(currentTag: currentCellTag)
                })
                
                
                
            }
            else
            {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                    
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                        self.tableView.reloadData()
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.4) {
                        
                        let viewcell = self.tableView.cellForRow(at: IndexPath(row: currentCellTag, section: 0)) as? BuildingDetailsCell
                        print(viewcell as Any)
                        
                        if let cell = self.tableView.cellForRow(at: IndexPath(row: currentCellTag, section: 0)) as? BuildingDetailsCell {
                            
                            if self.attachmentFacilitiesList != nil
                            {
                                let attachmentCount:Int = self.attachmentFacilitiesList.count + 1
                                
                                let numberofPhotosString = String(attachmentCount)
                                
                                cell.buildingInteriorView.numberOfPhotosInt = attachmentCount
                                cell.buildingInteriorView.noOfPhotosLabel.attributedText = "number_of_Photos".ls.getAttributeString(color: .darkGray).joinedString(string:numberofPhotosString.getUnderLineAttributeString(color: .red))
                            }else
                            {
                                let numberofPhotosString = "1"
                                
                                cell.buildingInteriorView.numberOfPhotosInt = 1
                                cell.buildingInteriorView.noOfPhotosLabel.attributedText = "number_of_Photos".ls.getAttributeString(color: .darkGray).joinedString(string:numberofPhotosString.getUnderLineAttributeString(color: .red))
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                                self.refreshedAPICallFromImagesUpload(currentTag: currentCellTag)
                            })
                        }
                    }
                    
                })
            }
        }
    }
    
}

extension CreateSimplifiedReportController:ImageRefreshDelegate
{
    
    
    func refreshPageAfterDeleteAttachment(currentCellTag: Int, attachmentIndex: Int) {
        
        self.reportFacilities[currentCellTag].facilityAttachmentsList.remove(at: attachmentIndex)
        if let cell = tableView.cellForRow(at: IndexPath(row: currentCellTag, section: 0)) as? BuildingDetailsCell {
            
            self.attachmentFacilitiesList = self.reportFacilities[self.currentCellTag].facilityAttachmentsList
            
            if self.reportFacilities[currentCellTag].facilityAttachmentsList.count > 0 {
                cell.buildingInteriorView.viewAttachedPhotosBtn.alpha = 1
                
            }else
            {
                cell.buildingInteriorView.viewAttachedPhotosBtn.alpha = 0
            }
        }
        
    }
    
}

extension CreateSimplifiedReportController: PopoverDelegate {
    
    func takePhotoAction() {
        
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
        #if targetEnvironment(simulator)
        Common.showToaster(message: "please_check_with_real_device_toast".ls)
        #else
        self.navigateToAddPhotoViewController(imageType:.camera, pickedImage: UIImage())
        #endif
        
    }
    
    func importPhotoFromLibraryAction() {
        
        dismiss(animated: true, completion: nil)
        self.importPhotosFromGallery()
        
    }
}


//MARK: PopoverDelegates
extension CreateSimplifiedReportController: UIPopoverPresentationControllerDelegate {
    
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    //UIPopoverPresentationControllerDelegate
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        
    }
    
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return true
    }
    
}


extension CreateSimplifiedReportController : UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    // MARK: - UIImagePickerControllerDelegate Methods
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if isDisable == false
        {
            isDisable = true
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                    
                    self.navigateToAddPhotoViewController(imageType: .photoLibrary, pickedImage: pickedImage)
                }
            }
            dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension CreateSimplifiedReportController:ReportImageDeleteDelegate
{
    
    func deleteImagesFromReportScreenToCreateReportScreen() {
        viewModel = SimplifiedReportViewModule(ReportService())
        
        //  setupApiCall()
        
        if let vM = viewModel {
            if let report = reportDetails{
                getReportFaciliesData(viewModel: vM, reportId: report.inspectionReportId)
                isFromPhotoUpdate = true
            }
        }
    }
}


extension CreateSimplifiedReportController:callBackReportDataDelegate{
    func updateReportDataSimplifiedReportController(summary:RequestSummary,report:InspectionReportRespose,facilities:[UserFacility],defaultFaclities:FacilityResponsePayload){
        
    //    (summary: requestDetails, report: reportDetails, faclities: reportFacilities, defaultFaclities: facilitiesData)
        
        self.requestDetails = summary
        self.reportDetails = report
        self.reportFacilities = facilities
        self.facilitiesData = defaultFaclities
        
        
    }
}
