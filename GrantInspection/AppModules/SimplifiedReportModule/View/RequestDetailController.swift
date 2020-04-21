//
//  RequestDetailController.swift
//  GrantInspection
//
//  Created by Rajeswaran Thangaperumal on 28/08/2019.
//  Copyright © 2019 MBRHE. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class RequestDetailController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let disposeBag = DisposeBag()
    
    var requestObject: Dashboard!
    
    var requestSummary: RequestSummary!
    
    var viewModel: RequestSummaryViewModel!
    var isFromStartMyTrip = Bool()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewSetup()
        setLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
       
        super.viewWillAppear(true)
        
        if Common.isConnectedToNetwork() == true
        {
            viewModel = RequestSummaryViewModel(RequestService())
            viewModelConfiguration(viewModel: viewModel)        }
        else{
            Common.showToaster(message: "no_Internet".ls )
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.tableHeaderView?.frame.size.height = self.tableView.frame.size.width * 0.3
    }
    
    func mockData(){
        if let _ = requestObject {
            let request = Dashboard()
            request.applicantId = 81753
            request.applicationNo = 1021481
            
            requestObject = request
            
        }
    }
    
    private func tableViewSetup() {
        tableView.dataSource = self
        
      
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .clear
    }
    
    func setLayout(){
        
        if Common.currentLanguageArabic() {
            
            if isFromStartMyTrip == false
            {
                self.tableView.transform = Common.arabicTransform
                self.tableView.toArabicTransform()
                self.view.transform = Common.arabicTransform
                self.view.toArabicTransform()
            }
   
            
           
        }
        else{
            self.tableView.transform = Common.englishTransform
            self.tableView.toEnglishTransform()
        }
    }
    
    private func tableHeaderView() {
        let requestDetailView = RequestDetailsView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 0))
        requestDetailView.delegate = self
        tableView.tableHeaderView = requestDetailView
        
        if Common.currentLanguageArabic() {
            if isFromStartMyTrip == false {
                tableView.tableHeaderView?.transform = Common.arabicTransform
                tableView.tableHeaderView?.toArabicTransform()
                
            }
           
        }
    }
    
    func addObserverToHeaderView(view:RequestDetailsView) {
        view.createReportButton.rx.tap.asObservable()
            .subscribe { [weak self] action in
                self?.navigateToCreateResportVC()
        }.disposed(by: DisposeBag())
    }
    
    func navigateToCreateResportVC(reportDetails:InspectionReportRespose?=nil) {
        
        guard let requestDetails = requestSummary else { return }
        if let createReportVC = self.storyboard?.instantiateViewController(withIdentifier: "CreateSimplifiedReportController") as? CreateSimplifiedReportController {
            createReportVC.requestDetails = requestDetails
            createReportVC.requestObject = requestObject
            createReportVC.reportDetails = reportDetails
            createReportVC.isFromStartMyTrip = self.isFromStartMyTrip
            self.navigationController?.pushViewController(createReportVC, animated: true)
        }
        
    }
    
    func navigateToResportDetailsVC() {
        let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "SimplifiedReportDetailsViewController") as! SimplifiedReportDetailsViewController
        
        
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    func viewModelConfiguration(viewModel:RequestSummaryViewModel) {
        
        Common.showActivityIndicator()
        viewModel.input.applicantId.asObserver().onNext("\(requestObject.applicantId)")
        viewModel.input.applicationNo.asObserver().onNext("\(requestObject.applicationNo)")
        viewModel.input.serviceType.asObserver().onNext(requestObject.serviceTypeId)
        viewModel.output.requestSummaryResultObservable
            .subscribe(onNext: { [unowned self](response) in

            Common.hideActivityIndicator()
              self.requestSummary = response.payload.summary
                self.checkReportDetails(summary: response)

        }) .disposed(by: disposeBag)

        
        viewModel.output.errorsObservable
            .subscribe(onNext: { [unowned self] (error) in
                
                Common.hideActivityIndicator()
                let errorMessage = (error as NSError).domain
                if !errorMessage.isEmpty{
                    
                    Common.showToaster(message: errorMessage)
                }else {
                    Common.showToaster(message: "bad_Gateway".ls)
                }
                
            })
            .disposed(by: disposeBag)
        
    }
    

    func checkReportDetails(summary:RequestDetailModel) {
         let viewModel = SimplifiedReportViewModule(ReportService())
        getReportDetails(vM: viewModel, requestSummary: summary)
    }
    
    func getReportDetails(vM:SimplifiedReportViewModule,requestSummary:RequestDetailModel) {
        
        guard let inputDetails = requestObject else { return  }
        Common.showActivityIndicator()
        vM.input.getReportRequest.onNext(inputDetails)
        vM.output.getReportResultObservable.subscribe { [weak self](response) in
            Common.hideActivityIndicator()
            
            if let value = response.element,value.success == true {
                if value.payload.inspectionReportId.count > 0 {
                    
                    self?.navigateToCreateResportVC(reportDetails: value.payload)
                }else {
                    DispatchQueue.main.async {
                        self?.tableHeaderView()
                        self?.valueToHeader(value: requestSummary)
                    }
                }
                
            } else {
                DispatchQueue.main.async {
                    self?.tableHeaderView()
                    self?.valueToHeader(value: requestSummary)
                }
            }
            }.disposed(by: disposeBag)

       
        
        vM.output.errorsObservable
            .subscribe(onNext: { [unowned self] (error) in
                
                Common.hideActivityIndicator()
                let errorMessage = (error as NSError).domain
                if !errorMessage.isEmpty{
                    
                    Common.showToaster(message: errorMessage)
                }else {
                    Common.showToaster(message: "502 Bad Gateway")
                    
                }
                
            })
            .disposed(by: disposeBag)
        

    }

    func valueToHeader(value:RequestDetailModel) {
        requestSummary = value.payload.summary
        if let header = tableView.tableHeaderView as? RequestDetailsView {
            let infoView = RequestInfo(applicationNo: value.payload.summary.applicationNo, applicantID: value.payload.summary.applicationNo, customerName: value.payload.summary.customerName, lanNo: value.payload.summary.landNo, duraton: value.payload.summary.duration, areaName: value.payload.summary.serviceRegion,plotArea: requestSummary.servicePlotArea)
            header.setRequestDetails(details: infoView, indicatorColor: requestObject.colorTag)
        }
    }
}

extension RequestDetailController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
}


extension RequestDetailController : RequestDetailsViewDelegate {
    func createReportAction() {
        self.navigateToCreateResportVC()
    }
    
    func backAction() {
        if let parentVC = self.parent {
            if parentVC.parent is StartMyTripViewController {
                let vc = parentVC.parent as? StartMyTripViewController
                vc?.tripInfoView.isHidden = false
                vc?.backAcnView.isHidden = false
            }
            parentVC.remove()
        }
        // self.navigationController?.popViewController(animated: true)
    }
}

