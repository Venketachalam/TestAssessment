//
//  BuildingSatelliteView.swift
//  GrantInspection
//
//  Created by Rajeswaran Thangaperumal on 03/09/2019.
//  Copyright © 2019 MBRHE. All rights reserved.
//

import UIKit
import GoogleMaps

class BuildingSatelliteView: UIView {
    
    
    @IBOutlet weak var editBtn: MBRHERoundButtonView!
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var noSatelliteImageview: UIView!
    @IBOutlet weak var gMapVw: UIView!
    
    @IBOutlet weak var zoomInOutView: UIView!
    
    @IBOutlet weak var zoomInButton: UIButton!
    @IBOutlet weak var zoomOutButton: UIButton!
     @IBOutlet weak var mapView: GMSMapView!
  
    var requestObject: Dashboard!
   
    
    @IBOutlet weak var satellitePhotoLbl: UILabel!
    @IBOutlet weak var noSatelliteImageLbl: UILabel!
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        localization()
    }
    func localization()
    {
        editBtn.setTitle("edit_btn".ls, for: .normal)
        satellitePhotoLbl.text = "satellite_photo_lbl".ls
        noSatelliteImageLbl.text = "no_satellite_image_lbl".ls
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
        localization()
    }
    
    private func setup() {
        
        
        Bundle.main.loadNibNamed("BuildingSatelliteView", owner: self, options: nil)
        contentView.translatesAutoresizingMaskIntoConstraints = true
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        self.addSubview(self.contentView)
        
        self.noSatelliteImageview.layer.cornerRadius = 10.0
        self.noSatelliteImageview.layer.masksToBounds = true
        
        let lineBorder = CAShapeLayer()
        lineBorder.strokeColor = UIColor.lightGray.cgColor
        lineBorder.lineDashPattern = [3, 3]
        lineBorder.frame = self.noSatelliteImageview.bounds
        lineBorder.fillColor = nil
        lineBorder.path = UIBezierPath(rect: self.noSatelliteImageview.bounds).cgPath
        
        self.noSatelliteImageview.isHidden = false
        
        self.zoomInOutView.layer.cornerRadius = 5.0
        self.zoomInOutView.layer.masksToBounds = true
        
        print("REQ_OJ      ", requestObject)
        
    }
    
    //MARK:- LOADING MAP VIEW
    
    
    func mapViewLoad(lat: Double, long: Double) {
        
        mapView.alpha = 1.0
        let latVal : CLLocationDegrees = lat
        let longVal : CLLocationDegrees = long
        
        let hydeParkLocation = CLLocationCoordinate2D(latitude: latVal , longitude: longVal)
        
        let camera = GMSCameraPosition.camera(withTarget: hydeParkLocation, zoom: 18)
    
        mapView.camera = camera
        mapView.isMyLocationEnabled = false
        mapView.settings.myLocationButton = false
        mapView.isUserInteractionEnabled = false
        mapView.settings.zoomGestures = false
        
        mapView.borderWithCornerRadius()
        mapView.mapType = .satellite
        
    }
  
  
  //MARK: - UIButton Action

  @IBAction func zoomOut(_ sender: AnyObject) {
    guard let mapView = self.mapView
      else {
        print("Set mapView variable")
        return
    }
    let zoomOutValue = mapView.camera.zoom - 1.0
    mapView.animate(toZoom: zoomOutValue)
  }
  
  @IBAction func zoomIn(_ sender: AnyObject) {
    
    guard let mapView = self.mapView
      else {
        print("Set mapView variable")
        return
    }
    
    let zoomInValue = mapView.camera.zoom + 1.0
    print ("Zoom value is:",zoomInValue)
    mapView.animate(toZoom: zoomInValue)
    
  }
  
  
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.noSatelliteImageview.borderWithCornerRadius()
        
    }
    
    func getValue(satellitePayload: SatelliteResponsePayload, reqObj: Dashboard) {
        
        print("Pass_Obj   ", reqObj)
        print("PayLD_Obj   ", satellitePayload)
        
        if satellitePayload.plotCoordinate == "" || satellitePayload.polygons.polygonTAG == "" || reqObj.plot.latitude == "" {
            
            mapView.isHidden = true
            noSatelliteImageview.isHidden = false
            zoomInOutView.isHidden = true
            return
            
        }
       
        mapView.isHidden = false
        zoomInOutView.isHidden = false
        mapView.clear()
        let plotCoordinateString = satellitePayload.polygons.polygonPoint.topRight

        if plotCoordinateString.count > 0
        {

            let polyTopRightLatLongs = plotCoordinateString.split(separator: ",")
                   let secondSideLatLongs = CLLocationCoordinate2D(latitude: CLLocationDegrees(Double(polyTopRightLatLongs[0])!), longitude: CLLocationDegrees(Double(polyTopRightLatLongs[1])!))
                   
                   let polyBottomLeftLatLongs = satellitePayload.polygons.polygonPoint.bottomLeft.split(separator: ",")
                   let fourthSideLatLongs = CLLocationCoordinate2D(latitude: CLLocationDegrees(Double(polyBottomLeftLatLongs[0])!), longitude: CLLocationDegrees(Double(polyBottomLeftLatLongs[1])!))

                   let centerMidPointLats = (secondSideLatLongs.latitude + fourthSideLatLongs.latitude) / 2
                   let centerMidPointLongs = (secondSideLatLongs.longitude + fourthSideLatLongs.longitude) / 2
                   let positions = CLLocationCoordinate2D(latitude: centerMidPointLats, longitude: centerMidPointLongs)
                   
                    print("Centre position is:",positions)
                   
                   mapViewLoad(lat: positions.latitude, long: positions.longitude)
            
            
        }else
        {
            mapViewLoad(lat: Double(reqObj.plot.latitude)!, long: Double(reqObj.plot.longitude)!)
        }
        
        self.noSatelliteImageview.isHidden = true
        
        if satellitePayload.imageType == 0
        {
            mapView.mapType = .normal
        }else if satellitePayload.imageType == 1
        {
            mapView.mapType = .hybrid
        }else if satellitePayload.imageType == 2
        {
            mapView.mapType = .satellite
        }
        
        let polyTopLeftLatLong = satellitePayload.polygons.polygonPoint.topLeft.split(separator: ",")
        let firstSideLatLong = CLLocationCoordinate2D(latitude: CLLocationDegrees(Double(polyTopLeftLatLong[0])!), longitude: CLLocationDegrees(Double(polyTopLeftLatLong[1])!))
        
        let polyTopRightLatLong = satellitePayload.polygons.polygonPoint.topRight.split(separator: ",")
        let secondSideLatLong = CLLocationCoordinate2D(latitude: CLLocationDegrees(Double(polyTopRightLatLong[0])!), longitude: CLLocationDegrees(Double(polyTopRightLatLong[1])!))
        
        let polyBottomRightLatLong = satellitePayload.polygons.polygonPoint.bottomRight.split(separator: ",")
        let thirdSideLatLong = CLLocationCoordinate2D(latitude: CLLocationDegrees(Double(polyBottomRightLatLong[0])!), longitude: CLLocationDegrees(Double(polyBottomRightLatLong[1])!))
        
        let polyBottomLeftLatLong = satellitePayload.polygons.polygonPoint.bottomLeft.split(separator: ",")
        let fourthSideLatLong = CLLocationCoordinate2D(latitude: CLLocationDegrees(Double(polyBottomLeftLatLong[0])!), longitude: CLLocationDegrees(Double(polyBottomLeftLatLong[1])!))

        print("Polygon value is:",polyTopLeftLatLong)

               
        let centerMidPointLat = (secondSideLatLong.latitude + fourthSideLatLong.latitude) / 2
        let centerMidPointLong = (secondSideLatLong.longitude + fourthSideLatLong.longitude) / 2
        let position = CLLocationCoordinate2D(latitude: centerMidPointLat, longitude: centerMidPointLong)
        
         print("Centre position is:",position)

        let finalPath = GMSMutablePath()
        finalPath.add(firstSideLatLong)
        finalPath.add(secondSideLatLong)
        finalPath.add(thirdSideLatLong)
        finalPath.add(fourthSideLatLong)
        finalPath.add(firstSideLatLong)
        
        
        let finalPolyLine = GMSPolyline(path: finalPath)
        finalPolyLine.map = nil
        finalPolyLine.map = mapView
        finalPolyLine.strokeColor = UIColor.orange
        finalPolyLine.strokeWidth = 4
        
        if satellitePayload.buildingPoints.count > 0 {
            
            for buidingPoint in satellitePayload.buildingPoints {
                
                let polyTopLeftLatLong = buidingPoint.topLeft.split(separator: ",")
                let firstSideLatLong = CLLocationCoordinate2D(latitude: CLLocationDegrees(Double(polyTopLeftLatLong[0])!), longitude: CLLocationDegrees(Double(polyTopLeftLatLong[1])!))
                
                let polyTopRightLatLong = buidingPoint.topRight.split(separator: ",")
                let secondSideLatLong = CLLocationCoordinate2D(latitude: CLLocationDegrees(Double(polyTopRightLatLong[0])!), longitude: CLLocationDegrees(Double(polyTopRightLatLong[1])!))
                
                let polyBottomRightLatLong = buidingPoint.bottomRight.split(separator: ",")
                let thirdSideLatLong = CLLocationCoordinate2D(latitude: CLLocationDegrees(Double(polyBottomRightLatLong[0])!), longitude: CLLocationDegrees(Double(polyBottomRightLatLong[1])!))
                
                let polyBottomLeftLatLong = buidingPoint.bottomLeft.split(separator: ",")
                let fourthSideLatLong = CLLocationCoordinate2D(latitude: CLLocationDegrees(Double(polyBottomLeftLatLong[0])!), longitude: CLLocationDegrees(Double(polyBottomLeftLatLong[1])!))
                
                 let buildingName = buidingPoint.buildingName
            
                
                if (!buildingName.isEmpty)
                {
               
                let secondmidPointLat = (secondSideLatLong.latitude + fourthSideLatLong.latitude) / 2
                let secondmidPointLong = (secondSideLatLong.longitude + fourthSideLatLong.longitude) / 2
                let position = CLLocationCoordinate2D(latitude: secondmidPointLat, longitude: secondmidPointLong)
                let marker = GMSMarker(position: position)
                
                let finalCGpoint = mapView.projection.point(for: position)
                let label =  UILabel()
                label.font = UIFont(name: "NeoSansArabic", size: 12)
                label.textColor = .black
                label.center = CGPoint(x: finalCGpoint.x, y: finalCGpoint.y)
                label.textAlignment = .center
                label.backgroundColor = UIColor.clear
                print ("Current Building",buildingName)

                label.text = buildingName
                label.numberOfLines = 0
                label.sizeToFit()
                label.frame = CGRect(x: 5, y: 0, width: 50, height:label.frame.height+5)
                label.frame.size = label.intrinsicContentSize

                let image = captureScreen(label)
                marker.icon = image
                marker.map = mapView
                }
                
                let finalPath = GMSMutablePath()
                finalPath.add(firstSideLatLong)
                finalPath.add(secondSideLatLong)
                finalPath.add(thirdSideLatLong)
                finalPath.add(fourthSideLatLong)
                finalPath.add(firstSideLatLong)
                
                let finalPolyLine = GMSPolyline(path: finalPath)
                finalPolyLine.map = nil
                finalPolyLine.map = mapView
                
                finalPolyLine.strokeColor = UIColor(red: 131/255, green: 205/255, blue: 254/255, alpha: 1.0)
                finalPolyLine.strokeWidth = 2
                
            }
        }
        
    }
    
    func captureScreen(_ viewcapture : UIView) -> UIImage {

      UIGraphicsBeginImageContextWithOptions(viewcapture.frame.size, false, UIScreen.main.scale)
        viewcapture.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!;
    }
    
    
    
}
