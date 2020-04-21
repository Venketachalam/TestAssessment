//
//  SearchContractorNameVC.swift
//  Progress
//
//  Created by Muhammad Akhtar on 11/20/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import NVActivityIndicatorView

//protocol PaymentDetailViewDelegate {
//    func selectedName(name: String)
//}

class PaymentDetailView: UIViewController, NVActivityIndicatorViewable, ControllerType  {
    
    @IBOutlet weak var mainContainer: MBRHEBorderView!
    @IBOutlet weak var lblContractIdTitle: UILabel!
    @IBOutlet weak var lblContractId: UILabel!
    @IBOutlet weak var lblRemainingPaymentTitle: UILabel!
    @IBOutlet weak var lblRemainingPayment: UILabel!
    
    @IBOutlet weak var lblApplicationNumberTitle: UILabel!
    @IBOutlet weak var lblApplicationNumber: UILabel!
    @IBOutlet weak var lblLastAmmountPaidTitle: UILabel!
    @IBOutlet weak var lblLastAmmountPaid: UILabel!
    
    @IBOutlet weak var lblApplicantIdTitle: UILabel!
    @IBOutlet weak var lblApplicantId: UILabel!
    @IBOutlet weak var lblContarctorIdTitle: UILabel!
    @IBOutlet weak var lblContarctorId: UILabel!
    
    @IBOutlet weak var lblOwnerNameTitle: UILabel!
    @IBOutlet weak var lblOwnerName: UILabel!
    @IBOutlet weak var lblConsultantIdTitle: UILabel!
    @IBOutlet weak var lblConsultantId: UILabel!
    
    @IBOutlet weak var lblMobileNoTitle: UILabel!
    @IBOutlet weak var lblMobileNo: UILabel!
    @IBOutlet weak var lblLastUpdateTitle: UILabel!
    @IBOutlet weak var lblLastUpdate: UILabel!
    
    @IBOutlet weak var lblContarctAmmountTitle: UILabel!
    @IBOutlet weak var lblContarctAmmount: UILabel!
    @IBOutlet weak var lblOfficePhoneTitle: UILabel!
    @IBOutlet weak var lblOfficePhone: UILabel!
    
    @IBOutlet weak var lblLoanAmmountTitle: UILabel!
    @IBOutlet weak var lblLoanAmmount: UILabel!
    @IBOutlet weak var lblEmailTitle: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    
    @IBOutlet weak var lblTransactionDateTitle: UILabel!
    @IBOutlet weak var lblTransactionDate: UILabel!
    @IBOutlet weak var lblContactMobileTitle: UILabel!
    @IBOutlet weak var lblContactMobile: UILabel!
    
    @IBOutlet weak var lblPercentCompleteTitle: UILabel!
    @IBOutlet weak var lblPercentComplete: UILabel!
    @IBOutlet weak var lblContactNameTitle: UILabel!
    @IBOutlet weak var lblContactName: UILabel!
    
    @IBOutlet weak var lblTotalPaymentTitle: UILabel!
    @IBOutlet weak var lblTotalPayment: UILabel!
    @IBOutlet weak var lblContractStartDateTitle: UILabel!
    @IBOutlet weak var lblContractStartDate: UILabel!
    
    @IBOutlet weak var lblContractorTitle: UILabel!
    @IBOutlet weak var lblContractor: UILabel!
    @IBOutlet weak var lblContractEndDateTitle: UILabel!
    @IBOutlet weak var lblContractEndDate: UILabel!
    
    @IBOutlet weak var lblServiceTypeTitle: UILabel!
    @IBOutlet weak var lblServiceType: UILabel!
    @IBOutlet weak var lblContractSTSDateTitle: UILabel!
    @IBOutlet weak var lblContractSTSDate: UILabel!
    
    @IBOutlet weak var lblCONTR_STSTitle: UILabel!
    @IBOutlet weak var lblCONTR_STS: UILabel!
    @IBOutlet weak var lblRemarkTitle: UILabel!
    @IBOutlet weak var lblRemark: UILabel!
    
    @IBOutlet weak var lblEngineerTitle: UILabel!
    @IBOutlet weak var lblEngineer: UILabel!
    @IBOutlet weak var lblLicenseNoTitle: UILabel!
    @IBOutlet weak var lblLicenseNo: UILabel!
    
    @IBOutlet weak var lblPlotNoTitle: UILabel!
    @IBOutlet weak var lblPlotNo: UILabel!
    @IBOutlet weak var lblCONTR_STS_ATitle: UILabel!
    @IBOutlet weak var lblCONTR_STS_A: UILabel!
    
    @IBOutlet weak var lblOwnerShareTitle: UILabel!
    @IBOutlet weak var lblOwnerShare: UILabel!
    @IBOutlet weak var lblCONTR_STS_ETitle: UILabel!
    @IBOutlet weak var lblCONTR_STS_E: UILabel!
    
    @IBOutlet weak var lblTotalRetentionsTitle: UILabel!
    @IBOutlet weak var lblTotalRetentions: UILabel!
    @IBOutlet weak var lblServiceTypeCodeTitle: UILabel!
    @IBOutlet weak var lblServiceTypeCode: UILabel!
    
    @IBOutlet weak var lblDM_COMPLETE_DTTitle: UILabel!
    @IBOutlet weak var lblDM_COMPLETE_DT: UILabel!
    
    @IBOutlet weak var btnClose: UIButton!
    
    typealias ViewModelType = PaymentDetailViewModel
    // MARK: - Properties
    private var viewModel: ViewModelType!
    private let disposeBag = DisposeBag()
    
    var paymentObj:Dashboard = Dashboard()
    // var nameList = [String]()
    //var searchedNameList = Variable<[String]>([])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainContainer.alpha = 0
        mainContainer.isHidden = true
        
        // Do any additional setup after loading the view.
        configure(with: viewModel)
    }
    
    @objc func checkAction(sender : UITapGestureRecognizer) {
        self.dismiss(animated: false, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configure(with viewModel: PaymentDetailViewModel) {
        
        //        let paymentId = paymentObj.contractId.description
        //
        //        self.showActivityIndicator()
        //        viewModel.input.paymentId.asObserver()
        //            .onNext(paymentId)
        
        
        if Common.isConnectedToNetwork() == true
        {
            viewModel.output.paymentSummaryResultObservable
                .subscribe(onNext: { [unowned self] (response) in
                    self.stopAnimating()
                    
                    self.lblContractId.text = String(describing: "\(response.payload.contractId)")
                    self.lblRemainingPayment.text = response.payload.remainingPayment
                    
                    self.lblApplicationNumber.text = response.payload.applicationNo
                    self.lblLastAmmountPaid.text = response.payload.lastAmountPaid
                    
                    self.lblApplicantId.text = String(describing: "\(response.payload.applicantID)")
                    self.lblContarctorId.text = String(describing: "\(response.payload.contractorID)")
                    
                    self.lblOwnerName.text = response.payload.ownerName
                    self.lblConsultantId.text = String(describing: "\(response.payload.consultantID)")
                    
                    self.lblMobileNo.text = response.payload.mobileNo
                    self.lblLastUpdate.text = response.payload.lastUpdateDate
                    
                    self.lblContarctAmmount.text = response.payload.contractAmount
                    self.lblOfficePhone.text = response.payload.officePhone
                    
                    self.lblLoanAmmount.text = response.payload.loanAmount
                    self.lblEmail.text = response.payload.email
                    
                    self.lblTransactionDate.text = response.payload.transDate
                    self.lblContactMobile.text = response.payload.contactMobile
                    
                    self.lblPercentComplete.text = response.payload.perCompleted
                    self.lblContactName.text = response.payload.contactName
                    
                    self.lblTotalPayment.text = response.payload.totalPayment
                    self.lblContractStartDate.text = response.payload.contrStartDate
                    
                    self.lblContractor.text = response.payload.contractorName
                    self.lblContractEndDate.text = response.payload.contrEndDate
                    
                    self.lblServiceType.text = response.payload.serviceType
                    self.lblContractSTSDate.text = response.payload.officePhone
                    
                    self.lblCONTR_STS.text = response.payload.contrsSts
                    self.lblRemark.text = response.payload.remark
                    
                    self.lblEngineer.text = response.payload.engineer
                    self.lblLicenseNo.text = response.payload.licenseNo
                    
                    self.lblPlotNo.text = response.payload.plotNo
                    self.lblCONTR_STS_A.text = response.payload.contrStsA
                    
                    self.lblOwnerShare.text = response.payload.ownerShare
                    self.lblCONTR_STS_E.text = response.payload.contrStsE
                    
                    self.lblTotalRetentions.text = response.payload.totalRetentions
                    self.lblServiceTypeCode.text = String(describing: "\(response.payload.serviceTypeCode)")
                    
                    self.lblDM_COMPLETE_DT.text = response.payload.dmCompleteDt
                    
                    self.mainContainer.isHidden = false
                    UIView.animate(withDuration: 0.5) {
                        self.mainContainer.alpha = 1
                        
                    }
                    
                })
                .disposed(by: disposeBag)
        }
        else{
            Common.showToaster(message: "no_Internet".ls)
        }
        
        viewModel.output.errorsObservable
            .subscribe(onNext: { [unowned self] (error) in
                self.stopAnimating()
                self.mainContainer.isHidden = false
                self.mainContainer.alpha = 1
                let errorMessage = (error as NSError).domain
                if(Common.isConnectedToNetwork() == false){
                    self.notAvailable(isNetwork: true)
                } else {
                    self.notAvailable(isNetwork: false)
                }
                Common.showToaster(message: errorMessage)
            })
            .disposed(by: disposeBag)
        
        btnClose.rx.tap.asObservable()
            .subscribe(onNext:{[weak self] _ in
                self?.dismiss(animated: false, completion: nil)
            })
            .disposed(by: disposeBag)
    }
    
    static func create(with viewModel: PaymentDetailViewModel) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "MoreVC") as! PaymentDetailView
        controller.viewModel = viewModel
        return controller
    }
    
    func showActivityIndicator() {
        let size = CGSize(width: 70, height: 70)
        startAnimating(size, message: "",messageFont: nil, type: NVActivityIndicatorType.ballBeat, color: UIColor(red: 0/255, green: 97/255, blue: 158/255, alpha: 1.0),padding:10)
        
    }
    
    @IBAction func contractorPressed(_ sender: Any) {
        
        Common.showToaster(message: "copied_to_clipboard".ls)

        UIPasteboard.general.string = self.lblContractId.text
    }
    
    @IBAction func applicationPressed(_ sender: Any) {
        Common.showToaster(message: "copied_to_clipboard".ls)
        UIPasteboard.general.string = self.lblApplicationNumber.text
    }
    
    //MARK: -- noData view --
    var noData : NoDataView!
    func notAvailable(isNetwork:Bool){
        
        noData = NoDataView.getEmptyDataView()
        if isNetwork {
            noData.frame = CGRect(x: 0, y: 100, width: self.mainContainer.frame.size.width ,  height:self.mainContainer.frame.size.width)
            noData.setLayout(noNetwork:isNetwork,Yposition :5)
            noData.backBtn.addTarget(self, action: #selector(self.remvoeNotAvailable), for: .touchUpInside)
        } else {
            noData.frame = CGRect(x: 0, y: 100, width: Common.screenWidth,  height:Common.screenHeight - 236)
            noData.setLayout(description:"Unable to load detail.", noNetwork:isNetwork,Yposition :5)
            noData.backBtn.addTarget(self, action: #selector(self.popToViewController), for: .touchUpInside)
        }
        
        self.mainContainer?.addSubview(noData)
    }
    
    @objc func remvoeNotAvailable(){
        
        if(Common.isConnectedToNetwork() == true){
            noData.removeFromSuperview()
            //add observer to call api 
            //            let paymentId = paymentObj.contractId.description
            //            self.showActivityIndicator()
            //            viewModel.input.paymentId.asObserver()
            //                .onNext(paymentId)
        }
        else{
            Common.showToaster(message: "no_Internet".ls)

        }
    }
    
    @objc func popToViewController(){
        self.dismiss(animated: false, completion: nil)
    }
    
}
