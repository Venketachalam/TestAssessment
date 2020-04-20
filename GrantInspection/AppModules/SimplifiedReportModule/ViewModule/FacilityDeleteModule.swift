//
//  FacilityDeleteModule.swift
//  GrantInspection
//
//  Created by Mohammed Hassan on 15/10/19.
//  Copyright © 2019 MBRHE. All rights reserved.
//

import RxSwift

struct FacilityDeleteRequestInput {
    let facilityId: String
}

class FacilityDeleteModule {
    
    struct InputFacilityDeleteData {
        let facilityIdInput: AnyObserver<String>
    }
    
    struct OutputFacilityDeleteData {
        let facilityDeleteSummaryResultObservable: Observable<BaseResponseForModels>
        let errorsObservable: Observable<Error>
    }
    
    let inputFacilityDelete: InputFacilityDeleteData
    let outputFacilityDelete: OutputFacilityDeleteData
    
    private let facilityIdObserver = PublishSubject<String>()
    private let errorsSubject = PublishSubject<Error>()
    private let disposeBag = DisposeBag()
    
    var facilityIDString = ""
    
    private let facilityOutputResponse = PublishSubject<BaseResponseForModels>()
    
    init(_ service: DeleteFacilityRequestProtocol) {
        
        inputFacilityDelete = InputFacilityDeleteData(facilityIdInput: facilityIdObserver.asObserver())

        outputFacilityDelete = OutputFacilityDeleteData(facilityDeleteSummaryResultObservable: facilityOutputResponse.asObserver(), errorsObservable: errorsSubject.asObserver())
        
        facilityIdObserver.asObserver().subscribe(onNext: { (param) in
            self.facilityIDString = param
        }).disposed(by: disposeBag)
        
        //     facility Delete api call
        facilityIdObserver.flatMap { [weak self] _ in
            return service.deleteFacilityRequestService(facilityId: self!.facilityIDString)
            } .subscribe(onNext: { [weak self] responce in
                
                if responce.success {
                    self?.facilityOutputResponse.onNext(responce)
                }else{
                    self?.errorsSubject.onNext(NSError(domain: responce.message, code: responce.statusCode, userInfo: nil))
                }
                
            })
            .disposed(by: disposeBag)
    }
    
}
