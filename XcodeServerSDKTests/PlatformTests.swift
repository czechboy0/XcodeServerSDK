//
//  PlatformTests.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 13/07/15.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import XCTest
import XcodeServerSDK

class PlatformTests: XCTestCase {

    func testGetPlatforms() {
        let expectation = self.expectation(description: "Get Platforms")
        let server = self.getRecordingXcodeServer("get_platforms")
        
        server.getPlatforms { (platforms, error) -> () in
            XCTAssertNil(error)
            XCTAssertNotNil(platforms)
            
            if let platforms = platforms {
                XCTAssertEqual(platforms.count, 3, "There should be 3 platforms (watchOS, iOS and OS X)")
                
                let displayNames = platforms.map { $0.displayName }
                XCTAssertTrue(displayNames.contains("Watch OS"))
                XCTAssertTrue(displayNames.contains("iOS"))
                XCTAssertTrue(displayNames.contains("OS X"))
            }
            
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 10.0, handler: nil)
    }

}
