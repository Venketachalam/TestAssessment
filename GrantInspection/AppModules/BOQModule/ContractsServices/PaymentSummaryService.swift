//
//  ContractService.swift
//  Progress
//
//  Created by Muhammad Akhtar on 6/6/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import UIKit
import RxSwift

protocol PaymentSummaryProtocol {
  func getPaymentSummaryData(with paymentId: String , projectID : String) -> Observable<PaymentSummaryResponse>
  func submitPaymentStatus(with contractId: String , paymentId : String , status : String) -> Observable<BaseResponseForModels>
}

class PaymentSummaryService: PaymentSummaryProtocol {
        func getPaymentSummaryData(with paymentId: String,projectID : String) -> Observable<PaymentSummaryResponse> {
            return Observable.create { observer in
        
                let apiCommunication = APICommunication()
                let urlToHit = APICommunicationURLs.getPaymentSummaryURL(currentLanguage: "en", paymentId: paymentId,projectId: projectID)
                apiCommunication.dataInStringFromURL(url: urlToHit, requestType: .get) { (_ response: APIBaseResponse?)  in
                    var apiResponse: PaymentSummaryResponse? = nil
                  
                  apiResponse = PaymentSummaryResponse(json: response?.responseString)
                  
                  print(urlToHit)
                  print(apiResponse)

                  observer.onNext(apiResponse!)
                  observer.onCompleted()
                  
                }
                return Disposables.create()
            }
        }
  
  
  
  func submitPaymentStatus(with contractId: String , paymentId : String , status : String) -> Observable<BaseResponseForModels> {
    
   
    return Observable.create { observer in
     
      
      let apiCommunication = APICommunication()
      
      let urlToHit = APICommunicationURLs.submitPaymentSummaryStatusURL(currentLanguage: "en", contractId: contractId,paymentId: paymentId,status:status)

      apiCommunication.dataInStringFromURL(url: urlToHit, requestType: .post) { (_ response: APIBaseResponse?)  in
       
        var apiResponse: BaseResponseForModels? = nil
       
        print("summary-Response")
        print(urlToHit)
        print(response)
        
        apiResponse = BaseResponseForModels(json: response?.responseString)
        observer.onNext(apiResponse!)
        observer.onCompleted()
        
      }
      
      return Disposables.create()
    }
  }
        
}

