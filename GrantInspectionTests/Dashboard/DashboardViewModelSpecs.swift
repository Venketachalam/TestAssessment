//
//  DashboardViewModelSpecs.swift
//  ProgressTests
//
//  Created by Hasnain on 4/28/19.
//  Copyright © 2019 MBRHE. All rights reserved.
//

import Quick
import Nimble
import RxSwift
@testable import GrantInspection

class DashboardViewModelSpecs : QuickSpec {
  
 
  override func spec() {

    let client : FakeDashboardFactory = FakeDashboardFactory()
    var pageIndex : Variable<Int>!
    let disposeBag = DisposeBag()
  
    describe("Given a Dashboard api Response") {
   
        // 1
      context("and a fake network call is established") {
       
        // 2
        beforeEach {
          pageIndex = Variable(0)
        }
        
        it("should get Dashboard success Response") {
          // 3
          pageIndex.asObservable()
            .flatMap { _ in  return client.getContracts(with: DashBoardApiRequest(page: pageIndex.debugDescription, pageSize: "50")) }
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        }
      }
    }
  }
}
