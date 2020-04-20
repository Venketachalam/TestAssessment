//
//  AttachmentCell.swift
//  Progress
//
//  Created by Muhammad Akhtar on 11/6/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ImagePicker
import Lightbox
import NVActivityIndicatorView

protocol forAttachmentPictureDelegate {
    
    func getSelectedPictureColumnRow(row: Int, column: Int)
}

class AttachmentCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var attachmentFileLabel: UILabel!
    @IBOutlet weak var countLbl: UILabel!
    @IBOutlet weak var imgViewArrow: UIImageView!
    @IBOutlet weak var viewLine: UIView!
    @IBOutlet weak var lblAttachmentTitle: UILabel!
    @IBOutlet weak var lblNoAttachment: UILabel!
  
    @IBOutlet weak var collectionView: UICollectionView!
    private let disposeBag = DisposeBag()
    let attachedItems = Variable<[AttachmentItemModel]>([])
    var indexOfImage = 0
    var selectedAttachmentObj: AttachmentModel = AttachmentModel()
    var paymentObj:Dashboard = Dashboard()
    var availableModalObj:Response! // .categoryModel
    
    var attachmentThumbnailDelegate : forAttachmentPictureDelegate?
    var currentSection:Int = 0
   
    @IBOutlet weak var attachmentCountLbl: UILabel!
    
    @IBOutlet weak var attachmentCollectionVw: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = UITableViewCell.SelectionStyle.none
        self.attachmentCollectionVw.register(UINib(nibName: "AttachmentItemCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        self.attachmentCollectionVw.delegate = self
        self.attachmentCollectionVw.dataSource = self
        
        //setCollectionView()
        self.countLbl.layer.cornerRadius  = self.countLbl.frame.size.width/2
        self.countLbl.layer.masksToBounds = true
        
        self.attachmentCountLbl.layer.cornerRadius  = self.attachmentCountLbl.frame.size.width/2
        self.attachmentCountLbl.layer.masksToBounds = true
        
        if Common.currentLanguageArabic() {
            self.attachmentCountLbl.transform = Common.arabicTransform
            self.attachmentCountLbl.toArabicTransform()
            self.attachmentFileLabel.transform = Common.arabicTransform
            self.attachmentFileLabel.toArabicTransform()

        }
        
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by:  UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0))
     
    }
    
    func setData(obj:AttachmentModel) {
       selectedAttachmentObj =  obj
        self.lblAttachmentTitle.text = obj.name
        if obj.attachmentsPayload.count > 0 {
            self.lblNoAttachment.isHidden = true
            self.imgViewArrow.isHidden = false
            attachedItems.value = obj.attachmentsPayload
            self.countLbl.text = obj.attachmentsPayload.count.description
            self.countLbl.backgroundColor = UIColor(red: 221/255, green: 101/255, blue: 101/255, alpha: 1.0)
            //self.isUserInteractionEnabled = true
        } else {
            self.countLbl.text = obj.attachmentsPayload.count.description
            self.countLbl.backgroundColor = UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 1.0)
            self.lblNoAttachment.isHidden = false
            self.imgViewArrow.isHidden = true
            //self.isUserInteractionEnabled = false
        }
    }
    
    func setData(obj:Response) {
        availableModalObj = obj
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

    
        return availableModalObj.contentCount
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell : AttachmentItemCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! AttachmentItemCell
        var documentNameAvailable : String
        if (availableModalObj.docName).isEmptyString()
        {
           // print("The attachemtn cell index:",indexPath.row)
            documentNameAvailable = "File_\(indexPath.row+1)"
        }
        else
        {
            documentNameAvailable = availableModalObj.docName
        }
        cell.lblAttachmentName.text = documentNameAvailable

        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let rowIs : Int = indexPath.item
        let columnIs : Int = (collectionView.superview?.superview!.tag)!
        
        attachmentThumbnailDelegate?.getSelectedPictureColumnRow(row: rowIs, column: columnIs)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: collectionView.frame.size.width / 8, height: collectionView.frame.size.width / 8)
    }
    
    func setCollectionView() {
        
        attachedItems.asObservable()
            .bind(to: attachmentCollectionVw.rx.items(cellIdentifier: "Cell")){
                (_, obj, cell) in
                if let cell = cell as? AttachmentItemCell {
                    cell.setDataWith(obj: obj)
                }
            }
            .disposed(by: disposeBag)
        
        attachmentCollectionVw.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        attachmentCollectionVw.rx
            .modelSelected(AttachmentItemModel.self)
            .subscribe(onNext:  { obj in
             
              
              let attachmentId = String(format:"\(obj.id)")
              self.openAttachmentView(iD:attachmentId ,attachmentName  : obj.attachmentName)
              
            })
            .disposed(by: disposeBag)
        
        
    }
    


  func openAttachmentView(iD : String , attachmentName : String){
 
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let controller = storyboard.instantiateViewController(withIdentifier: "PaymentWebView") as! PaymentWebView
    controller.id = iD
    controller.imageArray  = selectedAttachmentObj
    
    Common.appDelegate.window?.rootViewController?.present(controller, animated: false, completion: nil)
    
  }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
  
}
