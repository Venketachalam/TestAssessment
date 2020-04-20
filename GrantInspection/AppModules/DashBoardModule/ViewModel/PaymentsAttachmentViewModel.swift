  //
//  PaymentsAttachmentViewModel.swift
//  Progress
//
//  Created by Muhammad Akhtar on 11/06/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import RxSwift

class PaymentsAttachmentViewModel: ViewModelProtocol {
    
    struct Input {
        let paymentId: AnyObserver<String>
        let contractId: AnyObserver<String>
    }
    struct Output {
        let paymentAttachmentsResultObservable: Observable<AttachmentPayload>
        let errorsObservable: Observable<Error>
        
    }
    // MARK: - Public properties
    let input: Input
    let output: Output
    
    // MARK: - Private properties
    private let paymentIdSubject = PublishSubject<String>()
    private let contractIdSubject = PublishSubject<String>()
    private let paymentAttachmentsResultSubject = PublishSubject<AttachmentPayload>()
    private let errorsSubject = PublishSubject<Error>()
    private let disposeBag = DisposeBag()
    var paymentId = ""
    var contractId = ""
  
    // MARK: - Init and deinit
    init(_ service: PaymentAttachmentsService) {
        
        input = Input(paymentId: paymentIdSubject.asObserver(), contractId : contractIdSubject.asObserver())
        
        output = Output(paymentAttachmentsResultObservable: paymentAttachmentsResultSubject.asObservable(),
                        errorsObservable: errorsSubject.asObservable())
      
      
      contractIdSubject.asObserver()
        .subscribe (onNext: { [weak self] _id in
          self?.contractId = _id
          //print(_id)
        })
        .disposed(by: disposeBag)
      
      
      paymentIdSubject.asObserver()
        .subscribe (onNext: { [weak self] _id in
          self?.paymentId = _id
          //print(_id)
        })
        .disposed(by: disposeBag)
      
        paymentIdSubject.flatMap { [weak self] _ in
                
          return service.getPaymentAttachments(with: (self?.contractId)!,paymentId: (self?.paymentId)! )
            }
            .subscribe(onNext: { [weak self] responce in
               print(responce)
              
                if responce.success {
                    self?.paymentAttachmentsResultSubject.onNext(responce.payload.attachmentPayload)
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

