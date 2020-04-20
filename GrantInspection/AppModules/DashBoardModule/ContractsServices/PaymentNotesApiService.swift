//
//  PaymentNotesApiService.swift
//  Progress
//
//  Created by Muhammad Akhtar on 11/13/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import UIKit
import RxSwift

protocol PaymentNotesServiceProtocol {
    func addPaymentNotes(with credentials: RemarkRequest) -> Observable<BaseResponseForModels>
    func fetchPaymentNotes(with credentials: RemarkRequest) -> Observable<PaymenCommentsModelResponse>
}

class PaymentNotesService: PaymentNotesServiceProtocol {
    func addPaymentNotes(with credentials: RemarkRequest) -> Observable<BaseResponseForModels> {
        return Observable.create { observer in
            
            let apiCommunication = APICommunication()
            let urlToHit = APICommunicationURLs.getPaymentNotesURL(currentLanguage: "en", paymentId: credentials.paymentId)
            
            let peram = ["remark":credentials.remarks]
            
            apiCommunication.dataInStringFromURL(url: urlToHit, requestType: .post,paramsIfAny:peram, authenticationType:.Authentic) { (_ response: APIBaseResponse?)  in
                var apiResponse: BaseResponseForModels? = nil
                
                apiResponse = BaseResponseForModels(json: response?.responseString)
                observer.onNext(apiResponse!)
                observer.onCompleted()
              
            }
            return Disposables.create()
        }
    }
  
  func fetchPaymentNotes(with credentials: RemarkRequest) -> Observable<PaymenCommentsModelResponse> {
  
    return Observable.create { observer in
      
      let apiCommunication = APICommunication()
      let urlToHit = APICommunicationURLs.fetchCommentURL(currentLanguage: "en", contractId: credentials.contractorId, paymentId: credentials.paymentId, pId: credentials.pid, type: "0")
      
      
      apiCommunication.dataInStringFromURL(url: urlToHit, requestType: .get,paramsIfAny:nil, authenticationType:.Authentic) { (_ response: APIBaseResponse?)  in
        var apiResponse: PaymenCommentsModelResponse? = nil
        
     
        apiResponse = PaymenCommentsModelResponse(json: response?.responseString)
       
        Common.appDelegate.appLog.info("Fetch-Comments-From-Dashboard-Api-call")
        Common.appDelegate.appLog.debug(urlToHit)
        Common.appDelegate.appLog.debug(response)
        
        observer.onNext(apiResponse!)
        observer.onCompleted()
        
      }
      return Disposables.create()
    }
  }
  
  
}
