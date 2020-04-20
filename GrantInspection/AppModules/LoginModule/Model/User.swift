//
//  User.swift
//  Progress
//
//  Created by Muhammad Akhtar on 6/3/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import EVReflection

public class User : BaseResponseForModels {
    
    public var access_token:String=""
    public var expires_in:NSNumber = 0
    public var refresh_expires_in:NSNumber = 0
    public var refresh_token:String = ""
    public var token_type:String = ""
    public var not_before_policy:NSNumber = 0
    public var session_state:String = ""
    public var scope:String = ""
    public var username : String = ""
    override public func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
        return [(keyInObject: "not_before_policy",keyInResource: "not-before-policy")]
    }
    
    
    required public init() {}
    
}
