//
//  AttachmentViewModel.swift
//  GrantInspection
//
//  Created by Mohammed Hassan on 24/09/19.
//  Copyright © 2019 MBRHE. All rights reserved.
//

import EVReflection

public class  ResponseViewAttachmentsModel: BaseResponseForModels {
    
    open var payload: AttachmentViewResponsePayload = AttachmentViewResponsePayload()
    required public init() {}
}

public class AttachmentViewResponsePayload:EVObject
{
    open var viewAttachmentPayload: AttachmentViewResponseDetails = AttachmentViewResponseDetails()
    required public init() {}
}

public class AttachmentViewResponseDetails:EVObject
{
    open var url = ""
    open var remarks = ""
    open var attachmentId = ""
    required public init() {}
}



