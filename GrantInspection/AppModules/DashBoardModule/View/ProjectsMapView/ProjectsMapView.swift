//
//  ProjectsMapView.swift
//  Progress
//
//  Created by Muhammad Akhtar on 9/30/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import UIKit
import GoogleMaps

class ProjectsMapView: UIView, GMSMapViewDelegate, MapMarkerDelegate, CLLocationManagerDelegate {
    
    var delegate:PeojectListingViewDelegate?
    @IBOutlet weak var googleMapView: GMSMapView!
    @IBOutlet weak var alertMessageView: UIView!
    var locationManager = CLLocationManager()
    var infoWindow = ProjectInfoWindow()
    fileprivate var locationMarker : GMSMarker? = GMSMarker()
    var projectsPayload: [Dashboard] = [Dashboard]()
    var paymentObj: Dashboard = Dashboard()
    var projectsWithLatLongArray: [Dashboard] = [Dashboard]()
    var indexOfMarker = 0
    var isPlotSelected = false
    
    var markers = [GMSMarker]()
    
    class func getProjectsMapView() -> ProjectsMapView
    {
        return Bundle.main.loadNibNamed("ProjectsMapView", owner: self, options: nil)![0] as! ProjectsMapView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.distanceFilter = 500
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        self.alertMessageView.alpha = 0.0
      
        self.infoWindow = ProjectInfoWindow.getProjectInfoWindow()
        setFonts()
        setArray()
      
      
      if Common.currentLanguageArabic() {
         self.transform  = Common.arabicTransform
      }
    }
    
    func setArray() {
        projectsWithLatLongArray.removeAll()
        for projectObj in self.projectsPayload {
            guard Double(projectObj.plot.latitude) != nil else {
                continue
            }
            //Add project object in map rendering array if it has Coordinates
            projectsWithLatLongArray.append(projectObj)
        }
    }
    
    func loadPins(){
        
        setArray()
        indexOfMarker = 0
        markers.removeAll()
        for projectObj in self.projectsWithLatLongArray {

            guard let latVal = Double(projectObj.plot.latitude) else {
                continue
            }
            guard let longVal = Double(projectObj.plot.longitude) else {
                continue
            }
            let location = CLLocationCoordinate2D(latitude: latVal, longitude: longVal)
            let pin = GMSMarker(position: location)
            pin.icon = UIImage(named: "pin_icon_red")
            pin.accessibilityLabel = "\(indexOfMarker)"
            indexOfMarker += 1
            pin.map = googleMapView
            markers.append(pin)
        }
    }
    
    func removePins(){
      //  googleMapView.clear()
//        self.googleMapView.clear()
//        googleMapView.remov
        //self.googleMapView = nil
        
        for (index, _) in markers.enumerated() {
            //print("Item \(index): \(element)")
                        self.markers[index].map = nil
        }
    }
    
    
    func setFonts() {
    }
    
    //    func flippedView (){
    //        if Common.currentLanguageArabic() {
    //            self.transform = Common.arabicTransform
    //            self.toArabicTransform()
    //        }
    //    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
    
        locationMarker = marker
        infoWindow.removeFromSuperview()
        self.infoWindow = ProjectInfoWindow.getProjectInfoWindow()
        guard let location = locationMarker?.position else {
            print("locationMarker is nil")
            return false
        }
         let index:Int! = Int(marker.accessibilityLabel!)
        
        infoWindow.center = mapView.projection.point(for: location)
        infoWindow.center.y = infoWindow.center.y - 170
        
        self.paymentObj = self.projectsPayload[index]
        

        infoWindow.setDataForMap(dashboardObj: self.paymentObj)
        infoWindow.btnAddToTrip.tag = index
        infoWindow.btnAddToTrip.addTarget(self, action: #selector(btnAddToTrip_Action(_:)), for: .touchUpInside)
        //infoWindow.btnNotes.tag = indexPath.row
        infoWindow.btnNotes.addTarget(self, action: #selector(btnNotes_Action(_:)), for: .touchUpInside)
        //infoWindow.btnAttachments.tag = indexPath.row
        infoWindow.btnAttachments.addTarget(self, action: #selector(btnAttachments_Action(_:)), for: .touchUpInside)
        //infoWindow.btnNavigation.tag = indexPath.row
        infoWindow.btnNavigation.addTarget(self, action: #selector(btnNavigation_Action(_:)), for: .touchUpInside)
        //infoWindow.btnMore.tag = indexPath.row
        infoWindow.btnMore.addTarget(self, action: #selector(btnMore_Action(_:)), for: .touchUpInside)
        infoWindow.btnBoq.addTarget(self, action: #selector(btnBoq_Action(_:)), for: .touchUpInside)
        infoWindow.callNowBtn.tag = index
        infoWindow.callNowBtn.addTarget(self, action: #selector(callNowButtonPressed(_:)), for: .touchUpInside)
        
        infoWindow.addPlotNumberButton.tag = index
        infoWindow.addPlotNumberButton.addTarget(self, action: #selector(addPlotButton_Action(_:)), for: .touchUpInside)
        
        infoWindow.btnEditToTrip.tag = index
        infoWindow.btnEditToTrip.addTarget(self, action: #selector(editPlotButton_Action(_:)), for: .touchUpInside)
        
        self.addSubview(infoWindow)
        return false
    }
    
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        if (locationMarker != nil){
            guard let location = locationMarker?.position else {
                print("locationMarker is nil")
                return
            }
            infoWindow.center = mapView.projection.point(for: location)
            infoWindow.center.y = infoWindow.center.y - 170
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        infoWindow.removeFromSuperview()
    }
    
    
    func didTapInfoButton(data: String) {
        
    }
    
    @objc func addPlotButton_Action(_ sender:UIButton) {
        
        if SharedResources.sharedInstance.contractsPayload.payload.dashboard.count > 0
        {
             SharedResources.sharedInstance.isRefreshNeeded = true
            self.delegate?.addPlotButton_Action(paymentOBJ:SharedResources.sharedInstance.contractsPayload.payload.dashboard[sender.tag],delegateObj:self.delegate!)
        }
        
    }
    
    @objc func editPlotButton_Action(_ sender:UIButton)
    {
        if SharedResources.sharedInstance.contractsPayload.payload.dashboard.count > 0 {
            SharedResources.sharedInstance.isRefreshNeeded = true
            self.delegate?.editPlotButton_Action(paymentOBJ: SharedResources.sharedInstance.contractsPayload.payload.dashboard[sender.tag], delegateObj: self.delegate!)
        }
    }
    
    
    @objc func btnAddToTrip_Action(_ sender:UIButton) {

        if Common.isProjectAddedIntoTripArrayWith(paymentId: self.paymentObj.applicationNo) {

           setAddTripButtonColorAndImageForSelectedState()
       } else {
           setAddTripButtonColorAndImageForNormalState()
       }

        if SharedResources.sharedInstance.contractsPayload.payload.dashboard.count > 0 {
            self.delegate?.addToTrip_Action(paymentOBJ: SharedResources.sharedInstance.contractsPayload.payload.dashboard[sender.tag])
        }
        
    }
    
    func setAddTripButtonColorAndImageForSelectedState() {
        //self.btnAddToTrip.backgroundColor = UIColor.init(red: 231/255, green: 248/255, blue: 243/255, alpha: 1.0)
        infoWindow.addToTripLbl.text = "pay_added_to_trip".ls
        if Common.currentLanguageArabic()
        {
            infoWindow.addToTripImg.image = UIImage(named: "tripR_Check")
        }
        else
        {
            infoWindow.addToTripImg.image = UIImage(named: "trip_Check")
            
        }
        
        
        //self.btnAddToTrip.isUserInteractionEnabled = false
    }
    
    func setAddTripButtonColorAndImageForNormalState() {
       //x self.btnAddToTrip.backgroundColor = UIColor.init(red: 20/255, green: 193/255, blue: 139/255, alpha: 1.0)
        infoWindow.addToTripImg.image = UIImage(named: "Add_trip")
         infoWindow.addToTripLbl.text = "pay_add_to_trip".ls
        // self.btnAddToTrip.isUserInteractionEnabled = true
    }
    
    @objc func btnNotes_Action(_ sender:UIButton) {
        self.delegate?.gotToNotes_Action(paymentOBJ: self.paymentObj)
    }
    
    @objc func btnAttachments_Action(_ sender:UIButton) {
        self.delegate?.gotToAttachment_Action(paymentOBJ: self.paymentObj)
    }
    
    @objc func btnNavigation_Action(_ sender:UIButton) {
        self.delegate?.navigation_Action(paymentOBJ: self.paymentObj)
    }
    
    @objc func btnMore_Action(_ sender:UIButton) {
        self.delegate?.more_Action(paymentOBJ: self.paymentObj)
    }
    
    @objc func btnBoq_Action(_ sender:UIButton) {
        self.delegate?.boq_Action(paymentOBJ: self.paymentObj)
    }
    
    //MARK: --- Location Manager delgate ---
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        self.googleMapView.isMyLocationEnabled = true
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last
        self.googleMapView.camera = GMSCameraPosition.camera(withTarget: newLocation!.coordinate, zoom: 12.0)
        self.googleMapView.settings.myLocationButton = true

//        let marker = GMSMarker()
//        marker.position = CLLocationCoordinate2DMake(newLocation!.coordinate.latitude, newLocation!.coordinate.longitude)
//        marker.map = self.googleMapView
    }
    
    func fadeIn(view: UIView, _ duration: TimeInterval = 0.7, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
            view.alpha = 1.0
        }, completion: completion)  }
    
    func fadeOut(view: UIView, _ duration: TimeInterval = 0.7, delay: TimeInterval = 0.0, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
            view.alpha = 0.0
        }, completion: {
            (finished: Bool) -> Void in
            view.isHidden = true
        })
    }
    
    @objc func callNowButtonPressed(_ sender : UIButton){
           
           if SharedResources.sharedInstance.contractsPayload.payload.dashboard.count > 0 {
               let phoneNumber = SharedResources.sharedInstance.contractsPayload.payload.dashboard[sender.tag].applicantMobileNo
               Common.dialNumber(number: phoneNumber)
           }
           
       }
    
}

