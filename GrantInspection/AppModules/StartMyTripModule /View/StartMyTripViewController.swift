//
//  StartMyTripViewController.swift
//  Progress
//
//  Created by Muhammad Akhtar on 10/14/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import UIKit
import GoogleMaps
import RxSwift
import RxCocoa
import CoreLocation
import UserNotifications

class StartMyTripViewController: UIViewController, GMSMapViewDelegate, MapMarkerDelegate, CLLocationManagerDelegate, UNUserNotificationCenterDelegate, UITableViewDelegate, PlotMapViewDelegate  {
    
    
    
    
    @IBOutlet weak var googleMapView: GMSMapView!
    var locationManager = CLLocationManager()
    private var infoWindow = InfoWindow()
    fileprivate var locationMarker : GMSMarker? = GMSMarker()
    var mapMarkers : [GMSMarker] = []
    var projectsPayload: [Dashboard] = [Dashboard]()
    //var indexOfMarker = 0
    var mapViewDelegate: PlotMapViewDelegate?
    @IBOutlet weak var btnStartTrip: UIButton!
    @IBOutlet weak var btnAddNewProject: MBRHERoundButtonView!
    @IBOutlet weak var tripInfoView: UIView!
    @IBOutlet weak var btnExpand: UIButton!
    @IBOutlet weak var tblTripInfo: UITableView!
    @IBOutlet weak var tripViewRightMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerView: UIView!
     @IBOutlet weak var backAcnView: UIView!
    @IBOutlet weak var backAcn: UIButton!
    var paymentObj:Dashboard = Dashboard()
    
    var isExpand = true
    private let disposeBag = DisposeBag()
    let projectList = Variable<[Dashboard]>([])
    var tripInfoArray :Variable<[TripModel]> = Variable([])
    
    let tripDetailsArray: BehaviorRelay<[Dashboard]> = BehaviorRelay(value: [])
    
    var tripVwModel = TripModelView()
    
    var isCurrentLocationGet = false
    var enteredRegionIdentifier: String = " "
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestPermissionNotifications()
        // Do any additional setup after loading the view.
        
        googleMapView.tag = 200
        bindView()
        
        if(Common.isConnectedToNetwork() == false){
            notAvailable(isNetwork: true)
        }
        
        
        btnStartTrip.setTitle("start_trip_btn".ls, for: .normal)
        btnStartTrip.imageView?.changeTintColor(color: .white)
        backAcn.setTitle("back_btn".ls, for: .normal)
        
        //        addMRHEHeaderView()
        
        if Common.currentLanguageArabic()
        {
            
            self.view.transform  = Common.arabicTransform
            self.view.toArabicTransform()
            headerView.transform = Common.arabicTransform
            googleMapView.transform = Common.arabicTransform
            backAcnView.transform = Common.arabicTransform
            backAcn.titleLabel?.transform = Common.arabicTransform
            backAcn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)

            
        }
        
        addMRHELeftMenuView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
//        backAcn.isHidden = false
        setLocationManager()
        
        ignorePlotWithEmptyLatLongValue()
        
        if self.projectsPayload.count > 0 {
            self.btnStartTrip.isUserInteractionEnabled = true
        } else {
            self.btnStartTrip.isUserInteractionEnabled = false
        }
        
        print(backAcnView.isHidden)
        
        tripInfoView.isHidden = tripInfoView.isHidden
        backAcnView.isHidden = backAcnView.isHidden
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        self.googleMapView.clear()
        isCurrentLocationGet = false
        self.locationManager.delegate = nil
        self.locationManager.stopUpdatingLocation()
        self.tripInfoArray.value.removeAll()
        self.infoWindow.removeFromSuperview()
    }
    
    
    @IBAction func backBtnAcn(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func setRouteForTrip() {
        // print(TripModelView.setWaypointsArrayWith())
    }
    
    var sameValueRepeat = ""
    
    func bindView() {
        
        tblTripInfo.register(UINib.init(nibName: "TripInfoCell", bundle: nil), forCellReuseIdentifier: "cell")
        tblTripInfo.register(UINib(nibName: "CurrentLocationCell", bundle: nil), forCellReuseIdentifier: "CurrentCell")
        
        btnExpand.rx.tap.subscribe(onNext: { [unowned self] in
            self.slideInAndOut()
        }).disposed(by: disposeBag)
        
        print("TRP_DAT ", tripDetailsArray.value.count)
        
//        let tripModelView = TripModelView()
        
        sameValueRepeat = ""
        
        tripDetailsArray.bind(to: tblTripInfo.rx.items(cellIdentifier: "cell") ) { row, model, cell in
            if let tripCell = cell as? TripInfoCell {
                tripCell.callButton.tag = row
                tripCell.callButton.addTarget(self, action: #selector(self.callAction(_:)), for: .touchUpInside)
                if row == 0 {
                    tripCell.headerLabel.text = "current_request_lbl".ls
                }else {
                    tripCell.headerLabel.text = "next_request_lbl".ls
                }
                self.paymentObj = model
                tripCell.setValues(details: model)
                tripCell.btnMore.addTarget(self, action: #selector(self.btnMoreAction(sender:)), for: .touchUpInside)
                tripCell.btnMore.tag = row
              
                if let val = SharedResources.sharedInstance.tripModelDict[model.applicationNo.description] {
                    
                    tripCell.actionDateBtn.setTitle(val, for: .normal)
                        // now val is not nil and the Optional has been unwrapped, so use it
                }
                
            
            }
        }.disposed(by: disposeBag)
        
        TripModelView.trip.subscribe (onNext: { tripModel in
            
            self.tblTripInfo.reloadData()
            
        }).disposed(by:self.disposeBag)
        

    }
    
    @IBAction func btnMoreAction(sender: UIButton) {
        
        print(sender.tag)
        print(projectsPayload)
        
        self.infoWindow.removeFromSuperview()
        let dashboarObj = projectsPayload[sender.tag]
        navigateToSimplifiedReportModule(requestDetails: dashboarObj)
        
    }
    
    
    @objc func more_Action(_ sender:UIButton) {
        print(sender.tag)
        let strPaymentId = String(format:"\(sender.tag)")
        self.selectMarker(paymentID: strPaymentId)
    }
    
    @IBAction func callAction(_ sender: UIButton) {
        
        #if targetEnvironment(simulator)
        self.navigationController?.popViewController(animated: true)
        #else
        let trip = tripDetailsArray.value[sender.tag]
        if trip.applicantMobileNo.count > 0 {
            Common.dialNumber(number: trip.applicantMobileNo)
        }
        #endif
        
    }
    
    
    
    func slideInAndOut() {
        if self.isExpand {
            self.isExpand = false
            UIView.animate(withDuration: 0.7) {
                self.tripViewRightMarginConstraint.constant = -240
                self.view.layoutIfNeeded()
            }
            self.btnExpand.setImage(UIImage.init(named: "expand_icon"), for: .normal)
        } else {
            self.isExpand = true
            UIView.animate(withDuration: 1.0) {
                self.tripViewRightMarginConstraint.constant = 21
                self.view.layoutIfNeeded()
            }
            self.btnExpand.setImage(UIImage.init(named: "collaps_icon"), for: .normal)
        }
    }
    
    func setLocationManager() {
        //self.googleMapView.settings.myLocationButton = true
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()
        self.locationManager.distanceFilter = 100
        self.infoWindow = InfoWindow.getProjectInfoWindow()
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //    func addMRHEHeaderView(){
    //        let mrheHeaderView = MRHEHeaderView.getMRHEHeaderView()
    //        self.view.addSubview(mrheHeaderView)
    //    }
    
    func addMRHELeftMenuView(){
        let mrheMenuView = MBRHELeftMenuView.getMBRHELeftMenuView()
        self.view.addSubview(mrheMenuView)
        
        if Common.currentLanguageArabic()
        {
            mrheMenuView.transform = Common.arabicTransform
        }
        else
        {
            mrheMenuView.transform = Common.englishTransform
        }
    }
    
    func loadDummyPins() {
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
        
        var indexOfMarker = 0
        for projectObj in locationArray {
            
            guard let latVal = Double(projectObj.lat) else {
                continue
            }
            guard let longVal = Double(projectObj.lng) else {
                continue
            }
            
            let location = CLLocationCoordinate2D(latitude: latVal, longitude: longVal)
            let pin = GMSMarker(position: location)
            pin.icon = UIImage(named: "pin_icon")
            pin.accessibilityLabel = "\(indexOfMarker)"
            indexOfMarker += 1
            pin.map = googleMapView
        }
    }
    
    
    func ignorePlotWithEmptyLatLongValue() {
        self.projectsPayload.removeAll()
        //print("Count \(SharedResources.sharedInstance.selectedTripContracts.count)")
        let allSelectedTripProjectsArray = SharedResources.sharedInstance.selectedTripContracts
        if allSelectedTripProjectsArray.count > 0 {
            tripDetailsArray.accept(allSelectedTripProjectsArray)
        }
        
        print("tripDetailsArrayTRP    ", tripDetailsArray.value.count)
        
        for projectObj in allSelectedTripProjectsArray {
            
            guard Double(projectObj.plot.latitude) != nil else {
                continue
            }
            guard Double(projectObj.plot.longitude) != nil else {
                continue
            }
            
            self.projectsPayload.append(projectObj)
        }
        //Add pins on map
        loadPins()
        //loadDummyPins()
    }
    
    func loadPins(){
        
        for (index,projectObj) in self.projectsPayload.enumerated() {
            
            guard let latVal = Double(projectObj.plot.latitude) else {
                continue
            }
            guard let longVal = Double(projectObj.plot.longitude) else {
                continue
            }
            
            let location = CLLocationCoordinate2D(latitude: latVal, longitude: longVal)
            let pin = GMSMarker(position: location)
            pin.icon = UIImage(named: "pin_icon_red")
            pin.accessibilityLabel = "\(index)"
            pin.map = googleMapView
            mapMarkers.append(pin)
            /*
             //Add circle for geofence
             let radiusInMeter = 100.0
             let payId = String(format:"\(projectObj.paymentId)")
             let geoFenceRegion:CLCircularRegion = CLCircularRegion(center: CLLocationCoordinate2DMake(latVal, longVal), radius: radiusInMeter, identifier: payId)
             
             let circleCenter = CLLocationCoordinate2D(latitude: latVal, longitude: longVal)
             let cirlce = GMSCircle(position: circleCenter, radius: radiusInMeter)
             cirlce.fillColor = UIColor(red: 0, green: 0, blue: 0.3, alpha: 0.2)
             cirlce.strokeColor = Common.appThemeColor
             cirlce.strokeWidth = 2
             cirlce.map = self.googleMapView
             */
            //   locationManager.startMonitoring(for: geoFenceRegion)
            
        }
    }
    
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        locationMarker = marker
        guard let location = locationMarker?.position else {
            //print("locationMarker is nil")
            return false
        }
        self.showMapDetailWindow(pin: marker, position: location)
        /*
         locationMarker = marker
         infoWindow.removeFromSuperview()
         self.infoWindow = InfoWindow.getProjectInfoWindow()
         guard let location = locationMarker?.position else {
         //print("locationMarker is nil")
         return false
         }
         let index:Int! = Int(marker.accessibilityLabel!)
         
         infoWindow.center = mapView.projection.point(for: location)
         infoWindow.center.x = infoWindow.center.x + 100
         infoWindow.center.y = infoWindow.center.y - 70
         
         let projectObj =   getProjectOnTapWith(paymentId:index! as NSNumber)   //self.projectsPayload[index]
         infoWindow.setData(projectObj: projectObj)
         infoWindow.btnNotes.tag = index
         infoWindow.btnNotes.addTarget(self, action: #selector(btnNotes_Action(_:)), for: .touchUpInside)
         infoWindow.btnAttachments.tag = index
         infoWindow.btnAttachments.addTarget(self, action: #selector(btnAttachments_Action(_:)), for: .touchUpInside)
         infoWindow.btnNavigation.tag = index
         infoWindow.btnNavigation.addTarget(self, action: #selector(btnNavigation_Action(_:)), for: .touchUpInside)
         infoWindow.btnMore.tag = index
         infoWindow.btnMore.addTarget(self, action: #selector(btnMore_Action(_:)), for: .touchUpInside)
         
         self.view.addSubview(infoWindow)
         */
        return false
    }
    
    func selectMarker(paymentID:String){
        
        for marker in self.mapMarkers {
            if marker.accessibilityLabel == paymentID {
                //Show selected marker pin
                
                self.googleMapView?.selectedMarker = marker
                self.googleMapView?.animate(toLocation: (self.googleMapView?.selectedMarker!.position)!)
                self.showMapDetailWindow(pin: marker, position: (self.googleMapView?.selectedMarker!.position)!)
                return
            }
            
        }
        
        
    }
    
    func showMapDetailWindow(pin:GMSMarker, position:CLLocationCoordinate2D) {
        
        locationMarker = pin
        infoWindow.removeFromSuperview()
        self.infoWindow = InfoWindow.getProjectInfoWindow()
        
        guard let indexValue = pin.accessibilityLabel else { return  }
        let index = Int(indexValue) ?? 0
        
        infoWindow.center = self.googleMapView.projection.point(for: position)
        infoWindow.center.x = infoWindow.center.x + 100
        infoWindow.center.y = infoWindow.center.y - 50
        
        let projectObj =  self.projectsPayload[index] //getProjectOnTapWith(paymentId:index as NSNumber)   //self.projectsPayload[index]
        infoWindow.setData(projectObj: projectObj)
        infoWindow.detailsButton.addTarget(self, action: #selector(requestDetailsAction(_:)), for: .touchUpInside)
        
        self.view.addSubview(infoWindow)
    }
    
    @IBAction func requestDetailsAction(_ sender: UIButton) {
        
        if let details = tripDetailsArray.value.filter({Int(truncating: $0.applicationNo) == sender.tag}).first {
            navigateToSimplifiedReportModule(requestDetails: details)
            tripInfoView.isHidden = true
            //if let _ = infoWindow {
            infoWindow.removeFromSuperview()
            //}
        }
        
        
    }
    
    func navigateToSimplifiedReportModule(requestDetails:Dashboard) {
        
        backAcnView.isHidden = true
        tripInfoView.isHidden = true
        if let reportVC = self.storyboard?.instantiateViewController(withIdentifier: "RequestDetailController") as? RequestDetailController {
            reportVC.requestObject = requestDetails
            reportVC.isFromStartMyTrip = true
            let rootVC = UINavigationController(rootViewController: reportVC)
            rootVC.navigationBar.isHidden = true
            addChild(rootVC)
            rootVC.view.frame = self.googleMapView.bounds
            self.googleMapView.addSubview(rootVC.view)
            rootVC.didMove(toParent: self)
        }
    }
    
    func getProjectOnTapWith(paymentId:NSNumber) -> Dashboard {
        
        var paymentObj = Dashboard()
        // paymentObj = self.projectsPayload.filter{ $0.paymentId == paymentId }.first!
        return paymentObj
        
    }
    
    @objc func Notes_Action(_ sender:UIButton) {
        let index = sender.tag
        let projectObj = getProjectOnTapWith(paymentId:index as NSNumber)
        goToNotesVCWith(Obj: projectObj)
    }
    
    @objc func Attachments_Action(_ sender:UIButton) {
        let index = sender.tag
        let projectObj = getProjectOnTapWith(paymentId:index as NSNumber)
        goToPaymentAttachmentVCWith(Obj: projectObj)
    }
    
    @objc func Navigation_Action(_ sender:UIButton) {
        // let index = sender.tag
        let index = sender.tag
        let projectObj = getProjectOnTapWith(paymentId:index as NSNumber)
        
        if projectObj.plot.latitude != "" && projectObj.plot.longitude != "" {
            presentMapView(obj: projectObj)
        } else {
            Common.showToaster(message: "the_coordinate_is_not_set_for_this_plot.".ls)
        }

    }
    
    @objc func More_Action(_ sender:UIButton) {
        // let index = sender.tag
        let index = sender.tag
        let projectObj = getProjectOnTapWith(paymentId:index as NSNumber)
        presentPaymentDetailView(obj: projectObj)
    }
    
    func addToTripActionFromDelegate(obj: Dashboard) {
        self.mapViewDelegate?.addToTripActionFromDelegate(obj: obj)
    }
    
    
    @objc func BOQ_Action(_ sender:UIButton) {
        // let index = sender.tag
        let index = sender.tag
        let projectObj = getProjectOnTapWith(paymentId:index as NSNumber)
        goBOQVCWith(Obj: projectObj)
    }
    
    func goBOQVCWith(Obj:Dashboard) {
        let service = BOQContractService()
        let viewModel = BOQViewModel(service)
        let viewController = ContractBreakDownInfoViewController.create(with: viewModel) as! ContractBreakDownInfoViewController
        viewController.obj = Obj
        self.navigationController?.pushViewController(viewController,animated: false)
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        if (locationMarker != nil){
            guard let location = locationMarker?.position else {
                //print("locationMarker is nil")
                return
            }
            infoWindow.center = mapView.projection.point(for: location)
            infoWindow.center.x = infoWindow.center.x + 100
            infoWindow.center.y = infoWindow.center.y - 20
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        infoWindow.removeFromSuperview()
    }
    
    func didTapInfoButton(data: String) {
    }
    

    //MARK: ---- Views/screen naviagtion function --
    
    func goToPaymentAttachmentVCWith(Obj:Dashboard) {
        let service = PaymentAttachmentsService()
        let viewModel = PaymentsAttachmentViewModel(service)
        let viewController = PaymentAttachmentsViewController.create(with: viewModel) as! PaymentAttachmentsViewController
        viewController.obj = Obj
        self.navigationController?.pushViewController(viewController,animated: false)
    }
    
    func goToNotesVCWith(Obj:Dashboard) {
        let service = PaymentNotesService()
        let viewModel = PaymentNotesViewModel(service)
        let viewController = NotesViewController.create(with: viewModel) as! NotesViewController
        viewController.obj = Obj
        self.navigationController?.pushViewController(viewController,animated: false)
    }
    
    func presentMapView(obj:Dashboard) {
        
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MapView") as? PlotMapView
        {
            vc.mapViewDelegate = self
            vc.paymentObj = obj
            vc.modalPresentationStyle = .overCurrentContext
            Common.appDelegate.window?.rootViewController?.present(vc, animated: false, completion: nil)
        }
    }
    
    func btnNotes_Action(obj: Dashboard) {
        goToNotesVCWith(Obj: obj)
    }
    
    func btnAttachment_Action(obj: Dashboard) {
        goToPaymentAttachmentVCWith(Obj: obj)
    }
    
    func btnMore_Action(obj: Dashboard) {
        
        presentPaymentDetailView(obj: obj)
    }
    func presentPaymentDetailView(obj:Dashboard) {
        let service = PaymentDetailService()
        let viewModel = PaymentDetailViewModel(service)
        let vc = PaymentDetailView.create(with: viewModel) as! PaymentDetailView
        vc.paymentObj = obj
        vc.modalPresentationStyle = .overCurrentContext
        Common.appDelegate.window?.rootViewController?.present(vc, animated: false, completion: nil)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    /*
     func codeTried() {
     
     //Hide trip info window
     self.slideInAndOut()
     self.infoWindow.removeFromSuperview()
     
     for projectObj in self.projectsPayload {
     
     guard let latVal = Double(projectObj.plot.latitude) else {
     continue
     }
     guard let longVal = Double(projectObj.plot.longitude) else {
     continue
     }
     
     let location = CLLocationCoordinate2D(latitude: latVal, longitude: longVal)
     let pin = GMSMarker(position: location)
     pin.icon = UIImage(named: "pin_icon_red")
     //  pin.accessibilityLabel = "\(projectObj.paymentId)"
     pin.map = googleMapView
     mapMarkers.append(pin)
     
     }
     
     var projectsLocationArray = self.projectsPayload
     
     let destination = projectsLocationArray.last
     let destiLatDouble = destination?.plot.latitude ?? "0.0"
     let destiLongDouble = destination?.plot.longitude ?? "0.0"
     
     
     
     //let geoLocation = CLLocationCoordinate2D(latitude: CLLocationDegrees(Double(destiLatDouble!)!), longitude: CLLocationDegrees(Double(destiLongDouble!)!))
     
     let geoLocation = CLLocationCoordinate2D(latitude: CLLocationDegrees(Double(destiLatDouble)!), longitude: CLLocationDegrees(Double(destiLongDouble)!))
     
     let strDestination = "\(destiLatDouble.description),\(destiLongDouble.description)"
     
     let geocoder = GMSGeocoder()
     geocoder.reverseGeocodeCoordinate(geoLocation) { response , error in
     if let address = response?.firstResult() {
     let lines = address.lines ?? [""]
     
     if lines[0] == "" {
     // EMPTY STRING
     }
     else {
     
     //                        var addressLines = "59 42nd St - Dubai - United Arab Emirates" //lines.joined(separator: " ")
     var addressLines = "59 42nd St - Dubai - United Arab Emirates"
     
     addressLines = addressLines.replacingOccurrences(of: " ", with: "+")
     
     //                        addressLines = addressLines.replacingOccurrences(of: "+", with: "%2B")
     
     //DispatchQueue.main.async {
     
     var directionsRequest = "https://www.google.com/maps/dir/?api=1&origin=\(addressLines)&destination=25.44,56.90&travelmode=driving"
     
     
     //                        var directionsRequest =  "https://www.google.com/maps/dir/?api=1&origin=59+42nd+St+-+Dubai+-+United+Arab+Emirates&destination=25.44,56.10&travelmode=driving"
     
     print("directionsRequest  ", directionsRequest)
     
     //                        directionsRequest = directionsRequest.addingPercentEncoding(withAllowedCharacters: .) ?? ""
     
     if directionsRequest == "" {
     
     return
     }
     
     //                        var directionsURL : URL = URL(string: directionsRequest)!
     
     
     var url = URLComponents(string: "https://www.google.com/maps/dir/")!
     
     url.queryItems = [
     URLQueryItem(name: "api", value: "1"),
     URLQueryItem(name: "origin", value: "59+42nd+St+-+Dubai+-+United+Arab+Emirates"),
     URLQueryItem(name: "destination", value: "25.44,56.90"),
     URLQueryItem(name: "travelmode", value: "driving")
     ]
     
     //                        url.percentEncodedQuery = url.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
     
     
     
     print("directionsURL   ", url.url!)
     
     //UIApplication.shared.openURL(directionsURL)
     UIApplication.shared.open(directionsURL, options: [:], completionHandler: nil)
     
     UIApplication.shared.open(url.url!, options: [:]) { (val) in
     
     if val {
     
     print("URL_NAVIG___")
     }
     else {
     print("FAIL_  URL_NAVIG___     ", val)
     }
     }
     
     //}
     
     print("lines    ", addressLines)
     }
     
     
     }
     else {
     print("Err_in_Lat_long")
     }
     }
     
     //            var wayPoints = ""
     //            projectsLocationArray.removeLast() //last should be no more in waypoints array because it is now destination
     //
     //            for point in projectsLocationArray {
     //
     //                if wayPoints == "" {
     //                    wayPoints =  "&waypoints=\(point.plot.latitude),\(point.plot.longitude)"
     //                } else {
     //                    wayPoints = "\(wayPoints)%7C\(point.plot.latitude),\(point.plot.longitude)"
     //                }
     //            }
 
     //  Working url (Test)
     //  let directionsRequest = "https://www.google.com/maps/dir/?api=1&origin=Current+Location&destination=\(strDestination),&travelmode=driving&waypoints=\(25.255584),\(55.346164)%7C\(25.299047),\(55.413426)"
     
     //            let directionsRequest = "https://www.google.com/maps/dir/?api=1&origin=Current+Location&destination=\(strDestination)&travelmode=driving\(wayPoints)"
     
     
     //            let directionsRequest = "https://www.google.com/maps/dir/?api=1&origin=59+42nd+St+-+Dubai+-+United+Arab+Emirates&destination=25.44,56.10&travelmode=driving"
     
     // 59 42nd St - Dubai - United Arab Emirates
     
     //            let directionsURL = URL(string: directionsRequest)!
     //UIApplication.shared.openURL(directionsURL)
     //            UIApplication.shared.open(directionsURL, options: [:], completionHandler: nil)
     }
     
     */
    
    
    @IBAction func btnStartTrip_Tapped(_ sender: Any) {
        DispatchQueue.main.async {
            self.btnStartTrip.imageView?.changeTintColor(color: .white)
        }
        
        let testURL = URL(string: "comgooglemaps-x-callback://")!
        if UIApplication.shared.canOpenURL(testURL) {
            
            //Hide trip info window
            self.slideInAndOut()
            self.infoWindow.removeFromSuperview()
            
            for projectObj in self.projectsPayload {
                
                guard let latVal = Double(projectObj.plot.latitude) else {
                    continue
                }
                guard let longVal = Double(projectObj.plot.longitude) else {
                    continue
                }
                
                let location = CLLocationCoordinate2D(latitude: latVal, longitude: longVal)
                let pin = GMSMarker(position: location)
                pin.icon = UIImage(named: "pin_icon_red")
                //  pin.accessibilityLabel = "\(projectObj.paymentId)"
                pin.map = googleMapView
                mapMarkers.append(pin)
                
            }
            
            let projectsLocationArray = self.projectsPayload
            
            let destination = projectsLocationArray.last
            let destiLatDouble = destination?.plot.latitude ?? "0.0"
            let destiLongDouble = destination?.plot.longitude ?? "0.0"
            
            if destiLatDouble == "" || destiLatDouble == "0.0" || destiLongDouble == "" || destiLongDouble == "0.0" {
                
                Common.showToaster(message: "Invalid Lat Long")
                
                return
            }
            
            //let geoLocation = CLLocationCoordinate2D(latitude: CLLocationDegrees(Double(destiLatDouble!)!), longitude: CLLocationDegrees(Double(destiLongDouble!)!))
            
            //let geoLocation = CLLocationCoordinate2D(latitude: CLLocationDegrees(Double(destiLatDouble)!), longitude: CLLocationDegrees(Double(destiLongDouble)!))
            
            let strDestination = "\(destiLatDouble.description),\(destiLongDouble.description)"
            
            /*
             let geocoder = GMSGeocoder()
             
             
             geocoder.reverseGeocodeCoordinate(geoLocation) { response, error in
             guard let address = response?.firstResult(), let lines = address.lines else {
             return
             }
             
             var placeNameStr = lines.joined(separator: "\n")
             placeNameStr = placeNameStr.replacingOccurrences(of: " ", with: "+")
             
             
             print("place___    ", placeNameStr)
             
             //                let directionsRequest = "https://www.google.com/maps/dir/?api=1&origin=Current+Location&destination=\(placeNameStr)&travelmode=driving"
             
             let directionsRequest = "https://www.google.com/maps/dir/?api=1&origin=\(placeNameStr)&destination=Current+Location&travelmode=driving"
             
             // 59 42nd St - Dubai - United Arab Emirates
             
             let directionsURL = URL(string: directionsRequest)!
             
             UIApplication.shared.open(directionsURL, options: [:], completionHandler: nil)
             
             }
             
             */
            //            var wayPoints = ""
            //
            //            projectsLocationArray.removeLast() //last should be no more in waypoints array because it is now destination
            //
            //            for point in projectsLocationArray {
            //
            //                if wayPoints == "" {
            //                    wayPoints =  "&waypoints=\(point.plot.latitude),\(point.plot.longitude)"
            //                } else {
            //                    wayPoints = "\(wayPoints)%7C\(point.plot.latitude),\(point.plot.longitude)"
            //                }
            //            }
            
            
            
            //  Working url (Test)
            //            let directionsRequest = "https://www.google.com/maps/dir/?api=1&origin=Current+Location&destination=\(strDestination),&travelmode=driving&waypoints=\(25.255584),\(55.346164)%7C\(25.299047),\(55.413426)"
            
            let directionsRequest = "https://www.google.com/maps/dir/?api=1&origin=Current+Location&destination=\(strDestination)&travelmode=driving"
            
            
            //            let directionsRequest = "https://www.google.com/maps/dir/?api=1&origin=\(strDestination)&destination=25.44,56.10&travelmode=driving"
            
            // 59 42nd St - Dubai - United Arab Emirates
            
            let directionsURL = URL(string: directionsRequest)!
            
            UIApplication.shared.open(directionsURL, options: [:], completionHandler: nil)
            UIApplication.shared.open(directionsURL, options: [:], completionHandler: nil)
            
        }
        else {
            //NSLog("Can't use comgooglemaps-x-callback:// on this device.")
            self.presentMessage("Please Install google maps application for navigation.")
        }
    }
    
    
    
    //MARK: --- Location Manager delgate ---
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        self.googleMapView.isMyLocationEnabled = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last
        self.googleMapView.camera = GMSCameraPosition.camera(withTarget: newLocation!.coordinate, zoom: 12.0)
        self.googleMapView.settings.myLocationButton = true
        //        for currentLocation in locations{
        //            //print("\(index): \(currentLocation)")
        //            // "0: [locations]"
        //        }
        //print(TripModelView.setWaypointsArrayWith(currentLoc: newLocation!))
        if self.enteredRegionIdentifier != " " {
            checkRegionAndGetRegionLatLong(currentLoc: newLocation!)
        }
        
        
        
        if newLocation != nil && SharedResources.sharedInstance.selectedTripContracts.count > 0 {
            
            if  !isCurrentLocationGet {
                let positions = TripModelView.setWaypointsArrayWith(currentLoc: newLocation!, projectsPayload: self.projectsPayload)
                TripModelView.getDotsToDrawRoute(positions: positions, projectsArray: self.projectsPayload, completion: { path in
                    //self.route.countRouteDistance(p: path)
                    let polyline = GMSPolyline(path: path)
                    polyline.path = path
                    polyline.strokeColor = UIColor(red: 76/255, green: 183/255, blue: 255/255, alpha: 1.0)//Common.appThemeColor
                    polyline.strokeWidth = 4.0
                    polyline.map = self.googleMapView
                })
            }
            isCurrentLocationGet = true
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        //print("Entered: \(region.identifier)")
        self.enteredRegionIdentifier = region.identifier
        //Call geoactivity api for posting data
        let strPaymentId = region.identifier
        if let payIdnteger = Int(strPaymentId) {
            let payIdNumber = NSNumber(value:payIdnteger)
            let projectObj = getProjectOnTapWith(paymentId:payIdNumber)
            // postLocalNotifications(projectName: "Entered: \(projectObj.contractor.name)", distanceInMeters: 100)
            postGeoFenceDataToServerWith(obj: projectObj)
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        //print("Exited: \(region.identifier)")
        //postLocalNotifications(eventTitle: "Exited: \(region.identifier)")
    }
    
    // MARK: - UserNotifications and geofecncing -
    
    func checkRegionAndGetRegionLatLong(currentLoc:CLLocation) {
        let strPaymentId = self.enteredRegionIdentifier
        if let payIdnteger = Int(strPaymentId) {
            let payIdNumber = NSNumber(value:payIdnteger)
            let projectObj = getProjectOnTapWith(paymentId:payIdNumber)
            guard let latVal = Double(projectObj.plot.latitude) else {
                return
            }
            guard let longVal = Double(projectObj.plot.longitude) else {
                return
            }
            let coordinate = CLLocation(latitude: latVal, longitude: longVal)
            
            let distance = calculateDistanceFrom(currentLocation: currentLoc, enteredRegionLocation: coordinate)
            //            if distance >= 1 && distance <= 25 {
            //                postLocalNotifications(projectName: "Entered: \(projectObj.contractor.name)", distanceInMeters: distance)
            //                postGeoFenceDataToServerWith(obj: projectObj)
            //            } else if distance >= 30 && distance <= 55 {
            //                postLocalNotifications(projectName: "Entered: \(projectObj.contractor.name)", distanceInMeters: distance)
            //                postGeoFenceDataToServerWith(obj: projectObj)
            //            } else if distance >= 60 && distance <= 85 {
            //                postLocalNotifications(projectName: "Entered: \(projectObj.contractor.name)", distanceInMeters: distance)
            //                postGeoFenceDataToServerWith(obj: projectObj)
            //            }
            
            
        }
    }
    
    func calculateDistanceFrom(currentLocation:CLLocation, enteredRegionLocation:CLLocation) -> Int{
        //let coordinate₀ = CLLocation(latitude: 5.0, longitude: 5.0)
        //let coordinate₁ = CLLocation(latitude: 5.0, longitude: 3.0)
        let distanceInMeters = currentLocation.distance(from: enteredRegionLocation)
        //print("distance is = \(distanceInMeters)")
        return Int(distanceInMeters)
    }
    
    
    func requestPermissionNotifications(){
        let application =  UIApplication.shared
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (isAuthorized, error) in
                if( error != nil ){
                    print(error!)
                }
                else{
                    if( isAuthorized ){
                        print("authorized")
                        NotificationCenter.default.post(Notification(name: Notification.Name("AUTHORIZED")))
                    }
                    else{
                        let pushPreference = UserDefaults.standard.bool(forKey: "PREF_PUSH_NOTIFICATIONS")
                        if pushPreference == false {
                            let alert = UIAlertController(title: "turn_on_Notifications".ls, message: "push_notifications_are_turned_off".ls, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "turn_on_Notifications".ls, style: .default, handler: { (alertAction) in
                                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                                    return
                                }
                                
                                if UIApplication.shared.canOpenURL(settingsUrl) {
                                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                        // Checking for setting is opened or not
                                        print("Setting is opened: \(success)")
                                    })
                                }
                                UserDefaults.standard.set(true, forKey: "PREF_PUSH_NOTIFICATIONS")
                            }))
                            alert.addAction(UIAlertAction(title: "No thanks.".ls, style: .default, handler: { (actionAlert) in
                                print("user denied")
                                UserDefaults.standard.set(true, forKey: "PREF_PUSH_NOTIFICATIONS")
                            }))
                            let viewController = UIApplication.shared.keyWindow!.rootViewController
                            DispatchQueue.main.async {
                                viewController?.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        }
        else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        completionHandler(.alert)
    }
    
    func postLocalNotifications(projectName:String, distanceInMeters:Int){
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = projectName
        content.body = "You are \(distanceInMeters) meters away from contractor \(projectName) tap to start filling the payment details"
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let notificationRequest:UNNotificationRequest = UNNotificationRequest(identifier: "Region", content: content, trigger: trigger)
        
        center.add(notificationRequest, withCompletionHandler: { (error) in
            if let error = error {
                // Something went wrong
                print(error)
            }
            else{
                print("added")
            }
        })
    }
    
    //MARK: -- Call geolocation api --
    
    func postGeoFenceDataToServerWith(obj:Dashboard) {
        
        let services = GeoActivityService()
        services.postLocationData(obj:obj, completion: {(baseResposne : GeoActivityResponse?) in
            
            guard let response = baseResposne else {
                return
            }
            print(response)
        })
    }
    
    //MARK: -- noData view --
    var noData : NoDataView!
    func notAvailable(isNetwork:Bool){
        
        noData = NoDataView.getEmptyDataView()
        noData.frame = CGRect(x: (self.googleMapView?.frame.origin.x)!, y:((self.googleMapView?.frame.origin.y)! - 20), width: (self.googleMapView?.frame.size.width)!,  height:(self.googleMapView?.frame.size.height)! + 20)
        
        noData.setLayout(noNetwork:isNetwork,Yposition :5)
        noData.backBtn.addTarget(self, action: #selector(self.remvoeNotAvailable), for: .touchUpInside)
        
        self.view?.addSubview(noData)
        
    }
    
    
    @objc func remvoeNotAvailable(){
        
        if(Common.isConnectedToNetwork() == true){
            noData.removeFromSuperview()
        }
    }
  

    
}


extension GMSMapView {
    
    func setMapStyle() {
        self.mapStyle(withFilename: "map_style", andType: "json")
    }
    func mapStyle(withFilename name: String, andType type: String) {
        do {
            if let styleURL = Bundle.main.url(forResource: name, withExtension: type) {
                self.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
    }
}
