//
//  SimplifiedReportModel.swift
//  GrantInspection
//
//  Created by Rajeswaran Thangaperumal on 04/09/2019.
//  Copyright © 2019 MBRHE. All rights reserved.
//

import EVReflection

public class FacilityResposeModel: BaseResponseForModels {
    
    open var payload: FacilityResponsePayload = FacilityResponsePayload()
    required public init() {}
}

public class FacilityResponsePayload: EVObject {
    
    open var facilityPayload = FacilityPayload()
    open var expansions = [FacilityExpansions]()
    open var houseStatus = [HouseStatus]()
    required public init() {}
    
}

public class  FacilityPayload: EVObject {
    open var facilityTypes = [FacilityTypes]()
    open var facilityElements = [FacilityElements]()
    open var facilityConditions = [FacilityConditions]()
    open var facilityActions = [FacilityActions]()
    
    required public init() {}
}

public class FacilityExpansions: EVObject {
    open var expansionId = 0
    open var expansionNameEn = ""
    open var expansionName = ""
    open var expansionType = 0
    
    required public init() {}
}

extension FacilityExpansions{
    func expansionNameValue()->String{
        if Common.currentLanguageArabic() {
            return self.expansionName
        } else {
            return self.expansionNameEn
        }
    }
    
}


public class FacilityTypes: EVObject {
    open var fTypeId = 0
    open var fTypeNameEn = ""
    open var fTypeName = ""
    
    
    required public init() {}
}

extension FacilityTypes {
    func facilityTypeName() -> String {
        if Common.currentLanguageArabic() {
            return self.fTypeName
        } else {
            return self.fTypeNameEn
        }
    }
}

public class FacilityElements: EVObject {
    open var fElementId = 0
    open var fElementNameEn = ""
    open var fElementName = ""
    
    required public init() {}
}

extension FacilityElements {
    func elementName() -> String {
        if Common.currentLanguageArabic() {
            return self.fElementName
        } else {
            return self.fElementNameEn
        }
    }
}

public class FacilityConditions: EVObject {
    open var fConditionId = 0
    open var fConditionNameEn = ""
    open var fConditionName = ""
    
    
    required public init() {}
}

extension FacilityConditions {
    func conditionName() -> String {
        if Common.currentLanguageArabic() {
            return self.fConditionName
        } else {
            return self.fConditionNameEn
        }
    }
}

public class FacilityActions: EVObject {
    open var fActionId = 0
    open var fActionNameEn = ""
    open var fActionName = ""
    required public init() {}
}
extension FacilityActions {
    func actionName() -> String {
        if Common.currentLanguageArabic() {
            return self.fActionName
        } else {
            return self.fActionNameEn
        }
    }
}

public class HouseStatus: EVObject {
    open var id = 0
    open var houseStatusName = ""
    open var houseStatusNameEn = ""
    
    
    required public init() {}
}

extension HouseStatus {
    func statusName() -> String {
        if Common.currentLanguageArabic() {
            return self.houseStatusName
        } else {
            return self.houseStatusNameEn
        }
    }
}
