//
//  BuildingElementView.swift
//  GrantInspection
//
//  Created by Rajeswaran Thangaperumal on 29/08/2019.
//  Copyright © 2019 MBRHE. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

public struct ElementDataSet {
    var elementName:String?
    var elementCount:Int?
    var elementID: Int?
    var elementCountID:Int?
}
class BuildingElementView: UIView {
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var structClassFor = ElementDataSet()
    
    let helloSequence = Observable.of("Hello Rx")

    
    var mockDatasource = ["kitchen".ls,"bathroom".ls,"reception".ls,"living_room".ls,"store".ls,"washing_room".ls]
    var elementDataSource: [FacilityElements]!
    var selectedElements:[FacilityElementDetails]!
    var elementSetDataSource:[ElementDataSet]!
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.collectionView.reloadData()
        self.contentView.borderWithCornerRadius()
    }
    
    func setLayout(){
        
        if Common.currentLanguageArabic() {
            
            self.transform = Common.arabicTransform
            self.toArabicTransform()
        }
    }
    
    private func getCombineDataSource(defalutValue:[FacilityElements],selectedValue:[FacilityElementDetails]?) -> [ElementDataSet]{
        var combineValue = [ElementDataSet]()
        for data in defalutValue {
            var eCount = 0
            var eCountID = 0
            
            if let sValues = selectedValue {
                for sData in sValues where sData.facilityElementId == "\(data.fElementId)" {
                    eCount = Int(sData.facilityElementCount) ?? 0
                    eCountID = Int(sData.facilityElementCountId) ?? 0
                }
            }
            
            let value = ElementDataSet(elementName: data.elementName(), elementCount: eCount, elementID: data.fElementId,elementCountID:eCountID)
            print("Value is:",value)
            combineValue.append(value)
            
        }
        print ("Combine Value is:",combineValue)
        return combineValue
    }
    
    private func setup() {
        Bundle.main.loadNibNamed("BuildingElementView", owner: self, options: nil)
        contentView.translatesAutoresizingMaskIntoConstraints = true
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        self.addSubview(self.contentView)
        tableViewSetup()
        setLayout()
    }
    
    func tableViewSetup() {
        collectionView.register(UINib(nibName: "\(BuildingElementCell.self)", bundle: Bundle.main), forCellWithReuseIdentifier: BuildingElementCell.Identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func setDataSource(elements:[FacilityElements],existingData:[FacilityElementDetails]?) {
        self.elementDataSource = elements
        self.elementSetDataSource = getCombineDataSource(defalutValue: elements, selectedValue: existingData)
    }
    
    func getSelectedElements(facilityID:String) -> [FacilityElementDetails]  {

        var elementsArray = [FacilityElementDetails]()
        for element in elementSetDataSource {
            let data = FacilityElementDetails()
            data.facilityElementId = "\(element.elementID ?? 0)"
            data.facilityElementCount = "\(element.elementCount ?? 0)"
            data.facilityId = facilityID
            data.facilityElementCountId = "\(element.elementCountID ?? 0)"
            elementsArray.append(data)
        }
        return elementsArray
    }

}


extension BuildingElementView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let data = elementSetDataSource else { return mockDatasource.count }
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BuildingElementCell.Identifier, for: indexPath) as? BuildingElementCell else { return UICollectionViewCell() }
        cell.steeperView.delegate = self
        if let data = elementSetDataSource {
            let valueDetails = data[indexPath.row]
            cell.setValue(title: valueDetails.elementName ?? "", value: valueDetails.elementCount ?? 0)
            cell.steeperView.tag = valueDetails.elementID ?? 0
        } else {
             cell.setValue(title: mockDatasource[indexPath.row], value: 00)
        }
       
        cell.layoutIfNeeded()
        return cell
    }
}

extension BuildingElementView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width / 6, height: collectionView.frame.size.width * 0.11)
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return collectionView.frame.size.width * 0.1
    }
    
}

extension BuildingElementView: StepperSelectionDelegate {
    func valueChange(index: Int, value: Int) {
        guard let data = elementSetDataSource else { return  }
        let dataSourceIndex = data.firstIndex(where: {$0.elementID ?? 0 == index})
        elementSetDataSource?[dataSourceIndex ?? 0].elementCount = value
    }
}

class SelectionView : UIView {
    
    var stackView: UIStackView = {
        let stack = UIStackView()
        stack.distribution = .fillProportionally
        stack.axis = .horizontal
        stack.spacing = 5
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addConstraints()
    }
    
    private func setup() {
        self.addSubview(stackView)
        setLayout()
    }
    
    func setLayout() {
        if Common.currentLanguageArabic() {
            //self.transform = Common.arabicTransform
            //self.toArabicTransform()
        }
    }
    
    private func addConstraints() {
        self.stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        self.stackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
    func setSelectionData(titles:[String],selectedImage:UIImage,defaultImage:UIImage,curentSelctionIndex:Int) {
        for sView in self.stackView.arrangedSubviews {
            sView.removeFromSuperview()
        }
        for (index,title) in titles.enumerated() {
            
            let button = UIButton()
            button.titleLabel?.font = UIFont.appRegularFont(size: 11.0)
            button.setTitleColor(.darkGray, for: .normal)
            button.setTitle(title, for: .normal)
            button.titleLabel?.lineBreakMode = .byWordWrapping
            button.titleLabel?.numberOfLines = 2
            button.setImage(defaultImage, for: .normal)
            button.setImage(selectedImage, for: .selected)
            
            if Common.currentLanguageArabic() {
                button.titleLabel?.transform = Common.arabicTransform
                button.titleLabel?.toArabicTransform()
            }
            
            button.tag = index
            button.addTarget(self, action: #selector(selectionAction(sender:)), for: .touchUpInside)
            self.stackView.addArrangedSubview(button)
        }
    }
    
    func setSelectionData(titles:[String],curentSelctionIndex:Int) {
        for sView in self.stackView.arrangedSubviews {
            sView.removeFromSuperview()
        }
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        for (index,title) in titles.enumerated() {
            let button = UIButton()
            button.titleLabel?.font = UIFont.appRegularFont(size: 12.0)
            button.setTitleColor(.darkGray, for: .normal)
            button.setTitleColor(.white, for: .selected)
             button.setTitle(" " + title + " ", for: .normal)
            button.titleLabel?.lineBreakMode = .byWordWrapping
            button.titleLabel?.numberOfLines = 2
            if Common.currentLanguageArabic() {
                button.titleLabel?.transform = Common.arabicTransform
                button.titleLabel?.toArabicTransform()
            }
            button.tag = index
            button.addTarget(self, action: #selector(selectionAction(sender:)), for: .touchUpInside)
            
            
            self.stackView.addArrangedSubview(button)
        }
        
        DispatchQueue.main.async {
            for sView in self.stackView.arrangedSubviews {
                if let button = sView as? UIButton {
                    button.applyStyle()
                }
            }
        }
        
    }
    
    @IBAction func selectionAction(sender: UIButton) {
        guard let _ = sender.imageView?.image else {
            normalSelectionButton(sButton: sender)
            return
            
        }
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            for subView in stackView.arrangedSubviews {
                if let button = subView as? UIButton {
                    if button.tag != sender.tag {
                        button.isSelected = false
                    }
                }
            }
        }
    }
    
    func normalSelectionButton(sButton: UIButton) {
        
        for subView in stackView.arrangedSubviews {
            if let button = subView as? UIButton {
                if button.tag == sButton.tag {
                    button.isSelected = true
                    Common.userDefaults.setNotes(id: String(sButton.tag))
                    button.applyStyle(color: UIColor.blueGradient())
                } else {
                    button.isSelected = false
                    button.applyStyle()
                }
            }
            
        }
    }
}



protocol StepperDelegate {
    func pickerDateAction()
    func pickerValueAction()
}


class CustomImageButton: CustomStepper {
    
    public typealias Action = (_ isDate:Bool) -> Void
    
    fileprivate var action: Action?
    
    override func layoutSubviews() {
        addConstraints()
        self.applyStyle()
        decreaseButton.isUserInteractionEnabled = false
        increaseButton.isUserInteractionEnabled = false
        valueLabel.font = UIFont.appRegularFont(size: 14.0)
        valueLabel.textColor = .darkGray
    }
    
    func setButtonValue(rightImage:UIImage? = nil,leftImage:UIImage? = nil,value:String,isDatePicker:Bool = false,action:CustomImageButton.Action?) {
        
        if let right = rightImage {
            resetButton(button: increaseButton, image: right)
        }
        if let left = leftImage {
            addTapGesture(isDate: isDatePicker)
            resetButton(button: decreaseButton, image: left)
        }
        self.action = action
        self.valueLabel.text = value

    }
    
    func addTapGesture(isDate:Bool) {
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            self.stackView.isUserInteractionEnabled = true
           tap.name = isDate ? "Date" :"Normal"
            self.stackView.addGestureRecognizer(tap)
        
    }
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        
        if sender?.name == "Date" {
            self.action?(true)
            
        } else {
            self.action?(false)
        }
        
    }
    private func resetButton(button:UIButton,image:UIImage) {
        button.setImage(image, for: .normal)
        button.setTitle("", for: .normal)
    }
    
    
    private func addConstraints() {
        
        leftView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.2).isActive = true
        rightView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.2).isActive = true
        decreaseButton.leadingAnchor.constraint(equalTo: leftView.leadingAnchor).isActive = true
        decreaseButton.rightAnchor.constraint(equalTo: leftView.rightAnchor).isActive = true
        decreaseButton.heightAnchor.constraint(equalTo: leftView.heightAnchor, multiplier: 0.8).isActive = true
        decreaseButton.centerYAnchor.constraint(equalTo: leftView.centerYAnchor).isActive = true
        increaseButton.leadingAnchor.constraint(equalTo: rightView.leadingAnchor).isActive = true
        increaseButton.rightAnchor.constraint(equalTo: rightView.rightAnchor).isActive = true
        increaseButton.heightAnchor.constraint(equalTo: rightView.heightAnchor, multiplier: 0.8).isActive = true
        increaseButton.centerYAnchor.constraint(equalTo: rightView.centerYAnchor).isActive = true
        valueLabel.leadingAnchor.constraint(equalTo: centerView.leadingAnchor).isActive = true
        valueLabel.rightAnchor.constraint(equalTo: centerView.rightAnchor).isActive = true
        valueLabel.heightAnchor.constraint(equalTo: centerView.heightAnchor, multiplier: 0.8).isActive = true
        valueLabel.centerYAnchor.constraint(equalTo: centerView.centerYAnchor).isActive = true
        self.stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        self.stackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
    }
    
}



