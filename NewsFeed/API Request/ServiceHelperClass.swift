//
//  ServiceHelperClass.swift
//  Kuwy
//
//  Created by Saikrishna Kumbhoji on 13/05/19.
//  Copyright © 2019 Saikrishna Kumbhoji. All rights reserved.
//

import Foundation
import Alamofire
enum RequestType : String{
    case GET,POST
}

class ServiceHelperClass{
    
    public func makeGetRequest(_ controller: UIViewController,_ strURL: String, success:@escaping (_ parsedJSON: Data) -> Void, failure:@escaping (_ errorMsg: String) -> Void) {
        controller.view.isUserInteractionEnabled = false
        var url = Constants.baseUrl + strURL
        url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: Constants.header).responseJSON { (responseObject) -> Void in
            controller.view.isUserInteractionEnabled = true
            if responseObject.result.isSuccess {
                success(responseObject.data!)
            }
            if responseObject.result.isFailure {
                let error : NSError = responseObject.result.error! as NSError
                let errorMessage = self.handlingFailureCases(error.code)
                failure(errorMessage)
            }
        }
        
        
    }
    
    public func makePostRequest(_ controller: UIViewController,_ strURL : String, params : [String : Any]?, headers : [String : String]?, success:@escaping (_ parsedJSON: Data) -> Void, failure:@escaping (_ errorMsg: String) -> Void){
        controller.view.isUserInteractionEnabled = false
        let url = Constants.baseUrl + strURL
//        url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { (responseObject) -> Void in
            controller.view.isUserInteractionEnabled = true
            if responseObject.result.isSuccess {
                success(responseObject.data!)
            }
            if responseObject.result.isFailure {
                let error : NSError = responseObject.result.error! as NSError
                let errorMessage = self.handlingFailureCases(error.code)
                failure(errorMessage)
            }
        }
    }

   public func handlingFailureCases(_ statusCode: Int) -> String{
        print(statusCode)
        var errorMsg: String!
        switch statusCode{
        case 401:
            errorMsg = "Your login session has expired due to multiple logins! Please try logging in again"
            
        case 402 ... 499:
            errorMsg = "An error Occured"
        case 500 ... 510:
            errorMsg = "The server failed to fulfill an apparently valid request."
        case 900 :
            errorMsg = "An error Occured"
        case -1020 ... -1001:
            errorMsg = "Server couldn't be reached. Please try again later"
        default:
            errorMsg = "Unable to connect to the server"
        }
        return errorMsg
    }
    

}
    

