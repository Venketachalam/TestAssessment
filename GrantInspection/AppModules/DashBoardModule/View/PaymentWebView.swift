//
//  SearchContractorNameVC.swift
//  Progress
//
//  Created by Muhammad Akhtar on 11/20/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import NVActivityIndicatorView


class PaymentWebView: UIViewController, NVActivityIndicatorViewable  {
    
    
    @IBOutlet weak var attachmentName: UILabel!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var webInnerView: UIWebView!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var pageLbl: UILabel!
    
    var id : String!
    var imageArray: AttachmentModel = AttachmentModel()
    var model : AttachmentItemModel!
    var index : Int!
    var currentPage : Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        index  = imageArray.attachmentsPayload.index(where: { $0.id.description == id })!
        model = imageArray.attachmentsPayload[index]
        currentPage = index + 1
        pageLbl.text = String(format: "Page %@ of %@",imageArray.attachmentsPayload.count.description , currentPage.description)
        self.attachmentUrlApiCallWithId(_id:model.id.description)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func attachmentUrlApiCallWithId(_id: String){
        
        
        if(Common.isConnectedToNetwork() == true)
        {
            
            let service = AttachmentURLService()
            self.showActivityIndicator()
            
            service.getAttachmentURL(attachmentId: _id, completion: {(apiResponce:AttachmentURlResponse?) in
                
                self.stopAnimating()
                guard let responce = apiResponce else {
                    return
                }
                
                if responce.success {
                    
                    let urlStr = "\(responce.payload.viewAttachmentPayload.url)"
                    if let encoded = urlStr.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
                        let uRL = URL(string: encoded) {
                        
                        self.loadURLToView(url:uRL)
                        self.attachmentName.text = self.model.attachmentName
                        
                        //UIApplication.shared.open(uRL)
                    }
                    
                }else {
                    Common.showToaster(message: responce.message)
                }
            })
        }
        else{
            Common.showToaster(message: "no_Internet".ls)

        }
        
    }
    
    func loadURLToView(url:URL){
        
        let url = NSURL (string:url.description)
        var requestObj = URLRequest(url: url! as URL)
        requestObj.httpMethod = "POST"
        print("request object")
        print(requestObj)
        webInnerView.scalesPageToFit = true
        webInnerView.contentMode = .scaleAspectFit
        webInnerView.loadRequest(requestObj)
        mainView.addSubview(webInnerView)
    }
    
    @IBAction func closeBtnPressed(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func nextBtnPressed(_ sender: Any) {
        
        
        if index < imageArray.attachmentsPayload.count - 1 && index >= 0 {
            index = index + 1
            model = imageArray.attachmentsPayload[index]
            
            currentPage = index + 1
            pageLbl.text = String(format: "Page %@ of %@",imageArray.attachmentsPayload.count.description , currentPage.description)
            self.attachmentUrlApiCallWithId(_id:model.id.description)
        }
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        
        
        
        if index > 0 {
            
            index = index - 1
            model = imageArray.attachmentsPayload[index]
            currentPage = index + 1
            pageLbl.text = String(format: "Page %@ of %@",imageArray.attachmentsPayload.count.description , currentPage.description)
            self.attachmentUrlApiCallWithId(_id:model.id.description)
        }
    }
    
    
    func showActivityIndicator() {
        let size = CGSize(width: 70, height: 70)
        startAnimating(size, message: "",messageFont: nil, type: NVActivityIndicatorType.ballBeat, color: UIColor(red: 0/255, green: 97/255, blue: 158/255, alpha: 1.0),padding:10)
        
    }
    
}

