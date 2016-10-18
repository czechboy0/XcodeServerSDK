//
//  IntegrationTests.swift
//  XcodeServerSDK
//
//  Created by Honza Dvorsky on 17/07/2015.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation
import XcodeServerSDK
import XCTest
import Nimble

class IntegrationTests: XCTestCase {
    
    func test_GetIntegration() {
        
        let server = self.getRecordingXcodeServer("get_integration")
        var done = false
        server.getIntegration("ad2fac04895bd1bb06c1d50e3400fd35") { (integration, error) in
            expect(error).to(beNil())
            expect(integration).toNot(beNil())
            done = true
        }
        expect(done).toEventually(beTrue())
    }
    
    // MARK: Commits
    
    var expectedDate: Date = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZ"
        
        return formatter.date(from: "2015-07-24T09:40:58.462Z")!
    }()
    
    func testGetIntegrationCommits() {
        
        var done = false
        let server = self.getRecordingXcodeServer("get_integration_commits")
        server.getIntegrationCommits("56ad016e2e3993ca0b8ed276050150e8") {
            
            (integrationCommits, error) in
            
            expect(error).to(beNil())
            guard let integrationCommits = integrationCommits,
                  let expectationDate = integrationCommits.endedTimeDate,
                  let commits = integrationCommits.commits["A36AEFA3F9FF1F738E92F0C497C14977DCE02B97"] else {
                fail("Integration commits are empty")
                return
            }
            
            expect(expectationDate) == self.expectedDate
            expect(commits.count) == 6
            
            let commiters = Set(commits.map { $0.contributor.name })
            expect(commiters.count) == 2
            
            done = true
        }
        
        expect(done).toEventually(beTrue())
    }
    
    // MARK: Issues
    
    func testGetIntegrationIssues() {
        
        var done = false
        let server = self.getRecordingXcodeServer("get_integration_issues")
        server.getIntegrationIssues("960f6989b4c7289433ff04db71033d28") { (integrationIssues, error) -> () in
            
            expect(error).to(beNil())
            
            guard let issues = integrationIssues else {
                fail("Integration issues should be present")
                return
            }
            
            expect(issues.errors.count) == 1
            
            let expectation = issues.warnings.filter { $0.status == .Fresh }
            expect(expectation.count) == 2
            expect(issues.analyzerWarnings.isEmpty).to(beTrue())
            
            done = true
        }
        
        expect(done).toEventually(beTrue())
    }
    
}
