//
//  AttachmentUploadModel.swift
//  GrantInspection
//
//  Created by Mohammed Hassan on 22/09/19.
//  Copyright © 2019 MBRHE. All rights reserved.
//

import EVReflection


public class  RequestAttachmentsModel: BaseResponseForModels {
    
    open var payload: AttachmentRequestPayload = AttachmentRequestPayload()
    open var categorydata:CategoryRequestPayload=CategoryRequestPayload()
    open var attachmentDownloaddata:AttachmentDownloadData=AttachmentDownloadData()

    required public init() {}
}

public class  AttachmentRequestPayload: EVObject {
    
    open var summary = AttachmentUploadModel()
    required public init() {}
}

public class CategoryRequestPayload:EVObject{
    open var categoryInputData = CategoryUploadModel()
    open var categoryResponse=CategoryResponseListModel()
    required public init() {}
}

public class AttachmentDownloadData:EVObject{
    open var attachmentInputData = AttachmentDownloadInputParams()
    open var attachmentOutputData=AttachmentDownloadResponse()
    required public init() {}
}

public class  AttachmentUploadModel: EVObject {
  
    open var facilityId = ""
    open var remarks = ""
    open var attachmentTypeId:NSNumber = 0
    open var inspectionReportId:NSNumber = 0
    open var file = Data()
    required public init() {}
}

public class CategoryUploadModel:EVObject{
    open var applicationNo = ""
    open var applicantId = ""
    open var serviceType = ""
    required public init() {}
}


public class CategoryResponseListModel:BaseResponseForModels{
    
//    open var payload = responseString()
//    open var httpStatusCode = 0
    public var payload = [Response]()
    required public init() {}
}

public class responseString:EVObject{
    public var response = [Response]()
    required public init(){
}
}

public class Response:EVObject{
    
    open var guid = " "
    open var applicationNo = ""
    open var applicantId = ""
    open var serviceType = ""
    open var docName = ""
    open var docType = ""
    open var contentCount = 0
    
    required public init (){
}
}

public class  AttachmentDownloadInputParams: EVObject {
    open var guid = ""
    open var index = 0
    required public init() {}
}

public class AttachmentDownloadResponse:BaseResponseForModels{

    required public init() {}
}

