//
//  UIFont+Extension.swift
//  GrantInspection
//
//  Created by Rajeswaran Thangaperumal on 01/09/2019.
//  Copyright © 2019 MBRHE. All rights reserved.
//

import UIKit

extension UIFont {
    
    static func appRegularFont(size:CGFloat = 16.0) -> UIFont {
        
        return UIFont(name: "NeoSansArabic", size: size) ?? UIFont.systemFont(ofSize: size)
    }
}


