//
//  UIColor+Extension.swift
//  GrantInspection
//
//  Created by Rajeswaran Thangaperumal on 28/08/2019.
//  Copyright © 2019 MBRHE. All rights reserved.
//

import UIKit

extension UIColor {
    
    static func appBlueColor() -> UIColor {
         return UIColor(red: 36/255, green: 98/255, blue: 158/255, alpha: 1.0)
    }
    
    static func appBorderColor() -> UIColor {
        return UIColor(red: 232/255, green: 234/255, blue: 244/255, alpha: 1.0)
    }
    
    static func lightGrayGradiend() -> [UIColor] {
        return [UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0),UIColor(red: 242/255, green: 244/255, blue: 247/255, alpha: 1.0)]
    }
    static func blueGradient() -> [UIColor] {
        return [UIColor(red: 0/255, green: 132/255, blue: 215/255, alpha: 1.0),UIColor(red: 12/255, green: 104/255, blue: 162/255, alpha: 1.0)]
    }
    static func navySemitransperent() -> UIColor {
        return UIColor(red: 0/255, green: 39/255, blue: 63/255, alpha: 1.0).withAlphaComponent(0.7)
    }
}
