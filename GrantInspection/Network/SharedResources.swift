//
//  SharedResources.swift
//  iskan
//
//  Created by Zeshan on 8/14/16.
//  Copyright © 2016 MRHE. All rights reserved.
//

import Foundation
import RxSwift

class SharedResources: NSObject {
    
    static let sharedInstance = SharedResources()
    
    override init() {
        super.init()
    }
    
    var authorizedHeaders : [String:String] = [:]
    var normalUnAuthorisedHeader : [String : String] = [:]
    var contractsPayload: ContractsResponse = ContractsResponse()
    var selectedTripContracts: [Dashboard] = [Dashboard]()
    var currentRootTag = 1
    var currentUser : User!
    var appFeatureStatus : FetchFeaturesResponse = FetchFeaturesResponse()
    var pagesCount : Int = 0 
    var searchActive : Bool = false
    var oLImageUploader : OLimageUploaderView!
    var isRefreshNeeded : Bool = false
    var totalImageCount : CGFloat = 0
    var currentImageCount : CGFloat = 0
   
    var applicationNo : String = ""
    var plotNo : String = ""
  
    var userLat :  String = ""
    var userLong : String = ""
  
    var userLoggedIn : Bool = false
    
    var tripModelValue = TripModel(time: "", appNo: 0, appId: 0)
    var tripModelDict = [String : String]()
    
    func loadAllVariables(isFromAppDelegate:Bool)
    {
      
        var isLogedIn = false
        
        if Common.userDefaults.getIsRemember() {
            // get saved user object
            self.currentUser = Common.userDefaults.fetchCurrentUserModel()
        }
        
     /*   if !Common.userDefaults.getIsRemember() && isFromAppDelegate{
            isLogedIn = false
        } else {
            isLogedIn = Common.userDefaults.bool(forKey: Common.kLoggedIn)
        }
        
        if isLogedIn {
            //user logged in
            authorizedHeaders = [
                "Authorization": "bearer" + " " + self.currentUser.access_token
            ]
        } else {
            normalUnAuthorisedHeader = ["consumer-key": Common.client_id,
                                         "consumer-secret": Common.client_secret]
        }
 */
        if  Common.userDefaults.getIsRemember() && Common.isUserSessionActive() {
            authorizedHeaders = [
                "Authorization": "bearer" + " " + self.currentUser.access_token
            ]
        } else {
            normalUnAuthorisedHeader = ["consumer-key": Common.client_id,
                                        "consumer-secret": Common.client_secret]
        }
      
      if Common.userDefaults.getDebugMode()
      {
        Common.setAPPKeyAndSeacretDebuggMode(true)
        APICommunicationURLs.setApplicationEnviroment(_domainType: .QA)
        Localization.storeCurrentLanguage("en")
      }
      else
      {
        Common.setAPPKeyAndSeacretDebuggMode(false)
        APICommunicationURLs.setApplicationEnviroment(_domainType: .Production)
        Localization.storeCurrentLanguage("ar")
      }
    }
}
