//
//  TripViewController.swift
//  Progress
//
//  Created by Muhammad Akhtar on 7/2/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire

class TripViewController: UIViewController {

    @IBOutlet weak var googleMapView: GMSMapView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        /*
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        self.googleMapView.camera = camera
        
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.map = self.googleMapView
        */
        
        drawRoute()
        let directionUrl = "https://www.google.com/maps/dir/?api=1&origin=Paris,France&destination=Cherbourg,France&travelmode=driving&waypoints=Versailles,France%7CChartres,France%7CLe+Mans,France%7CCaen,France&waypoint_place_ids=ChIJdUyx15R95kcRj85ZX8H8OAU%7CChIJKzGHdEgM5EcR_OBTT3nQoEA%7CChIJG2LvQNCI4kcRKXNoAsPi1Mc%7CChIJ06tnGbxCCkgRsfNjEQMwUsc"
        
        /*
        let sourceLat = 25.202217
        let sourceLong = 55.277306
        
        let destinationLat = 25.222151
        let destinationLong = 55.309750
        
        let sourceLoc = CLLocationCoordinate2D(latitude: sourceLat, longitude: sourceLong)
        let destinationLoc = CLLocationCoordinate2D(latitude: destinationLat, longitude: destinationLong)
        
        getPolylineRoute(from: sourceLoc, to: destinationLoc)
 */
    }
    @IBAction func btnBack_Tap(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func getPolylineRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D){
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(source.latitude),\(source.longitude)&destination=\(destination.latitude),\(destination.longitude)&sensor=true&mode=driving&key=\(Common.googleMapSDKKey)")!
        
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
                //self.activityIndicator.stopAnimating()
            }
            else {
                do {
                    if let json : [String:Any] = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]{
                        
                        guard let routes = json["routes"] as? NSArray else {
                            DispatchQueue.main.async {
                                //self.activityIndicator.stopAnimating()
                            }
                            return
                        }
                        
                        if (routes.count > 0) {
                            let overview_polyline = routes[0] as? NSDictionary
                            let dictPolyline = overview_polyline?["overview_polyline"] as? NSDictionary
                            
                            let points = dictPolyline?.object(forKey: "points") as? String
                            
                            self.showPath(polyStr: points!)
                            
                            DispatchQueue.main.async {
                                //self.activityIndicator.stopAnimating()
                                
                                let bounds = GMSCoordinateBounds(coordinate: source, coordinate: destination)
                                let update = GMSCameraUpdate.fit(bounds, with: UIEdgeInsets(top: 170, left: 30, bottom: 30, right: 30))
                                self.googleMapView!.moveCamera(update)
                            }
                        }
                        else {
                            DispatchQueue.main.async {
                                //self.activityIndicator.stopAnimating()
                            }
                        }
                    }
                }
                catch {
                    print("error in JSONSerialization")
                    DispatchQueue.main.async {
                        //self.activityIndicator.stopAnimating()
                    }
                }
            }
        })
        task.resume()
    }
    
    func showPath(polyStr :String){
        let path = GMSPath(fromEncodedPath: polyStr)
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 3.0
        polyline.strokeColor = UIColor.red
        polyline.map = self.googleMapView // Your map view
    }
    
    
    func drawRoute() {
        
        let sourceLat = 25.193794
        let sourceLong = 55.434671
        
        let destinationLat = 25.144389
        let destinationLong = 55.212541
        
        let sourceLoc = CLLocationCoordinate2D(latitude: sourceLat, longitude: sourceLong)
        let destinationLoc = CLLocationCoordinate2D(latitude: destinationLat, longitude: destinationLong)
        
        let waypointOne = CLLocationCoordinate2D(latitude: 25.260589, longitude: 55.331651)
//        let waypointTwo = CLLocationCoordinate2D(latitude: 25.256996, longitude: 55.329491)
//        let waypointThree = CLLocationCoordinate2D(latitude: 25.216488, longitude: 55.331267)
//        let  positions = [sourceLoc,waypointOne,waypointTwo,waypointThree,destinationLoc]
        
        let  positions = [sourceLoc,waypointOne,destinationLoc]
        
        getDotsToDrawRoute(positions: positions, completion: { path in
            //self.route.countRouteDistance(p: path)
            let polyline = GMSPolyline(path: path)
            polyline.path = path
            polyline.strokeColor = UIColor.red
            polyline.strokeWidth = 4.0
            polyline.map = self.googleMapView
        })
    }

    
    func getDotsToDrawRoute(positions : [CLLocationCoordinate2D], completion: @escaping(_ path : GMSPath) -> Void) {
        if positions.count > 1 {
            let origin = positions.first
            let destination = positions.last
            var wayPoints = ""
            for point in positions {
                wayPoints = wayPoints.utf8CString.count == 0 ? "\(point.latitude),\(point.longitude)" : "\(wayPoints)|\(point.latitude),\(point.longitude)"
            }
            let request = "https://maps.googleapis.com/maps/api/directions/json"
            let parameters : [String : String] = ["origin" : "\(origin!.latitude),\(origin!.longitude)", "destination" : "\(destination!.latitude),\(destination!.longitude)", "wayPoints" : wayPoints]
            Alamofire.request(request, method:.get, parameters : parameters).responseJSON(completionHandler: { response in
                guard let dictionary = response.result.value as? [String : AnyObject]
                    else {
                        return
                }
                if let routes = dictionary["routes"] as? [[String : AnyObject]] {
                    if routes.count > 0 {
                        var first = routes.first
                        if let legs = first!["legs"] as? [[String : AnyObject]] {
                            let fullPath : GMSMutablePath = GMSMutablePath()
                            for leg in legs {
                                if let steps = leg["steps"] as? [[String : AnyObject]] {
                                    for step in steps {
                                        if let polyline = step["polyline"] as? [String : AnyObject] {
                                            if let points = polyline["points"] as? String {
                                                fullPath.appendPath(path: GMSMutablePath(fromEncodedPath: points))
                                            }
                                        }
                                    }
                                    completion(fullPath)
                                }
                            }
                        }
                    }
                }
            })
        }
    }

    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension GMSMutablePath {
    
    func appendPath(path : GMSPath?) {
        if let path = path {
            for i in 0..<path.count() {
                self.add(path.coordinate(at: i))
            }
        }
    }
}
