//
//  PaymentDetailViewModel.swift
//  Progress
//
//  Created by Muhammad Akhtar on 1/2/19.
//  Copyright © 2019 MBRHE. All rights reserved.
//

import RxSwift

class PaymentDetailViewModel: ViewModelProtocol {
    
    struct Input {
        let paymentId: AnyObserver<String>
    }
    struct Output {
        let paymentSummaryResultObservable: Observable<PaymentDetailModel>
        let errorsObservable: Observable<Error>
        
    }
    // MARK: - Public properties
    let input: Input
    let output: Output
    
    // MARK: - Private properties
    private let paymentIdSubject = PublishSubject<String>()
    private let paymentSummaryResultSubject = PublishSubject<PaymentDetailModel>()
    private let errorsSubject = PublishSubject<Error>()
    private let disposeBag = DisposeBag()
    var paymentId = ""
    
    // MARK: - Init and deinit
    init(_ service: PaymentDetailService) {
        
        input = Input(paymentId: paymentIdSubject.asObserver())
        
        output = Output(paymentSummaryResultObservable: paymentSummaryResultSubject.asObservable(),
                        errorsObservable: errorsSubject.asObservable())
        
        paymentIdSubject.asObserver()
            .subscribe (onNext: { [weak self] _id in
                self?.paymentId = _id
            })
            .disposed(by: disposeBag)
        
        paymentIdSubject
            .flatMap { [weak self] _ in
                
                return service.getPaymentDetailData(with: (self?.paymentId)! )
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
