//
//  PlanMyTripViewController.swift
//  Progress
//
//  Created by Muhammad Akhtar on 10/14/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PlanMyTripViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var btnSelectAll: UIButton!
    @IBOutlet weak var btnUncheckAll: UIButton!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var lblCountOfSelectedProjects: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var lblProjects: UILabel!
    @IBOutlet weak var lblNumberOfProjects: UILabel!
    @IBOutlet weak var containerView: UIView!
    var projectsArray :[Dashboard] = [Dashboard]()
    let projectsPayload = Variable<[Dashboard]>([])
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        addMRHEHeaderView()
        addMRHELeftMenuView()
        setLayout()
        
        bindCollectionViewData()
        
        if(Common.isConnectedToNetwork() == false){
            notAvailable(isNetwork: true)
        } else if SharedResources.sharedInstance.contractsPayload.payload.dashboard.count == 0 {
            notAvailable(isNetwork: false)
        }
    }
    
    func bindCollectionViewData() {
        
        setCollectionViewArrayAsPerSelectedTrips()
        setCountLable()
        
        projectsPayload.asObservable()
            .bind(to: collectionView.rx.items(cellIdentifier: "cell")){
                (_, obj, cell) in
                if let cell = cell as? PlanTripCell {
                    cell.setData(projectObj: obj)
                }
            }
            .disposed(by: disposeBag)
        
        
        collectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        collectionView.rx
            .modelSelected(Dashboard.self)
            .subscribe(onNext:  { obj in
                //print(obj)
            })
            .disposed(by: disposeBag)
        
        collectionView.rx.itemSelected.subscribe(onNext:  {
            [weak self] IndexPath in
            if let cell = self?.collectionView.cellForItem(at: IndexPath) as? PlanTripCell {
                let obj  = self?.projectsPayload.value[IndexPath.row]
                
                if (obj?.isObjectSelected)! {
                    cell.containerView.borderWidth  = 0.0
                    cell.containerView.borderColor = UIColor.clear
                    self?.projectsPayload.value[IndexPath.row].isObjectSelected = false
                } else {
                    cell.containerView.borderWidth  = 1.0
                    cell.containerView.borderColor = Common.appThemeColor
                    self?.projectsPayload.value[IndexPath.row].isObjectSelected = true
                }
                self?.setCountLable()
            }
            
        })
            .disposed(by: disposeBag)
        
        btnSelectAll.rx.tap
            .bind {
                var updatedObjectsArray: [Dashboard] = [Dashboard]()
                let objects = self.projectsPayload.value
                for obj in objects{
                    obj.isObjectSelected = true
                    updatedObjectsArray.append(obj)
                }
                self.projectsPayload.value.removeAll()
                self.projectsPayload.value = updatedObjectsArray
                self.setCountLable()
            }
            .disposed(by: disposeBag)
        
        btnUncheckAll.rx.tap
            .bind {
                var updatedObjectsArray: [Dashboard] = [Dashboard]()
                let objects = self.projectsPayload.value
                for obj in objects{
                    obj.isObjectSelected = false
                    updatedObjectsArray.append(obj)
                }
                self.projectsPayload.value.removeAll()
                self.projectsPayload.value = updatedObjectsArray
                self.setCountLable()
            }
            .disposed(by: disposeBag)
        
        
        btnAdd.rx.tap
            .bind {
                //On Add tap update the selected trip array
                var selectedObjectsArray: [Dashboard] = [Dashboard]()
                let objects = self.projectsPayload.value
                for obj in objects{
                    if obj.isObjectSelected {
                        //                        guard Double(obj.plot.latitude) != nil else {
                        //                            continue
                        //                        }
                        selectedObjectsArray.append(obj)
                    }
                }
                SharedResources.sharedInstance.selectedTripContracts = selectedObjectsArray
                self.navigationController?.popViewController(animated: false)
            }
            .disposed(by: disposeBag)
        
        btnCancel.rx.tap
            .bind {
                //On cancel tap make all isObjectSelected false
                var updatedObjectsArray: [Dashboard] = [Dashboard]()
                let objects = self.projectsPayload.value
                for obj in objects{
                    obj.isObjectSelected = false
                    updatedObjectsArray.append(obj)
                }
                self.projectsPayload.value.removeAll()
                self.projectsPayload.value = updatedObjectsArray
                
                //SharedResources.sharedInstance.selectedTripContracts.removeAll()
                self.navigationController?.popViewController(animated: false)
            }
            .disposed(by: disposeBag)
        
    }
    
    func setCollectionViewArrayAsPerSelectedTrips() {
        
        var updatedObjectsArray: [Dashboard] = [Dashboard]()
        let paymentObjArray = SharedResources.sharedInstance.contractsPayload.payload.dashboard
        for obj in paymentObjArray{
            

            updatedObjectsArray.append(obj)
        }
        self.projectsPayload.value.removeAll()
        self.projectsPayload.value = updatedObjectsArray
        
    }
    
    func setCountLable() {
        let objects = self.projectsPayload.value
        var count = 0
        for obj in objects{
            if obj.isObjectSelected {
               
                count = count + 1
            }
        }
        self.lblNumberOfProjects.text = "\(count)"
    }
    
    
    //    deinit {
    //        disposeBag.insert(disposeBag as! Disposable)
    //    }
    
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
    
    func setLayout(){
        
        self.collectionView.register(UINib(nibName: "PlanTripCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        
    }
    
    //MARK: ---- UICollectionView delagte and datasource method ----
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: 418.0, height: 218.0)
    }
    
    //MARK: -- noData view --
    var noData : NoDataView!
    func notAvailable(isNetwork:Bool){
        
        noData = NoDataView.getEmptyDataView()
        noData.frame = CGRect(x: (self.containerView?.frame.origin.x)!, y:(self.containerView?.frame.origin.y)!, width: (self.containerView?.frame.size.width)!,  height:(self.containerView?.frame.size.height)!)
        
        if isNetwork {
            noData.setLayout(noNetwork:isNetwork,Yposition :5)
            noData.backBtn.addTarget(self, action: #selector(self.remvoeNotAvailable), for: .touchUpInside)
        } else {
            noData.setLayout(description:"Unable to show route, Please make sure the plots has been slected for trip.", noNetwork:isNetwork,Yposition :5)
            noData.backBtn.addTarget(self, action: #selector(self.popToRootView), for: .touchUpInside)
        }
        self.view?.addSubview(noData)
        
    }
    
    @objc func popToRootView(){
        self.navigationController?.popViewController(animated: false)
        
    }
    
    @objc func remvoeNotAvailable(){
        
        if(Common.isConnectedToNetwork() == true){
            noData.removeFromSuperview()
        }
    }
    
    
}

