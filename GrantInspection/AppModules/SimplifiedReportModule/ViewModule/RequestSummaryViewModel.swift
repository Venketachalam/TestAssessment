//
//  RequestSummaryViewModel.swift
//  GrantInspection
//
//  Created by Rajeswaran Thangaperumal on 02/09/2019.
//  Copyright © 2019 MBRHE. All rights reserved.
//


import RxSwift

struct RequestSummaryInput {
    let applicationID: String
    let applicationNo: String
}

class RequestSummaryViewModel {
    
    struct Input {
        let applicationNo: AnyObserver<String>
        let applicantId: AnyObserver<String>
        let serviceType: AnyObserver<String>
    }
    
    struct Output {
        let requestSummaryResultObservable: Observable<RequestDetailModel>
        let errorsObservable: Observable<Error>
    }
    
    // MARK: - Public properties
    let input: Input
    let output: Output
    
    private let applicationID = PublishSubject<String>()
    private let applicationNo = PublishSubject<String>()
    private let serviceTypeID = PublishSubject<String>()
    
    private let requestSummarySubject = PublishSubject<RequestDetailModel>()
   
    private let errorsSubject = PublishSubject<Error>()
    private let disposeBag = DisposeBag()
    
    var request = RequestSummaryInput(applicationID: "", applicationNo: "")
    
    var appIDValue = ""
    var applicationNoValue = ""
    var serviceTypeIDValue = ""
    
    private var summaryInputObservable: Observable<RequestSummaryInput> {
        
        return Observable.combineLatest(applicationID.asObservable(), applicationNo.asObservable() ) { (appID, appNo) in
            
            return RequestSummaryInput(applicationID: appID, applicationNo: appNo)
        }
    }
    
    
     init(_ service: RequestServiceProtocol) {
        
        input = Input(applicationNo: applicationNo.asObserver(), applicantId: applicationID.asObserver(), serviceType: serviceTypeID.asObserver())
        output = Output(requestSummaryResultObservable: requestSummarySubject.asObserver(), errorsObservable: errorsSubject.asObserver())
      
        
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
      serviceTypeID
            .flatMap { [weak self] _ in
                
                return service.getRequestSummary(applicationID: self?.appIDValue ?? "", applicationNo: self?.applicationNoValue ?? "", serviceTypeID: self?.serviceTypeIDValue ?? "")
                
            }
        
            .subscribe(onNext: { [weak self] responce in
                if responce.success {
                    self?.requestSummarySubject.onNext(responce)
                }else{
                    self?.errorsSubject.onNext(NSError(domain: responce.message, code: responce.statusCode, userInfo: nil))
                }
                
            })
            .disposed(by: disposeBag)
        }
        else{
           Common.showToaster(message: "no_Internet".ls)
        }
    }
    
    deinit {
        print("\(self) dealloc")
    }
}


