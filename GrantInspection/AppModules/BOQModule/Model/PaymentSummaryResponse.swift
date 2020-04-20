//
//  PaymentSummaryResponse.swift
//  Progress
//
//  Created by Muhammad Akhtar on 10/21/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import UIKit
import EVReflection

public class PaymentSummaryResponse: BaseResponseForModels {
    
        open var payload: PaymentSummaryModel = PaymentSummaryModel()
        required public init() {}
}

public class  PaymentSummaryModel: EVObject {
    
    open var perCompleted: String = ""
    open var gross: String = ""
    open var deduction: String = ""
    open var billRetention: String = ""
    open var totalBillPayment: String = ""
    open var paymentOwner: String = ""
    open var paymentContractor: String = ""
    open var contractAmount: String = ""
    open var ownerShare: String = ""
    open var totalRetention: String = ""
    open  var totalPayment : String = ""
    
    required public init() {}
}

