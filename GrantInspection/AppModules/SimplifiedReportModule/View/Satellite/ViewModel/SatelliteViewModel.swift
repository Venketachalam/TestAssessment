//
//  SatelliteViewModel.swift
//  GrantInspection
//
//  Created by Gopalakrishnan Chinnadurai on 08/10/19.
//  Copyright © 2019 MBRHE. All rights reserved.
//

import Foundation
import RxSwift

class SatelliteViewModel {
    
    struct Input {
        let postCoordinateRequest: AnyObserver<SatelliteInputModel> // FOR POST
        
        let applicationNo: AnyObserver<String> //FOR GET
        let applicantId: AnyObserver<String> //FOR GET
        let serviceType: AnyObserver<String> //FOR GET
    }
    
    struct Output {
        
        let coordinateResponse: Observable<BaseResponseForModels> // FOR POST
        
        let getCoordinateResponse: Observable<SatelliteResponseModel> // FOR GET
        
        let errorsObservable: Observable<Error> // FOR COMMON
    }
    
    // MARK: - Public properties
    
    let output: Output
    let input: Input
    
    private let applicationID = PublishSubject<String>()
    private let applicationNo = PublishSubject<String>()
    private let serviceTypeID = PublishSubject<String>()
    
    private let inputPostRequest = PublishSubject<SatelliteInputModel>()
    private let responseSubject = PublishSubject<BaseResponseForModels>()
    
    private let outputResponse = PublishSubject<SatelliteResponseModel>()
    
    private let errorsSubject = PublishSubject<Error>()
    private let disposeBag = DisposeBag()
    var satelliteInput = SatelliteInputModel()
    
    var appIDValue = ""
    var applicationNoValue = ""
    var serviceTypeIDValue = ""
    
    init(_ service: CoordinatesServiceProtocol) {
        
        input = Input(postCoordinateRequest: inputPostRequest.asObserver(), applicationNo: applicationNo.asObserver(), applicantId: applicationID.asObserver(), serviceType: serviceTypeID.asObserver())
        
        output = Output(coordinateResponse: responseSubject.asObserver(), getCoordinateResponse: outputResponse.asObserver(), errorsObservable: errorsSubject.asObserver())
        
        inputPostRequest.asObserver().subscribe(onNext: { [weak self] (value) in
                   self?.satelliteInput = value
            
               }).disposed(by: disposeBag)
        
        
        applicationID.asObserver().subscribe(onNext: { [weak self] (appID) in
              self?.appIDValue = appID
          }).disposed(by: disposeBag)
        
        applicationNo.asObserver().subscribe(onNext: { [weak self] (appNo) in
              self?.applicationNoValue = appNo
          }).disposed(by: disposeBag)
          
          serviceTypeID.asObserver().subscribe(onNext: { [weak self] (serviceType) in
              self?.serviceTypeIDValue = serviceType
          }).disposed(by: disposeBag)
        
        
        if Common.isConnectedToNetwork() == true
        {
            inputPostRequest
                .flatMap { [weak self] _ in
                    
                    return service.saveSatelliteCoordinate(inputValues: self!.satelliteInput)
                    
                }
                .subscribe(onNext: { [weak self] responce in
                    if responce.success {
                        self?.responseSubject.onNext(responce)
                    }else{
                        self?.errorsSubject.onNext(NSError(domain: responce.message, code: responce.statusCode, userInfo: nil))
                    }
                    
                })
                .disposed(by: disposeBag)
            
            serviceTypeID
                .flatMap { [weak self] _ in
                    
                    return service.getSatelliteCoordinate(applicationID: self?.appIDValue ?? "", applicationNo: self?.applicationNoValue ?? "", serviceTypeID: self?.serviceTypeIDValue ?? "")
                    
                }
                .subscribe(onNext: { [weak self] responce in
                    if responce.success {
                        self?.outputResponse.onNext(responce)
                    }else{
                        self?.errorsSubject.onNext(NSError(domain: responce.message, code: responce.statusCode, userInfo: nil))
                    }
                    
                })
                .disposed(by: disposeBag)
        }
        else{
            Common.showToaster(message: "no_Internet".ls )
        }
        
    }
    
    deinit {
        print("\(self) dealloc")
    }

}
