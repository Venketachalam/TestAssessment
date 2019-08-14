//
//  UIViewControllerExtension.swift
//  SlideMenuControllerSwift
//
//  Created by Yuji Hato on 1/19/15.
//  Copyright (c) 2015 Yuji Hato. All rights reserved.
//

import UIKit
import KRProgressHUD
import CoreData
extension UIViewController {
    func showLoader(){
         KRProgressHUD.show(withMessage: "Loading...")
        KRProgressHUD.set(activityIndicatorViewColors: [UIColor.red])
    }
    func hideLoader(){
        KRProgressHUD.dismiss {
            print("dismiss() completion handler.")
        }
    }
    func checkDataInCD(entityName:String,keyName:String) -> Array<Any> {
        var  temp = Array<Any>()
        
        do{
            //getting all datas from entity
            let request = self .setFetchReques(entityName: entityName)
            request.predicate = self .setPredicate(keyName: keyName, entityName:entityName)
            temp = try  self.getContext().fetch(request) as Array
            if temp .count == 0 {
                return temp
            }else{
                return temp
            }
            
        }catch{
            //            print("problem with fetching core data")
        }
        return temp
    }
    
    func getContext() -> NSManagedObjectContext {
        let context = (UIApplication .shared .delegate as! AppDelegate).persistentContainer.viewContext
        return context
    }
    func setFetchReques(entityName:String) -> NSFetchRequest<NSFetchRequestResult> {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName:entityName)
        request .returnsObjectsAsFaults = false
        return request
    }
    func setPredicate(keyName:String, entityName:String) -> NSPredicate {
        let resultPredicate = NSPredicate(format: "key = %@", keyName)
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        request.predicate = resultPredicate
        return resultPredicate
    }
    func deleteDataInCD(entityName : String, keyName: String) {
        do{
            let request = self .setFetchReques(entityName: entityName)
            request.predicate = self .setPredicate(keyName: keyName, entityName:entityName)
            let results = try self.getContext().fetch(request) as Array
            if results.count > 0{
                for result in results as! [NSManagedObject]{
                    if result.value(forKey: "data") != nil  {
                        self.getContext().delete(result)
                    }
                    do{
                        try self .getContext().save()
                    } catch{
                        //                        print("error deleting data from core data")
                    }
                }
            }
            
        } catch{
            //            print("no records found")
            
        }
    }
    func showNoDataFound(currentView:UIView,content:String,textColorType: UIColor){
        let noView = NoDataFound()
        noView.tag = 12345
        noView.translatesAutoresizingMaskIntoConstraints = false
        noView.showContent(msg: content, textColorTyp: textColorType)
        currentView .addSubview(noView)
        
        NSLayoutConstraint(item: noView, attribute: .centerX, relatedBy: .equal, toItem: currentView, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: noView, attribute: .centerY, relatedBy: .equal, toItem: currentView, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        
    }
    func removeNoviewTag(currentView:UIView){
        for view in currentView .subviews{
            if view.tag == 12345{
                view .removeFromSuperview()
            }
        }
    }
}
public extension UITableView {
    
    func registerCellClass(_ cellClass: AnyClass) {
        let identifier = String.className(cellClass)
        self.register(cellClass, forCellReuseIdentifier: identifier)
    }
    
    func registerCellNib(_ cellClass: AnyClass) {
        let identifier = String.className(cellClass)
        let nib = UINib(nibName: identifier, bundle: nil)
        self.register(nib, forCellReuseIdentifier: identifier)
    }
    
    func registerHeaderFooterViewClass(_ viewClass: AnyClass) {
        let identifier = String.className(viewClass)
        self.register(viewClass, forHeaderFooterViewReuseIdentifier: identifier)
    }
    
    func registerHeaderFooterViewNib(_ viewClass: AnyClass) {
        let identifier = String.className(viewClass)
        let nib = UINib(nibName: identifier, bundle: nil)
        self.register(nib, forHeaderFooterViewReuseIdentifier: identifier)
    }
    func removeSeparatorsOfEmptyCells() {
        tableFooterView = UIView(frame: .zero)
    }
    
    func removeSeparatorsOfEmptyCellsAndLastCell() {
        tableFooterView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 0, height: 1)))
    }
}
extension String {
    func attributedStringWithColor(_ strings: [String], color: UIColor, characterSpacing: UInt? = nil) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: self)
        for string in strings {
            let range = (self as NSString).range(of: string)
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        }
        
        guard let characterSpacing = characterSpacing else {return attributedString}
        
        attributedString.addAttribute(NSAttributedString.Key.kern, value: characterSpacing, range: NSRange(location: 0, length: attributedString.length))
        
        return attributedString
    }
}
