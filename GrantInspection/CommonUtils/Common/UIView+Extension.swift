//  UIView+Extension.swift
//  Progress
//
//  Created by Muhammad Akhtar on 9/26/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

extension UIView  {
    
    func toArabicTransform(_ align : Bool? = true) -> Void
    {
        if !Common.currentLanguageArabic() {
            return
        }
        
        for subView in self.subviews {
            
            if let label = subView as? UILabel {
                if align == true {
                    label.textAlignment = .right
                }
                label.transform = Common.arabicTransform
            } else if let button = subView as? UIButton {
                
                button.transform = Common.arabicTransform
                
                if align == true {
                    if button.contentHorizontalAlignment == .right {
                        button.contentHorizontalAlignment = .left
                    } else if button.contentHorizontalAlignment == .left {
                        button.contentHorizontalAlignment = .right
                    }
                }
            } else if let imageView = subView as? UIImageView {
                if imageView.tag == 420 {
                    imageView.transform = Common.arabicTransform
                }
                
            }
            else if let textField = subView as? UITextField {
                if align == true {
                    textField.textAlignment = .right
                }
                textField.transform = Common.arabicTransform
            }
            else if let textView = subView as? UITextView
            {
                
                if align == true {
                    textView.textAlignment = .right
                }
                textView.transform = Common.arabicTransform
            } else if let scrollView = subView as? UIScrollView {
                scrollView.toArabicTransform(align)
            } else if let view = subView as? UIView {
                view.toArabicTransform(align)
            } else if let stackView = subView as? UIStackView {
                stackView.semanticContentAttribute = .forceRightToLeft
            }
        }
    }
    
    
    func toEnglishTransform(_ align : Bool? = true) -> Void
    {
        
        
        for subView in self.subviews {
            
            if let label = subView as? UILabel {
                if align == true {
                    label.textAlignment = .left
                }
                label.transform = Common.englishTransform
            } else if let button = subView as? UIButton {
                
                if align == true
                {
                    if button.contentHorizontalAlignment == .right
                    {
                        button.contentHorizontalAlignment = .left
                    } else if button.contentHorizontalAlignment == .left
                    {
                        button.contentHorizontalAlignment = .right
                    }
                    else if button.semanticContentAttribute == .forceRightToLeft {
                        button.semanticContentAttribute = .forceRightToLeft
                    }
                    else
                    {
                        button.semanticContentAttribute = .forceLeftToRight
                    }
                }
                button.transform = Common.englishTransform
                
            } else if let imageView = subView as? UIImageView {
                if imageView.tag == 420 {
                    imageView.transform = Common.englishTransform
                }
                
            }
            else if let textField = subView as? UITextField {
                if align == true {
                    textField.textAlignment = .left
                }
                textField.transform = Common.englishTransform
            }
            else if let textView = subView as? UITextView
            {
                
                if align == true {
                    textView.textAlignment = .right
                }
                textView.transform = Common.englishTransform
            } else if let scrollView = subView as? UIScrollView {
                scrollView.toEnglishTransform(align)
            } else if let view = subView as? UIView {
                view.toEnglishTransform(align)
            } else if let stackView = subView as? UIStackView {
                stackView.semanticContentAttribute = .forceLeftToRight
            }
        }
    }
    
    
    func createActivityIndicator(_ frameToShow : CGRect? = CGRect(x:0,y:0,width:50,height:50),activityTag : Int ) -> NVActivityIndicatorView
    {
        
        guard let activityIndicatorView : NVActivityIndicatorView = self.viewWithTag(activityTag) as? NVActivityIndicatorView
            else {
                let activityIndicatorView : NVActivityIndicatorView = NVActivityIndicatorView(frame: frameToShow!)
                activityIndicatorView.tag = activityTag
                
                activityIndicatorView.color = UIColor(red: 0/255, green: 97/255, blue: 158/255, alpha: 1.0)
                
                activityIndicatorView.type = NVActivityIndicatorType.ballBeat
                
                activityIndicatorView.startAnimating()
                
                return activityIndicatorView
                
        }
        
        activityIndicatorView.startAnimating()
        return activityIndicatorView
        
    }
    
    
    func removeActivityIndicator(_ activityTag: Int){
        
        print("ALl_subvws   ", self.subviews)
        
        guard let activityIndicatorView : NVActivityIndicatorView = self.viewWithTag(activityTag) as? NVActivityIndicatorView
            else {
                return
        }
        
        activityIndicatorView.stopAnimating()
        activityIndicatorView.removeFromSuperview()
        
    }
    
    
    func makeCircel() {
        self.layer.cornerRadius = self.frame.size.height / 2
        self.layer.masksToBounds = true
    }
    
    func applyStyle(color:[UIColor] = UIColor.lightGrayGradiend()) {
        
        if let sLayer = self.layer.sublayers {
            for glayer in sLayer where glayer.name == "gradient" {
                glayer.removeFromSuperlayer()
            }
        }
        
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.name = "gradient"
        gradientLayer.colors = color.map({$0.cgColor})
        gradientLayer.frame = self.bounds
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint (x: 0.5, y: 1)
        gradientLayer.cornerRadius = 5.0
        gradientLayer.masksToBounds = true
        self.layer.insertSublayer(gradientLayer, at: 0)
        
        borderWithCornerRadius()
        
    }
    
    func borderWithCornerRadius(cornerRadius:CGFloat = 5.0,color:UIColor = UIColor.appBorderColor()) {
        self.layer.cornerRadius = cornerRadius
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = 1.0
    }
    
    func borderWithCornerRadiusShadow(cornerRadius:CGFloat = 5.0) {
        borderWithCornerRadius(cornerRadius: cornerRadius, color: UIColor.appBorderColor())
        addShadowEffect()
    }
    
    func addShadowEffect() {
        removeShadow()
        self.layer.shadowColor = UIColor(red: 138/255, green: 138/255, blue: 138/255, alpha: 0.2).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowOpacity = 0.7
        self.layer.shadowRadius = 10.0
    }
    
    func removeShadow() {
        self.layer.shadowColor = UIColor.clear.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowOpacity = 0
        self.layer.shadowRadius = 0
    }
    
    
    
    
    func emptyDataView(message:String) {
        let noDataLabel = UILabel(frame: self.bounds)
        tag = 12345
        noDataLabel.text = message
        noDataLabel.textColor = UIColor.darkGray
        noDataLabel.textAlignment = .center
        noDataLabel.backgroundColor = UIColor.clear
        self.addSubview(noDataLabel)
        
    }
    
    func removeEmptyDataView() {
        for sView in self.subviews where sView.tag == 12345 {
            sView.removeFromSuperview()
        }
    }
    
    
    
}



extension UIButton {
    
    func appyStyleWithImage() {
        
        borderWithCornerRadiusShadow(cornerRadius: self.frame.size.height / 2)
        
        // let leftVal:CGFloat = self.frame.width - (imageView?.frame.maxX ?? 0.0)
        
        //imageEdgeInsets.left =  imageEdgeInsets.left + leftVal
    }
    
}
