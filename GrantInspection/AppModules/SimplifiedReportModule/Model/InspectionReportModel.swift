//
//  InspectionReportModel.swift
//  GrantInspection
//
//  Created by Rajeswaran Thangaperumal on 08/09/2019.
//  Copyright © 2019 MBRHE. All rights reserved.
//


import EVReflection

public class InspectionReportResposeModel: BaseResponseForModels {
    
    open var payload = InspectionReportPayload()
    required public init() {}
}

public class InspectionReportRequestPayload: BaseResponseForModels {
    
    open var payload = InspectionReportPayload()
    required public init() {}
}

public class InspectionInputReportRequestPayload: EVObject {
    
    open var payload = InspectionReportPayload()
    required public init() {}
}
public class InspectionReportPayload: EVObject {
    
    open var inspectionReport = InspectionReport()
    open var userFacility = UserFacility()
    required public init() {}
}

public class InspectionGetReportResposeModel: BaseResponseForModels {
    
    open var payload = InspectionReportRespose()
    required public init() {}
}

public class InspectionReportRespose: InspectionReport {
    open var satelliteImage = ImageAttachments()
    
    required public init() {}
}


public class InspectionReport: EVObject {
    
    open var inspectionReportId = ""
    open var applicationNumber = ""
    open var applicantId = ""
    open var lattitude = ""
    open var longitude = ""
    open var plotNumber = ""
    open var serviceTypeId = ""
    open var remarks = ""
    open var recommendation = ""
    open var createdDate = ""
    open var updatedDate = ""
    open var createdBy = ""
    open var approximateConstructionSize = ""
    open var occupiedByCitizens = ""
    open var houseStatusId = ""
    open var actionId = ""
    open var expansionIdHor = ""
    open var expansionIdVart = ""
    open var reportStatus = 0
  
    
    required public init() {}
    
}


public class UserFacility: EVObject {
    
    open var facilityId = ""
    open var inspectionReportId = ""
    open var buildingNameEnglish = ""
    open var buildingNameArabic = ""
    open var buildingSizeSQF = ""
    open var approximateCompletionDate = ""
    open var facilityActionId = ""
    open var facilityTypeId = ""
    open var buildingStatusId = ""
    open var serviceStatusId = ""
    open var facilityElementsList = [FacilityElementDetails]()
    open var facilityAttachmentsList = [FacilityAttachments]()

   
    required public init() {}
    
}

extension UserFacility {
    func buidingName() -> String {
        if Common.currentLanguageArabic() {
            if self.buildingNameArabic.count > 0{
                 return self.buildingNameArabic
            }else {
                return self.buildingNameEnglish
            }
          
        } else {
            if self.buildingNameEnglish.count > 0 {
                return self.buildingNameEnglish
            } else {
                return self.buildingNameArabic
            }
           
        }
    }
}


public class FacilityElementDetails: EVObject {
    
    open var facilityElementId = ""
    open var facilityElementCount = ""
    open var facilityId = ""
   open var facilityElementCountId = ""
   
    
    required public init() {}
    
}



public class FacilityAttachments: EVObject {
    
    open var attachmentId = ""
    open var facilityId = ""
    open var name = ""
    open var inspectionReportId = ""
    open var attachmentTypeId = ""

    required public init() {}
    
}

public class ImageAttachments: EVObject {
    open var attachmentId = ""
    open var facilityId = ""
    open var name = ""
    open var inspectionReportId = ""
    open var attachmentTypeId = ""
    required public init() {}
    
}

public class ReportFacilitiesResposneModel: BaseResponseForModels {
    open var payload = FacilitiesPayload()
    required public init() {}
}

public class FacilitiesPayload: BaseResponseForModels {
    open var userFacility = [UserFacility]()
    required public init() {}
}


public class ReportInputDetails: EVObject {
    open var applicationNo = ""
    open var applicantId = ""
    open var serviceTypeId = ""
  
    
}
