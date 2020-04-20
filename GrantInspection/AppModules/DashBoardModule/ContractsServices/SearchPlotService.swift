//
//  SearchPlotService.swift
//  GrantInspection
//
//  Created by Rajeswaran Thangaperumal on 08/09/2019.
//  Copyright © 2019 MBRHE. All rights reserved.
//

import RxSwift


protocol SearchPlotServiceProtocol {
    func getSearchLocations(_ searchText: String,_ searchLanguage: String ) -> Observable<SearchLocationModelResponse>
}

class SearchPlotService: SearchPlotServiceProtocol {
    func getSearchLocations(_ searchText: String,_ searchLanguage: String) -> Observable<SearchLocationModelResponse> {
        return Observable.create { observer in
            
            let apiCommunication = APICommunication()
            
            var currentLanguage = "" 

            print("Search language:\(searchLanguage)")
            print("Search searchText:\(searchText)")
            
            if (searchLanguage.contains("en"))
            {
                currentLanguage = "E"
            }
            else if (searchLanguage.contains("ar"))
            {
                currentLanguage = "A"
            }
            
            
            let urlToHit = APICommunicationURLs.getSearchLocations(text: searchText, lang: currentLanguage)

            apiCommunication.dataInStringFromURL(url: urlToHit, requestType: .get, completion: { (response) in
                var paymentDetailResponse: SearchLocationModelResponse? = nil
                
//                paymentDetailResponse = SearchLocationModelResponse(json: response?.responseString)
//                observer.onNext(paymentDetailResponse!)
//                observer.onCompleted()
//

               
                guard let requestResponse = response else {
                    let error = NSError(domain: "the_request_timed_out".ls, code:0, userInfo: nil)
                    observer.onError(error)
                    return
                }
                
                
                if !requestResponse.handleErrorsIfAny(response: requestResponse) {
                    paymentDetailResponse = SearchLocationModelResponse(json: response?.responseString)
                    
                    Common.appDelegate.appLog.debug(response?.responseString)
                    
                    Common.appDelegate.appLog.debug(urlToHit)
                   
                    Common.appDelegate.appLog.debug(paymentDetailResponse)
                    
                    observer.onNext(paymentDetailResponse!)
                    observer.onCompleted()
                }else {
                    paymentDetailResponse = SearchLocationModelResponse(json: response?.responseString)
                    let error = NSError(domain: paymentDetailResponse!.message, code:500, userInfo: nil)
                    observer.onError(error)
                }
            })

            
            return Disposables.create()
        }
    }
    
    func getSearchLocations(_ applicationNo: String,plotNo: String,serviceTypeId:String,applicantId:String,plotNewNo:String) -> Observable<PlotLocationModelResponse> {
        return Observable.create { observer in
            
            let apiCommunication = APICommunication()
            let urlToHit = APICommunicationURLs.getLocationsFromPlotNumber(plotNo: plotNo, applicationNo: applicationNo,serviceTypeId: serviceTypeId,applicantId:applicantId, plotNewNo:plotNewNo)
            
            apiCommunication.dataInStringFromURL(url: urlToHit, requestType: .get, completion: { (response) in
                var paymentDetailResponse: PlotLocationModelResponse? = nil
                
                paymentDetailResponse = PlotLocationModelResponse(json: response?.responseString)
                observer.onNext(paymentDetailResponse!)
                observer.onCompleted()
               
                
            })
            
            
            return Disposables.create()
        }
    }
    
    func getLocationDetailsFromLocationID(locationRequest: AddLocationRequestModel) -> Observable<PlotLocationModelResponse> {
        return Observable.create { observer in
            
            let apiCommunication = APICommunication()
            let urlToHit = APICommunicationURLs.getLocationsFromLocationID(requestParam: locationRequest )
            
            apiCommunication.dataInStringFromURL(url: urlToHit, requestType: .get, completion: { (response) in
                var paymentDetailResponse: PlotLocationModelResponse? = nil
                
//                paymentDetailResponse = PlotLocationModelResponse(json: response?.responseString)
//                observer.onNext(paymentDetailResponse!)
//                observer.onCompleted()
                
                guard let requestResponse = response else {
                    let error = NSError(domain: "the_request_timed_out".ls, code:0, userInfo: nil)
                    observer.onError(error)
                    return
                }
                
                
                if !requestResponse.handleErrorsIfAny(response: requestResponse) {
                    paymentDetailResponse = PlotLocationModelResponse(json: response?.responseString)
                    
                    Common.appDelegate.appLog.debug(response?.responseString)
                    
                    Common.appDelegate.appLog.debug(urlToHit)
                    
                    Common.appDelegate.appLog.debug(paymentDetailResponse)
                    
                    observer.onNext(paymentDetailResponse!)
                    observer.onCompleted()
                }else {
                    paymentDetailResponse = PlotLocationModelResponse(json: response?.responseString)
                    let error = NSError(domain: paymentDetailResponse!.message, code:500, userInfo: nil)
                    observer.onError(error)
                }
            })
            
            
            return Disposables.create()
        }
    }
    
//    func detectedLangauge(for string: String) -> String? {
//        let recognizer = NLLanguageRecognizer()
//        recognizer.processString(string)
//        guard let languageCode = recognizer.dominantLanguage?.rawValue else { return nil }
//        let detectedLangauge = Locale.current.localizedString(forIdentifier: languageCode)
//        return detectedLangauge
//    }
    
    
    
}


