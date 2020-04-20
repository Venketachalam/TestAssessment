//
//  AttachmentURLService.swift
//  Progress
//
//  Created by Muhammad Akhtar on 11/8/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import UIKit
import EVReflection

class AttachmentURLService: NSObject {
    
    open func getAttachmentURL(attachmentId:String,completion: @escaping ( _ dataObject:
        AttachmentURlResponse?) -> Void) {
        
        let apiCommunication = APICommunication()
        let urlToHit = APICommunicationURLs.getAttachmentURL(currentLanguage: "en", attachmentId: attachmentId)
        apiCommunication.dataInStringFromURL(url: urlToHit, requestType: .get ) { (_ response: APIBaseResponse?)  in
            var apiResponse: AttachmentURlResponse? = nil
            
            defer {
                completion(apiResponse)
            }
            
            guard let requestResponse = response else {
                return
            }
            
             apiResponse = AttachmentURlResponse(json: response?.responseString)

        }
    }
}

public class  AttachmentURlResponse: BaseResponseForModels {
    
    open var payload: ViewAttachment = ViewAttachment()
    required public init() {}
}

public class ViewAttachment: EVObject {
 
  open var viewAttachmentPayload: AttachmentObject = AttachmentObject()
  required public init() {}
}

public class  AttachmentObject: EVObject {
    open var url:String = ""
    required public init() {}
}


