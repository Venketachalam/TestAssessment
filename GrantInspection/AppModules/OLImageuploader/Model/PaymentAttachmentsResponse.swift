//
//  PaymentAttachmentsResponse.swift
//  Progress
//
//  Created by Muhammad Akhtar on 10/24/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import EVReflection

public class  PaymentAttachmentsResponse: BaseResponseForModels {
    
    open var payload: Attachment = Attachment()
    required public init() {}
}

public class  Attachment: EVObject {
  
  open var attachmentPayload : AttachmentPayload = AttachmentPayload()
  
  required public init() {}
}

public class  AttachmentPayload: EVObject {
    
    open var paymentId:NSNumber = 0
    open var contractorId:NSNumber = 0
    open var category: [AttachmentModel] = [AttachmentModel]()
    
    required public init() {}
}

public class  AttachmentModel: EVObject {
    
    open var id:NSNumber = 0
    open var name:String = ""
    open var attachmentsPayload: [AttachmentItemModel] = [AttachmentItemModel]()
    open var isExpanded = false
    
    public func propertyMapping() -> [(keyInObject: Bool?, keyInResource: Bool?)] {
        return [(keyInObject: isExpanded,keyInResource: nil)]
    }
    required public init() {}
}

public class  AttachmentItemModel: EVObject {
    
    open var id:NSNumber = 0
    //open var mimeType:String = ""
    open var createdAt:String = ""
    open var attachmentName:String = ""
    open var fileExtension:String = ""
    //open var documentId:NSNumber = 0

    
    required public init() {}
}

