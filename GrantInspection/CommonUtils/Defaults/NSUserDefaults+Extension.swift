//
//  NSUserDefaults+Extension.swift
//  Progress
//
//  Created by Muhammad Akhtar on 6/3/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import UIKit
import EVReflection

extension UserDefaults {
  
 
    func archiveUserLoginState() {
        let kUserProfileImage = "kUserProfileImage"
        self.setValue(nil, forKey: kUserProfileImage)
        let kUserLoginStatus = "kUserLoginStatus"
        self.set(false, forKey: kUserLoginStatus)
        self.synchronize()
    }
    
    func showUserLoginState() -> Bool
    {
        let kUserLoginStatus = "kUserLoginStatus"
        return self.bool(forKey: kUserLoginStatus)
    }
    
    
    func saveLogInStatus(isLogedIn:Bool) {
        self.set(isLogedIn, forKey: Common.kLoggedIn)
    }
    
    func setIsRemember(isRemember:Bool) {
        self.set(isRemember, forKey: "remember")
    }
    
    func getIsRemember() -> Bool {
       return self.bool(forKey: "remember")
    }
    func setUpgradeApp(isShowUpgrade:Bool) {
        self.set(isShowUpgrade, forKey: "Upgrade")
    }
    func getUpgradeApp() -> Bool{
        return self.bool(forKey: "Upgrade")
    }
    func saveUserModel(_ userModel: User) {
        //self.set(true, forKey: Common.kLoggedIn)
        userModel.saveToTemp(Common.loginUserFileName)
    }
    
    func fetchCurrentUserModel() -> User {
       return User.init(fileNameInTemp:Common.loginUserFileName)
    }
    
    func setLoginUserTime(_time:String) {
        self.setValue(_time, forKeyPath: "LogInTime")
        self.synchronize()
    }
    
    func getLoginUserTime() -> String {
        guard let logInTime = self.string(forKey: "LogInTime") else {
            return " "
        }
        return logInTime
    }
    
    func saveLoggedUserName(userName:String,environment:String,password:String)  {
    
        let dataUser = ["UserName":userName,"Password":password]
//        self.set(object: NSKeyedArchiver.archivedData(withRootObject: dataUser), forKey: environment)
         do {
        let data = try NSKeyedArchiver.archivedData(withRootObject: dataUser, requiringSecureCoding: false)
        self.set(data, forKey: environment)
        } catch{
           print("error in saving")
            return
        }
        
//       if (environment == ".QA")
//       {
//        self.setValue(userName, forKeyPath: "UserName")
//        }
//        else
//       {
//        self.setValue(userName, forKeyPath: "prodUser")
//        }
        
        self.synchronize()
        
    }
    
   // func getSavedLoggedUserName(environment:String) -> String {
    func getSavedLoggedUserName(environment:String) -> [String:String] {

      //  func getSavedLoggedUserName() -> String {
       // let environment = "QA"
//        if (environment == ".QA")
//              {
//        guard let savedLoggedUserName = self.string(forKey: "UserName") else {
//            return " "
//        }
//        return savedLoggedUserName
//        }
//        else
//        {
//            guard let savedLoggedUserName = self.string(forKey: "prodUser") else {
//                       return " "
//                   }
//                   return savedLoggedUserName
//        }
//  guard let data = self.object(forKey: environment) as? NSData else{return ""}
        
        
        
        //let unarchivedObject = UserDefaults.standard.data(forKey: environment)
        
        
        
//        guard let cachedUserData = self.object(forKey: environment) as? NSData else {
//            print("Could not unarchive from placesData")
//            return ""
//        }
        
        
//        do {
//            let array = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(placesArray as Data) as? [String : String]
//        } catch {
//            fatalError("loadWidgetDataArray - Can't encode data: \(error)")
//        }
//        let object =  NSKeyedUnarchiver.unarchiveObject(with: (self.object(forKey: environment) as? NSData) as! Data) as? [String: String]
        
//        guard (NSKeyedUnarchiver.unarchiveObject(with: cachedUserData as Data) as? Any) != nil else {
//            return ""
//        }
        
//        do {
//            guard let array = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(cachedUserData) as? Any else {
//                fatalError("loadWidgetDataArray - Can't get Array")
//            }
//            return ""
//        } catch {
//            fatalError("loadWidgetDataArray - Can't encode data: \(error)")
//        }
        
        if let val = self.value(forKey: environment) as? Data,
            let obj = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(val) as? [String: String] {
//            if let person = obj?.values  {
//              //  let data = person["UserName"]
//               print("Person is:",person)
//            }
            let username = obj ["UserName"] ?? ""
            let password = obj ["Password"] ?? ""

            
           // print ("Checking is:",obj)
            return ["UserName":username,"Password":password]
        }
        
        return ["UserName":"","Password":""]

    }
    
   func savePassword(password:String)  {
          self.setValue(password, forKeyPath: "Password")
          self.synchronize()
      }
      
      func getSavedPassword() -> String {
          guard let savedPassword = self.string(forKey: "Password") else {
              return " "
          }
          return savedPassword
      }
    

    func saveDebugMode(_ isDubuggModeSelectedVal: Bool)  {
      let _kDebuggMode = "kDebuggMode"
      self.set(isDubuggModeSelectedVal, forKey: _kDebuggMode)
      self.synchronize()
  }
  
  func getDebugMode() -> Bool {
    let _kDebuggMode = "kDebuggMode"
    if let debugMode = self.object(forKey: _kDebuggMode) as? Bool
    {
      return debugMode
    }
    else
    {
      return false
    }
  }
  
    func setBuildingName(name:String) {
        self.set(name, forKey: "buildingName")
        self.synchronize()
    }
    
    func getBuildingName() -> String {
        guard let buildName = self.string(forKey: "buildingName") else {
            return " "
        }
        return buildName
    }
    
    func setNotes(id:String) {
        self.set(id, forKey: "notes")
        self.synchronize()
    }
    
    func getNotes() -> String {
        guard let noteId = self.string(forKey: "notes") else {
            return " "
        }
        return noteId
    }
    
    func setServices(id:String) {
        self.set(id, forKey: "services")
        self.synchronize()
    }
    
    func getServices() -> String {
        guard let noteId = self.string(forKey: "services") else {
            return " "
        }
        return noteId
    }
        
    
    func clearData() {
      if let bundleID = Bundle.main.bundleIdentifier {
        
      //  guard let QAData = self.object(forKey: "QA") as? NSData else { return }
        //  guard let ProdData = self.object(forKey: "Prod") as? NSData else { return }
        
        var cachedQAData : NSData?
        var cachedprodData : NSData?

        if let QAData = self.object(forKey: "QA") as? NSData{
            cachedQAData = QAData
        }
        if let prodData =  self.object(forKey: "Prod") as? NSData{
            cachedprodData = prodData
        }
        
        let qaUser = self.getSavedLoggedUserName(environment: "QA")
        let prodUser = self.getSavedLoggedUserName(environment: "Prod")
        
         let isrememberData = self.getIsRemember()
        UserDefaults.standard.removePersistentDomain(forName: bundleID)
        self.setIsRemember(isRemember: isrememberData)
        
        self.saveLoggedUserName(userName: qaUser["UserName"]!, environment: "QA", password: qaUser["Password"]!)
        self.saveLoggedUserName(userName: prodUser["UserName"]!, environment: "Prod", password: prodUser["Password"]!)

        
//        if let QAcredentials = cachedQAData {
//            do {
//              let data = try NSKeyedArchiver.archivedData(withRootObject: QAcredentials, requiringSecureCoding: false)
//              self.set(data, forKey: "QA")
//              } catch{
//                 print("error in QA saving")
//                  return
//              }
//        }
//       if let prodCredentials = cachedprodData {
//        do {
//        let data = try NSKeyedArchiver.archivedData(withRootObject: prodCredentials, requiringSecureCoding: false)
//        self.set(data, forKey: "Prod")
//        } catch{
//           print("error in Prod saving")
//            return
//        }
//        }
        UserDefaults.standard.synchronize()
        }
    }
  
    func logout() {
        

        
        /*
        let service = MRHELogOutService()
        service.authorizedHeaders = SharedResources.sharedInstance.authorizedHeaders
        service.accessToken = SharedResources.sharedInstance.currentUser.access_token
        service.bearer = SharedResources.sharedInstance.currentUser.token_type
        
        service.logOut(locale: Common.languageCode) { (result, response) in
            if result == MRHEAPIResult.Success {
                
                
            }
        }
        */
    }
    
    
}
extension UserDefaults {
    func object<T: Codable>(_ type: T.Type, with key: String, usingDecoder decoder: JSONDecoder = JSONDecoder()) -> T? {
        guard let data = self.value(forKey: key) as? Data else { return nil }
        return try? decoder.decode(type.self, from: data)
    }

    func set<T: Codable>(object: T, forKey key: String, usingEncoder encoder: JSONEncoder = JSONEncoder()) {
        let data = try? encoder.encode(object)
        self.set(data, forKey: key)
    }
}
