//
//  GeoActivityService.swift
//  Progress
//
//  Created by Muhammad Akhtar on 3/10/19.
//  Copyright © 2019 MBRHE. All rights reserved.
//


import UIKit
import EVReflection

class GeoActivityService: NSObject {
    
    open func postLocationData(obj:Dashboard, completion: @escaping ( _ dataObject:
        GeoActivityResponse?) -> Void) {
        /*
        let apiCommunication = APICommunication()
        var urlToHit = APICommunicationURLs.postGeoActivityDataAppNo(paymentId: obj.paymentId.description, appNo: obj.applicationNo)
        
        let dict = ["latitude":obj.plot.latitude,
                    "longitude":obj.plot.longitude]
        
        apiCommunication.dataInStringFromURL(url: urlToHit, requestType: .post, paramsIfAny: dict) { (_ response: APIBaseResponse?)  in
            
            var apiResponse: GeoActivityResponse? = nil
            
            defer {
                completion(apiResponse)
            }
           
            //EVReflection.setBundleIdentifier(BaseResponseForModels.self)
            apiResponse = GeoActivityResponse(json: response?.responseString)
            
        }
       */
    }
}

public class  GeoActivityResponse: BaseResponseForModels {
    
    required public init() {}
}





