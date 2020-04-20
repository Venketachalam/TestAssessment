//
//  DashboardViewModel.swift
//  Progress
//
//  Created by Muhammad Akhtar on 10/21/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import RxSwift

class DashboardViewModel: ViewModelProtocol {
    struct Input {
        let page: AnyObserver<String>
        let pageSize: AnyObserver<String>
        let viewLoad: AnyObserver<String>
    }
    struct Output {
        let dashBoardResultObservable: Observable<ContractsResponse>
        let errorsObservable: Observable<Error>
        
    }
    // MARK: - Public properties
    let input: Input
    let output: Output
    
    // MARK: - Private properties
    private let pageSubject = PublishSubject<String>()
    private let pagesizeSubject = PublishSubject<String>()
    private let viewLoadSubject = PublishSubject<String>()
    private let dashboardResultSubject = PublishSubject<ContractsResponse>()
    private let errorsSubject = PublishSubject<Error>()
    private let disposeBag = DisposeBag()
    

    private var credentialsObservable: Observable<DashBoardApiRequest> {
        return Observable.combineLatest(pageSubject.asObservable(), pagesizeSubject.asObservable()) { (page, pageSize) in
            return DashBoardApiRequest(page: page, pageSize: pageSize)
        }
    }
    
    func bindViewDidLoad(_ viewControllerDidLoad: Observable<Void>) {
        //Create observers which depend on viewControllerDidLoad
        //print("view did load .....")
    }
    
    // MARK: - Init and deinit
    init(_ dashBoardService: DashboardServiceProtocol) {
        
        input = Input(page: pageSubject.asObserver(), pageSize: pagesizeSubject.asObserver(), viewLoad: viewLoadSubject.asObserver())
        
        output = Output(dashBoardResultObservable: dashboardResultSubject.asObservable(),
                        errorsObservable: errorsSubject.asObservable())
        
        viewLoadSubject
            .withLatestFrom(credentialsObservable)
            .flatMap { credentials in
                return dashBoardService.getContracts(with: credentials).materialize()
            }
            .subscribe(onNext: { [weak self] event in
                switch event {
                case .next(let contracts):
                 self?.dashboardResultSubject.onNext(contracts)
                  print("dashBoardService result-here")
                case .error(let error):
                    self?.errorsSubject.onNext(error)
                print("error-here")
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
    }
    
    deinit {
        print("\(self) dealloc")
    }
}

