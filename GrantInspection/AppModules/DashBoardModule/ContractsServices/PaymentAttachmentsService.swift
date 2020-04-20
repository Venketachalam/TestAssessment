//
//  PaymentAttachmentsService.swift
//  Progress
//
//  Created by Muhammad Akhtar on 6/6/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import UIKit
import RxSwift
import EVReflection

protocol PaymentAttachmentServiceProtocol {
    func getPaymentAttachments(with contractId: String , paymentId: String) -> Observable<PaymentAttachmentsResponse>
}

class PaymentAttachmentsService: PaymentAttachmentServiceProtocol {
  
  func getPaymentAttachments(with contractId: String, paymentId: String) -> Observable<PaymentAttachmentsResponse> {
        return Observable.create { observer in
            
            let apiCommunication = APICommunication()
          let urlToHit = APICommunicationURLs.getPaymentAttachmentsURL(currentLanguage: "en", paymentId:paymentId,contractID :contractId)
          
            apiCommunication.dataInStringFromURL(url: urlToHit, requestType: .get) { (_ response: APIBaseResponse?)  in
            
                var paymentAttachmentsResponse: PaymentAttachmentsResponse? = nil
                EVReflection.setBundleIdentifier(AttachmentPayload.self)
                EVReflection.setBundleIdentifier(AttachmentModel.self)
                EVReflection.setBundleIdentifier(AttachmentItemModel.self)
                paymentAttachmentsResponse = PaymentAttachmentsResponse(json: response?.responseString)
                observer.onNext(paymentAttachmentsResponse!)
                observer.onCompleted()
              
              Common.appDelegate.appLog.debug(paymentAttachmentsResponse)
              Common.appDelegate.appLog.info("payment attachment list api")
              Common.appDelegate.appLog.debug(urlToHit)
              Common.appDelegate.appLog.debug(response)
                
            }
            return Disposables.create()
        }
    }

}
