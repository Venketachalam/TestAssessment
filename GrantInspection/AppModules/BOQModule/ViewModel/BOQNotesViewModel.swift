//
//  PaymentNotesViewModel.swift
//  Progress
//
//  Created by Muhammad Akhtar on 11/13/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import RxSwift


class BOQNotesViewModel: ViewModelProtocol {
    
    struct Input {
        let contractId: AnyObserver<String>
        let paymentId: AnyObserver<String>
        let pId: AnyObserver<String>
        let workID: AnyObserver<String>
        let comment: AnyObserver<String>
        let engineerPercentage: AnyObserver<String>
        let addCommentDidTap: AnyObserver<Void>
    }
    struct Output {
        let boqNotesResultObservable: Observable<BaseResponseForModels>
        let boqCommentsResultObservable: Observable<PaymenCommentsModelResponse>
        let errorsObservable: Observable<Error>
        
    }
    // MARK: - Public properties
    let input: Input
    let output: Output
    
    // MARK: - Private properties
    private let contractIdSubject = PublishSubject<String>()
    private let paymentIdSubject = PublishSubject<String>()
    private let pIdSubject = PublishSubject<String>()
    private let workIDSubject = PublishSubject<String>()
    private let commentSubject = PublishSubject<String>()
    private let engineerPercentageSubject = PublishSubject<String>()
    private let addCommentSubject = PublishSubject<Void>()
    
    private let boqNotesResultSubject = PublishSubject<BaseResponseForModels>()
    private let boqCommentsResultSubject = PublishSubject<PaymenCommentsModelResponse>()
    private let errorsSubject = PublishSubject<Error>()
    private let disposeBag = DisposeBag()
    
    var contractId = ""
    var paymentId = ""
    var pId = ""
    var workID = ""
    var engineerPercentage = ""
    var commentTxt = ""
  
  var request: BOQCommentRequest = BOQCommentRequest(contractId: "", paymentId: "", paymentDetailId:"", workID: "",comment:"",engeeringPercentage:"")
  
    
    // MARK: - Init and deinit
    init(_ service: BOQNotesServiceProtocol) {
        
      input = Input(contractId: contractIdSubject.asObserver(), paymentId:paymentIdSubject.asObserver(), pId: pIdSubject.asObserver(),workID:workIDSubject.asObserver() , comment :commentSubject.asObserver() , engineerPercentage : engineerPercentageSubject.asObserver() , addCommentDidTap : addCommentSubject.asObserver())
      
        
      output = Output(boqNotesResultObservable: boqNotesResultSubject.asObservable(), boqCommentsResultObservable: boqCommentsResultSubject.asObserver(),errorsObservable: errorsSubject.asObservable())
      
      contractIdSubject.asObserver()
        .subscribe (onNext: { [weak self] _contractId in
          self?.contractId = _contractId
        })
        .disposed(by: disposeBag)
      
        paymentIdSubject.asObserver()
            .subscribe (onNext: { [weak self] _id in
                self?.paymentId = _id
            })
            .disposed(by: disposeBag)
       
        workIDSubject.asObserver()
            .subscribe (onNext: { [weak self] _id in
                self?.workID = _id
            })
            .disposed(by: disposeBag)
      
      commentSubject.asObserver()
        .subscribe (onNext: { [weak self] _comment in
          self?.commentTxt = _comment
          
          self?.request = BOQCommentRequest(contractId: (self?.contractId)!, paymentId: (self?.paymentId)!, paymentDetailId: (self?.pId)!, workID: (self?.workID)!,comment:(self?.commentTxt)!,engeeringPercentage:(self?.engineerPercentage)!)
        })
        .disposed(by: disposeBag)
      
        engineerPercentageSubject.asObserver()
            .subscribe (onNext: { [weak self] percentage in
                self?.engineerPercentage = percentage
            })
            .disposed(by: disposeBag)
        
      
        addCommentSubject
            .flatMap { [weak self] _ in
              
                return service.addBOQNotes(with: (self?.request)!)
            }
            .subscribe(onNext: { [weak self] responce in
  
              if responce.success {
                  
                  self?.boqNotesResultSubject.onNext(responce)
                }else{
                    self?.errorsSubject.onNext(NSError(domain: responce.message, code: responce.statusCode, userInfo: nil))
                }
                
            })
            .disposed(by: disposeBag)
      
      
      pIdSubject.asObserver()
        .subscribe (onNext: { [weak self] _pId in
          self?.pId = _pId
          
          self?.request = BOQCommentRequest(contractId: (self?.contractId)!, paymentId:(self?.paymentId)!, paymentDetailId: (self?.pId)!, workID:(self?.workID)!, comment:(self?.commentTxt)!, engeeringPercentage: "")
          
        })
        .disposed(by: disposeBag)
      
      pIdSubject
        .flatMap { [weak self] _ in
          
          return service.fetchPaymentNotes(with: (self?.request)!)
        }
        .subscribe(onNext: { [weak self] responce in
          if responce.success {
            self?.boqCommentsResultSubject.onNext(responce)
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

