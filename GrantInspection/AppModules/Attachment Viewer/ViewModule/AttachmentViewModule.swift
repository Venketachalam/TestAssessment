//
//  AttachmentViewModule.swift
//  GrantInspection
//
//  Created by Mohammed Hassan on 24/09/19.
//  Copyright © 2019 MBRHE. All rights reserved.
//

import RxSwift

struct AttachmentRequestSummaryInput {
    let attachmentId: String
}

class AttachmentViewModule {
    
    struct InputAttachmentsViewData {
         let attachmentId: AnyObserver<String>
//          let attachmentsViewModel:AnyObserver<AttachmentViewModel>
    }
    
    struct OutputAttachmentsViewData {
        let attachmentrequestSummaryResultObservable: Observable<ResponseViewAttachmentsModel>
        let errorsObservable: Observable<Error>
    }
    
    let inputDataAttachmentView: InputAttachmentsViewData
    let outputDataAttachmentView: OutputAttachmentsViewData
    

    private let attachmentIdString = PublishSubject<String>()
    private let errorsSubject = PublishSubject<Error>()
    private let disposeBag = DisposeBag()
    
    var attachmentIdView = ""

    private let attachmentViewOutputResponse = PublishSubject<ResponseViewAttachmentsModel>()
    
    init(_ service: RequestViewAttachmentServiceProtocol) {
        
        inputDataAttachmentView = InputAttachmentsViewData(attachmentId: attachmentIdString.asObserver())
        
        outputDataAttachmentView = OutputAttachmentsViewData(attachmentrequestSummaryResultObservable: attachmentViewOutputResponse.asObserver(), errorsObservable: errorsSubject.asObserver())
        
        attachmentIdString.asObserver().subscribe(onNext: { (param) in
            self.attachmentIdView = param
        }).disposed(by: disposeBag)
        
//     Attachment api call
        attachmentIdString.flatMap { [weak self] _ in
            return service.getAttachmentViewRequestSummary(requestAttachmentId: self!.attachmentIdView)
            } .subscribe(onNext: { [weak self] responce in
                
                if responce.success {
                    self?.attachmentViewOutputResponse.onNext(responce)
                }else{
                    self?.errorsSubject.onNext(NSError(domain: responce.message, code: responce.statusCode, userInfo: nil))
                }
                
            })
            .disposed(by: disposeBag)
    }
    
}

