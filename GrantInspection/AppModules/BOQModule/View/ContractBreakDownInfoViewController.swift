//
//  ContractBreakDownInfoViewController.swift
//  Progress
//
//  Created by Muhammad Akhtar on 6/21/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ImagePicker
import Lightbox
import NotificationBannerSwift
import NVActivityIndicatorView
import Foundation
import CoreLocation

class ContractBreakDownInfoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ControllerType ,BreakDownProtocol , ImagePickerDelegate , NVActivityIndicatorViewable, CLLocationManagerDelegate {

  
  @IBOutlet weak var progressView: UIView!
  @IBOutlet weak var expandView: UIView!
  @IBOutlet weak var headerView: UIView!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var boqContainerView: UIView!
  @IBOutlet weak var searchView: UIView!
  
  @IBOutlet weak var applicationNolbl: UILabel!
  @IBOutlet weak var contractIDlbl: UILabel!
  @IBOutlet weak var paymentIDlbl: UILabel!
  @IBOutlet weak var statusView: UIView!
  @IBOutlet weak var subHeaderView: UIView!
  
    var breakDownDataArray = [MRHEOpenNewFileBillOfQuantityModel]()
    var breakDownSearchDataArray = [MRHEOpenNewFileBillOfQuantityModel]()
    var obj:Dashboard = Dashboard()
    var projectID : String = ""
    var paymentID : String = ""
    var noData : NoDataView!
    var indexOfImage = 0
    var expand : Bool = false

    var locationManager: LocationManager?
    var OLImageUploaderVC : OLImageUploaderViewController = OLImageUploaderViewController()
  
  @IBOutlet weak var cameraBtn: UIButton!
  @IBOutlet weak var attachmentBtn: UIButton!
  @IBOutlet weak var searchBar: UITextField!
  @IBOutlet weak var btnBack: UIButton!
  @IBOutlet weak var btnNext: UIButton!
  @IBOutlet weak var backView: MBRHEBorderView!
  @IBOutlet weak var nextView: MBRHEBorderView!
  @IBOutlet weak var expandBtn: UIButton!
  
  typealias ViewModelType = BOQViewModel
    // MARK: - Properties
    private var viewModel: ViewModelType!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
      
        addMRHEHeaderView()
        addMRHELeftMenuView()
        setLayout()
        breakDownDataArray = MRHEOpenNewFileBillOfQuantityModel.addDataIntoParentBOQObject()
        configure(with: viewModel)
        searchBar.addTarget(self, action: #selector(searchRecordsAsPerText(_ :)), for: .editingChanged)
      
      
    }
  
    override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
     
    }
  
    override func viewDidDisappear(_ animated: Bool) {
      super.viewDidDisappear(animated)
      locationManager?.stopUpdatingLocation()
    }

  
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(true)

//      self.paymentID = obj.paymentId.description
//      self.projectID = obj.contractId.description
//      self.applicationNolbl.text = "Application No :  #" + obj.applicationNo
//      self.paymentIDlbl.text = "Payment No : #" + obj.paymentId.description
//      self.contractIDlbl.text = "Contract ID : " + obj.contractId.description
//
       self.statusView.backgroundColor = Common.hexStringToUIColor(hex: obj.colorTag)
      
      viewModel.input.paymentId.asObserver()
        .onNext(paymentID)
      viewModel.input.projectId.asObserver()
        .onNext(projectID)
      
    }
    
    func configure(with viewModel: BOQViewModel) {
  
        self.showIndicator()
      
        viewModel.output.paymentBOQResultObservable
            .subscribe(onNext: { [unowned self] (payload) in
          
             
              if payload.payload.count > 0 {
                
                self.breakDownSearchDataArray = self.breakDownDataArray
                
                self.breakDownSearchDataArray.forEach {
                  $0.innerBreakDownObj.forEach{
                    
                    let trace = $0.workId! as NSNumber
                    let filter = payload.payload.filter({$0.workId == trace})
                    if filter.isEmpty { return } // if no record found return the loop
                    
                    let output : BOQModel = filter[0]
                    $0.workId = output.workId as! Int
                    $0.comment  = output.comments
                    $0.workDesc =  output.workDesc
                    $0.paymentDetailId =  output.paymentDetailId
                    $0.contarctPercentage = output.contractPercentage
                    $0.actualDone = output.actualDone
                    $0.paymentPercentage = output.paymentPercentage
                    $0.engineerPercentage = output.engineerPercentage
                    
                  }
                }
                self.tableView.reloadData()
                self.showControls()
              }else {
                self.noDataAvailable()
              }
                self.stopAnimating()
            })
            .disposed(by: disposeBag)
      
      
      viewModel.output.addPercentageResultObservable
        .subscribe(onNext: { [unowned self] (payload) in
          //self.stopAnimating()
            print(payload)
          
          
        })
        .disposed(by: disposeBag)
      
      
        
        viewModel.output.errorsObservable
            .subscribe(onNext: { [unowned self] (error) in
                //self.stopAnimating()
                //self.presentError(error)
                let errorMessage = (error as NSError).domain
                Common.showToaster(message: errorMessage)

                //self.presentError(errorMessage)
            })
            .disposed(by: disposeBag)
      
        btnBack.rx.tap.asObservable()
            .subscribe(onNext:{[weak self] _ in
                self?.navigationController?.popViewController(animated: false)
            })
            .disposed(by: disposeBag)
        
        btnNext.rx.tap.asObservable()
            .subscribe(onNext:{[weak self] _ in
                self?.view.endEditing(true)
                self?.goToSummaryVCWith(Obj: (self?.obj)!)
            })
            .disposed(by: disposeBag)
        
        
    }
    
    static func create(with viewModel: BOQViewModel) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "BillOffQuantityVC") as! ContractBreakDownInfoViewController
        controller.viewModel = viewModel
        return controller
    }
    
    func goToSummaryVCWith(Obj:Dashboard) {
        let service = PaymentSummaryService()
        let viewModel = PaymentSummaryViewModel(service)
        let viewController = PaymentSummaryViewController.create(with: viewModel) as! PaymentSummaryViewController
        viewController.obj = Obj
        self.navigationController?.pushViewController(viewController,animated: false)
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
    
    func setLayout(){
        
        self.tableView.register(UINib(nibName: "HeaderCell",bundle: nil), forCellReuseIdentifier: "headerCell")
        self.tableView.register(UINib(nibName: "BreakDownInnerCell",bundle: nil), forCellReuseIdentifier: "breakDownInnerCell")

    }

    
    // MARK: - UITableViewDataSource and Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return breakDownSearchDataArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if breakDownSearchDataArray[indexPath.row].opened == true {
            return 61
        } else {
            return 56
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        if breakDownSearchDataArray[section].opened == true {
            return breakDownSearchDataArray[section].innerBreakDownObj.count + 1
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
      let dataIndex = indexPath.row - 1
      
      if indexPath.row  == 0 {
        
            let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath) as! HeaderCell
            cell.titleLbl.text = breakDownSearchDataArray[indexPath.section].name
            if breakDownSearchDataArray[indexPath.section].opened == true {
                cell.arrowImageView.image = UIImage.init(named: "gray_arrow_up")
            }else{
                cell.arrowImageView.image = UIImage.init(named: "gray_arrow_down")
            }
            return cell
        } else {
        
          let cell = tableView.dequeueReusableCell(withIdentifier: "breakDownInnerCell", for: indexPath) as! BreakDownInnerCell
          cell.titleLbl.text = breakDownSearchDataArray[indexPath.section].innerBreakDownObj[dataIndex].workDesc
          cell.btnAddComment_Tapped.addTarget(self, action: #selector(goToNotesVCWith(_:)), for: .touchUpInside)
          cell.btnAddComment_Tapped.tag = breakDownSearchDataArray[indexPath.section].innerBreakDownObj[dataIndex].workId
          cell.idLbl.text =  breakDownSearchDataArray[indexPath.section].innerBreakDownObj[dataIndex].workId.description
        
          cell.workID = breakDownSearchDataArray[indexPath.section].innerBreakDownObj[dataIndex].workId.description
         // cell.paymentID = obj.paymentId.description
   
          cell.addDelegate = self
          cell.contractPercentageTextField.text = breakDownSearchDataArray[indexPath.section].innerBreakDownObj[dataIndex].contarctPercentage.description
          cell.actualDoneTextField.text = breakDownSearchDataArray[indexPath.section].innerBreakDownObj[dataIndex].actualDone.description
          cell.paymentTextField.text = breakDownSearchDataArray[indexPath.section].innerBreakDownObj[dataIndex].paymentPercentage.description
          cell.engineerTextField.text = breakDownSearchDataArray[indexPath.section].innerBreakDownObj[dataIndex].engineerPercentage.description
        
        if breakDownSearchDataArray[indexPath.section].innerBreakDownObj[dataIndex].engineerPercentage == 0{
          if breakDownSearchDataArray[indexPath.section].innerBreakDownObj[dataIndex].paymentPercentage > breakDownSearchDataArray[indexPath.section].innerBreakDownObj[dataIndex].engineerPercentage {
            cell.engineerTextField.text = breakDownSearchDataArray[indexPath.section].innerBreakDownObj[dataIndex].paymentPercentage.description
          }
        }
            return cell
        }
        
    }
   
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
      if indexPath.row == 0 {
            if breakDownSearchDataArray[indexPath.section].opened == true {
                breakDownSearchDataArray[indexPath.section].opened = false
                let sections = IndexSet.init(integer:indexPath.section)
                tableView.reloadSections(sections, with: .none)
            } else {
                breakDownSearchDataArray[indexPath.section].opened = true
                let sections = IndexSet.init(integer:indexPath.section)
                tableView.reloadSections(sections, with: .none)
            }
        } else {
            
        }
        
    }
    
    @objc func goToNotesVCWith(_ sender : UIButton) {
      
      let tag = sender.tag
      var inputArray  = [MRHEOpenNewFileBillOfQuantityInnerObject]()
      var outArray = [MRHEOpenNewFileBillOfQuantityInnerObject]()
      
      self.breakDownSearchDataArray.forEach {
        inputArray  =  $0.innerBreakDownObj.filter({$0.workId == tag })
        if inputArray.count > 0  {
          outArray = inputArray
        }
      }
      
      let model : MRHEOpenNewFileBillOfQuantityInnerObject = outArray[0]
      let service = BOQNotesApiService()
      let viewModel = BOQNotesViewModel(service)
      let viewController = BOQNotesViewController.create(with: viewModel) as! BOQNotesViewController
      print(model.paymentDetailId)
      
      viewController.model = model
      viewController.contractId = self.projectID
      viewController.paymentId = self.paymentID
      self.navigationController?.pushViewController(viewController,animated: false)
    }
    
    // MARK: - Navigation
  
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

    @objc func searchRecordsAsPerText(_ textfield:UITextField) {
      
      breakDownSearchDataArray.removeAll()
      
      let searchTxt : String = textfield.text!
        
      if (searchTxt.count) > 0 {
          
          if  let i = breakDownDataArray.index(where: {$0.name.contains(searchTxt)}) {
              breakDownSearchDataArray.append(breakDownDataArray[i])
            }
        } else {
            breakDownSearchDataArray = breakDownDataArray
        }
        
        self.tableView.reloadData()
    }
  
  func addPercentage(dict : [String:String]){
    
//    viewModel.input.workID.asObserver()
//      .onNext(obj.contractId.description)
    
    viewModel.input.workID.asObserver()
      .onNext(dict["workID"]!)
    
    viewModel.input.comment.asObserver()
      .onNext(dict["comment"]!)
    
    viewModel.input.engineerPercentage.asObserver()
      .onNext(dict["engineerPercentage"]!)
    
  }

  func noDataAvailable(){
    
    noData = NoDataView.getEmptyDataView()
    noData.frame = CGRect(x: 0, y:headerView.frame.origin.y, width: self.tableView.frame.size.width,  height:self.noData.frame.size.height)
    
    noData.backBtn.addTarget(self, action: #selector(pushToBack), for: .touchUpInside)
    noData.Yposition.constant = 70
    
//    let theString = String(format: "%@ %@ %@","Unable to retrieve the bill of quantity for this payment no",self.obj.paymentId.description,"Please make sure that the bill of quantity has been added.") as NSString
//    let theAttributedString = NSMutableAttributedString(string: theString as String)
//    
//    let boldString = self.obj.paymentId.description
//    let boldRange = theString.range(of: boldString)
//    let font = UIFont.boldSystemFont(ofSize: 17)
//    
//    theAttributedString.addAttribute(kCTFontAttributeName as NSAttributedStringKey, value: font, range: boldRange)
//    noData.notAvailableText.attributedText = theAttributedString
    self.boqContainerView.addSubview(noData)
    
    
   hideControles()
  }
  
  func hideControles(){
    self.attachmentBtn.isHidden = true
    self.nextView.isHidden = true
    self.cameraBtn.isHidden = true
    self.backView.isHidden = true
    self.headerView.isHidden = true
    self.searchView.isHidden = true
    self.expandView.isHidden = true
    self.subHeaderView.isHidden = true
    
  }
  func showControls(){
    
    self.attachmentBtn.isHidden = false
    self.nextView.isHidden = false
    self.cameraBtn.isHidden = false
    self.backView.isHidden = false
    self.headerView.isHidden = false
    self.searchView.isHidden = false
    self.expandView.isHidden = false
    self.subHeaderView.isHidden = false
    
  }
  
  @IBAction func expandPressed(_ sender: Any) {
    
    if expand == false {
      self.breakDownSearchDataArray.filter({$0.opened == false}).forEach { $0.opened = true }
      expand = true
      expandBtn.setImage(UIImage(named:"Collapse"), for: .normal)
    }else {
      self.breakDownSearchDataArray.filter({$0.opened == true}).forEach { $0.opened = false }
      expand = false
      expandBtn.setImage(UIImage(named:"Expand"), for: .normal)
    
    }
    tableView.reloadData()
  
  }
  
  
  @objc func pushToBack(){
    self.navigationController?.popViewController(animated: false)
  }
  
  @IBAction func attachmentBtnSelected(_ sender: Any) {
    
    let service = PaymentAttachmentsService()
    let viewModel = PaymentsAttachmentViewModel(service)
    let viewController = PaymentAttachmentsViewController.create(with: viewModel) as! PaymentAttachmentsViewController
    
    viewController.obj = obj
    self.navigationController?.pushViewController(viewController,animated: false)
  }
  
  @IBAction func addCameraPressed(_ sender: Any) {

    
    if locationManager == nil{
      locationManager = LocationManager()
    }
    locationManager?.startUpdatingLocation()
    
    
    
    var config = Configuration()
    
    config.doneButtonTitle = "upload".ls
    config.noImagesTitle = "Sorry_There_are_no_images_here".ls
    config.allowVideoSelection = false
    config.recordLocation = true
    
    let imagePicker = ImagePickerController(configuration: config)
    imagePicker.galleryView.isHidden = true
    imagePicker.delegate = self
    Common.appDelegate.shouldRotate = true
    Common.appDelegate.window?.rootViewController?.present(imagePicker, animated: false, completion: nil)
    
  }
  // Mark:-- Open the picker view
  func openCamerViewWith() {
    
  }
  
  // MARK: - ImagePickerDelegate
  
  func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
    
    self.perform(#selector(delay), with: nil, afterDelay: 0.5)
    imagePicker.dismiss(animated: false, completion: nil)
  }
  
  @objc func delay()  {
    Common.appDelegate.shouldRotate = false
  }
  
  func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
    guard images.count > 0 else { return }

    let lightboxImages = images.map {
      return LightboxImage(image: $0)
    }
    
    let lightbox = LightboxController(images: lightboxImages, startIndex: 0)
    imagePicker.present(lightbox, animated: false, completion: nil)
  }
  
  func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
 
    
    var lat : String =  SharedResources.sharedInstance.userLat
    var long : String = SharedResources.sharedInstance.userLong
    indexOfImage = 0
    
    if !(((locationManager?.latestLocation?.coordinate.latitude.description) != nil)) {
      
      lat = (locationManager?.latestLocation?.coordinate.latitude.description)!
      SharedResources.sharedInstance.userLat = (locationManager?.latestLocation?.coordinate.latitude.description)!
    }
    
    
    if  !(((locationManager?.latestLocation?.coordinate.longitude.description) != nil)) {
      long = (locationManager?.latestLocation?.coordinate.longitude.description)!
      SharedResources.sharedInstance.userLong = (locationManager?.latestLocation?.coordinate.latitude.description)!
    }
    /*
    
    let paymentId = obj.paymentId.description
    let contrId = obj.contractId.description
    
    
    var count = images.count
    let docDir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    
    
      for _  in images{
        
      
        let fileName  : String = "Attachment-" + Common.randomString(length: 5) + ".png"
        let filePath = docDir.appendingPathComponent("\(fileName)");
        
        let currentImage = images[indexOfImage]
        indexOfImage = indexOfImage + 1
        
        do{
          
          if let pngImageData = UIImagePNGRepresentation((currentImage)){
            
            let attachment  : OLDBModel = OLDBModel()
            attachment.paymentId = paymentId
            attachment.contractId  = contrId
            attachment.fileName  = fileName
            attachment.filePath = filePath.description
            attachment.longitude = long
            attachment.latitude = lat
            attachment.status = "toDo"
            attachment.percentage = 0.0
            attachment.token = Common.randomString(length: 15)
            
            
            if CoreDataManager.sharedManager.insert(model: attachment){
              
              Common.appDelegate.appLog.info("saving attachment to local storage")
              Common.appDelegate.appLog.verbose(filePath)
              Common.appDelegate.appLog.verbose(fileName)
              
              try pngImageData.write(to : filePath , options : .atomic)
              
              if count == 1 {
                self.perform(#selector(showNotification), with: nil, afterDelay: 0.5)
                Common.smsReceviedSound() //Play Sms recevied sound
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                self.OLImageUploaderVC = storyboard.instantiateViewController(withIdentifier: "OLImageUploader") as! OLImageUploaderViewController  
              }
           
              count = count - 1
            }else {
              Toast(text: "Failed to upload the image, Please try again!", duration: Delay.short).show()
            }
          }
        }catch{
          print("couldn't write image")
        }
      }
*/
    self.perform(#selector(delay), with: nil, afterDelay: 0.5)
    imagePicker.dismiss(animated: false, completion: nil)
    
  }
  
  
  @objc func showNotification(){
    
    let rightView = UIImageView.init(image: UIImage(named: "ViewBTN.png"))
    let leftView = UIImageView.init(image: UIImage(named: "Notification_Icon.ong"))
   
    let banner = NotificationBanner(title: "uploading....".ls, subtitle: "your_images_has_been_started_to_upload._Please_click_on_View_to_see_the_progress...".ls, leftView: leftView, rightView: rightView, style: .success)
    banner.show()
    banner.onTap = {
      SharedResources.sharedInstance.currentRootTag = 5
      self.navigationController?.pushViewController(self.OLImageUploaderVC,animated: false)
    }
    banner.show()
  }

  
  func showIndicator() {
    
    let size = CGSize(width: 70, height: 70)
    startAnimating(size, message: "",messageFont: nil, type: NVActivityIndicatorType.ballBeat, color: UIColor(red: 0/255, green: 97/255, blue: 158/255, alpha: 1.0),padding:10)

  }
  
  

  
}
