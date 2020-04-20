//
//  PaymentNotesModel.swift
//  Progress
//
//  Created by Muhammad Akhtar on 11/13/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import EVReflection

public class  PaymentNotesModel: BaseResponseForModels {
    
    open var payload: [NotesPayload] = [NotesPayload]()
    required public init() {}
}

public class  NotesPayload: EVObject {
    
    open var date:String = ""
    open var remarks:String = ""
    
    required public init() {}
}
