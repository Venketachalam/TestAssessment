//
//  PaymentSummaryService.swift
//  Progress
//
//  Created by Muhammad Akhtar on 1/2/19.
//  Copyright © 2019 MBRHE. All rights reserved.
//


import UIKit
import RxSwift

protocol PaymentDetailServiceProtocol {
    func getPaymentDetailData(with paymentId: String ) -> Observable<PaymentDetailModel>
}

class PaymentDetailService: PaymentDetailServiceProtocol {
    func getPaymentDetailData(with paymentId: String) -> Observable<PaymentDetailModel> {
        return Observable.create { observer in
            let apiCommunication = APICommunication()
            let urlToHit = APICommunicationURLs.getPaymentDetailURL(currentLanguage: "en", paymentId: paymentId)
            apiCommunication.dataInStringFromURL(url: urlToHit, requestType: .get) { (_ response: APIBaseResponse?)  in
                var paymentDetailResponse: PaymentDetailModel? = nil
                paymentDetailResponse = PaymentDetailModel(json: response?.responseString)
                observer.onNext(paymentDetailResponse!)
                observer.onCompleted()
                
            }
            return Disposables.create()
        }
    }
    
}
