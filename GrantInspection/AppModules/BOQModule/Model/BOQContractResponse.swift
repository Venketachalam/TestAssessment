//
//  PaymentSummaryResponse.swift
//  Progress
//
//  Created by Muhammad Akhtar on 10/21/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import UIKit
import EVReflection

public class BOQContractResponse: BaseResponseForModels {
  
  open var payload: [BOQModel] = [BOQModel]()
  required public init() {}
}

public class  BOQModel: EVObject {
  
  open var workId: NSNumber = 0
  open var paymentDetailId: Int = 0
  open var workDesc : String = ""
  open var actualDone : Float = 0
  open var contractPercentage: Float = 0
  open var paymentPercentage: Float = 0
  open var engineerPercentage: Float = 0
  open var comments: [String] = [String]()
  
  required public init() {}
}


public class  CommentModel: EVObject {
  open var remark: String = ""
  
  required public init() {}
}
