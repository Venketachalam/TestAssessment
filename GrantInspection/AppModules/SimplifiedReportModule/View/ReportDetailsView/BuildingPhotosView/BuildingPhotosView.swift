//
//  BuildingPhotosView.swift
//  GrantInspection
//
//  Created by Rajeswaran Thangaperumal on 03/09/2019.
//  Copyright © 2019 MBRHE. All rights reserved.
//

import UIKit

class BuildingPhotosView: UIView {
    
    @IBOutlet weak var noAttachmentView: UIView!
    @IBOutlet weak var attachmentStackView: UIStackView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var rightArrowButton: UIButton!
    
    @IBOutlet weak var leftArrowButton: UIButton!
    
    @IBOutlet weak var imagePdfGenerate_Btn: MBRHERoundButtonView!
    
    @IBOutlet weak var photosLbl: UILabel!
    @IBOutlet weak var noPhotosAttachedLbl: UILabel!
    var photoThumbImgs = [UIImage]()
    var attachmentFaclitiesList:[FacilityAttachments]!
    var imageAttachmentList : [AttachmentViewResponseDetails]!

    var imageCache = NSCache<NSString, AnyObject>()
    var attachmentDownloaded = AttachmentImageDownload()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
//       NotificationCenter.default.addObserver(self, selector: #selector(self .methodOfReceivedNotificationFromReport(notification:)), name: Notification.Name("imageDeleteFromReport"), object: nil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
                setup()
        photosLbl.text = "photos".ls
                       noPhotosAttachedLbl.text = "no_photos_attached_lbl".ls
        
    }
 
    
    private func setup() {
        Bundle.main.loadNibNamed("BuildingPhotosView", owner: self, options: nil)
        contentView.translatesAutoresizingMaskIntoConstraints = true
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        self.addSubview(self.contentView)
        collectionViewSetup()
        setLayout()
        
        photoThumbImgs.append(UIImage(named: "Img1.png")!)
        photoThumbImgs.append(UIImage(named: "Img2.png")!)
        photoThumbImgs.append(UIImage(named: "Img3.png")!)
        photoThumbImgs.append(UIImage(named: "Img4.png")!)
        photoThumbImgs.append(UIImage(named: "Img5.png")!)
    }
    
    func setLayout(){
        
        if Common.currentLanguageArabic() {
            
            self.transform = Common.arabicTransform
            self.toArabicTransform()
        }
    }
    
    @IBAction func imagePdfBtn_Click(_ sender: Any) {
    

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.rightArrowButton.imageView?.changeTintColor(color: .darkGray)
        self.leftArrowButton.imageView?.changeTintColor(color: .darkGray)
       
    }
    func collectionViewSetup(){
        
        
       collectionView.register(UINib(nibName: "\(PhotosCollectionCell.self)", bundle: Bundle.main), forCellWithReuseIdentifier: PhotosCollectionCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
       
        
    }
    
    func collectionViewReload()  {
        collectionView.reloadData()
    }
    
    func setAttachmentViews(){
        
         if imageAttachmentList.count > 0 {
            self.attachmentStackView.isHidden = false
            self.noAttachmentView.isHidden = true
            collectionView .reloadData()
        }else
        {
            self.noAttachmentView.isHidden = false
            self.attachmentStackView.isHidden  = true
            self.noAttachmentView.layer.cornerRadius = 10.0
            self.noAttachmentView.layer.masksToBounds = true
            
            let lineBorder = CAShapeLayer()
            lineBorder.strokeColor = UIColor.lightGray.cgColor
            lineBorder.lineDashPattern = [3, 3]
            lineBorder.frame = self.noAttachmentView.bounds
            lineBorder.fillColor = nil
            lineBorder.path = UIBezierPath(rect: self.noAttachmentView.bounds).cgPath
            self.noAttachmentView.layer.addSublayer(lineBorder)
 
        }
    }
    
    //MARK: - UIButton Action

    @IBAction func leftArrowAction(sender: UIButton) {
        DispatchQueue.main.async {
            sender.imageView?.changeTintColor(color: .darkGray)
        }
        let collectionBounds = self.collectionView.bounds
        let contentOffset = CGFloat(floor(self.collectionView.contentOffset.x - collectionBounds.size.width))
        self.moveCollectionToFrame(contentOffset: contentOffset)
        
    }
    
    @IBAction func rightArrowAction(sender: UIButton) {
        DispatchQueue.main.async {
            sender.imageView?.changeTintColor(color: .darkGray)
        }
        
        let collectionBounds = self.collectionView.bounds
        let contentOffset = CGFloat(floor(self.collectionView.contentOffset.x + collectionBounds.size.width))
        self.moveCollectionToFrame(contentOffset: contentOffset)
        
    }
    
    func moveCollectionToFrame(contentOffset : CGFloat) {
        
        let frame: CGRect = CGRect(x : contentOffset ,y : self.collectionView.contentOffset.y ,width : self.collectionView.frame.width,height : self.collectionView.frame.height)
        self.collectionView.scrollRectToVisible(frame, animated: true)
    }

}

extension BuildingPhotosView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let data = imageAttachmentList else { return 0 }
        return data.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotosCollectionCell.identifier, for: indexPath) as? PhotosCollectionCell else { return UICollectionViewCell() }
//        let faclityAttachments = self.attachmentFaclitiesList[indexPath.item]
//
//        let attachmentIdString = faclityAttachments.attachmentId
//        let attachmentFaclityName = faclityAttachments.name
//
//        let attachmentName = "\(attachmentIdString)\(attachmentFaclityName)"
//        let appBaseURL = APICommunicationURLs.baseURL
//        let attachmentNameURLString = "\(appBaseURL)/img/\(attachmentName)"
        
        let imageAttachments = self.imageAttachmentList[indexPath.item]
        let currentimageUrl = imageAttachments.url
             let replacedUrlAttachmentString = currentimageUrl.replacingOccurrences(of: "'\'", with: "")
             
            cell.imageView.image = nil
             cell.imageView.layer.cornerRadius = 5.0
        
        print ("Image Url are at index:\(indexPath.item) is:",replacedUrlAttachmentString)
        cell.activityIndicator.startAnimating()
        cell.activityIndicator.isHidden = false
        if let imageFromCache = imageCache.object(forKey: replacedUrlAttachmentString as NSString) as? UIImage
        {
             DispatchQueue.main.async {
            cell.imageView.image = imageFromCache
            cell.activityIndicator.stopAnimating()
            cell.activityIndicator.isHidden = true
            }
        }else
        {
            attachmentDownloaded.downloadImageAttachment(attachmentUrlString: replacedUrlAttachmentString, fromCollectionCell: true) { (image) in
                
                let imageData = image.cgImage
                let ciImageDat = image.ciImage
                print("Image Data is:",imageData as Any)
                print("Image ciData is:",ciImageDat as Any)

                if (ciImageDat == nil && imageData == nil)
                {
                    DispatchQueue.main.async {
                                       cell.activityIndicator.isHidden = true
                                       cell.activityIndicator.stopAnimating()
                        
                        var noImage = UIImage()
                        
                        if Common.currentLanguageArabic()
                        {
                            noImage = UIImage(named: "No_image_Ar")!
                            cell.imageView.transform = Common.arabicTransform
                            cell.imageView.toArabicTransform()
                        }else
                        {
                            noImage = UIImage(named: "No_image_En")!
                        }
                        

                        cell.imageView.image = noImage
                        
                    }
                }
                else{
                    self.imageCache.setObject(image, forKey: replacedUrlAttachmentString as NSString)
                    DispatchQueue.main.async {
                        print("Entered image Upload")
                    cell.activityIndicator.isHidden = true
                    cell.activityIndicator.stopAnimating()
                    cell.imageView.image = image
                    }
                    
                }
            }
        }
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        print(self.attachmentFaclitiesList.count)
        
        let topVc = UIApplication.topViewController()
        guard let popVc = topVc?.storyboard?.instantiateViewController(withIdentifier: "SimplifiedReportPopController") as? SimplifiedReportPopController else { return }
        popVc.delegate =  self
        popVc.modalPresentationStyle = .overCurrentContext
        popVc.modalTransitionStyle = .crossDissolve
        popVc.type = .Photo
        popVc.totalPhotosCount = self.attachmentFaclitiesList.count
        popVc.imageAttachmentList = self.imageAttachmentList
        popVc.attachmentFaclitiesList = self.attachmentFaclitiesList
        popVc.imageInt = indexPath.row
        popVc.popupFrom = .OverAllImageList
        popVc.delegateForAttachmentOverAll = self
        topVc?.present(popVc, animated: true, completion: nil)
        
    }

}


extension BuildingPhotosView: AttachmentRefreshAction
{
    func refreshAttachmentFromOverAllList(imageIndex: Int) {
        
//        let attachmentDeleteImages = self.attachmentFaclitiesList[imageIndex]
//        print(attachmentDeleteImages)
//        let attachmentId = attachmentDeleteImages.attachmentId
//        self.attachmentFaclitiesList.remove(at: imageIndex)
        
        let attachmentDeleteImages = self.imageAttachmentList[imageIndex]
      print(attachmentDeleteImages)
    let attachmentId = attachmentDeleteImages.attachmentId
      self.imageAttachmentList.remove(at: imageIndex)
        
        self.collectionView.reloadData()
        
        NotificationCenter.default.post(name: Notification.Name("imageDeleteFromCollection"), object: nil, userInfo:["AttachmentID":attachmentId])
    }
 
}

extension BuildingPhotosView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width / 5.5, height: collectionView.frame.size.height * 1.0)
        
    }

}

extension BuildingPhotosView: PoupDelegate {
    func continueAction() {
        
    }
    
    
}


extension UIImageView {
    
    func changeTintColor(color: UIColor) {
        self.image = self.image?.withRenderingMode(.alwaysTemplate)
        self.tintColor = color
    }
}
