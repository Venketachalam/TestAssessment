//
//  PayloadVC.swift
//  NewsFeed
//
//  Created by MAC on 8/14/19.
//  Copyright © 2019 Kuwy-Technology. All rights reserved.
//

import UIKit

class PayloadVC: BaseVC {
    @IBOutlet weak var listObj: UITableView!
    var dataValues = [Payloads]()
    let imageCache = NSCache<NSString, AnyObject>()
    var isPullDown = false
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(PayloadVC.handleRefresh(_:)),
                                 for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.white
        let attributedWithTextColor: NSAttributedString = "Fetching News data ...".attributedStringWithColor(["Fetching News data ..."], color: Color.white)
        refreshControl.attributedTitle = attributedWithTextColor
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "News feeds"
        registerCell()
        listObj.removeSeparatorsOfEmptyCells()
        listObj.estimatedRowHeight = 44
        listObj.rowHeight = UITableView.automaticDimension
        if #available(iOS 10.0, *) {
            listObj.refreshControl = refreshControl
        } else {
            listObj.addSubview(refreshControl)
        }
        self.getNewsFeeds()
        // Do any additional setup after loading the view.
    }
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        isPullDown = true
        self.getNewsFeeds()
        DispatchQueue.main.async {
             refreshControl.endRefreshing()
        }
       
    }
    
    fileprivate func getNewsFeeds(){
        if self.appUtil.currentInternetStatus(){
            if !isPullDown{
                DispatchQueue.main.async {
                 self.showLoader()
                }
            }
            self.serviceRequest.makeGetRequest(self, Constants.newsList, success: { (data) in
                if !self.isPullDown{
                    self.hideLoader()
                }
                let decoder = JSONDecoder()
                do {
                    let responseModel = try decoder.decode(PayLoadResponse.self, from: data)
                    if let success = responseModel.success{
                        if success{
                            if let payloads = responseModel.payload{
                                if payloads.count > 0{
                                    self.dataValues.removeAll()
                                    self.dataValues = payloads
                                    DispatchQueue.main.async {
                                        self.listObj.isHidden = false
                                        self.listObj.reloadData()
                                        self.removeNoviewTag(currentView: self.view)
                                    }
                                }else{
                                    self.listObj.isHidden = true
                                    self.showNoDataFound(currentView: self.view, content: Constants.nodatafound, textColorType: UIColor.black)
                                }
                            }else{
                                self.listObj.isHidden = true
                                self.showNoDataFound(currentView: self.view, content: Constants.nodatafound, textColorType: UIColor.black)
                                
                            }
                        }else{
                            self.alertControll.showAlert(self, title:Constants.appName , message: Constants.somethingWrong, button: "OK")
                        }

                    }else{
                        self.alertControll.showAlert(self, title:Constants.appName , message: Constants.somethingWrong, button: "OK")
                    }
                }catch {
                    print("error")
                    self.alertControll.showAlert(self, title:Constants.appName , message: Constants.somethingWrong, button: "OK")
                }
            }) { (errorMsg) in
                if !self.isPullDown{
                        self.hideLoader()
                }
                 self.alertControll.showAlert(self, title:Constants.appName , message: errorMsg, button: "OK")
            }
        }else{
            self.alertControll.showAlert(self, title:Constants.appName , message: Constants.connectionAlert, button: "OK")
        }
    }
    fileprivate func registerCell(){
        self.listObj.register(UINib(nibName: "PayloadCell", bundle: nil), forCellReuseIdentifier: "Cell")
    }
    
    func downloadImageFrom(urlString: String, cell:PayloadCell) {
        guard let url = URL(string: urlString) else { return }
        downloadImageFrom(url: url, cell: cell)
    }
    
    func downloadImageFrom(url: URL, cell:PayloadCell) {
        if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) as? UIImage {
            DispatchQueue.main.async {
               cell.contentImage.image = cachedImage
            }
        } else {
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async {
                    let imageToCache = UIImage(data: data)
                    self.imageCache.setObject(imageToCache!, forKey: url.absoluteString as NSString)
                    cell.contentImage.image = imageToCache
                }
                }.resume()
        }
    }
}
extension PayloadVC : UITableViewDataSource,UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataValues.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.listObj.dequeueReusableCell(withIdentifier: "Cell") as! PayloadCell
        let obj = dataValues[indexPath.section]
        if let title = obj.title{
            cell.lblTitle.text  = title
        }
        if let desc = obj.description{
            cell.lblDescription.text = desc
        }
        if let date = obj.date{
            cell.lblDate.text = date
        }
        if let imageUrl = obj.image{
            DispatchQueue.global(qos: .background).async {
                self .downloadImageFrom(urlString: imageUrl, cell: cell)
            }
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let obj = dataValues[indexPath.section]
        if let title = obj.title{
            self.alertControll.showAlert(self, title:Constants.appName , message: title, button: "OK")
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
}
struct PayLoadResponse : Codable {
    let payload : [Payloads]?
    let success : Bool?
    
    enum CodingKeys: String, CodingKey {
        
        case payload = "payload"
        case success = "success"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        payload = try values.decodeIfPresent([Payloads].self, forKey: .payload)
        success = try values.decodeIfPresent(Bool.self, forKey: .success)
    }
    
}
struct Payloads : Codable {
    let title : String?
    let description : String?
    let date : String?
    let image : String?
    
    enum CodingKeys: String, CodingKey {
        
        case title = "title"
        case description = "description"
        case date = "date"
        case image = "image"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        title = try values.decodeIfPresent(String.self, forKey: .title)
        description = try values.decodeIfPresent(String.self, forKey: .description)
        date = try values.decodeIfPresent(String.self, forKey: .date)
        image = try values.decodeIfPresent(String.self, forKey: .image)
    }
    
}
