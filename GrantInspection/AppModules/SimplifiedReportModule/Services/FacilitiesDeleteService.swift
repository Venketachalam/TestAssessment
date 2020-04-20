//
//  FacilitiesDeleteService.swift
//  GrantInspection
//
//  Created by Mohammed Hassan on 15/10/19.
//  Copyright © 2019 MBRHE. All rights reserved.
//

import UIKit
import RxSwift

protocol DeleteFacilityRequestProtocol {
    
    func deleteFacilityRequestService(facilityId:String) -> Observable<BaseResponseForModels>
}

class FacilityDeleteService: DeleteFacilityRequestProtocol {
    
    func deleteFacilityRequestService(facilityId: String) -> Observable<BaseResponseForModels>{
        return Observable.create{ observer in
            
            let apiCommunication = APICommunication()
            let urlToHit = APICommunicationURLs.deleteFacilityFromTheReport(facilityID: facilityId)
            
            apiCommunication.dataInStringFromURL(url: urlToHit, requestType: .delete, completion: { (response) in

                var facilityDeleteResponse: BaseResponseForModels? = nil
                
                guard let requestResponse = response else {
                    let error = NSError(domain: "the_request_timed_out".ls, code:0, userInfo: nil)
                    observer.onError(error)
                    return
                }
                
                if !requestResponse.handleErrorsIfAny(response: requestResponse) {
                    facilityDeleteResponse = BaseResponseForModels(json: response?.responseString)
                    Common.appDelegate.appLog.debug(response?.responseString)
                    
                    Common.appDelegate.appLog.debug(urlToHit)
                    
                    Common.appDelegate.appLog.debug(facilityDeleteResponse)
                    
                    observer.onNext(facilityDeleteResponse!)
                    observer.onCompleted()
                }else {
                    facilityDeleteResponse = BaseResponseForModels(json: response?.responseString)
                    let error = NSError(domain: facilityDeleteResponse!.message, code:500, userInfo: nil)
                    observer.onError(error)
                }
            })
            
            return Disposables.create()
        }
        
        
    }
    
    
}
