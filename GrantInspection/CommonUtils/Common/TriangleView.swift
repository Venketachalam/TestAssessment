//
//  TriangleView.swift
//  Progress
//
//  Created by Muhammad Akhtar on 10/2/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import UIKit

@IBDesignable
class TriangleView : UIView {
    var _color: UIColor! = UIColor.blue
    var _margin: CGFloat! = 0
    var _degrees: CGFloat! = 180
    
    @IBInspectable var margin: Double {
        get { return Double(_margin)}
        set { _margin = CGFloat(newValue)}
    }
    
    @IBInspectable var degree: Double {
        get { return Double(_margin)}
        set { _degrees = CGFloat(newValue)}
    }
    
    @IBInspectable var fillColor: UIColor? {
        get { return _color }
        set{ _color = newValue }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.beginPath()
        context.move(to: CGPoint(x: rect.minX + _margin, y: rect.maxY - _margin))
        context.addLine(to: CGPoint(x: rect.maxX - _margin, y: rect.maxY - _margin))
        context.addLine(to: CGPoint(x: (rect.maxX / 2.0), y: rect.minY + _margin))
        context.closePath()
        
        context.setFillColor(_color.cgColor)
        context.fillPath()
        
        //let degrees = 20 //the value in degrees
        //self.transform = CGAffineTransformMakeRotation(degrees * M_PI/180)
        
        let radians = _degrees / 180.0 * CGFloat.pi
        let rotation = self.transform.rotated(by: radians)
        self.transform = rotation
    }
}
