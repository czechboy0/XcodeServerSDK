//
//  Repository.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 28.06.2015.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import XCTest
import XcodeServerSDK

class RepositoryTests: XCTestCase {
    
    let json: [String: Any] = [
        "readAccessExternalIDs": [],
        "writeAccessExternalIDs": [
            "FDF283F5-B9C3-4B43-9000-EF6A54934D4E",
            "ABCDEFAB-CDEF-ABCD-EFAB-CDEF00000050"
        ],
        "name": "Test",
        "posixPermissions": 1,
        "httpAccessType": 1
    ]

    // MARK: Initialization
    func testInit() throws {
        let repo = try Repository(json: json as NSDictionary)
        
        XCTAssertEqual(repo.name, "Test")
        XCTAssertEqual(repo.httpAccess, Repository.HTTPAccessType.loggedIn)
        XCTAssertEqual(repo.sshAccess, Repository.SSHAccessType.loggedInReadSelectedWrite)
        XCTAssertEqual(repo.writeAccessExternalIds, [ "FDF283F5-B9C3-4B43-9000-EF6A54934D4E", "ABCDEFAB-CDEF-ABCD-EFAB-CDEF00000050" ])
        XCTAssertEqual(repo.readAccessExternalIds, [])
    }
    
    func testManualInit() {
        let repo = Repository(name: "Test", httpAccess: .loggedIn, sshAccess: .loggedInReadSelectedWrite, writeAccessExternalIds: [ "FDF283F5-B9C3-4B43-9000-EF6A54934D4E", "ABCDEFAB-CDEF-ABCD-EFAB-CDEF00000050" ], readAccessExternalIds: [])
        
        XCTAssertEqual(repo.name, "Test")
        XCTAssertEqual(repo.httpAccess, Repository.HTTPAccessType.loggedIn)
        XCTAssertEqual(repo.sshAccess, Repository.SSHAccessType.loggedInReadSelectedWrite)
        XCTAssertEqual(repo.writeAccessExternalIds, [ "FDF283F5-B9C3-4B43-9000-EF6A54934D4E", "ABCDEFAB-CDEF-ABCD-EFAB-CDEF00000050" ])
        XCTAssertEqual(repo.readAccessExternalIds, [])
    }
    
    func testConvenienceInit() {
        let repo = Repository(name: "Test")
        
        XCTAssertEqual(repo.name, "Test")
        XCTAssertEqual(repo.httpAccess, Repository.HTTPAccessType.none)
        XCTAssertEqual(repo.sshAccess, Repository.SSHAccessType.loggedInReadWrite)
        XCTAssertEqual(repo.writeAccessExternalIds, [])
        XCTAssertEqual(repo.readAccessExternalIds, [])
    }
    
    // MARK: JSONifying
    func testDictionarify() {
        let repo = Repository(name: "Test", httpAccess: .loggedIn, sshAccess: .loggedInReadSelectedWrite, writeAccessExternalIds: [ "FDF283F5-B9C3-4B43-9000-EF6A54934D4E", "ABCDEFAB-CDEF-ABCD-EFAB-CDEF00000050" ], readAccessExternalIds: [])
        
        XCTAssert(repo.dictionarify() == json)
    }
    
    // MARK: Enum tests
    func testHTTPEnum() {
        var httpEnum = Repository.HTTPAccessType.none
        XCTAssertEqual(httpEnum.toString(), "No users are not allowed to read or write")
        
        httpEnum = .loggedIn
        XCTAssertEqual(httpEnum.toString(), "Logged in users are allowed to read and write")
    }
    
    func testSSHEnum() {
        var sshEnum = Repository.SSHAccessType.selectedReadWrite
        XCTAssertEqual(sshEnum.toString(), "Only selected users can read and/or write")
        
        sshEnum = .loggedInReadSelectedWrite
        XCTAssertEqual(sshEnum.toString(), "Only selected users can write but all logged in can read")
        
        sshEnum = .loggedInReadWrite
        XCTAssertEqual(sshEnum.toString(), "All logged in users can read and write")
    }
    
    // MARK: API Routes tests
    func testGetRepositories() {
        let expectation = self.expectation(description: "Get Repositories")
        let server = self.getRecordingXcodeServer("get_repositories")
        
        server.getRepositories() { (repositories, error) in
            XCTAssertNil(error, "Error should be nil")
            XCTAssertNotNil(repositories, "Repositories shouldn't be nil")
            
            if let repos = repositories {
                XCTAssertEqual(repos.count, 2, "There should be two repositories available")
                
                let reposNames = Set(repos.map { $0.name })
                let reposSSHAccess = Set(repos.map { $0.sshAccess.rawValue })
                let writeAccessExternalIDs = Set(repos.flatMap { $0.writeAccessExternalIds })
                
                for (index, _) in repos.enumerated() {
                    XCTAssertTrue(reposNames.contains("Test\(index + 1)"))
                    XCTAssertTrue(reposSSHAccess.elementsEqual(Set([2, 0])))
                    XCTAssertTrue(writeAccessExternalIDs.elementsEqual(Set([ "ABCDEFAB-CDEF-ABCD-EFAB-CDEF00000050", "D024C308-CEBE-4E72-BE40-E1E4115F38F9" ])))
                }
            }
            
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 10.0, handler: nil)
    }

}
