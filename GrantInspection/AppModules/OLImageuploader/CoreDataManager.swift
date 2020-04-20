//
//  CoreDataManager.swift
//  PersistentTodoList
//
//  Created by Alok Upadhyay on 30/03/2018.
//  Copyright © 2017 Alok Upadhyay. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CoreDataManager {
  
  //1
  static let sharedManager = CoreDataManager()
  private init() {} // Prevent clients from creating another instance.
  
  //2
  lazy var persistentContainer: NSPersistentContainer = {
    
    let container = NSPersistentContainer(name: "OLImageUploader")
    
    
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
    return container
  }()
  
  //3
  func saveContext () {
    
    let context = CoreDataManager.sharedManager.persistentContainer.viewContext
    if context.hasChanges {
      do {
        try context.save()
      } catch {
        // Replace this implementation with code to handle the error appropriately.
        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        let nserror = error as NSError
        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
      }
    }
  }
  
  /*Insert*/
  func insert(model : OLDBModel )->Bool {
    
    /*1.
     Before you can save or retrieve anything from your Core Data store, you first need to get your hands on an NSManagedObjectContext. You can consider a managed object context as an in-memory “scratchpad” for working with managed objects.
     Think of saving a new managed object to Core Data as a two-step process: first, you insert a new managed object into a managed object context; then, after you’re happy with your shiny new managed object, you “commit” the changes in your managed object context to save it to disk.
     Xcode has already generated a managed object context as part of the new project’s template. Remember, this only happens if you check the Use Core Data checkbox at the beginning. This default managed object context lives as a property of the NSPersistentContainer in the application delegate. To access it, you first get a reference to the app delegate.
     */
    let managedContext = CoreDataManager.sharedManager.persistentContainer.viewContext
    
    /*
     An NSEntityDescription object is associated with a specific class instance
     Class
     NSEntityDescription
     A description of an entity in Core Data.
     
     Retrieving an Entity with a Given Name here person
     */
    let entity = NSEntityDescription.entity(forEntityName: "Attachments",
                                            in: managedContext)!
    
    
    /*
     Initializes a managed object and inserts it into the specified managed object context.
     
     init(entity: NSEntityDescription,
     insertInto context: NSManagedObjectContext?)
     */
    
    let modelEntity = NSManagedObject(entity: entity,
                                 insertInto: managedContext)
    
    /*
     With an NSManagedObject in hand, you set the name attribute using key-value coding. You must spell the KVC key (name in this case) exactly as it appears in your Data Model
     */
    modelEntity.setValue(model.token, forKeyPath: "token")
    modelEntity.setValue(model.paymentId, forKeyPath: "paymentId")
    modelEntity.setValue(model.contractId, forKeyPath: "contractId")
    modelEntity.setValue(model.filePath, forKeyPath: "filePath")
    modelEntity.setValue(model.fileName, forKeyPath: "fileName")
    modelEntity.setValue(model.latitude, forKeyPath: "latitude")
    modelEntity.setValue(model.longitude, forKeyPath: "longitude")
    modelEntity.setValue(model.status, forKeyPath: "status")
    modelEntity.setValue(model.percentage, forKeyPath: "percentage")
    
    
    /*
     You commit your changes to person and save to disk by calling save on the managed object context. Note save can throw an error, which is why you call it using the try keyword within a do-catch block. Finally, insert the new managed object into the people array so it shows up when the table view reloads.
     */
    do {
      try managedContext.save()
      return true
    } catch let error as NSError {
      print("Could not save. \(error), \(error.userInfo)")
      return false
    }
  }
  
  
  func update(token: String,percentage:Double,status:String)-> Bool {

    
    /*get reference of managed object context*/
    let managedContext = CoreDataManager.sharedManager.persistentContainer.viewContext
    
    /*init fetch request*/
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Attachments")
    
    /*pass your condition with NSPredicate. We only want to delete those records which match our condition*/
    fetchRequest.predicate = NSPredicate(format: "token == %@" ,token)
    
    do {
      
      /*managedContext.fetch(fetchRequest) will return array of person objects [personObjects]*/
      
      let item = try managedContext.fetch(fetchRequest)
      let managedObject = item[0]
      
      managedObject.setValue(percentage, forKey: "percentage")
      managedObject.setValue(status, forKey: "status")
      
      
      /*call delete method(aManagedObjectInstance)*/
      /*here i is managed object instance*/
      
      /*finally save the contexts*/
      try managedContext.save()
      
      return  true
      
    } catch let error as NSError {
      print("Could not fetch. \(error), \(error.userInfo)")
      return false
    }
    
  }
/*
  /*delete*/
  func delete(person : OLUploadFilesModel){
    
    let managedContext = CoreDataManager.sharedManager.persistentContainer.viewContext
    
    do {
      
      managedContext.delete(person)
      
    } catch {
      // Do something in response to error condition
      print(error)
    }
    
    do {
      try managedContext.save()
    } catch {
      // Do something in response to error condition
    }
  }
  */
  
  func fetch(status:String? = "all") -> [OLDBModel]?{
    
    
    /*Before you can do anything with Core Data, you need a managed object context. */
    let managedContext = CoreDataManager.sharedManager.persistentContainer.viewContext
    
    /*As the name suggests, NSFetchRequest is the class responsible for fetching from Core Data.
     
     Initializing a fetch request with init(entityName:), fetches all objects of a particular entity. This is what you do here to fetch all Person entities.
     */
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Attachments")
    
    /*You hand the fetch request over to the managed object context to do the heavy lifting. fetch(_:) returns an array of managed objects meeting the criteria specified by the fetch request.*/
    do {
     
      if status == "toDo"{
        fetchRequest.predicate = NSPredicate(format: "status == %@" ,status!)
      }
      
      let records = try managedContext.fetch(fetchRequest)
      
      var recordsArray : [OLDBModel] =  [OLDBModel]()
      
     
      for attachment in records {
        
        let record : OLDBModel = OLDBModel()
        record.token = attachment.value(forKey: "token") as! String
        record.contractId = attachment.value(forKey: "contractId") as! String
        record.paymentId = attachment.value(forKey: "paymentId") as! String
        record.fileName = attachment.value(forKey: "fileName") as! String
        record.filePath = attachment.value(forKey: "filePath") as! String
        record.longitude = attachment.value(forKey: "longitude") as! String
        record.latitude = attachment.value(forKey: "latitude") as! String
        record.status = attachment.value(forKey: "status") as! String
        record.percentage = attachment.value(forKey: "percentage") as! Double
        
        recordsArray.append(record)
      
      }

      return recordsArray
      
    } catch let error as NSError {
      print("Could not fetch. \(error), \(error.userInfo)")
      return nil
    }
  }

  
  
  func delete(token: String? = "" , clearAll : Bool? = false) -> Bool {
   
    /*get reference to appdelegate file*/
   
    /*get reference of managed object context*/
    let managedContext = CoreDataManager.sharedManager.persistentContainer.viewContext
    
    /*init fetch request*/
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Attachments")
    
    
    /*pass your condition with NSPredicate. We only want to delete those records which match our condition*/
    fetchRequest.predicate = NSPredicate(format: "token == %@" ,token!)
   
    if clearAll == true{
      fetchRequest.predicate = NSPredicate(format: "status == %@" ,"done")
    }
    
    do {
      
      /*managedContext.fetch(fetchRequest) will return array of person objects [personObjects]*/
     
      let item = try managedContext.fetch(fetchRequest)
      
      for i in item {
        
        /*call delete method(aManagedObjectInstance)*/
        /*here i is managed object instance*/
       
        managedContext.delete(i)
        
        /*finally save the contexts*/
        try managedContext.save()
        
    
      }
      return  true
      
    } catch let error as NSError {
      print("Could not fetch. \(error), \(error.userInfo)")
      return false
    }
    
  }
}
