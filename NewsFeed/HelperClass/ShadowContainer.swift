//
//  ShadowContainer.swift
//  Kuwy
//
//  Created by Saikrishna Kumbhoji on 28/05/19.
//  Copyright © 2019 Saikrishna Kumbhoji. All rights reserved.
//

import Foundation
import UIKit
class ShadowContainer: UIView {
    override init(frame: CGRect) {
        // 1. setup any properties here
        
        // 2. call super.init(frame:)
        super.init(frame: frame)
        
        // 3. Setup view from .xib file
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        // 1. setup any properties here
        
        // 2. call super.init(coder:)
        super.init(coder: aDecoder)
        
        // 3. Setup view from .xib file
        xibSetup()
        //        self.view = loadViewFromNib() as! CustomView
    }
    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        xibSetup()
    }
    func xibSetup() {
//        layer.masksToBounds = false
//        layer.shadowColor = UIColor.black.cgColor
//        layer.shadowOpacity = 1
//        layer.shadowOffset = CGSize.zero
//        layer.shadowRadius = 1
//        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
//        layer.shouldRasterize = true
//        layer.rasterizationScale = 1
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        layer.shadowRadius = 3.0
        layer.shadowColor = UIColor.black.cgColor
    }
    
    
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
        xibSetup()
     }
 
    
}
