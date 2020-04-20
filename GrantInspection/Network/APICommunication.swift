//
//  APICommunication.swift
//  iskan
//
//  Created by Zeshan Hayder on 1/18/18.
//  Copyright © 2018 MRHE. All rights reserved.
//

import Foundation
import Alamofire

public enum AuthenticationType : Int {
  case Normal
  case Authentic
  case Github
  case AuthenticJsonType
}

public class APICommunication: NSObject {
  
  var allowCache : Bool = false
  var manager : Alamofire.SessionManager?
  
  public override init() {
    
    let memoryCacheCapacity = 50 * 1024 * 1024 // 50 Mb
    let diskCacheCapacity = 200 * 1024 * 1024 // 200 Mb
    let cache = URLCache(memoryCapacity: memoryCacheCapacity, diskCapacity: diskCacheCapacity, diskPath: "iskanData")
    
    let configuration = URLSessionConfiguration.default
    let defaultHeaders = Alamofire.SessionManager.defaultHTTPHeaders
    
    configuration.httpAdditionalHeaders = defaultHeaders
    configuration.requestCachePolicy = .useProtocolCachePolicy
    if allowCache {
      configuration.urlCache = cache
    }

    configuration.timeoutIntervalForRequest = 60  //10 //secs
    configuration.timeoutIntervalForResource = 60  //10 //secs

    
    manager = Alamofire.SessionManager(configuration : configuration)
  }
  
  private var log = true
  
  public func dataInStringFromURL_withoutTimeout(url: String,
                                                 requestType: HTTPMethod,
                                                 paramsIfAny: [String: String]? = nil,
                                                 authenticationType : AuthenticationType? = .Authentic ,
                                                 completion: @escaping
    (_ response: APIBaseResponse?) -> Void) {
    
    if log {
      print(String(format: "Method ----> %@\n", requestType.rawValue))
      print(String(format: "paramsIfAny ----> %@\n", paramsIfAny ?? "Empty params"))
      print(String(format: "url ----> %@\n", url))
      //            print((authenticationType == .Authentic) ? authorizedHeader : normalHeader)
    }
    var baseResponse: APIBaseResponse?
    
    var requestHeader : [String : String]!
    if (authenticationType == .Authentic) {
      requestHeader = SharedResources.sharedInstance.authorizedHeaders
    } else {
      requestHeader = SharedResources.sharedInstance.normalUnAuthorisedHeader
    }
    
    request(URL(string: url)!, method: requestType, parameters: paramsIfAny, encoding: URLEncoding.default, headers: requestHeader).responseString { (dataResponse: DataResponse<String>) in
            
            defer {
                completion(baseResponse)
            }
            guard let response = dataResponse.response else {
                // invalid response
                return
            }
            
            guard let responseString = dataResponse.result.value else {
                //nil value
                return
            }
            
            
            if self.log {
                print(String(format: "response.statusCode ----> %i\n", response.statusCode))
                print(String(format: "result ----> %@\n", dataResponse.result.value!))
            }
            
            let statusCode = response.statusCode
            var successCall = false
            
            switch statusCode {
            case HttpStatusCode.Http200_OK.rawValue ... (HttpStatusCode.Http300_MultipleChoices.rawValue - 1):
                successCall = true
                break
            default:
                successCall = false
                break
            }
            
            baseResponse = APIBaseResponse.init(response: responseString, statusCode: statusCode, success: successCall)
    }
    /*request(url,
            method: requestType,
            parameters: paramsIfAny,
            encoding: URLEncoding.default,
            headers: requestHeader
      )
      
      .responseString { (dataResponse: DataResponse<String>) in
        
        defer {
          completion(baseResponse)
        }
        guard let response = dataResponse.response else {
          // invalid response
          return
        }
        
        guard let responseString = dataResponse.result.value else {
          //nil value
          return
        }
        
        
        if self.log {
          print(String(format: "response.statusCode ----> %i\n", response.statusCode))
          print(String(format: "result ----> %@\n", dataResponse.result.value!))
        }
        
        let statusCode = response.statusCode
        var successCall = false
        
        switch statusCode {
        case HttpStatusCode.Http200_OK.rawValue ... (HttpStatusCode.Http300_MultipleChoices.rawValue - 1):
          successCall = true
          break
        default:
          successCall = false
          break
        }
        
        baseResponse = APIBaseResponse.init(response: responseString, statusCode: statusCode, success: successCall)
    }*/
  }
  
  
  
  //    func handleErrorsIfAny(response: APIBaseResponse?) -> Bool {
  //        var isError = true
  //        if (response?.success)! {
  //            let statusCode : Int = (response?.httpStatusCode)!
  //            //we need to parse
  //            if statusCode == 500 {
  //                self.showProgressHud(message: "common_network_error".ls)
  //                isError = true
  //            }else if (statusCode >= 400) && (statusCode < 500) {
  //                let baseResponse : BaseResponseForModels = BaseResponseForModels.deserialize(from: response?.responseString)!
  //                self.showProgressHud(message: baseResponse.message)
  //                isError = true
  //
  //            } else if (statusCode >= 200) && (statusCode < 300) {
  //                isError = false
  //            }
  //
  //        }
  //        return isError
  //    }
  
  public func dataInStringFromURL(url: String,
                                  requestType: HTTPMethod,
                                  paramsIfAny: [String: Any]? = nil,
                                  authenticationType : AuthenticationType? = .Authentic ,
                                  completion: @escaping
    (_ response: APIBaseResponse?) -> Void) {
    
    if log {
      print(String(format: "Method ----> %@\n", requestType.rawValue))
      print(String(format: "paramsIfAny ----> %@\n", paramsIfAny ?? "Empty params"))
      print(String(format: "url ----> %@\n", url))
      //            print((authenticationType == .Authentic) ? authorizedHeader : normalHeader)
    }
    var baseResponse: APIBaseResponse?
    
    var requestHeader : [String : String]!
    var encodingType: ParameterEncoding!
    if (authenticationType == .Authentic) {
      requestHeader = SharedResources.sharedInstance.authorizedHeaders
    } else if (authenticationType == .Github) {
      requestHeader = ["Authorization":"bearer 6d23902e6a9ffdac8811f777e1cb467591921931"]
    } else if authenticationType == .AuthenticJsonType {
        requestHeader = SharedResources.sharedInstance.authorizedHeaders
        encodingType = JSONEncoding.default
    }else {
      requestHeader = SharedResources.sharedInstance.normalUnAuthorisedHeader
    }
    //print(manager)
    
    manager?.request(url,
                     method: requestType,
                     parameters: paramsIfAny,
                     encoding: encodingType ?? URLEncoding.default,
                     headers: requestHeader
      )
      
      .responseString { (dataResponse: DataResponse<String>) in
        
        defer {
          completion(baseResponse)
        }
        guard let response = dataResponse.response else {
          // invalid response
          return
        }
        
        guard let responseString = dataResponse.result.value else {
          //nil value
          return
        }
        
        
        if self.log {
          print(String(format: "response.statusCode ----> %i\n", response.statusCode))
          print(String(format: "result ----> %@\n", dataResponse.result.value!))
        }
        
        let statusCode = response.statusCode
        var successCall = false
        
        switch statusCode {
        case HttpStatusCode.Http200_OK.rawValue ... (HttpStatusCode.Http300_MultipleChoices.rawValue - 1):
          successCall = true
          break
        default:
          successCall = false
          break
        }
        
        baseResponse = APIBaseResponse.init(response: responseString, statusCode: statusCode, success: successCall)
    }
  }
    
    
    public func dataInStringFromURLCallToUpload(url: String,
                                    requestType: HTTPMethod,
                                    paramsIfAny: [String: String]? = nil,
                                    authenticationType : AuthenticationType? = .Authentic ,
                                    image:UIImage,
                                    completion: @escaping
        (_ response: APIBaseResponse?) -> Void) {
        
        if log {
            print(String(format: "Method ----> %@\n", requestType.rawValue))
            print(String(format: "paramsIfAny ----> %@\n", paramsIfAny ?? "Empty params"))
            print(String(format: "url ----> %@\n", url))
            
        }
        var baseResponse: APIBaseResponse?
        
        var requestHeader : [String : String]!
        if (authenticationType == .Authentic) {
            requestHeader = SharedResources.sharedInstance.authorizedHeaders
        } else if (authenticationType == .Github) {
            requestHeader = ["Authorization":"bearer 6d23902e6a9ffdac8811f777e1cb467591921931"]
        } else {
            requestHeader = SharedResources.sharedInstance.normalUnAuthorisedHeader
        }
     
        let imgData = image.pngData()
        
        manager?.upload(multipartFormData: { multipartFormData in
           
            for(key,value) in paramsIfAny!
            {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
             multipartFormData.append(imgData!, withName: "file",fileName: "file.png", mimeType: "image/png")
        }, to:URL(string: url)!, headers :requestHeader,
           encodingCompletion: { (encodingResult) in

            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    debugPrint(response)
                }
            case .failure(let encodingError):
                print(encodingError)
            }

        })
        
        //        manager?.request(url,
//                         method: requestType,
//                         parameters: paramsIfAny,
//                         encoding: URLEncoding.default,
//                         headers: requestHeader
//            )
//
//            .responseString { (dataResponse: DataResponse<String>) in
//
//                defer {
//                    completion(baseResponse)
//                }
//                guard let response = dataResponse.response else {
//                    // invalid response
//                    return
//                }
//
//                guard let responseString = dataResponse.result.value else {
//                    //nil value
//                    return
//                }
//
//
//                if self.log {
//                    print(String(format: "response.statusCode ----> %i\n", response.statusCode))
//                    print(String(format: "result ----> %@\n", dataResponse.result.value!))
//                }
//
//                let statusCode = response.statusCode
//                var successCall = false
//
//                switch statusCode {
//                case HttpStatusCode.Http200_OK.rawValue ... (HttpStatusCode.Http300_MultipleChoices.rawValue - 1):
//                    successCall = true
//                    break
//                default:
//                    successCall = false
//                    break
//                }
//
//                baseResponse = APIBaseResponse.init(response: responseString, statusCode: statusCode, success: successCall)
//        }
        
        
    }
}


extension Dictionary {
    var jsonStringRepresentation: String? {
        guard let theJSONData = try? JSONSerialization.data(withJSONObject: self,
                                                            options: [.prettyPrinted]) else {
                                                                return nil
        }
        
        return String(data: theJSONData, encoding: .ascii)
    }
}
