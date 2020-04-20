//
//  TripModel.swift
//  Progress
//
//  Created by Muhammad Akhtar on 10/30/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import UIKit

class TripModel: NSObject {
   // var projectName: String
    var time: String
    var applicationNo: NSNumber
    var applicationId: NSNumber
   // var paymentId: String
    
    init(time: String, appNo: NSNumber, appId: NSNumber) {
     //   self.projectName = name
        self.time = time
        self.applicationNo = appNo
        self.applicationId = appId
     //   self.paymentId = PaymnetID
        
    }
    
    
}

class DummyLocationObject: NSObject {
    var lat: String
    var lng: String
    
    init(lat: String, lng: String) {
        self.lat = lat
        self.lng = lng
    }
}
