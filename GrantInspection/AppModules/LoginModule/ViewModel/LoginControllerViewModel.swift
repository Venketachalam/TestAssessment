//
//  LoginViewControllerViewModel.swift
//  Progress
//
//  Created by Muhammad Akhtar on 10/16/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import RxSwift

class LoginControllerViewModel: ViewModelProtocol {

    struct Input {
        let email: AnyObserver<String>
        let password: AnyObserver<String>
        let rememberMeVal: AnyObserver<Bool>
        let signInDidTap: AnyObserver<Void>
    }
    struct Output {
        let loginResultObservable: Observable<User>
        let errorsObservable: Observable<Error>
        
    }
    
    // MARK: - Public properties
    let input: Input
    let output: Output
    
    // MARK: - Private properties
    private let userNameSubject = PublishSubject<String>()
    private let passwordSubject = PublishSubject<String>()
    private let rememberMeSubject = PublishSubject<Bool>()
    private let signInDidTapSubject = PublishSubject<Void>()
    private let loginResultSubject = PublishSubject<User>()
    private let errorsSubject = PublishSubject<Error>()
    private let disposeBag = DisposeBag()
    private var isRememberTrue = true
    
    
    private var credentialsObservable: Observable<UserLoginRequest> {
        return Observable.combineLatest(userNameSubject.asObservable(), passwordSubject.asObservable()) { (username, password) in
            return UserLoginRequest(username: username, password: password)
        }
    }
    
    // MARK: - Init and deinit
    init(_ loginService: LoginServiceProtocol) {
        
        input = Input(email: userNameSubject.asObserver(),
                      password: passwordSubject.asObserver(), rememberMeVal: rememberMeSubject.asObserver(),
                      signInDidTap: signInDidTapSubject.asObserver())
        
        output = Output(loginResultObservable: loginResultSubject.asObservable(),
                        errorsObservable: errorsSubject.asObservable())
        
        
        rememberMeSubject.asObserver()
            .subscribe (onNext: { switchValue in
                //print("This is new SwitchValue: \(switchValue)")
                self.isRememberTrue = switchValue
            }).disposed(by: disposeBag)
        
        signInDidTapSubject
            .withLatestFrom(credentialsObservable)
            .flatMapLatest { credentials in
                
                return loginService.signIn(with: credentials).materialize()
            }
            .subscribe(onNext: { [weak self] event in
                switch event {
                case .next(let user):
                    if user.success {
                        if  (self?.isRememberTrue)! {
                            Common.userDefaults.setIsRemember(isRemember: true)
                            Common.userDefaults.saveUserModel(user)
                        } else {
                            Common.userDefaults.setIsRemember(isRemember: false)
                            SharedResources.sharedInstance.currentUser = user
                        }
                        Common.userDefaults.saveLogInStatus(isLogedIn: true)
                        SharedResources.sharedInstance.loadAllVariables(isFromAppDelegate: false)
                    }
                    self?.loginResultSubject.onNext(user)
                    
                    //print(user)
                case .error(let error):
                    Common.userDefaults.setIsRemember(isRemember: false)
                    Common.userDefaults.saveLogInStatus(isLogedIn: false)
                    self?.errorsSubject.onNext(error)
                    //print(error)
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
