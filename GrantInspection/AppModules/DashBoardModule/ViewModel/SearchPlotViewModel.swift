//
//  SearchPlotViewModel.swift
//  GrantInspection
//
//  Created by Rajeswaran Thangaperumal on 08/09/2019.
//  Copyright © 2019 MBRHE. All rights reserved.
//

import RxSwift

struct AddLocationRequestModel {
    var locationId = ""
    var featureClassId = ""
    var applicationNo = ""
    var applicantId = ""
    var serviceTypeId = ""
    
    init() {
        
    }
}

class SearchPlotViewModel {
    
    struct SearchInput {
        let searchArea: AnyObserver<String>
        let searchLanguage: AnyObserver<String>
        let locationId: AnyObserver<String>
        let featureClassId:AnyObserver<String>
        let applicationNo: AnyObserver<String>
        let plotNo: AnyObserver<String>
        let applicantId: AnyObserver<String>
        let serviceTypeId: AnyObserver<String>
        let addLocationAction: AnyObserver<Void>
        let addPlotAction: AnyObserver<Void>
        let plotNewNo: AnyObserver<String>
    }
    
    struct SearchOutput {
        let requestSummaryResultObservable: Observable<SearchLocationModelResponse>
        let plotLocationResultObservable:Observable<PlotLocationModelResponse>
        let errorsObservable: Observable<Error>
    }
    
    private let areaNameSubject = PublishSubject<String>()
    private let searchLanguageSubject = PublishSubject<String>()
    private let locationIdSubject = PublishSubject<String>()
    private let featureClassIdSubject = PublishSubject<String>()
    private let applicationNoSubject = PublishSubject<String>()
    private let plotNoSubject = PublishSubject<String>()
    private let plotNewNoSubject = PublishSubject<String>()
    private let applicantIdSubject = PublishSubject<String>()
    private let serviceTypeSubject = PublishSubject<String>()
    private let addLocationActionSubject = PublishSubject<Void>()
    private let addPlotActionSubject = PublishSubject<Void>()
    var areaName = ""
    var locationID = ""
    var searchLang = ""
    var featureClassID = ""
    var applicationNo = ""
    var applicantID = ""
    var serviceTypeID = ""
    var plotNo = ""
    var plotNewNo = ""
    
    var addLocationRequets:AddLocationRequestModel!
    
    private let searcLocationResponseSubject = PublishSubject<SearchLocationModelResponse>()
    
    private let plotLocationResponseSubject = PublishSubject<PlotLocationModelResponse>()
    
    
    private let errorsSubject = PublishSubject<Error>()
    
    private let disposeBag = DisposeBag()
    
    var input: SearchInput
    var output: SearchOutput
    
    init(_ service: SearchPlotService) {
        
        input = SearchInput(searchArea: areaNameSubject.asObserver(), searchLanguage:searchLanguageSubject.asObserver(), locationId: locationIdSubject.asObserver(),featureClassId: featureClassIdSubject.asObserver(), applicationNo: applicationNoSubject.asObserver(), plotNo: plotNoSubject.asObserver(),applicantId:applicantIdSubject.asObserver(),serviceTypeId: serviceTypeSubject.asObserver(), addLocationAction: addLocationActionSubject.asObserver(), addPlotAction: addPlotActionSubject.asObserver(),plotNewNo:plotNewNoSubject.asObserver())
        output = SearchOutput(requestSummaryResultObservable: searcLocationResponseSubject.asObserver(), plotLocationResultObservable: plotLocationResponseSubject.asObserver(), errorsObservable: errorsSubject.asObserver())
        
       
        areaNameSubject.asObserver().subscribe(onNext: { [weak self] (text) in

            self?.areaName = text
            
        }).disposed(by: disposeBag)
        
        searchLanguageSubject.asObserver().subscribe(onNext: { [weak self] (text) in

            self?.searchLang = text
            
        }).disposed(by: disposeBag)
        
        
        searchLanguageSubject.flatMap { [weak self] _ in
            
            return service.getSearchLocations(self?.areaName ?? "", self?.searchLang ?? "")
            }.subscribe { [weak self] (event) in
                switch event {
                case .next(let location):
                    self?.searcLocationResponseSubject.onNext(location)
                    print("result-here")
                //print(contracts)
                case .error(let error):
                    self?.errorsSubject.onNext(error)
                    print("error-here")
                //print(error)
                default:
                    break
                }
        }.disposed(by: disposeBag)
        
        
        locationIdSubject.flatMap { [weak self] _ in
            
            return service.getLocationDetailsFromLocationID(locationRequest: self?.addLocationRequets ?? AddLocationRequestModel() )
            }.subscribe { [weak self] (event) in
            switch event {
            case .next(let location):
                self?.plotLocationResponseSubject.onNext(location)
                print("result-here")
            //print(contracts)
            case .error(let error):
                self?.errorsSubject.onNext(error)
                print("error-here")
            //print(error)
            default:
                break
            }
            }.disposed(by: disposeBag)
        
        print(plotNewNo)
        print(plotNo)
        
        plotNewNoSubject.asObserver().subscribe(onNext: { [weak self] (text) in
            self?.plotNewNo = text
        }).disposed(by: disposeBag)
        
        plotNoSubject.asObserver().subscribe(onNext: { [weak self] (text) in
            self?.plotNo = text
        }).disposed(by: disposeBag)
        
        print(plotNewNo)
        
        
        
        plotNoSubject.flatMap { [weak self] _ in
        return service.getSearchLocations(self?.applicationNo ?? "", plotNo: self?.plotNo ?? "",serviceTypeId: self?.serviceTypeID ?? "",applicantId:self?.applicantID ?? "",plotNewNo: self?.plotNewNo ?? "")
        }.subscribe(onNext: { [weak self] response in
            if response.success {
                self?.plotLocationResponseSubject.onNext(response)
            }else{
                self?.errorsSubject.onNext(NSError(domain: response.message, code: response.statusCode, userInfo: nil))
            }
            
        })
        .disposed(by: disposeBag)
        
        

        plotNewNoSubject.flatMap { [weak self] _ in
        return service.getSearchLocations(self?.applicationNo ?? "", plotNo: self?.plotNo ?? "",serviceTypeId: self?.serviceTypeID ?? "",applicantId:self?.applicantID ?? "",plotNewNo: self?.plotNewNo ?? "")
        }.subscribe(onNext: { [weak self] response in
            if response.success {
                self?.plotLocationResponseSubject.onNext(response)
            }else{
                self?.errorsSubject.onNext(NSError(domain: response.message, code: response.statusCode, userInfo: nil))
            }
            
        })
        .disposed(by: disposeBag)
        
        
    }
    
}
