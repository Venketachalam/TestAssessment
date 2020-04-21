//
//  MRHEOpenNewFileBillOfQuantityInnerObject.swift
//  Progress
//
//  Created by Muhammad Akhtar on 6/21/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import UIKit

class MRHEOpenNewFileBillOfQuantityInnerObject {
  
  
    var workId: Int!
    var paymentDetailId: Int!
    var workDesc: String!
    var actualDone: Float!
    var contarctPercentage: Float!
    var paymentPercentage: Float!
    var engineerPercentage: Float!
    var comment: [String] = [String]()
    
  init(paymentDetailId : Int,workId: Int, workDesc: String, contarctPercentage: Float,actualDone:Float, paymentPercentage:Float, engineerPercentage:Float, comment:[String]) {
    
        self.paymentDetailId = paymentDetailId
        self.workId = workId
        self.workDesc = workDesc
        self.actualDone = actualDone
        self.contarctPercentage = contarctPercentage
        self.paymentPercentage = paymentPercentage
        self.engineerPercentage = engineerPercentage
        self.comment = comment
       
    }
    
}
