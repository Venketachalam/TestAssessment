//
//  DashboardSpecs.swift
//  ProgressTests
//
//  Created by Hasnain on 4/28/19.
//  Copyright © 2019 MBRHE. All rights reserved.
//

import Quick
import Nimble
import XCTest
@testable import Pods_GrantInspection

class DashboardSpecs: QuickSpec {
  
  override func spec() {
    
    var filters: Filters!
    var payment: Payment!
    var pagination: MBRHEPagination!
    
    //1
    describe("The 'Dashboard View Controller'") {
      //2
      context("Always have Filters, Payments and Pagination") {
        
        //3
        afterEach {
          filters = nil
          payment = nil
          pagination = nil
        }
        
        //4
        beforeEach {
          //5
          
          //Filter
          filters = Filters()
          
          //Payment
          payment = Payment()
          payment.applicationNo = "999616"
          
          //Pagination
          pagination = MBRHEPagination()
          pagination.pageSize =  10
          
        }
        
        
        //6
        it("Should not be nil") {
          expect(filters).toNot(beNil())
        }
        
        //7
        it("Should not nil and equal to some application no") {
          expect(payment.applicationNo).toNot(beNil())
          expect(payment.applicationNo).to(equal("999616"))
        }
        
        //8
        it("Should always euqal or greater than 10") {
          expect(pagination.pageSize).to(beGreaterThanOrEqualTo(10))
          
        }
      }
    }
  }
}
