//
//  SatelliteServiceCall.swift
//  GrantInspection
//
//  Created by Gopalakrishnan Chinnadurai on 08/10/19.
//  Copyright © 2019 MBRHE. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

protocol CoordinatesServiceProtocol {
    
    func saveSatelliteCoordinate(inputValues: SatelliteInputModel) -> Observable<BaseResponseForModels>
    func getSatelliteCoordinate(applicationID: String,applicationNo: String,serviceTypeID: String) -> Observable<SatelliteResponseModel>
   
}

class SatelliteServiceCall : CoordinatesServiceProtocol {
    
    func saveSatelliteCoordinate(inputValues: SatelliteInputModel) -> Observable<BaseResponseForModels> {
        return Observable.create { observer in
            
            let apiCommunication = APICommunication()
            let urlToHit = APICommunicationURLs.postSatelliteCoordinates()
            
            let param : [String : Any] = inputValues.toDictionary() as! [String : Any]
            
            print("\n\nSatellite_Param:::      ", param)
            apiCommunication.dataInStringFromURL(url: urlToHit, requestType: .post, paramsIfAny: param, authenticationType: .AuthenticJsonType, completion: { (response) in
                
                print("HITTED_Resp   ", response)
                let obj = BaseResponseForModels(json: response?.responseString)
                observer.onNext(obj)
                observer.onCompleted()
            })
           
            return Disposables.create()
        }
    }
    
    func getSatelliteCoordinate(applicationID: String,applicationNo: String,serviceTypeID: String) -> Observable<SatelliteResponseModel> {
        
        return Observable.create { observer in
            
            let apiCommunication = APICommunication()
            var urlToHit = APICommunicationURLs.getSatelliteCoordinates(applicationNo: applicationNo, serviceTypeId: serviceTypeID, applicantId: applicationID)
            
            apiCommunication.dataInStringFromURL(url: urlToHit, requestType: .get, completion: { (response) in
                
                print("Get__HITTED_Resp   ", response)
                
                let obj = SatelliteResponseModel(json: response?.responseString)
                
                observer.onNext(obj )
                observer.onCompleted()
            })
            
            return Disposables.create()
        }
    }
}
