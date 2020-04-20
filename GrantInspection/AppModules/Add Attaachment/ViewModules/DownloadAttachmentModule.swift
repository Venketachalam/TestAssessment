//
//  DownloadAttachmentModule.swift
//  GrantInspection
//
//  Created by Venketachalam Govindaraj on 29/09/19.
//  Copyright © 2019 MBRHE. All rights reserved.
//

import RxSwift

class DownloadAttachmentModule {
    
    struct  inputData {
        let downloadAttachmentInputModal:AnyObserver<AttachmentDownloadInputParams>
    }
    struct  OutputData {
        let downloadAttachmentResultObservable: Observable<AttachmentDownloadResponse>
        let errorsObservable: Observable<Error>
    }
    
    let inputDownloadAttachmentData:inputData
    let outputDownloadAttachment:OutputData
    
    private let downloadAttachmentUploadRequest = PublishSubject<AttachmentDownloadInputParams>()
    private let downloadAttachmentOutputResponse=PublishSubject<AttachmentDownloadResponse>()
    private let errorsSubject = PublishSubject<Error>()
    private let disposeBag = DisposeBag()
    
    var downloadAttachmentDetails=AttachmentDownloadInputParams()
    private let categoryRequestforUploading=PublishSubject<AttachmentDownloadResponse>()
    
    init(_ service:DownloadAttachmentServiceProtocol) {
        
        inputDownloadAttachmentData = inputData(downloadAttachmentInputModal: downloadAttachmentUploadRequest.asObserver())
        
        outputDownloadAttachment = OutputData(downloadAttachmentResultObservable: downloadAttachmentOutputResponse.asObserver(), errorsObservable: errorsSubject.asObserver())
        
        
        downloadAttachmentUploadRequest.asObserver().subscribe(onNext:  { (param) in
            self.downloadAttachmentDetails = param
        }).disposed(by: disposeBag)
        
        
        downloadAttachmentUploadRequest.flatMap { [weak self] _ in
            return service.downloadattachmentRequestSummary(param: self!.downloadAttachmentDetails)
            } .subscribe(onNext: { [weak self] responce in
                
                if responce.success {
                    
                    self?.downloadAttachmentOutputResponse.onNext(responce)
                    
                }else{
                    self?.errorsSubject.onNext(NSError(domain: responce.message, code: responce.statusCode, userInfo: nil))
                }
                
            })
            .disposed(by: disposeBag)
    }
    
    
    
}
