//
//  Constants.swift
//  NewsFeed
//
//  Created by MAC on 8/13/19.
//  Copyright © 2019 Kuwy-Technology. All rights reserved.
//

import Foundation
struct Constants {
    static let baseUrl = "https://api.qa.mrhe.gov.ae/mrhecloud/v1.4/api/"
    static let loginMethod = "iskan/v1/certificates/towhomitmayconcern"
    static let newsList = "public/v1/news?local=en"
    static let appName = "News Feed"
    static let somethingWrong = "Something went wrong!!!"
    static let connectionAlert = "Internet connection appears to be offline."
    static let nodatafound = "No data found!!!."
//    static let header = ["Content-Type" : "application/x-www-form-urlencoded","consumer-key":"mobile_dev","consumer-secret":"20891a1b4504ddc33d42501f9c8d2215fbe85008"]
    
    static let header = ["consumer-key":"mobile_dev","consumer-secret":"20891a1b4504ddc33d42501f9c8d2215fbe85008"]
    
    static let entityName = "Users"
}
