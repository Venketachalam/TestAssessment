//
//  APICommunicationURLs.swift
//  iskan
//
//  Created by Zeshan Hayder on 1/24/18.
//  Copyright © 2018 MRHE. All rights reserved.
//

import Foundation

public enum APIDomainType: String {
    case QA = "https://apiqa.mrhecloud.com/grants-inspect"//"https://api.mrhecloud.com/grants-inspect_"

   // case Production = "https://api.mrhecloud.com/grants-inspect"
    case Production = "https://api.mrhecloud.com/grants-inspect"

}

open class APICommunicationURLs : NSObject {
  
    internal static var domainType: APIDomainType = APIDomainType.Production
  
    public static var currentLanguage: String =  "en"

    public static let featuresURLQA = "https://git.mrhe.gov.ae/raw/mrhe/features-apps/master/monitoring-app-{QA}.json"
    public static let featuresURLPRO = "https://git.mrhe.gov.ae/raw/mrhe/features-apps/master/monitoring-app-{PROD}.json"

    public static func setApplicationEnviroment(_domainType: APIDomainType) {
        domainType = _domainType
    }
    
    public static var baseURL: String {
        get {
            return domainType.rawValue
        }
    }

    internal static func UserLoginURL(currentLanguage:String) -> String {
      

        let urlStr:String = String(format:"https://api.mrhecloud.com/auth/realms/mbrhe-ldap/protocol/openid-connect/token")

        return urlStr
    }

    internal static func getPaymentsURL(currentLanguage:String, page:String ) -> String {
        return "\(baseURL)/api/v1.0/inspection/maintenance/request/list?page=\(page)&pageSize=10"
    }
    
  
    internal static func getContractorPaymentURL() -> String {
    
        let urlString = "\(baseURL)/api/v1.0/inspection/maintenance/request/list/search?"
        return urlString
    }
  
  internal static func getPaymentAttachmentsURL(currentLanguage:String,paymentId:String,contractID : String) -> String {
        return String(format: "\(baseURL)/eng-review/api/v1.0/payments/contract/\(contractID)/payment/\(paymentId)/attachments")
    }
    
    internal static func getPaymentDetailURL(currentLanguage:String,paymentId:String) -> String {
        return String(format: "\(baseURL)/eng-review/api/v1.0/payments/contract/\(paymentId)/summary")
    }
    
    
    // SATELLITE COORDINATES
    internal static func postSatelliteCoordinates() -> String {
        return String(format: "\(baseURL)/api/v1.0/requests/facility/attachment/satellite/add")
    }
    internal static func getSatelliteCoordinates(applicationNo:String,serviceTypeId:String,applicantId:String) -> String {
        var url = URLComponents(string: "\(baseURL)/api/v1.0/requests/facility/attachment/satellite")!
        
        url.queryItems = [
            URLQueryItem(name: "applicationNo", value: applicationNo),
            URLQueryItem(name: "applicantId", value: applicantId),
            URLQueryItem(name: "serviceTypeId", value: serviceTypeId)
        ]
        
        url.percentEncodedQuery = url.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        return url.string ?? ""
    }
    
    internal static func getAttachmentURL(currentLanguage:String,attachmentId:String) -> String {
        return String(format: "\(baseURL)/eng-review/api/v1.0/payment/attachment/\(attachmentId)")
    }

    internal static func getUploadAttachmentURL(currentLanguage:String,attachmentId:String) -> String {
    
        return String(format: "\(baseURL)/eng-review/api/v1.0/payment/attachment/\(attachmentId)/add")
    }
    
    internal static func getPaymentNotesURL(currentLanguage:String,paymentId:String) -> String {
        return String(format: "\(baseURL)/eng-review/api/v1.0/payments/\(paymentId)/remark/add")
    }

  
  internal static func getBOQURL(contractId : String,paymentId:String) -> String {
        return String(format: "\(baseURL)/eng-review/api/v1.0/payments/contract/\(contractId)/payment/\(paymentId)/boq")
    }
    

  internal static func getPaymentSummaryURL(currentLanguage:String,paymentId:String,projectId:String) -> String {
    return String(format: "\(baseURL)/eng-review/api/v1.0/payments/contract/\(projectId)/payment/\(paymentId)/summary")
  }
  
  internal static func submitPaymentSummaryStatusURL(currentLanguage:String,contractId:String,paymentId:String,status:String) -> String {
    return String(format: "\(baseURL)/eng-review/api/v1.0/payments/contract/\(contractId)/payment/\(paymentId)/\(status)/status")
  }
  
    internal static func boqAddCommentURL(currentLanguage:String,contractId:String,paymentId:String,workID:String) -> String {
      return String(format: "\(baseURL)/eng-review/api/v1.0/payments/contract/\(contractId)/payment/\(paymentId)/work/\(workID)/boq/add")
    }
  
  internal static func fetchCommentURL(currentLanguage:String,contractId:String,paymentId:String,pId:String,type:String) -> String {
    
    return String(format: "\(baseURL)/eng-review/api/v1.0/payments/contract/\(contractId)/payment/\(paymentId)/paymentDetail/\(pId)/type/\(type)/remarks")
    
    
  }
  
  
    //MockUP URLs
    
    internal static func getContractsMockURL() -> String {
        return String(format:"https://21abdde6-9545-44bf-b294-edc9dc47e5a5.mock.pstmn.io/payments")
    }
    internal static func getContractPayemtsMockURL() -> String {
        return String(format:"https://487f45fd-3f3d-4d2d-a0cd-69da58096306.mock.pstmn.io/payments")
    }
    
    internal static func postGeoActivityDataAppNo(paymentId:String, appNo:String) -> String {
        
        // api/v1.0/payments/contract/payment/3689/application/10744/geo/status
         return String(format: "https://apiqa.mrhecloud.com/eng-review/api/v1.0/payments/contract/payment/\(paymentId)/application/\(appNo)/geo/status")
    }
    
    //Request Summary
    
    internal static func getRequestDetails(currentLanguage:String) -> String {
        
       return String(format: "\(baseURL)/api/v1.0/inspection/maintenance/request/summary")
    }
    
    internal static func getFacilitiesList(currentLanguage:String) -> String {
        
        return String(format: "\(baseURL)/api/v1.0/requests/facilities/list")
    }
    
    internal static func getSearchLocations(text:String,lang:String) -> String {
       var url = URLComponents(string: "\(baseURL)/api/v1.0/inspection/makani/searchByText")!
        url.queryItems = [
            URLQueryItem(name: "text", value: text),
            URLQueryItem(name: "local", value: lang)
        ]
        
        url.percentEncodedQuery = url.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        return url.string ?? ""
       
    }
    
    internal static func getLocationsFromPlotNumber(plotNo:String,applicationNo:String,serviceTypeId:String,applicantId:String ,plotNewNo:String) -> String {
       
        var url = URLComponents(string: "\(baseURL)/api/v1.0/inspection/makani/search")!
       
        if plotNewNo.isEmpty {
            url.queryItems = [
                URLQueryItem(name: "applicationNo", value: applicationNo),
                URLQueryItem(name: "plotNo", value: plotNo),
                URLQueryItem(name: "serviceTypeId", value: serviceTypeId),
                URLQueryItem(name: "applicantId", value: applicantId),
            ]
        }else
        {
            url.queryItems = [
                URLQueryItem(name: "applicationNo", value: applicationNo),
                URLQueryItem(name: "plotNo", value: plotNo),
                URLQueryItem(name: "serviceTypeId", value: serviceTypeId),
                URLQueryItem(name: "applicantId", value: applicantId),
                URLQueryItem(name: "plotNoNew", value: plotNewNo)
            ]
        }
        
        
        
        url.percentEncodedQuery = url.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        return url.string ?? ""
       
    }
    
    internal static func getLocationsFromLocationID(requestParam:AddLocationRequestModel) -> String {
        
        var url = URLComponents(string: "\(baseURL)/api/v1.0/inspection/makani/location")!
    
        url.queryItems = [
             URLQueryItem(name: "locationId", value: requestParam.locationId),
            URLQueryItem(name: "applicationNo", value: requestParam.applicationNo),
            URLQueryItem(name: "featureClassId", value: requestParam.featureClassId),
            URLQueryItem(name: "applicantId", value: requestParam.applicantId),
            URLQueryItem(name: "serviceTypeId", value: requestParam.serviceTypeId)
            
        ]
        
        url.percentEncodedQuery = url.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        return url.string ?? ""
        
    }
    
    internal static func getInspectionReport(requestParam:Dashboard) -> String {
        
        var url = URLComponents(string: "\(baseURL)/api/v1.0/requests/get/inspection/report")!
        
        url.queryItems = [
           
            URLQueryItem(name: "applicationNo", value: "\(requestParam.applicationNo)"),
            URLQueryItem(name: "applicantId", value: "\(requestParam.applicantId)"),
            URLQueryItem(name: "serviceTypeId", value: requestParam.serviceTypeId)
            
        ]
        
        url.percentEncodedQuery = url.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        return url.string ?? ""
        
    }
    
    internal static func getReportFacilities(reportID:String) -> String {
        
        var url = URLComponents(string: "\(baseURL)/api/v1.0/requests/getreportfacilities")!
    
        url.queryItems = [
            
            URLQueryItem(name: "inspectionReportId", value: reportID)
           
        ]
        
        url.percentEncodedQuery = url.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        return url.string ?? ""
    }
    
    internal static func createInspectionReport() -> String {
        
        let url = URLComponents(string: "\(baseURL)/api/v1.0/requests/post/inspection/report")!
    
        return url.string ?? ""
        
    }
    

    internal static func saveReportStatus() -> String {
        
        let url = URLComponents(string: "\(baseURL)/api/v1.0/requests/inspection/status/save")!

        return url.string ?? ""
        
    }
    
    internal static func uploadedAttachmentsFiles() -> String {
        
        let url = URLComponents(string: "\(baseURL)/api/v1.0/requests/facility/attachment/upload")!
        
        return url.string ?? ""
        
    }
    
    internal static func categoryListAttachments()->String {
        let url=URLComponents(string: "\(baseURL)/api/v1.0/requests/facility/attachment/category/list")!
        return url.string ?? ""

    }
    
    
    internal static func dashboardListAttachments(applicationNo:String,applicantID:String,serviceTypeID:String)->String {
        
        let urlString="https://apiqa.mrhecloud.com/FN_MS/api/v1.0/filenet/operations/executeDocSearch.mbrh?fnDocQuery=SELECT[This],[id],[ClassDescription],[DocumentTitle]FROM[MBRH_APPLICATIONS]WHERE[APPLICATION_NO]=\(applicationNo)AND[APPLICANT_ID]=\(applicantID)AND[SERVICE_TYPE]=\(serviceTypeID)"
        
        return urlString 
        
    }
    
    
    
    internal static func attachmentsViewFiles(requestParam:String) -> String {
        
        var url = URLComponents(string: "\(baseURL)/api/v1.0/requests/facility/attachment/view")!
        
        url.queryItems = [
            URLQueryItem(name: "attachmentId", value: "\(requestParam)"),
        ]
        
        url.percentEncodedQuery = url.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        
        return url.string ?? ""
        
    }
    
    
    internal static func downloadAttachment(guid:String,index:Int) -> String {
        
        var url = URLComponents(string: "\(baseURL)/api/v1.0/requests/facility/attachment/download")!

        url.queryItems = [
            URLQueryItem(name: "guid", value: guid),
            URLQueryItem(name: "index", value: "\(index)"),
        ]
        
        url.percentEncodedQuery = url.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        return url.string ?? ""
        
    }
    
    internal static func deleteFacilityFromTheReport(facilityID:String) -> String {
        
         var url = URLComponents(string: "\(baseURL)/api/v1.0/requests/delete/userfacility")!
        url.queryItems = [
            URLQueryItem(name: "facilityID", value: facilityID)
        ]
        
        url.percentEncodedQuery = url.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        return url.string ?? ""
        
    }
    
    internal static func deleteAttachmentFromTheFacility(attachmentId:String) -> String
    {
        var url = URLComponents(string: "\(baseURL)/api/v1.0/requests/facility/attachment/delete")!
        url.queryItems = [
            URLQueryItem(name: "attachmentId", value: attachmentId)
        ]
        
        url.percentEncodedQuery = url.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        return url.string ?? ""
    }
}
