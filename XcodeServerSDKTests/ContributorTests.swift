//
//  ContributorTests.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 21/07/15.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import XCTest
@testable import XcodeServerSDK

public func ==(lhs: [AnyHashable: Any], rhs: [AnyHashable: Any] ) -> Bool {
    return NSDictionary(dictionary: lhs).isEqual(to: rhs)
}

public func ==(lhs: [String: Any], rhs: [String: Any] ) -> Bool {
    return NSDictionary(dictionary: lhs).isEqual(to: rhs)
}

class ContributorTests: XCTestCase {

    let singleEmailContributor = [
        kContributorName: "Foo Bar",
        kContributorDisplayName: "Foo",
        kContributorEmails: [
            "foo@bar.com"
        ]
    ] as [String : Any]
    
    let multiEmailContributor = [
        kContributorName: "Baz Bar",
        kContributorDisplayName: "Baz",
        kContributorEmails: [
            "baz@bar.com",
            "baz@example.com"
        ]
    ] as [String : Any]
    
    var singleEmail: Contributor!
    var multiEmail: Contributor!
    
    override func setUp() {
        super.setUp()
        
        singleEmail = try! Contributor(json: singleEmailContributor as NSDictionary)
        multiEmail = try! Contributor(json: multiEmailContributor as NSDictionary)
    }
    
    // MARK: Test cases
    func testInitialization() {
        XCTAssertEqual(singleEmail.name, "Foo Bar")
        XCTAssertEqual(singleEmail.emails.count, 1)
        
        XCTAssertEqual(multiEmail.name, "Baz Bar")
        XCTAssertEqual(multiEmail.emails.count, 2)
    }
    
    // MARK: Dictionarify
    func testDictionarify() {
        XCTAssert(singleEmail.dictionarify() == singleEmailContributor)
        XCTAssert(multiEmail.dictionarify() == multiEmailContributor)
    }
    
    func testDescription() {
        XCTAssertEqual(multiEmail.description(), "Baz [baz@bar.com]")
    }
    
}
