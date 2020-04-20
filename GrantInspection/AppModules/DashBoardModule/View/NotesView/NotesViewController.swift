//
//  NotesViewController.swift
//  Progress
//
//  Created by Muhammad Akhtar on 11/12/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import NVActivityIndicatorView

class NotesViewController: UIViewController, ControllerType, NVActivityIndicatorViewable {
    
    // MARK: - Properties
    
    
    @IBOutlet weak var btnComment: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var txtFieldComment: UITextField!
    @IBOutlet weak var tblView: UITableView!
    
    var refresher:UIRefreshControl!
    var obj:Dashboard = Dashboard()
    var remarksArray = Variable<[String]>([])
    
    typealias ViewModelType = PaymentNotesViewModel
    var viewModel: ViewModelType!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.tblView.register(UINib(nibName: "NotesCustomCell", bundle: nil), forCellReuseIdentifier: "NotesCustomCell")
        configure(with: viewModel)
        setRefreshControl()
        
        if(Common.isConnectedToNetwork() == false){
            notAvailable(isNetwork: true)
        }
        txtFieldComment.placeholder = "enter_comments_placeholder".ls
    }
    
    
    func setRefreshControl() {
        self.refresher = UIRefreshControl()
        self.tblView!.alwaysBounceVertical = true
        self.refresher.tintColor = Common.appThemeColor
        self.refresher.addTarget(self, action: #selector(fetch), for: .valueChanged)
        self.tblView!.addSubview(refresher)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


  @objc func fetch(){
    /*
    let contractId = obj.contractId.description
    let plotId = obj.plot.landNo.description
    let paymentId = obj.paymentId.description
    let pId = "0"
    
    viewModel.input.paymentId.asObserver()
      .onNext(paymentId)
    
    viewModel.input.plotId.asObserver()
      .onNext(plotId)
    
    viewModel.input.contractorId.asObserver()
      .onNext(contractId)
    
    viewModel.input.pId.asObserver()
      .onNext(pId)
    */
   // self.showActivityIndicator()
  }

    func configure(with viewModel: PaymentNotesViewModel) {
      
        fetch()
      
        txtFieldComment.rx.text.asObservable()
            .ignoreNil()
            .subscribe(viewModel.input.remark)
            .disposed(by: disposeBag)

        
        btnComment.rx.tap.asObservable()
            .subscribe(viewModel.input.addCommentDidTap)
            .disposed(by: disposeBag)

        
        if Common.isConnectedToNetwork() == true
        {
            fetch()
            
            txtFieldComment.rx.text.asObservable()
                .ignoreNil()
                .subscribe(viewModel.input.remark)
                .disposed(by: disposeBag)
            
            
            btnComment.rx.tap.asObservable()
                .subscribe(viewModel.input.addCommentDidTap)
                .disposed(by: disposeBag)
            
            btnComment.rx.tap.asObservable()
                .subscribe(onNext:{[weak self] _ in
                    //call add comment service
                    if !((self?.txtFieldComment.text?.isEmpty)!){
                        self?.remarksArray.value.append((self?.txtFieldComment.text!)!)
                        self?.txtFieldComment.text = ""
                        if (self?.remarksArray.value.count)! > 0{
                            self?.scrollToBottom()
                        }
                        
                        self?.view.endEditing(true)
                    }
                    
                })
                .disposed(by: disposeBag)
            
            
            viewModel.output.paymentCommentsResultObservable
                .subscribe(onNext: { [unowned self] (commentPayload) in
                    self.refresher.endRefreshing()
                    self.remarksArray.value =  commentPayload.payload
                    if (self.remarksArray.value.count) > 0{
                        self.scrollToBottom()
                    } else {
                        if(Common.isConnectedToNetwork() == false){
                            self.notAvailable(isNetwork: true)
                        }
                        
                    }
                    self.stopAnimating()
                    
                })
                .disposed(by: disposeBag)
            
            
            viewModel.output.paymentNotesResultObservable
                .subscribe(onNext: { [unowned self] (notesPayload) in
                    
                    if(Common.isConnectedToNetwork() == false){
                        self.notAvailable(isNetwork: true)
                    }
                    
                })
                .disposed(by: disposeBag)
            
            viewModel.output.errorsObservable
                .subscribe(onNext: { [unowned self] (error) in
                    
                    self.refresher.endRefreshing()
                    self.stopAnimating()
                    let errorMessage = (error as NSError).domain
                    Common.showToaster(message: errorMessage)

                })
                .disposed(by: disposeBag)
            
            remarksArray.asObservable()
                .bind(to: self.tblView.rx.items(cellIdentifier: "NotesCustomCell")){
                    (_, obj, cell) in
                    if let cell = cell as? NotesCustomCell {
                        cell.setData(obj: obj)
                    }
            }
            .disposed(by: disposeBag)
            
            btnBack.rx.tap.asObservable()
                .subscribe(onNext:{[weak self] _ in
                    self?.navigationController?.popViewController(animated: false)
                })
                .disposed(by: disposeBag)
        }
        else{
            Common.showToaster(message: "no_Internet".ls)

        }
        
    }
    
    static func create(with viewModel: PaymentNotesViewModel) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "NotesVC") as! NotesViewController
        controller.viewModel = viewModel
        return controller
    }
    
    func scrollToBottom(){
        
        DispatchQueue.main.async {
            
            let indexPath = IndexPath(row: self.remarksArray.value.count - 1, section: 0)
            self.tblView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    
    func showActivityIndicator() {
        let size = CGSize(width: 70, height: 70)
        startAnimating(size, message: "",messageFont: nil, type: NVActivityIndicatorType.ballBeat, color: UIColor(red: 0/255, green: 97/255, blue: 158/255, alpha: 1.0),padding:10)
        
    }
    
    //MARK: -- noData view --
    var noData : NoDataView!
    func notAvailable(isNetwork:Bool){
        
        noData = NoDataView.getEmptyDataView()
        noData.frame = CGRect(x: 0, y: 100, width: Common.screenWidth,  height:Common.screenHeight - 100)
        noData.setLayout(noNetwork:isNetwork,Yposition :5)
        noData.backBtn.addTarget(self, action: #selector(self.remvoeNotAvailable), for: .touchUpInside)
        self.view?.addSubview(noData)
    }
    
    @objc func remvoeNotAvailable(){
        
        if(Common.isConnectedToNetwork() == true){
            noData.removeFromSuperview()
        }
    }
    
}
