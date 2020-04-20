//
//  MapModelView.swift
//  Progress
//
//  Created by Muhammad Akhtar on 10/28/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps
import Alamofire
import RxSwift
import RxCocoa

class TripModelView: NSObject {
    
    static var isFirstRoute: Bool = true
    static var counter: Int = 0
    
    private var disposeBag = DisposeBag()
    
    static let trip = PublishSubject<TripModel>()
    
    
    
    override init() {
        super.init()
    }
    
    
    class  func setWaypointsArrayWith(currentLoc:CLLocation, projectsPayload: [Dashboard] ) -> [CLLocationCoordinate2D] {
    
        //let projectsPayload = SharedResources.sharedInstance.selectedTripContracts
        var positions  = [CLLocationCoordinate2D]()
        let coordinateSource: CLLocationCoordinate2D = currentLoc.coordinate
        positions.append(coordinateSource)
        for obj in projectsPayload {
            let latitude: Double = Double(obj.plot.latitude) ?? 0.0
            let longtitude: Double = Double(obj.plot.longitude) ?? 0.0
            let waypoint = CLLocationCoordinate2D(latitude: latitude, longitude: longtitude)
            positions.append(waypoint)
        }
 
    /* //For testing dummy locations
    var locationArray:[DummyLocationObject] = [DummyLocationObject]()
    let loc1  = DummyLocationObject.init(lat: "25.283739", lng: "55.406025")
    let loc2  = DummyLocationObject.init(lat: "25.221968", lng: "55.313265")
    let loc3  = DummyLocationObject.init(lat: "25.280743", lng: "55.336391")
    //let loc4  = DummyLocationObject.init(lat: "25.198854", lng: "55.519489")
    //let loc5  = DummyLocationObject.init(lat: "25.068690", lng: "55.167086")
    
    locationArray.append(loc1)
    locationArray.append(loc2)
    //locationArray.append(loc5)
    //locationArray.append(loc4)
    locationArray.append(loc3)
    
    
        var positions  = [CLLocationCoordinate2D]()
        let coordinateSource: CLLocationCoordinate2D = currentLoc.coordinate
        positions.append(coordinateSource)
        for obj in locationArray {
            //let latitude: Double = Double(obj.lat) ?? 0.0
            //let longtitude: Double = Double(obj.lng) ?? 0.0
            
           let latitude  = (obj.lat as NSString).doubleValue
           let longtitude  = (obj.lng as NSString).doubleValue
            
            let waypoint = CLLocationCoordinate2D(latitude: latitude, longitude: longtitude)
            positions.append(waypoint)
        }
    */
        return positions
        
    }
    
   class func getDotsToDrawRoute(positions : [CLLocationCoordinate2D], projectsArray: [Dashboard], completion: @escaping(_ path : GMSPath) -> Void) {
    
    var latLongsArray = positions
    
        if latLongsArray.count > 1 {
            let origin = latLongsArray.first
            let destination = latLongsArray.last
            var wayPoints = " "
    
            latLongsArray.removeFirst()
            latLongsArray.removeLast() //last should be no more in waypoints array because it is now destination
            
            for point in latLongsArray {
               // wayPoints = wayPoints.utf8CString.count == 0 ? "\(point.latitude),\(point.longitude)" : "\(wayPoints)|\(point.latitude),\(point.longitude)"
                if wayPoints == " " {
                   wayPoints =  "optimize:true|\(point.latitude),\(point.longitude)"
                } else {
                    wayPoints = "\(wayPoints)|\(point.latitude),\(point.longitude)"
                }
                
            }
            //for setting the waypoints url key we need to check if waypoints exists.
            if latLongsArray.count > 0 {
                wayPoints = "&waypoints=" + wayPoints
            }
            
//            for point in latLongsArray {
//                //wayPoints = wayPoints.utf8CString.count == 0 ? ""
//                if wayPoints == "" {
//                    wayPoints = "\(point.latitude),\(point.longitude)"
//                } else {
//                    wayPoints =  "\(wayPoints)\(point.latitude),\(point.longitude)"
//                }
//            }
//            print(wayPoints)
    
            
            
            let originLatDouble = origin?.latitude
            let originLongDouble = origin?.longitude
            
            let destiLatDouble = destination?.latitude
            let destiLongDouble = destination?.longitude
            
            let origin1 = "\(originLatDouble!.description),\(originLongDouble!.description)"
            let destination1 = "\(destiLatDouble!.description),\(destiLongDouble!.description)"
            
            
            let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin1)&destination=\(destination1)&mode=driving\(wayPoints)&key=\(Common.googleMapSDKKey)&mode=driving"
 
            // Alamofire.request(urlString, method:.get, parameters: nil).responseJSON(completionHandler: { response in
            
            //let request = "https://maps.googleapis.com/maps/api/directions/json"
            //let parameters : [String : String] = ["origin" : "\(origin!.latitude),\(origin!.longitude)", "destination" : "\(destination!.latitude),\(destination!.longitude)", "wayPoints" : wayPoints, "key":Common.googleMapSDKKey, "alternatives":"false", "mode":"driving"]
        
            let encodedUrl = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

            
            Alamofire.request(encodedUrl!, method:.get, parameters : nil).responseJSON(completionHandler: { response in
            
                guard let dictionary = response.result.value as? [String : AnyObject]
                    else {
                        return
                }
               isFirstRoute = true
                let status = dictionary["status"] as! String
                if status == "OK" {
                    if let routes = dictionary["routes"] as? [[String : AnyObject]] {
                        if routes.count > 0 {
                            var first = routes.first
                            if let legs = first!["legs"] as? [[String : AnyObject]] {
                                
                                let fullPath : GMSMutablePath = GMSMutablePath()
                                for leg in legs {
                                    var legTime = 0
                                    if let steps = leg["steps"] as? [[String : AnyObject]] {
                                        for step in steps {
                                            if let polyline = step["polyline"] as? [String : AnyObject] {
                                                if let points = polyline["points"] as? String {
                                                    fullPath.appendPath(path: GMSMutablePath(fromEncodedPath: points))
                                                }
                                            }
                                            
                                            if let duration = step["duration"] as? [String : AnyObject] {
                                                if let durationTime = duration["text"] as? String {
                                                    if let time = durationTime.components(separatedBy: " ").first {
                                                        legTime = legTime + Int(time)!
                                                    }
                                                    
                                                }
                                            }
                                            
                                        }
                                        completion(fullPath)
                                    }
                                    setRouteInfoWithLegTime(time: legTime, tripProjects: projectsArray)
                                    
                                }
                                counter = 0
                            }
                        }else {
                            print("No Routes result found...")
                            Common.appDelegate.window?.rootViewController?.presentMessage("No Routes result found...")
                        }
                    }
                } else {
                    guard let statusMsg = dictionary["error_message"] as? String else {
                        return
                    }
                    //print(statusMsg)
                    Common.appDelegate.window?.rootViewController?.presentMessage(statusMsg)
                }
                
                
                
            })
        }
    }
   static var tripStartDate = Date()
 
    class func setRouteInfoWithLegTime(time:Int, tripProjects: [Dashboard]) {
     
       let obj = TripModelView()
       let tripProjects = SharedResources.sharedInstance.selectedTripContracts
        let calendar = Calendar.current
        
        if tripProjects.count > 0 {
            if isFirstRoute {
                
                let currentDate = Date()
                
                let hh2 = (calendar.component(.hour, from: currentDate))
                let mm2 = (calendar.component(.minute, from: currentDate))
                let ss2 = (calendar.component(.second, from: currentDate))
                
                print(hh2,":", mm2,":", ss2)
                let timeStr = "\(hh2):\(mm2):\(ss2)"
                let strCurrentTime12H = convert24HTo12HFormate(strTime24H: timeStr)
             //   let currentLocationObj = TripModel(name: "Current Location", time: strCurrentTime12H, appNo: "CurrentLoc", PaymnetID: "CurrentLoc")
                
                let currentLocationObj = TripModel( time: strCurrentTime12H, appNo: 0 ,appId:0)
                
                SharedResources.sharedInstance.tripModelValue = currentLocationObj
                self.trip.onNext(currentLocationObj)
                
                
            
                tripStartDate = calendar.date(byAdding: .minute, value: time, to: currentDate)!
                let hhh2 = (calendar.component(.hour, from: tripStartDate))
                let mmm2 = (calendar.component(.minute, from: tripStartDate))
                let sss2 = (calendar.component(.second, from: tripStartDate))
                
                let firstWayPointTimeStr = "\(hhh2):\(mmm2):\(sss2)"
                let strTime12H = convert24HTo12HFormate(strTime24H: firstWayPointTimeStr)
                let obj = tripProjects[counter]
              //  let paymentId = String(stringLiteral: "\(obj.fileNo)")
              //  let firstWayPointObj = TripModel(name: obj.contractor.name, time: strTime12H, appNo: obj.applicationNo, PaymnetID: paymentId)
                let firstWayPointObj = TripModel(time: strTime12H, appNo: obj.applicationNo,appId:obj.applicantId)
                print("FirstappNo:",obj.applicationNo)
                print("Ftimetaken",strTime12H)
                SharedResources.sharedInstance.tripModelDict[obj.applicationNo.description] = strTime12H
                counter = counter + 1
                SharedResources.sharedInstance.tripModelValue = firstWayPointObj
                self.trip.onNext(firstWayPointObj)
                
                isFirstRoute = false
            } else {
                let date = calendar.date(byAdding: .minute, value: time, to: tripStartDate)
                let hh2 = (calendar.component(.hour, from: date!))
                let mm2 = (calendar.component(.minute, from: date!))
                let ss2 = (calendar.component(.second, from: date!))
                
                let wayPointTimeStr = "\(hh2):\(mm2):\(ss2)"
                let strTime12H = convert24HTo12HFormate(strTime24H: wayPointTimeStr)
                let obj = tripProjects[counter]
              //  let paymentId = String(stringLiteral: "\(obj.fileNo)")
                counter = counter + 1
              //  let wayPointObj = TripModel(name: obj.contractor.name, time: strTime12H, appNo: obj.applicationNo, PaymnetID: paymentId)
                let wayPointObj = TripModel( time: strTime12H, appNo: obj.applicationNo,appId:obj.applicantId)
                
                print("SecondappNo:",obj.applicationNo)
                print("Stimetaken",strTime12H)
                SharedResources.sharedInstance.tripModelDict[obj.applicationNo.description] = strTime12H
                SharedResources.sharedInstance.tripModelValue = wayPointObj
                self.trip.onNext(wayPointObj)
            }
        }
 
    }
    
    class func convert24HTo12HFormate(strTime24H:String) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        
        let date = dateFormatter.date(from: strTime24H)
        dateFormatter.dateFormat = "h:mm a"
        let Date12 = dateFormatter.string(from: date!)
        //print("12 hour formatted Date:",Date12)
        
        return Date12
    }

}

