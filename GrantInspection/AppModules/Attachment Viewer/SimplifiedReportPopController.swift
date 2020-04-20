//
//  SimplifiedReportPopController.swift
//  GrantInspection
//
//  Created by Rajeswaran Thangaperumal on 05/09/2019.
//  Copyright © 2019 MBRHE. All rights reserved.
//

import UIKit
import RxSwift
import PDFKit



enum PopUpType {
    case Success
    case Failure
    case Satellite
    case Photo
    case Empty
}

enum PopUpAction {
    case Edit
    case Report
    case OverAllImageList
    case Nothing
    
}

protocol PoupDelegate {
    func continueAction()
}

protocol AttachmentRefreshAction {
    func refreshAttachmentFromOverAllList(imageIndex:Int)
}

protocol ImageRefreshDelegate {
    func refreshPageAfterDeleteAttachment(currentCellTag:Int, attachmentIndex:Int)
}

protocol RefreshDelegateFromSimplifiedReport {
    func refreshPageAfterDeleteAttachmentFromReport(currentCellTag:Int, attachmentIndex:Int)
}


//protocol DashBoardDelegate{
//    func
//}
class SimplifiedReportPopController: UIViewController , UIDocumentInteractionControllerDelegate{
    
    @IBOutlet weak var imgPdfButton: MBRHERoundButtonView!
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var satellitePhotoView: UIView!
    @IBOutlet weak var photoView: UIView!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var reportStatusLabel: UILabel!
    @IBOutlet weak var imageDeleteButton: MBRHERoundButtonView!
    
    @IBOutlet weak var continueButton: MBRHERoundButtonView!
   
    var type:PopUpType = .Empty
    var popupFrom:PopUpAction = .Nothing
    var delegate: PoupDelegate!
    var delegateForRefresh: ImageRefreshDelegate!
    var delegateForRefreshAttachment: RefreshDelegateFromSimplifiedReport!
    var delegateForAttachmentOverAll:AttachmentRefreshAction!
    
  
    var attachmentViewRequestingToApi:AttachmentViewModule!
    var attachmentFaclitiesList :[FacilityAttachments]!
    var imageAttachmentList : [AttachmentViewResponseDetails]!

    var photoImgCell : BuildingPhotoDetailsCell?
    
    var dashboardInstance : DashboardViewController?
    
    var deletedPopupView = DeleteAttachmentFilesView()
    
    var currentCellTag = 0
    
    private let disposeBag = DisposeBag()
    
    var totalPhotosCount :Int = 0
    var indexPathItemNumber : Int = 0
    
    @IBOutlet weak var rightArrowBtn: UIButton!
    @IBOutlet weak var leftArrowBtn: UIButton!
    @IBOutlet weak var photosPageCountLbl: UILabel!
    
    var responseAttachmentViewPayload:AttachmentViewResponsePayload!
    var responseAttachmentViewResponse:AttachmentViewResponseDetails!
    var attachmentDownloaded = AttachmentImageDownload()
    var imageCache = NSCache<AnyObject, AnyObject>()
    var imageInt:Int = 0

    var currentImageData = UIImage()
    
    var attachmentDeleteModuleRequestToAPI:AttachmentDeleteModule!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.navySemitransperent()
        view.isOpaque = false
        registerCells()
      //  currentImageData
        setUIBasedOnState(type: type)
        continueButton.setTitle("continue_btn".ls, for: .normal)
        reportStatusLabel.text = "report_Submitted_sucessfully_lbl".ls
        if (popupFrom == .OverAllImageList){
                   indexPathItemNumber = imageInt
                   Common.showActivityIndicator()
                   loadImagefromCollectionView(indexPathItem: imageInt, scrollPosition: UICollectionView.ScrollPosition.right)
                   DispatchQueue.main.async {
                       self.moveCollectionToFrame()
                   }
               }
              else if  (type == .Photo){
            attachmentViewRequestingToApi = AttachmentViewModule(AttachmentViewService())
            Common.showActivityIndicator()
            loadImageFromApiCall(indexPathItem: imageInt, scrollPosition: UICollectionView.ScrollPosition.right)
        }
        
        self.photosPageCountLbl.isHidden = true
        
        if self.totalPhotosCount > 0 {
            
            self.photosPageCountLbl.isHidden = false
            self.photosPageCountLbl.text = "1 / \(self.totalPhotosCount) " + " photos".ls
            
            self.leftArrowBtn.isEnabled = true
            
            
        }
    
        attachmentDeleteModuleRequestToAPI = AttachmentDeleteModule(AttachmentDeleteService())
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        closeButton.makeCircel()

    }
    func dismiss() {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    private func registerCells() {
        photoCollectionView.register(UINib(nibName: "\(BuildingPhotoDetailsCell.self)", bundle: Bundle.main), forCellWithReuseIdentifier: BuildingPhotoDetailsCell.identifier)
        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
        photoCollectionView.isScrollEnabled = false
    }
    
    private func setUIBasedOnState(type:PopUpType) {
        switch type {
        case .Empty:
            alertView.isHidden = true
            satellitePhotoView.isHidden = true
            photoView.isHidden = true
            closeButton.isHidden = true
        case .Success,.Failure :
            alertView.isHidden = false
            satellitePhotoView.isHidden = true
            photoView.isHidden = true
            closeButton.isHidden = true
        case .Photo:
            alertView.isHidden = true
            satellitePhotoView.isHidden = true
            photoView.isHidden = false
            closeButton.isHidden = false
        case .Satellite:
            alertView.isHidden = true
            satellitePhotoView.isHidden = false
            photoView.isHidden = true
            closeButton.isHidden = false
        }
    }
    
    //MARK: - UIButton Action
    @IBAction func continueAction(sender: UIButton) {
        dismiss()
        if let _ = delegate {
            SharedResources.sharedInstance.isRefreshNeeded = true
            NotificationCenter.default.post(name: Notification.Name("dashboardRefreshApi"), object: nil)
            delegate.continueAction()

        }
       
    }
    
    @IBAction func closeAction(_ sender: UIButton) {
        dismiss()
    }
    
    @IBAction func leftArrowAction(_ sender: UIButton) {
        

        indexPathItemNumber = indexPathItemNumber - 1


        if(popupFrom == .OverAllImageList){
                           loadImagefromCollectionView(indexPathItem: indexPathItemNumber, scrollPosition: UICollectionView.ScrollPosition.right)
                      }
                      else{
                          loadImageFromApiCall(indexPathItem: indexPathItemNumber, scrollPosition: UICollectionView.ScrollPosition.right)
                      }
        
      
    }
    
   
    
    @IBAction func rightArrowAction(_ sender: UIButton) {

        indexPathItemNumber = indexPathItemNumber+1
        
        if(popupFrom == .OverAllImageList){
                    loadImagefromCollectionView(indexPathItem: indexPathItemNumber, scrollPosition: UICollectionView.ScrollPosition.right)
               }
               else{
                   loadImageFromApiCall(indexPathItem: indexPathItemNumber, scrollPosition: UICollectionView.ScrollPosition.right)
               }

    }
    
    func loadImageFromApiCall(indexPathItem:Int,scrollPosition:UICollectionView.ScrollPosition)  {
        
        let indexPathInt = indexPathItem + 1
        
        if indexPathItem >= 0 && self.attachmentFaclitiesList.count >= indexPathInt  {
            let attachmentId:String = attachmentFaclitiesList[indexPathItem].attachmentId
            attachmentViewRequestingToApi.inputDataAttachmentView.attachmentId.onNext(attachmentId)
            attachmentViewRequestingToApi.outputDataAttachmentView.attachmentrequestSummaryResultObservable.subscribe{[weak self](response) in
                Common.hideActivityIndicator()
                if let value = response.element,value.success == true {
                    self?.responseAttachmentViewPayload = value.payload
                    self?.responseAttachmentViewResponse = self?.responseAttachmentViewPayload.viewAttachmentPayload
                    self?.photoCollectionView .reloadData()
                    self!.photoCollectionView.scrollToItem(at: IndexPath(item:indexPathItem, section: 0), at:scrollPosition, animated: true)
                    
                }
                
                }.disposed(by: disposeBag)
        }
            }
    
    func loadImagefromCollectionView(indexPathItem:Int,scrollPosition:UICollectionView.ScrollPosition){
           let indexPathInt = indexPathItem
                   self.responseAttachmentViewResponse = imageAttachmentList[indexPathInt]
                   self.photoCollectionView .reloadData()
                   self.photoCollectionView.scrollToItem(at: IndexPath(item:indexPathItem, section: 0), at:scrollPosition, animated: true)
       }
    
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    func moveCollectionToFrame() {

        if totalPhotosCount == 1
        {
            rightArrowBtn.isEnabled = false
            leftArrowBtn.isEnabled = false
            return
        }
        
      if indexPathItemNumber >= (totalPhotosCount - 1) {
            
            rightArrowBtn.isEnabled = false
            leftArrowBtn.isEnabled = true
        }
        else if indexPathItemNumber <= 0 {
            rightArrowBtn.isEnabled = true
            leftArrowBtn.isEnabled = false
        }
        else {
            rightArrowBtn.isEnabled = true
            leftArrowBtn.isEnabled = true
        }
        
        photosPageCountLbl.text = "\(indexPathItemNumber + 1) / \(totalPhotosCount) " + "photos".ls
    }
}

extension SimplifiedReportPopController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       // print ("Total Attachments Available",self.attachmentFaclitiesList.count)
       if(popupFrom == .OverAllImageList){
            guard let data = self.imageAttachmentList else { return 0 }
            return data.count
        }
        else{
            guard let data = self.attachmentFaclitiesList else { return 0 }
            return data.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BuildingPhotoDetailsCell.identifier, for: indexPath) as? BuildingPhotoDetailsCell else { return UICollectionViewCell() }
        
        cell.photoThumbImgView.image = nil
        cell.photoCommentsLabel.text = ""
        cell.pdfGenerateBtn.addTarget(self, action: #selector(self.generateImagePdf), for: .touchUpInside)
        self.imgPdfButton.isHidden = true
        self.imageDeleteButton.isHidden = true
        
        if let imageDataResponse = self.responseAttachmentViewResponse
        {
            cell.photoCommentsLabel.text = imageDataResponse.remarks
            let urlAttachmentString = imageDataResponse.url
            cell.photoThumbImgView.tag = indexPath.row
            
            let replacedUrlAttachmentString = urlAttachmentString.replacingOccurrences(of: "'\'", with: "")

            if let imageFromCache = imageCache.object(forKey: replacedUrlAttachmentString as AnyObject) as? UIImage
            {
                cell.photoThumbImgView.image = imageFromCache
                self.imgPdfButton.isHidden = false
                self.imageDeleteButton.isHidden = false
                self.currentImageData = imageFromCache
                self.photoImgCell = cell
                
            }else
            {
                               
                attachmentDownloaded.downloadImageAttachment(attachmentUrlString: replacedUrlAttachmentString, fromCollectionCell: false) { (image) in
                    
                    self.imageCache.setObject(image, forKey: replacedUrlAttachmentString as AnyObject)
                    cell.photoThumbImgView.image = image
                 //   cell.pdfGenerateBtn.isHidden = false
                    self.currentImageData = image
                    self.imgPdfButton.isHidden = false
                    self.imageDeleteButton.isHidden = false
                    self.photoImgCell = cell
                    
                }
            }
    
        }
        cell.photoViewCountLbl.isHidden = true
        return cell
    }
    
    //MARK: UIButton Action
    @IBAction func deleteAttachmentFromFaclity(sender : UIButton)
    {

        deletedPopupView = UINib(nibName: "DeleteAttachmentFilesView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! DeleteAttachmentFilesView
        deletedPopupView.deleteButton.tag = indexPathItemNumber
       deletedPopupView.deleteButton.addTarget(self, action: #selector(deleteAttachmentAction), for: .touchUpInside)
       deletedPopupView.cancelButton.addTarget(self, action: #selector(cancelAttachmentAction), for: .touchUpInside)
        
        deletedPopupView.deleteButton.setTitle("yes_lbl".ls, for: .normal)
        deletedPopupView.cancelButton.setTitle("no_lbl".ls, for: .normal)
        deletedPopupView.titleLabelForDelete.text = "are_you_sure_want￼_delete_attachment_lbl".ls
        
        deletedPopupView.popupView.layer.cornerRadius = 10.0
        deletedPopupView.popupView.layer.masksToBounds = true
        
        
        deletedPopupView.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            
            self.deletedPopupView.frame = UIScreen.main.bounds
            self.deletedPopupView.alpha = 1
            self.view.addSubview(self.deletedPopupView)
            
            
        }, completion: nil)
    }
    
    @objc func cancelAttachmentAction() {
           
           UIView.animate(withDuration: 0.5, animations: {
               self.deletedPopupView.alpha = 0.0
           }) { (completion) in
               self.deletedPopupView .removeFromSuperview()
           }
       }
    
    @objc func deleteAttachmentAction()
    {
        print(indexPathItemNumber)
        
        var attachmentIDString:String
         if(popupFrom == .OverAllImageList)
         {
            attachmentIDString = self.imageAttachmentList[indexPathItemNumber].attachmentId }
        else
         {
             attachmentIDString = self.attachmentFaclitiesList[indexPathItemNumber].attachmentId
        }
        
        Common.showActivityIndicator()
        
        
        self.cancelAttachmentAction()
        
        attachmentDeleteModuleRequestToAPI.inputAttachmentDelete.attachmentIdInput.onNext(attachmentIDString)
        
        attachmentDeleteModuleRequestToAPI.outputAttachmentDelete.attachmentDeleteSummaryResultObservable.subscribe{[weak self](response) in
            Common.hideActivityIndicator()
            if let value = response.element,value.success == true {
                
                if let imageUrlData = self?.imageAttachmentList {
                                   if let isAttachmentAvailable = imageUrlData.filter({$0.attachmentId == attachmentIDString}).first{
                                                      let index = self?.imageAttachmentList.firstIndex(where: {$0.attachmentId == attachmentIDString})
                                                      self?.imageAttachmentList.remove(at: index!)
                                                  }
                               }
                
                
                self?.dismiss()
                if self?.popupFrom == .Edit {
                    self?.delegateForRefresh?.refreshPageAfterDeleteAttachment(currentCellTag: self!.currentCellTag, attachmentIndex: self!.indexPathItemNumber)
                }
                else if self?.popupFrom == .Report
                {
                    self?.delegateForRefreshAttachment.refreshPageAfterDeleteAttachmentFromReport(currentCellTag: self!.currentCellTag, attachmentIndex: self!.indexPathItemNumber)
                }else if self?.popupFrom == .OverAllImageList
                {
                    print(self!.currentCellTag)
                    print(self!.indexPathItemNumber)
                    self?.delegateForAttachmentOverAll.refreshAttachmentFromOverAllList(imageIndex: self!.imageInt)

                }
                
            }
            
        }.disposed(by: disposeBag)
   
    }
    
    
    @IBAction func generateImagePdf(sender : UIButton) {

                      let pdfDocument = PDFDocument()

        let pdfPage = PDFPage(image: self.currentImageData)
                        pdfDocument.insert(pdfPage!,at: 0)
                      let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
                      let path = dir?.appendingPathComponent("Building Attachment.pdf")
                      let data = pdfDocument.dataRepresentation()
                      try! data!.write(to: path!)
                      var docController:UIDocumentInteractionController!
                      docController = UIDocumentInteractionController(url: path!)
                      docController.delegate = self
                      docController.presentPreview(animated: true)
        
    }
    
    func screenshot() -> UIImage{
               var image = UIImage();
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 768,height: 1024), false, UIScreen.main.scale)
                photoImgCell?.photoThumbImgView.layer.render(in: UIGraphicsGetCurrentContext()!)
               image = UIGraphicsGetImageFromCurrentImageContext()!;
               UIGraphicsEndImageContext();
               return image
        
           }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let indPath = collectionView.indexPath(for: collectionView.visibleCells[0])
        indexPathItemNumber = indPath!.item
        moveCollectionToFrame()
    }
}




extension SimplifiedReportPopController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width , height: collectionView.frame.size.height)
        
    }
    
}

extension SimplifiedReportPopController : UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    }
}
