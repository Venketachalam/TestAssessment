//
//  ProjectsListingView.swift
//  Progress
//
//  Created by Muhammad Akhtar on 9/30/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import UIKit

protocol PeojectListingViewDelegate {
    func selectedPayment_Action(index:Int)
    func addToTrip_Action(paymentOBJ:Dashboard)
    func addPlotButton_Action(paymentOBJ:Dashboard,delegateObj:PeojectListingViewDelegate)
    func gotToNotes_Action(paymentOBJ:Dashboard)
    func gotToAttachment_Action(paymentOBJ:Dashboard)
    func navigation_Action(paymentOBJ:Dashboard)
    func more_Action(paymentOBJ:Dashboard)
    func boq_Action(paymentOBJ:Dashboard)
    func callApiToRefreshContractList()
    func callPaginationApiWith(page:Int)
    func createReportAction(object:Dashboard)
    func editPlotButton_Action(paymentOBJ:Dashboard,delegateObj:PeojectListingViewDelegate)
    func callApiToRefreshApplicationList(dashboarObj:Dashboard)
}

class ProjectsListingView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var projectsPayload: [Dashboard] = [Dashboard]()
    var delegate:PeojectListingViewDelegate?
    var refresher:UIRefreshControl!
    var currentPage : Int = 0
    
    
    
    
    class func getProjectsListingView() -> ProjectsListingView
    {
        return Bundle.main.loadNibNamed("ProjectsListingView", owner: self, options: nil)![0] as! ProjectsListingView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.collectionView.register(UINib(nibName: "ProjectsListingCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        //flippedView()
        setFonts()
        NotificationCenter.default.removeObserver(self, name: Notification.Name("dashboardRefreshApi"), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(self.loadData),name:Notification.Name("dashboardRefreshApi") ,object: nil)
        setRefreshControl()
        collectionView.reloadData()
    }
    
    func setRefreshControl() {
        self.refresher = UIRefreshControl()
        self.collectionView!.alwaysBounceVertical = true
        self.refresher.tintColor = Common.appThemeColor
        self.refresher.addTarget(self, action: #selector(loadData), for: .valueChanged)
        self.collectionView!.addSubview(refresher)
    }
    
    @objc func loadData() {
       SharedResources.sharedInstance.isRefreshNeeded = true
        self.delegate?.callApiToRefreshContractList()
        stopRefresher()
            
    }
    
    func stopRefresher() {
        self.refresher.endRefreshing()
    }
    
    func setFonts() {
    }
    
    
    //MARK: ---- UICollectionView delagte and datasource method ----
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        //return CGSize(width: 418.0, height: 290.0)
        
        return CGSize(width: collectionView.frame.width / 2, height: 290.0)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        print("==>>collectionView.Frame    ", collectionView.frame)
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.projectsPayload.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : ProjectsListingCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ProjectsListingCell
        
        
        let projectObj = self.projectsPayload[indexPath.row]
        cell.setData(projectObj: projectObj)
        
        if projectObj.reportStatus == "1" {
            cell.requestStatusLbl.text = "Completed_lbl".ls
            cell.requestStatusLbl.textColor = UIColor(red: 0/255, green: 195/255, blue: 179/255, alpha: 1.0)
        }else {
            cell.requestStatusLbl.text = "pay_request_status".ls
            cell.requestStatusLbl.textColor = UIColor(red: 255/255, green: 111/255, blue: 121/255, alpha: 1.0)
        }
        // cell.btnCell.tag = indexPath.row
        //cell.btnCell.addTarget(self, action: #selector(cell_Action(_:)), for: .touchUpInside)
        cell.btnAddToTrip.tag = indexPath.row
        cell.btnAddToTrip.addTarget(self, action: #selector(btnAddToTrip_Action(_:)), for: .touchUpInside)
        cell.btnNotes.tag = indexPath.row
        cell.btnNotes.addTarget(self, action: #selector(btnNotes_Action(_:)), for: .touchUpInside)
        cell.btnAttachments.tag = indexPath.row
        cell.btnAttachments.addTarget(self, action: #selector(btnAttachments_Action(_:)), for: .touchUpInside)
        cell.btnNavigation.tag = indexPath.row
        cell.btnNavigation.addTarget(self, action: #selector(btnNavigation_Action(_:)), for: .touchUpInside)
        cell.btnMore.tag = indexPath.row
        cell.btnMore.addTarget(self, action: #selector(btnMore_Action(_:)), for: .touchUpInside)
        cell.callNowBtn.tag = indexPath.row
        cell.callNowBtn.addTarget(self, action: #selector(callNowButtonPressed(_:)), for: .touchUpInside)
        
        cell.addPlotNumberButton.tag=indexPath.row
        cell.addPlotNumberButton.addTarget(self, action: #selector(addPlotButton_Action(_:)), for: .touchUpInside)
        
        cell.btnEditToTrip.tag = indexPath.row
        cell.btnEditToTrip.addTarget(self, action: #selector(editPlotButton_Action(_:)), for: .touchUpInside)
        
        
        //      if SharedResources.sharedInstance.appFeatureStatus.payments.is_add_trip == false{
        //        cell.btnAddToTrip.isUserInteractionEnabled = false
        //        cell.btnAddToTrip.setImage(UIImage.init(named: "add_disable_icon"), for: .normal)
        //        cell.btnAddToTrip.backgroundColor = UIColor.init(hex: "#9DD0C2")
        //      }
        //      if SharedResources.sharedInstance.appFeatureStatus.payments.is_comments == false{
        //        cell.btnNotes.isUserInteractionEnabled = false
        //        cell.btnNotes.setImage(UIImage.init(named: "comment_icon_disable"), for: .normal)
        //      }
        //      if SharedResources.sharedInstance.appFeatureStatus.payments.is_attachments == false{
        //        cell.btnAttachments.isUserInteractionEnabled = false
        //        cell.btnAttachments.setImage(UIImage.init(named: "attachment_icon_disable"), for: .normal)
        //      }
        //      if SharedResources.sharedInstance.appFeatureStatus.payments.is_plot_on_map == false{
        //        cell.btnNavigation.isUserInteractionEnabled = false
        //        cell.btnNavigation.setImage(UIImage.init(named: "navigate_icon_disable"), for: .normal)
        //      }
        //      if SharedResources.sharedInstance.appFeatureStatus.payments.is_payment_detail == false{
        //        cell.btnMore.isUserInteractionEnabled = false
        //        cell.btnMore.setImage(UIImage.init(named: "detail_icon_disable"), for: .normal)
        //      }
        //      if SharedResources.sharedInstance.appFeatureStatus.payments.is_payment_boq_listing == false{
        //       // cell.btnCell.isUserInteractionEnabled = false
        //      }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        
        //      print("currentPage",currentPage)
        //      print("arrayCount",self.projectsPayload.count - 1)
        //      print("indexPath",indexPath.row)
        //      print("totalPages",SharedResources.sharedInstance.contractsPayload.payload.pagination.totalPages)
        //      print("total payload",SharedResources.sharedInstance.contractsPayload.payload.payment.count )
        //
        if indexPath.row == self.projectsPayload.count - 1 { // last cell
            if SharedResources.sharedInstance.contractsPayload.payload.pagination.totalItems > self.projectsPayload.count {
                // more items to fetch
                SharedResources.sharedInstance.isRefreshNeeded = true
                currentPage = currentPage + 1
                self.delegate?.callPaginationApiWith(page: currentPage)
                
            }
        }
        /*
         
         if indexPath.row == (self.projectsPayload.count - 1) && currentPage < SharedResources.sharedInstance.contractsPayload.payload.pagination.totalPages{
         
         currentPage = currentPage + 1
         self.delegate?.callPaginationApiWith(page: currentPage)
         }
         
         if indexPath.row == (self.projectsPayload.count - 1) && currentPage < SharedResources.sharedInstance.contractsPayload.payload.pagination.totalPages && SharedResources.sharedInstance.contractsPayload.payload.pagination.totalItems > 4{
         
         currentPage = currentPage + 1
         self.delegate?.callPaginationApiWith(page: currentPage)
         
         }
         */
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let _ = delegate  {
            if projectsPayload.count > indexPath.row {
                delegate?.createReportAction(object: projectsPayload[indexPath.row])
            }
            
        }
    }
    //MARK: - UIButton Action
    
    @objc func callNowButtonPressed(_ sender : UIButton){
        
        if SharedResources.sharedInstance.contractsPayload.payload.dashboard.count > 0 {
            let phoneNumber = SharedResources.sharedInstance.contractsPayload.payload.dashboard[sender.tag].applicantMobileNo
            Common.dialNumber(number: phoneNumber)
        }
        
    }
    @objc func infoButton_Action(_ sender:UIButton) {
        
    }
    
    @objc func cell_Action(_ sender:UIButton) {
        
        if SharedResources.sharedInstance.contractsPayload.payload.dashboard.count > 0 {
            self.delegate?.selectedPayment_Action(index: sender.tag)
        }
        
    }
    
    @objc func btnAddToTrip_Action(_ sender:UIButton) {
        
        if SharedResources.sharedInstance.contractsPayload.payload.dashboard.count > 0 {
            self.delegate?.addToTrip_Action(paymentOBJ: SharedResources.sharedInstance.contractsPayload.payload.dashboard[sender.tag])
        }
        
    }
    
    @objc func addPlotButton_Action(_ sender:UIButton) {
        
        if SharedResources.sharedInstance.contractsPayload.payload.dashboard.count > 0
        {
             SharedResources.sharedInstance.isRefreshNeeded = true
            self.delegate?.addPlotButton_Action(paymentOBJ:SharedResources.sharedInstance.contractsPayload.payload.dashboard[sender.tag],delegateObj:self.delegate!)
        }
        
    }
    
    @objc func editPlotButton_Action(_ sender:UIButton)
    {
        if SharedResources.sharedInstance.contractsPayload.payload.dashboard.count > 0 {
            SharedResources.sharedInstance.isRefreshNeeded = true
            self.delegate?.editPlotButton_Action(paymentOBJ: SharedResources.sharedInstance.contractsPayload.payload.dashboard[sender.tag], delegateObj: self.delegate!)
        }
    }
    
    @objc func btnNotes_Action(_ sender:UIButton) {
        
        if SharedResources.sharedInstance.contractsPayload.payload.dashboard.count > 0 {
            self.delegate?.gotToNotes_Action(paymentOBJ: SharedResources.sharedInstance.contractsPayload.payload.dashboard[sender.tag])
            
        }
    }
    
    @objc func btnAttachments_Action(_ sender:UIButton) {
        
        if SharedResources.sharedInstance.contractsPayload.payload.dashboard.count > 0 {
            self.delegate?.gotToAttachment_Action(paymentOBJ: SharedResources.sharedInstance.contractsPayload.payload.dashboard[sender.tag])
        }
        
    }
    
    @objc func btnNavigation_Action(_ sender:UIButton) {
        
        if SharedResources.sharedInstance.contractsPayload.payload.dashboard.count > 0 {
            self.delegate?.navigation_Action(paymentOBJ: SharedResources.sharedInstance.contractsPayload.payload.dashboard[sender.tag])
        }
    }
    
    @objc func btnMore_Action(_ sender:UIButton) {
        
        if SharedResources.sharedInstance.contractsPayload.payload.dashboard.count > 0 {
            self.delegate?.more_Action(paymentOBJ: SharedResources.sharedInstance.contractsPayload.payload.dashboard[sender.tag])
        }
    }
    
    
    
    
    
}
