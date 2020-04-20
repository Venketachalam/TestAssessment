//
//  ErrorResponseModel.swift
//  Progress
//
//  Created by Muhammad Akhtar on 12/19/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import EVReflection

open class ErrorResponseModel: EVObject {
    
    public var success: Bool = false
    public var message: String = ""
    public var timestamp : NSNumber = 0
    public var details: String = ""
    
}
