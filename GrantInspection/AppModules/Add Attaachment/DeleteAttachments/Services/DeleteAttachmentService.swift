//
//  DeleteAttachmentService.swift
//  GrantInspection
//
//  Created by Mohammed Hassan on 14/11/19.
//  Copyright © 2019 MBRHE. All rights reserved.
//

import UIKit
import RxSwift

protocol DeleteAttachmentRequestProtocol {
    
    func deleteAttachmentRequestService(attachmentId:String) -> Observable<BaseResponseForModels>
}

class AttachmentDeleteService: DeleteAttachmentRequestProtocol {
    
    func deleteAttachmentRequestService(attachmentId: String) -> Observable<BaseResponseForModels>{
        return Observable.create{ observer in
            
            let apiCommunication = APICommunication()
            let urlToHit = APICommunicationURLs.deleteAttachmentFromTheFacility(attachmentId: attachmentId)
            
            apiCommunication.dataInStringFromURL(url: urlToHit, requestType: .delete, completion: { (response) in

                var attachmentDeleteResponse: BaseResponseForModels? = nil
                
                guard let requestResponse = response else {
                    let error = NSError(domain: "the_request_timed_out".ls, code:0, userInfo: nil)
                    observer.onError(error)
                    return
                }
                
                if !requestResponse.handleErrorsIfAny(response: requestResponse) {
                    attachmentDeleteResponse = BaseResponseForModels(json: response?.responseString)
                    Common.appDelegate.appLog.debug(response?.responseString)
                    
                    Common.appDelegate.appLog.debug(urlToHit)
                    
                    Common.appDelegate.appLog.debug(attachmentDeleteResponse)
                    
                    observer.onNext(attachmentDeleteResponse!)
                    observer.onCompleted()
                }else {
                    attachmentDeleteResponse = BaseResponseForModels(json: response?.responseString)
                    let error = NSError(domain: attachmentDeleteResponse!.message, code:500, userInfo: nil)
                    observer.onError(error)
                }
            })
            
            return Disposables.create()
        }
        
        
    }
    
    
}
