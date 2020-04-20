//
//  DashboardViewController.swift
//  Progress
//
//  Created by Muhammad Akhtar on 6/4/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//
import Foundation
import UIKit
import NVActivityIndicatorView
import RxSwift
import RxCocoa
import NotificationBannerSwift
class DashboardViewController: UIViewController, NVActivityIndicatorViewable, PeojectListingViewDelegate, UITableViewDelegate, PlotMapViewDelegate, ControllerType , UITextFieldDelegate{

  
  // MARK: - Properties
  @IBOutlet weak var mainFilterView: UIView!
  @IBOutlet weak var startMyTripView: MBRHEBorderView!
  @IBOutlet weak var planMyTripImgView: UIImageView!
  @IBOutlet weak var lblPlanMyTrip: UILabel!
  @IBOutlet weak var projectListingView: UIView!
  @IBOutlet weak var projectMapView: UIView!
  @IBOutlet weak var filterOptionsView: MBRHEBorderView!
  @IBOutlet weak var filterTblView: UITableView!
  @IBOutlet weak var radiobtnView: MBRHEBorderView!
  @IBOutlet weak var lblSelectedOptionTitle: UILabel!
  @IBOutlet weak var searchView: UIView!
  @IBOutlet weak var btnList: UIButton!
  @IBOutlet weak var btnFindProject: UIButton!
  @IBOutlet weak var btnMap: UIButton!
  @IBOutlet weak var btnFindContracts: UIButton!
  @IBOutlet weak var btnStartMyTrip: UIButton!
  @IBOutlet weak var searchViewHeightConstant: NSLayoutConstraint!
  @IBOutlet weak var btnPlanMyTrip: UIButton!
  @IBOutlet weak var clearFilterOptionView: UIView!

    @IBOutlet weak var searchResultsLabel: UILabel!
    @IBOutlet weak var startMytripLbl: UILabel!
  @IBOutlet weak var mainLbl: UILabel!
  @IBOutlet weak var currentRequestLbl: UILabel!
  @IBOutlet weak var containerView: UIView!
  
    @IBOutlet weak var headerView: UIView!
    
  var isFilterViewHidden = true
  var projectsListView : ProjectsListingView?
  var projectsMapView : ProjectsMapView?
  var projectSerachView : ProjectSearchView?
  
  var isSearchViewOpen = false
  var isFromTabSearchVC = false
  var isListViewShown = true
  var filteredPaymentsArray: [Dashboard] = [Dashboard]()
  var selectedFilterValue = "3"
  var paymentObj: Dashboard = Dashboard()
  var filtersArray: [Filters] = [Filters]()

  @IBOutlet weak var selectAllbtn: UIButton!
  @IBOutlet weak var unSelectAllBtn: UIButton!
  @IBOutlet weak var innerView: UIView!
  let projectsPayload = Variable<[Dashboard]>([])
  
    @IBOutlet weak var clearFilterBtn: UIButton!
    var page : Int = 0
  var noData : NoDataView!
  var mrheMenuView : MBRHELeftMenuView!
  var searchPlotView : SearchPlotView?
  var SimplifiedReportPopView :SimplifiedReportPopController?
    
  private var viewModel: ViewModelType!
  private let disposeBag = DisposeBag()
  let filterList = Variable<[Filters]>([])
  typealias ViewModelType = DashboardViewModel
    var showUpgradePopUp = true
  override func viewDidLoad() {
    super.viewDidLoad()
    whenViewIsLoad()
  }
  
  func setLayout(){
    
    self.filterOptionsView.isHidden = true
    self.btnList.isUserInteractionEnabled = false
    self.mainLbl.text = "main_page".ls
    self.currentRequestLbl.text = "current_request".ls
    self.startMytripLbl.text = "start_my_trip".ls
    
    let yourAttributes : [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.font : UIFont(name: "NeoSansArabic", size: 12) as Any,
        NSAttributedString.Key.foregroundColor : UIColor(red: 0/255, green: 97/255, blue: 158/255, alpha: 1),
        NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue]
    
    let selectAS = NSMutableAttributedString(string: "select_all".ls,
                                                    attributes: yourAttributes)
    let unSelectAS = NSMutableAttributedString(string: "un_select_all".ls,
                                             attributes: yourAttributes)
    selectAllbtn.setAttributedTitle(selectAS, for: .normal)
    unSelectAllBtn.setAttributedTitle(unSelectAS, for: .normal)
    
    let clearFilterAttributes : [NSAttributedString.Key: Any] = [
           NSAttributedString.Key.font : UIFont(name: "NeoSansArabic", size: 14) as Any,
           NSAttributedString.Key.foregroundColor : UIColor(red: 0/255, green: 97/255, blue: 158/255, alpha: 1),
           NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue]
       
       let clearFilterText = NSMutableAttributedString(string: "clear_filters".ls,
                                                       attributes: clearFilterAttributes)
    
    clearFilterBtn.setAttributedTitle(clearFilterText, for: .normal)
      let countOfItems = SharedResources.sharedInstance.contractsPayload.payload.pagination.totalItems
    self.searchResultsLabel.text = String(format:"%@ ( %d )","search_results".ls,countOfItems)

  }
  
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    print("Viewwill")
        if(Common.isConnectedToNetwork() == false){
            noDataAvailable(noInternet: true)
            return
        }
    if (SharedResources.sharedInstance.searchActive)
    {
        self.clearFilterOptionView.isHidden = false
    }
    else
    {
         self.clearFilterOptionView.isHidden = true
    }
    
        whenViewIsAppear()
  }
  
    

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
    func addProjectsListingView()
    {
        if self.projectsMapView != nil {
//            self.projectListingView.willRemoveSubview(self.projectsMapView!)
            self.projectsMapView?.infoWindow.removeFromSuperview()
            self.projectsMapView = nil
        }
        self.projectsListView = ProjectsListingView.getProjectsListingView()
        self.projectsListView?.frame = CGRect.init(x: 0, y: 0, width: self.projectListingView.frame.size.width, height:self.projectListingView.frame.size.height)
        self.projectsListView?.delegate = self
        self.projectListingView.addSubview(self.projectsListView!)
    }
    
    func addProjectsMapView(){
        
        if self.projectListingView != nil {
            self.projectsMapView?.infoWindow.removeFromSuperview()
            self.projectsListView = nil
        }
        self.projectsMapView = ProjectsMapView.getProjectsMapView()
        projectsMapView?.frame = CGRect.init(x: 0, y: 0, width: self.projectListingView.frame.size.width, height:self.projectListingView.frame.size.height)
        self.projectsMapView?.delegate = self
        self.projectListingView.addSubview(projectsMapView!)
    }
  
    func whenViewIsLoad() {
        setLayout()
        addProjectsListingView()
        configure(with: viewModel)
        bindFilterTableView()
        addSearchView()


        if(Common.isConnectedToNetwork() == false){
        }else {
            self.fetchAppFeatureStatus() // fetch the features enable/disable status from github
        }
        
        if Common.currentLanguageArabic() {
            self.view.transform  = Common.arabicTransform
            self.view.toArabicTransform()

            startMytripLbl.semanticContentAttribute = .forceRightToLeft
            btnStartMyTrip.semanticContentAttribute = .forceLeftToRight
            btnStartMyTrip.imageEdgeInsets = UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 0)
            headerView.transform = Common.arabicTransform
            headerView.toArabicTransform()

        }
        else
        {
            self.view.transform  = Common.englishTransform
            self.view.toEnglishTransform()
        }
        addMRHELeftMenuView()
    }
    
    
    func whenViewIsAppear() {
       print ("ViewIsAppear Called")
        callApiToRefreshContractList()
     
    }
  
    
    deinit {
        print("Dashboard VC deintialised")
    }
    @IBAction func btnList_Action(_ sender: Any) {
        self.btnList.backgroundColor = Common.appThemeColor
        self.btnList.setImage(UIImage.init(named: "list_icon_selected"), for: .normal)
        self.btnMap.backgroundColor = UIColor.white
        self.btnMap.setImage(UIImage.init(named: "map_icon_normal"), for: .normal)
        self.btnList.isUserInteractionEnabled = false
        self.btnMap.isUserInteractionEnabled = true
        addProjectsListingView()
        self.reloadCollectionViewWithData()
    }
  
    @IBAction func btnMap_Action(_ sender: Any) {
       
        self.btnList.backgroundColor = UIColor.white
        self.btnList.setImage(UIImage.init(named: "list_icon_normal"), for: .normal)
        self.btnMap.backgroundColor = Common.appThemeColor
        self.btnMap.setImage(UIImage.init(named: "map_icon_selected"), for: .normal)
        self.btnList.isUserInteractionEnabled = true
        self.btnMap.isUserInteractionEnabled = false
        addProjectsMapView()
        self.projectsMapView?.projectsPayload = self.filteredPaymentsArray
        self.clearFilterOptionView.isHidden = true
        self.projectsMapView?.projectsWithLatLongArray = self.filteredPaymentsArray
        self.projectsMapView?.loadPins()
    }
    
    
  @objc func dashboardRefreshApi(notification:NotificationCenter)
    {
        Common.showActivityIndicator()
        callApiToRefreshContractList()
    }
  
  //MARK: --- Search view functions ----

  func addSearchView(){

    self.projectSerachView = ProjectSearchView.getProjectSearchView()
    projectSerachView?.frame = CGRect.init(x: 0, y: 0, width: self.searchView.frame.size.width, height:self.searchView.frame.size.height)
    projectSerachView?.btnApplyFilter.addTarget(self, action: #selector(filterBtnPressed), for: .touchUpInside)
    projectSerachView?.clearButton.addTarget(self, action: #selector(clearBtnPressed), for: .touchUpInside)
    projectSerachView?.txtFieldApplicationNumber.delegate =  self
    projectSerachView?.txtFieldLandNumber.delegate = self
    self.searchView.addSubview(projectSerachView!)

  }
 
   func textFieldDidEndEditing(_ textField: UITextField) {
  }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        let text = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        let Regex = "[0-9a-z A-Zء-ي ]+$"
        let predicate = NSPredicate.init(format: "SELF MATCHES %@", Regex)
        if predicate.evaluate(with: text) || string == ""
        {
            return true
        }
        else
        {
            return false
        }

    }

    func addMRHELeftMenuView()
    {
        mrheMenuView = MBRHELeftMenuView.getMBRHELeftMenuView()
        self.view.addSubview(mrheMenuView)
        if Common.currentLanguageArabic()
        {
            mrheMenuView.transform = Common.arabicTransform
        }
        else
        {
            mrheMenuView.transform = Common.englishTransform
        }
    }
  
  func enableDisableFeatures(){
    
    if SharedResources.sharedInstance.appFeatureStatus.dashbaord.is_plan_trip == false {
      self.btnPlanMyTrip.isUserInteractionEnabled = false
      self.planMyTripImgView.image = UIImage.init(named: "trip_icon_disable")
      self.lblPlanMyTrip.textColor = UIColor.init(hex: "#CFCFCF")
    }

    if SharedResources.sharedInstance.appFeatureStatus.dashbaord.is_start_trip == false {
      self.btnStartMyTrip.isUserInteractionEnabled = false
      self.startMyTripView.backgroundColor = UIColor.init(hex: "#9DD0C2")
    }
    
    if SharedResources.sharedInstance.appFeatureStatus.dashbaord.is_filter_payments_days == false {
      self.btnFindProject.isUserInteractionEnabled = false
    }
    
    if SharedResources.sharedInstance.appFeatureStatus.dashbaord.is_filter_payments == false {
      self.btnFindContracts.isUserInteractionEnabled = false
      self.btnFindContracts.setImage(UIImage.init(named: "search_expoand_icon_disable"), for: .normal)
    }
    
    if SharedResources.sharedInstance.appFeatureStatus.dashbaord.is_payments_mapview == false {
      self.btnMap.isUserInteractionEnabled = false
      self.btnMap.setImage(UIImage.init(named: "map_icon_disable"), for: .normal)
    }
    
  }
  
  static func create(with viewModel: DashboardViewModel) -> UIViewController {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let controller = storyboard.instantiateViewController(withIdentifier: "DashboardScreen") as! DashboardViewController
    controller.viewModel = viewModel
   return controller
  }
  
     static func settings() ->UIViewController
     {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
           let controller = storyboard.instantiateViewController(withIdentifier: "DashboardSettingsViewController") as! DashboardSettingsViewController
        return controller
    }
  
    func navigation(requestDetails:Dashboard)
    {
         let storyboardMain = UIStoryboard(name: "Main", bundle: nil)
        if let dashBoardVc = storyboardMain.instantiateViewController(withIdentifier: "DashboardSettingsViewController") as? DashboardSettingsViewController
             {
                    let rootVC = UINavigationController(rootViewController: dashBoardVc)
                    rootVC.navigationBar.isHidden = true
                    addChild(rootVC)
                    rootVC.view.frame = containerView.bounds
                    containerView.addSubview(rootVC.view)
                    rootVC.didMove(toParent: self)
                }
    }
    
  func configure(with viewModel: ViewModelType) {
   
    btnStartMyTrip.rx.tap.asObservable()
      .subscribe(onNext:{[weak self] _ in
        if SharedResources.sharedInstance.selectedTripContracts.count > 0 {
          
          let storyboard = UIStoryboard(name: "Main", bundle: nil)
          let controller = storyboard.instantiateViewController(withIdentifier: "StartMyTripVC") as! StartMyTripViewController
            controller.mapViewDelegate = self
          SharedResources.sharedInstance.currentRootTag = 0
          self?.navigationController?.pushViewController(controller, animated: false)
        }
        else
        {
            Common.showToaster(message: "startTrip_error_msg".ls)
        }
      })
      .disposed(by: disposeBag)
    
    btnPlanMyTrip.rx.tap.asObservable()
      .subscribe(onNext:{[weak self] _ in
        
        if SharedResources.sharedInstance.contractsPayload.payload.dashboard.count > 0 {
          self?.performSegue(withIdentifier: "PlanMyTripVC", sender: self)
        }
      })
      .disposed(by: disposeBag)
    
    selectAllbtn.rx.tap
      .bind {
        
        SharedResources.sharedInstance.selectedTripContracts.removeAll()
        let objects = SharedResources.sharedInstance.contractsPayload.payload.dashboard
        
        for obj in objects{
            if obj.plot.latitude.count > 0 && obj.plot.longitude.count > 0 {
                obj.isObjectSelected = true
                SharedResources.sharedInstance.selectedTripContracts.append(obj)
            }
          
        }
        
        self.reloadCollectionViewWithData()

      }
      .disposed(by: disposeBag)
    
    unSelectAllBtn.rx.tap
      .bind {
        SharedResources.sharedInstance.selectedTripContracts.removeAll()
        self.reloadCollectionViewWithData()
      }
      .disposed(by: disposeBag)
    
  }
  
  func dashboardAPI(){
   
    let pageSize = "10"
    viewModel.input.pageSize.asObserver()
      .onNext(pageSize)
    viewModel.input.pageSize.onCompleted()
    
//
    viewModel.input.page.asObserver()
      .onNext(self.page.description)
    
    Common.showActivityIndicator()
    _ = self.viewModel.input.viewLoad.asObserver()
      .onNext("")
  }
  
  func bindObservers(){
    
    let pageSize = "10"
    viewModel.input.pageSize.asObserver()
      .onNext(pageSize)
    viewModel.input.page.asObserver()
      .onNext(self.page.description)
    
   viewModel.output.errorsObservable
           .subscribe(onNext: { [unowned self] (error) in
          Common.hideActivityIndicator()
             let errorMessage = (error as NSError).domain
             if !errorMessage.isEmpty{
                Common.showToaster(message: errorMessage)
                self.noDataAvailable(noInternet: false, noDataAvailable: true, serverError: true)
                return

             }else {
                Common.showToaster(message: "bad_Gateway".ls)
                self.noDataAvailable(noInternet: false, noDataAvailable: false, serverError: true)
                return
             }
             self.noDataAvailable(noInternet: true)
           })
           .disposed(by: disposeBag)

   
    viewModel.output.dashBoardResultObservable
      .subscribe(onNext: { [unowned self] (payemtsArray) in
    
        Common.hideActivityIndicator()

        if self.page == 0 {
          SharedResources.sharedInstance.contractsPayload.payload.dashboard.removeAll()
        }
        
        payemtsArray.payload.dashboard = payemtsArray.payload.dashboard.sorted{ $0.applicationNo.intValue > $1.applicationNo.intValue }
        
        print(payemtsArray.payload.dashboard)
        
        if  payemtsArray.payload.dashboard.count > 0 {
  
            for newValue in payemtsArray.payload.dashboard{
                let existingObject = SharedResources.sharedInstance.contractsPayload.payload.dashboard.filter({$0.applicationNo == newValue.applicationNo})
                if existingObject.count == 0 {
                    SharedResources.sharedInstance.contractsPayload.payload.dashboard.append(newValue)
                }
            }

          SharedResources.sharedInstance.contractsPayload.payload.pagination = payemtsArray.payload.pagination
          SharedResources.sharedInstance.contractsPayload.payload.filters = payemtsArray.payload.filters
          SharedResources.sharedInstance.pagesCount = payemtsArray.payload.pagination.totalPages
          
        }
        
        if  SharedResources.sharedInstance.contractsPayload.payload.dashboard.count > 0 {

            if(self.projectsMapView == nil)
            {
                self.reloadCollectionViewWithData()

            }
            else
            {
                self.projectsMapView?.projectsPayload.removeAll()
            
                self.projectsMapView?.removePins()
                self.projectsMapView?.projectsPayload = SharedResources.sharedInstance.contractsPayload.payload.dashboard
                print ("Project payload datas:",SharedResources.sharedInstance.contractsPayload.payload.dashboard)
                print ("Project payload:",SharedResources.sharedInstance.contractsPayload.payload.dashboard.count)
                let countOfItems = SharedResources.sharedInstance.contractsPayload.payload.pagination.totalItems
                self.currentRequestLbl.text = String(format:"%@ ( %d )","current_request".ls,countOfItems)
                self.projectsMapView?.loadPins()
            }
            
            
        }else {
          self.noDataAvailable()
        }
      })
      .disposed(by: disposeBag)
    
    
    
   
  }
 // MARK: - Reload Collection view -
  func reloadCollectionViewWithData() {
    
    self.btnMap.isUserInteractionEnabled = true
    
    self.projectsListView?.currentPage = SharedResources.sharedInstance.contractsPayload.payload.pagination.page

    if self.filteredPaymentsArray.count > 0 {
        self.filteredPaymentsArray.removeAll()
    }
    
    print(self.filteredPaymentsArray)
    
    if selectedFilterValue == "3" {
      self.filteredPaymentsArray = SharedResources.sharedInstance.contractsPayload.payload.dashboard
      // Assign the actuall no of total items
       SharedResources.sharedInstance.contractsPayload.payload.pagination.totalPages =  SharedResources.sharedInstance.pagesCount
    } else {
      self.filteredPaymentsArray = SharedResources.sharedInstance.contractsPayload.payload.dashboard.filter {
        $0.value == selectedFilterValue
      }
        // Assign the actuall no of items within 3 days
       SharedResources.sharedInstance.contractsPayload.payload.pagination.totalPages =  self.filteredPaymentsArray.count / 10
    }
    

    
    SharedResources.sharedInstance.contractsPayload.payload.dashboard = SharedResources.sharedInstance.contractsPayload.payload.dashboard.sorted{ $0.applicationNo.intValue > $1.applicationNo.intValue }
    
    self.filteredPaymentsArray = self.filteredPaymentsArray.sorted{ $0.applicationNo.intValue > $1.applicationNo.intValue }
   
    if self.filteredPaymentsArray.count > 0 {
        self.projectsListView?.projectsPayload.removeAll()
        
      //Data found reload collection view
      self.projectsListView?.projectsPayload = self.filteredPaymentsArray
    }else {
      self.projectsListView?.projectsPayload.removeAll()
    }
    self.projectsListView?.collectionView.reloadData()
    
    //Add filter data
    filtersArray = SharedResources.sharedInstance.contractsPayload.payload.filters
    filterList.value = filtersArray
    
    if (self.projectsListView?.isHidden == false)
    {
        if (self.projectsListView?.projectsPayload.count)! > 0 {
          if self.noData != nil {
          self.noData.removeFromSuperview()
          }
        }
    }

    let countOfItems = SharedResources.sharedInstance.contractsPayload.payload.pagination.totalItems
    self.currentRequestLbl.text = String(format:"%@ ( %d )","current_request".ls,countOfItems)
  }
  //MARK: -- Bind Table view ---
  func bindFilterTableView()  {
    
    filterList.asObservable()
      .bind(to: filterTblView.rx.items(cellIdentifier: "filterCell")){
        (_, filterOBJ, cell) in
        if let filterCell = cell as? FilterCell {
          filterCell.setData(filterOBJ: filterOBJ)
        }
      }
      .disposed(by: disposeBag)
    
    filterTblView.rx
      .modelSelected(Filters.self)
      .subscribe(onNext:  { filterOBJ in
        let tag = Int(filterOBJ.value)
        self.radiobtnView.backgroundColor = Common.hexStringToUIColor(hex: filterOBJ.colorTag)
        if tag == 0 || tag == 1 || tag == 2 {
          // Specific days
          self.radiobtnView.borderWidth = 0.0
          self.lblSelectedOptionTitle.text = String(format: "%@ days", filterOBJ.label)
        } else if tag == 3 {
          // All projects
          self.radiobtnView.borderColor = UIColor.gray
          self.radiobtnView.borderWidth = 1.0
          self.lblSelectedOptionTitle.text = String(format: "%@", filterOBJ.label)
        }
        self.selectedFilterValue = filterOBJ.value
        self.reloadCollectionViewWithData()
        
        self.isFilterViewHidden = true
        self.fadeOut(view: self.filterOptionsView)
        
      })
      .disposed(by: disposeBag)
  }
  

  func callApiToRefreshContractList()
  {
    print(SharedResources.sharedInstance.isRefreshNeeded)
    
      if(SharedResources.sharedInstance.isRefreshNeeded)
          {
    callPaginationApiWith(page: 0)
    SharedResources.sharedInstance.contractsPayload.payload.dashboard.removeAll()
    self.projectsListView?.currentPage = SharedResources.sharedInstance.contractsPayload.payload.pagination.page
    
    if SharedResources.sharedInstance.contractsPayload.payload.dashboard.count > 0 {
        reloadCollectionViewWithData()
        
    }else {
        self.projectsListView?.projectsPayload.removeAll()
        self.projectsListView?.collectionView.reloadData()
        
    }
     self.enableViewsVisibility()
            
    }
  }
    
    func enableViewsVisibility(){
        containerView.backgroundColor = UIColor.clear
        mainFilterView.isHidden = false
        selectAllbtn.isHidden = false
        unSelectAllBtn.isHidden = false
        innerView.isHidden = false
        searchView.isHidden = false
    }
    
    
    func callApiToRefreshApplicationList(dashboarObj: Dashboard) {
       
        callPaginationApiWith(page: 0)
        
        self.btnMap.isUserInteractionEnabled = false
        
        if SharedResources.sharedInstance.selectedTripContracts.count > 0 {
            let removingApplicationNo = dashboarObj.applicationNo
                   
            let index = SharedResources.sharedInstance.selectedTripContracts.firstIndex(where: {$0.applicationNo == removingApplicationNo})
            
            SharedResources.sharedInstance.selectedTripContracts.remove(at: index!)
            
            SharedResources.sharedInstance.selectedTripContracts.append(dashboarObj)
        }
        
        SharedResources.sharedInstance.contractsPayload.payload.dashboard.removeAll()
        self.projectsListView?.currentPage = SharedResources.sharedInstance.contractsPayload.payload.pagination.page
        
        if SharedResources.sharedInstance.contractsPayload.payload.dashboard.count > 0 {
            reloadCollectionViewWithData()
            self.btnMap.isUserInteractionEnabled = true
        }else {
            self.projectsListView?.projectsPayload.removeAll()
            self.projectsListView?.collectionView.reloadData()
            self.btnMap.isUserInteractionEnabled = true
        }
        self.enableViewsVisibility()
    }
    


  func callPaginationApiWith(page: Int) {
   
    if(SharedResources.sharedInstance.isRefreshNeeded)
    {
        SharedResources.sharedInstance.isRefreshNeeded = false
    self.page = page
    if SharedResources.sharedInstance.searchActive == true{
      self.filterApiCall()
    }else {
        bindObservers()
        dashboardAPI()
   }
    }
  }

  @objc func clearBtnPressed(){
    
  self.refreshDashBoardData()
}
 
    
    @IBAction func clearFilterBtnClick(_ sender: Any) {
        self.refreshDashBoardData()
    }
    
    func refreshDashBoardData(){
          UIView.animate(withDuration: 0.7) {
            self.clearFilterOptionView.isHidden = true
        }
        projectSerachView?.txtFieldApplicationNumber.text = ""
          projectSerachView?.txtFieldLandNumber.text = ""
          SharedResources.sharedInstance.applicationNo = ""
          SharedResources.sharedInstance.plotNo = ""
          SharedResources.sharedInstance.searchActive = false
          SharedResources.sharedInstance.isRefreshNeeded = true
          self.page = 0
          closeSearchBar()
          bindObservers()
          dashboardAPI()
    }
    
    
    
  @objc func filterBtnPressed(){
   
    if(searchViewHeightConstant.constant != 0)
    {
   if (self.projectSerachView?.txtFieldLandNumber.text?.isEmpty)! && (self.projectSerachView?.txtFieldApplicationNumber.text?.isEmpty)!{
         Common.showToaster(message: "please_enter_applicationid".ls)
     }

    else {
    
      self.projectSerachView?.btnApplyFilter.isHidden = true
      self.projectSerachView?.clearButton.isHidden = true
      SharedResources.sharedInstance.contractsPayload.payload.dashboard.removeAll()
      self.page = 0
      filterApiCall()
    
    }
    
  }
    }
  
  @objc func filterApiCall(){
    
    
  //  let pageSize = "50"
    let pageSize = "10"
    viewModel.input.pageSize.asObserver()
      .onNext(pageSize)
    
    viewModel.input.page.asObserver()
      .onNext(self.page.description)
    
    let service = FilterService()
    
    var parameter = Dictionary<String, Any>()
    var applicationNumber = self.projectSerachView?.txtFieldApplicationNumber.text
    var plotNumber = self.projectSerachView?.txtFieldLandNumber.text
    SharedResources.sharedInstance.searchActive = true
    
    if !(plotNumber?.isEmpty)! && !(applicationNumber?.isEmpty)!
    {
        SharedResources.sharedInstance.plotNo = plotNumber!
        SharedResources.sharedInstance.applicationNo = applicationNumber!
        
    }
    else if !(plotNumber?.isEmpty)!
    {
        SharedResources.sharedInstance.plotNo = plotNumber!
         SharedResources.sharedInstance.applicationNo = ""
    }
    else if !(applicationNumber?.isEmpty)!
    {
        SharedResources.sharedInstance.applicationNo = applicationNumber!
        SharedResources.sharedInstance.plotNo = ""
    }

    if !SharedResources.sharedInstance.applicationNo.isEmpty {
      applicationNumber = SharedResources.sharedInstance.applicationNo
    }

    if !SharedResources.sharedInstance.plotNo.isEmpty {
      plotNumber = SharedResources.sharedInstance.plotNo
    }
    
    self.projectSerachView?.btnApplyFilter.isUserInteractionEnabled = false

    if (applicationNumber?.count)! > 0 &&  (plotNumber?.count)! > 0 {
      parameter = ["applicantId":plotNumber ?? String(),
                   "applicationNo":applicationNumber ?? String(),
                   "page":page.description,
                   "pageSize":"10"]
    } else if (plotNumber?.count)! > 0 {
      parameter = ["applicantId":plotNumber ?? String(),
                   "page":page.description,
                   "pageSize":"10"]
        self.projectSerachView?.txtFieldApplicationNumber.text = ""

    } else if (applicationNumber?.count)! > 0 {
      parameter = ["applicationNo":applicationNumber ?? String(),
                   "page":page.description,
                   "pageSize":"10"]
        self.projectSerachView?.txtFieldLandNumber.text = ""

    }else if (applicationNumber?.count)! > 0 {
    parameter = ["applicationNo":applicationNumber ?? String(),
                 "page":page.description,
                 "pageSize":"10"]
    }
    else if (applicationNumber?.count)! == 0 &&  (plotNumber?.count)! == 0 {
      
      parameter = ["applicationNo":"",
                   "page":page.description,
                   "pageSize":"10"]
    }
    
    Common.showActivityIndicator()
    service.getContractorPayments(dict: parameter as! Dictionary<String, String>, completion: {(contractorPaymentResponce:ContractsResponse?) in
      
        Common.hideActivityIndicator()
      self.projectSerachView?.btnApplyFilter.isUserInteractionEnabled = true
      
      guard let responce = contractorPaymentResponce else {
        return
      }
      
      if responce.success {
        
        if responce.payload.dashboard.count > 0 {

           UIView.animate(withDuration: 0.7) {
            self.clearFilterOptionView.isHidden = false
                            }
            if self.page == 0 {
                     SharedResources.sharedInstance.contractsPayload.payload.dashboard.removeAll()
                   }
            
            SharedResources.sharedInstance.contractsPayload.payload.dashboard.append(contentsOf: responce.payload.dashboard)
            SharedResources.sharedInstance.contractsPayload.payload.pagination = responce.payload.pagination
            SharedResources.sharedInstance.contractsPayload.payload.filters = responce.payload.filters
            SharedResources.sharedInstance.pagesCount = responce.payload.pagination.totalPages
         
          // Will hide the filter view after the api result only for if search is from dashboard
          if SharedResources.sharedInstance.searchActive == true {
            
            Common.hideActivityIndicator()
            self.closeSearchBar()
            
          }
        }else{
          
          if SharedResources.sharedInstance.contractsPayload.payload.dashboard.count < 0 {
            SharedResources.sharedInstance.contractsPayload.payload.dashboard.removeAll()
          }
          
          SharedResources.sharedInstance.contractsPayload.payload.pagination = responce.payload.pagination
          SharedResources.sharedInstance.contractsPayload.payload.filters = responce.payload.filters
          SharedResources.sharedInstance.pagesCount = responce.payload.pagination.totalPages
            self.noDataAvailable( noDataAvailable: true)
        }
       
        let countOfItems = SharedResources.sharedInstance.contractsPayload.payload.pagination.totalItems
        self.searchResultsLabel.text = String(format:"%@ ( %d )","search_results".ls,countOfItems)
        
        if(self.projectsMapView == nil)
        {
            self.reloadCollectionViewWithData()

        }
        else
        {
            self.projectsMapView?.projectsPayload.removeAll()
     
            self.projectsMapView?.removePins()
            self.projectsMapView?.projectsPayload = SharedResources.sharedInstance.contractsPayload.payload.dashboard
            print ("Project payload datas:",SharedResources.sharedInstance.contractsPayload.payload.dashboard)
            print ("Project payload:",SharedResources.sharedInstance.contractsPayload.payload.dashboard.count)
            let countOfItems = SharedResources.sharedInstance.contractsPayload.payload.dashboard.count
            self.currentRequestLbl.text = String(format:"%@ ( %d )","current_request".ls,countOfItems)
            
            self.projectsMapView?.loadPins()
        }
        
        
      } else {
        if !responce.message.isEmpty{
            Common.showToaster(message: responce.message)
        }else {
          Common.showToaster(message: "bad_Gateway".ls)
        }
        self.noDataAvailable(serverError: true)
      }
    })
    
  }
  
  @IBAction func btnProjectFind_Action(_ sender: Any) {
    
//    return
    if isSearchViewOpen {
      self.btnFindContracts.setImage(UIImage.init(named: "filter_icon"), for: .normal)
      self.btnFindContracts.backgroundColor = UIColor.white
      UIView.animate(withDuration: 0.7) {
        self.searchViewHeightConstant.constant = 0
        self.view.layoutIfNeeded()
      }
      self.searchView.translatesAutoresizingMaskIntoConstraints = false
      self.isSearchViewOpen = false
    
    } else {
      self.btnFindContracts.setImage(UIImage.init(named: "cross_white_icon"), for: .normal)
      self.btnFindContracts.backgroundColor = Common.appThemeColor
      
        self.projectSerachView?.btnApplyFilter.isHidden = false
        self.projectSerachView?.clearButton.isHidden = false
        
      UIView.animate(withDuration: 0.7) {
        self.searchViewHeightConstant.constant = 288
        self.view.layoutIfNeeded()
      }
      self.searchView.translatesAutoresizingMaskIntoConstraints = false
      self.isSearchViewOpen = true
    }
  }
  
  func closeSearchBar(){
 
    self.btnFindContracts.setImage(UIImage.init(named: "filter_icon"), for: .normal)
    self.btnFindContracts.backgroundColor = UIColor.white
    UIView.animate(withDuration: 0.7) {
      self.searchViewHeightConstant.constant = 0
      self.view.layoutIfNeeded()
    }
    self.searchView.translatesAutoresizingMaskIntoConstraints = false
    self.isSearchViewOpen = false
    
    
  }
  
  
  @IBAction func btnProjectFilter_Action(_ sender: Any) {
   
    let tag = (sender as! UIButton).tag
    if tag == 0 {
      //drop down list button touch
      if isFilterViewHidden {
        isFilterViewHidden = false
        self.filterOptionsView.isHidden = false
        fadeIn(view: self.filterOptionsView)
      } else {
        isFilterViewHidden = true
        fadeOut(view: self.filterOptionsView)
      }
      return
    }
    isFilterViewHidden = true
    fadeOut(view: self.filterOptionsView)
  }
  
  func fadeIn(view: MBRHEBorderView, _ duration: TimeInterval = 0.7, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
    UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
      view.alpha = 1.0
    }, completion: completion)  }
  
  func fadeOut(view: MBRHEBorderView, _ duration: TimeInterval = 0.7, delay: TimeInterval = 0.0, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in}) {
    UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
      view.alpha = 0.0
    }, completion: {
      (finished: Bool) -> Void in
      view.isHidden = true
    })
  }
  
  func showActivityIndicator(activityTag :Int,YPostion : Int? = 400) {
    
    let frameToShow = CGRect(x: (self.view.frame.size.width / 2) , y: (self.view.frame.size.height / 2), width: 50,  height:50)
    var activityView : NVActivityIndicatorView!
    activityView = self.view.createActivityIndicator(frameToShow, activityTag:activityTag)
    
    print("activityViewactivityView  ", activityView)
    self.view.addSubview(activityView)
   
  }
  
  
  //MARK: --- PeojectListingViewDelegate ---
  func selectedPayment_Action(index: Int) {
    paymentObj = SharedResources.sharedInstance.contractsPayload.payload.dashboard[index]
    goBOQVCWith(Obj: paymentObj)
  }
  
    func createReportAction(object: Dashboard) {
       //navigateToSimplifiedReportModule(requestDetails: object)
    }
  
  
  func addToTrip_Action(paymentOBJ: Dashboard) {
   
    paymentObj = paymentOBJ
    addToTrip_ActionFromDelegateAndDashboard(paymentOBJ: paymentOBJ)
  }
    
    func addToTrip_ActionFromDelegateAndDashboard(paymentOBJ: Dashboard)  {
        
        if paymentOBJ.plot.latitude != "" && paymentOBJ.plot.longitude != "" {
        //saved for trip
        if Common.isProjectAddedIntoTripArrayWith(paymentId: paymentOBJ.applicationNo) {
          let index : Int =  SharedResources.sharedInstance.selectedTripContracts.index{$0.applicationNo == paymentOBJ.applicationNo}!
          SharedResources.sharedInstance.selectedTripContracts.remove(at: index)
        } else {
          SharedResources.sharedInstance.selectedTripContracts.append(paymentOBJ)
        }
            
            if projectsListView?.isHidden == false {
                reloadCollectionViewWithData()
            }else
            {
                self.projectsMapView!.infoWindow.setDataForMap(dashboardObj: paymentOBJ)
            }
        }
        else{
            searchPlotView = SearchPlotView.getSearchPlotView()
            searchPlotView?.obj = paymentOBJ
            searchPlotView?.delegateObj = self
            searchPlotView!.frame = CGRect(x: 0, y: 0, width: Common.screenWidth, height: Common.screenHeight)
            searchPlotView?.setPlotDetils()
            searchPlotView?.searchPlotOption = .Add
            self.view.addSubview(searchPlotView!)
        }
    }
  
    
    func addPlotButton_Action(paymentOBJ: Dashboard,delegateObj:PeojectListingViewDelegate)
    {
        paymentObj = paymentOBJ
        
        if paymentOBJ.plot.latitude != "" && paymentOBJ.plot.longitude != "" {
            //saved for trip
            if Common.isProjectAddedIntoTripArrayWith(paymentId: paymentOBJ.applicationNo) {
                let index : Int =  SharedResources.sharedInstance.selectedTripContracts.index{$0.applicationNo == paymentOBJ.applicationNo}!
                SharedResources.sharedInstance.selectedTripContracts.remove(at: index)
            } else {
                SharedResources.sharedInstance.selectedTripContracts.append(paymentOBJ)
            }
            SharedResources.sharedInstance.isRefreshNeeded = true
            callApiToRefreshContractList()
            
        }
        else
        {
            searchPlotView = SearchPlotView.getSearchPlotView()
            searchPlotView?.obj = paymentOBJ
            searchPlotView?.delegateObj = self
            searchPlotView!.frame = CGRect(x: 0, y: 0, width: Common.screenWidth, height: Common.screenHeight)
            searchPlotView?.setPlotDetils()
            searchPlotView?.searchPlotOption = .Add
            self.view.addSubview(searchPlotView!)
        }
    }
    
    func editPlotButton_Action(paymentOBJ: Dashboard, delegateObj: PeojectListingViewDelegate) {
        
        searchPlotView = SearchPlotView.getSearchPlotView()
        searchPlotView?.obj = paymentOBJ
        searchPlotView?.delegateObj = self
        searchPlotView!.frame = CGRect(x: 0, y: 0, width: Common.screenWidth, height: Common.screenHeight)
        searchPlotView?.setPlotDetils()
        searchPlotView?.searchPlotOption = .Edit
        self.view.addSubview(searchPlotView!)
        
    }
    
  
  func gotToNotes_Action(paymentOBJ: Dashboard){
    paymentObj = paymentOBJ
    goToNotesVCWith(Obj: paymentObj)
  }
  
  func gotToAttachment_Action(paymentOBJ: Dashboard) {
    paymentObj = paymentOBJ
    goToPaymentAttachmentVCWith(Obj: paymentObj)
  }
  
  func navigation_Action(paymentOBJ: Dashboard) {
    paymentObj = paymentOBJ
    if paymentOBJ.plot.latitude != "" && paymentOBJ.plot.longitude != "" {
        presentMapView(obj: paymentObj)
    } else {
        Common.showToaster(message: "the_coordinate_is_not_set_for_this_plot".ls)

    }
    
  }
  
  func more_Action(paymentOBJ: Dashboard) {
    paymentObj = paymentOBJ
    var isLoading = false
    for loaderView in self.view.subviews where loaderView.tag == 111 || loaderView.tag == 112 || loaderView.tag == 113 {
        isLoading = true
       
    }
    if !isLoading {
        navigateToSimplifiedReportModule(requestDetails: paymentOBJ)
        
    }
    
  }
  
    func boq_Action(paymentOBJ: Dashboard) {
        paymentObj = paymentOBJ
        goBOQVCWith(Obj: paymentObj)
    }
    
    func addToTripActionFromDelegate(obj: Dashboard) {
        addToTrip_ActionFromDelegateAndDashboard(paymentOBJ: obj)
    }
    
  @objc func presentMapView(obj:Dashboard)
  {
   
    if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MapView") as? PlotMapView
    {
      vc.mapViewDelegate = self
      vc.paymentObj = obj
      vc.modalPresentationStyle = .overCurrentContext
      Common.appDelegate.window?.rootViewController?.present(vc, animated: false, completion: nil)
    }
    
  }
  
  func btnNotes_Action(obj: Dashboard) {
    goToNotesVCWith(Obj: obj)
  }
  
  func btnAttachment_Action(obj: Dashboard)
  {
    goToPaymentAttachmentVCWith(Obj: obj)
  }
  
  func btnMore_Action(obj: Dashboard) {
//    presentPaymentDetailView(obj: obj)
    
    navigateToSimplifiedReportModule(requestDetails: obj)
  }
  
  @objc func presentPaymentDetailView(obj:Dashboard) {
    let service = PaymentDetailService()
    let viewModel = PaymentDetailViewModel(service)
    let vc = PaymentDetailView.create(with: viewModel) as! PaymentDetailView
    vc.paymentObj = obj
    vc.modalPresentationStyle = .overCurrentContext
    Common.appDelegate.window?.rootViewController?.present(vc, animated: false, completion: nil)
  }
  
  //MARK: ---- Views/screen naviagtion function --
  
  func goToPaymentAttachmentVCWith(Obj:Dashboard) {
    let service = PaymentAttachmentsService()
    let viewModel = PaymentsAttachmentViewModel(service)
    let viewController = PaymentAttachmentsViewController.create(with: viewModel) as! PaymentAttachmentsViewController
    
    viewController.obj = Obj
   // Common.showActivityIndicator()
    self.navigationController?.pushViewController(viewController,animated: false)
  }
  
  func goToNotesVCWith(Obj:Dashboard) {
    let service = PaymentNotesService()
    let viewModel = PaymentNotesViewModel(service)
    let viewController = NotesViewController.create(with: viewModel) as! NotesViewController
    viewController.obj = Obj
    self.navigationController?.pushViewController(viewController,animated: false)
  }
  
  func goBOQVCWith(Obj:Dashboard) {
    let service = BOQContractService()
    let viewModel = BOQViewModel(service)
    let viewController = ContractBreakDownInfoViewController.create(with: viewModel) as! ContractBreakDownInfoViewController
    viewController.obj = Obj
    self.navigationController?.pushViewController(viewController,animated: false)
  }
  
    //MARK:- Navigate to Simplified Report Module
    func navigateToSimplifiedReportModule(requestDetails:Dashboard) {
        
        if requestDetails.plot.latitude.isEmpty && requestDetails.plot.longitude.isEmpty {
            
            searchPlotView = SearchPlotView.getSearchPlotView()
            searchPlotView?.obj = requestDetails
            searchPlotView?.delegateObj = self
            searchPlotView!.frame = CGRect(x: 0, y: 0, width: Common.screenWidth, height: Common.screenHeight)
            searchPlotView?.setPlotDetils()
            searchPlotView?.searchPlotOption = .Add
            self.view.addSubview(searchPlotView!)
            
            return
            
        }

        if let reportVC = self.storyboard?.instantiateViewController(withIdentifier: "RequestDetailController") as? RequestDetailController {
            reportVC.requestObject = requestDetails
            reportVC.isFromStartMyTrip = false
            let rootVC = UINavigationController(rootViewController: reportVC)
            rootVC.navigationBar.isHidden = true
            addChild(rootVC)
            rootVC.view.frame = containerView.bounds
            containerView.addSubview(rootVC.view)
            rootVC.didMove(toParent: self)
        }       
    }
    
    func navigateToSettings(requestDetails:Dashboard)
    {
        let storyboardMain = UIStoryboard(name: "Main", bundle: nil)
               if let dashBoardVc = storyboardMain.instantiateViewController(withIdentifier: "DashboardSettingsViewController") as? DashboardSettingsViewController {
                           let rootVC = UINavigationController(rootViewController: dashBoardVc)
                           rootVC.navigationBar.isHidden = true
                           addChild(rootVC)
                           rootVC.view.frame = containerView.bounds
                           containerView.addSubview(rootVC.view)
                           rootVC.didMove(toParent: self)
                       }
    }
    
  // Based on github json enable/disable features
  func fetchAppFeatureStatus() {
  
    if(SharedResources.sharedInstance.isRefreshNeeded == true)
    {
        print ("Entered fetchAppFeatureStatus")
        SharedResources.sharedInstance.isRefreshNeeded = false
    let services = FetchFeatureService()
    Common.showActivityIndicator()
    services.fetchFeatures(completion: {(baseResposne : FetchFeaturesResponse?) in
      Common.hideActivityIndicator()
      guard let response = baseResposne else {
        return
      }
      
      if !response.isEqual(nil){
        SharedResources.sharedInstance.appFeatureStatus = response
        self.enableDisableFeatures() // Enable/Disable Features
      }
      
      self.initiateView()
    })
    }
    else
    {
        self .reloadCollectionViewWithData()
    }
    
  }
  
  @objc func initiateView(){

    if SharedResources.sharedInstance.searchActive == false {
      bindObservers()
      dashboardAPI()
    
    }else{
      
      self.projectSerachView?.txtFieldApplicationNumber.text = SharedResources.sharedInstance.applicationNo
      self.projectSerachView?.txtFieldLandNumber.text = SharedResources.sharedInstance.plotNo
      SharedResources.sharedInstance.contractsPayload.payload.dashboard.removeAll()
      filterApiCall()
    }

     addMRHELeftMenuView()
  }
    
  
    func noDataAvailable(noInternet: Bool? = false ,noDataAvailable:Bool? = false,serverError:Bool? = false){
    
   Common.hideActivityIndicator()
    noData = NoDataView.getEmptyDataView()
    if isSearchViewOpen {
        btnProjectFind_Action(UIButton())
    }
    noData.frame = CGRect(x: 0, y:0, width: (self.projectsListView?.frame.size.width)!,  height:(self.projectsListView?.frame.size.height)!)
    containerView.backgroundColor = UIColor.white
    noData.tag = 3000
    noData.setLayout(hideBack:true,Yposition:60)
    
    self.projectsListView?.addSubview(noData)
    
    if (noInternet ?? false) == false {
        noData.notAvailableText.text = "Unable to retrieve requests, Please make sure that requests has been added"
    }
    
    mainFilterView.isHidden = true
    selectAllbtn.isHidden = true
    unSelectAllBtn.isHidden = true
    innerView.isHidden = true
    searchView.isHidden = true
    
    if noInternet!{
      noData.setLayout(noNetwork:true,hideBack:false)
      noData.backBtn.addTarget(self, action: #selector(self.removeNotAvailable), for: .touchUpInside)
      return
    }
        else if noDataAvailable!{
        noData.setLayout(noResponseDataAvailable:true,hideBack:false)
        noData.backBtn.addTarget(self, action: #selector(self.removeNoResponse), for: .touchUpInside)
        return
        }
        
    else if serverError!{
        noData.setLayout(serverError:true,hideBack:false)
        noData.backBtn.addTarget(self, action: #selector(self.removeNoResponse), for: .touchUpInside)
        return
        }
  }
    
    @objc func removeNoResponse(){
        if(Common.isConnectedToNetwork() == true)
        {
            for sub in self.projectsListView?.subviews ?? [UIView()] {
                if sub.tag == 3000
                {
                    sub.removeFromSuperview()
                }
            }
            
            projectSerachView?.txtFieldApplicationNumber.text = ""
            projectSerachView?.txtFieldLandNumber.text = ""
            
            self.enableViewsVisibility()

            SharedResources.sharedInstance.isRefreshNeeded = true
            SharedResources.sharedInstance.searchActive = false
            self.fetchAppFeatureStatus()
            whenViewIsAppear()
            
        }
        else
        {
            Common.showToaster(message: "no_Internet".ls)
        }
        
    }
    

  @objc func removeNotAvailable(){
    if(Common.isConnectedToNetwork() == true)
    {
        for sub in self.projectsListView?.subviews ?? [UIView()] {
            if sub.tag == 3000
            {
                sub.removeFromSuperview()
            }
        }
 
        self.enableViewsVisibility()
        SharedResources.sharedInstance.isRefreshNeeded = true
        self.fetchAppFeatureStatus()
       whenViewIsAppear() // Recalling ViewWillAppear()
      
    }
    else
    {
        Common.showToaster(message: "no_Internet".ls)
    }
  }
  
}



