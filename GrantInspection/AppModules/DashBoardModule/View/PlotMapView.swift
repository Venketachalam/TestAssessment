//
//  SearchContractorNameVC.swift
//  Progress
//
//  Created by Muhammad Akhtar on 11/20/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import GoogleMaps

protocol PlotMapViewDelegate {
    func btnNotes_Action(obj:Dashboard)
    func btnAttachment_Action(obj:Dashboard)
    func btnMore_Action(obj:Dashboard)
    func addToTripActionFromDelegate(obj:Dashboard)
}

class PlotMapView: UIViewController {

   
    @IBOutlet weak var googleMapView: GMSMapView!
    @IBOutlet weak var btnNavigate: UIButton!
    private let disposeBag = DisposeBag()
    var mapViewDelegate: PlotMapViewDelegate?
    
    @IBOutlet weak var statusView: MBRHEBorderView!
    @IBOutlet weak var lblContractNumberTitle: UILabel!
    @IBOutlet weak var lblContractNumber: UILabel!
    @IBOutlet weak var lblProjectId: UILabel!
    @IBOutlet weak var lblAdress: UILabel!
    
    @IBOutlet weak var btnAddToTrip: UIButton!
    @IBOutlet weak var btnNotes: UIButton!
    @IBOutlet weak var btnAttachments: UIButton!
    @IBOutlet weak var btnMore: UIButton!
    @IBOutlet weak var btnClose: UIButton!
    var paymentObj:Dashboard = Dashboard()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        lblContractNumberTitle.text = "\("file_number".ls) : \(paymentObj.applicationNo.stringValue)"
//        lblContractNumber.text = paymentObj.applicationNo.stringValue
        lblProjectId.text = "\("customer_number".ls) : \(paymentObj.applicantId)"
        
        if Common.currentLanguageArabic()
        {
            self.view.transform = Common.arabicTransform
            self.view.toArabicTransform()
            googleMapView.transform = Common.arabicTransform
            
        }
        
        if Common.isProjectAddedIntoTripArrayWith(paymentId: paymentObj.applicationNo) {
          let index : Int =  SharedResources.sharedInstance.selectedTripContracts.index{$0.applicationNo == paymentObj.applicationNo }!
            print(index)
            self.btnAddToTrip.isSelected = true
        } else {
           self.btnAddToTrip.isSelected = false

        }

      
        btnClose.rx.tap.asObservable()
            .subscribe(onNext:{[weak self] _ in
                self?.dismiss(animated: false, completion: nil)
            })
            .disposed(by: disposeBag)
        
        btnAddToTrip.rx.tap.asObservable()
            .subscribe(onNext:{[weak self] _ in
                
                if self?.btnAddToTrip.isSelected == true
                {
//                    self?.setAddTripButtonColorAndImageForNormalState()
                    self?.btnAddToTrip.isSelected = false
                }else
                {
//                    self?.setAddTripButtonColorAndImageForSelectedState()
                    self?.btnAddToTrip.isSelected = true
                }
                
                self?.mapViewDelegate?.addToTripActionFromDelegate(obj: self!.paymentObj)

            })
            .disposed(by: disposeBag)
        
        btnNotes.rx.tap.asObservable()
            .subscribe(onNext:{[weak self] _ in
                self?.mapViewDelegate?.btnNotes_Action(obj: self!.paymentObj)
                self?.dismiss(animated: false, completion: nil)
            })
            .disposed(by: disposeBag)
        
        btnAttachments.rx.tap.asObservable()
            .subscribe(onNext:{[weak self] _ in
                self?.mapViewDelegate?.btnAttachment_Action(obj: self!.paymentObj)
                self?.dismiss(animated: false, completion: nil)
            })
            .disposed(by: disposeBag)
        
        btnMore.rx.tap.asObservable()
            .subscribe(onNext:{[weak self] _ in
                

                
                self?.dismiss(animated: false, completion: {
                    self?.mapViewDelegate?.btnMore_Action(obj: self!.paymentObj)
                })
                
               
            })
            .disposed(by: disposeBag)
        
        let latitdue = self.paymentObj.plot.latitude
        let longitude = self.paymentObj.plot.longitude
        // Do any additional setup after loading the view.
        //addPinWith(latitdue: "25.204849",longitude:"55.270782")
        
        //Test location
        //let latitdue = "25.204849"
        //let longitude = "55.270782"
        
        guard let latVal = Double(latitdue) else {
            return
        }
        guard let longVal = Double(longitude) else {
            return
        }
        
        self.getAddressForLatLng(latitude: latitdue, longitude: longitude)
        
        let location = CLLocationCoordinate2D(latitude: latVal, longitude: longVal)
       
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            let pin = GMSMarker(position: location)
            pin.icon = UIImage(named: "round_pin_icon")
            pin.map = self.googleMapView
            self.setCameraPostion(loc: location)
        }
        
        
        
        btnNavigate.rx.tap.asObservable()
            .subscribe(onNext:{[weak self] _ in
                self?.setCameraPostion(loc: location)
            })
            .disposed(by: disposeBag)
    }
    
    func setAddTripButtonColorAndImageForSelectedState() {
        btnAddToTrip.backgroundColor = UIColor.init(red: 231/255, green: 248/255, blue: 243/255, alpha: 1.0)
        btnAddToTrip.setImage(UIImage.init(named: "tick_icon_green"), for: .normal)
        
        

    }
    
    func setAddTripButtonColorAndImageForNormalState() {
        btnAddToTrip.backgroundColor = UIColor.init(red: 20/255, green: 193/255, blue: 139/255, alpha: 1.0)
        
        btnAddToTrip.setImage(UIImage.init(named: "add_white_icon"), for: .normal)

    }
    
    func setCameraPostion(loc:CLLocationCoordinate2D) {
        self.googleMapView.camera = GMSCameraPosition.camera(withTarget: loc, zoom: 12.0)
        self.googleMapView.settings.myLocationButton = false
        
    }
    
    @objc func checkAction(sender : UITapGestureRecognizer) {
         //self.dismiss(animated: false, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    
    //https://stackoverflow.com/questions/16647996/get-location-name-from-latitude-longitude-in-ios
    
    func getAddressForLatLng(latitude: String, longitude: String)  {
        
        let url = NSURL(string: "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(latitude),\(longitude)&key=\(Common.googleMapSDKKey)&sensor=true")
        print(url!)
        let data = NSData(contentsOf: url! as URL)
        
        if data != nil {
            let json = try! JSONSerialization.jsonObject(with: data! as Data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
            //print(json)
            
            let status = json["status"] as! String
            if status == "OK" {
                
                if let result = json["results"] as? NSArray   {
                    
                    if result.count > 0 {
                        if let addresss:NSDictionary = result[0] as? NSDictionary {
                            if let address = addresss["address_components"] as? NSArray {
                                var newaddress = ""
                                var number = ""
                                var street = ""
                                var city = ""
                                var state = ""
                                var zip = ""
                                //var country = ""
                                
                                if(address.count > 1) {
                                    number =  (address.object(at: 0) as! NSDictionary)["short_name"] as! String
                                }
                                if(address.count > 2) {
                                    street = (address.object(at: 1) as! NSDictionary)["short_name"] as! String
                                }
                                if(address.count > 3) {
                                    city = (address.object(at: 2) as! NSDictionary)["short_name"] as! String
                                }
                                if(address.count > 4) {
                                    state = (address.object(at: 4) as! NSDictionary)["short_name"] as! String
                                }
                                if(address.count > 6) {
                                    zip =  (address.object(at: 6) as! NSDictionary)["short_name"] as! String
                                }
                                newaddress = "\(number) \(street), \(city), \(state) \(zip)"
                                //print(newaddress)
                                self.lblAdress.text = newaddress
                                
                            }
                            
                            
                            
                        }
                    }
                    
                }
                
            }
            
        }
        
    }

}
