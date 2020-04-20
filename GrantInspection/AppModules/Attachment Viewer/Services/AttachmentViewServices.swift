//
//  AttachmentViewServices.swift
//  GrantInspection
//
//  Created by Mohammed Hassan on 24/09/19.
//  Copyright © 2019 MBRHE. All rights reserved.
//

import UIKit
import RxSwift

protocol RequestViewAttachmentServiceProtocol {
    
    func getAttachmentViewRequestSummary(requestAttachmentId:String) -> Observable<ResponseViewAttachmentsModel>
    
}

class AttachmentViewService: RequestViewAttachmentServiceProtocol {
   
    func getAttachmentViewRequestSummary(requestAttachmentId: String) -> Observable<ResponseViewAttachmentsModel> {
        return Observable.create{ observer in
            
            let apiCommunication = APICommunication()
             let urlToHit = APICommunicationURLs.attachmentsViewFiles(requestParam: requestAttachmentId)
            
            apiCommunication.dataInStringFromURL(url: urlToHit, requestType: .get, completion: { (response) in
               
                var attachmentViewResponse: ResponseViewAttachmentsModel? = nil
              
                guard let requestResponse = response else {
                    let error = NSError(domain: "the_request_timed_out".ls, code:0, userInfo: nil)
                    observer.onError(error)
                    return
                }
                
                if !requestResponse.handleErrorsIfAny(response: requestResponse) {
                    attachmentViewResponse = ResponseViewAttachmentsModel(json: response?.responseString)
                    
                    Common.appDelegate.appLog.debug(response?.responseString)
                    
                    Common.appDelegate.appLog.debug(urlToHit)
                    
                    Common.appDelegate.appLog.debug(attachmentViewResponse)
                    
                    observer.onNext(attachmentViewResponse!)
                    observer.onCompleted()
                }else {
                    attachmentViewResponse = ResponseViewAttachmentsModel(json: response?.responseString)
                    let error = NSError(domain: attachmentViewResponse!.message, code:500, userInfo: nil)
                    observer.onError(error)
                }
            })
            
            return Disposables.create()
        }
    }
    
  
    
    
    
}
