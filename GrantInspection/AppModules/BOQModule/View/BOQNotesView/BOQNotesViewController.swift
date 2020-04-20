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

class BOQNotesViewController: UIViewController, ControllerType, NVActivityIndicatorViewable {
  
  
    @IBOutlet weak var btnComment: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var txtFieldComment: UITextField!
    @IBOutlet weak var tblView: UITableView!
  
    var remarksArray = Variable<[String]>([])
    var model:MRHEOpenNewFileBillOfQuantityInnerObject = MRHEOpenNewFileBillOfQuantityInnerObject(paymentDetailId: 0, workId: 0, workDesc: "", contarctPercentage: 0, actualDone: 0, paymentPercentage: 0, engineerPercentage: 0, comment: [])
    var contractId : String = ""
    var paymentId : String = ""
    var refresher:UIRefreshControl!
    typealias ViewModelType = BOQNotesViewModel
  
    // MARK: - Properties0
    private var viewModel: ViewModelType!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Do any additional setup after loading the view.
        self.tblView.register(UINib(nibName: "BOQNotesCustomCell", bundle: nil), forCellReuseIdentifier: "Cell")
        configure(with: viewModel)
   
        setRefreshControl()
        
        if(Common.isConnectedToNetwork() == false){
            notAvailable(isNetwork: true)
        }
  }
  
  
  func setRefreshControl() {
    
    self.refresher = UIRefreshControl()
    self.tblView!.alwaysBounceVertical = true
    self.refresher.tintColor = Common.appThemeColor
    self.refresher.addTarget(self, action: #selector(fetch), for: .valueChanged)
    self.tblView!.addSubview(refresher)
  }

  @objc func fetch(){
    
    let contractId = self.contractId.description
    let paymentId = self.paymentId.description
    let workID = model.workId.description
    let percentage = model.engineerPercentage.description
    let pID = model.paymentDetailId.description
    
    
    viewModel.input.paymentId.asObserver()
      .onNext(paymentId)
    
    viewModel.input.workID.asObserver()
      .onNext(workID)
    
    viewModel.input.contractId.asObserver()
      .onNext(contractId.description)
    
    viewModel.input.engineerPercentage.asObserver()
      .onNext(percentage)
    
    viewModel.input.pId.asObserver()
      .onNext(pID)
    
    showActivityIndicator()
  }
  
  override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func configure(with viewModel: BOQNotesViewModel) {
      
        fetch()
      
        txtFieldComment.rx.text.asObservable()
            .ignoreNil()
            .subscribe(viewModel.input.comment)
            .disposed(by: disposeBag)
 
        btnComment.rx.tap.asObservable()
            .subscribe(viewModel.input.addCommentDidTap)
            .disposed(by: disposeBag)
        
        btnComment.rx.tap.asObservable()
            .subscribe(onNext:{[weak self] _ in
                //call add comment service
                if(Common.isConnectedToNetwork() == false){
                    self?.notAvailable(isNetwork: true)
                } else {
                    if !((self?.txtFieldComment.text?.isEmpty)!){
                        self?.remarksArray.value.append((self?.txtFieldComment.text!)!)
                        self?.txtFieldComment.text = ""
                        self?.scrollToBottom()
                        self?.view.endEditing(true)
                    }
                }
                
            
              
            
            })
            .disposed(by: disposeBag)
        
        
        viewModel.output.boqNotesResultObservable
            .subscribe(onNext: { [unowned self] (notesPayload) in
                self.stopAnimating()
                
            })
            .disposed(by: disposeBag)
      
   
      viewModel.output.boqCommentsResultObservable
        .subscribe(onNext: { [unowned self] (commentPayload) in
          self.refresher.endRefreshing()
          self.remarksArray.value =  commentPayload.payload
          if (self.remarksArray.value.count) > 0{
            self.scrollToBottom()
          }else {
            if(Common.isConnectedToNetwork() == false){
                self.notAvailable(isNetwork: true)
            }
            }
          self.stopAnimating()
          
        })
        .disposed(by: disposeBag)
      
      
        
        viewModel.output.errorsObservable
            .subscribe(onNext: { [unowned self] (error) in
                self.stopAnimating()
                let errorMessage = (error as NSError).domain

            })
            .disposed(by: disposeBag)
    
         remarksArray.asObservable()
         .bind(to: self.tblView.rx.items(cellIdentifier: "Cell")){
         (_, obj, cell) in
            if let cell = cell as? BOQNotesCustomCell {
              
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
    
    static func create(with viewModel: BOQNotesViewModel) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "BOQNotesViewController") as! BOQNotesViewController
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
