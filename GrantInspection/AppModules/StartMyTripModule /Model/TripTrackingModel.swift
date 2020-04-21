//
//  TripTrackingModel.swift
//  GrantInspection
//
//  Created by Venketachalam Govindaraj on 24/01/20.
//  Copyright © 2020 MBRHE. All rights reserved.
//

import UIKit

class TripTrackingModel: NSObject {
    
    var LatitudeCoordinate : String
    var LongitudeCoodinate : String
    
    init(latitude : String, longitude : String) {
        self.LatitudeCoordinate = latitude
        self.LongitudeCoodinate = longitude
    }

}
