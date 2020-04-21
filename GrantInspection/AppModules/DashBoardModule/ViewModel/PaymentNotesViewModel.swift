//
//  PaymentNotesViewModel.swift
//  Progress
//
//  Created by Muhammad Akhtar on 11/13/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import RxSwift

class PaymentNotesViewModel: ViewModelProtocol {
    
    struct Input {
        let paymentId: AnyObserver<String>
        let plotId: AnyObserver<String>
        let remark: AnyObserver<String>
        let contractorId: AnyObserver<String>
        let pId: AnyObserver<String>
        let addCommentDidTap: AnyObserver<Void>
    }
    struct Output {
        let paymentNotesResultObservable: Observable<BaseResponseForModels>
        let paymentCommentsResultObservable: Observable<PaymenCommentsModelResponse>
        let errorsObservable: Observable<Error>
        
    }
    // MARK: - Public properties
    let input: Input
    let output: Output
    
    // MARK: - Private properties
    private let paymentIdSubject = PublishSubject<String>()
    private let plotIdSubject = PublishSubject<String>()
    private let contractorIdSubject = PublishSubject<String>()
    private let pIdSubject = PublishSubject<String>()
    private let remarkSubject = PublishSubject<String>()
    private let addCommentSubject = PublishSubject<Void>()
    
    private let paymentNotesResultSubject = PublishSubject<BaseResponseForModels>()
    private let paymentCommentsResultSubject = PublishSubject<PaymenCommentsModelResponse>()
    private let errorsSubject = PublishSubject<Error>()
    private let disposeBag = DisposeBag()
    
    var paymentId = ""
    var plotId = ""
    var remarksTxt = ""
    var contractorId = ""
    var pId = ""
  
  var request:RemarkRequest = RemarkRequest(paymentId: "", plotId: "", remarks: "", pid: "", contractorId: "" )
    
    private var credentialsObservable: Observable<RemarkRequest> {
      
      return Observable.combineLatest(paymentIdSubject.asObservable(), plotIdSubject.asObservable(), remarkSubject.asObservable() ,pIdSubject.asObservable() ,contractorIdSubject.asObservable() ) { (paymId, pltId, remark,pdetailId,contId) in
         
          return RemarkRequest(paymentId:paymId, plotId:pltId, remarks:remark, pid: pdetailId, contractorId:contId)
        }
    }
    
    // MARK: - Init and deinit
    init(_ service: PaymentNotesServiceProtocol) {
        
        
      input = Input(paymentId: paymentIdSubject.asObserver(), plotId: plotIdSubject.asObserver(), remark: remarkSubject.asObserver(), contractorId: contractorIdSubject.asObserver(), pId: pIdSubject.asObserver(), addCommentDidTap: addCommentSubject.asObserver())
      
      output = Output(paymentNotesResultObservable: paymentNotesResultSubject.asObservable(), paymentCommentsResultObservable: paymentCommentsResultSubject.asObservable(),
                        errorsObservable: errorsSubject.asObservable())
        
      
        paymentIdSubject.asObserver()
            .subscribe (onNext: { [weak self] _id in
                self?.paymentId = _id
               //e print(self?.paymentId)
            })
            .disposed(by: disposeBag)
      
        contractorIdSubject.asObserver()
          .subscribe (onNext: { [weak self] _id in
          self?.contractorId = _id
          
          })
          .disposed(by: disposeBag)
      
        plotIdSubject.asObserver()
            .subscribe (onNext: { [weak self] _id in
                self?.plotId = _id
            })
            .disposed(by: disposeBag)
        
        remarkSubject.asObserver()
            .subscribe (onNext: { [weak self] note in
                self?.remarksTxt = note
                print(note)
              self?.request = RemarkRequest(paymentId:(self?.paymentId)!, plotId:(self?.plotId)!, remarks:(self?.remarksTxt)!, pid: "", contractorId: "")
            })
            .disposed(by: disposeBag)
        
        addCommentSubject
            .flatMap { [weak self] _ in
                
                return service.addPaymentNotes(with: (self?.request)!)
            }
            .subscribe(onNext: { [weak self] responce in
                if responce.success {
                    self?.paymentNotesResultSubject.onNext(responce)
                }else{
                    self?.errorsSubject.onNext(NSError(domain: responce.message, code: responce.statusCode, userInfo: nil))
                }
                
            })
            .disposed(by: disposeBag)
    
      
        pIdSubject.asObserver()
          .subscribe (onNext: { [weak self] _pId in
            self?.pId = _pId
            
            self?.request = RemarkRequest(paymentId:(self?.paymentId)!, plotId:(self?.plotId)!, remarks:(self?.remarksTxt)!, pid: (self?.pId)!, contractorId: (self?.contractorId)!)
            
          })
          .disposed(by: disposeBag)
      
      pIdSubject
        .flatMap { [weak self] _ in
          
          return service.fetchPaymentNotes(with: (self?.request)!)
        }
        .subscribe(onNext: { [weak self] responce in
          if responce.success {
            self?.paymentCommentsResultSubject.onNext(responce)
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



