//
//  BuildingDetailsCell.swift
//  GrantInspection
//
//  Created by Rajeswaran Thangaperumal on 29/08/2019.
//  Copyright © 2019 MBRHE. All rights reserved.
//

import UIKit

class BuildingDetailsCell: UITableViewCell {
    
    static var Identifier = "BuildingDetailsCell"
    
    @IBOutlet weak var buildingInteriorView: BuildingInteriorDetailsView!
    
    @IBOutlet weak var buildingExteriorView: BuildingExteriorDetailsView!
    
    @IBOutlet weak var buildingNameView: BuildingNameView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        buildingInteriorView.nextButton.addTarget(self, action: #selector(nextButtonAction(sender:)), for: .touchUpInside)
        buildingExteriorView.backButton.addTarget(self, action: #selector(backButtonAction(sender:)), for: .touchUpInside)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        buildingInteriorView.layer.cornerRadius = 10
        buildingInteriorView.clipsToBounds = true
        
        buildingExteriorView.layer.cornerRadius = 10
        buildingExteriorView.clipsToBounds = true
        
        buildingNameView.layer.cornerRadius = 10
        buildingNameView.clipsToBounds = true
    }
    
    @IBAction func nextButtonAction(sender: UIButton) {
        buildingExteriorView.isHidden = false
        buildingInteriorView.isHidden = true
        buildingNameView.isHidden = true
        reloadTableView()
        
    }
    @IBAction func backButtonAction(sender: UIButton) {
        //showBuildingInteriorView()
    }
    
    func showBuildingHeaderView(index:Int) {
        
        buildingExteriorView.isHidden = true
        buildingInteriorView.isHidden = true
        buildingNameView.isHidden = false
        if index == 0 {
            buildingNameView.headerLabel.isHidden = false
        } else {
            buildingNameView.headerLabel.isHidden = true
        }
       // reloadTableView()
    }
    
    func setBuildingDetails(report:InspectionReportRespose,faclities: UserFacility) {
        buildingInteriorView.setInterierBuildingViewData(data: faclities)
        buildingInteriorView.elementFacilities = faclities.facilityElementsList
        buildingExteriorView.setBuildingReportDetails(details: report)
        buildingNameView.buildingTitleLabel.text = faclities.buidingName()
        
    }
    func showBuildingInteriorView() {
        buildingExteriorView.isHidden = true
        buildingInteriorView.isHidden = false
        buildingNameView.isHidden = true
    }
    func showBuildingExteriorView() {
        buildingExteriorView.isHidden = false
        buildingInteriorView.isHidden = true
        buildingNameView.isHidden = true
        //reloadTableView()
    }
    
    func showCompletedReportView() {
        buildingExteriorView.isHidden = true
        buildingInteriorView.isHidden = true
        buildingNameView.isHidden = false
        let createDate = buildingInteriorView.report.inspectionReport.createdDate.serverDateFormatToNormal()
        buildingNameView.showSavedReportView(date: createDate)
    }
    
    func showBuildingNameView() {
        buildingExteriorView.isHidden = true
        buildingInteriorView.isHidden = true
        buildingNameView.isHidden = false
        buildingNameView.showEditReportView()
    }
    
    func reloadTableView() {
        
        if let sView = self.superview, sView is UITableView {
            if let tableView = sView as? UITableView {
                let indexPath = IndexPath(row: 0, section: 0)
                tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                tableView.reloadData()
                
            }
        }
    }
    
    func setFacilitiesData(data: FacilityResponsePayload,faclities: UserFacility) {
        buildingInteriorView.facilityPayload = data.facilityPayload
        buildingInteriorView.elementFacilities = faclities.facilityElementsList
        buildingInteriorView.addSelectionViewVaules()
        buildingInteriorView.addPickerValues()
        buildingExteriorView.reportDetails = data
        buildingExteriorView.setBuildingExteriorDetails(facilities: data)
    }
    
    func setFacilitiesData(data: FacilityResponsePayload) {
        buildingInteriorView.facilityPayload = data.facilityPayload
        buildingExteriorView.reportDetails = data
        buildingExteriorView.setBuildingExteriorDetails(facilities: data)
        buildingInteriorView.addSelectionViewVaules()
        buildingInteriorView.addPickerValues()
    }
    
    func getBuildingInterierViewData() -> UserFacility? {
        
        print(UserFacility())
        if let faclity = buildingInteriorView.postbuildingdetailsEntered().dataObject {
            return faclity.userFacility
        }else if let error = buildingInteriorView.postbuildingdetailsEntered().error {
            Common.showToaster(message: error)
        }
        return nil
    }
    
    func getBuildingExterierViewData() -> InspectionReport? {
        if let reportDetails = buildingExteriorView.exteriorBuildingDetailsPostData().dataObject {
            return reportDetails.inspectionReport
        }else if let error = buildingExteriorView.exteriorBuildingDetailsPostData().error {
            Common.showToaster(message: error)
        }
        return nil
    }
}


struct BuildingDetails {
    var name: String
    var completionDate: String
    var buildingType: String
    var buildingElement: String
    var buildingStatus: String
    var buildingService: String
    var buildingsSize: String
    var notes: String
    var houseStatus: String
    var apporimateSize: String
    var posibilityOfHorizontal: String
    var posibilityOfVertical: String
    var conclusion: String
    var recommendation: String
    
}

class SimplifiedReportMockData {
    static var shared = SimplifiedReportMockData()
    
    private var buildingData = [BuildingDetails]()
    
    func setData(data:BuildingDetails) {
        buildingData.append(data)
    }
    
    func getData() -> [BuildingDetails] {
        return buildingData
    }
}
