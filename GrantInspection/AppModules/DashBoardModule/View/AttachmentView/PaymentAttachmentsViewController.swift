  //
//  PaymentAttachmentsViewController.swift
//  Progress
//
//  Created by Muhammad Akhtar on 11/6/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import NVActivityIndicatorView
import Alamofire
  import WebKit

class PaymentAttachmentsViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, NVActivityIndicatorViewable, ControllerType, forAttachmentPictureDelegate, UIDocumentInteractionControllerDelegate,WKUIDelegate,WKNavigationDelegate{
    
    @IBOutlet weak var attachmentIconVw: UIImageView!
    
    var attachmentPayload: AttachmentPayload = AttachmentPayload()
    var attachmentsArray:[AttachmentModel] = [AttachmentModel]()
    var filePath:String = ""
    var webView: WKWebView!

    @IBOutlet weak var backStackView: UIView!
    @IBOutlet weak var backBtnView: MBRHEBorderView!
  @IBOutlet weak var mainView: UIView!
  @IBOutlet weak var tblView: UITableView!
    var selectedTableCellIndexPath: IndexPath? = nil
    var isExpnaded: Bool = false
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var attachmentFilesLabel: UILabel!
    
    typealias ViewModelType = PaymentsAttachmentViewModel
    // MARK: - Properties
    private var viewModel: ViewModelType!
    private let disposeBag = DisposeBag()
    var obj:Dashboard = Dashboard()
    var noData : NoDataView!
    var categoryResponse:CategoryResponseListModel!
    
    var interactionDocView: UIDocumentInteractionController?

    var categoryModel=[Response]()

    var categoryApiUploadRequest:CategoryUploadModule!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //addMRHEHeaderView()
        //addMRHELeftMenuView()
        // Do any additional setup after loading the view.
        configure(with: viewModel)
        self.tblView.register(UINib(nibName: "AttachmentCell", bundle: nil), forCellReuseIdentifier: "Cell")
       
        attachmentIconVw.image = attachmentIconVw.image?.tinted(with: UIColor(red: 32/255, green: 132/255, blue: 203/255, alpha: 1.0))
        attachmentFilesLabel.text = "attachment_Files".ls
        btnBack.setTitle("back_btn".ls, for: .normal)
       
        if Common.currentLanguageArabic()
        {
            backStackView.transform = Common.arabicTransform
            backStackView.toArabicTransform()
            btnBack.imageView?.transform = CGAffineTransform(rotationAngle: (180.0 * .pi) / 180.0)
            btnBack.imageEdgeInsets = UIEdgeInsets(top: 0, left: -60, bottom: 0, right: 0)
            btnBack.titleEdgeInsets = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 0)
            btnBack.semanticContentAttribute = .forceRightToLeft
            
            self.mainView.transform = Common.arabicTransform
            self.mainView.toArabicTransform()
        }
        else
        {
           
        }
        
      if(Common.isConnectedToNetwork() == false){
        noDataAvailable(noInternet: true)
      }
        else
      {
       // Common.showActivityIndicator()
        categoryApiUploadRequest = CategoryUploadModule(CategoryUploadService())
        categoryApiUpload()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        Common.appDelegate.shouldRotate = false
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
    }
    
    func addMRHEHeaderView(){
        let mrheHeaderView = MRHEHeaderView.getMRHEHeaderView()
        self.view.addSubview(mrheHeaderView)
    }
    
    func addMRHELeftMenuView(){
        let mrheMenuView = MBRHELeftMenuView.getMBRHELeftMenuView()
        self.view.addSubview(mrheMenuView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configure(with viewModel: PaymentsAttachmentViewModel) {
      
//        let paymentId = obj.paymentId.description
//        let contractId = obj.contractId.description
//
//        self.showActivityIndicator()
//
//        viewModel.input.contractId.asObserver()
//        .onNext(contractId)
//
//        viewModel.input.paymentId.asObserver()
//            .onNext(paymentId)
     
        if Common.isConnectedToNetwork() == true
        {
          Common.showActivityIndicator()
          //  self.startAnimating()
            
        viewModel.output.paymentAttachmentsResultObservable
            .subscribe(onNext: { [unowned self] (attachments) in
               // self.stopActivityIndicator()
                self.stopAnimating()
              
                self.attachmentPayload = attachments
                self.attachmentsArray = self.attachmentPayload.category
              
              if self.attachmentsArray.count > 0 {
                self.tblView.delegate = self
                self.tblView.dataSource = self
                self.tblView.reloadData()
                
              }else {
                self.noDataAvailable()
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
                let errorMessage = (error as NSError).domain
                //print("Erorrrrr \(errorMessage)")
                Common.showToaster(message: errorMessage)

            })
            .disposed(by: disposeBag)
    /*
        attachmentsArray.asObservable()
            .bind(to: self.tblView.rx.items(cellIdentifier: "Cell")){
                (_, obj, cell) in
                if let cell = cell as? AttachmentCell {
                    cell.setData(obj: obj)
                }
            }
            .disposed(by: disposeBag)
        
        tblView.rx
            .modelSelected(AttachmentModel.self)
            .subscribe(onNext:  { obj in
                print(obj.name)
                //let tag = Int(obj.value)
            })
            .disposed(by: disposeBag)
        
        tblView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
//                let cell = self?.tblView.cellForRow(at: indexPath) as? AttachmentCell
//                cell?.lblAttachmentTitle.isEnabled = false
                
                self?.tblView.beginUpdates()
                let element = self?.attachmentsArray.value[indexPath.row]
                element?.isExpanded = !(element?.isExpanded)!
                self?.tblView.reloadRows(at: [indexPath], with: .automatic)
                self?.tblView.endUpdates()
                
            }).disposed(by: disposeBag)
    
        Observable
            .zip(tblView.rx.itemSelected, tblView.rx.modelSelected(String.self))
            .bind { [unowned self] indexPath, model in
                self.tblView.deselectRow(at: indexPath, animated: true)
                print("Selected " + model + " at \(indexPath)")
            }
            .disposed(by: disposeBag)
        */
        
        btnBack.rx.tap.asObservable()
            .subscribe(onNext:{[weak self] _ in
                self?.navigationController?.popViewController(animated: false)
            })
            .disposed(by: disposeBag)
    }
    
    
    //MARK:- API ACCESS
    
    func categoryApiUpload(){

        if Common.isConnectedToNetwork() == true
        {
        //Common.showActivityIndicator()
        showActivityIndicator()
        let inputData=CategoryUploadModel()
        
        inputData.applicantId = obj.applicantId.stringValue
        inputData.applicationNo=obj.applicationNo.stringValue
        inputData.serviceType=obj.serviceTypeId
        
//        inputData.applicantId = "80806"
//        inputData.applicationNo = "1020654"
//        inputData.serviceType = "120"
        
        categoryApiUploadRequest.inputCategoryData.categoriesUploadModal.onNext(inputData)
        categoryApiUploadRequest.outputCategoryData.categoryUploadedResultObservable.subscribe { [weak self](response) in
            self?.stopActivityIndicator()
             if let value = response.element,value.success == true {
//                  if let value = response.element{
                    if value.payload.count > 0 {
                        self?.categoryModel=value.payload

                    } else {

                        self?.noAttachmentAvailable()
                        Common.showToaster(message: "no_attachment_found".ls)
                    }
                    
                self?.tblView.reloadData()
   }
            }.disposed(by: disposeBag)
        
        categoryApiUploadRequest.outputCategoryData.errorsObservable
            .subscribe(onNext: { (error) in
                
                Common.hideActivityIndicator()
                let errorMessage = (error as NSError).domain
                if !errorMessage.isEmpty{
                    self.serverError()
                    Common.showToaster(message: errorMessage)
                }else {

                    Common.showToaster(message: "bad_Gateway".ls)
 
                }
                // self.noDataAvailable(noInternet: true)
            })
            .disposed(by: disposeBag)
        }
        else{
            Common.showToaster(message: "no_Internet".ls)
        }
    }
    

    func downloadAttachmentApiAccess(guid:String,index:Int,fileName:String)
    {

        
        if Common.isConnectedToNetwork() == true
        {

           guard let downloadUrl = URL(string: APICommunicationURLs.downloadAttachment(guid: guid, index: index)) else { return  }
        
//        guard let downloadUrl = URL(string: APICommunicationURLs.downloadAttachment(guid: "{10932E6A-0000-C91E-92F6-C9C0A9124434}", index: 1)) else { return  }
        
        let destinationPath: DownloadRequest.DownloadFileDestination = { _, _ in
            let pathComponent = fileName+".jpg"
          //  let testData = (fileName as NSString).pathExtension
           // print("Path extension",testData)
            let directoryURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let folderPath: URL = directoryURL.appendingPathComponent("Downloads", isDirectory: true)
            let fileURL: URL = folderPath.appendingPathComponent(pathComponent)
            self.filePath=fileURL.absoluteString.removingPercentEncoding!
            self.filePath=self.filePath.replacingOccurrences(of: "file://", with: "",
                                                             options: NSString.CompareOptions.literal, range:nil)
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
           

            Common.showToaster(message: "downloading_file_please_wait".ls)

    
        
        Alamofire.download(
            downloadUrl,
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: SharedResources.sharedInstance.authorizedHeaders,
            to: destinationPath).downloadProgress{ (progress) in
                //progress closure
//                print("Download Progress: \(progress.fractionCompleted)")
            }.response(completionHandler: {[unowned self] (DefaultDownloadResponse) in
                
//                }.response{ (DefaultDownloadResponse) in
                
            let OutputResponse = DefaultDownloadResponse.response?.statusCode
                let errorMessage = DefaultDownloadResponse.error
                print("Error Message",errorMessage ?? "")
                if(OutputResponse == 200)
                {
                    Common.hideActivityIndicator()

                    Common.showToaster(message: "downloaded_successfully".ls)

                    print ("The final url: \(self.filePath)")
                    self.interactionDocView = UIDocumentInteractionController(url: URL(fileURLWithPath:self.filePath, isDirectory:true))
                    self.interactionDocView!.delegate = self
                    self.interactionDocView!.name = fileName
                    self.interactionDocView!.presentPreview(animated: true)
                }
                
                else
             {
               
                Common.hideActivityIndicator()
                
                if let err = DefaultDownloadResponse.error {
                    Common.showToaster(message: err.localizedDescription)
                } else {

                    Common.showToaster(message: "bad_Gateway".ls)

                }

                }
            })
       }
        else
        {
            Common.showToaster(message: "no_Internet".ls)
        }
    }

    
    //MARK:- ATTACHMENT PICTURE DELEGATE
    func getSelectedPictureColumnRow(row: Int, column: Int) {
        
        let currentModalObj=categoryModel[column]
        let selectedObjguid=currentModalObj.guid
        var selectedObjName=currentModalObj.docName
        
        if (selectedObjName.isEmptyString())
        {
            selectedObjName = ("File_\(row+1)")
        }
        
        print("\n\nClicked:: Section is \(column) and Item is \(row)")
        
//        showWebView(guid: selectedObjguid, index:row+1)

        
      if let attachmentVC = self.storyboard?.instantiateViewController(withIdentifier: "AttachmentViewController") as? AttachmentViewController{
            attachmentVC.guid = selectedObjguid
            attachmentVC.index = row+1
            attachmentVC.fileName=selectedObjName
            navigationController?.pushViewController(attachmentVC, animated: true)
        }
        

        
       // downloadAttachmentApiAccess(guid: selectedObjguid, index:row+1, fileName: selectedObjName)
    }
    
    // MARK: - UItable view delegate and datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return  categoryModel.count//attachmentsArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return tableView.frame.size.width / 6 + 35
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: AttachmentCell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! AttachmentCell
//        let item : AttachmentModel = attachmentsArray[indexPath.row]
//        cell.setData(obj: item)
        cell.setData(obj: categoryModel[indexPath.row])
        cell.contentView.tag = indexPath.row
        cell.clipsToBounds = true
        if selectedTableCellIndexPath == indexPath {
            cell.imgViewArrow.image = UIImage.init(named: "cell_up_arrow")
        }else{
            cell.imgViewArrow.image = UIImage.init(named: "cell_down_arrow")
        }
        let currentModal = categoryModel[indexPath.row]
        NSLog("The index part is:", indexPath.row)
        cell.attachmentCountLbl.text=String(currentModal.contentCount)
        //let dataString=NSMutableAttributedString(string: currentModal.docType)
        cell.attachmentFileLabel.attributedText = NSAttributedString(string: currentModal.docType)
        cell.attachmentThumbnailDelegate = self
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("\n\nTblVw_indexxPath   ", indexPath.row)
        
    }
    
    
    static func create(with viewModel: PaymentsAttachmentViewModel) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "PaymenAtttachemntsView") as! PaymentAttachmentsViewController
        controller.viewModel = viewModel
        return controller
    }
    
    func showActivityIndicator() {

               DispatchQueue.main.async {
           let frameToShow = CGRect(x: 0, y:0, width: 50,  height:50)
           let activityIndicatorView : NVActivityIndicatorView = NVActivityIndicatorView(frame: frameToShow)
           activityIndicatorView.tag = 1111
                activityIndicatorView.center = self.view.center 
           activityIndicatorView.color = UIColor(red: 0/255, green: 97/255, blue: 158/255, alpha: 1.0)
           activityIndicatorView.type = NVActivityIndicatorType.ballBeat
           activityIndicatorView.startAnimating()
          self.view.addSubview(activityIndicatorView)
               }
    }
    
    func stopActivityIndicator(){
        DispatchQueue.main.async {
            let view =  self.view//UIApplication.shared.keyWindow!
            for sView in view?.subviews ?? [UIView()] where sView.tag == 1111 {
                sView.removeFromSuperview()
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
  
//    public func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
//        return self
//    }
//
//    public func documentInteractionControllerDidEndPreview(_ controller: UIDocumentInteractionController) {
//         interactionDocView = nil
//    }
    
    
    func noAttachmentAvailable(){
        
        stopActivityIndicator()
        noData = NoDataView.getEmptyDataView()
        noData.frame = CGRect(x: 0, y:0, width: self.mainView.frame.size.width,  height:self.noData.frame.size.height)
        noData.backBtn.addTarget(self, action: #selector(refreshData), for: .touchUpInside)
        noData.setLayout(Yposition:170)
        self.mainView.addSubview(noData)
        
//        if Common.currentLanguageArabic() {
//            self.mainView.transform = Common.arabicTransform
//            self.mainView.toArabicTransform()
//        }
        noData.setLayout(noAttachmentAvailable:true)
        return
    
    }
    
    func serverError(){
        
        noData = NoDataView.getEmptyDataView()
        noData.frame = CGRect(x: 0, y:0, width: self.mainView.frame.size.width,  height:self.noData.frame.size.height)
        noData.backBtn.addTarget(self, action: #selector(refreshData), for: .touchUpInside)
        noData.setLayout(Yposition:170)
        self.mainView.addSubview(noData)
        //   hideControles()
        noData.setLayout(serverError:true)
        return
        
    }
    
  func noDataAvailable(noInternet: Bool? = false){
    self.stopActivityIndicator()
    noData = NoDataView.getEmptyDataView()
    noData.frame = CGRect(x: 0, y:0, width: self.mainView.frame.size.width,  height:self.noData.frame.size.height)
    noData.backBtn.addTarget(self, action: #selector(pushToBack), for: .touchUpInside)
    noData.setLayout(Yposition:35)
    self.mainView.addSubview(noData)
    hideControles()
   
    if noInternet! {
      noData.setLayout(noNetwork:true)
      return
    }
  }
    
  
  func hideControles(){
    self.backBtnView.isHidden = true
    
  }
  func showControls(){
    
   self.backBtnView.isHidden = false
    
  }
  
  @objc func pushToBack(){
    self.navigationController?.popViewController(animated: false)

  }
    @objc func refreshData(){
        noData.removeFromSuperview()
            if(Common.isConnectedToNetwork() == false){
                noDataAvailable(noInternet: true)
            }
            else
            {
                categoryApiUploadRequest = CategoryUploadModule(CategoryUploadService())
                categoryApiUpload()
            }
    }
}

  extension UIImage {
    func tinted(with color: UIColor) -> UIImage? {
        return UIGraphicsImageRenderer(size: size, format: imageRendererFormat).image { _ in
            color.set()
            withRenderingMode(.alwaysTemplate).draw(at: .zero)
        }
    }
  }

//  extension String {
//    func fixUnicode() -> String {
//        var copy = self as NSString
//        let regex = try! NSRegularExpression(pattern: "\\\\U([A-Z0-9]{4})", options: .caseInsensitive)
//        let matches = regex.matches(in: self, options: [], range: NSMakeRange(0, characters.count)).reversed()
//        matches.forEach {
//            let char = copy.substring(with: $0.range(at: 1))
//            copy = copy.replacingCharacters(in: $0.range, with: String(UnicodeScalar(Int(char, radix: 16)!)!)) as NSString
//        }
//        return copy as String
//    }
//  }
