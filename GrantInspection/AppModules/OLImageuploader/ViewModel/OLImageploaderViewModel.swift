//
//  MapModelView.swift
//  Progress
//
//  Created by Hasnain Haider on 5/11/19.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import UIKit
import Alamofire
import NotificationBannerSwift

protocol modelDelegate: class {
  func didFinishProcess()
}
  
class OLImageploaderViewModel : NSObject,uploadDelegate {
 
  
  var indexOfImage = 0
  var imageRawData : Data!
  var modelDelegate  : modelDelegate!
  var dataArray : [OLDBModel] = [OLDBModel]()
  var dbModel : OLDBModel! = nil

  func didStartProgress(_ status: Bool){

    if CoreDataManager.sharedManager.fetch(status: "toDo") != nil{
      
      dataArray = CoreDataManager.sharedManager.fetch(status: "toDo")!
     
      if dataArray.count > 0 {
        
        self.indexOfImage = dataArray.count
        self.convertToImageData(index: 0)
        
      }
    }
  }
  
  func convertToImageData(index:Int) {
  
    dbModel  = dataArray[index]
    let docDir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    
    let filePathFetch = docDir.appendingPathComponent(dbModel.fileName);
    if FileManager.default.fileExists(atPath: filePathFetch.path){
     
      if let image = UIImage(contentsOfFile: filePathFetch.path) {
       // imageRawData  = UIImageJPEGRepresentation(image, 0.1)!
        imageRawData = image.jpegData(compressionQuality: 0.1)
      }
    }
    
    self.uploadAttachments(imageData: imageRawData, dbModel: dbModel)
  }
  
  func uploadAttachments(imageData: Data, dbModel : OLDBModel){
    
    
    if(Common.isConnectedToNetwork() == false)
    {
      
    }else{
      
      let service = OLUploadAttachmentsService()
      service.deletgate = self
      let dataDict : [String : AnyObject]!
      let fileName  : String = "Attachment-" + Common.randomString(length: 5) + ".PNG"
      
      dataDict = [
        "paymentId" :  dbModel.paymentId,
        "contractId" : dbModel.contractId ,
        fileName : imageRawData,
        "latitude" :dbModel.latitude,
        "longitude":dbModel.longitude,
        "extension":"jpeg"
        ] as [String : AnyObject]
      

      service.uploadDocuments(attachmentId: "24", dataDict: dataDict, completion:{(baseResposne : OLUploadFilesModel?) in
        
        guard let response = baseResposne else {
          return
        }
        
        if response.success {
          
          self.syncDB(dbModel:dbModel)
          //Toast(text: response.message, duration: Delay.short).show()
        }else{
          if response.message.isEmpty{
            Common.showToaster(message: "error_InvalidJson".ls)
           
          }else {
            Common.showToaster(message: response.message)
          }
        }
        
      })
    }
  }
  
  func syncDB(dbModel : OLDBModel){
   
    
    if CoreDataManager.sharedManager.fetch(status: "toDo") != nil{
      
      if CoreDataManager.sharedManager.update(token: dbModel.token, percentage: 1, status: "done"){
        
        self.modelDelegate.didFinishProcess()
        
         dataArray = CoreDataManager.sharedManager.fetch(status: "toDo")!
        
          if dataArray.count > 0{
          
            self.convertToImageData(index: 0)
        }
      }
    }else {
      showNotification()
    }
  }
  
  func processPercentage(percentage: Double) {
    
    //if percentage == 1 {
      //if CoreDataManager.sharedManager.update(token: dbModel.token, percentage: dbModel.percentage, status: "toDo"){
     
        self.modelDelegate.didFinishProcess()
     
      
        print("percentage-completed",percentage)
      //}
   // }
  }
  
  
  func deleteRecord(token : String){
    
    if CoreDataManager.sharedManager.delete(token:token){
      self.modelDelegate.didFinishProcess()
      }
  }
  
  func clearAll(){
    if CoreDataManager.sharedManager.delete(clearAll: true){
      self.modelDelegate.didFinishProcess()
    }
  }
  
  func showNotification(){
    
    let rightView = UIImageView.init(image: UIImage(named: "ViewBTN.png"))
    let leftView = UIImageView.init(image: UIImage(named: "Notification_Icon.ong"))
    
    let banner = NotificationBanner(title: "uploading....".ls, subtitle: "your_Uploading_has_been_completed".ls, leftView: leftView, rightView: rightView, style: .success)
    banner.show()
    
    banner.onTap = {
      
    }
    
    banner.show()
  }
  

    
}


