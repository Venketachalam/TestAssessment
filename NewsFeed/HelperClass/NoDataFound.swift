//
//  NoDataFound.swift
//  DailythanthiRevamp
//
//  Created by Sureshbabu Naidu on 25/11/16.
//  Copyright © 2016 Vishwak. All rights reserved.
//

import UIKit

class NoDataFound: UIView {

    @IBOutlet var noDataLbl: UILabel!
    var view = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }
    func setup() {        
        // setup the view from .xib
        view = loadViewFromNib()
        //view.frame = bounds
//        print(view.bounds)
        self.frame = view.bounds
        self .isUserInteractionEnabled = true
        view.backgroundColor = UIColor.clear
        view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        addSubview(view)
    }
    func loadViewFromNib() -> UIView {
        // grabs the appropriate bundle
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "NoDataFound", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    func  showContent(msg:String,textColorTyp: UIColor){
        self.noDataLbl.textColor = textColorTyp
        self.noDataLbl.text = msg
        self.noDataLbl.font = UIFont(name:"HelveticaNeue-Medium", size: 19.0)
    }

}
