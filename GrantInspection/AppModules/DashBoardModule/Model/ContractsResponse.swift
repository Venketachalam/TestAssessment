//
//  ContractPaymentDetailsResponse.swift
//  Progress
//
//  Created by Muhammad Akhtar on 10/21/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import UIKit
import EVReflection

public class ContractsResponse: BaseResponseForModels {
  
    open var payload: payloads = payloads()
 
    required public init() {}
} 


public class payloads : EVObject {
  
  open var filters: [Filters] = [Filters]()
  open var dashboard   : [Dashboard] = [Dashboard]()
  open var pagination : MBRHEPagination = MBRHEPagination()
  
}
public class  Filters: EVObject {
    
    open var label:String = ""
    open var colorTag:String = ""
    open var value:String = ""
    
    required public init() {}
}

public class  Dashboard: EVObject {
 
  
    open var applicationNo: NSNumber = 0
    open var applicantId: NSNumber = 0
    open var customerName: String = ""
    open var applicantMobileNo: String = ""
    open var serviceTypeId = ""
    open var value: String = ""
    open var serviceRegion: String = ""
    open var colorTag: String = ""
    open var plot: Plot = Plot()
    open var isObjectSelected: Bool = false
    open var reportStatus = ""
    open var actionDate = ""
   open var servicePlotArea = ""
 
  
    public func propertyMapping() -> [(keyInObject: Bool?, keyInResource: Bool?)] {
        return [(keyInObject: isObjectSelected,keyInResource: nil)]
    }
    
    
    required public init() {}
}


public class  Plot: EVObject {
    
    open var longitude: String = ""
    open var latitude: String = ""
    open var landNo: String = ""
    required public init() {}
}



