//
//  ContractPaymentDetails.swift
//  Progress
//
//  Created by Muhammad Akhtar on 10/24/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import EVReflection

public class  ContractPaymentDetailsResponse: BaseResponseForModels {
    
    open var payload: [ContractPaymentDetails] = [ContractPaymentDetails]()
    required public init() {}
}

public class  ContractPaymentDetails: EVObject {
    
    open var id:NSNumber = 0
    open var paymentRefr:String = ""
    open var payment: ProjectPayment = ProjectPayment()
    required public init() {}
}

public class  ProjectPayment: EVObject {
    
    open var id:NSNumber = 0
    open var lastVisit:String = ""
    open var date:String = ""
    open var amount:String = ""
    open var totalBillPayment:String = ""
    open var billRetention:String = ""
    open var remarks:NSNumber = 0
    open var remarksId:NSNumber = 0
    open var attachmentId:NSNumber = 0
    required public init() {}
    
}
