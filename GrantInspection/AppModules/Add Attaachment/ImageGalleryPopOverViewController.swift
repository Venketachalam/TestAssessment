//
//  ImageGalleryPopOverViewController.swift
//  GrantInspection
//
//  Created by Mohammed Hassan on 08/10/19.
//  Copyright © 2019 MBRHE. All rights reserved.
//

import UIKit
import AVFoundation

protocol PopoverDelegate:class {
    func takePhotoAction()
    func importPhotoFromLibraryAction() 
}
class ImageGalleryPopOverViewController: UIViewController {
    
    
    var delegatePopOver : PopoverDelegate?
    
    @IBOutlet weak var takePhotoBtn: UIButton!
    @IBOutlet weak var chooseFromLibraryBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        takePhotoBtn.setTitle("take_photo_btn".ls, for: .normal)
        chooseFromLibraryBtn.setTitle("choose_from_library_btn".ls, for: .normal)
        // Do any additional setup after loading the view.
    }
    
    
    
    
    
    //MARK: - UIButton Action

    @IBAction func choosePhotLibraryAction(_ sender: Any) {
        
            self.delegatePopOver?.importPhotoFromLibraryAction()
      
    }
    
    @IBAction func takePhotoAction(_ sender: Any) {
 
        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
            self.delegatePopOver?.takePhotoAction()
        } else {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                if granted {
                    self.delegatePopOver?.takePhotoAction()
                } else {
                    //access denied
                    
                    DispatchQueue.main.async {
                        self.presentCameraSettings()
                    }
                    
                    
                }
            })
        }
    }
    
    func presentCameraSettings() {
        let alertController = UIAlertController(title: "Error",
                                                message: "Camera access is denied",
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default))
        alertController.addAction(UIAlertAction(title: "Settings", style: .cancel) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: { _ in
                    // Handle
                })
            }
        })
        
        present(alertController, animated: true)
    }
    
}
