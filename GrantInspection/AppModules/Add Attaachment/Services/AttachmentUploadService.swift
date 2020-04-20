//
//  AttachmentUploadService.swift
//  GrantInspection
//
//  Created by Mohammed Hassan on 22/09/19.
//  Copyright © 2019 MBRHE. All rights reserved.
//

import UIKit
import RxSwift

protocol RequestAttachmentServiceProtocol {
    
    
    func getAttachedRequestSummary(parmas:AttachmentUploadModel) -> Observable<RequestAttachmentsModel>
    
}



class AttachmentUploadService: RequestAttachmentServiceProtocol {
    
    var modelDelegate  : modelDelegate!
    
    var imageRawData : Data!
    
    func getAttachedRequestSummary(parmas: AttachmentUploadModel) -> Observable<RequestAttachmentsModel> {
        
        return Observable.create { observer in
            
            let urlToHit = APICommunicationURLs.uploadedAttachmentsFiles()
            
            self.imageRawData = parmas.file
            
            let service = OLUploadAttachmentsService()
            let dataDict : [String : AnyObject]!
            let fileName  : String = "Attachment-" + Common.randomString(length: 5) + ".JPEG"
            dataDict = [
                "facilityId":"\(parmas.facilityId)",
                "remarks":"\(parmas.remarks)",
                "attachmentTypeId":"\(parmas.attachmentTypeId)",
                "inspectionReportId":"\(parmas.inspectionReportId)",
                fileName: self.imageRawData,
                ] as [String : AnyObject]
            
           
                service.uploadedAttachmentFiles(dataDict: dataDict, url: urlToHit, completion: { (baseResposne : RequestAttachmentsModel?) in
                Common.hideActivityIndicator()
                guard let response = baseResposne else {
                    let error = NSError(domain: "the_request_timed_out".ls, code:0, userInfo: nil)
                    observer.onError(error)
                    return
                }
                if response.message.trimmingCharacters(in: .whitespaces).count == 0 {
                    let error = NSError(domain: "the_request_timed_out".ls, code:0, userInfo: nil)
                    observer.onError(error)
                    return
                }

                if response.success {
                    observer.onNext(response)
                }else{
                    if response.message.isEmpty{
                        Common.showToaster(message: "error_InvalidJson".ls )
                    }else {
                        Common.showToaster(message: response.message )
                    }
                }
                
            })
            
            return Disposables.create()
        }
        
        
    }
   
}


