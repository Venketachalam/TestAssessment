//
//  DashboardViewModel.swift
//  Progress
//
//  Created by Muhammad Akhtar on 10/21/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import RxSwift

class PaymentSummaryViewModel: ViewModelProtocol {
    struct Input {
        let projectId: AnyObserver<String>
        let paymentId: AnyObserver<String>
        let status: AnyObserver<String>
    }
    struct Output {
        let paymentSummaryResultObservable: Observable<PaymentSummaryResponse>
        let paymentSummaryStatusResultObservable: Observable<BaseResponseForModels>
        let errorsObservable: Observable<Error>
        
    }
    // MARK: - Public properties
    let input: Input
    let output: Output
    
    // MARK: - Private properties
    private let projectIdSubject = PublishSubject<String>()
    private let paymentIdSubject = PublishSubject<String>()
    private let paymentStatusSubject = PublishSubject<String>()
    private let paymentSummaryResultSubject = PublishSubject<PaymentSummaryResponse>()
    private let paymentSummaryStatusResultSubject = PublishSubject<BaseResponseForModels>()
  
    private let errorsSubject = PublishSubject<Error>()
    private let disposeBag = DisposeBag()
  
    var projectId = ""
    var paymentId = ""
    var status = ""
  
    // MARK: - Init and deinit
    init(_ service: PaymentSummaryProtocol) {
        
      input = Input(projectId: projectIdSubject.asObserver(),paymentId : paymentIdSubject.asObserver(), status: paymentStatusSubject.asObserver())
        
      output = Output(paymentSummaryResultObservable: paymentSummaryResultSubject.asObservable(), paymentSummaryStatusResultObservable: paymentSummaryStatusResultSubject.asObserver(),
                        errorsObservable: errorsSubject.asObservable())
        
        projectIdSubject.asObserver()
            .subscribe (onNext: { [weak self] _id in
                self?.projectId = _id
                //print(_id)
            })
            .disposed(by: disposeBag)
      
      
      paymentIdSubject.asObserver()
        .subscribe (onNext: { [weak self] _payment in
          self?.paymentId = _payment
        })
        .disposed(by: disposeBag)
      
      paymentStatusSubject.asObserver()
        .subscribe (onNext: { [weak self] _status in
          self?.status = _status
        })
        .disposed(by: disposeBag)
      
      
      paymentStatusSubject
        .flatMap { [weak self] _ in
       
          return service.submitPaymentStatus(with: (self?.projectId)!, paymentId: (self?.paymentId)!, status: (self?.status)!)
        }
        .subscribe(onNext: { [weak self] responce in
          if responce.success {
            self?.paymentSummaryStatusResultSubject.onNext(responce)
          }else{
            self?.errorsSubject.onNext(NSError(domain: responce.message, code: responce.statusCode, userInfo: nil))
          }
        })
        .disposed(by: disposeBag)
      
      
        projectIdSubject
            .flatMap { [weak self] _ in
              
              return service.getPaymentSummaryData(with:(self?.paymentId)!,projectID :(self?.projectId)!)
            }
            .subscribe(onNext: { [weak self] responce in
                if responce.success {
                  
                    self?.paymentSummaryResultSubject.onNext(responce)
                }else{
                    self?.errorsSubject.onNext(NSError(domain: responce.message, code: responce.statusCode, userInfo: nil))
                }
            })
            .disposed(by: disposeBag)
        
    }
    
    deinit {
        print("\(self) dealloc")
    }
}

