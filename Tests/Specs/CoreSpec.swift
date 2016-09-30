//
//  HaloCoreTests.swift
//  HaloCoreTests
//
//  Created by Borja Santos-Díez on 17/06/15.
//  Copyright (c) 2015 MOBGEN Technology. All rights reserved.
//

import Quick
import Nimble
import OHHTTPStubs
@testable import Halo

class CoreSpec: BaseSpec {
    
    override func spec() {
        
        super.spec()
        
        let mgr = Halo.Manager.core
        
        beforeSuite {
            mgr.appCredentials = Credentials(clientId: "halotestappclient", clientSecret: "halotestapppass")
        }
        
        describe("The core manager") {
            
            afterEach {
                OHHTTPStubs.removeAllStubs()
            }
            
            context("when the startup process succeeds") {
            
                beforeEach {
                    stub(pathStartsWith("/api/segmentation/appuser")) { (request) -> OHHTTPStubsResponse in
                        let fixture = OHPathForFile("segmentation_appuser_success.json", self.dynamicType)
                        return OHHTTPStubsResponse(fileAtPath: fixture!, statusCode: 200, headers: ["Content-Type": "application/json"])
                    }.name = "Successful appuser stub"
                }
                
                it("has been initialised properly") {
                    expect(mgr).toNot(beNil())
                }
                
                it("starts properly") {
                    waitUntil { done in
                        mgr.startup { success in
                            done()
                        }
                    }
                    
                    expect(mgr.user).toNot(beNil())
                }
            }
            
            context("when saving the user fails") {
                
                beforeEach {
                    stub(pathStartsWith("/api/segmentation/appuser")) { (request) -> OHHTTPStubsResponse in
                        let fixture = OHPathForFile("segmentation_appuser_failure.json", self.dynamicType)
                        return OHHTTPStubsResponse(fileAtPath: fixture!, statusCode: 400, headers: ["Content-Type": "application/json"])
                    }.name = "Successful appuser stub"
                }
                
                it("user has not changed") {
                    
                    let oldUser = mgr.user
                    
                    waitUntil { done in
                        mgr.saveUser { _ in
                            done()
                        }
                    }
                    
                    expect(mgr.user).to(be(oldUser))
                }
            }
        }
        
        describe("Framework version") {
            it("is correct") {
                expect(mgr.frameworkVersion).to(equal("2.0.0"))
            }
        }
        
        describe("Registering an addon") {
            
            var addon: Addon?
            
            beforeEach {
                addon = DummyAddon()
                mgr.registerAddon(addon: addon!)
            }
            
            it("succeeds") {
                expect(mgr.addons.count).to(equal(1))
                expect(mgr.addons.first).to(be(addon))
            }
        }
        
        describe("The oauth process") {
            
            beforeEach {
                Halo.Router.appToken = nil
                Halo.Router.userToken = nil
            }
            
            afterEach {
                OHHTTPStubs.removeAllStubs()
            }
            
            context("with the right credentials") {
                
                beforeEach {
                    stub(isPath("/api/oauth/token")) { (request) -> OHHTTPStubsResponse in
                        let fixture = OHPathForFile("oauth_success.json", self.dynamicType)
                        return OHHTTPStubsResponse(fileAtPath: fixture!, statusCode: 200, headers: ["Content-Type": "application/json"])
                    }.name = "Successful OAuth stub"
                    
                    waitUntil { done in
                        Halo.Manager.network.authenticate(mode: .App) { _ in
                            done()
                        }
                    }
                }
                
                it("succeeds") {
                    expect(Halo.Router.appToken).toNot(beNil())
                }
                
                it("retrieves a valid token") {
                    expect(Halo.Router.appToken?.isValid()).to(beTrue())
                    expect(Halo.Router.appToken?.isExpired()).to(beFalse())
                }
                
            }
            
            context("with the wrong credentials") {
                
                beforeEach {
                    stub(isPath("/api/oauth/token")) { (request) -> OHHTTPStubsResponse in
                        let fixture = OHPathForFile("oauth_failure.json", self.dynamicType)
                        return OHHTTPStubsResponse(fileAtPath: fixture!, statusCode: 403, headers: ["Content-Type": "application/json"])
                    }.name = "Failed OAuth stub"
                                        
                    waitUntil { done in
                        Halo.Manager.network.authenticate(mode: .App) { _ in
                            done()
                        }
                    }
                }
                
                it("fails") {
                    expect(Halo.Router.appToken).to(beNil())
                }
            }
        }
    }
}
