  //
  //  PaymentSummaryViewController.swift
  //  Progress
  //
  //  Created by Muhammad Akhtar on 11/13/18.
  //  Copyright © 2018 MBRHE. All rights reserved.
  //
  
  import UIKit
  import RxSwift
  import RxCocoa
  import NVActivityIndicatorView
  
  class PaymentSummaryViewController: UIViewController, ControllerType ,NVActivityIndicatorViewable {
    
    
    typealias ViewModelType = PaymentSummaryViewModel
    // MARK: - Properties
    private var viewModel: ViewModelType!
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var customerNameLbl: UILabel!
    @IBOutlet weak var customerName: UILabel!
    
    @IBOutlet weak var contractorNameLbl: UILabel!
    @IBOutlet weak var contractorName: UILabel!
    
    @IBOutlet weak var contractAmountLbl: UILabel!
    @IBOutlet weak var contractAmount: UILabel!
    
    @IBOutlet weak var totalPaymentLbl: UILabel!
    @IBOutlet weak var totalPayment: UILabel!
    
    @IBOutlet weak var grossLbl: UILabel!
    @IBOutlet weak var gross: UILabel!
    
    @IBOutlet weak var billRetentionLbl: UILabel!
    @IBOutlet weak var billRentation: UILabel!
    
    @IBOutlet weak var paymentToOwnerLbl: UILabel!
    @IBOutlet weak var paymentToOwner: UILabel!
    
    @IBOutlet weak var totalRetentionLbl: UILabel!
    @IBOutlet weak var totalRetention: UILabel!
    
    @IBOutlet weak var ownerToShareLbl: UILabel!
    
    @IBOutlet weak var ownerToShare: UILabel!
    
    @IBOutlet weak var percentageCompletedLbl: UILabel!
    
    @IBOutlet weak var percentageCompleted: UILabel!
    
    @IBOutlet weak var deductionLbl: UILabel!
    @IBOutlet weak var deduction: UILabel!
    
    @IBOutlet weak var totalBillPaymentLbl: UILabel!
    @IBOutlet weak var totalBillPayment: UILabel!
    
    @IBOutlet weak var paymentToContractorLbl: UILabel!
    @IBOutlet weak var paymentToContractor: UILabel!
    
    @IBOutlet weak var contractIDlbl: UILabel!
    @IBOutlet weak var paymentIDlbl: UILabel!
    @IBOutlet weak var applicationNolbl: UILabel!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var subHeaderView: UIView!
    
    
    @IBOutlet weak var btnFinish: UIButton!
    @IBOutlet weak var btnHold: UIButton!
    @IBOutlet weak var btnReject: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var lblAlertMessage: UILabel!
    @IBOutlet weak var btnContinue: UIButton!
    
    @IBOutlet weak var lblPaymentOwner: UILabel!
    var obj:Dashboard = Dashboard()
    
    override func viewDidLoad() {
      super.viewDidLoad()
      
      // Do any additional setup after loading the view.
      addMRHEHeaderView()
      addMRHELeftMenuView()
      configure(with: viewModel)
      self.alertView.isHidden = true
      btnContinue.setTitle("continue_btn".ls, for: .normal)
    }
    
    override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
    }
    
    func addMRHEHeaderView(){
      let mrheHeaderView = MRHEHeaderView.getMRHEHeaderView()
      self.view.addSubview(mrheHeaderView)
    }
    
    func addMRHELeftMenuView(){
      let mrheMenuView = MBRHELeftMenuView.getMBRHELeftMenuView()
      self.view.addSubview(mrheMenuView)
    }
    
    func configure(with viewModel: PaymentSummaryViewModel) {
/*
      let projectID : String = obj.contractId.description
      let paymentID : String = obj.paymentId.description
      
      self.applicationNolbl.text = "Application No :  #" + obj.applicationNo
      self.paymentIDlbl.text = "Payment No : #" + obj.paymentId.description
      self.contractIDlbl.text = "Contract ID : " + obj.contractId.description
      self.customerName.text = obj.owner.description
      self.contractorName.text = obj.contractor.name.description
      self.contractAmount.text = obj.contractAmount.description
      
      self.customerName.isHidden = true
       self.contractorName.isHidden = true
      self.contractAmount.isHidden = true
      
      self.statusView.backgroundColor = Common.hexStringToUIColor(hex: obj.colorTag)
      
      viewModel.input.paymentId.asObserver()
        .onNext(paymentID)
      
      viewModel.input.projectId.asObserver()
        .onNext(projectID)
      self.showActivityIndicator()
      
      viewModel.output.paymentSummaryResultObservable
        .subscribe(onNext: { [unowned self] (payload) in
          
            self.stopAnimating()
            let obj = payload.payload
          
            self.totalPayment.text = obj.totalPayment
            self.gross.text = obj.gross
            self.billRentation.text = obj.billRetention
            self.paymentToOwner.text = obj.paymentOwner
            self.totalRetention.text = obj.totalRetention
            self.ownerToShare.text = obj.ownerShare
            self.percentageCompleted.text = obj.perCompleted
            self.deduction.text = obj.deduction
            self.totalBillPayment.text = obj.totalBillPayment
            self.paymentToContractor.text = obj.paymentContractor
          
          self.customerName.isHidden = false
          self.contractAmount.isHidden = false
          self.contractorName.isHidden = false
          
        })
        .disposed(by: disposeBag)
      
      
      viewModel.output.paymentSummaryStatusResultObservable
        .subscribe({ [unowned self] (payload) in
        
          let message = payload.element?.message
  
          self.stopAnimating()
          Toast(text: message, duration: Delay.short).show()
          self.navigationController?.popToRootViewController(animated: true)
          
        })
        .disposed(by: disposeBag)
      
      
      
      viewModel.output.errorsObservable
        .subscribe(onNext: { [unowned self] (error) in
          self.stopAnimating()
            if(Common.isConnectedToNetwork() == false){
                self.notAvailable(isNetwork: true)
            }else{
                self.notAvailable(isNetwork: false)
            }
        })
        .disposed(by: disposeBag)
      
      
      btnBack.rx.tap.asObservable()
        .subscribe(onNext:{[weak self] _ in
          self?.navigationController?.popViewController(animated: false)
        })
        .disposed(by: disposeBag)
      
      
      
      btnReject.rx.tap.asObservable()
        .subscribe(onNext:{[weak self] _ in
          
           let message = String(format:"%@%@ %@ %@","Are you sure you want to reject payment #", (self?.obj.paymentId)! ,"for contractor",(self?.obj.contractor.name)!," on hold ?")
          
          self?.confirmation(message: message) { result in
            
            if (result){
              viewModel.input.status.asObserver()
                .onNext("reject")
              self?.showActivityIndicator()
            }
          }
          
         
        })
        .disposed(by: disposeBag)
      
      btnFinish.rx.tap.asObservable()
        .subscribe(onNext:{[weak self] _ in
          
          let message = String(format:"%@%@ %@ %@","Are you sure you want to submit payment #", (self?.obj.paymentId)! ,"for contractor",(self?.obj.contractor.name)!," on hold ?")
          
          self?.confirmation(message: message) { result in
            
            if (result){
              viewModel.input.status.asObserver()
                .onNext("submit")
              self?.showActivityIndicator()
            }
          }
    
          
        })
        .disposed(by: disposeBag)
      
      btnHold.rx.tap.asObservable()
        .subscribe(onNext:{[weak self] _ in
          
          let message = String(format:"%@%@ %@ %@ %@","Are you sure you want to put payment #", (self?.obj.paymentId)! ,"for contractor",(self?.obj.contractor.name)!," on hold ?")
          
          self?.confirmation(message: message) { result in
            
            if (result){
              viewModel.input.status.asObserver()
                .onNext("hold")
              self?.showActivityIndicator()
            }
          }
          
          
        })
        .disposed(by: disposeBag)
      
      
//
//      btnHold.rx.tap.asObservable()
//        .subscribe({[weak self] _ in
//
//
//
//          self?.confirmation(message: message) { result in
//
//            if (result){
//              viewModel.input.status.asObserver()
//                .onNext("hold")
//              self?.showActivityIndicator()
//            }
//          }
//
//        })
//        .disposed(by: disposeBag)
      
//      btnContinue.rx.tap.asObservable()
//        .subscribe(onNext:{[weak self] _ in
//        })
//        .disposed(by: disposeBag)
      */

    }
    
    func confirmation(message:String, completionHandler: @escaping (_ result: Bool) -> Void){
      
        let refreshAlert = UIAlertController(title: "Confirmation!", message: message, preferredStyle: UIAlertController.Style.alert)
      
      refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in

           completionHandler(true)
        
      }))
      
      refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
        completionHandler(false)
      }))

      Common.appDelegate.window?.rootViewController?.present(refreshAlert, animated: true, completion: nil)
   
    }
    
    
    static func create(with viewModel: PaymentSummaryViewModel) -> UIViewController {
      let storyboard = UIStoryboard(name: "Main", bundle: nil)
      let controller = storyboard.instantiateViewController(withIdentifier: "SummaryVC") as! PaymentSummaryViewController
      controller.viewModel = viewModel
      return controller
    }
    
    
    func showActivityIndicator() {
      let size = CGSize(width: 70, height: 70)
      startAnimating(size, message: "",messageFont: nil, type:  NVActivityIndicatorType.ballBeat, color: UIColor(red: 0/255, green: 97/255, blue: 158/255, alpha: 1.0),padding:10)
      
    }
    
    //MARK: -- noData view --
    var noData : NoDataView!
    func notAvailable(isNetwork:Bool){
        
        noData = NoDataView.getEmptyDataView()
        noData.frame = CGRect(x: 100, y: 100, width: Common.screenWidth - 100,  height:Common.screenHeight - 100)
      
        if isNetwork {
            noData.setLayout(noNetwork:isNetwork,Yposition :5)
            noData.backBtn.addTarget(self, action: #selector(self.remvoeNotAvailable), for: .touchUpInside)
        } else {
            noData.setLayout(description:"Unable to load payment summary.", noNetwork:isNetwork,Yposition :5)
            noData.backBtn.addTarget(self, action: #selector(self.popToViewController), for: .touchUpInside)
        }
        
        self.view?.addSubview(noData)
    }
    
    @objc func remvoeNotAvailable(){
        
        if(Common.isConnectedToNetwork() == true){
            noData.removeFromSuperview()
            //Call summary api again
//            let projectID : String = obj.contractId.description
//            let paymentID : String = obj.paymentId.description
//            
//            viewModel.input.paymentId.asObserver()
//                .onNext(paymentID)
//            
//            viewModel.input.projectId.asObserver()
//                .onNext(projectID)
            self.showActivityIndicator()
        }
    }
    
    @objc func popToViewController(){
        self.navigationController?.popViewController(animated: false)
    }
    
    
    
  }
