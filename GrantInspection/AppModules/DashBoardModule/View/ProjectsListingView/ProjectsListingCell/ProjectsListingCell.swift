//
//  ProjectsListingCell.swift
//  Progress
//
//  Created by Muhammad Akhtar on 10/1/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//
  
import UIKit

class ProjectsListingCell: UICollectionViewCell {

  @IBOutlet weak var statusView: MBRHEBorderView!
  @IBOutlet weak var requestNoLbl: UILabel!
  @IBOutlet weak var requestStatusLbl: UILabel!
  @IBOutlet weak var addToTripLbl: UILabel!
 @IBOutlet weak var btnEditToTrip: MBRHERoundButtonView!

  
  @IBOutlet weak var lbl1: UILabel!
  @IBOutlet weak var val1: UILabel!
  @IBOutlet weak var lbl2: UILabel!
  @IBOutlet weak var val2: UILabel!
  @IBOutlet weak var lbl3: UILabel!
  @IBOutlet weak var val3: UILabel!
  @IBOutlet weak var lbl4: UILabel!
  @IBOutlet weak var val4: UILabel!
  @IBOutlet weak var lbl5: UILabel!
  @IBOutlet weak var val5: UILabel!
  
  
    @IBOutlet weak var addToTripImg: UIImageView!
    @IBOutlet weak var btnAddToTrip: MBRHERoundButtonView!
    @IBOutlet weak var btnNotes: UIButton!
    @IBOutlet weak var btnAttachments: UIButton!
    @IBOutlet weak var btnNavigation: UIButton!
    @IBOutlet weak var btnMore: UIButton!
    @IBOutlet weak var btnCell: UIButton!
    @IBOutlet weak var callNowBtn: MBRHERoundButtonView!
    @IBOutlet weak var addPlotNumberButton: UIButton!
    @IBOutlet weak var callnowLbl: UILabel!
    @IBOutlet weak var callNowBorderView:MBRHEBorderView!
    
    var serviceType = [String]()
    override func awakeFromNib() {
        super.awakeFromNib()
        serviceType = ["serviceType_loan_lbl".ls,"serviceType_grant_lbl".ls]
        setLayout()
      if Common.currentLanguageArabic() {
        self.transform = Common.arabicTransform
        self.toArabicTransform()
        self.btnEditToTrip.semanticContentAttribute = .forceLeftToRight
        self.btnEditToTrip.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5)
        
        addPlotNumberButton.semanticContentAttribute = .forceLeftToRight
        addPlotNumberButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5)
      }
        else
       {
         self.transform = Common.englishTransform
         self.toEnglishTransform()
        }
       
    }
  
    func setLayout(){
    
      self.lbl1.text = "applicant_Id".ls
      self.lbl2.text = "customer_name".ls
      self.lbl3.text = "land_no".ls
      self.lbl4.text = "area_name".ls
        self.lbl5.text = "service_type_lbl".ls
     // self.callNowBtn.setTitle("callnow_btn".ls, for:.normal)
        callnowLbl.text = "callnow_btn".ls
      self.requestStatusLbl.text = "pay_request_status".ls
      self.addToTripLbl.text = "pay_add_to_trip".ls
        self.addPlotNumberButton.setTitle("add_btn".ls, for: .normal)
        self.btnEditToTrip.setTitle("edit_btn".ls, for: .normal)
        
    }
  
    func setData(projectObj:Dashboard) {
      
      self.requestNoLbl.text = String(format: "%@ %@","application_ID".ls,projectObj.applicationNo)
      self.val1.text = projectObj.applicantId.description
      self.val2.text = projectObj.customerName
      self.val3.text =  projectObj.plot.landNo
      self.val4.text = projectObj.serviceRegion
        
      //self.val3.textAlignment = .left
     // self.val2.textAlignment = .left
     // self.val1.textAlignment =  .left
        
        if projectObj.plot.longitude . isEmpty {
           self.addPlotNumberButton.isHidden = false
        }else {
            self.addPlotNumberButton.isHidden = true
        }
        
        if !projectObj.plot.landNo.isEmpty || !projectObj.plot.latitude.isEmpty  {
            self.btnEditToTrip.isHidden = false
            
        }else
        {
            self.btnEditToTrip.isHidden = true

        }

        if projectObj.applicantMobileNo.isEmpty
        {
            self.callNowBorderView.isHidden = true
        }else
        {
            self.callNowBorderView.isHidden = false
        }
     
      if Common.isProjectAddedIntoTripArrayWith(paymentId: projectObj.applicationNo) {
            setAddTripButtonColorAndImageForSelectedState()
        } else {
            setAddTripButtonColorAndImageForNormalState()
        }
      
        self.statusView.backgroundColor = Common.hexStringToUIColor(hex: projectObj.colorTag)
        if (projectObj.serviceTypeId == "230")
        {
            self.val5.text = serviceType[0]
        }
        else if (projectObj.serviceTypeId == "210")
        {
            self.val5.text = serviceType[1]
        }
        else
        {
            self.val5.text = "-"
        }
    }

    func setAddTripButtonColorAndImageForSelectedState() {
        //self.btnAddToTrip.backgroundColor = UIColor.init(red: 231/255, green: 248/255, blue: 243/255, alpha: 1.0)
        self.addToTripLbl.text = "pay_added_to_trip".ls
        if Common.currentLanguageArabic()
        {
            self.addToTripImg.image = UIImage(named: "tripR_Check")
        }
        else
        {
            self.addToTripImg.image = UIImage(named: "trip_Check")
            
        }
        
        
        //self.btnAddToTrip.isUserInteractionEnabled = false
    }
    
    func setAddTripButtonColorAndImageForNormalState() {
       //x self.btnAddToTrip.backgroundColor = UIColor.init(red: 20/255, green: 193/255, blue: 139/255, alpha: 1.0)
        self.addToTripImg.image = UIImage(named: "Add_trip")
         self.addToTripLbl.text = "pay_add_to_trip".ls
        // self.btnAddToTrip.isUserInteractionEnabled = true
    }
    
}
