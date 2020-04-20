//
//  DateExtension.swift
//  GrantInspection
//
//  Created by Rajeswaran Thangaperumal on 30/08/2019.
//  Copyright © 2019 MBRHE. All rights reserved.
//

import Foundation

extension Date {
    
    func getExpectedFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "en_US")
        return dateFormatter.string(from: self)
    }
    
   
    func getToServerFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yy"
        return dateFormatter.string(from: self)
            
    }
    
}
