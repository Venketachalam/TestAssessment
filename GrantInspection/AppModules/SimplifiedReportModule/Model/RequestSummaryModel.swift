//
//  RequestSummaryModel.swift
//  GrantInspection
//
//  Created by Rajeswaran Thangaperumal on 02/09/2019.
//  Copyright © 2019 MBRHE. All rights reserved.
//

import EVReflection

public class  RequestDetailModel: BaseResponseForModels {
    
    open var payload: RequestPayload = RequestPayload()
    required public init() {}
}

public class  RequestPayload: EVObject {
    open var summary = RequestSummary()
    required public init() {}
}

public class  RequestSummary: EVObject {    
    open var applicationNo = ""
    open var applicantId = ""
    open var customerName = ""
    open var landNo = ""
    open var latitude = ""
    open var longitude = ""
    open var duration = ""
    open var applicantMobileNo = ""
    open var serviceRegion = ""
    open var servicePlotArea = ""
    required public init() {}
}

