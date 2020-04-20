//
//  AddSatellitePhotoController.swift
//  GrantInspection
//
//  Created by Rajeswaran Thangaperumal on 04/09/2019.
//  Copyright © 2019 MBRHE. All rights reserved.
//

import UIKit
import GoogleMaps
import RxCocoa
import RxSwift

class AddSatellitePhotoController: UIViewController, GMSMapViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var mapViewLabel: UILabel!
    @IBOutlet weak var satelliteLabel: UILabel!
    @IBOutlet weak var deafaultMapLabel: UILabel!
    @IBOutlet weak var selectAreaLabel: UILabel!
    @IBOutlet weak var drawPolygonButton: UIButton!
    @IBOutlet weak var addBuildingPointButton: UIButton!
    @IBOutlet weak var buildingPointsTabelView: UITableView!
    @IBOutlet weak var saveBuildingButton: UIButton!

    var touch : UITouch!
    var lastPoint : CGPoint!
    var currentPoint : CGPoint!
    
    
    var requestObject: Dashboard!
    
    
    var lines : [Line] = []
    let freeform = UIBezierPath()
    var lastPosition: CGPoint?
    var teshapeView = UIView()
    var shapeView:ShapeView!
    var shapesArray:[[ShapeView]]!
    var dataSource:[SatelliteImageData]!
    var polygonCount : Int = 0
    var topShapetag = 0
    
    var drawPolygonBuildingPointDict = [Int : Any]()
    var buildingPointViewArr = [Int]()
    
    var smallViewTag = 1000
    var currentEditVwTag : Int = 0
    var currentSectionEdit : Int = 0
    var createVwTag : Int = 0
    var isAddBuildingPointsInExistingVw : Bool = false
    var isDeletingClick : Bool = false
    
    var maxVwCreated = [Int : Int]()
    var keyUsedInPolygon = [Int]()
    var txtFldTagWithText = [Int : String]()
    
    @IBOutlet weak var googleMapVw: UIView!
    
    var allPolygonDraw = [String : [Any]]()
    
    var onlyOnePolygonCanDraw : Bool = false
    
    var mapView: GMSMapView!
    
    private let disposeBag = DisposeBag()
    var viewModel: SatelliteViewModel!
    var satellitePayload = SatelliteResponsePayload()
    var imageTypeInt = Int()
    
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("QWE   ", requestObject)
        
        viewModel = SatelliteViewModel(SatelliteServiceCall())

        // Do any additional setup after loading the view.
        navigationBarSetup()
        tableViewSetUp()
        
        freeform.move(to: CGPoint(x: 350, y: 150))
        freeform.addLine(to: CGPoint(x: 350, y: 250))
        freeform.addLine(to: CGPoint(x: 650, y: 250))
        freeform.addLine(to: CGPoint(x: 650, y: 150))
        freeform.close()
        
        
        let shapeLayer = CAShapeLayer()
        
        // The Bezier path that we made needs to be converted to
        // a CGPath before it can be used on a layer.
        shapeLayer.path = freeform.cgPath
        
        // apply other properties related to the path
        shapeLayer.strokeColor = UIColor.blue.cgColor
        shapeLayer.fillColor = UIColor.green.cgColor
        shapeLayer.lineWidth = 1.0
        //self.view.layer.addSublayer(shapeLayer)
        teshapeView.frame = CGRect(x: 50, y: 200, width: 200, height: 200)
        teshapeView.backgroundColor = .red
        
        UserDefaults.standard.set(nil, forKey: "AllPolygonDraw")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        localizationSetUp()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // UserDefaults.standard.set(allPolygonDraw, forKey: "AllPolygonDraw")
        
        mapViewLoad()
        
        if (UserDefaults.standard.value(forKey: "AllPolygonDraw") != nil) {
            
            allPolygonDraw = UserDefaults.standard.value(forKey: "AllPolygonDraw") as! [String : [Any]]
            
            //loadAllPolygonsInView()
        }
        
        if Common.isConnectedToNetwork() {
            GetCoordinatesApiCall()
        }
        else {
            Common.showToaster(message: "check_Internet_Connectivity_issue".ls)
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    //MARK:- LOADING MAP VIEW
    func mapViewLoad() {
        
        let hydeParkLocation = CLLocationCoordinate2D(latitude: Double(requestObject.plot.latitude)!, longitude: Double(requestObject.plot.longitude)!)
        let camera = GMSCameraPosition.camera(withTarget: hydeParkLocation, zoom: 20)
        
        mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: 0, width: googleMapVw.frame.width, height: googleMapVw.frame.height), camera: camera)
        mapView.isMyLocationEnabled = false
        mapView.settings.myLocationButton = false
        mapView.delegate = self
        
        self.googleMapVw.addSubview(mapView)
        
        let customVw = UIView(frame: CGRect(x: 10, y: 10, width: 200, height: 100))
        customVw.backgroundColor = UIColor.yellow.withAlphaComponent(0.7)
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: Double(requestObject.plot.latitude)!, longitude: Double(requestObject.plot.longitude)!)
        marker.title = "Dubai"
        marker.snippet = "Finance Centre"
        marker.isDraggable = true
        marker.map = mapView
        marker.tracksViewChanges = true
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        return false
    }
    
    //MARK:- MAP VIEW CHANGE
    @IBAction func openSatelliteView(_ sender: UIButton) {
        self.mapView.mapType = .satellite
        self.imageTypeInt = 2
    }
    
    @IBAction func openTerrainView(_ sender: UIButton) {
        self.mapView.mapType = .normal
        self.imageTypeInt = 0
    }
    
    
    
    //MARK:- VIEW MODEL CONFIG
    func viewModelConfiguration(inputModel: SatelliteInputModel) {
        
        Common.showActivityIndicator()
        
        viewModel.input.postCoordinateRequest.asObserver().onNext(inputModel)
        viewModel.output.coordinateResponse.subscribe(onNext: { [unowned self](response) in

            print("SUcccc:::response:::     ", response)
            
            Common.hideActivityIndicator()
            Common.showToaster(message: "Successfully Added".ls)
            
            
        }) .disposed(by: disposeBag)

        viewModel.output.errorsObservable
            .subscribe(onNext: { [unowned self] (error) in
                
                Common.hideActivityIndicator()
                let errorMessage = (error as NSError).domain
                if !errorMessage.isEmpty{
                    
                    Common.showToaster(message: errorMessage)
                }else {
                    Common.showToaster(message: "bad_Gateway".ls)
                }
                
            })
            .disposed(by: disposeBag)
        
    }
    
    //MARK:- GET API CALL - COORDINATES
    func GetCoordinatesApiCall() {
        Common.showActivityIndicator()
        
        let applicationNO = "\(requestObject.applicationNo)"
        let applicationID = "\(requestObject.applicantId)"
        let serviceType = "\(requestObject.serviceTypeId)"
        
        viewModel.input.applicantId.asObserver().onNext(applicationID)
        viewModel.input.applicationNo.asObserver().onNext(applicationNO)
        viewModel.input.serviceType.asObserver().onNext(serviceType)
        
        viewModel.output.getCoordinateResponse.subscribe(onNext: { [unowned self](response) in
            
            //print("GET_SUcccc:::response:::     ", response)
            
            self.satellitePayload = response.payload
            print("PaylDD     ",self.satellitePayload)
            
            if self.satellitePayload.plotCoordinate != "" && self.satellitePayload.polygons.polygonTAG != "" {
                
                self.loadAllPolygonsInView()
            }
            
            Common.hideActivityIndicator()
            
            
        }) .disposed(by: disposeBag)
        
        viewModel.output.errorsObservable
        .subscribe(onNext: { [unowned self] (error) in
            
            Common.hideActivityIndicator()
            let errorMessage = (error as NSError).domain
            if !errorMessage.isEmpty{
                
                Common.showToaster(message: errorMessage)
            }else {
                Common.showToaster(message: "bad_Gateway".ls)
            }
            
        })
        .disposed(by: disposeBag)
    }


    
    //MARK:- LOAD POLYGON FROM API
    func loadAllPolygonsInView() {
        
        isAddBuildingPointsInExistingVw = false
        isDeletingClick = false
        
        let polyTopLeftLatLong = satellitePayload.polygons.polygonPoint.topLeft.split(separator: ",")
        let firstSideLatLong = CLLocationCoordinate2D(latitude: CLLocationDegrees(Double(polyTopLeftLatLong[0])!), longitude: CLLocationDegrees(Double(polyTopLeftLatLong[1])!))
        
        let polyTopRightLatLong = satellitePayload.polygons.polygonPoint.topRight.split(separator: ",")
        let secondSideLatLong = CLLocationCoordinate2D(latitude: CLLocationDegrees(Double(polyTopRightLatLong[0])!), longitude: CLLocationDegrees(Double(polyTopRightLatLong[1])!))
        
        let polyBottomRightLatLong = satellitePayload.polygons.polygonPoint.bottomRight.split(separator: ",")
        let thirdSideLatLong = CLLocationCoordinate2D(latitude: CLLocationDegrees(Double(polyBottomRightLatLong[0])!), longitude: CLLocationDegrees(Double(polyBottomRightLatLong[1])!))
        
        let polyBottomLeftLatLong = satellitePayload.polygons.polygonPoint.bottomLeft.split(separator: ",")
        let fourthSideLatLong = CLLocationCoordinate2D(latitude: CLLocationDegrees(Double(polyBottomLeftLatLong[0])!), longitude: CLLocationDegrees(Double(polyBottomLeftLatLong[1])!))
        
        let firstCGPoint = mapView.projection.point(for: firstSideLatLong)
        let secondCGPoint = mapView.projection.point(for: secondSideLatLong)
        let thirdCGPoint = mapView.projection.point(for: thirdSideLatLong)
        let fourthCGPoint = mapView.projection.point(for: fourthSideLatLong)
        
        let shapeView = ShapeView()
        
        shapeView.frame.origin.x = firstCGPoint.x //+ (self.googleMapVw.superview?.frame.origin.x)!
        shapeView.frame.origin.y = firstCGPoint.y //+ 50
        shapeView.frame.size.width = secondCGPoint.x - firstCGPoint.x
        shapeView.frame.size.height = fourthCGPoint.y - firstCGPoint.y
        shapeView.layer.borderColor = UIColor.orange.cgColor
        shapeView.layer.borderWidth = 4.0
        shapeView.backgroundColor = UIColor.orange.withAlphaComponent(0.0)
        shapeView.tag = Int(satellitePayload.polygons.polygonTAG)!
        
        print("shapeView     ", shapeView)
        
        if satellitePayload.imageType == 0 {
            self.mapView.mapType = .normal
        }else if satellitePayload.imageType == 1
        {
            self.mapView.mapType = .hybrid
        }else if satellitePayload.imageType == 2
        {
            self.mapView.mapType = .satellite
        }
        
        self.googleMapVw.addSubview(shapeView)
        
        onlyOnePolygonCanDraw = true
        
        keyUsedInPolygon.append(Int(satellitePayload.polygons.polygonTAG)!)
        buildingPointViewArr.removeAll()
        drawPolygonBuildingPointDict[Int(satellitePayload.polygons.polygonTAG)!] = buildingPointViewArr
        
        if satellitePayload.buildingPoints.count > 0 {
            loadingBuildPointsinPolygon(superView: shapeView)
        }
        
        removeAllMovingViews()
        
        polygonCount = Int(satellitePayload.polygons.polygonTAG)!
        topShapetag = polygonCount
        dataSource = [SatelliteImageData(polygon: polygonCount, buildingPoints: nil)]
        topShapetag = polygonCount
        currentEditVwTag = polygonCount
        currentSectionEdit = polygonCount
        smallViewTag = 0
        showPolygonMovingKeys(tagValue: polygonCount)
        
        
        print("\n\nDraw_pol____::   ", drawPolygonBuildingPointDict)
        print("key_usd_poly___::   ", keyUsedInPolygon)
        print("build_pt_arr___::   ", buildingPointViewArr)
        print("maxVwCreated_pt_arr___::   ", maxVwCreated)
        
        
        buildingPointsTabelView.reloadData()
    }
    
    func loadingBuildPointsinPolygon(superView: ShapeView) {
        
        for buidingPoint in satellitePayload.buildingPoints {
            
            let polyTopLeftLatLong = buidingPoint.topLeft.split(separator: ",")
            let firstSideLatLong = CLLocationCoordinate2D(latitude: CLLocationDegrees(Double(polyTopLeftLatLong[0])!), longitude: CLLocationDegrees(Double(polyTopLeftLatLong[1])!))
            
            let polyTopRightLatLong = buidingPoint.topRight.split(separator: ",")
            let secondSideLatLong = CLLocationCoordinate2D(latitude: CLLocationDegrees(Double(polyTopRightLatLong[0])!), longitude: CLLocationDegrees(Double(polyTopRightLatLong[1])!))
            
            let polyBottomRightLatLong = buidingPoint.bottomRight.split(separator: ",")
            let thirdSideLatLong = CLLocationCoordinate2D(latitude: CLLocationDegrees(Double(polyBottomRightLatLong[0])!), longitude: CLLocationDegrees(Double(polyBottomRightLatLong[1])!))
            
            let polyBottomLeftLatLong = buidingPoint.bottomLeft.split(separator: ",")
            let fourthSideLatLong = CLLocationCoordinate2D(latitude: CLLocationDegrees(Double(polyBottomLeftLatLong[0])!), longitude: CLLocationDegrees(Double(polyBottomLeftLatLong[1])!))
            
            let firstCGPoint = mapView.projection.point(for: firstSideLatLong)
            let secondCGPoint = mapView.projection.point(for: secondSideLatLong)
            let thirdCGPoint = mapView.projection.point(for: thirdSideLatLong)
            let fourthCGPoint = mapView.projection.point(for: fourthSideLatLong)
            
            print("sUUup_fra   ", superView.frame)
            print("firstCGPoint_fra   ", firstCGPoint)
            
            let polyView = ShapeView()
            

            
            polyView.frame.origin.x = abs(superView.frame.origin.x - firstCGPoint.x)
            polyView.frame.origin.y = abs(superView.frame.origin.y - firstCGPoint.y) //firstCGPoint.y
            polyView.frame.size.width = secondCGPoint.x - firstCGPoint.x
            polyView.frame.size.height = fourthCGPoint.y - firstCGPoint.y
            
            polyView.layer.borderColor = UIColor(red: 131/255, green: 205/255, blue: 254/255, alpha: 1.0).cgColor
            polyView.layer.borderWidth = 2.0
            
            polyView.backgroundColor = UIColor.white.withAlphaComponent(1.0)
            polyView.tag = Int(buidingPoint.buildingTAG)!
            
            let bpView = Bundle.main.loadNibNamed("BuildingPoint", owner: self, options: nil)![0] as! BuildingPointView
                            
            bpView.editButton.layer.cornerRadius = 4
            bpView.editButton.layer.borderColor = UIColor.lightGray.cgColor
            bpView.editButton.layer.borderWidth = 0.5
 
            bpView.deleteButton.layer.cornerRadius = 4
            bpView.deleteButton.layer.borderColor = UIColor.lightGray.cgColor
            bpView.deleteButton.layer.borderWidth = 0.5

            bpView.nameTxtFle.delegate = self
            bpView.nameTxtFle.borderStyle = .none
            
            bpView.nameLbl.text = buidingPoint.buildingName
            bpView.editButton.addTarget(self, action: #selector(self.editButtonTappedInSection), for: .touchUpInside)
            bpView.deleteButton.addTarget(self, action: #selector(self.deleteButtonTappedInSection), for: .touchUpInside)
            
            bpView.editButton.tag = Int(buidingPoint.buildingTAG)!
            bpView.deleteButton.tag = Int(buidingPoint.buildingTAG)!
            bpView.nameTxtFle.tag = Int(buidingPoint.buildingTAG)!
            bpView.stckVw.tag = Int(buidingPoint.buildingTAG)!
            bpView.backgroundColor = .clear
            polyView.backgroundColor = .clear
            polyView.addSubview(bpView)
            addConstraintsToTextField(textField: bpView)
            superView.addSubview(polyView)
            
            buildingPointViewArr.append(Int(buidingPoint.buildingTAG)!)
            
            txtFldTagWithText[Int(buidingPoint.buildingTAG)!] = buidingPoint.buildingName
        }
        
        if buildingPointViewArr.count > 0 {
            
            maxVwCreated[superView.tag] = buildingPointViewArr.max()! % 1000
        }
        
        drawPolygonBuildingPointDict[superView.tag] = buildingPointViewArr //satellitePayload.buildingPoints
        
    }
   
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        
        if let touch = touches.first{
            
            let position = touch.location(in: view)
            if let lastPosition = self.lastPosition {
                self.drawLineFromPoint(start: lastPosition, toPoint: position, ofColor: UIColor.red, inView: self.view)
            }
            self.lastPosition = position
            // View the x and y coordinates
            let dot = UIView(frame: CGRect(x: position.x, y: position.y, width: 10, height: 10))
            dot.backgroundColor = .red
            print(position)
            
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let newPoint = touches.first?.location(in: self.view)
        //print(newPoint)
        let hhh = newPoint?.x ?? 0 - teshapeView.frame.maxX
     
       
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first{
            
            let position = touch.location(in: view)
            if let lastPosition = self.lastPosition {
                self.drawLineFromPoint(start: lastPosition, toPoint: position, ofColor: UIColor.red, inView: self.view)
            }

            
        }
    }
    
    func drawLineFromPoint(start : CGPoint, toPoint end:CGPoint, ofColor lineColor: UIColor, inView view:UIView) {
        
        let path = UIBezierPath()
        path.move(to: start)
        path.addLine(to: end)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor.green.cgColor
        shapeLayer.lineWidth = 1.0
        
    }
    
    func tableViewSetUp() {
        buildingPointsTabelView.register(UINib(nibName: "\(BuildingPointCell.self)", bundle: Bundle.main), forCellReuseIdentifier: BuildingPointCell.identifier)
        buildingPointsTabelView.dataSource = self
        buildingPointsTabelView.delegate = self
        buildingPointsTabelView.tableFooterView = UIView()
    }
    
    func localizationSetUp() {
        mapViewLabel.text = "mapView_lbl".ls
        satelliteLabel.text = "satellite_btn".ls
        deafaultMapLabel.text = "defaultMapButton_btn".ls
        selectAreaLabel.text = "select_area_lbl".ls
        drawPolygonButton.setTitle("drawPolygon_btn".ls, for: .normal)
        addBuildingPointButton.setTitle("addBuildingPoint_btn".ls, for: .normal)
        saveBuildingButton.setTitle("saveBuilding_btn".ls, for: .normal)
    }
    
    func navigationBarSetup() {
        navigationController?.navigationBar.barTintColor = UIColor(red: 75/255, green: 75/255, blue: 75/255, alpha: 1.0)
        navigationController?.navigationBar.tintColor = .white
        setTitle("addSatellitePhoto_lbl".ls, andImage: #imageLiteral(resourceName: "satelliteHeader_icon"))
    }
    
    
    //MARK:- ADD POLYGON
    @IBAction func drawPolygonAction(sender: UIButton) {
        
        if onlyOnePolygonCanDraw {
            Common.showToaster(message: "one_polygon_can_draw".ls)
            return
        }
        
        isAddBuildingPointsInExistingVw = false
        isDeletingClick = false
        let shapeView = ShapeView()
        
        shapeView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        shapeView.backgroundColor = .clear
        self.googleMapVw.clipsToBounds = true
//        shapeView.clipsToBounds = true
        shapeView.center = self.googleMapVw.center
        self.googleMapVw.addSubview(shapeView)

        
        if polygonCount != 0 {
            
            removeAllMovingViews()
        }
        
        polygonCount = polygonCount + 1
                
        buildingPointViewArr.removeAll()
        drawPolygonBuildingPointDict[polygonCount] = buildingPointViewArr
        smallViewTag = 0
        dataSource = [SatelliteImageData(polygon: polygonCount, buildingPoints: nil)]
        shapeView.tag = polygonCount
        topShapetag = polygonCount
        currentEditVwTag = polygonCount
        currentSectionEdit = polygonCount
        keyUsedInPolygon.append(polygonCount)
        buildingPointsTabelView.reloadData()
       
        onlyOnePolygonCanDraw = true
        print("\n\nPoly_Click   ", drawPolygonBuildingPointDict)
        print("PLykeyUsedInPolygon   ", keyUsedInPolygon)
    }
    
    func scrollToLastRow() {
        
        let scrollPoint = CGPoint(x: 0, y: self.buildingPointsTabelView.contentSize.height - self.buildingPointsTabelView.frame.size.height)
        self.buildingPointsTabelView.setContentOffset(scrollPoint, animated: true)
        
    }
    
    //MARK:- ADD BUILDING POINTS
    @IBAction func drawBuildingPointAction(sender: UIButton) {
        
        
        if isDeletingClick {
            Common.showToaster(message: "select_polygon_to_add_building_point".ls )
            return
        }
        
        removeAllMovingViews()
        
        let sView = ShapeView()
        sView.frame = CGRect(x: 10, y: 10, width: 170, height: 170)
        sView.backgroundColor = .clear
        
        
        
        let bpView = Bundle.main.loadNibNamed("BuildingPoint", owner: self, options: nil)![0] as! BuildingPointView
        
        bpView.editButton.layer.cornerRadius = 4
        bpView.editButton.layer.borderColor = UIColor.lightGray.cgColor
        bpView.editButton.layer.borderWidth = 0.5
        bpView.deleteButton.layer.cornerRadius = 4
        bpView.deleteButton.layer.borderColor = UIColor.lightGray.cgColor
        bpView.deleteButton.layer.borderWidth = 0.5
        bpView.nameTxtFle.delegate = self
        

        if isAddBuildingPointsInExistingVw {
            // topShapetag smallViewTag
            
            let currentPolygonKey = currentSectionEdit // currentEditVwTag.getFirstValueFromDigits()
            
            var existingBuildingPointCount = 0
            
            if drawPolygonBuildingPointDict.count > 0 {
                
                existingBuildingPointCount = (drawPolygonBuildingPointDict[currentPolygonKey] as! [Any]).count
            }
            else {
                existingBuildingPointCount = 0
            }
            
            topShapetag = currentPolygonKey
        }
        
        if maxVwCreated.keys.contains(topShapetag) {
            
            smallViewTag = maxVwCreated[topShapetag]!
            smallViewTag = smallViewTag + 1
            maxVwCreated[topShapetag] = smallViewTag
        }
        else {
            
            smallViewTag = smallViewTag + 1
            maxVwCreated[topShapetag] = smallViewTag
        }
        
        createVwTag = topShapetag * 1000 + smallViewTag
        
        sView.tag = createVwTag //polygonCount * 1000 + smallViewTag
        bpView.editButton.tag = createVwTag
        bpView.deleteButton.tag = createVwTag
        bpView.nameTxtFle.tag = createVwTag
        bpView.stckVw.tag = createVwTag
        bpView.nameTxtFle.borderStyle = .none
        currentEditVwTag = createVwTag
        txtFldTagWithText[createVwTag] = "Building \(smallViewTag)"
        bpView.nameLbl.text = "Building \(smallViewTag)"
        
        bpView.editButton.addTarget(self, action: #selector(self.editButtonTappedInSection), for: .touchUpInside)
        bpView.deleteButton.addTarget(self, action: #selector(self.deleteButtonTappedInSection), for: .touchUpInside)
        
        bpView.backgroundColor = .clear
        sView.addSubview(bpView)
        sView.frameSetUp()
        sView.buildingPointSetup()
        addConstraintsToTextField(textField: bpView)
        
        if let _ = dataSource {
            for polygon in self.googleMapVw.subviews where polygon.tag == topShapetag {
                polygon.addSubview(sView)
            }
        }
        buildingPointViewArr.removeAll()
        
        if let _ = dataSource {
            for polygon in self.googleMapVw.subviews where polygon.tag == topShapetag {
                for subVw in polygon.subviews where subVw.tag > topShapetag * 1000 {
                    buildingPointViewArr.append(subVw.tag)
                }
            }
            drawPolygonBuildingPointDict[topShapetag] = buildingPointViewArr
        }
        
        buildingPointsTabelView.reloadData()
        
        print("Building_Ptd_Poly_Click   ", drawPolygonBuildingPointDict)
        
    }
    
    //MARK:- SAVE POLYGON ACTION
    @IBAction func savePolygonAction(_ sender: UIButton) {

        var boxFrame = CGRect()
        
        var topLeft = CGPoint()
        var topRight = CGPoint()
        var bottomRight = CGPoint()
        var bottomLeft = CGPoint()
        
        let allKeys = drawPolygonBuildingPointDict.keys
    
        var polygonObjArr = [Any]()
        
        let inputModel = SatelliteInputModel()
        
        for keys in allKeys {
            for createdView in self.googleMapVw.subviews where createdView.tag == keys {

                print("\n\nFRAmee___  ", createdView.frame)

                boxFrame.origin.x =             createdView.frame.origin.x //- (googleMapVw.superview?.frame.origin.x)!
                boxFrame.origin.y =             createdView.frame.origin.y //- 50
                boxFrame.size.width =     createdView.frame.width
                boxFrame.size.height =    createdView.frame.height

                print("\n\nBox__FRAmee___  ", boxFrame)
                
                topLeft = CGPoint(x: boxFrame.origin.x, y: boxFrame.origin.y)
                topRight = CGPoint(x: boxFrame.origin.x + boxFrame.size.width, y: boxFrame.origin.y)
                bottomRight = CGPoint(x: boxFrame.origin.x + boxFrame.size.width, y: boxFrame.origin.y + boxFrame.size.height)
                bottomLeft = CGPoint(x: boxFrame.origin.x, y: boxFrame.origin.y + boxFrame.size.height)
                
                let firstSideLatLong = mapView.projection.coordinate(for: topLeft)
                let secondSideLatLong = mapView.projection.coordinate(for: topRight)
                let thirdSideLatLong = mapView.projection.coordinate(for: bottomRight)
                let fourthSideLatLong = mapView.projection.coordinate(for: bottomLeft)
            
                let finalPath = GMSMutablePath()
                finalPath.add(firstSideLatLong)
                finalPath.add(secondSideLatLong)
                finalPath.add(thirdSideLatLong)
                finalPath.add(fourthSideLatLong)
                finalPath.add(firstSideLatLong)
                //path.add(CLLocationCoordinate2D(latitude: 40.602216, longitude: -74.22655))
                let finalPolyLine = GMSPolyline(path: finalPath)
                //finalPolyLine.map = mapView
                finalPolyLine.strokeColor = UIColor.orange
                finalPolyLine.strokeWidth = 4
                
                let polygonID = keys
                let mapZoom = mapView.camera.zoom
                
                let polygonPoint = [
                    "topLeft" : ["latitude": firstSideLatLong.latitude, "longitude": firstSideLatLong.longitude],
                    "topRight" : ["latitude": secondSideLatLong.latitude, "longitude": secondSideLatLong.longitude],
                    "bottomRight" : ["latitude": thirdSideLatLong.latitude, "longitude": thirdSideLatLong.longitude],
                    "bottomLeft" : ["latitude": fourthSideLatLong.latitude, "longitude": fourthSideLatLong.longitude]
                    ]
                
            
                let polyLatLong = PolygonLatLong()
                polyLatLong.topLeft = firstSideLatLong.latitude.description + "," + firstSideLatLong.longitude.description
                polyLatLong.topRight = secondSideLatLong.latitude.description + "," + secondSideLatLong.longitude.description
                polyLatLong.bottomRight = thirdSideLatLong.latitude.description + "," + thirdSideLatLong.longitude.description
                polyLatLong.bottomLeft = fourthSideLatLong.latitude.description + "," + fourthSideLatLong.longitude.description
                
                
                let subViewsCount = drawPolygonBuildingPointDict[keys] as! [Int]
                
                var buildingPtArr = [Any]()
                
                
                let polygonDetail = PolygonDetails()
                
                for vwTag in subViewsCount {
                    
                    for bpView in createdView.subviews where bpView.tag == vwTag {
                        
                        var boxFrameBP = CGRect()
                        
                        boxFrameBP.origin.x =             bpView.frame.origin.x + boxFrame.origin.x
                        boxFrameBP.origin.y =             bpView.frame.origin.y + boxFrame.origin.y
                        boxFrameBP.size.width =     bpView.frame.width
                        boxFrameBP.size.height =    bpView.frame.height

                        print("\n\nBox__FRAmee___BPP  ", boxFrameBP)
                        
                        topLeft = CGPoint(x: boxFrameBP.origin.x, y: boxFrameBP.origin.y)
                        topRight = CGPoint(x: boxFrameBP.origin.x + boxFrameBP.size.width, y: boxFrameBP.origin.y)
                        bottomRight = CGPoint(x: boxFrameBP.origin.x + boxFrameBP.size.width, y: boxFrameBP.origin.y + boxFrameBP.size.height)
                        bottomLeft = CGPoint(x: boxFrameBP.origin.x, y: boxFrameBP.origin.y + boxFrameBP.size.height)
                        
                        let firstSideLatLong = mapView.projection.coordinate(for: topLeft)
                        let secondSideLatLong = mapView.projection.coordinate(for: topRight)
                        let thirdSideLatLong = mapView.projection.coordinate(for: bottomRight)
                        let fourthSideLatLong = mapView.projection.coordinate(for: bottomLeft)
                    
                        let finalPath = GMSMutablePath()
                        finalPath.add(firstSideLatLong)
                        finalPath.add(secondSideLatLong)
                        finalPath.add(thirdSideLatLong)
                        finalPath.add(fourthSideLatLong)
                        finalPath.add(firstSideLatLong)
                
                        let finalPolyLine = GMSPolyline(path: finalPath)
                        //finalPolyLine.map = mapView
                        
                        finalPolyLine.strokeColor = UIColor(red: 131/255, green: 205/255, blue: 254/255, alpha: 1.0)
                        finalPolyLine.strokeWidth = 2
                        
                        let buildingID = vwTag
                        let buildingName = txtFldTagWithText[vwTag]
                        
                        let buildingPoint = [
                            "topLeft" : ["latitude": firstSideLatLong.latitude, "longitude": firstSideLatLong.longitude],
                            "topRight" : ["latitude": secondSideLatLong.latitude, "longitude": secondSideLatLong.longitude],
                            "bottomRight" : ["latitude": thirdSideLatLong.latitude, "longitude": thirdSideLatLong.longitude],
                            "bottomLeft" : ["latitude": fourthSideLatLong.latitude, "longitude": fourthSideLatLong.longitude]
                        ]
                        
                        let buildingPointObj = [
                            
                            "buildingTAG" : buildingID,
                            "buildingName" : buildingName,
                            "buildingPoint" : buildingPoint,
                            
                        ] as [String : Any]
                        
                        buildingPtArr.append(buildingPointObj)
                        
                        //let buildLatLong = BuildingLatLong()
                        let buildPointDetail = BuildingPointDetails()
                        buildPointDetail.buildingTAG = String(buildingID)
                        buildPointDetail.buildingName = buildingName!
                        
                        buildPointDetail.topLeft = firstSideLatLong.latitude.description + "," + firstSideLatLong.longitude.description
                        buildPointDetail.topRight = secondSideLatLong.latitude.description + "," + secondSideLatLong.longitude.description
                        buildPointDetail.bottomRight = thirdSideLatLong.latitude.description + "," + thirdSideLatLong.longitude.description
                        buildPointDetail.bottomLeft = fourthSideLatLong.latitude.description + "," + fourthSideLatLong.longitude.description
                        
                        
                        inputModel.buildingPoints.append(buildPointDetail)
                    }
                }
                
                let polygonDict = [
                    "polygonTAG" : polygonID,
                    "mapZoom" : mapZoom,
                    "polygonPoint" : polygonPoint,
                    "buildingPoints" : buildingPtArr
                ] as [String : Any]
                
                polygonObjArr.append(polygonDict)
                
                polygonDetail.polygonTAG        = String(polygonID)
                polygonDetail.mapZoom           = String(mapZoom)
                polygonDetail.polygonPoint      = polyLatLong
                
                inputModel.polygons = polygonDetail
            }
        }
        
        let applicationNO = "\(requestObject.applicationNo)"
        let applicationID = "\(requestObject.applicantId)"
        let serviceType = "\(requestObject.serviceTypeId)"
        
        inputModel.applicantId = applicationID
        inputModel.applicationNo = applicationNO
        inputModel.serviceTypeId = serviceType
        inputModel.plotCoordinate = "\(requestObject.plot.latitude),\(requestObject.plot.longitude)"
        inputModel.imageType = self.imageTypeInt
        print("Final_model:::::        ", inputModel)
        
        if Common.isConnectedToNetwork() {
            viewModelConfiguration(inputModel: inputModel) // API CALL
        }
        else {
            Common.showToaster(message: "check_Internet_Connectivity_issue".ls)
        }
        
        if polygonObjArr.count > 0 {
            
            allPolygonDraw["Polygons"] = polygonObjArr
            hideAndShowAllPolygon(show: true)
            removeAllMovingViews()
            
            isDeletingClick = true
            buildingPointsTabelView.reloadData()
            
            //UserDefaults.standard.set(allPolygonDraw, forKey: "AllPolygonDraw")
            print("Final_Polygon_API:::::       ", allPolygonDraw)
        }
        else {
            //UserDefaults.standard.set(nil, forKey: "AllPolygonDraw")
        }
    }
    func addConstraintsToTextField(textField: UIView) {
        textField.translatesAutoresizingMaskIntoConstraints = false

        
        textField.leadingAnchor.constraint(equalTo: textField.superview!.leadingAnchor, constant: 0).isActive = true
        textField.trailingAnchor.constraint(equalTo: textField.superview!.trailingAnchor, constant: 0).isActive = true
        textField.topAnchor.constraint(equalTo: textField.superview!.topAnchor, constant: 0).isActive = true
        textField.bottomAnchor.constraint(equalTo: textField.superview!.bottomAnchor, constant: 0).isActive = true
    }

}

extension AddSatellitePhotoController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return keyUsedInPolygon.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let drww = drawPolygonBuildingPointDict[keyUsedInPolygon[section]] as! [Any]
        return drww.count
        

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BuildingPointCell.identifier, for: indexPath) as? BuildingPointCell else { return UITableViewCell() }
    
        let pointTagVal = (drawPolygonBuildingPointDict[keyUsedInPolygon[indexPath.section]] as! [Any])[indexPath.row] as! Int
        cell.editBtn.tag = pointTagVal // (indexPath.section + 1) * 1000 + indexPath.row + 1
        cell.smallPointIndicatorImg.tag = pointTagVal //(indexPath.section + 1) * 1000 + indexPath.row + 1
        
        cell.editBtn.addTarget(self, action: #selector(self.editButtonTappedInSection), for: .touchUpInside)
        
        cell.deleteBtn.tag = pointTagVal// (indexPath.section + 1) * 1000 + indexPath.row + 1
        cell.deleteBtn.addTarget(self, action: #selector(self.deleteButtonTappedInSection), for: .touchUpInside)
        
        cell.smallPointIndicatorImg.changeTintColor(color: UIColor.lightGray)
        
        if isDeletingClick == false && cell.smallPointIndicatorImg.tag == currentEditVwTag {
            
            cell.smallPointIndicatorImg.changeTintColor(color: UIColor.red)
            
        }
        
        if txtFldTagWithText.keys.contains(pointTagVal) {
            
            cell.buildingPtName.text = txtFldTagWithText[pointTagVal]
        }
        
        cell.stackVw.tag = keyUsedInPolygon[indexPath.section] //indexPath.section + 1
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 32
    }

    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView()
        headerView.backgroundColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1.0)

        let headerLabel = UILabel(frame: CGRect(x: 8, y: 0, width:
            tableView.bounds.size.width, height: 32))
        headerLabel.font = UIFont.boldSystemFont(ofSize: 15)
        headerLabel.textColor = UIColor.darkGray
        headerLabel.text = "Polygon \(String(section + 1))"
        //headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)

        let deletebutton = UIButton(frame: CGRect(x: tableView.bounds.size.width - 32, y: 0, width:
        32, height: 32))
        deletebutton.setImage(UIImage(named: "delete_icon"), for: .normal)
        deletebutton.addTarget(self, action: #selector(self.deleteButtonTappedInSection), for: .touchUpInside)
        deletebutton.tag = keyUsedInPolygon[section]  //section + 1
        
        headerView.addSubview(deletebutton)
        
        let editbutton = UIButton(frame: CGRect(x: tableView.bounds.size.width - 32 - 32, y: 0, width:
        32, height: 32))
        editbutton.setImage(UIImage(named: "edit_icon"), for: .normal)
        editbutton.addTarget(self, action: #selector(self.editButtonTappedInSection), for: .touchUpInside)
        editbutton.tag = keyUsedInPolygon[section] //section + 1
        
        headerView.addSubview(editbutton)
        
        if isDeletingClick == false {
        
            let firstDigit = currentSectionEdit //currentEditVwTag.getFirstValueFromDigits()
            if firstDigit == keyUsedInPolygon[section] {
                
                headerView.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
                
                if currentEditVwTag == editbutton.tag {
                    headerLabel.textColor = UIColor.red
                }
            }
        }
        
        headerView.tag = keyUsedInPolygon[section] //section + 1
        return headerView
    }
    
    // MARK:- EDIT POLYGON & BUILDING POINTS
    @objc func editButtonTappedInSection(sender : UIButton) {
        //Write button action here
        currentSectionEdit = sender.superview!.tag
        
        if sender.tag.description.count == 4 {
            currentSectionEdit =  Int(String(sender.superview!.tag.description.prefix(1)))!
        }
        else if sender.tag.description.count == 5 {
            currentSectionEdit =  Int(String(sender.superview!.tag.description.prefix(2)))!
        }
        else if sender.tag.description.count == 6 {
            currentSectionEdit =  Int(String(sender.superview!.tag.description.prefix(3)))!
        }
        
        isDeletingClick = false
        currentEditVwTag = sender.tag
        removeAllMovingViews()
        showPolygonMovingKeys(tagValue: sender.tag)

        
        buildingPointsTabelView.reloadData()
        
        isAddBuildingPointsInExistingVw = true
    }
    
    // MARK:- DELETE BUILDING POINTS
    @objc func deleteButtonTappedInSection(sender : UIButton) {
        
        print("Dele_tagg  ", sender.tag)
        
        currentSectionEdit =  sender.superview!.tag
        onlyOnePolygonCanDraw = false
        if sender.tag.description.count == 4 {
            currentSectionEdit =  Int(String(sender.superview!.tag.description.prefix(1)))!
            onlyOnePolygonCanDraw = true
        }
        else if sender.tag.description.count == 5 {
            currentSectionEdit =  Int(String(sender.superview!.tag.description.prefix(2)))!
            onlyOnePolygonCanDraw = true
        }
        else if sender.tag.description.count == 6 {
            currentSectionEdit =  Int(String(sender.superview!.tag.description.prefix(3)))!
            onlyOnePolygonCanDraw = true
        }
        
        removeAllMovingViews()
        removeViewFromSatellite(tagValue: sender.tag)
        
        
    }
    
    
    //MARK:- TEXTFIELD DELEGATE
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
            
        for labelVw in (textField.superview?.subviews)! where labelVw.tag == 500 {
            
            labelVw.isHidden = true
        }
        textField.borderStyle = .roundedRect
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        print("textSuspect   \(textField.text)   TAGVAL   \(textField.tag)")
        
        for labelVw in (textField.superview?.subviews)! where labelVw.tag == 500 {
            
            labelVw.isHidden = false
            
            for lab in labelVw.subviews where lab.tag == 501 {
                
                (lab as! UILabel).text = textField.text
            }
        }
        
        txtFldTagWithText[textField.tag] = textField.text
        textField.text = ""
        textField.borderStyle = .none
        buildingPointsTabelView.reloadData()
    }
    
    func removeViewFromSatellite(tagValue: Int) {
        
        let allKeys = drawPolygonBuildingPointDict.keys
        
        var polygonTag = 99999999
        var buildingPointTag = 99999999
        var buildPointRemoved : Bool = false
        
        for keys in allKeys {
            
            for createdView in self.googleMapVw.subviews where createdView.tag == currentSectionEdit {
                
                if keys == tagValue { // POLYGON DELETE
                    
                    polygonTag = keys
                    (createdView as? ShapeView)?.removeFromSuperview()

                    drawPolygonBuildingPointDict.removeValue(forKey: polygonTag)
                    
                    if keyUsedInPolygon.contains(polygonTag) {
                        
                        keyUsedInPolygon = keyUsedInPolygon.filter{$0 != polygonTag}
                    }
                    
                    break
                }
                
                for subVw in createdView.subviews { // BUILDING POINT DELETE
                    
                    if subVw.tag == tagValue {
                        
                        buildingPointTag = tagValue

                        var dictValues = drawPolygonBuildingPointDict[currentSectionEdit] as! [Any]
                        for (i,deleteVw) in dictValues.enumerated() {
                            
                            if (deleteVw as! Int) == buildingPointTag {
                                    
                                dictValues.remove(at: i)
                                break
                            }
                        }
                        
                        drawPolygonBuildingPointDict[currentSectionEdit] = dictValues
                        (subVw as? ShapeView)?.removeFromSuperview()
                        buildPointRemoved = true
                        
                        break
                    }
                }
            }
        }
        
        print("\n\npolygonTag      \(polygonTag)")
        print("buildingPointTag      \(buildingPointTag)")
        print("DLTkeyUsedInPolygon   ", keyUsedInPolygon)
        
        print("\n\nFinally  ", drawPolygonBuildingPointDict)
        
        isDeletingClick = true
        buildingPointsTabelView.reloadData()
    }
    
    func removeAllMovingViews() {
        
        let allKeys = drawPolygonBuildingPointDict.keys
        
        for keys in allKeys {
            
            for createdView in self.googleMapVw.subviews where createdView.tag == keys {
                
                (createdView as! ShapeView).isHideAllMovingViews(yes: true)
                
                for subVw in createdView.subviews {
                    
                    (subVw as? ShapeView)?.isHideAllMovingViews(yes: true)
                }
            }
        }
    }
    
    func hideAndShowAllPolygon(show: Bool) {
        
        let allKeys = drawPolygonBuildingPointDict.keys
        for keys in allKeys {
            for createdView in self.googleMapVw.subviews where createdView.tag == keys {
                createdView.isHidden = !show
            }
        }
    }
    
    func showPolygonMovingKeys(tagValue: Int) {
        
        print("TAGG__gsubVwVw   ", tagValue)
        
        var thisIsForPolygon : Bool = false
        
        // TO SHOW MOVING ICONS IN POLYGON
        for createdView in self.googleMapVw.subviews where createdView.tag == tagValue {
            (createdView as! ShapeView).isHideAllMovingViews(yes: false)
            
            thisIsForPolygon = true
            return
        }
        
        // TO SHOW MOVING ICONS IN BUILDING POINTS
        if thisIsForPolygon == false {
            
            for createdView in self.googleMapVw.subviews {
                
                for subVw in createdView.subviews where subVw.tag == tagValue {
                    
                    (subVw as? ShapeView)?.isHideAllMovingViews(yes: false)
                    return
                }
            }
        }
    }
}


class Line {
    
    var start : CGPoint
    var end : CGPoint
    
    init(start _start : CGPoint , end _end : CGPoint) {
        
        start = _start
        
        end = _end
    }
}

class ShapeView: UIView {
    private let topControlPointView = UIView()
    private let leftControlPointView = UIView()
    private let bottomControlPointView = UIView()
    private let rightControlPointView = UIView()
    
    var isBuildingPoint = false
    var gestureXPos = CGFloat()
    var gestureYPos = CGFloat()
    
   
    let buildingBorderColor = UIColor(red: 131/255, green: 205/255, blue: 254/255, alpha: 1.0)// UIColor(red: 180/255, green: 180/255, blue: 180/255, alpha: 1.0)
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frameSetUp()
         addPanGesture()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.frameSetUp()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        positionControlPoints()
    }
    
    func buildingPointSetup() {
        self.layer.borderColor = buildingBorderColor.cgColor
        self.layer.borderWidth = 2.0
        self.backgroundColor = .clear
    }
    func frameSetUp() {
        //self.tag = 1000
    
        
        topControlPointView.tag = 100
        bottomControlPointView.tag = 100
        leftControlPointView.tag = 111
        rightControlPointView.tag = 111
        self.layer.borderWidth = 4.0
        self.layer.borderColor = UIColor.orange.cgColor
        self.backgroundColor = .clear
        for controlPoint in [topControlPointView, leftControlPointView,
                             bottomControlPointView, rightControlPointView] {
            controlPoint.backgroundColor = .lightGray
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didSwipeOnView(gestureRecognizer:)))
                                controlPoint.addGestureRecognizer(panGesture)
            addSubview(controlPoint)
            self.bringSubviewToFront(controlPoint)
            controlPoint.frame = CGRect(x: 0.0, y: 0.0, width: 50.0, height: 50.0)
            controlPoint.layer.cornerRadius = controlPoint.frame.size.height / 2
        }
    }
    
    func addPanGesture() {

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didSwipeOnParentView(gestureRecognizer:)))
        self.addGestureRecognizer(panGesture)
    
    }
    
    @objc func didSwipeOnParentView(gestureRecognizer: UIPanGestureRecognizer) {
        
        let vDirection = gestureRecognizer.verticalDirection(target: self)
        let hDirection = gestureRecognizer.horizontalDirection(target: self)
        let superViewForPan = gestureRecognizer.view
         let mapViewSuperViewForPan = gestureRecognizer.view?.superview?.superview
        
        if hDirection == .Left
        {
            if self.frame.origin.x < 0 {
                self.frame.origin.x = 0
            }
            
        }else
        {
            let mapSuperViewWidth = Int(CGFloat(mapViewSuperViewForPan?.frame.size.width ?? 0))
            
            let overAllPanOrigin =  CGFloat(superViewForPan?.frame.origin.x ?? 0) + CGFloat(superViewForPan?.frame.size.width ?? 0)
           
            
            
            

            if  Int(overAllPanOrigin) > mapSuperViewWidth
             {
                if gestureXPos == 0.0 {
                     let wid = mapSuperViewWidth - Int(overAllPanOrigin)
                                   
                    self.frame.size.width += CGFloat(wid)
                    print(self.frame.size.width)
                    gestureXPos = CGFloat(mapSuperViewWidth) - self.frame.size.width
                }else
                {
                    self.frame.origin.x = gestureXPos

                }

                 return
             }
        }
        
        if vDirection == .Up {
            
            if self.frame.origin.y < 0 {
                self.frame.origin.y = 0
            }
        }else
        {
           let mapSuperViewHeight = Int(CGFloat(mapViewSuperViewForPan?.frame.size.height ?? 0))
            
            let overAllPanOriginY =  CGFloat(superViewForPan?.frame.origin.y ?? 0) + CGFloat(superViewForPan?.frame.size.height ?? 0)
            
            if  Int(overAllPanOriginY) > mapSuperViewHeight
             {
                if gestureYPos == 0.0
                {
                    let heightForPan = mapSuperViewHeight - Int(overAllPanOriginY)
                    
                    self.frame.size.height += CGFloat(heightForPan)
                    print(self.frame.size.height)
                     gestureYPos = CGFloat(mapSuperViewHeight) - self.frame.size.height
                }else
                {
                    self.frame.origin.y = gestureYPos
                }
    
                
                
                
        
                 return
             }
        }
        

        let translation = gestureRecognizer.translation(in: self)
        
        if let myView = gestureRecognizer.view {
            self.center = CGPoint(x: myView.center.x + translation.x, y: myView.center.y + translation.y)
            
        }
        gestureRecognizer.setTranslation(CGPoint(x: 0, y: 0), in: self)
    }
    
    func isHideAllMovingViews(yes: Bool) {
        
        topControlPointView.isHidden = yes
        leftControlPointView.isHidden = yes
        bottomControlPointView.isHidden = yes
        rightControlPointView.isHidden = yes
        
        self.bringSubviewToFront(topControlPointView)
        self.bringSubviewToFront(leftControlPointView)
        self.bringSubviewToFront(bottomControlPointView)
        self.bringSubviewToFront(rightControlPointView)
    }
    
    private func positionControlPoints(){
        topControlPointView.center = CGPoint(x: bounds.midX, y: 0.0)
        leftControlPointView.center = CGPoint(x: 0.0, y: bounds.midY)
        bottomControlPointView.center = CGPoint(x:bounds.midX, y: bounds.maxY)
        rightControlPointView.center = CGPoint(x: bounds.maxX, y: bounds.midY)
    }
    
   @objc func didSwipeOnView(gestureRecognizer: UIPanGestureRecognizer) {
    var point = gestureRecognizer.location(in: self)
    let panGesture = gestureRecognizer.view
    
    let superViewForPan = gestureRecognizer.view?.superview
    let mapViewSuperViewForPan = gestureRecognizer.view?.superview?.superview
    
    
    
    let vDirection = gestureRecognizer.verticalDirection(target: self)
    let hDirection = gestureRecognizer.horizontalDirection(target: self)

    if panGesture?.tag == 100 {
        if vDirection == .Down {
            //print(" ypos:\(point.y) direction:\(vDirection)")
            panGesture?.center = CGPoint(x: (panGesture?.center.x) ?? 0, y: point.y)
            let val = self.frame.origin.y + (panGesture?.center.y ?? 0)
            
            
            
            if point.y > self.frame.size.height {
                let hee = self.frame.size.height - (panGesture?.center.y ?? 0)
                if hee < 0 {
                   self.frame.size.height += abs(hee)
                }
               
            } else {
                let hee = self.frame.size.height - (panGesture?.center.y ?? 0)
                if hee > 10 {
                    self.frame.origin.y = val
                    self.frame.size.height = hee
                    
                }
               
            }
            
        }else if vDirection == .Up {
            
            let superViewYPos = Int(CGFloat(superViewForPan?.frame.origin.y ?? 0))
            
            if superViewYPos < 5 {
                point.y = 0
                return
            }
            
            if point.y < 0 {
                let vvv =  abs(point.y)
                
                self.frame.origin.y -= vvv
                self.frame.size.height += vvv
            } else if point.y > 0  {
              
                self.frame.size.height -= self.frame.size.height - point.y
            }
            
            if self.frame.origin.y < 0 {
                self.frame.origin.y = 0
            }
            
            let mapSuperViewHeight = Int(CGFloat(mapViewSuperViewForPan?.frame.size.height ?? 0))
            
            if  Int(self.frame.size.height) > mapSuperViewHeight
            {
                self.frame.size.height = mapViewSuperViewForPan?.frame.size.height ?? 0
            }
            
            panGesture?.center = CGPoint(x: (panGesture?.center.x ?? 0), y: point.y)
           
            
        }
    }
    if panGesture?.tag == 111 {
       
        if hDirection == .Left {
            
            let superViewXPos = Int(CGFloat(superViewForPan?.frame.origin.x ?? 0))
            
             
            if superViewXPos < 5
            {
                point.x = 0
                return
            }
            if point.x < 0 {
                let vvv =  abs(point.x)
                self.frame.origin.x -= vvv
                self.frame.size.width += vvv

            } else if point.x > 0  {
                
                self.frame.size.width -= self.frame.size.width - point.x
                
            }
            
            if self.frame.origin.x < 0 {
                self.frame.origin.x = 0
            }
            
            
            
            let mapSuperViewWidth = Int(CGFloat(mapViewSuperViewForPan?.frame.size.width ?? 0))
           
            
            
            
            if  Int(self.frame.size.width) > mapSuperViewWidth
            {
                self.frame.size.width = mapViewSuperViewForPan?.frame.size.width ?? 0
            }
            
            
            

            panGesture?.center = CGPoint(x: point.x, y: (panGesture?.center.y ?? 0))
           
        }else if hDirection == .Right {
             panGesture?.center = CGPoint(x: point.x, y: (panGesture?.center.y ?? 0))
            let val = self.frame.origin.x + (panGesture?.center.x ?? 0)
            
            if point.x > self.frame.size.width {
                
                let hee = self.frame.size.width - (panGesture?.center.x ?? 0)
                if hee < 0 {
                    self.frame.size.width += abs(hee)
                }
            } else {
                let hee = self.frame.size.width - (panGesture?.center.x ?? 0)
                
                if hee > 10 {
                    self.frame.origin.x = val
                    self.frame.size.width = hee
                }
               
            }
            
            
        }
    }
    
    }
}


extension UIPanGestureRecognizer {
    
    enum GestureDirection {
        case Up
        case Down
        case Left
        case Right
    }
    
    /// Get current vertical direction
    ///
    /// - Parameter target: view target
    /// - Returns: current direction
    func verticalDirection(target: UIView) -> GestureDirection {
        return self.velocity(in: target).y > 0 ? .Down : .Up
    }
    
    /// Get current horizontal direction
    ///
    /// - Parameter target: view target
    /// - Returns: current direction
    func horizontalDirection(target: UIView) -> GestureDirection {
        return self.velocity(in: target).x > 0 ? .Right : .Left
    }
    
    /// Get a tuple for current horizontal/vertical direction
    ///
    /// - Parameter target: view target
    /// - Returns: current direction
    func versus(target: UIView) -> (horizontal: GestureDirection, vertical: GestureDirection) {
        return (self.horizontalDirection(target: target), self.verticalDirection(target: target))
    }
    
}



struct SatelliteImageData {
    let polygon: Int
    let buildingPoints : [Int]?
    
    var numberOfItems: Int {
        return buildingPoints?.count ?? 0
    }
    
    subscript(index: Int) -> Int {
        return buildingPoints?[index] ?? 0
    }
}

extension Int {
    
    func getFirstValueFromDigits() -> Int {
        
        return String(self).compactMap{ $0.wholeNumberValue }[0]
    }
}

extension UITableView {
    func scrollToLastCell(animated : Bool) {
        
        let lastSectionIndex = self.numberOfSections - 1 // last section
        var lastRowIndex = self.numberOfRows(inSection: lastSectionIndex) - 1// last row
        
        if lastRowIndex <= 0 {
            lastRowIndex = 0
        }
        
        self.scrollToRow(at: IndexPath(row: lastRowIndex, section: lastSectionIndex), at: .bottom, animated: animated)
    }
}


extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        return sqrt(pow(x - point.x, 2) + pow(y - point.y, 2))
    }
    
    func angle(to comparisonPoint: CGPoint) -> CGFloat {
        let originX = comparisonPoint.x - self.x
        let originY = comparisonPoint.y - self.y
        let bearingRadians = atan2f(Float(originY), Float(originX))
        var bearingDegrees = CGFloat(bearingRadians).degrees
        while bearingDegrees < 0 {
            bearingDegrees += 360
        }
        return bearingDegrees
    }
}

extension CGFloat {
    var degrees: CGFloat {
        return self * CGFloat(180.0 / M_PI)
    }
}
