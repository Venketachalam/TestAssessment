//
//  Localization.swift
//  iskan
//
//  Created by Hasnain Haider on 3/27/19.
//  Copyright © 2016 MRHE. All rights reserved.
//

import UIKit

@objc open class Localization: NSObject {
    
    static func ELS(_ key:String, table:String) -> String {
      
      let  languagesArray = UserDefaults.standard.value(forKey: "CurrentLanguages")
        
        if languagesArray == nil {
           
            let currentLanguageBundle = Bundle(path: Bundle.main.path(forResource: "en", ofType: "lproj")!)

            return NSLocalizedString(key , tableName: table, bundle: currentLanguageBundle!, value: "", comment: "")
          
        } else {
            
            let langAr = languagesArray as! NSArray
            
            let currentLanguageBundle = Bundle(path: Bundle.main.path(forResource: langAr[0] as? String, ofType: "lproj")!)
            
            return NSLocalizedString(key , tableName: table, bundle: currentLanguageBundle!, value: "", comment: "")
        }
        
    }
    
    static func ELS(_ key:String) -> String {
        return Localization.ELS(key, table: "Localizable")
    }
    
    
    static func currentLanguage() -> String {
        
        let  languagesArray = UserDefaults.standard.value(forKey: "CurrentLanguages")
        
        
        if languagesArray != nil
        {
            let langAr = languagesArray as! NSArray
            
            if langAr.count > 0
            {
                return (langAr[0] as? String)!
            }
            else
            {
                return "en"
            }
        }
        else
        {
            return  "ar" //"en"
        }
    }
    
    static func storeCurrentLanguage(_ languageString:String) {
        let userDefaults = UserDefaults.standard
      
      if languageString == "ar" {
            userDefaults.set(["ar","en"], forKey: "CurrentLanguages")
        } else {
            userDefaults.set(["en","ar"], forKey: "CurrentLanguages")
        }
        userDefaults.synchronize()
    }
  
}
