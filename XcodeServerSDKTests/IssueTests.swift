//
//  IssueTests.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 05.08.2015.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import XCTest
@testable import XcodeServerSDK

class IssueTests: XCTestCase {

    let buildServiceError = try! IntegrationIssue(json: [
        "_id": "99e84a22b20df344df2217d5e4186094",
        "_rev": "3-0cf0b25e995f1a050617d3c5824007f7",
        "message": "This integration was canceled.",
        "type": "buildServiceError",
        "issueType": "Build Service Error",
        "commits": [],
        "integrationID": "99e84a22b20df344df2217d5e4183bce",
        "age": 0,
        "status": 0
    ])
    
    let errorWithCommits = try! IntegrationIssue(json: [
        "_id": "99e84a22b20df344df2217d5e413f43e",
        "_rev": "3-7dfc0aa57a8119c025cd2d86143589f2",
        "message": "Expected declaration",
        "type": "error",
        "issueType": "Swift Compiler Error",
        "commits": [
            [
                "XCSCommitCommitChangeFilePaths": [
                [
                "status": 4,
                "filePath": "XcodeServerSDK/Server Entities/Bot.swift"
                ],
                [
                "status": 4,
                "filePath": "XcodeServerSDK/Server Entities/Trigger.swift"
                ]
                ],
                "XCSCommitMessage": "Break regular code\n",
                "XCSBlueprintRepositoryID": "A36AEFA3F9FF1F738E92F0C497C14977DCE02B97",
                "XCSCommitContributor": [
                    "XCSContributorEmails": [
                    "example@example.com"
                    ],
                    "XCSContributorName": "tester",
                    "XCSContributorDisplayName": "tester"
                ],
                "XCSCommitHash": "1a37d7ce39297ad822626fc2061a1ba343aed343",
                "XCSCommitTimestamp": "2015-08-03T08:23:17.000Z"
            ]
        ],
        "target": "XcodeServerSDK - OS X",
        "documentFilePath": "XcodeServerSDK/XcodeServerSDK/Server Entities/Bot.swift",
        "documentLocationData": "YnBsaXN0MDDUAQIDBAUGIyRYJHZlcnNpb25YJG9iamVjdHNZJGFyY2hpdmVyVCR0b3ASAAGGoKQHCBobVSRudWxs2gkKCwwNDg8QERITFBQVFhcYGRgVW2RvY3VtZW50VVJMXxAUc3RhcnRpbmdDb2x1bW5OdW1iZXJfEBJlbmRpbmdDb2x1bW5OdW1iZXJfEBFjaGFyYWN0ZXJSYW5nZUxlbl8QEGxvY2F0aW9uRW5jb2RpbmdWJGNsYXNzXxAQZW5kaW5nTGluZU51bWJlcll0aW1lc3RhbXBfEBJzdGFydGluZ0xpbmVOdW1iZXJfEBFjaGFyYWN0ZXJSYW5nZUxvY4ACEAQQABABgAMQHIAAXxCbZmlsZTovLy9MaWJyYXJ5L0RldmVsb3Blci9YY29kZVNlcnZlci9JbnRlZ3JhdGlvbnMvQ2FjaGVzLzk5ZTg0YTIyYjIwZGYzNDRkZjIyMTdkNWU0MDNmM2U0L1NvdXJjZS9YY29kZVNlcnZlclNESy9YY29kZVNlcnZlclNESy9TZXJ2ZXIlMjBFbnRpdGllcy9Cb3Quc3dpZnTSHB0eH1okY2xhc3NuYW1lWCRjbGFzc2VzXxAXRFZUVGV4dERvY3VtZW50TG9jYXRpb26jICEiXxAXRFZUVGV4dERvY3VtZW50TG9jYXRpb25fEBNEVlREb2N1bWVudExvY2F0aW9uWE5TT2JqZWN0XxAPTlNLZXllZEFyY2hpdmVy0SUmVHJvb3SAAQAIABEAGgAjAC0AMgA3ADwAQgBXAGMAegCPAKMAtgC9ANAA2gDvAQMBBQEHAQkBCwENAQ8BEQGvAbQBvwHIAeIB5gIAAhYCHwIxAjQCOQAAAAAAAAIBAAAAAAAAACcAAAAAAAAAAAAAAAAAAAI7",
        "lineNumber": 29,
        "integrationID": "99e84a22b20df344df2217d5e413adf7",
        "age": 0,
        "status": 0
    ])
    
    // MARK: Test cases
    func testJSONInitialization() {
        // Shouldn't be nil
        XCTAssertNotNil(buildServiceError)
        XCTAssertNotNil(errorWithCommits)
        
        // Check types
        XCTAssertEqual(buildServiceError.type, IntegrationIssue.IssueType.buildServiceError)
        XCTAssertEqual(errorWithCommits.type, IntegrationIssue.IssueType.error)
    }
    
    func testPayload() {
        XCTAssertEqual(buildServiceError.payload.allKeys.count, 9)
        XCTAssertEqual(errorWithCommits.payload.allKeys.count, 13)
        
        // Check if Error payload contain line number
        let expectation = errorWithCommits.payload["lineNumber"] as! Int
        XCTAssertEqual(expectation, 29)
    }
    
    func testCommitsArray() {
        // Build Service Error doesn't have commits
        XCTAssertTrue(buildServiceError.commits.isEmpty)
        
        // Error, on the other hand, has one...
        XCTAssertEqual(errorWithCommits.commits.count, 1)
        XCTAssertEqual(errorWithCommits.commits.first!.filePaths.count, 2)
        XCTAssertEqual(errorWithCommits.commits.first!.contributor.name, "tester")
    }

}
