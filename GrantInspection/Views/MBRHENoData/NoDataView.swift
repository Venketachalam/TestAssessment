//
//  NoDataView.swift
//  iskan
//
//  Created by Zeshan on 8/8/16.
//  Copyright © 2016 MRHE. All rights reserved.
//

import UIKit


class NoDataView: UIView {
  
  @IBOutlet weak var title: UILabel!
  @IBOutlet weak var centerView: UIView!
  @IBOutlet weak var icon: UIImageView!
  @IBOutlet weak var notAvailableText: UILabel!
  @IBOutlet weak var backBtn: UIButton!
  @IBOutlet weak var checkSettings: UIButton!
  @IBOutlet weak var Yposition: NSLayoutConstraint!
  
    class func getEmptyDataView() -> NoDataView
    {
        return (Bundle.main.loadNibNamed("NoDataView", owner: self, options: nil)![0] as? NoDataView)!
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.checkSettings.setTitle("check_your_wifi_settings_toast".ls, for: .normal)

    }
  
    func setLayout(title : String? = "", description : String? = "" , serverError : Bool = false ,noAttachmentAvailable:Bool = false,noResponseDataAvailable:Bool = false,noNetwork : Bool? = false , textToBold : String? = "",hideBack:Bool? = false , Yposition :CGFloat? = 15 ,icon :String? = ""){
        
        
        if Common.currentLanguageArabic() {
            self.title.transform = Common.arabicTransform
            self.title.toArabicTransform()
            self.notAvailableText.transform = Common.arabicTransform
            self.notAvailableText.toArabicTransform()
            self.backBtn.titleLabel?.transform = Common.arabicTransform
            self.backBtn.titleLabel?.toArabicTransform()
            self.checkSettings.titleLabel?.transform = Common.arabicTransform
            self.checkSettings.titleLabel?.toArabicTransform()
        }

    if noNetwork!{
      
        self.title.text = "no_internet_connection".ls
        self.notAvailableText.text = "not_connected".ls
        self.icon.image = UIImage(named:"NoInternetConnection")
        self.backBtn.setTitle("refresh_btn".ls, for: .normal)
        self.backBtn.isHidden=false
        self.checkSettings.isHidden = false
        
    }
    
    if serverError {
      
      self.title.text = "server_error".ls
      self.notAvailableText.text = "work_in_progress".ls
      self.icon.image = UIImage(named:"Servererror")
        self.backBtn.isHidden=false

        self.backBtn.setTitle("refresh_btn".ls, for: .normal)

      self.checkSettings.isHidden = true
    }
    
        if noAttachmentAvailable {
     
            self.title.text = "no_attachment_available".ls
            self.notAvailableText.text = "no_attachment_description".ls
            self.icon.image = UIImage(named:"NoAttachment")
             self.backBtn.setTitle("refresh_btn".ls, for: .normal)
            self.backBtn.isHidden=true
            self.checkSettings.isHidden = true
            

        }
        
        if noResponseDataAvailable {
            
            self.title.text = "no_data_Available".ls
            self.notAvailableText.text = "no_data_description".ls
            self.icon.image = UIImage(named:"NoData")
             self.backBtn.setTitle("refresh_btn".ls, for: .normal)
            self.backBtn.isHidden=true
            self.checkSettings.isHidden = true

        }
        
        
    
    if !(title?.isEmpty)! {
      self.title.text = title
    }
    
    if !(description?.isEmpty)! {
      self.notAvailableText.text = description
    }
    
    if Yposition != 15 {
      self.Yposition.constant = Yposition!
    }
    
    if !(icon?.isEmpty)!{
      self.icon.image = UIImage(named:icon!)
    }
    
    self.backBtn.isHidden = hideBack!
    self.checkSettings.addTarget(self, action: #selector(openSettings), for: .touchUpInside)
    
  }
  
    @IBAction func backBtnAction(_ sender: Any) {
        
        print("function sdgg")
        
    }
    @objc func openSettings(){
    
    if let url = URL(string:UIApplication.openSettingsURLString) {
      if UIApplication.shared.canOpenURL(url) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
      }
    }
  }
}
