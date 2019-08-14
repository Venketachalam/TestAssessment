//
//  LoginVC.swift
//  NewsFeed
//
//  Created by MAC on 8/13/19.
//  Copyright © 2019 Kuwy-Technology. All rights reserved.
//

import UIKit

class LoginVC: BaseVC {

    @IBOutlet weak var txtEmpId: UITextField!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtBarahNo: UITextField!
    @IBOutlet weak var txtEmailAddress: UITextField!
    @IBOutlet weak var txtUnifield: UITextField!
    @IBOutlet weak var txtMobileNo: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func submitAction(_ sender: Any) {
        self.view.endEditing(true)
        if txtEmpId.text?.count == 0{
             self.alertControll.showAlert(self, title:Constants.appName , message: "Enter valid employee ID", button: "OK")
        }else if txtName.text?.count == 0{
            self.alertControll.showAlert(self, title:Constants.appName , message: "Enter user name", button: "OK")
        }else if txtBarahNo.text?.count == 0{
            self.alertControll.showAlert(self, title:Constants.appName , message: "Enter barah number", button: "OK")
        }else if txtEmailAddress.text?.count == 0 || !txtEmailAddress.text!.isValidEmail{
            self.alertControll.showAlert(self, title:Constants.appName , message: "Enter valid email address", button: "OK")
        }else if txtUnifield.text?.count == 0{
            self.alertControll.showAlert(self, title:Constants.appName , message: "Enter unified number", button: "OK")
        }else if txtMobileNo.text?.count == 0{
            self.alertControll.showAlert(self, title:Constants.appName , message: "Enter valid mobile number", button: "OK")
        }else{
            var dataToServer = [String:Any]()
            dataToServer["eid"] = txtEmpId.text?.toInt()
            dataToServer["name"] = txtName.text
            dataToServer["idbarahno"] = txtBarahNo.text
            dataToServer["emailaddress"] = txtEmailAddress.text
            dataToServer["unifiednumber"] = txtUnifield.text?.toInt()
            dataToServer["mobileno"] = txtMobileNo.text
            if self.appUtil.currentInternetStatus(){
                self.showLoader()
                self.serviceRequest.makePostRequest(self,Constants.loginMethod, params: dataToServer, headers: Constants.header, success: { (data) in
                    self.hideLoader()
                    let decoder = JSONDecoder()
                    do {
                        let responseModel = try decoder.decode(LoginResponse.self, from: data)
                        if responseModel.success!{
                            if let refId = responseModel.payload?.referenceNo{
                                self.deleteDataInCD(entityName: Constants.entityName, keyName: "\(refId)")
                                var tempObj = [String:Any]()
                                tempObj["eid"] = self.txtEmpId.text!
                                tempObj["name"] = self.txtName.text!
                                tempObj["idbarahno"] = self.txtBarahNo.text!
                                tempObj["emailaddress"] = self.txtEmailAddress.text!
                                tempObj["unifiednumber"] = self.txtUnifield.text!
                                tempObj["mobileno"] = self.txtMobileNo.text!
                                self.txtName.text = ""
                                self.txtEmpId.text = ""
                                self.txtBarahNo.text = ""
                                self.txtEmailAddress.text = ""
                                self.txtMobileNo.text = ""
                                self.txtUnifield.text = ""
                                // Saving user info into core data, reference key is an unique
                                self.saveUser(refId: refId, userInfo: tempObj)
                                let obj = self.storyboard?.instantiateViewController(withIdentifier: "PayloadVC")
                                self.navigationController?.pushViewController(obj!, animated: true)
                            }
                        }else{
                            var msg = ""
                            if let msgs = responseModel.message{
                                msg = msgs
                            }
                         self.alertControll.showAlert(self, title:Constants.appName , message: msg, button: "OK")
                        }
                    } catch {
                        print("error")
                        self.alertControll.showAlert(self, title:Constants.appName , message: Constants.somethingWrong, button: "OK")
                    }
                }) { (errorMsg) in
                    self.hideLoader()
                     self.alertControll.showAlert(self, title:Constants.appName , message: errorMsg, button: "OK")
                }
                
            }else{
                self.alertControll.showAlert(self, title:Constants.appName , message: Constants.connectionAlert, button: "OK")
            }
            
         }
    }
    fileprivate func saveUser(refId : Int,userInfo : [String:Any]){
        var data = [[String:Any]]()
        data.append(userInfo)
        let menuObj = UsersModel(categories:data)
        let newsListing = Users(context: self.getContext())
        let encodedObject = NSKeyedArchiver.archivedData(withRootObject:menuObj) as NSObject?
        newsListing.data = encodedObject
        newsListing.key  = "\(refId)"
        (UIApplication .shared .delegate as! AppDelegate).saveContext()
    }
    fileprivate func getUsers(refId : Int){
        let datas = self .checkDataInCD(entityName: Constants.entityName, keyName: "\(refId)")
        if (datas as AnyObject) .count == 0 {
            
        }else{
            //caching data
            //get data local db only
            let localNewsData = datas[0] as! Users
            let newsModelObj = NSKeyedUnarchiver.unarchiveObject(with:localNewsData.data as! Data) as! UsersModel
            
            let temp = newsModelObj.categories
            if temp.count > 0{
                let storedObj = temp[0]
                print(storedObj)
            }
        }
    }
}
struct LoginResponse : Codable {
    let message : String?
    let success : Bool?
    let payload : Payload?
    enum CodingKeys: String, CodingKey {
        
        case message = "message"
        case success = "success"
        case payload = "payload"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        message = try values.decodeIfPresent(String.self, forKey: .message)
        success = try values.decodeIfPresent(Bool.self, forKey: .success)
        payload = try values.decodeIfPresent(Payload.self, forKey: .payload)
    }
    
}
struct Payload : Codable {
    let referenceNo : Int?
    
    enum CodingKeys: String, CodingKey {
        
        case referenceNo = "referenceNo"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        referenceNo = try values.decodeIfPresent(Int.self, forKey: .referenceNo)
    }
    
}
struct UsersData {
    let eid : String
    let name : String
    let idbarahno : String
    let emailaddress : String
    let unifiednumber : String
    let mobileno : String
}
class UsersObject: NSObject {
    
    var eid : String
    var name : String
    var idbarahno : String
    var emailaddress : String
    var unifiednumber : String
    var mobileno : String
    init(eid: String,name : String,idbarahno : String,emailaddress : String,unifiednumber : String,mobileno : String) {
        self.eid = eid
        self.name = name
        self.idbarahno = idbarahno
        self.emailaddress = emailaddress
        self.unifiednumber = unifiednumber
        self.mobileno = mobileno
        super.init()
    }
}
class UsersModel: NSObject,NSCoding {
    var categories: [[String:Any]]
    init(categories:[[String:Any]]) {
        self.categories = categories
    }
    // MARK: NSCoding
    required convenience init(coder aDecoder: NSCoder) {
        let categories = aDecoder.decodeObject(forKey: "categories")
        self.init(categories: categories! as! [[String:Any]])
    }
    
    func encode(with aCoder: NSCoder) {
        //        print(self.categories)
        aCoder.encode(self.categories, forKey: "categories")
        //aCoder.encodeConditionalObject(self.categories, forKey: "categories")
    }
}
