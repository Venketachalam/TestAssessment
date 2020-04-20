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

struct SelectedLocation {
    var location: LocationDetails
    var index: Int
}

protocol DashboardProtocol {
    func updateService()
}

enum SearchPlotOptions {
    case Add
    case Edit
}

class SearchPlotView: UIView, ControllerType, NVActivityIndicatorViewable{
    
    // MARK: - Properties
    
    var delegateObj:PeojectListingViewDelegate?
    var noData : NoDataView!
    
    @IBOutlet weak var searchResultLbl: UILabel!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var txtFieldComment: UITextField!
    @IBOutlet weak var tblView: UITableView!
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var addPlotView: UIView!
    @IBOutlet weak var addPlotBtn: MBRHERoundButtonView!
    
    @IBOutlet weak var searchPlotView: MBRHEBorderView!
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var layer1: UIView!
    @IBOutlet weak var searchByAreaBtn: MBRHERoundButtonView!
    
    @IBOutlet weak var areaNameSearchButton: UIButton!
    
    @IBOutlet weak var addPlotViewButton: UIButton!
    
    @IBOutlet weak var searchLocationView: UIView!
    
    @IBOutlet weak var addPlotNumberView: UIView!
    
    @IBOutlet weak var locationViewConstraints: NSLayoutConstraint!
    
    @IBOutlet weak var addPlotConstraints: NSLayoutConstraint!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var plotNumberTextField: UITextField!
    
    @IBOutlet weak var addPlotStackView: UIStackView!
    
    var selectedPlace:SelectedLocation!
    @IBOutlet weak var cancelBtn: MBRHERoundButtonView!
    @IBOutlet weak var addButton: MBRHERoundButtonView!
    
    @IBOutlet weak var layer2: UIView!
    var refresher:UIRefreshControl!
    var obj:Dashboard = Dashboard()
    var remarksArray = Variable<[String]>([])
    
    let places: BehaviorRelay<[LocationDetails]> = BehaviorRelay(value: [])
    
    var searchPlotOption:SearchPlotOptions = .Add
    
    var searchPlotLocationPayload: PlotLocationDetails!
   
    
    typealias ViewModelType = PaymentNotesViewModel
    private var viewModel: ViewModelType!
    private let disposeBag = DisposeBag()
    
    private var VM: SearchPlotViewModel!
    
    class func getSearchPlotView() -> SearchPlotView
    {
        return Bundle.main.loadNibNamed("SearchPlotView", owner: self, options: nil)![0] as! SearchPlotView
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Do any additional setup after loading the view.
        //  self.tblView.register(UINib(nibName: "NotesCustomCell", bundle: nil), forCellReuseIdentifier: "NotesCustomCell")
        // configure(with: viewModel)
        VM = SearchPlotViewModel(SearchPlotService())
        configure(viewModel: VM)
        if(Common.isConnectedToNetwork() == false){
            notAvailable(isNetwork: true)
        }
        
        tblView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        searchBar.setImage(#imageLiteral(resourceName: "Search_icon-1"), for: .search, state: .normal)
        addPlotButtonAction(addPlotViewButton)
        self.tblView.tableFooterView = UIView()
        areaNameSearchButton.setTitle("search_area_lbl".ls, for: .normal)
        addPlotViewButton.setTitle("add_plot_no_lbl".ls, for: .normal)
        cancelBtn.setTitle("cancel_btn".ls, for: .normal)
        addButton.setTitle("add_btn".ls, for: .normal)
        searchResultLbl.text = "search_result_Lbl".ls
        
        plotNumberTextField.placeholder = "enter_plotnumber_placeholder".ls
        
        if Common.currentLanguageArabic() {
            
            self.addPlotViewButton.transform = Common.arabicTransform
            self.addPlotViewButton.toArabicTransform()
            self.addButton.transform = Common.arabicTransform
            self.addButton.toArabicTransform()
            self.cancelBtn.transform = Common.arabicTransform
            self.cancelBtn.toArabicTransform()
            
            self.areaNameSearchButton.transform = Common.arabicTransform
            self.areaNameSearchButton.toArabicTransform()
            
            self.plotNumberTextField.transform = Common.arabicTransform
            self.plotNumberTextField.toArabicTransform()
            
            self.plotNumberTextField.textAlignment = .right
            
            self.searchResultLbl.transform = Common.arabicTransform
            self.searchResultLbl.toArabicTransform()
            
            self.searchResultLbl.textAlignment = .right
            
        }
        
        plotNumberTextField.delegate = self
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        plotNumberTextField.applyStyle()
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
        self.showActivityIndicator()
    }
    
    func configure(with viewModel: PaymentNotesViewModel) {
        
        if Common.isConnectedToNetwork() == true{
            
            
            fetch()
            
            txtFieldComment.rx.text.asObservable()
                .ignoreNil()
                .subscribe(viewModel.input.remark)
                .disposed(by: disposeBag)
            
            
            btnAdd.rx.tap.asObservable()
                .subscribe(viewModel.input.addCommentDidTap)
                .disposed(by: disposeBag)
            
            btnAdd.rx.tap.asObservable()
                .subscribe(onNext:{[weak self] _ in
                    //call add comment service
                    if !((self?.txtFieldComment.text?.isEmpty)!){
                        self?.remarksArray.value.append((self?.txtFieldComment.text!)!)
                        self?.txtFieldComment.text = ""
                        if (self?.remarksArray.value.count)! > 0{
                            self?.scrollToBottom()
                        }
                        
                        self?.endEditing(true)
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
                    // self.stopAnimating()
                    
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
                    //self.stopAnimating()
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
                .subscribe({[weak self] _ in
                    // self?.navigationController?.popViewController(animated: false)
                })
                .disposed(by: disposeBag)
            
        }
        else
        {
            Common.showToaster(message: "no_Internet".ls)
        }
        
    }
    
    
    func setPlotDetils() {
        if obj.plot.landNo.count > 0 {
            plotNumberTextField.text = obj.plot.landNo
            plotNumberTextField.isUserInteractionEnabled = true
        } else {
            plotNumberTextField.text = ""
            plotNumberTextField.isUserInteractionEnabled = true
        }
    }
    
    func configure(viewModel: SearchPlotViewModel)
    {
        if Common.isConnectedToNetwork() == true
        {
            searchBar.rx.searchButtonClicked.subscribe { _ in
                let language = self.searchBar.textInputMode?.primaryLanguage
                
                Common.showActivityIndicator()
                
                viewModel.input.searchArea.onNext(self.searchBar.text ?? "")
                viewModel.input.searchLanguage.onNext(language ?? "")
                
                self.endEditing(true)
            }.disposed(by: disposeBag)
            
            viewModel.output.requestSummaryResultObservable.subscribe { [weak self] (response) in
                Common.hideActivityIndicator()
                
                if let location = response.element?.payload.makaniDetailPayload,location.count > 0 {
                    self?.places.accept(location)
                    
                } else {
                    var emptyResponse=self?.places.value
                    emptyResponse?.removeAll()
                    self?.places.accept(emptyResponse ?? [])
                    self?.tblView.reloadData()
                    Common.showToaster(message: "no_location_found".ls)
                }
                
            }.disposed(by: disposeBag)
            
            viewModel.output.errorsObservable.subscribe { [weak self] (error) in
                
                Common.hideActivityIndicator()
                
                let errorMessage = (error.element! as NSError).domain
                if !errorMessage.isEmpty{
                    Common.showToaster(message: errorMessage)
                    
                }else {
                    Common.showToaster(message: "bad_Gateway".ls)
                }
                Common.showToaster(message: errorMessage)
            }.disposed(by: disposeBag)
            
            
            places.bind(to: tblView.rx.items(cellIdentifier: "cell")) { row, model, cell in
                if let sValue = self.selectedPlace {
                    if sValue.index == row {
                        cell.accessoryType = .checkmark
                        // cell.selectionStyle = .none
                    } else {
                        cell.accessoryType = .none
                        //  cell.selectionStyle = .none
                    }
                }
                self.searchResultLbl.isHidden = true
                cell.textLabel?.text = model.location
                cell.textLabel?.font = UIFont.appRegularFont(size: 11.0)
                cell.textLabel?.textColor = .darkGray
            }.disposed(by: disposeBag)
            
            
            tblView.rx.itemSelected
                .subscribe(onNext: { [weak self] indexPath in
                    if  let sValue = self?.places.value[indexPath.row] {
                        self?.selectedPlace = SelectedLocation(location: sValue, index: indexPath.row)
                    }
                    
                    let cell = self?.tblView.cellForRow(at: indexPath)
                    cell?.accessoryType = .checkmark
                    cell?.contentView.backgroundColor = UIColor .clear
                    // cell?.selectionStyle = .none
                }).disposed(by: disposeBag)
            
            tblView.rx.itemDeselected
                .subscribe(onNext: { [weak self] indexPath in
                    self?.tblView.deselectRow(at: indexPath, animated: false)
                    let cell = self?.tblView.cellForRow(at: indexPath)
                    cell?.accessoryType = .none
                }).disposed(by: disposeBag)
        }
        else{
            Common.showToaster(message: "no_Internet".ls)
            
        }
    }
    
    static func create(with viewModel: PaymentNotesViewModel) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "NotesVC") as! NotesViewController
        //controller.viewModel = viewModel
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
        // startAnimating(size, message: "",messageFont: nil, type: NVActivityIndicatorType.ballBeat, color: UIColor(red: 0/255, green: 97/255, blue: 158/255, alpha: 1.0),padding:10)
        
    }
    
    //MARK: -- noData view --
    //  var noData : NoDataView!
    func notAvailable(isNetwork:Bool){
        
        noData = NoDataView.getEmptyDataView()
        noData.frame = CGRect(x: 0, y: 100, width: Common.screenWidth,  height:Common.screenHeight - 100)
        noData.setLayout(noNetwork:isNetwork,Yposition :5)
        noData.backBtn.addTarget(self, action: #selector(self.remvoeNotAvailable), for: .touchUpInside)
        self.addSubview(noData)
        
    }
    
    @objc func remvoeNotAvailable(){
        
        if(Common.isConnectedToNetwork() == true){
            noData.removeFromSuperview()
        }
    }
    
    //MARK: - UIButton Action

    @IBAction func btnTogglePressed(_ sender: Any) {
        if (sender as AnyObject).tag == 1 {
            self.addPlotView.isHidden = false
            self.layer1.isHidden = false
            
            self.searchPlotView.isHidden = true
            self.layer2.isHidden = true
        }else {
            
            self.addPlotView.isHidden = true
            self.layer1.isHidden = true
            
            self.searchPlotView.isHidden = false
            self.layer2.isHidden = false
        }
    }
    @IBAction func cancelButtonPressed(_ sender: Any) {
        Common.hideActivityIndicator()
        self.removeFromSuperview()
    }
    
    @IBAction func searchLocationButtonAction(_ sender: UIButton) {
        self.endEditing(true)
        if sender.isSelected {return}
        higlightViewSetUp(button: sender)
        normalViewSetup(button: addPlotViewButton)
        searchLocationView.isHidden = false
        addPlotNumberView.isHidden = true
        locationViewConstraints.isActive = true
        addPlotConstraints.isActive = false
    }
    
    @IBAction func addPlotButtonAction(_ sender: UIButton) {
        self.endEditing(true)
        if sender.isSelected {return}
        higlightViewSetUp(button: sender)
        normalViewSetup(button: areaNameSearchButton)
        searchLocationView.isHidden = true
        addPlotNumberView.isHidden = false
        locationViewConstraints.isActive = false
        addPlotConstraints.isActive = true
    }
    
    @IBAction func addLocationAction(_ sender: UIButton)
    {
        
        if Common.isConnectedToNetwork() == true
        {
            if areaNameSearchButton.isSelected {
                if let place = selectedPlace {
                    var requestParam = AddLocationRequestModel()
                    requestParam.locationId = place.location.locationId
                    requestParam.featureClassId = place.location.featureclassId
                    requestParam.applicationNo = "\(obj.applicationNo)"
                    requestParam.applicantId = "\(obj.applicantId)"
                    requestParam.serviceTypeId = obj.serviceTypeId
                    VM.addLocationRequets = requestParam
                    Common.showActivityIndicator()
                    VM.input.locationId.asObserver()
                        .onNext(place.location.locationId)
                    VM.output.plotLocationResultObservable.subscribe { [weak self] (response) in
                        Common.hideActivityIndicator()
                        
                        if ((response.element?.payload.plot.count)! > 0)
                        {
                            Common.showToaster(message: "successfully_added_location".ls)
                            DispatchQueue.main.async {
                                self?.removeFromSuperview()
                            }
                            self!.delegateObj?.callApiToRefreshContractList()
                        }
                        else
                        {
                            Common.showToaster(message: response.element!.message)
                        }
                        
                    }.disposed(by: disposeBag)
                }
                
            } else {
                //if obj.plot.landNo.count > 0 { return }
                
                if searchPlotOption == .Add {
                    
                    if !(plotNumberTextField.text?.isEmptyString() ?? false) {
                        VM.applicationNo = "\(obj.applicationNo)"
                        VM.serviceTypeID=obj.serviceTypeId
                        VM .applicantID = "\(obj.applicantId)"
                        VM.plotNewNo = "\("")"
                        Common.showActivityIndicator()
                        VM.input.plotNo.asObserver().onNext(plotNumberTextField.text ?? "")
                        VM.output.plotLocationResultObservable.subscribe { [weak self] (response) in
                            Common.hideActivityIndicator()
                            if ((response.element?.payload.plot.count)! > 0)
                            {
                                
                                Common.showToaster(message: "successfully_added_Plot_number".ls)
                                DispatchQueue.main.async {
                                    self?.removeFromSuperview()
                                    
                                }
                                SharedResources.sharedInstance.isRefreshNeeded = true
                                self!.delegateObj?.callApiToRefreshContractList()
                            }
                            else
                            {
                                Common.showToaster(message: response.element!.message)
                            }
                        }.disposed(by: disposeBag)
                    }
                }
                else if searchPlotOption == .Edit
                {
                    if !(plotNumberTextField.text?.isEmptyString() ?? false) {
                        VM.applicationNo = "\(obj.applicationNo)"
                        VM.serviceTypeID=obj.serviceTypeId
                        VM .applicantID = "\(obj.applicantId)"
                        VM.plotNo = "\(obj.plot.landNo)"
                        
                        VM.input.plotNewNo.asObserver().onNext(plotNumberTextField.text ?? "")
                        VM.output.plotLocationResultObservable.subscribe { [weak self] (response) in
                            Common.hideActivityIndicator()
                            if ((response.element?.payload.plot.count)! > 0)
                            {
 
                                self?.searchPlotLocationPayload = response.element?.payload.plot.first

                                let plotNoString:String = (self?.searchPlotLocationPayload.plotNo)!
                                let latitudeString:String = (self?.searchPlotLocationPayload.latitude)!
                                let longitudeString:String = (self?.searchPlotLocationPayload.longitude)!
                                
                                self?.obj.plot.landNo = plotNoString
                                self?.obj.plot.latitude = latitudeString
                                self?.obj.plot.longitude = longitudeString

                                Common.showToaster(message: "successfully_added_Plot_number".ls)
                                DispatchQueue.main.async {
                                    self?.removeFromSuperview()
                                    
                                }
                                 SharedResources.sharedInstance.isRefreshNeeded = true
                                self!.delegateObj?.callApiToRefreshApplicationList(dashboarObj: self!.obj)
                                
                            }
                            else
                            {
                                Common.showToaster(message: response.element!.message)
                                
                                
                            }
                            
                            
                        }.disposed(by: disposeBag)

                    }
                }
            }
        }
        else{
            Common.showToaster(message: "no_Internet".ls)
            
        }
    }
    
    func higlightViewSetUp(button: UIButton) {
        button.isSelected = true
        if let stackView = button.superview as? UIStackView {
            stackView.arrangedSubviews.last?.isHidden = false
        }
    }
    
    func normalViewSetup(button:UIButton) {
        button.isSelected = false
        if let stackView = button.superview as? UIStackView {
            stackView.arrangedSubviews.last?.isHidden = true
        }
    }
    
}


extension SearchPlotView: UITextFieldDelegate{
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
}
