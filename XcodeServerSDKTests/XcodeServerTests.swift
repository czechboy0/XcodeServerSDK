//
//  XcodeServerSDKTests.swift
//  XcodeServerSDKTests
//
//  Created by Honza Dvorsky on 11/06/2015.
//  Copyright (c) 2015 Honza Dvorsky. All rights reserved.
//

import Cocoa
import XCTest
import XcodeServerSDK

class XcodeServerTests: XCTestCase {
    
    var config: XcodeServerConfig?
    var server: XcodeServer?
    
    override func setUp() {
        super.setUp()
        
        config = XcodeServerConfig(
            host: "https://127.0.0.1",
            apiVersion: XcodeServerConfig.APIVersion.Xcode7,
            user: "ICanCreateBots",
            password: "superSecr3t")
        
        server = XcodeServerFactory.server(config!)
    }
    
    func testServerCreation() {
        XCTAssertNotNil(server)
    }
    
}
