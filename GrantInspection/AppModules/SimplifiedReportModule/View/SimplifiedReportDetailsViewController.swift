//
//  SimplifiedReportDetailsViewController.swift
//  GrantInspection
//
//  Created by Rajeswaran Thangaperumal on 03/09/2019.
//  Copyright © 2019 MBRHE. All rights reserved.
//

import UIKit
import RxSwift
import Toaster
import PDFKit
import Alamofire

protocol ReportImageDeleteDelegate {

    func deleteImagesFromReportScreenToCreateReportScreen()
}

protocol  callBackReportDataDelegate: class {
    func updateReportDataSimplifiedReportController(summary:RequestSummary,report:InspectionReportRespose,facilities:[UserFacility],defaultFaclities:FacilityResponsePayload)
}

class SimplifiedReportDetailsViewController: UIViewController, UIDocumentInteractionControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var currentState: ReportStatus!

    var updateReportDataDelegate:callBackReportDataDelegate!
    
    var reportSummaryDetails: RequestSummary!
    
    var reportFacilityData : [UserFacility]!
    
    var reportDetails: InspectionReportRespose!
    
    var allFacilityFields: FacilityResponsePayload!
    
    var attachmentFaclitiesList:[FacilityAttachments]!
    
    var attachmentsOverAllList = [FacilityAttachments]()
    var attachmentImageList = [AttachmentViewResponseDetails]()

    
    var requestObject: Dashboard!
    
    var viewModel: SimplifiedReportViewModule!
    
    var b_Img_Cell : BuildingImageDetailsCell?
    var f_Report_Cell : FinalReportNotesCell?
    var b_Info_Cell = [Int: BuildingInfoCell?]()
    var b_Info_Cell_Arr = [BuildingInfoCell?]()
    var b_Info_Set :Set = Set<BuildingInfoCell?>()
    
    var testCellArr = [BuildingInfoCell]()
    

     var currentCellTag = 0
    var currentFacilityIndex = 0

    
    var cellTag = 0
    var deleteImage:Bool = false
    
    
    var attachmentViewRequestingToApi:AttachmentViewModule!
    var responseAttachmentViewPayload:AttachmentViewResponsePayload!
    var responseAttachmentViewResponse:AttachmentViewResponseDetails!
    
    var cellImageArray = [Int:UIImage] ()
    var cellView = [BuildingInfoCell]()
    var delegateFromImages:ReportImageDeleteDelegate!
    
    var isPDFViewMode : Bool = false {
        didSet {
            hideAndShowButtonsForPDF(bool: isPDFViewMode)
        }
    }
    
    var isImageApiAccessNeeded : Bool = false {
              didSet{
                  getFacilityAttachmentsImages(isApiAccessNeeded: isImageApiAccessNeeded)
              }
          }
    var finalImageData = [UIImage]()

    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         attachmentViewRequestingToApi = AttachmentViewModule(AttachmentViewService())
        satViewModel = SatelliteViewModel(SatelliteServiceCall())
        
        NotificationCenter.default.addObserver(self, selector: #selector(self .methodOfReceivedNotification(notification:)), name: Notification.Name("imageDeleteFromCollection"), object: nil)
        
        
    
        tableViewSetup()
        currentState = .view
        viewModel = SimplifiedReportViewModule(ReportService())
        setLayout()
        
        
        if Common.isConnectedToNetwork() {

                   currentFacilityIndex = 0
                   //isImageApiAccessNeeded = true
        }
        
        self.attachmentViewRequestingToApi.outputDataAttachmentView.attachmentrequestSummaryResultObservable.subscribe{[weak self](response) in
        if let value = response.element,value.success == true {
            self?.responseAttachmentViewPayload = value.payload
           self?.responseAttachmentViewResponse = self?.responseAttachmentViewPayload.viewAttachmentPayload

            if(self!.currentFacilityIndex < (self?.attachmentsOverAllList.count)!){
            let currentFacilityData = self?.attachmentsOverAllList[self!.currentFacilityIndex]
            let attachmentId = currentFacilityData!.attachmentId
          self?.responseAttachmentViewResponse.attachmentId = attachmentId
                
          let existing = self?.attachmentImageList.filter({$0.attachmentId == value.payload.viewAttachmentPayload.attachmentId})
                     if existing?.count == 0 {
                          self?.attachmentImageList.append(self!.responseAttachmentViewResponse)
                     }
                
                if (self?.attachmentImageList.count == self?.attachmentsOverAllList.count) && (self?.currentState == .final) {
                                DispatchQueue.main.async {
                           self?.b_Img_Cell?.buildingSiteImagesView.imageAttachmentList = self?.attachmentImageList
                           self?.b_Img_Cell?.buildingSiteImagesView.setAttachmentViews()
                               }
                           }
                
                
          self?.currentFacilityIndex = self!.currentFacilityIndex+1
                
            if  (self?.currentFacilityIndex == self?.attachmentsOverAllList.count) || (self!.currentFacilityIndex > (self?.attachmentsOverAllList.count)!)
          {
             self?.currentFacilityIndex = 0
              self?.isImageApiAccessNeeded = false
          }
          else{
              self?.isImageApiAccessNeeded = true
          }
            }
        }
        }.disposed(by: self.disposeBag)
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if tableView != nil {
            tableView.tableHeaderView?.frame.size.height = self.tableView.frame.size.width * 0.32
        }
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // print("requestObject    ", requestObject)
        
        if Common.isConnectedToNetwork() {
            
                  if self.attachmentImageList.count > 0  {
                      self.attachmentImageList.removeAll()
                  }
                     
                     if attachmentsOverAllList.count > 0 {
                         isImageApiAccessNeeded = true
                     }
            
            GetCoordinatesApiCall()
            
//            currentFacilityIndex = 0
//
//            isImageApiAccessNeeded = true
            
        }
        else {
            Common.showToaster(message: "check_internet_connectivity_issue".ls)
        }
    
    }
    
   
    @objc func methodOfReceivedNotification(notification:Notification)  {

        let attachmentId = notification.userInfo?["AttachmentID"] as? String ?? ""

        let data = reportFacilityData.map({$0.facilityAttachmentsList}).flatMap({$0}).filter({$0.attachmentId == attachmentId})
       
        let userFacility = reportFacilityData.filter({$0.facilityAttachmentsList.first?.facilityId == data.first?.facilityId})
        
        let indexFacility = reportFacilityData.firstIndex(where: {$0.facilityId == userFacility.first?.facilityId})

        let attachmentList = reportFacilityData[indexFacility ?? 0].facilityAttachmentsList
 
        let index = attachmentList.firstIndex(where: {$0.attachmentId == attachmentId})
    
        self.reportFacilityData[indexFacility!].facilityAttachmentsList.remove(at: index!)

         let indexForOverall = self.attachmentsOverAllList.firstIndex(where: {$0.attachmentId == attachmentId})
        
        self.attachmentsOverAllList.remove(at: indexForOverall!)
        
        if (attachmentImageList.count > 0)
            {
        if let isImageAttachmentAvailable = self.attachmentImageList.filter({$0.attachmentId == attachmentId}).first{
                                  let index = self.attachmentImageList.firstIndex(where: {$0.attachmentId == attachmentId})
                                  self.attachmentImageList.remove(at: index!)
                              }
        }
        
        self.delegateFromImages.deleteImagesFromReportScreenToCreateReportScreen()
        
        self.tableView.reloadData()
        
    }
    
    //MARK:- GET API CALL - COORDINATES
    
    var satViewModel: SatelliteViewModel!
    var satellitePayload = SatelliteResponsePayload()
    
    func GetCoordinatesApiCall() {
        Common.showActivityIndicator()
        
        if requestObject == nil {
            return
        }
        
        let applicationNO = "\(requestObject.applicationNo)"
        let applicationID = "\(requestObject.applicantId)"
        let serviceType = "\(requestObject.serviceTypeId)"
        
        satViewModel.input.applicantId.asObserver().onNext(applicationID)
        satViewModel.input.applicationNo.asObserver().onNext(applicationNO)
        satViewModel.input.serviceType.asObserver().onNext(serviceType)
        
        satViewModel.output.getCoordinateResponse.subscribe(onNext: { [unowned self](response) in
            
            //// print("GET_SUcccc:::response:::     ", response)
            
            self.satellitePayload = response.payload
            // print("RPT_VW_PaylDD     ",self.satellitePayload)
            
            if self.satellitePayload.plotCoordinate != "" && self.satellitePayload.polygons.polygonTAG != "" {
                
                //mapView.camera.zoom = Double(self.satellitePayload.polygons.mapZoom)
                //self.loadAllPolygonsInView()
                
                self.tableView.reloadData()
            }else
            {
                self.tableView.reloadData()
            }
            
            
            Common.hideActivityIndicator()
            
            
        }) .disposed(by: disposeBag)
        
        viewModel.output.errorsObservable
        .subscribe(onNext: { [unowned self] (error) in
            
            Common.hideActivityIndicator()
            let errorMessage = (error as NSError).domain
            if !errorMessage.isEmpty{
                
                Common.showToaster(message: errorMessage)
            }else {
                Common.showToaster(message: "bad_Gateway".ls)
            }
            
            // self.noDataAvailable(noInternet: true)
        })
        .disposed(by: disposeBag)
    }
    
    func getFacilityAttachmentsImages(isApiAccessNeeded : Bool){
                
                let isfacilityattachmentsavailable = self.attachmentsOverAllList
                Common.showActivityIndicator()
                    if (currentFacilityIndex < isfacilityattachmentsavailable.count)&&(isApiAccessNeeded)
                    {
                        let currentFacilityData = isfacilityattachmentsavailable[currentFacilityIndex]
                        let attachmentId = currentFacilityData.attachmentId
                       // print("Current AttachmentID:",attachmentId)
                        self.attachmentViewRequestingToApi.inputDataAttachmentView.attachmentId.onNext(attachmentId)
                    }
                    else if (currentFacilityIndex == isfacilityattachmentsavailable.count) && (isfacilityattachmentsavailable.count != 0)
                    {
                         Common.hideActivityIndicator()
                        if (currentState != .view)
                        {
                        b_Img_Cell?.buildingSiteImagesView.imageAttachmentList = self.attachmentImageList
                        b_Img_Cell?.buildingSiteImagesView.collectionView .reloadData()
                        }
                }
        else
        {
                        Common.hideActivityIndicator()
        }
            }
    
    
    func setLayout(){
        
        if Common.currentLanguageArabic() {

            self.view.transform = Common.arabicTransform
            self.view.toArabicTransform()
        }
        else{
            self.view.transform = Common.englishTransform
            self.view.toEnglishTransform()
        }
    }
    
    private func tableViewSetup() {
        
        tableViewHeaderSetup()
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "\(BuildingInfoCell.self)", bundle: Bundle.main), forCellReuseIdentifier: BuildingInfoCell.identifier)
        tableView.register(UINib(nibName: "\(BuildingImageDetailsCell.self)", bundle: Bundle.main), forCellReuseIdentifier: BuildingImageDetailsCell.identifier)
        tableView.register(UINib(nibName: "\(FinalReportNotesCell.self)", bundle: Bundle.main), forCellReuseIdentifier: FinalReportNotesCell.identifier)
    }
    
    private func tableViewHeaderSetup() {
        let requestHeader = SimplifiedRequestHeaderView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 0))
        
        requestHeader.houseStatusLabel.text = "simplified_report_lbl".ls
        if let report = reportDetails {
            let date = report.createdDate.serverDateFormatToNormal()
            requestHeader.houseStatusLabel.text = date//"Simplified Report - 05/09/2019"
        }
        requestHeader.addNewBuildingButton.isHidden = true
        requestHeader.backButton.addTarget(self, action: #selector(backAction(sender:)), for: .touchUpInside)
//        requestHeader.toPrint.addTarget(self, action: #selector(// printScreen(sender:)), for: .touchUpInside)
        requestHeader.toPrint.isHidden = true
        requestHeader.tag = 4000
        tableView.tableHeaderView = requestHeader
        setRequestDetailsOnView(requestView: requestHeader)
    }
    
    
    private func showCreatedValue(date:String) {
        guard let headerView = tableView.tableHeaderView as? SimplifiedRequestHeaderView else { return  }
        headerView.houseStatusLabel.text = date
    }
    
    func setRequestDetailsOnView(requestView:SimplifiedRequestHeaderView) {
        if let  details  = reportSummaryDetails {
            let infoView = RequestInfo(applicationNo: details.applicationNo, applicantID: details.applicationNo, customerName: details.customerName, lanNo: details.landNo, duraton: details.duration, areaName: details.serviceRegion, plotArea: details.servicePlotArea)
            requestView.requestSummaryView.setRequestDetails(details: infoView)
        }
        
    }
    
    func setValuesToReportOverView(summary:RequestSummary,report:InspectionReportRespose,faclities:[UserFacility],defaultFaclities:FacilityResponsePayload) {
       
        self.reportSummaryDetails = summary
        self.reportFacilityData = faclities
        self.attachmentsOverAllList = faclities.map({$0.facilityAttachmentsList}).flatMap({$0})
        var imageArray = [String]()
      
        for FacilityAttachments in self.attachmentsOverAllList
        {
            let attachmentIdString = FacilityAttachments.attachmentId
            let attachmentFaclityName = FacilityAttachments.name
            let attachmentName = "\(attachmentIdString)\(attachmentFaclityName)"
            let appBaseURL = APICommunicationURLs.baseURL
            let attachmentNameURLString = "\(appBaseURL)/img/\(attachmentName)"
            imageArray.append(attachmentNameURLString)
        }
       
        self.reportDetails = report
        self.allFacilityFields = defaultFaclities
    }
    
    
    
    
    @IBAction func nextAction(sender: UIButton) {
        
        // print(self.tableView.subviews)
        
        currentState = .final
        
        self.tableViewMoveTo(top: 0)
        
        hideViewPDFBtn(need: true)
        
    }
    @IBAction func backAction(sender: UIButton) {
        b_Info_Cell_Arr.removeAll()
        if currentState == .view {
             updateReportDataDelegate.updateReportDataSimplifiedReportController(summary: self.reportSummaryDetails, report: self.reportDetails, facilities: self.reportFacilityData, defaultFaclities: self.allFacilityFields)
            self.navigationController?.popViewController(animated: true)
            self.tableViewMoveTo(top: 0)

        } else {
            currentState = .view
            self.tableViewMoveTo(top: 0)
            hideViewPDFBtn(need: true)
            
        }
        
    }
    @IBAction func editAction(sender: UIButton) {

        currentCellTag = sender.tag
       navigateToCreateResportVC()
    }
    
    var pageImage = [UIImage]()
    var screenShotView = [UIView]()
    
    @IBAction func submitAction(sender: UIButton) {
        
        if Common.isConnectedToNetwork() == true
        {
            
            submitApiCall()
        }
        else{
            Common.showToaster(message: "no_Internet".ls )
        }
        
    }
    
    //MARK:-PDF PRINT-
    @IBAction func printScreen(sender: UIButton)
    {
            
        isPDFViewMode = true

        let scrImg = screenshot()
        pageImage .removeAll()
        pageImage.append(scrImg)
        
        isPDFViewMode = false
        b_Info_Cell.removeAll()
        
        let pdfDocument = PDFDocument()
        for (i,img) in pageImage.enumerated() {

            let pdfPage = PDFPage(image: img)
            pdfDocument.insert(pdfPage!, at: i)
        }

        //pdfDocument
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
        let path = dir?.appendingPathComponent("report.pdf")
        let data = pdfDocument.dataRepresentation()
        try! data!.write(to: path!)

        var docController:UIDocumentInteractionController!
        docController = UIDocumentInteractionController(url: path!)
        docController.delegate = self
        docController.presentPreview(animated: true)
 
 
        
    }
    
    var imgArrCTX = [UIImage]()
    var clubbedImgArr = [UIImage]()
    
    
    func hideAndShowButtonsForPDF(bool: Bool) {
        
        imgArrCTX.removeAll()
        clubbedImgArr.removeAll()
        
        let headerVw = tableView.tableHeaderView as! SimplifiedRequestHeaderView
        headerVw.toPrint.isHidden = true
        headerVw.backButton.isHidden = bool
        
        if bool {
            
            imgArrCTX.append(screenShotCell(cell: headerVw.contentView))
        }
        
        if let _ = b_Img_Cell {
            b_Img_Cell?.buildingSateliteImageView.editBtn.isHidden = bool
   
            
            let stckVwSub = b_Img_Cell?.buildingSateliteImageView.subviews[0].subviews[0]
            for subVw in stckVwSub!.subviews where subVw.tag == 1111
            {
                    for zoominOutView in subVw.subviews where zoominOutView.tag == 3333 {
                        
                      //  // print("DEL_VWWWWWW")
                        if bool {
                            zoominOutView.alpha = 0.0
                        }
                        else {
                            zoominOutView.alpha = 1.0
                        }
                    }
            }
            
            if bool {
                         
                imgArrCTX.append(screenShotCell(cell: b_Img_Cell!.contentView))
                
            }
        }

        let sortedKeys = cellImageArray.sorted(by: { $0.0 < $1.0 })
           if bool {
            for(_,cellImage) in sortedKeys{
                       imgArrCTX.append(cellImage)
                   }
               }
        
       for (_,cell) in b_Info_Cell {
            cell?.nextButton.isHidden = bool
            cell?.backButton.isHidden = bool
            cell?.buildingInfoView.editButton.isHidden = bool
            cell?.buildingInfoView.viewAttachedPhotosBtn.isHidden = bool

        }

        if let _ = f_Report_Cell {
            f_Report_Cell?.submitButton.isHidden = bool
            f_Report_Cell?.backButton.isHidden = bool
            f_Report_Cell?.generatePdfButton.isHidden =  bool
            
            if bool {
                
                imgArrCTX.append(screenShotCell(cell: f_Report_Cell!.contentView))
            }
        }
        
        var totalHeight = CGFloat()
        let holderView = UIView()
        for i in 0..<imgArrCTX.count {
            
            holderView.frame = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: imgArrCTX[i].size.height + 10)
            
            let imageView = UIImageView(image: imgArrCTX[i])
            imageView.frame = CGRect(x: 0, y: totalHeight, width: tableView.frame.size.width, height: imgArrCTX[i].size.height)
              
            imageView.tag = 444
            imageView.contentMode = .scaleAspectFit
            imageView.backgroundColor = .clear
            
            if Common.currentLanguageArabic() && i != 1 {
                imageView.transform = Common.arabicTransform

            }

            holderView.addSubview(imageView)
            
          //  // print("BEFOR____totalHeight   ", totalHeight)
            totalHeight = totalHeight + imgArrCTX[i].size.height + 10
            holderView.frame.size.height = totalHeight
          //  // print("Outside___totalHeight   ", totalHeight)
            
            if i % 2 == 1 {
                clubbedImgArr.append(screenShotCell(cell: holderView))
                totalHeight = 0
                
                holderView.frame.size.height = 0
                
                for subVws in holderView.subviews {
                    
                    if subVws.tag == 444 {
                        subVws.removeFromSuperview()
                    }
                }
                
            } else {
                
                if i == imgArrCTX.count - 1 {
                    
                    clubbedImgArr.append(screenShotCell(cell: holderView))

                }
                
            }
        }
    }
    
    //MARK:-UIDOCUMENTINTERACTION DELEGATE-
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        
        return self
    }
    
    //MARK:-ALPHA VALUE CHANGE-
    
    func hideViewPDFBtn(need: Bool) {
        
        for subVw in self.tableView.subviews where subVw.tag == 4000 { //SimplifiedRequestHeaderView
            
            for subv in subVw.subviews {
                
                let viewPdfBtn = getTopHeaderBackButton(whichView: subv.subviews, tagVal: 2999)
                
                viewPdfBtn.isHidden = need
                
            }
        }
    }
    
    
    func getTopHeaderBackButton(whichView: [UIView], tagVal : Int) -> UIView {
        
        let subVw = whichView.filter { (myVw) -> Bool in
            
            if myVw.tag == tagVal {
                return true
            }
            return false
        }
        return subVw[0]
    }
    
    //MARK:-TAKE VIEW SCREENSHOT-
    
    func screenShotCell(cell: UIView) -> UIImage {
        var image = UIImage()

            UIGraphicsBeginImageContextWithOptions(cell.frame.size, false, 0)
            cell.layer.render(in: UIGraphicsGetCurrentContext()!)
            image = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
        return image
    }
    
    
    func screenshot() -> UIImage{
        var image = UIImage();
        
        
        UIGraphicsBeginImageContextWithOptions(self.tableView.contentSize, false, 1)

        let savedContentOffset = self.tableView.contentOffset;
        let savedFrame = self.tableView.frame;
        let savedBackgroundColor = self.tableView.backgroundColor

        self.tableView.contentOffset = CGPoint(x: tableView.contentOffset.x, y: tableView.contentOffset.y);
        self.tableView.frame = CGRect(x: 0, y: 0, width: self.tableView.contentSize.width, height: self.tableView.contentSize.height);
        self.tableView.backgroundColor = UIColor.clear
        
        self.tableView.layer.render(in: UIGraphicsGetCurrentContext()!)
        image = UIGraphicsGetImageFromCurrentImageContext()!;

        self.tableView.contentOffset = savedContentOffset;
        self.tableView.frame = savedFrame;
        self.tableView.backgroundColor = savedBackgroundColor

        // print("Saved Content Offset:",savedContentOffset)
        // print("Saved Frame:",savedFrame)
        UIGraphicsEndImageContext();

        return image
    }
    
    func navigateToCreateResportVC() {
        
        guard let requestDetails = reportSummaryDetails else { return }
        if let createReportVC = self.storyboard?.instantiateViewController(withIdentifier: "CreateSimplifiedReportController") as? CreateSimplifiedReportController {
            createReportVC.currentCellTag = currentCellTag
            createReportVC.buildingInfoDelegate = self
            createReportVC.requestDetails = requestDetails
            createReportVC.reportDetails = reportDetails
            createReportVC.currentStatus = .editFromReport
            createReportVC.requestObject = requestObject
            self.navigationController?.pushViewController(createReportVC, animated: true)
        }
        
    }
    
    func submitApiCall() {
        
        guard let report = reportDetails else { return  }
        let dashBoard = ReportInputDetails()
        dashBoard.applicantId = report.applicantId
        dashBoard.applicationNo = report.applicationNumber
        dashBoard.serviceTypeId = reportDetails.serviceTypeId
        
        Common.showActivityIndicator()
        viewModel.input.submitReport.onNext(dashBoard)
        viewModel.output.submitResponseResultObservable.subscribe { [weak self](response) in
            Common.hideActivityIndicator()
            
            if let value = response.element,value.success == true {
                DispatchQueue.main.async {
                     let topVc = UIApplication.topViewController()
                    // print(topVc as Any)
                    
                    self?.presentPopUpView(type: .Success)
                }
            }
        }.disposed(by: disposeBag)
    }
    
    func addGestureToView(view: UIView,name:String) {
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        view.isUserInteractionEnabled = true
        tap.name = name
        view.addGestureRecognizer(tap)
    }
    
    func tableViewMoveTo(top:CGFloat) {
        
        UIView.animate (withDuration: 0.1, animations: {
            var value:CGPoint = .zero
            if top > 0 {
                value = CGPoint(x: self.tableView.contentOffset.x, y: value.y)
            }
            self.tableView.contentOffset = value
        }) {(_) in
            self.tableView.reloadData ()
        }

        
    }
    
    @IBAction func viewAttachedPhotosBtn(sender: UIButton) {
        
        cellTag = sender.tag
        self.attachmentFaclitiesList = reportFacilityData[sender.tag].facilityAttachmentsList
        
        guard let attchement = attachmentFaclitiesList else {
            return
        }
        if attchement.count > 0 {
            presentPopUpViewForPhoto(type: .Photo,photoCount:self.attachmentFaclitiesList.count, facilitiesAttachmentList: self.attachmentFaclitiesList)
        }
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        
        if let tagView = sender?.view {
            self.attachmentFaclitiesList = reportFacilityData[tagView.tag].facilityAttachmentsList
        }
        if sender?.name == "satellite" {
            presentPopUpView(type: .Satellite)
        } else {
            
            guard let attchement = attachmentFaclitiesList else {return}
            if attchement.count > 0 {
                presentPopUpViewForPhoto(type: .Photo,photoCount:self.attachmentFaclitiesList.count, facilitiesAttachmentList: self.attachmentFaclitiesList)
                
            }
        }
    }
    
    private func presentPopUpView(type:PopUpType)
    {
        guard let popVc = self.storyboard?.instantiateViewController(withIdentifier: "SimplifiedReportPopController") as? SimplifiedReportPopController else { return }
        popVc.delegate = self
        popVc.modalPresentationStyle = .overCurrentContext
        popVc.modalTransitionStyle = .crossDissolve
        popVc.type = type
        let rootVC = UIApplication.shared.keyWindow!.rootViewController
        rootVC?.present(popVc, animated: true, completion: nil)
    }
    
    private func presentPopUpViewForPhoto(type:PopUpType,photoCount: Int, facilitiesAttachmentList:[FacilityAttachments]) {
        
        guard let popVc = self.storyboard?.instantiateViewController(withIdentifier: "SimplifiedReportPopController") as? SimplifiedReportPopController else { return }
        popVc.delegate = self
        popVc.modalPresentationStyle = .overCurrentContext
        popVc.modalTransitionStyle = .crossDissolve
        popVc.type = type
        popVc.totalPhotosCount = photoCount
        popVc.attachmentFaclitiesList = facilitiesAttachmentList
        popVc.imageAttachmentList = attachmentImageList
        popVc.delegateForRefreshAttachment = self
        popVc.currentCellTag = cellTag
        popVc.popupFrom = .Report
        let rootVC = UIApplication.shared.keyWindow!.rootViewController
        rootVC?.present(popVc, animated: true, completion: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    var ctxImage = [Int : UIImage]()
}

extension SimplifiedReportDetailsViewController: RefreshDelegateFromSimplifiedReport
{
    func refreshPageAfterDeleteAttachmentFromReport(currentCellTag: Int, attachmentIndex: Int) {
        
        let removingAttachmentId = self.reportFacilityData[cellTag].facilityAttachmentsList[attachmentIndex].attachmentId
        
        let index = self.attachmentsOverAllList.firstIndex(where: {$0.attachmentId == removingAttachmentId})

        self.reportFacilityData[cellTag].facilityAttachmentsList.remove(at: attachmentIndex)
        self.attachmentsOverAllList.remove(at: index!)
        
        if  (self.attachmentImageList.count>0) {
                                  if let isAttachmentAvailable = self.attachmentImageList.filter({$0.attachmentId == removingAttachmentId}).first{
                                                     let index = self.attachmentImageList.firstIndex(where: {$0.attachmentId == removingAttachmentId})
                                                     self.attachmentImageList.remove(at: index!)
                                                 }
                              }
        
        self.deleteImage = true
      //  // print(self.attachmentsOverAllList)
        self.tableView.reloadData()
        
        self.delegateFromImages.deleteImagesFromReportScreenToCreateReportScreen()
    }
    
    

}

extension SimplifiedReportDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let data = reportFacilityData else { return 0 }
        
        return currentState == .view ? data.count : data.count + 2
        
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if currentState == .view {
         
            return getBuildingDetailsCell(tableView, cellForRowAt: indexPath)
        }
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: BuildingImageDetailsCell.identifier, for: indexPath) as? BuildingImageDetailsCell else {
                return UITableViewCell()
            }
            b_Img_Cell = cell
            cell.reqObj = requestObject
            cell.buildingSateliteImageView.requestObject = requestObject
            cell.buildingSateliteImageView.editBtn.addTarget(self, action: #selector(self.editButtonTappedInSection), for: .touchUpInside)
            cell.buildingSateliteImageView.getValue(satellitePayload: self.satellitePayload, reqObj: requestObject)
           // cell.buildingSateliteImageView.zoomInOutView.isHidden = true
            cell.buildingSiteImagesView.imagePdfGenerate_Btn.addTarget(self, action: #selector(self.imagePdfButtonClick), for: .touchUpInside)
            
            cell.borderWithCornerRadius(cornerRadius: 10, color: .clear)
            cell.buildingSiteImagesView.attachmentFaclitiesList = self.attachmentsOverAllList
            cell.buildingSiteImagesView.imageAttachmentList = self.attachmentImageList

            cell.buildingSiteImagesView.setAttachmentViews()
            
            if deleteImage == true {
                cell.buildingSiteImagesView.collectionViewReload()
            }
            
            return cell
        }
        else if indexPath.row == reportFacilityData.count + 1 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: FinalReportNotesCell.identifier, for: indexPath) as? FinalReportNotesCell else { return UITableViewCell() }
            cell.borderWithCornerRadius(cornerRadius: 10, color: .clear)
            cell.setReportDetails(details: reportDetails, expansions: allFacilityFields.expansions,houseStatus: allFacilityFields.houseStatus)
            f_Report_Cell = cell
            
            cell.generatePdfButton.addTarget(self, action: #selector(self.generatePdfAction), for: .touchUpInside)
            
            if let reportObj = reportDetails, reportDetails.inspectionReportId.count > 0 {
                let actionID = Int(reportObj.actionId) ?? 0
                let actionObject = allFacilityFields.facilityPayload.facilityActions.filter({$0.fActionId == actionID }).first
              //  cell.recommendationLabel.text = "Selected Value: \(actionObject?.actionName() ?? "")"
                cell.recommendationTitleLabel.text = "recommendation_lbl".ls + " :  \(actionObject?.actionName() ?? "")"
            }
            
            cell.submitButton.addTarget(self, action: #selector(submitAction(sender:)), for: .touchUpInside)
            cell.backButton.addTarget(self, action: #selector(backAction(sender:)), for: .touchUpInside)
            
            return cell
        }
        
       
        return getBuildingDetailsCell(tableView, cellForRowAt: IndexPath(row: indexPath.row - 1, section: indexPath.section))
        
    }
    
    
    

    //MARK: - UIButton Action

      @objc func generatePdfAction(sender : UIButton){
        
        isPDFViewMode = true
        
        
        let pdfDocument = PDFDocument()
        for (i,img) in clubbedImgArr.enumerated() {
            let pdfPage = PDFPage(image: img)
            pdfDocument.insert(pdfPage!, at: i)
        }
        
        isPDFViewMode = false
        //b_Info_Cell_Arr .removeAll()
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
        let path = dir?.appendingPathComponent("report.pdf")
        let data = pdfDocument.dataRepresentation()
        try! data!.write(to: path!)
        
        
        var docController:UIDocumentInteractionController!
        docController = UIDocumentInteractionController(url: path!)
        docController.delegate = self
        docController.presentPreview(animated: true)
        

    }
    
    
    
    @objc func imagePdfButtonClick(sender : UIButton){
        
    
        var scrollView: UIScrollView!
        scrollView = UIScrollView(frame: CGRect(x: 100, y: 0, width: self.view.frame.size.width-100, height: self.view.frame.size.height))
        scrollView.backgroundColor = UIColor.green
    
        var yPos : CGFloat = 10
        
        for imgs in finalImageData
        {
            let imagVw = UIImageView(frame: CGRect(x: 50, y: yPos, width: 700, height: 400))
            imagVw.image = imgs
            yPos = yPos + 440
            
            scrollView.addSubview(imagVw)

        }
        
        scrollView.contentSize = CGSize(width: 700, height: yPos)
        let topVC = UIApplication.topViewController()?.view

        topVC?.addSubview(scrollView)
        
    }
    
    // MARK:- EDIT POLYGON
    @objc func editButtonTappedInSection(sender : UIButton) {
        
        let satelliteVC = self.storyboard?.instantiateViewController(withIdentifier: "AddSatellitePhotoController") as! AddSatellitePhotoController
        satelliteVC.requestObject = requestObject
        self.parent?.navigationController?.pushViewController(satelliteVC, animated: true)
        
    }
    
    func getBuildingDetailsCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BuildingInfoCell.identifier, for: indexPath) as? BuildingInfoCell else { return UITableViewCell()}
        cell.footerView.isHidden = false
        cell.nextButton.addTarget(self, action: #selector(nextAction(sender:)), for: .touchUpInside)
        cell.backButton.addTarget(self, action: #selector(backAction(sender:)), for: .touchUpInside)
        
        cell.tag = 40000 + indexPath.row
        

        
        cell.buildingInfoView.editButton.addTarget(self, action: #selector(editAction(sender:)), for: .touchUpInside)
        
        cell.buildingInfoView.editButton.tag = indexPath.row
        
        addGestureToView(view: cell.buildingInfoView.noOfSatellitePhotosLabel, name: "satellite")
        addGestureToView(view: cell.buildingInfoView.noOfPhotosLabel, name: "photo")
        cell.buildingInfoView.noOfPhotosLabel.tag = indexPath.row
        
        cell.buildingInfoView.noOfPhotosLabel.isHidden = true
        
        if let availableData = reportFacilityData
        {
            if (indexPath.row < reportFacilityData.count){
        self.attachmentFaclitiesList = reportFacilityData[indexPath.row].facilityAttachmentsList
        if self.attachmentFaclitiesList.count > 0 {
            cell.buildingInfoView.viewAttachedPhotosBtn.alpha = 1
        }else
        {
            cell.buildingInfoView.viewAttachedPhotosBtn.alpha = 0
        }}
        }
        cell.buildingInfoView.viewAttachedPhotosBtn.tag = indexPath.row
        cell.buildingInfoView.viewAttachedPhotosBtn.addTarget(self, action: #selector(viewAttachedPhotosBtn(sender:)), for: .touchUpInside)
        

        
        guard let data = reportFacilityData else { return cell }
        if currentState == .view && indexPath.row == data.count - 1 {
            cell.footerView.isHidden = false
        } else {
            cell.footerView.isHidden = true
        }
        if indexPath.row < data.count {
            cell.setBuildingDetails(details: data[indexPath.row], defaultFacilies: allFacilityFields)
        }
        
        cell.buildingInfoView.editButton.isHidden = false
        cell.buildingInfoView.viewAttachedPhotosBtn.isHidden = false
        
        if currentState == .final {
            
            if b_Info_Cell.count == reportFacilityData.count {
                
            }
            else {
                if let _ = b_Info_Cell[cell.tag] {
                    // print("key already_present    ")
                }
                else {
                    // print("New_key already_present    ")
                    b_Info_Cell[cell.tag] = cell
                    cell.buildingInfoView.editButton.isHidden = true
                    cell.buildingInfoView.viewAttachedPhotosBtn.isHidden = true
                    cellImageArray[cell.tag] = screenShotCell(cell: cell.contentView)
                    
                }
            }
            
        }

        return cell
    }
    
    
}


extension SimplifiedReportDetailsViewController: PoupDelegate {
    func continueAction() {
        if let parentVC = self.parent {
            parentVC.remove()
        }
    }
    }

extension UITableView {
    
    // Export pdf from UITableView and save pdf in drectory and return pdf file path
    func exportAsPdfFromTable() -> String {
        
        let originalBounds = self.bounds
        self.bounds = CGRect(x:originalBounds.origin.x, y: originalBounds.origin.y, width: self.contentSize.width, height: self.contentSize.height)
        let pdfPageFrame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.contentSize.height)
        
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, pdfPageFrame, nil)
        UIGraphicsBeginPDFPageWithInfo(pdfPageFrame, nil)
        guard let pdfContext = UIGraphicsGetCurrentContext() else { return "" }
        self.layer.render(in: pdfContext)
        UIGraphicsEndPDFContext()
        self.bounds = originalBounds
        // Save pdf data
        return self.saveTablePdf(data: pdfData)
        
    }
    
    // Save pdf file in document directory
    func saveTablePdf(data: NSMutableData) -> String {
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docDirectoryPath = paths[0]
        let pdfPath = docDirectoryPath.appendingPathComponent("report.pdf")
        if data.write(to: pdfPath, atomically: true) {
            return pdfPath.path
        } else {
            return ""
        }
    }
}


extension SimplifiedReportDetailsViewController:ReportDataDelegate
   {
     func shareReportDataInfo  (summary:RequestSummary,report:InspectionReportRespose,faclities:[UserFacility],defaultFaclities:FacilityResponsePayload){
               self.reportSummaryDetails = summary
               self.reportFacilityData = faclities
               self.attachmentsOverAllList = faclities.map({$0.facilityAttachmentsList}).flatMap({$0})
               self.reportDetails = report
               self.allFacilityFields = defaultFaclities
       
   }
}
