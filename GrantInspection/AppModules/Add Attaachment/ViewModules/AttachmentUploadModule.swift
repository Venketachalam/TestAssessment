//
//  AttachmentUploadModule.swift
//  GrantInspection
//
//  Created by Mohammed Hassan on 22/09/19.
//  Copyright © 2019 MBRHE. All rights reserved.
//
import RxSwift


class AttachmentUploadModule {

    struct inputData {
        let attachmentsUploadedModel:AnyObserver<AttachmentUploadModel> 
    }
    
    struct OutputData {
        let attachmentUploadedResultObservable: Observable<RequestAttachmentsModel>
        let errorsObservable: Observable<Error>
    }
    
    //MARK: Public Variables
    
    let inputDataAttachments:inputData
    let outputDataAttachments:OutputData

    
    private let attachmentUploadRequest = PublishSubject<AttachmentUploadModel>()
    
    private let attachmentOutputResponse = PublishSubject<RequestAttachmentsModel>()
    
    private let errorsSubject = PublishSubject<Error>()
    private let disposeBag = DisposeBag()
    
     var attachmentsUploadDetails = AttachmentUploadModel()
     private let attachmentsRequestForUploading = PublishSubject<AttachmentUploadModel>()
    
    
    init(_ service: RequestAttachmentServiceProtocol) {
        
        inputDataAttachments = inputData(attachmentsUploadedModel: attachmentUploadRequest.asObserver())
        
        outputDataAttachments = OutputData(attachmentUploadedResultObservable: attachmentOutputResponse.asObserver(), errorsObservable: errorsSubject.asObserver())
        
        
        if Common.isConnectedToNetwork() == true
        {
        attachmentUploadRequest.asObserver().subscribe(onNext:  { (param) in
            self.attachmentsUploadDetails = param
        }).disposed(by: disposeBag)
        
        
        attachmentUploadRequest.flatMap { [weak self] _ in
            return service.getAttachedRequestSummary(parmas: self!.attachmentsUploadDetails)
            } .subscribe(onNext: { [weak self] responce in
                
                if responce.success {
                    
                    self?.attachmentOutputResponse.onNext(responce)
                  
                }else{
                    self?.errorsSubject.onNext(NSError(domain: responce.message, code: responce.statusCode, userInfo: nil))
                }
                
            })
            .disposed(by: disposeBag)
        }
        else{
            Common.showToaster(message: "no_Internet".ls )
        }
    
    }
    
 
    deinit {
        print("\(self) dealloc")
    }
    
}
