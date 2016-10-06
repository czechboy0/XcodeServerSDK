//
//  ToolchainTests.swift
//  XcodeServerSDK
//
//  Created by Laurent Gaches on 21/04/16.
//  Copyright © 2016 Laurent Gaches. All rights reserved.
//

import XCTest
import XcodeServerSDK

class ToolchainTest: XCTestCase {
    
    func testGetToolchains() {
        let expectation = self.expectation(description: "Get Toolchains")
        let server = self.getRecordingXcodeServer("get_toolchains")
        
        server.getToolchains { (toolchains, error) -> () in
            XCTAssertNil(error)
            XCTAssertNotNil(toolchains)
            
            if let toolchains = toolchains {
                XCTAssertEqual(toolchains.count, 2, "There should be 2 toolchains")
                
                let displayNames = toolchains.map { $0.displayName }
                XCTAssertTrue(displayNames.contains("Xcode Swift 2.2.1 Snapshot 2016-04-12 (a)"))
                XCTAssertTrue(displayNames.contains("Xcode Swift DEVELOPMENT Snapshot 2016-04-12 (a)"))
                
            }
            
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 10.0, handler: nil)
    }
}
