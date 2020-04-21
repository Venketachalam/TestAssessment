//
//  CustomButton.swift
//  GrantInspection
//
//  Created by Divya Lingam on 30/01/20.
//  Copyright © 2020 MBRHE. All rights reserved.
//

import UIKit

enum CustomButtonType {
    case blue
    case lightGray
    case darkGray
    case gray
}

class CustomButton: UIButton {
    
    var type:CustomButtonType = .blue {
        didSet {
           addLayerBasedOnType(type: type)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
         
        addLayerBasedOnType(type: type)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
         addLayerBasedOnType(type: type)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setComponetColorBasedOnType(type: type)

    }
    
    
    private func addLayerBasedOnType(type: CustomButtonType) {
        switch type {
        case .blue:
             self.applyStyle(color: [UIColor(red: 0/255, green: 132/255, blue: 215/255, alpha: 1.0),UIColor(red: 12/255, green: 104/255, blue: 162/255, alpha: 1.0)])
        case .lightGray,.darkGray:
            self.applyStyle()
        case .gray:
            self.applyStyle(color: [UIColor.darkGray,UIColor.black])
        }
    }
    
    private func setComponetColorBasedOnType(type: CustomButtonType) {
        switch type {
               case .blue:
                    self.titleLabel?.textColor = .white
               case .lightGray,.darkGray:
                   self.titleLabel?.textColor = UIColor(red: 36/255, green: 98/255, blue: 158/255, alpha: 1.0)
            case .gray:
                   self.titleLabel?.textColor = .white
               }
    }
}
