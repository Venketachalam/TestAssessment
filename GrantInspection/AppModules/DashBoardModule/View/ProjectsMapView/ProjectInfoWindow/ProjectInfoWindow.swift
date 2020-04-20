//
//  ProjectInfoWindow.swift
//  Progress
//
//  Created by Muhammad Akhtar on 10/2/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import UIKit
import UICircularProgressRing

protocol MapMarkerDelegate: class {
    func didTapInfoButton(data: String)
}

class ProjectInfoWindow: UIView {
    
    //@IBOutlet weak var progressRing: UICircularProgressRingView!
    
    @IBOutlet weak var statusView: MBRHEBorderView!
    @IBOutlet weak var lblContractNumberTitle: UILabel!
    
    @IBOutlet weak var lblProjectId: UILabel!
    @IBOutlet weak var lblReportStatus: UILabel!
    
    @IBOutlet weak var callNowView:MBRHEBorderView!
    
    @IBOutlet weak var lblApplicationIdTitle: UILabel!
    @IBOutlet weak var lblApplicationIdValue: UILabel!
    
    @IBOutlet weak var lblCustomerTitle: UILabel!
    @IBOutlet weak var lblCustomerValue: UILabel!
    @IBOutlet weak var lblLandNoTitle: UILabel!
    @IBOutlet weak var lblLandValue: UILabel!
    @IBOutlet weak var lblAreaNameTitle: UILabel!
    @IBOutlet weak var lblAreaName: UILabel!
    @IBOutlet weak var lblServiceTypeTitle: UILabel!
    @IBOutlet weak var lblServiceType: UILabel!
    
    
    
    @IBOutlet weak var btnAddToTrip: UIButton!
    @IBOutlet weak var btnNotes: UIButton!
    @IBOutlet weak var btnAttachments: UIButton!
    @IBOutlet weak var btnMore: UIButton!
    @IBOutlet weak var btnNavigation: UIButton!
    @IBOutlet weak var btnBoq: UIButton!
    @IBOutlet weak var addToTripLbl: UILabel!
    
    weak var delegate: MapMarkerDelegate?
    var serviceType = [String]()
    
    @IBOutlet weak var addPlotNumberButton: UIButton!
    @IBOutlet weak var btnEditToTrip: UIButton!
    
    
    @IBOutlet weak var callNowBtn: MBRHERoundButtonView!
    @IBOutlet weak var callnowLbl: UILabel!
    @IBOutlet weak var addToTripImg: UIImageView!
    
    
    class func getProjectInfoWindow() -> ProjectInfoWindow
    {
        return Bundle.main.loadNibNamed("ProjectInfoWindow", owner: self, options: nil)![0] as! ProjectInfoWindow
        
    }
    
    //    class func instanceFromNib() -> UIView {
    //        return UINib(nibName: "ProjectInfoWindow", bundle: nil).instantiate(withOwner: self, options: nil).first as! UIView
    //    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        serviceType = ["serviceType_loan_lbl".ls,"serviceType_grant_lbl".ls]
        
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
        setupLayout()
        
    }
    
    func setupLayout()  {
        self.lblApplicationIdTitle.text = "applicant_Id".ls
        self.callnowLbl.text = "callnow_btn".ls
        self.lblCustomerTitle.text = "customer_name".ls
        self.lblLandNoTitle.text = "land_no".ls
        self.lblAreaNameTitle.text = "area_name".ls
        self.lblServiceTypeTitle.text = "service_type_lbl".ls
        self.lblReportStatus.text = "pay_request_status".ls
        self.addToTripLbl.text = "pay_add_to_trip".ls
        self.addPlotNumberButton.setTitle("add_btn".ls, for: .normal)
        self.btnEditToTrip.setTitle("edit_btn".ls, for: .normal)
    }
    
    @IBAction func didTapTripButton(_ sender: UIButton) {
        delegate?.didTapInfoButton(data: "buttonClick")
    }
    
    func setDataForMap(dashboardObj:Dashboard)  {
        
        
        self.lblContractNumberTitle.text = String(format: "%@ %@","application_ID".ls,dashboardObj.applicationNo)
        self.statusView.backgroundColor = Common.hexStringToUIColor(hex: dashboardObj.colorTag)
        
        if dashboardObj.reportStatus == "1" {
            self.lblReportStatus.text = "Completed_lbl".ls
            self.lblReportStatus.textColor = UIColor(red: 0/255, green: 195/255, blue: 179/255, alpha: 1.0)
        }else {
            self.lblReportStatus.text = "pay_request_status".ls
            self.lblReportStatus.textColor = UIColor(red: 255/255, green: 111/255, blue: 121/255, alpha: 1.0)
        }
        self.lblApplicationIdValue.text = dashboardObj.applicantId.description
        self.lblCustomerValue.text = dashboardObj.customerName
        self.lblLandValue.text =  dashboardObj.plot.landNo
        
        
        if dashboardObj.plot.longitude . isEmpty {
            self.addPlotNumberButton.isHidden = false
        }else {
            self.addPlotNumberButton.isHidden = true
        }
        
        if !dashboardObj.plot.landNo.isEmpty || !dashboardObj.plot.latitude.isEmpty  {
            self.btnEditToTrip.isHidden = false
            
        }else
        {
            self.btnEditToTrip.isHidden = true
            
        }
        
        
        if dashboardObj.applicantMobileNo.isEmpty
        {
            self.callNowView.isHidden = true
        }else
        {
            self.callNowView.isHidden = false
        }
        
        
        if Common.isProjectAddedIntoTripArrayWith(paymentId: dashboardObj.applicationNo) {
            setAddTripButtonColorAndImageForSelectedState()
        } else {
            setAddTripButtonColorAndImageForNormalState()
        }
        
        self.lblAreaName.text = dashboardObj.serviceRegion
        
        if (dashboardObj.serviceTypeId == "230")
        {
            self.lblServiceType.text = serviceType[0]
        }
        else if (dashboardObj.serviceTypeId == "210")
        {
            self.lblServiceType.text = serviceType[1]
        }
        else
        {
            self.lblServiceType.text = "-"
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
