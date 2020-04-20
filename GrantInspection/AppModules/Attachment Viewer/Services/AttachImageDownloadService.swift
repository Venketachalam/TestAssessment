//
//  AttachImageDownloadService.swift
//  GrantInspection
//
//  Created by Mohammed Hassan on 01/10/19.
//  Copyright © 2019 MBRHE. All rights reserved.
//

import UIKit
import Alamofire
//import

class AttachmentImageDownload: NSObject {
    
    open func downloadImageAttachment(attachmentUrlString:String, fromCollectionCell:Bool, compeletion:@escaping (_ image: UIImage) -> Void) {
        
        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
        
        if let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.path {
//            print("Documents Directory: \(documentsPath)")
        }
        

         let downloadQueue = DispatchQueue(label: "Images cache", qos: DispatchQoS.background)
        
        if fromCollectionCell == false
        {
            Common.showActivityIndicator()
        }
      
        
        Alamofire.request(attachmentUrlString, method: .get, parameters: nil, encoding:  URLEncoding.default, headers: SharedResources.sharedInstance.authorizedHeaders).downloadProgress(queue: DispatchQueue.global(qos: .background)) { (progress) in

                 print("Download progress: \(progress.fractionCompleted)")
        }.validate().response(completionHandler: { (responseData) in
                    //  downloadQueue.async(execute: { () -> Void in
                    do{


                        if let image = UIImage(data: responseData.data!) { compeletion(image)
                           if fromCollectionCell == false
                           {
                            DispatchQueue.main.async {
                                Common.hideActivityIndicator()
                            }
                           }
                        } else {

                            let imageA4: UIImage? = UIImage()
                            DispatchQueue.main.async { compeletion((imageA4)!)
                                Common.hideActivityIndicator()
                            }
                        }
                    }catch { print("Could not load URL: \(attachmentUrlString): \(error)") }
                   // }
               // })
            })
        
    }

}


