//
//  DeleteAttachmentModule.swift
//  GrantInspection
//
//  Created by Mohammed Hassan on 14/11/19.
//  Copyright © 2019 MBRHE. All rights reserved.
//

import RxSwift

struct AttachmentDeleteRequestInput {
    let facilityId: String
}

class AttachmentDeleteModule {
    
    struct InputAttachmentDeleteData {
           let attachmentIdInput: AnyObserver<String>
       }
    
    struct OutputAttachmentDeleteData {
        let attachmentDeleteSummaryResultObservable: Observable<BaseResponseForModels>
        let errorsObservable: Observable<Error>
    }
    
    let inputAttachmentDelete: InputAttachmentDeleteData
    let outputAttachmentDelete: OutputAttachmentDeleteData
    
    
    private let attachmentIdObserver = PublishSubject<String>()
    private let errorsSubject = PublishSubject<Error>()
    private let disposeBag = DisposeBag()
    
    var attachmentIDString = ""
    
    private let attachmentOutputResponse = PublishSubject<BaseResponseForModels>()
    
    init(_ services: DeleteAttachmentRequestProtocol) {
        
        inputAttachmentDelete = InputAttachmentDeleteData(attachmentIdInput: attachmentIdObserver.asObserver())
        
        outputAttachmentDelete = OutputAttachmentDeleteData(attachmentDeleteSummaryResultObservable: attachmentOutputResponse.asObserver(), errorsObservable: errorsSubject.asObserver())
        
        attachmentIdObserver.asObserver().subscribe(onNext: { (param) in
            self.attachmentIDString = param
        }).disposed(by: disposeBag)
        
        //     facility Delete api call
        attachmentIdObserver.flatMap { [weak self] _ in
            return services.deleteAttachmentRequestService(attachmentId: self!.attachmentIDString)
            } .subscribe(onNext: { [weak self] responce in
                
                if responce.success {
                    self?.attachmentOutputResponse.onNext(responce)
                }else{
                    self?.errorsSubject.onNext(NSError(domain: responce.message, code: responce.statusCode, userInfo: nil))
                }
                
            })
            .disposed(by: disposeBag)
        
    }
    
}
