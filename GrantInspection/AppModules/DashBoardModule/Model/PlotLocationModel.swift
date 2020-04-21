//
//  PlotLocationModel.swift
//  GrantInspection
//
//  Created by Rajeswaran Thangaperumal on 08/09/2019.
//  Copyright © 2019 MBRHE. All rights reserved.
//

import EVReflection

public class  SearchLocationModelResponse: BaseResponseForModels {
    
    public var payload = SearchLocationPayload()
    required public init() {}
}

public class SearchLocationPayload: EVObject {
    public var makaniDetailPayload = [LocationDetails]()
    required public init() {}
}

public class LocationDetails: EVObject {
    public var location = ""
    public var locationId = ""
    public var featureclassId = ""
    
    required public init() {}
}

public class PlotLocationModelResponse: BaseResponseForModels {
    
    public var payload = PlotLocationPayload()
    required public init() {}
}

public class PlotLocationPayload: EVObject {
    public var plot = [PlotLocationDetails]()
    required public init() {}
}

public class PlotLocationDetails: EVObject {
    public var applicationNo = ""
    public var plotNo = ""
    public var latitude = ""
    public var longitude = ""
    public var locationId = ""
    required public init() {}
}


