//
//  BaseResponseForModels
//  iskan
//
//  Created by Zeshan Hayder on 1/24/18.
//  Copyright © 2018 MRHE. All rights reserved.

import EVReflection

open class BaseResponseForModels: EVObject {
    
    public var success: Bool = false
    public var message: String = ""
    public var statusCode : Int = 0
    
}
