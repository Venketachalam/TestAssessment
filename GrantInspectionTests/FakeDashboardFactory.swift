//
//  FakeDashboardFactory.swift
//  ProgressTests
//
//  Created by Hasnain on 4/28/19.
//  Copyright © 2019 MBRHE. All rights reserved.
//


import RxSwift
import Foundation
import OHHTTPStubs


open class FakeDashboardFactory : NSObject , DashboardServiceProtocol {
 
  open func getContracts(with data: DashBoardApiRequest) -> Observable<ContractsResponse>{
   
    return Observable.create { observer in
      
      let contractsResponse = ContractsResponse()
      
      // Arrange
      //
      // Setup network stubs
      
   
      let filter : Filters = Filters()
      filter.colorTag = "1-3"
      filter.label = "#94DD65"
      filter.value = "0"
      
      let payment : Payment = Payment()
      payment.contractId = 34961
      payment.paymentId = 44226
      payment.applicationNo = "9992221"
      payment.plot.landNo = "671-1545"
      payment.plot.latitude = ""
      payment.plot.longitude = ""
      payment.contractor.Id = 5521
      payment.contractor.name = "Demo Contractor"
      payment.contractor.contactName = "demo contractor"
      payment.contractor.mobileNo = "971566444566"
      
      
      let pagination : MBRHEPagination = MBRHEPagination()
      pagination.page = 0
      pagination.pageSize = 50
      pagination.totalItems = 1
      pagination.totalPages  = 3
      
      let stubbedJSON = [
        "Filter": filter,
        "Pagination": pagination,
        "Payment": payment]
        as [String : Any]
      
      stub(condition: isHost("Stub_Response_From_Fake_URL.com")) { _ in
        
        return OHHTTPStubsResponse(
          jsonObject: stubbedJSON,
          statusCode: 200,
          headers: nil)
      }
      
      // consider success response from api and after parsing return Dashboard data
      //
      //
      contractsResponse.success = true
      contractsResponse.statusCode = 200
      contractsResponse.payload.filters = [stubbedJSON["Filter"] as! Filters]
      contractsResponse.payload.pagination = stubbedJSON["Pagination"] as! MBRHEPagination
      contractsResponse.payload.payment = [stubbedJSON["Payment"] as! Payment]
      
      // Fake Response return with Dashboard Data
      //
      //
      observer.onNext(contractsResponse)
      observer.onCompleted()
      
      // Tear Down
      //
      //
      OHHTTPStubs.removeAllStubs()
      
      return Disposables.create()
    }
    
   
   
  }
 
}


