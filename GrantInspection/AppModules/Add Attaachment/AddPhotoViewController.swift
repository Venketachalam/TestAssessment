//
//  AddPhotoViewController.swift
//  GrantInspection
//
//  Created by Rajeswaran Thangaperumal on 16/09/2019.
//  Copyright © 2019 MBRHE. All rights reserved.
//

import UIKit
import AVFoundation
import RxSwift


enum imageTypeForUploading {
    case photoLibrary
    case camera
}

protocol PageRefreshDelegate {
    func refreshPage(currentCellTag:Int)
}

class AddPhotoViewController: UIViewController,AVCaptureVideoDataOutputSampleBufferDelegate {
    
    
    
    @IBOutlet weak var layeredStackView: UIStackView!
    @IBOutlet weak var imageViewForPreview: UIImageView!
    @IBOutlet weak var PhotoPreviewLayer: UIView!
    
    var captureSession = AVCaptureSession()
    var  previewLayer:CALayer!
    var captureDevice: AVCaptureDevice!
    private let disposeBag = DisposeBag()
    var takePhoto = false
    var imagePreviewView = ImagePreviewToSaveView()
    var imageCaptureFromCamera = UIImage()
    var rightBarButton: UIBarButtonItem!
    
    var attachmentModel = AttachmentUploadModel()
    var inspectionParms = InspectionReport()
    var userFaclityParms:[UserFacility]!
    var imageType:imageTypeForUploading!
    var imageSelectedFromPicker = UIImage()
    
    var delegate : PageRefreshDelegate?
    
    var currentTag:Int = 0
    
    var attachmentUploadRequestingToApi:AttachmentUploadModule!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        navigationBarSetup() // Set up navigation bar
        if imageType == .camera {
            setUpCameraPerview() // Set up Camera
        }else if imageType == .photoLibrary
        {
            let button = UIButton.init(type: .custom)
            button.addTarget(self, action: #selector(ImagePreviewToSaveAction), for: .touchUpInside)
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            imageView.image = UIImage(named: "save_icon_green")
            let label = UILabel(frame: CGRect(x: 35, y: 0, width: 50, height: 30))
            label.text = "save_btn".ls
            label.textColor = UIColor.white
            label.font = UIFont.systemFont(ofSize: 15)
            let buttonView = UIView(frame: CGRect(x: 0, y: 0, width: 90, height: 30))
            button.frame = buttonView.frame
            buttonView.addSubview(button)
            buttonView.addSubview(imageView)
            buttonView.addSubview(label)
            let barButton = UIBarButtonItem.init(customView: buttonView)
            self.navigationItem.rightBarButtonItem = barButton
            
            self.layeredStackView.isHidden = true
            self.imageViewForPreview.isHidden = false
            self.imageViewForPreview.image = imageSelectedFromPicker
        }
        
        attachmentUploadRequestingToApi = AttachmentUploadModule(AttachmentUploadService())
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    
    //    MARK: Setup Navigation Bar
    
    func navigationBarSetup() {
        
        navigationController?.navigationBar.barTintColor = UIColor(red: 75/255, green: 75/255, blue: 75/255, alpha: 1.0)
        navigationController?.navigationBar.tintColor = .white
        
        self.navigationItem.rightBarButtonItem = nil
        
        let backButton = UIBarButtonItem()
        backButton.title = "back_btn".ls
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
 
        setTitle("addPhoto_lbl".ls, andImage: #imageLiteral(resourceName: "cameraNavBar_icon"))
    }
    
    //    MARK: Setup Camera Preview
    
    func setUpCameraPerview()  {
        
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        
        if let availableDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back).devices.first {
            captureDevice = availableDevices
            beginSessionForCamera()
            
        }
        
    }
    
    func beginSessionForCamera()  {
        do{
            let captureInputDevice = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(captureInputDevice)
        }catch
        {
            print(error.localizedDescription)
        }
        
        let previewsLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        if let connection = previewsLayer.connection {
            
            self.previewLayer = previewsLayer
            
            self.PhotoPreviewLayer.layer.addSublayer(self.previewLayer)
            
            self.previewLayer.frame = self.PhotoPreviewLayer.bounds
            self.previewLayer.frame.size.width = self.view.frame.size.width
            
            let currentDevice: UIDevice = UIDevice.current
            let orientation: UIDeviceOrientation = currentDevice.orientation
            let previewLayerConnection : AVCaptureConnection = connection
            
            if (previewLayerConnection.isVideoOrientationSupported) {
                switch (orientation) {
                case .landscapeRight:
                    previewLayerConnection.videoOrientation = AVCaptureVideoOrientation.landscapeRight
                case .landscapeLeft:
                    previewLayerConnection.videoOrientation = AVCaptureVideoOrientation.landscapeRight
                default:
                    previewLayerConnection.videoOrientation = AVCaptureVideoOrientation.landscapeRight
                }
            }
        }
        
        
        captureSession.startRunning()
        
        let outputCaptureData = AVCaptureVideoDataOutput()
        outputCaptureData.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString):NSNumber(value: kCVPixelFormatType_32BGRA)] as [String : Any]
        outputCaptureData.alwaysDiscardsLateVideoFrames = true
        
        if captureSession.canAddOutput(outputCaptureData) {
            captureSession.addOutput(outputCaptureData)
        }
        
        captureSession.commitConfiguration()
        
        let queue = DispatchQueue(label: "Grant Inspection")
        outputCaptureData.setSampleBufferDelegate(self, queue: queue)
        
        
    }
    
    
    // MARK: AVFoundation sample Buffer Delegates
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        if takePhoto {
            takePhoto = false
            
            if let image = self.getImageFromTheSampleBuffer(buffer: sampleBuffer) {
                
                DispatchQueue.main.async {
                    self.layeredStackView.isHidden = true
                    self.imageViewForPreview.isHidden = false
                    self.imageViewForPreview.image = image
                    self.imageCaptureFromCamera = image  
                }
                
            }
        }
        
    }
    
    
    
    func getImageFromTheSampleBuffer(buffer:CMSampleBuffer) -> UIImage?  {
        if let imagePixelBuffer = CMSampleBufferGetImageBuffer(buffer)  {
            let ciImage = CIImage(cvPixelBuffer: imagePixelBuffer)
            let context = CIContext()
            
            let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(imagePixelBuffer), height: CVPixelBufferGetHeight(imagePixelBuffer))
            
            if let image = context.createCGImage(ciImage, from: imageRect){
                return UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: .up)
            }
            
            
        }
        return nil
    }
    
    //MARK: - UIButton Action
    @IBAction func ClickCameraButtonAction(_ sender: Any) {
        takePhoto = true
        
        let button = UIButton.init(type: .custom)
        button.addTarget(self, action: #selector(ImagePreviewToSaveAction), for: .touchUpInside)
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        imageView.image = UIImage(named: "save_icon_green")
        let label = UILabel(frame: CGRect(x: 35, y: 0, width: 50, height: 30))
        label.text = "save_btn".ls
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 15)
        let buttonView = UIView(frame: CGRect(x: 0, y: 0, width: 90, height: 30))
        button.frame = buttonView.frame
        buttonView.addSubview(button)
        buttonView.addSubview(imageView)
        buttonView.addSubview(label)
        let barButton = UIBarButtonItem.init(customView: buttonView)
        self.navigationItem.rightBarButtonItem = barButton
        
    }
    //    MARK: Camera Image Preview View and Its Actions
    
    @objc func ImagePreviewToSaveAction()  {
        
        imagePreviewView = UINib(nibName: "ImagePreviewToSaveView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ImagePreviewToSaveView
        
        var buildingName = userFaclityParms[currentTag].buidingName()
        
       
        
        if buildingName.isEmpty  {
            buildingName = "building_name_not_yet_assigned".ls
        }
        
        imagePreviewView.backButton.setTitle("back_btn".ls, for: .normal)
        imagePreviewView.saveButton.setTitle("save_btn".ls, for: .normal)
        imagePreviewView.buildingTitleLabel.text = "select_Building_lbl".ls
        imagePreviewView.commentTitleLabel.text = "add_Comment_lbl".ls

        imagePreviewView.backButton.addTarget(self, action: #selector(self.backButtonAction), for: .touchUpInside)
        imagePreviewView.saveButton.addTarget(self, action: #selector(self.saveButtonAction), for: .touchUpInside)
        
        imagePreviewView.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            
            self.imagePreviewView.frame = self.view.bounds
            self.imagePreviewView.alpha = 1
            self.navigationController?.view.addSubview(self.imagePreviewView)
            
            self.imagePreviewView.outerViewForImage.layer.cornerRadius = 15.0
            self.imagePreviewView.outerViewForImage.layer.masksToBounds = true
            
            self.imagePreviewView.commentTextBox.applyStyle()
            
            if self.imageType == .camera
            {
                self.imagePreviewView.imageFromPreview.image = self.imageCaptureFromCamera
            }else
            {
                self.imagePreviewView.imageFromPreview.image = self.imageSelectedFromPicker
            }
            self.imagePreviewView.imageFromPreview.contentMode = .scaleAspectFit
            
            self.imagePreviewView.buildingTypeLabel.text = buildingName
            
        }, completion: nil)
        
    }
    
    @objc func backButtonAction()  {
        
        UIView.animate(withDuration: 0.5, animations: {
            self.imagePreviewView.alpha = 0.0
        }) { (completion) in
            self.imagePreviewView .removeFromSuperview()
        }
        
    }
    
    @objc func saveButtonAction (){

        self.navigationItem.rightBarButtonItem = nil
                self.backButtonAction()
        
        let input = AttachmentUploadModel()
        
        if let imageData = imagePreviewView.imageFromPreview.image?.jpegImageCompressionFor(.low) {
            
            let bytesToMb = 2 * 1024 * 1024
            
            if Int64(imageData.count) > 5242880  {
                let imagesData = imagePreviewView.imageFromPreview.image?.jpegImageCompressionFor(.lowest)
                input.file = imagesData!
               
            }else
            {
                input.file = imageData
            }
            
        }
        
        
//        let byteCountFormatter = ByteCountFormatter()
//        byteCountFormatter.allowedUnits = [.useMB] // optional: restricts the units to MB only
//        byteCountFormatter.countStyle = .file
        
//        let string = byteCountFormatter.string(fromByteCount: Int64(imageData!.count))
//        print("formatted result: \(string)")
    
//        let bytesToMb = 5 * 1024 * 1024
        
//        print(bytesToMb)
      
//        if Int64(imageData!.count) > bytesToMb  {
//            Common.showToaster(message: "please_upload_the_image_size_below".ls)
//            return
//        }
        
        
        let attachmentTypeId = NSNumber(value: 1)
        
        let inspectionReportIdstring = inspectionParms.inspectionReportId

        let commenttrimmed = imagePreviewView.commentTextBox.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        input.facilityId = userFaclityParms[currentTag].facilityId
        input.remarks = commenttrimmed
        input.attachmentTypeId = attachmentTypeId
        
        if let inspectReportInt = Int(inspectionReportIdstring) {
            let inspectReportId = NSNumber(value:inspectReportInt)
            input.inspectionReportId = inspectReportId
        }
        
        
        
        if Common.isConnectedToNetwork() == true
        {

            
            Common.showActivityIndicator()
            attachmentUploadRequestingToApi.inputDataAttachments.attachmentsUploadedModel.onNext(input)
            attachmentUploadRequestingToApi.outputDataAttachments.attachmentUploadedResultObservable.subscribe { [weak self](response) in
                Common.hideActivityIndicator()
                

                if let value = response.element,value.success == true {
                    
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                        //print("enter")
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                          //print("enter RefreshPage")
                          self?.delegate?.refreshPage(currentCellTag: self!.currentTag)
                        }
                    }
                    UIView.animate(withDuration: 0.5, animations: {
                        self!.imagePreviewView.alpha = 0.0
                    }) { (completion) in
                        self!.imagePreviewView .removeFromSuperview()
                    }
                    Common.showToaster(message: "attachment_uploaded_successfully".ls )

                    self?.navigationController?.popViewController(animated: true)
                }

            }.disposed(by: disposeBag)
        }
        else{
            Common.showToaster(message: "no_Internet".ls )
        }
    }

}

// MARK: UIImage Extension for the image Quality

extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0.07
        case low     = 0.1
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }

    func jpegImageCompressionFor(_ jpegQuality: JPEGQuality) -> Data? {
        return jpegData(compressionQuality: jpegQuality.rawValue)
    }
}
