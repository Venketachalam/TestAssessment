//
//  ContractService.swift
//  Progress
//
//  Created by Muhammad Akhtar on 6/6/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import UIKit
import RxSwift

protocol BillOfQuantityProtocol {
    func getBOQData(with contractID : String , paymentId: String) -> Observable<BOQContractResponse>
    func addPercentageNotes(with credentials: BOQCommentRequest) -> Observable<BaseResponseForModels>
}

class BOQContractService: BillOfQuantityProtocol {
  
  func addPercentageNotes(with credentials: BOQCommentRequest) -> Observable<BaseResponseForModels> {
    
    return Observable.create { observer in
      
      
      let urlToHit = APICommunicationURLs.boqAddCommentURL(currentLanguage: "en",contractId : credentials.contractId, paymentId: credentials.paymentId,workID :credentials.workID)
      let params = ["comment":credentials.comment,
                    "engineerPercentage":credentials.engeeringPercentage]
      
      
      let apiCommunication = APICommunication()
      apiCommunication.dataInStringFromURL(url: urlToHit, requestType: .post,paramsIfAny:params, authenticationType:.Authentic) { (_ response: APIBaseResponse?)  in
        var apiResponse: BaseResponseForModels? = nil
        
        print("Add Percentage")
        print(urlToHit)
        print(params)
        print(response)
        
        apiResponse = BaseResponseForModels(json: response?.responseString)
        observer.onNext(apiResponse!)
        observer.onCompleted()
          
      }
      
      return Disposables.create()
    }
  }
  
  
  func getBOQData(with contractID : String , paymentId: String) -> Observable<BOQContractResponse> {
            return Observable.create { observer in
             
                let apiCommunication = APICommunication()
                let urlToHit = APICommunicationURLs.getBOQURL(contractId:contractID,paymentId: paymentId)
                apiCommunication.dataInStringFromURL(url: urlToHit, requestType: .get) { (_ response: APIBaseResponse?)  in
                    var apiResponse: BOQContractResponse? = nil
                  
                 
                    guard let requestResponse = response else {
                        let error = NSError(domain: "", code:0, userInfo: [NSLocalizedDescriptionKey : response?.debugDescription as Any])
                        observer.onError(error)
                        return
                    }
                    
                    if !requestResponse.handleErrorsIfAny(response: requestResponse) {
                        apiResponse = BOQContractResponse(json: response?.responseString)
                      print("fetch BOQ Records")
                      print(urlToHit)
                      print(apiResponse)
                      
                        observer.onNext(apiResponse!)
                        observer.onCompleted()
                    }else {
                        let error = NSError(domain: "", code: (response?.httpStatusCode)!, userInfo: [NSLocalizedDescriptionKey : response?.responseString as Any])
                        observer.onError(error)
                    }
                }
                return Disposables.create()
            }
        }
        
}

