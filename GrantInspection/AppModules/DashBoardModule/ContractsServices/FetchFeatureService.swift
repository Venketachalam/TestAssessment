//
//  AttachmentURLService.swift
//  Progress
//
//  Created by Muhammad Akhtar on 11/8/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import UIKit
import EVReflection

class FetchFeatureService: NSObject {
    
    open func fetchFeatures(completion: @escaping ( _ dataObject:
        FetchFeaturesResponse?) -> Void) {
      
      let apiCommunication = APICommunication()
      var urlToHit : String = APICommunicationURLs.featuresURLPRO
      
      var debug = true
     
      if debug == true {
        urlToHit = APICommunicationURLs.featuresURLQA
      }
     
    
       let encoded = urlToHit.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
       let uRL = URL(string: encoded!)?.absoluteString
       
    
      apiCommunication.dataInStringFromURL(url: uRL!, requestType: .get , authenticationType:.Github ) { (_ response: APIBaseResponse?)  in
        
        var apiResponse: FetchFeaturesResponse? = nil
        
            defer {
                print("Api Response:",apiResponse)
                completion(apiResponse)
            }
            EVReflection.setBundleIdentifier(GitDashboardModel.self)
            EVReflection.setBundleIdentifier(GitPaymentsModel.self)
            EVReflection.setBundleIdentifier(GitMenuModel.self)
            EVReflection.setBundleIdentifier(GitCommentModel.self)
            EVReflection.setBundleIdentifier(GitAttachmentModel.self)
            EVReflection.setBundleIdentifier(GitBill_of_quantityModel.self)
            EVReflection.setBundleIdentifier(BaseResponseForModels.self)
            apiResponse = FetchFeaturesResponse(json: response?.responseString)
        
        }
    }
}

public class  FetchFeaturesResponse: BaseResponseForModels {

  open var dashbaord = GitDashboardModel()
  open var payments = GitPaymentsModel()
  open var menu  = GitMenuModel()
  open var comment = GitCommentModel()
  open var attachment = GitAttachmentModel()
  open var bill_of_quantity = GitBill_of_quantityModel()
  
  required public init() {}
}

public class  GitDashboardModel: EVObject {
  
  open var is_payments_listing:Bool = true
  open var is_plan_trip:Bool = true
  open var is_start_trip:Bool = true
  open var is_filter_payments:Bool = true
  open var is_filter_payments_days:Bool = true
  open var is_payments_mapview:Bool = true
  required public init() {}
}

public class  GitPaymentsModel: EVObject {
  open var is_add_trip:Bool = true
  open var is_attachments:Bool = true
  open var is_comments:Bool = true
  open var is_payment_detail:Bool = true
  open var is_payment_boq_listing:Bool = true
  open var is_plot_on_map:Bool = true
  required public init() {}
}
public class  GitMenuModel: EVObject {
 
  open var is_dashboard:Bool = true
  open var is_search_payments:Bool = true
  open var is_trip:Bool = true
  open var is_manage_trip:Bool = true
  open var is_logout:Bool = true
  required public init() {}
}
public class  GitCommentModel: EVObject {
   open var is_add_comment:Bool = true
  required public init() {}
}
public class  GitAttachmentModel: EVObject {
   open var is_upload_attachment:Bool = true
  required public init() {}
}
public class  GitBill_of_quantityModel: EVObject {
   open var is_seacrh_bill_of_quantity:Bool = true
  open var is_boq_add_comment:Bool = true
  open var is_boq_add_view_comment:Bool = true
  open var is_boq_add_percentage:Bool = true
  open var is_boq_view_summary:Bool = true
  open var is_boq_summary_reject:Bool = true
  open var is_boq_summary_hold:Bool = true
  open var is_boq_summary_finish:Bool = true
  
  required public init() {}
}




