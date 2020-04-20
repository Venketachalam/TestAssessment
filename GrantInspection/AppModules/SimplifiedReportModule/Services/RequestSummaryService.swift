//
//  RequestSummaryService.swift
//  GrantInspection
//
//  Created by Rajeswaran Thangaperumal on 02/09/2019.
//  Copyright © 2019 MBRHE. All rights reserved.
//


import UIKit
import RxSwift

protocol RequestServiceProtocol {
    
    func getRequestSummary(applicationID: String,applicationNo: String,serviceTypeID: String) -> Observable<RequestDetailModel>
   
}

class RequestService: RequestServiceProtocol {
    func getRequestSummary(applicationID: String, applicationNo: String,serviceTypeID: String) -> Observable<RequestDetailModel> {
        return Observable.create { observer in
            
            let apiCommunication = APICommunication()
            let urlToHit = APICommunicationURLs.getRequestDetails(currentLanguage: "en")
            let param = ["applicationNo":applicationNo,"applicantId":applicationID,"serviceTypeId":serviceTypeID]
            apiCommunication.dataInStringFromURL(url: urlToHit, requestType: .post, paramsIfAny: param, authenticationType: .Authentic, completion: { (response) in
                var paymentDetailResponse: RequestDetailModel? = nil
                
                paymentDetailResponse = RequestDetailModel(json: response?.responseString)
                observer.onNext(paymentDetailResponse!)
                observer.onCompleted()
            })
           
            return Disposables.create()
    }
    }
    
    
}
