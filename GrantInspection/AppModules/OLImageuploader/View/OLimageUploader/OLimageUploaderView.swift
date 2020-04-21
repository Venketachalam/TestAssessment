  //
//  ProjectInfoWindow.swift
//  Progress
//
//    Created by Hasnain Haider on 08/4/19.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import UIKit
  
  class OLimageUploaderView: UIView , UITableViewDelegate , UITableViewDataSource , modelDelegate{
    

  @IBOutlet weak var mainView: UIView!
  @IBOutlet weak var headerView: UIView!
  @IBOutlet weak var tableView: UITableView!
  
  var dataArray : [OLDBModel]!
  var noData : NoDataView!
  var viewModel : OLImageploaderViewModel!
 
  
  class func getProjectInfoWindow() -> OLimageUploaderView
    {
        return Bundle.main.loadNibNamed("OLimageUploaderView", owner: self, options: nil)![0] as! OLimageUploaderView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
      
      
      viewModel = OLImageploaderViewModel()
      dataArray =  [OLDBModel]()
      setLayout()
      loadData()
      viewModel.didStartProgress(true)
      
    }
    
  func setLayout(){
  
    let path = UIBezierPath(roundedRect: self.headerView.bounds, byRoundingCorners: [.topRight,.topLeft], cornerRadii: CGSize(width: 10, height: 10))
    let mask = CAShapeLayer()
    mask.path = path.cgPath
    self.headerView.layer.mask = mask
    
    
    tableView.register(UINib.init(nibName: "OLImageUploaderCell", bundle: nil), forCellReuseIdentifier: "OLImageUploaderCell")
    tableView.delegate = self
    tableView.dataSource = self
    
    viewModel.modelDelegate = self
    
  }
  
  func retry(){
      loadData()
      viewModel.didStartProgress(true)
  }
    
  func loadData() {
    
    if CoreDataManager.sharedManager.fetch() != nil{
     
      dataArray = CoreDataManager.sharedManager.fetch()!
 
      if dataArray.count <= 0 {
        notAvailable()
        tableView.isUserInteractionEnabled = false
      }else {
         tableView.isUserInteractionEnabled = true
        
        if noData != nil {
         noData.removeFromSuperview()
        }
      }
    }else {
       dataArray  = [OLDBModel]()
    }
    
    DispatchQueue.main.async {
      self.tableView.reloadData()
    }
   
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataArray.count
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
   return 115
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell:OLImageUploaderCell = self.tableView.dequeueReusableCell(withIdentifier: "OLImageUploaderCell") as! OLImageUploaderCell
    
    let record : OLDBModel = dataArray[indexPath.row]
    cell.selectionStyle = .none
    cell.setData(model: record)
    cell.btn2.tag = indexPath.row
    
    if record.status == "toDo"{
      //cell.btn2.addTarget(self, action: #selector(confirmation), for: .touchUpInside)
    }
    
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    print("You tapped cell number \(indexPath.row).")
  }
  
  func notAvailable(){
    
    noData = NoDataView.getEmptyDataView()
    noData.frame = CGRect(x: 0, y:0, width: (self.tableView?.frame.size.width)!,  height:(self.tableView?.frame.size.height)!)
    
    noData.setLayout(title:"Opps.. No Images for Upload", description:"Sorry for your inconvenience, At this time no images are available to upload...", noNetwork:false,hideBack:true, Yposition :5,icon:"NoUpload_Artwork")
    
    self.tableView?.addSubview(noData)
    noData.backBtn.addTarget(self, action: #selector(self.pushTobackView), for: .touchUpInside)
    
    
  }
  
  @objc func pushTobackView(){
    
  }

  @objc func startProgress(){
     viewModel.didStartProgress(true)
  }

    func didFinishProcess() {
      loadData()
    }
    
  @objc func confirmation(sender:UIButton){
    
    let record : OLDBModel = dataArray[sender.tag]
    
    let refreshAlert = UIAlertController(title: "Confirmation".ls, message: "Are_you_sure_You_want_to_clear_the_images".ls, preferredStyle: UIAlertController.Style.alert)
    
    refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
      
      self.viewModel.deleteRecord(token: record.token)
      
    }))
    
    refreshAlert.addAction(UIAlertAction(title: "cancel_btn".ls, style: .cancel, handler: { (action: UIAlertAction!) in
    
    }))
    
    Common.appDelegate.window?.rootViewController?.present(refreshAlert, animated: true, completion: nil)
    
  }
    
   
    
  
}
