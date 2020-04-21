//
//  SimplifiedReportViewModule.swift
//  GrantInspection
//
//  Created by Rajeswaran Thangaperumal on 28/08/2019.
//  Copyright © 2019 MBRHE. All rights reserved.
//

import RxSwift

class SimplifiedReportViewModule {
    
    struct Input {
        let getReportRequest: AnyObserver<Dashboard>
        let postReportRequest: AnyObserver<InspectionInputReportRequestPayload>
        let reportID: AnyObserver<String>
        let submitReport: AnyObserver<ReportInputDetails>
        
    }
    
    struct Output {
        
        let getReportResultObservable: Observable<InspectionGetReportResposeModel>
        let reportPostResponseObservable: Observable<InspectionReportRequestPayload>
        let facilityResultObservable: Observable<FacilityResposeModel>
        let reportFacilitiesResultObservable: Observable<ReportFacilitiesResposneModel>
        let submitResponseResultObservable: Observable<BaseResponseForModels>
        let errorsObservable: Observable<Error>
    }
    
    // MARK: - Public properties
    
    let output: Output
    
    let input: Input
    
    
    private let reportFacilitySubject = PublishSubject<FacilityResposeModel>()
    private let inspectionReportFacilitiesSubject = PublishSubject<ReportFacilitiesResposneModel>()
    private let reportGetRequestSubject = PublishSubject<Dashboard>()
    private let reportPostRequestSubject = PublishSubject<InspectionInputReportRequestPayload>()
    private let reportResponseSubject = PublishSubject<InspectionReportRequestPayload>()
    private let reportGetResponseSubject = PublishSubject<InspectionGetReportResposeModel>()
    private let submitResponseSubject = PublishSubject<BaseResponseForModels>()
    private let submitRequestSubject = PublishSubject<ReportInputDetails>()
    private let reportIDSubject = PublishSubject<String>()
    private let errorsSubject = PublishSubject<Error>()
    private let disposeBag = DisposeBag()
    var reportIDValue = ""
    var getReportValue = Dashboard()
    var postReportValue = InspectionInputReportRequestPayload()
    var getReportResponseValue = InspectionGetReportResposeModel()
    var submitReportObj = ReportInputDetails()
    
    init(_ service: ReportServiceProtocol) {
        input = Input(getReportRequest: reportGetRequestSubject.asObserver(), postReportRequest: reportPostRequestSubject.asObserver(), reportID: reportIDSubject.asObserver(), submitReport: submitRequestSubject.asObserver())
        
        output = Output(getReportResultObservable: reportGetResponseSubject.asObserver(), reportPostResponseObservable: reportResponseSubject.asObserver(), facilityResultObservable: reportFacilitySubject.asObserver(), reportFacilitiesResultObservable: inspectionReportFacilitiesSubject.asObserver(), submitResponseResultObservable: submitResponseSubject.asObserver(), errorsObservable: errorsSubject.asObserver())
        
        if Common.isConnectedToNetwork() == true
        {
            //1. Get All Faciliies List
            getAllFacilitiesDetails(service: service)
            
            //2. Get Request report Details
            getSimplifiedReportDetails(service: service)
            
            //3. Get Report Facilities list
            getSimplifiedReportFacilitiesList(service: service)
            
            //4. Post report details
            createAndUpdateReport(service: service)
            
            //5. Submit Report
            submitSimplifiedReport(service: service)
        }
        else{
            Common.showToaster(message: "no_Internet".ls)
        }
        
    }
    
    
    private func getAllFacilitiesDetails(service: ReportServiceProtocol) {
        
        service.getFacilitiesList().asObservable().subscribe(onNext: { [weak self](response) in
            if response.success {
                self?.reportFacilitySubject.onNext(response)
            }else{
                self?.errorsSubject.onNext(NSError(domain: response.message, code: response.statusCode, userInfo: nil))
            }
        }).disposed(by: disposeBag)
        
    }
    
    private func getSimplifiedReportDetails(service: ReportServiceProtocol) {
        
        reportGetRequestSubject.asObserver().subscribe(onNext: { (param) in
            self.getReportValue = param
        }).disposed(by: disposeBag)
        
       
        reportGetRequestSubject.flatMap { [weak self] _ in
            return service.getSimplifiedReport(requestParam: self?.getReportValue ?? Dashboard())
            }.subscribe {[weak self] (event) in
                switch event {
                case .next(let response):
                    self?.reportGetResponseSubject.onNext(response)
                    print("result-here")
                case .error(let error):
                    self?.errorsSubject.onNext(error)
                    print("error-here")
                default:
                    break
                }
            }.disposed(by: disposeBag)

        
       
        
    }
    
    private func getSimplifiedReportFacilitiesList(service: ReportServiceProtocol) {
        reportIDSubject.asObserver().subscribe(onNext: { (reportID) in
            self.reportIDValue = reportID
        }).disposed(by: disposeBag)        
        
        reportIDSubject.flatMap { [weak self] _ in
            return service.getReportFacilitiesList(reportId: self?.reportIDValue ?? "")
        }.subscribe {[weak self] (event) in
            switch event {
            case .next(let response):
                Common.hideActivityIndicator()
                self?.inspectionReportFacilitiesSubject.onNext(response)
                print("result-here")
            case .error(let error):
                self?.errorsSubject.onNext(error)
                print("error-here")
            default:
                break
            }
        }.disposed(by: disposeBag)
    }
    
    private func createAndUpdateReport(service: ReportServiceProtocol) {
        
        reportPostRequestSubject.asObserver().subscribe(onNext: { (param) in
            self.postReportValue = param
            service.createSimplifiedReport(requestParam: self.postReportValue.toDictionary() as? [String:Any] ?? ["":""]).asObservable().materialize().subscribe { [weak self](event) in
                switch event.element {
                case .next(let response):
                    
                    self?.reportResponseSubject.onNext(response)
                    print("result-here")
                case .error(let error):
                    self?.errorsSubject.onNext(error)
                    print("error-here")
                default:
                    break
                }
            }.disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
        
   
    }
    
    
    private func submitSimplifiedReport(service: ReportServiceProtocol) {
        
        submitRequestSubject.asObserver().subscribe(onNext: { (param) in
            
            self.submitReportObj = param
            
        }).disposed(by: disposeBag)
        
        submitRequestSubject.flatMap { [weak self] _ in
            return service.saveReportStatus(requestParam: self?.submitReportObj.toDictionary() as? [String:Any] ?? ["":""])
        }.subscribe {[weak self] (event) in
            switch event {
            case .next(let response):
                self?.submitResponseSubject.onNext(response)
                print("result-here")
            case .error(let error):
                self?.errorsSubject.onNext(error)
                print("error-here")
            default:
                break
            }
        }.disposed(by: disposeBag)
    }
    
}


