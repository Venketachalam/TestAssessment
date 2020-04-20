//
//  CategoryUploadService.swift
//  GrantInspection
//
//  Created by Venketachalam Govindaraj on 25/09/19.
//  Copyright © 2019 MBRHE. All rights reserved.
//

import UIKit
import RxSwift

protocol  CategoryServiceProtocol {
    func getCategoryRequestSummary(param:CategoryUploadModel)->Observable<CategoryResponseListModel>
}

class CategoryUploadService:CategoryServiceProtocol{
    
    func getCategoryRequestSummary(param:CategoryUploadModel)->Observable<CategoryResponseListModel>
    {
        return Observable.create{ observer in
            let apiCommunication=APICommunication()
            let urlToHit=APICommunicationURLs.categoryListAttachments()
            
            let requestParam:[String:String] = ["applicationNo":"\(param.applicationNo)","applicantId":"\(param.applicantId)","serviceType":"\(param.serviceType)"]
            
            apiCommunication.dataInStringFromURL(url: urlToHit, requestType: .post , paramsIfAny: requestParam, authenticationType: .Authentic, completion: { (response) in
                var categoryListResponse: CategoryResponseListModel? = nil
                guard let requestResponse = response else {
                    let error = NSError(domain: "the_request_timed_out".ls, code:0, userInfo: nil)
                    observer.onError(error)
                    return
                }
                
                if !requestResponse.handleErrorsIfAny(response: requestResponse) {
                    categoryListResponse = CategoryResponseListModel(json: response?.responseString)
                    Common.appDelegate.appLog.debug(response?.responseString)
                    Common.appDelegate.appLog.debug(urlToHit)
                    Common.appDelegate.appLog.debug(categoryListResponse)
                    observer.onNext(categoryListResponse!)
                    observer.onCompleted()
                }else {
                    categoryListResponse = CategoryResponseListModel(json: response?.responseString)
                    let error = NSError(domain: categoryListResponse!.message, code:500, userInfo: nil)
                    observer.onError(error)
                }
            })
            
            
            
            return Disposables.create()
        }
    }

    

}
