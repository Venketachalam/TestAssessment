//
//  MRHEHeaderView.swift
//  Progress
//
//  Created by Muhammad Akhtar on 6/7/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import UIKit

class MRHEHeaderView: UIView {
 
  @IBOutlet weak var mrheLogo: UIImageView!
  @IBOutlet weak var dubaiLogo: UIImageView!
  
    override func awakeFromNib() {
        super.awakeFromNib()
    
   //   setLayout()
    }
    
  func setLayout() {
   
    if Common.currentLanguageArabic() {
        self.transform = Common.arabicTransform
        self.toArabicTransform()
//        mrheLogo.transform = Common.englishTransform
//        dubaiLogo.transform = Common.englishTransform

   }

  }
    
    class func getMRHEHeaderView() -> MRHEHeaderView
    {
        return Bundle.main.loadNibNamed("MRHEHeaderView", owner: self, options: nil)![0] as! MRHEHeaderView
        
    }

}
