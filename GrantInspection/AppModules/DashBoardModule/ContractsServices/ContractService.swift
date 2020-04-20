//
//  ContractService.swift
//  Progress
//
//  Created by Muhammad Akhtar on 6/6/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import UIKit
import RxSwift

protocol DashboardServiceProtocol {
    func getContracts(with data: DashBoardApiRequest ) -> Observable<ContractsResponse>
}

class ContractsService: DashboardServiceProtocol {
    open func getContracts(with data: DashBoardApiRequest) -> Observable<ContractsResponse>{
        return Observable.create { observer in

            let apiCommunication = APICommunication()
            let urlToHit = APICommunicationURLs.getPaymentsURL(currentLanguage: "en",page: data.page)
           apiCommunication.dataInStringFromURL(url: urlToHit, requestType: .get) { (_ response: APIBaseResponse?)  in
                var contractsResponse:  ContractsResponse? = nil
            
            print("DAsh_bpoar_URL     ", urlToHit)
            
                guard let requestResponse = response else {
                    let error = NSError(domain: "the_request_timed_out".ls, code:0, userInfo: nil)
                    observer.onError(error)
                    return
                }
         
            
                if !requestResponse.handleErrorsIfAny(response: requestResponse) {
                    contractsResponse = ContractsResponse(json: response?.responseString)
                  
                  Common.appDelegate.appLog.debug(response?.responseString)
                  
                  Common.appDelegate.appLog.info("dashboard-Api-call")
                  Common.appDelegate.appLog.debug(urlToHit)
                  Common.appDelegate.appLog.debug(data)
                  Common.appDelegate.appLog.debug(contractsResponse)
                  
                    observer.onNext(contractsResponse!)
                    observer.onCompleted()
                }else {
                     contractsResponse = ContractsResponse(json: response?.responseString)
                    let error = NSError(domain: contractsResponse!.message, code:500, userInfo: nil)
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }
}




