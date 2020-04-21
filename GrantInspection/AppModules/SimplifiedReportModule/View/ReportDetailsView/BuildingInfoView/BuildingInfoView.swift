//
//  BuildingInfoView.swift
//  GrantInspection
//
//  Created by Rajeswaran Thangaperumal on 03/09/2019.
//  Copyright © 2019 MBRHE. All rights reserved.
//

import UIKit

struct MockElementData {
    var image:UIImage
    var name: String
    var count: String
}

class BuildingInfoView: UIView {

    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var completionDateLabel: UILabel!
    
    @IBOutlet weak var buildingTypeLabel: UILabel!
    
    @IBOutlet weak var buildingSizeLabel: UILabel!
    
    @IBOutlet weak var structuralLabel: UILabel!
    
    @IBOutlet weak var serviceLabel: UILabel!
    
    @IBOutlet weak var notesLabel: UILabel!
    
    @IBOutlet weak var noOfPhotosLabel: UILabel!
    
    @IBOutlet weak var noOfSatellitePhotosLabel: UILabel!
    
    @IBOutlet weak var buildingNameLabel: UILabel!
    
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var buildingElementsLbl: UILabel!
    
    @IBOutlet weak var buildingStatusLbl: UILabel!
    var dataSource = [MockElementData]()
    
    var notedFacilities:UserFacility!
    
    var defaultFacilities:FacilityResponsePayload!
    
    var elementDataSource:[FacilityElementDetails]!
    
    var imageArray = [#imageLiteral(resourceName: "reception_icon"),#imageLiteral(resourceName: "livingroom_icon"),#imageLiteral(resourceName: "washroom_icon"),#imageLiteral(resourceName: "kictchen_icon"),#imageLiteral(resourceName: "bedroom_icon"),#imageLiteral(resourceName: "foodroom_icon"),#imageLiteral(resourceName: "bathroom_icon"),#imageLiteral(resourceName: "storeroom_icon"),#imageLiteral(resourceName: "maidroom_icon")]

    
    @IBOutlet weak var viewAttachedPhotosBtn: MBRHERoundButtonView!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setLayout(){
        
        if Common.currentLanguageArabic()
        {
            viewAttachedPhotosBtn.semanticContentAttribute = .forceRightToLeft
            viewAttachedPhotosBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        }
        else {
            viewAttachedPhotosBtn.semanticContentAttribute = .forceLeftToRight
            viewAttachedPhotosBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        }
    }
    
    private func setup() {
        Bundle.main.loadNibNamed("BuildingInfoView", owner: self, options: nil)
        contentView.translatesAutoresizingMaskIntoConstraints = true
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        self.addSubview(self.contentView)
        collectionViewSetup()
        setBuildingDatas()
        setMockData()
        setLayout()
    }
    
    func setMockData() {
        dataSource = [MockElementData(image: #imageLiteral(resourceName: "foodroom_icon"), name: "kitchen".ls, count: "01"),
                      MockElementData(image: #imageLiteral(resourceName: "bathroom_icon"), name: "bathroom".ls, count: "02"),
                      MockElementData(image: #imageLiteral(resourceName: "bedroom_icon"), name: "bedrooms".ls, count: "02"),
                      MockElementData(image: #imageLiteral(resourceName: "reception_icon"), name: "living_room".ls, count: "01"),
                      MockElementData(image: #imageLiteral(resourceName: "washroom_icon"), name: "washing_room".ls, count: "01"),
        MockElementData(image: #imageLiteral(resourceName: "storeroom_icon"), name: "store".ls, count: "01"),
        MockElementData(image: #imageLiteral(resourceName: "kictchen_icon"), name: "kitchen".ls, count: "01")]
        
    }
    
    func collectionViewSetup(){
        collectionView.register(UINib(nibName: "\(BuildingElementGridCell.self)", bundle: Bundle.main), forCellWithReuseIdentifier: BuildingElementGridCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func setBuildingDatas() {
        guard let sValue = notedFacilities else { return  }
        guard let defaultValues = defaultFacilities else { return  }
        let building = defaultValues.facilityPayload.facilityTypes.filter({$0.fTypeId == Int(sValue.facilityTypeId)}).first
        let service = defaultValues.facilityPayload.facilityConditions.filter({$0.fConditionId == Int(sValue.serviceStatusId)}).first
        let notes = defaultValues.facilityPayload.facilityActions.filter({$0.fActionId == Int(sValue.facilityActionId)}).first
        let buildingStatus = defaultValues.facilityPayload.facilityConditions.filter({$0.fConditionId == Int(sValue.buildingStatusId)}).first
        buildingNameLabel.text = sValue.buidingName()
        if sValue.approximateCompletionDate.count > 0 {
            
            let splitStringArray = sValue.approximateCompletionDate.components(separatedBy: "-")
            print(splitStringArray)
            
            let splitString = splitStringArray.last
            
          
            
            completionDateLabel.attributedText = "approximate_completion_date".ls.getAttributeString(color: .appBlueColor()).joinedString(string: " \(splitString ?? "")" .getAttributeString(color: .darkGray))
        }else
        {
            completionDateLabel.attributedText = "approximate_completion_date".ls.getAttributeString(color: .appBlueColor()).joinedString(string: "unknown_btn".ls.getAttributeString(color: .darkGray))
        }
       
        buildingTypeLabel.attributedText = "building_Type".ls.getAttributeString(color: .appBlueColor()).joinedString(string: " \((building?.facilityTypeName() ?? ""))".getAttributeString(color: .darkGray))
        buildingSizeLabel.attributedText = "building_Size".ls.getAttributeString(color: .appBlueColor()).joinedString(string: " \(sValue.buildingSizeSQF)".getAttributeString(color: .darkGray))
        structuralLabel.attributedText = "building_status".ls.getAttributeString(color: .appBlueColor()).joinedString(string: " \((buildingStatus?.conditionName() ?? ""))".getAttributeString(color: .darkGray))
        serviceLabel.attributedText = "services".ls.getAttributeString(color: .appBlueColor()).joinedString(string: " \((service?.conditionName() ?? ""))".getAttributeString(color: .darkGray))
        notesLabel.attributedText = "notes_lbl".ls.getAttributeString(color: .appBlueColor()).joinedString(string: " \((notes?.actionName() ?? ""))".getAttributeString(color: .darkGray))

        elementDataSource = notedFacilities.facilityElementsList
        
        print(elementDataSource)
        collectionView .reloadData()
        buildingElementsLbl.text = "building_elements".ls
        buildingStatusLbl.text = "building_status_lbl".ls
        editButton.setTitle("edit_btn".ls, for: .normal)
        viewAttachedPhotosBtn.setTitle("view_attached_photos".ls, for: .normal)

    }
    
    func setBuildingData(data:UserFacility,defaultValues:FacilityResponsePayload) {
       self.notedFacilities = data
       self.defaultFacilities = defaultValues
        
    }

    
}

extension BuildingInfoView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let data = elementDataSource else { return 0 }
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BuildingElementGridCell.identifier, for: indexPath) as? BuildingElementGridCell
        
        let myvalue = elementDataSource.sorted(by: {$0.facilityElementCountId < $1.facilityElementCountId })
        
        print("MY changeed Value \(myvalue)")
        let value = myvalue[indexPath.row]
        
        if (Int(value.facilityElementId) ?? 0) > 0 {
            cell?.imageView.image = imageArray[(Int(value.facilityElementId) ?? 0) - 1]
            let fName = self.defaultFacilities.facilityPayload.facilityElements.filter({$0.fElementId == (Int(value.facilityElementId) ?? 0)}).first!
            cell?.nameLabel.text =  fName.elementName()
            cell?.countLabel.text = value.facilityElementCount
        }else
        {
            print("okay")
        }
        
        return cell!
    }
    
    
}

extension BuildingInfoView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width / 5.5, height: collectionView.frame.size.width * 0.2)
        
    }
    
}
