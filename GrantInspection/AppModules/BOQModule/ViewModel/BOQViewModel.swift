//
//  DashboardViewModel.swift
//  Progress
//
//  Created by Muhammad Akhtar on 10/21/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import RxSwift

class BOQViewModel: ViewModelProtocol {
  struct Input {
    let projectId: AnyObserver<String>
    let paymentId: AnyObserver<String>
    let workID: AnyObserver<String>
    let comment: AnyObserver<String>
    let engineerPercentage: AnyObserver<String>
  }
  struct Output {
    let paymentBOQResultObservable: Observable<BOQContractResponse>
    let addPercentageResultObservable: Observable<BaseResponseForModels>
    let errorsObservable: Observable<Error>
    
  }
  // MARK: - Public properties
  let input: Input
  let output: Output
  
  // MARK: - Private properties
  private let projectIdSubject = PublishSubject<String>()
  private let paymentIdSubject = PublishSubject<String>()
  private let workIDSubject = PublishSubject<String>()
  private let commentSubject = PublishSubject<String>()
  private let engineerPercentageSubject = PublishSubject<String>()
  
  private let paymentBOQResultSubject = PublishSubject<BOQContractResponse>()
  private let addPercentageResultSubject = PublishSubject<BaseResponseForModels>()
  private let errorsSubject = PublishSubject<Error>()
  private let disposeBag = DisposeBag()
  
  var projectId = ""
  var paymentId = ""
  var pId = ""
  var workID = ""
  var engineerPercentage = ""
  var commentTxt = ""
  var request: BOQCommentRequest = BOQCommentRequest(contractId: "", paymentId: "", paymentDetailId: "", workID: "",comment:"",engeeringPercentage:"")
  
  
  // MARK: - Init and deinit
  init(_ service: BillOfQuantityProtocol) {
    
    input = Input(projectId: projectIdSubject.asObserver(),paymentId: paymentIdSubject.asObserver(), workID: workIDSubject.asObserver(), comment: commentSubject.asObserver(), engineerPercentage: engineerPercentageSubject.asObserver())
    
    output = Output(paymentBOQResultObservable: paymentBOQResultSubject.asObservable(),addPercentageResultObservable: addPercentageResultSubject.asObserver(),errorsObservable: errorsSubject.asObservable())
    
    projectIdSubject.asObserver()
      .subscribe (onNext: { [weak self] _id in
        self?.projectId = _id

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
        
      })
      .disposed(by: disposeBag)
    
    engineerPercentageSubject.asObserver()
      .subscribe (onNext: { [weak self] percentage in
        self?.engineerPercentage = percentage
        self?.request = BOQCommentRequest(contractId : (self?.projectId)!,paymentId: (self?.paymentId)!, paymentDetailId: (self?.pId)!, workID: (self?.workID)!,comment:(self?.commentTxt)!,engeeringPercentage:(self?.engineerPercentage)!)
      })
      .disposed(by: disposeBag)
    
    
    engineerPercentageSubject
      .flatMap { [weak self] _ in
        return service.addPercentageNotes(with: (self?.request)!)
      }
      .subscribe(onNext: { [weak self] responce in

        if responce.success {
          self?.addPercentageResultSubject.onNext(responce)
        }else{
          self?.errorsSubject.onNext(NSError(domain: responce.message, code: responce.statusCode, userInfo: nil))
          
        }
      })
      .disposed(by: disposeBag)
    
    
    projectIdSubject
      .flatMap { [weak self] _ in
        return service.getBOQData(with: (self?.projectId)!, paymentId: (self?.paymentId)!) }
      .subscribe(onNext: { [weak self] responce in
      
        if responce.success {
          self?.paymentBOQResultSubject.onNext(responce)
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

