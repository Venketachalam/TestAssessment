//
//  AttachmentViewController.swift
//  GrantInspection
//
//  Created by Venketachalam Govindaraj on 07/10/19.
//  Copyright © 2019 MBRHE. All rights reserved.
//

import UIKit
import WebKit

class AttachmentViewController: UIViewController,WKNavigationDelegate,WKUIDelegate{

    @IBOutlet var webView: WKWebView!
    var guid:String = ""
    var index:Int = 0
    var  fileName:String = ""
    var noData : NoDataView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
         self.navigationItem.title = fileName
        if(Common.isConnectedToNetwork() == false){
            noDataAvailable(noInternet: true)
        }
        else{
       
     loadWebView(guid: guid, index: index)
        }
        // Do any additional setup after loading the view.
    }
    
    func loadWebView(guid:String,index:Int)
    {

        Common.showActivityIndicator()
        webView.uiDelegate = self
        webView.navigationDelegate = self
        
       if let anURL = URL(string:APICommunicationURLs.downloadAttachment(guid: guid, index: index))
       {
        
        var aRequest = URLRequest(url: anURL)
        aRequest.httpMethod = "POST"
        aRequest.setValue("bearer" + " " + SharedResources.sharedInstance.currentUser.access_token, forHTTPHeaderField: "Authorization")
        //        }
        DispatchQueue.main.async {
            self.webView.load(aRequest)
        }
        }
    }
    
    
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if let serverTrust = challenge.protectionSpace.serverTrust {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        }
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {

        Common.hideActivityIndicator()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false

        super.viewWillAppear(true)
      }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true

        super.viewWillDisappear(true)
        
    }
    
    func noDataAvailable(noInternet: Bool? = false){
        
        noData = NoDataView.getEmptyDataView()
        noData.frame = CGRect(x: 0, y:0, width: self.view.frame.size.width,  height:self.noData.frame.size.height)
        noData.backBtn.addTarget(self, action: #selector(refreshData), for: .touchUpInside)
        noData.setLayout(Yposition:140)
        self.view.addSubview(noData)
        
        if noInternet! {
            noData.setLayout(noNetwork:true)
            return
        }
    }
    
   
    @objc func refreshData(){
        
         noData.removeFromSuperview()
         if(Common.isConnectedToNetwork() == false){
        noDataAvailable(noInternet: true)
        }
        else
         {
            loadWebView(guid: guid, index: index)
        }
        }
   
}


