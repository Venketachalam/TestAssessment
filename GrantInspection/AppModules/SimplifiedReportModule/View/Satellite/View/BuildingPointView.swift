//
//  buildingPointView.swift
//  GrantInspection
//
//  Created by Gopalakrishnan Chinnadurai on 07/10/19.
//  Copyright © 2019 MBRHE. All rights reserved.
//

import UIKit

class BuildingPointView : UIView {
    
    @IBOutlet weak var stckVw: UIStackView!
    @IBOutlet weak var bpView: UIView!
    @IBOutlet weak var nameTxtFle: UITextField!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
        
    }
    
    private func setup() {
        
            
        
    }
    
    
}
