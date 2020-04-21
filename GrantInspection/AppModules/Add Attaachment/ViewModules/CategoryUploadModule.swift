//
//  CategoryUploadModule.swift
//  GrantInspection
//
//  Created by Venketachalam Govindaraj on 25/09/19.
//  Copyright © 2019 MBRHE. All rights reserved.
//

import RxSwift

class CategoryUploadModule {
    
    struct  inputData {
        let categoriesUploadModal:AnyObserver<CategoryUploadModel>
    }
    struct  OutputData {
        let categoryUploadedResultObservable: Observable<CategoryResponseListModel>
        let errorsObservable: Observable<Error>
    }
    
    let inputCategoryData:inputData
    let outputCategoryData:OutputData
    
    private let categoryUploadRequest = PublishSubject<CategoryUploadModel>()
    private let categoryOutputResponse=PublishSubject<CategoryResponseListModel>()
    private let errorsSubject = PublishSubject<Error>()
    private let disposeBag = DisposeBag()
    
    var categoryUploadDetails=CategoryUploadModel()
    private let categoryRequestforUploading=PublishSubject<CategoryUploadModel>()
    
    init(_ service:CategoryServiceProtocol) {
        
        inputCategoryData = inputData(categoriesUploadModal: categoryUploadRequest.asObserver())
        
        outputCategoryData = OutputData(categoryUploadedResultObservable: categoryOutputResponse.asObserver(), errorsObservable: errorsSubject.asObserver())
        
        if Common.isConnectedToNetwork() == true
        {
            categoryUploadRequest.asObserver().subscribe(onNext:  { (param) in
                self.categoryUploadDetails = param
            }).disposed(by: disposeBag)
            
            categoryUploadRequest.flatMap { [weak self] _ in
                return service.getCategoryRequestSummary(param: self!.categoryUploadDetails)
            }.subscribe {[weak self] (event) in
                switch event {
                case .next(let response):
                    self?.categoryOutputResponse.onNext(response)
                //print(contracts)
                case .error(let error):
                    self?.errorsSubject.onNext(error)
                //print(error)
                default:
                    break
                }
            }.disposed(by: disposeBag)
            
        }
        else{
            Common.showToaster(message: "no_Internet".ls )
        }
         
}

}
