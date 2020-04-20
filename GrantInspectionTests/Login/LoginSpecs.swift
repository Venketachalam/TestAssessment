//
//  LoginSpecs.swift
//  ProgressTests
//
//  Created by Hasnain on 4/25/19.
//  Copyright © 2019 MBRHE. All rights reserved.
//

  
import Quick
import Nimble
import RxSwift
@testable import GrantInspection


class LoginSpecs: QuickSpec {
  
  override func spec() {
    
    
    var username : String = "John.smith"
    var password : String = "123456"
    
    //1
    describe("The 'Login View Controller'") {
      //2
      context("username and password are required for login") {
       
        //3
        afterEach {
          
          username  = ""
          password = ""
        }
        
        //4
        beforeEach {
          //5
          username = "John.smith"
          password = "123456"
          
        }
      }
     
      //6
      it("username can't be empty") {
        expect(username).toNot(equal(""))
      }
      
      //7
      it("password is equal to") {
        expect(password).toEventually(contain(("123456")))
      }
      
      //8
      it("password can't be less then 6 chracter") {
        expect(password.count).to(beGreaterThanOrEqualTo(6))
      }
    }
  }
}
