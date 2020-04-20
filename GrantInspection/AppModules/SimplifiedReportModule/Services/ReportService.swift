//
//  ReportService.swift
//  GrantInspection
//
//  Created by Rajeswaran Thangaperumal on 04/09/2019.
//  Copyright © 2019 MBRHE. All rights reserved.
//

import UIKit
import RxSwift

protocol ReportServiceProtocol {

    
    func getFacilitiesList() -> Observable<FacilityResposeModel>
    func getSimplifiedReport(requestParam:Dashboard) -> Observable<InspectionGetReportResposeModel>
    func createSimplifiedReport(requestParam:[String:Any]) -> Observable<InspectionReportRequestPayload>
    func getReportFacilitiesList(reportId:String) -> Observable<ReportFacilitiesResposneModel>
    func saveReportStatus(requestParam:[String:Any]) -> Observable<BaseResponseForModels>
    
}

class ReportService: ReportServiceProtocol {
    func saveReportStatus(requestParam:[String:Any]) -> Observable<BaseResponseForModels> {
        return Observable.create { observer in
            
            let apiCommunication = APICommunication()
            let urlToHit = APICommunicationURLs.saveReportStatus()
            apiCommunication.dataInStringFromURL(url: urlToHit, requestType: .post, paramsIfAny: requestParam, authenticationType: .Authentic, completion: { (response) in
                var facilitiesListResponse: BaseResponseForModels? = nil
                guard let requestResponse = response else {
                    let error = NSError(domain:"the_request_timed_out".ls, code:0, userInfo: nil)
                    observer.onError(error)
                    return
                }
                
                if !requestResponse.handleErrorsIfAny(response: requestResponse) {
                    facilitiesListResponse = BaseResponseForModels(json: response?.responseString)
                    
                    Common.appDelegate.appLog.debug(response?.responseString)
                    
                    Common.appDelegate.appLog.debug(urlToHit)
                    
                    Common.appDelegate.appLog.debug(facilitiesListResponse)
                    
                    observer.onNext(facilitiesListResponse!)
                    observer.onCompleted()
                }else {
                    facilitiesListResponse = BaseResponseForModels(json: response?.responseString)
                    let error = NSError(domain: facilitiesListResponse!.message, code:500, userInfo: nil)
                    observer.onError(error)
                }
            })
            
            
            return Disposables.create()
        }
    }
    
    func createSimplifiedReport(requestParam:[String:Any]) -> Observable<InspectionReportRequestPayload> {
        return Observable.create { observer in
            
            let apiCommunication = APICommunication()
            let urlToHit = APICommunicationURLs.createInspectionReport()
            apiCommunication.dataInStringFromURL(url: urlToHit, requestType: .post, paramsIfAny: requestParam, authenticationType: .AuthenticJsonType, completion: { (response) in
                var facilitiesListResponse: InspectionReportRequestPayload? = nil
                guard let requestResponse = response else {
                    let error = NSError(domain: "the_request_timed_out".ls, code:0, userInfo: nil)
                    observer.onError(error)
                   // observer.onCompleted()
                    return
                }
                
                if !requestResponse.handleErrorsIfAny(response: requestResponse) {
                    facilitiesListResponse = InspectionReportRequestPayload(json: response?.responseString)
                    
                    Common.appDelegate.appLog.debug(response?.responseString)
                    
                    Common.appDelegate.appLog.debug(urlToHit)
                    
                    Common.appDelegate.appLog.debug(facilitiesListResponse)
                    
                    observer.onNext(facilitiesListResponse!)
                    observer.onCompleted()
                }else {
                    facilitiesListResponse = InspectionReportRequestPayload(json: response?.responseString)
                    let error = NSError(domain: facilitiesListResponse!.message, code:500, userInfo: nil)
                    observer.onError(error)
                    //observer.onCompleted()
                }
            })
            
            
            return Disposables.create()
        }
    }
    
    
    func getSimplifiedReport(requestParam:Dashboard) -> Observable<InspectionGetReportResposeModel> {
        return Observable.create { observer in
            
            let apiCommunication = APICommunication()
            let urlToHit = APICommunicationURLs.getInspectionReport(requestParam: requestParam)
            apiCommunication.dataInStringFromURL(url: urlToHit, requestType: .get, completion: { (response) in
                var facilitiesListResponse: InspectionGetReportResposeModel? = nil
                guard let requestResponse = response else {
                    let error = NSError(domain: "the_request_timed_out".ls, code:0, userInfo: nil)
                    observer.onError(error)
                    return
                }
    
                if !requestResponse.handleErrorsIfAny(response: requestResponse) {
                    facilitiesListResponse = InspectionGetReportResposeModel(json: response?.responseString)
                    Common.appDelegate.appLog.debug(response?.responseString)
                    Common.appDelegate.appLog.debug(urlToHit)
                    Common.appDelegate.appLog.debug(facilitiesListResponse)
                    observer.onNext(facilitiesListResponse!)
                    observer.onCompleted()
                }else {
                    facilitiesListResponse = InspectionGetReportResposeModel(json: response?.responseString)
                    let error = NSError(domain: facilitiesListResponse!.message, code:500, userInfo: nil)
                    observer.onError(error)
                }
            })
            
            return Disposables.create()
        }
    }
    
    func getFacilitiesList() -> Observable<FacilityResposeModel> {
        
        return Observable.create { observer in
            
            let apiCommunication = APICommunication()
            let urlToHit = APICommunicationURLs.getFacilitiesList(currentLanguage: "en")
            apiCommunication.dataInStringFromURL(url: urlToHit, requestType: .get, completion: { (response) in
                var facilitiesListResponse: FacilityResposeModel? = nil
                
                facilitiesListResponse = FacilityResposeModel(json: response?.responseString)
                observer.onNext(facilitiesListResponse!)
                observer.onCompleted()
            })
            
            return Disposables.create()
        }
    }
    
    func getReportFacilitiesList(reportId:String) -> Observable<ReportFacilitiesResposneModel> {
        
        return Observable.create { observer in
            
            let apiCommunication = APICommunication()
            let urlToHit = APICommunicationURLs.getReportFacilities(reportID:reportId )
            apiCommunication.dataInStringFromURL(url: urlToHit, requestType: .get, completion: { (response) in
                var facilitiesListResponse: ReportFacilitiesResposneModel? = nil
                
                guard let requestResponse = response else {
                    let error = NSError(domain: "the_request_timed_out".ls, code:0, userInfo: nil)
                    observer.onError(error)
                    return
                }
                
                
                if !requestResponse.handleErrorsIfAny(response: requestResponse) {
                    facilitiesListResponse = ReportFacilitiesResposneModel(json: response?.responseString)
                    
                    Common.appDelegate.appLog.debug(response?.responseString)
                    Common.appDelegate.appLog.debug(urlToHit)
                    Common.appDelegate.appLog.debug(facilitiesListResponse)
                    observer.onNext(facilitiesListResponse!)
                    observer.onCompleted()
                    
                }else {
                    facilitiesListResponse = ReportFacilitiesResposneModel(json: response?.responseString)
                    let error = NSError(domain: facilitiesListResponse!.message, code:500, userInfo: nil)
                    observer.onError(error)
                }
            })
            return Disposables.create()
        }
    }
    
   
    
}

