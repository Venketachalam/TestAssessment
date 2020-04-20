//
//  MBRHEBorderView.swift
//  Progress
//
//  Created by Muhammad Akhtar on 6/7/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import UIKit

@IBDesignable
class MBRHEBorderView: UIView {
    

  @IBInspectable var firstColor: UIColor = UIColor.clear {
    didSet {
      updateView()
    }
  }
  
  @IBInspectable var secondColor: UIColor = UIColor.clear {
    didSet {
      updateView()
    }
  }
  
  @IBInspectable var isHorizontal: Bool = true {
    didSet {
      updateView()
    }
  }
  
  override class var layerClass: AnyClass {
    get {
      return CAGradientLayer.self
    }
  }
  
  func updateView() {
    let layer = self.layer as! CAGradientLayer
    layer.colors = [firstColor, secondColor].map {$0.cgColor}
    if (isHorizontal) {
      layer.startPoint = CGPoint(x: 0, y: 0.5)
      layer.endPoint = CGPoint (x: 1, y: 0.5)
    } else {
      layer.startPoint = CGPoint(x: 0.5, y: 0)
      layer.endPoint = CGPoint (x: 0.5, y: 1)
    }
  }
  
  
  
    @IBInspectable var shadowRadius: CGFloat = 0 {
        didSet {
            layer.shadowRadius = 2.0
        }
    }
    
    @IBInspectable var shadowOffset: CGSize = CGSize() {
        didSet {
            //for bottom and right and left sides shadow on view
            layer.shadowOffset = shadowOffset
        }
    }
    @IBInspectable var shadowOpacity:  CGFloat = 0 {
        didSet {
            layer.shadowOpacity = 0.3
        }
    }
    
    @IBInspectable var shadowColor:  UIColor = UIColor.black {
        didSet {
            layer.shadowColor = shadowColor.cgColor
        }
    }
    
    
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
//    @IBInspectable
//    var borderWidth: CGFloat {
//        get {
//            return layer.borderWidth
//        }
//        set {
//            layer.borderWidth = newValue
//        }
//    }
//
//    @IBInspectable
//    var borderColor: UIColor? {
//        get {
//            let color = UIColor(cgColor: layer.borderColor!)
//            return color
//        }
//        set {
//            layer.borderColor = newValue?.cgColor
//        }
//    }
    
    
    @IBInspectable var borderColor: UIColor? {
        set {
            layer.borderColor = newValue!.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    
    
}
