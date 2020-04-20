//
//  DownloadAttachmentService.swift
//  GrantInspection
//
//  Created by Venketachalam Govindaraj on 29/09/19.
//  Copyright © 2019 MBRHE. All rights reserved.
//

import UIKit
import RxSwift

protocol DownloadAttachmentServiceProtocol {
    func downloadattachmentRequestSummary(param:AttachmentDownloadInputParams)->Observable<AttachmentDownloadResponse>
}

class DownloadAttachmentService: DownloadAttachmentServiceProtocol {
    
    func downloadattachmentRequestSummary(param:AttachmentDownloadInputParams)->Observable<AttachmentDownloadResponse>
    {
        return Observable.create{ observer in
            let apiCommunication=APICommunication()
            let urlToHit=APICommunicationURLs.downloadAttachment(guid: "",index:0)
            
            let requestParam:[String:String] = ["guid":"\(param.guid)","index":"\(param.index)"]
            
            apiCommunication.dataInStringFromURL(url: urlToHit, requestType: .post, paramsIfAny: requestParam, authenticationType: .Authentic, completion: { (response) in
                var categoryListResponse: AttachmentDownloadResponse? = nil
                guard let requestResponse = response else {
                    let error = NSError(domain: "the_request_timed_out".ls, code:0, userInfo: nil)
                    observer.onError(error)
                    return
                }
                if !requestResponse.handleErrorsIfAny(response: requestResponse) {
                    categoryListResponse = AttachmentDownloadResponse(json: response?.responseString)
                    
                    Common.appDelegate.appLog.debug(response?.responseString)
                    
                    Common.appDelegate.appLog.debug(urlToHit)
                    
                    Common.appDelegate.appLog.debug(categoryListResponse)
                    
                    observer.onNext(categoryListResponse!)
                    observer.onCompleted()
                }else {
                    categoryListResponse = AttachmentDownloadResponse(json: response?.responseString)
                    let error = NSError(domain: categoryListResponse!.message, code:500, userInfo: nil)
                    observer.onError(error)
                }
            })
            
            
            
            return Disposables.create()
        }
    }
    
    

}
