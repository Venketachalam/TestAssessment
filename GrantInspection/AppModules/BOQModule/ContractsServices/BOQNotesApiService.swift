//
//  PaymentNotesApiService.swift
//  Progress
//
//  Created by Muhammad Akhtar on 11/13/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import UIKit
import RxSwift

protocol BOQNotesServiceProtocol {
  func addBOQNotes(with credentials: BOQCommentRequest) -> Observable<BaseResponseForModels>
  func fetchPaymentNotes(with credentials: BOQCommentRequest) -> Observable<PaymenCommentsModelResponse>
}

class BOQNotesApiService: BOQNotesServiceProtocol {

  func addBOQNotes(with credentials: BOQCommentRequest) -> Observable<BaseResponseForModels> {
    
    return Observable.create { observer in
      
      if credentials.comment.isEmpty{
        return Disposables.create()
      }
      
      let urlToHit = APICommunicationURLs.boqAddCommentURL(currentLanguage: "en", contractId: credentials.contractId, paymentId: credentials.paymentId,workID :credentials.workID)
      let params = ["comment":credentials.comment,
                    "engineerPercentage":credentials.engeeringPercentage]
      
      let apiCommunication = APICommunication()
      apiCommunication.dataInStringFromURL(url: urlToHit, requestType: .post,paramsIfAny:params, authenticationType:.Authentic) { (_ response: APIBaseResponse?)  in
        var apiResponse: BaseResponseForModels? = nil
        
        Common.appDelegate.appLog.info("Add-Boq-Percentage-Api-call")
        Common.appDelegate.appLog.debug(urlToHit)
        Common.appDelegate.appLog.debug(params)
        Common.appDelegate.appLog.debug(response)
      
        apiResponse = BaseResponseForModels(json: response?.responseString)
        observer.onNext(apiResponse!)
        observer.onCompleted()
        
      }
      
      return Disposables.create()
    }
  }
  
  func fetchPaymentNotes(with credentials: BOQCommentRequest) -> Observable<PaymenCommentsModelResponse> {
    
    return Observable.create { observer in
      
      let apiCommunication = APICommunication()
      let urlToHit = APICommunicationURLs.fetchCommentURL(currentLanguage: "en", contractId: credentials.contractId, paymentId: credentials.paymentId, pId: credentials.paymentDetailId, type: "1")
      
      
      apiCommunication.dataInStringFromURL(url: urlToHit, requestType: .get,paramsIfAny:nil, authenticationType:.Authentic) { (_ response: APIBaseResponse?)  in
        var apiResponse: PaymenCommentsModelResponse? = nil
        
        apiResponse = PaymenCommentsModelResponse(json: response?.responseString)
        
        Common.appDelegate.appLog.info("Fetch-Comments-BOQ-Api-call")
        Common.appDelegate.appLog.debug(urlToHit)
        Common.appDelegate.appLog.debug(response)
        
          
        observer.onNext(apiResponse!)
        observer.onCompleted()
        
      }
      return Disposables.create()
    }
  }
  
  
}


struct BOQCommentRequest {
  let contractId: String
  let paymentId: String
  let paymentDetailId: String
  let workID: String
  let comment: String
  let engeeringPercentage: String
}

