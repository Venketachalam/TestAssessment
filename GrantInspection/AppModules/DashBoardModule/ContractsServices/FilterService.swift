//
//  FilterService.swift
//  Progress
//
//  Created by Muhammad Akhtar on 11/19/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import Foundation

open class FilterService: NSObject {
    func getContractorPayments(dict:Dictionary<String, String>,completion: @escaping ( _ dataObject:
        ContractsResponse?) -> Void) {
        
        let apiCommunication = APICommunication()
        let urlToHit = APICommunicationURLs.getContractorPaymentURL()
        print ("The params are:",dict)
        
//        apiCommunication.dataInStringFromURL(url: urlToHit, requestType: .post , paramsIfAny: requestParam, authenticationType: .Authentic, completion: { (response) in
//            var categoryListResponse: CategoryResponseListModel? = nil
//            guard let requestResponse = response else {
//                let error = NSError(domain: "the_request_timed_out".ls, code:0, userInfo: nil)
//                observer.onError(error)
//                return
//            }
//
//            if !requestResponse.handleErrorsIfAny(response: requestResponse) {
//                categoryListResponse = CategoryResponseListModel(json: response?.responseString)
//                Common.appDelegate.appLog.debug(response?.responseString)
//                Common.appDelegate.appLog.debug(urlToHit)
//                Common.appDelegate.appLog.debug(categoryListResponse)
//                observer.onNext(categoryListResponse!)
//                observer.onCompleted()
//            }else {
//                categoryListResponse = CategoryResponseListModel(json: response?.responseString)
//                let error = NSError(domain: categoryListResponse!.message, code:500, userInfo: nil)
//                observer.onError(error)
//            }
//        })
        
        apiCommunication.dataInStringFromURL(url: urlToHit, requestType: .post, paramsIfAny:  dict, authenticationType: .Authentic, completion: { (response)  in
            var contractorPaymentsResponse: ContractsResponse? = nil
          
          Common.appDelegate.appLog.info("Filter-Contractor-Payment-Api-call")
          Common.appDelegate.appLog.debug(urlToHit)
          Common.appDelegate.appLog.debug(dict)
          Common.appDelegate.appLog.debug(response)
          
            defer {
                completion(contractorPaymentsResponse)
            }
            
            contractorPaymentsResponse = ContractsResponse(json: response?.responseString)
          
        })
    }
}


