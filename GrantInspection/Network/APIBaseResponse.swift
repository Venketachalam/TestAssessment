//
//  APIBaseResponseString.swift
//  iskan
//
//  Created by Zeshan Hayder on 1/23/18.
//  Copyright © 2018 MRHE. All rights reserved.
//
import EVReflection

open class APIBaseResponse :EVObject  {
  
    public var httpStatusCode : Int = 0
    public var success : Bool = false
    public var responseString : String = ""

    required public init() {
        super.init()
    }
    init(response : String , statusCode : Int , success : Bool) {
        self.httpStatusCode = statusCode
        self.success = success
        self.responseString = response
    }
    
}


extension APIBaseResponse {
    
    func handleErrorsIfAny(response: APIBaseResponse?) -> Bool {
        var isError = true
        if (response?.success)! {
            let statusCode : Int = (response?.httpStatusCode)!
            //we need to parse
            if statusCode == 500 {
                //self.showProgressHud(message: "common_network_error".ls)
                isError = true
            }else if (statusCode >= 400) && (statusCode < 500) {
                //let baseResponse : BaseResponseForModels = BaseResponseForModels(json: response?.responseString)
                //self.showProgressHud(message: baseResponse.message)
                //print(baseResponse.message)
                isError = true
                
            } else if (statusCode >= 200) && (statusCode < 300) {
                isError = false
            }
            
        } else {
            //let baseResponse : BaseResponseForModels = BaseResponseForModels(json: response?.responseString)
            //print(baseResponse.message)
            isError = true
        }
        
        return isError
    }
}
