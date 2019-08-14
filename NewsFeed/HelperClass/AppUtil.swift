//
//  AppUtil.swift
//  Subclassing
//
//  Created by Dinesh Reddy.C on 11/11/16.
//  Copyright © 2016 Vishwak. All rights reserved.
//

import UIKit
import Alamofire
class AppUtil: NSObject {
    public let dateFormatter = DateFormatter()
    
    func getCurrentTimeZone() -> String{
        
        return String (TimeZone.current.identifier)
        
    }
    func convertDateFromCalendar(selectedDate : Date) -> String {
        dateFormatter.dateFormat = "yyyy/MM/dd"
        let convertedString = dateFormatter.string(from: selectedDate)
        
        let convertedDate = convertedString.components(separatedBy: " ")[0]
        let resultDate = dateFormatter.date(from: convertedDate)
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let result = dateFormatter.string(from: resultDate!)
//        print(result)
        return result
    }
    
    func convertStringToDate (inputDateString : String , dateFormat : String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = NSTimeZone(name: "IST")! as TimeZone
        let date = formatter.date(from: inputDateString)
        return date!
    }
    
    func convertDateToString (inputDate : Date, dateFormat : String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = NSTimeZone(name: "IST")! as TimeZone
        let dateString = formatter.string(from: inputDate)
        return dateString
    }

    func convertDateFormat(stringDate:NSString) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let resultDate = dateFormatter.date(from: stringDate as String)
        
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let result = dateFormatter.string(from: resultDate!)
        
        return result
    }
    public func removeDefaults(key : String){
        UserDefaults.standard.removeObject(forKey: key)
    }
    func saveValue(value:String, key : String){
        UserDefaults.standard.set(value, forKey: key )
    }
    func getValue(key : String) ->String{
        if UserDefaults.standard.value(forKey: key) != nil{
            return  UserDefaults.standard.value(forKey: key) as! String
        }
        return ""
    }
    public func currentInternetStatus() -> Bool{
        return NetworkReachabilityManager()!.isReachable
    }
    
   
   
    public func getAgeValues()->[String]{
        var values = [String]()
        for i in 21 ... 59{
            let value = String(i)
            values.append(value)
        }
         return values
    }
    public func getDocumentId(id : String)->String{
        switch id {
        case "1":
            return "1"
         case "2":
            return "2"
         case "3":
            return "3"
         case "4":
            return "4"
         case "5":
            return "5"
         default:
            return "1"
        }
    }
    public func validatePANCardNumber(_ strPANNumber : String) -> Bool{
//        let regularExpression = "[A-Z]{5}[0-9]{4}[A-Z]{1}"
//        let regularExpression = "[A-Z]{3}P[A-Z]{1}[0-9]{4}[A-Z]{1}"
        let regularExpression = "^[A-Z]{5}[0-9]{4}[A-Z]$"
        let panCardValidation = NSPredicate(format : "SELF MATCHES %@", regularExpression)
        return panCardValidation.evaluate(with: strPANNumber)
    }
    public func isValidYear(year : String) -> Bool{
        let regularExpression = "19\\d{2}|[2-9]\\d{3}"
        let panCardValidation = NSPredicate(format : "SELF MATCHES %@", regularExpression)
        return panCardValidation.evaluate(with: year)
    }
   
//    public func getNoDaysInMonth()->Int{
//        let dateComponents = DateComponents(year: getCurrentYear(), month: getCurrentMonth())
//        let calendar = Calendar.current
//        let date = calendar.date(from: dateComponents)!
//        
//        let range = calendar.range(of: .day, in: .month, for: date)!
//        let numDays = range.count
//        return numDays // 31
//    }
//    public func ageRangeCalculation(year : String) -> Bool{
//        if year == ""{
//            return false
//        }
//        let value = getCurrentYear() - year.toInt()!
//        if value >= 21 && value <= 60{
//            return true
//        }
//        return false
//    }
   
    public func restrictKeyBoard(sender : UITextField){
        if let last = sender.text?.last{
            if last == " "{
                sender.text?.removeLast()
            }else{
                let zero :Character = "0"
                let num : Int = Int(UnicodeScalar(String((last)))!.value - UnicodeScalar(String(zero))!.value)
                if num < 0 || num > 9{
                    sender.text?.removeLast()
                    return
                }
            }
        }
    }
    
    public func TitleOfMonthsOfDays()->[String]{
        let cal = Calendar.current
        var date = cal.startOfDay(for: Date())
        var months = [String]()
        var monthValue = ""
        for _ in 1 ... 3 {
            dateFormatter.dateFormat = "MMM"
            monthValue = dateFormatter.string(from: date)
            months.append(monthValue)
            date = cal.date(byAdding: .day, value: 1, to: date)!
        }
        return months
    }
    public func getTitleOfNext3days()->[String]{
        let cal = Calendar.current
        var date = cal.startOfDay(for: Date())
        var days = [String]()
        var dayString = ""
        for _ in 1 ... 3 {
            let day = cal.component(.day, from: date)
            let month = cal.component(.month, from: date)
            var value = String(day)
            dateFormatter.dateFormat = "EEE"
            dayString = dateFormatter.string(from: date)
            if value.count == 1{
                value = "0" + value
            }
            days.append(dayString + "\n " + value)
            date = cal.date(byAdding: .day, value: 1, to: date)!
        }
        return days
    }
    public func getCurrencyFormat(price : String)->String{
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.locale = Locale(identifier: "en_IN")
        var result = formatter.string(from: NSNumber(value: price.toInt()!))
//        result = Constants.priceUnicodeCharecter + result!
        return result!
    }
    public func getDateFormater(inputString : String)->String{
        var returenObj = inputString
        let values = inputString.components(separatedBy: " ")
        if values.count == 2{
            let temp = inputString.replacingOccurrences(of: ".0", with: "")
            
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let dateObj = dateFormatter.date(from: temp)
            if let date = dateObj{
                dateFormatter.dateFormat = "EEE,dd MMM yyyy hh:mm aa"
                returenObj = dateFormatter.string(from: date)
            }
        }else{
           dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateObj = dateFormatter.date(from: inputString)
            if let date = dateObj{
                dateFormatter.dateFormat = "EEE,dd MMM yyyy"
                returenObj = dateFormatter.string(from: date)
            }
        }
        return returenObj
    }
    public func buttonHideStatus()->(Bool,Bool,Bool,Bool,Bool,Bool,Bool,Bool,Bool,Bool,Bool,Bool){
        let calendar = Calendar.current
        let time=calendar.dateComponents([.hour], from: Date())
        print("\(time.hour!)")
        switch time.hour {
        case 7:
            return (true,true,true,true,true,true,true,true,true,true,true,true)
        case 8:
            return (false,true,true,true,true,true,true,true,true,true,true,true)
        case 9:
            return (false,false,true,true,true,true,true,true,true,true,true,true)
         case 10:
            return (false,false,false,true,true,true,true,true,true,true,true,true)
         case 11:
            return (false,false,false,false,true,true,true,true,true,true,true,true)
        case 12:
            return (false,false,false,false,false,true,true,true,true,true,true,true)
        case 13:
            return (false,false,false,false,false,false,true,true,true,true,true,true)
        case 14:
            return (false,false,false,false,false,false,false,true,true,true,true,true)
        case 15:
            return (false,false,false,false,false,false,false,true,true,true,true,true)
        case 16:
            return (false,false,false,false,false,false,false,false,true,true,true,true)
        case 17:
            return (false,false,false,false,false,false,false,false,false,true,true,true)
        case 18:
            return (false,false,false,false,false,false,false,false,false,false,true,true)
         case 19:
            return (false,false,false,false,false,false,false,false,false,false,false,true)
        default:
             return (true,true,true,true,true,true,true,true,true,true,true,true)
        }
     }
 }
