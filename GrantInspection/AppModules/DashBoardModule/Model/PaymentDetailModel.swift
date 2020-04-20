//
//  PaymentSummaryModel.swift
//  Progress
//
//  Created by Muhammad Akhtar on 1/2/19.
//  Copyright © 2019 MBRHE. All rights reserved.
//


import EVReflection

public class  PaymentDetailModel: BaseResponseForModels {
    
    open var payload: SummaryPayload = SummaryPayload()
    required public init() {}
}

public class  SummaryPayload: EVObject {
    
    open var contractId:NSNumber = 0
    open var contractorName:String = ""
    open var contractorID:NSNumber = 0
    open var contactName:String = ""
    open var applicationNo:String = ""
    open var mobileNo:String = ""
    open var plotNo:String = ""
    open var ownerName:String = ""
    open var engineer:String = ""
    open var perCompleted:String = ""
    open var lastUpdateDate:String = ""
    open var applicantID:NSNumber = 0
    open var contractAmount:String = ""
    open var loanAmount:String = ""
    open var transDate:String = ""
    open var totalPayment:String = ""
    open var serviceType:String = ""
    open var contrsSts:String = ""
    open var ownerShare:String = ""
    open var totalRetentions:String = ""
    open var remainingPayment:String = ""
    open var lastAmountPaid:String = ""
    open var consultantID:NSNumber = 0
    open var officePhone:String = ""
    open var email:String = ""
    open var contactMobile:String = ""
    open var contrStartDate:String = ""
    open var contrEndDate:String = ""
    open var contrStsID:NSNumber = 0
    open var remark:String = ""
    open var licenseNo:String = ""
    open var contrStsA:String = ""
    open var contrStsE:String = ""
    open var serviceTypeCode:NSNumber = 0
    open var dmCompleteDt:String = ""
    
    required public init() {}
}


