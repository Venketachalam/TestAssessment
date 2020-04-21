//
//  UploadFilesModel.swift
//  Progress
//
//    Created by Hasnain Haider on 08/4/19.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import EVReflection

public class OLUploadFilesModel: BaseResponseForModels {

    open var payload: AttachmentPayload = AttachmentPayload()
    required public init() {}
}


public class OLDBModel : EVObject {
 
  open var token:String = ""
  open var paymentId:String = ""
  open var contractId:String = ""
  open var filePath:String = ""
  open var fileName:String = ""
  open var latitude:String = ""
  open var status:String = ""
  open var longitude:String = ""
  open var percentage:Double = 0.0
  required public init() {}
}
