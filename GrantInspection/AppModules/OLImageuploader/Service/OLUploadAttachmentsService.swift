//
//  UploadAttachmentsService.swift
//  Progress
//
//  Created by Hasnain Haider on 08/4/19.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import UIKit
import Alamofire
import EVReflection

protocol uploadDelegate: class {
  func processPercentage(percentage : Double)
}

class OLUploadAttachmentsService: NSObject {
  
    var deletgate : uploadDelegate!
  
  
    open func uploadDocuments(attachmentId : String , dataDict : [String : AnyObject], completion: @escaping ( _ dataObject:
        OLUploadFilesModel?) -> Void) {
        
        var url = APICommunicationURLs.getUploadAttachmentURL(currentLanguage: "en", attachmentId: attachmentId)
      
      
        uploadPictureForTypeId(dataDict,url) { (_ response : APIBaseResponse?) in
            var apiResponse : OLUploadFilesModel? = nil
            
            defer {
                completion(apiResponse)
            }
            
            guard let requestResponse = response else {
                return
            }
          
          
            if !requestResponse.handleErrorsIfAny(response: requestResponse) {
                apiResponse = OLUploadFilesModel(json: response?.responseString)
                
            }
        }
    }
    
    open func uploadedAttachmentFiles(dataDict : [String : AnyObject], url:String, completion: @escaping ( _ dataObject:
        RequestAttachmentsModel?) -> Void) {
        
        uploadPictureForTypeId(dataDict,url) { (_ response : APIBaseResponse?) in
            var apiResponse : RequestAttachmentsModel? = nil
            
            defer {
                completion(apiResponse)
            }
            
            guard let requestResponse = response else {
                return
            }
            
            
            if !requestResponse.handleErrorsIfAny(response: requestResponse) {
                apiResponse = RequestAttachmentsModel(json: response?.responseString)
                
            }
        }
    }
    
    open func uploadPictureForTypeId(_ param : [String : AnyObject],
                                     _ url :String,
                                     completion: @escaping (_ response : APIBaseResponse?) -> Void) {
      
      var fileFound : Bool = false
      let file : String = "file"
      var mimeType : String = "image/jpeg"
    //    var mimeType : String = "image/png"

     
      
      for (key, value) in param {
        if value is Data {
          fileFound = true
        }
        
        if key == "mimeType" {
          mimeType = value as! String
        }
      }
      
      if fileFound == false {
        return
      }
        
      
        Alamofire.upload(multipartFormData: { (multipartFormData) in
          
          for (key, value) in param {

            if let data = value as? Data {
              multipartFormData.append(data, withName: file, fileName: key, mimeType: mimeType)
            }
            else {
              multipartFormData.append(value.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue).rawValue)!, withName: key)
            }
          }
            
        },usingThreshold:UInt64.init(),
          to:url,
          method:.post,
          headers:["Authorization": "bearer" + " " + SharedResources.sharedInstance.currentUser.access_token])
        { (result) in
            switch result {
            case .success(let upload, _, _):
              
              
                upload.uploadProgress(closure: { (Progress) in
                  print("Upload Progress: \(Progress.fractionCompleted)")
                })
                upload.responseJSON { response in
                    let responseString = String(data: response.data!, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))

                    var baseResponse: APIBaseResponse?
                    baseResponse = APIBaseResponse.init(response: responseString!, statusCode: 200, success: true)
 
                    completion(baseResponse)
                }
                
            case .failure(let encodingError):
                completion(APIBaseResponse.init(response: encodingError.localizedDescription, statusCode: 200, success: false))
            }
            
        }
    }
    
}
