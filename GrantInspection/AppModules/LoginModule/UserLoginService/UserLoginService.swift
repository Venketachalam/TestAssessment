//
//  UserLoginService.swift
//  Progress
//
//  Created by Muhammad Akhtar on 6/4/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import Foundation
import RxSwift

protocol LoginServiceProtocol {
    func signIn(with credentials: UserLoginRequest) -> Observable<User>
}

class LoginService: LoginServiceProtocol {
    func signIn(with credentials: UserLoginRequest) -> Observable<User> {
        return Observable.create { observer in
            let apiCommunication = APICommunication()
            let urlToHit = APICommunicationURLs.UserLoginURL(currentLanguage: "en")
            let peram = ["client_id":Common.client_id,
                         "client_secret":Common.client_secret,
                         "grant_type":"password",
                         "username":credentials.username,
                         "password":credentials.password]
          
            
            if (credentials.username == "") || (credentials.password == "") {
                return Disposables.create()
            }
            
          
            apiCommunication.dataInStringFromURL(url: urlToHit, requestType: .post,paramsIfAny:peram, authenticationType:.Normal) { (_ response: APIBaseResponse?)  in
                              
              var userLoginResponce : User? = nil
             
                userLoginResponce = User(json: response?.responseString)
                userLoginResponce?.statusCode = (response?.httpStatusCode) ?? 0
                userLoginResponce?.message = (response?.responseString) ?? ""
                observer.onNext(userLoginResponce ?? User())
                observer.onCompleted()
              
              Common.appDelegate.appLog.info("login-Api-call")
              Common.appDelegate.appLog.debug(urlToHit)
              Common.appDelegate.appLog.debug(response)
              
            }
            
            //observer.onNext(User()) // Simulation of successful user authentication.
            return Disposables.create()
        }
    }
}

