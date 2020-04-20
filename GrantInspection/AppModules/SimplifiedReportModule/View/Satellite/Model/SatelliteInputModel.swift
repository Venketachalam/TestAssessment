//
//  satelliteInputModel.swift
//  GrantInspection
//
//  Created by Gopalakrishnan Chinnadurai on 07/10/19.
//  Copyright © 2019 MBRHE. All rights reserved.
//

import UIKit
import EVReflection

//MARK:- GET


class SatelliteResponseModel: BaseResponseForModels {
    
    var payload = SatelliteResponsePayload()
    
    required public init() {}
}

class SatelliteResponsePayload: EVObject {
    var applicantId = ""
    var applicationNo = ""
    var plotCoordinate = ""
    var imageType = 0
    
    var polygons = PolygonDetails()
    var buildingPoints = [BuildingPointDetails]()
    required public init() {}
}

//MARK:- POST
class SatelliteInputModel: EVObject {
    
    var imageType = 0
    var applicantId = ""
    var applicationNo = ""
    var serviceTypeId = ""
    var plotCoordinate = ""
    var polygons = PolygonDetails()
    var buildingPoints = [BuildingPointDetails]()
    
    required public init() {}
}

class PolygonDetails: EVObject {
    
    var polygonTAG = ""
    var mapZoom = ""
    var polygonPoint = PolygonLatLong()
    
    required public init() {}
}

class PolygonLatLong : EVObject {
    
    var topLeft = ""
    var topRight = ""
    var bottomRight = ""
    var bottomLeft = ""
    
    required public init() {}
    
}

class BuildingPointDetails : EVObject {
    
    var buildingTAG = ""
    var buildingName = ""
    var topLeft = ""
    var topRight = ""
    var bottomRight = ""
    var bottomLeft = ""
    
    required public init() {}
}


