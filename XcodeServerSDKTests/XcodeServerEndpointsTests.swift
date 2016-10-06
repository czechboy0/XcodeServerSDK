//
//  XcodeServerEndpointsTests.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 20/07/15.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import XCTest
@testable import XcodeServerSDK

class XcodeServerEndpointsTests: XCTestCase {

    let serverConfig = try! XcodeServerConfig(host: "https://127.0.0.1", user: "test", password: "test")
    var endpoints: XcodeServerEndpoints?
    
    override func setUp() {
        super.setUp()
        self.endpoints = XcodeServerEndpoints(serverConfig: serverConfig)
    }
    
    // MARK: createRequest()
    
    // If malformed URL is passed to request creation function it should early exit and retur nil
    func testMalformedURLCreation() {
        let expectation = endpoints?.createRequest(.GET, endpoint: .Bots, params: ["test": "test"], query: ["test//http\\": "!test"], body: ["test": "test"], doBasicAuth: true)
        XCTAssertNil(expectation, "Shouldn't create request from malformed URL")
    }
    
    func testRequestCreationForEmptyAuthorizationParams() {
        let expectedUrl = URL(string: "https://127.0.0.1:20343/api/bots/bot_id/integrations")
        let expectedRequest = NSMutableURLRequest(url: expectedUrl!)
        // HTTPMethod
        expectedRequest.httpMethod = "GET"
        // Authorization header: "": ""
        expectedRequest.setValue("Basic Og==", forHTTPHeaderField: "Authorization")
        
        let noAuthorizationConfig = try! XcodeServerConfig(host: "https://127.0.0.1")
        let noAuthorizationEndpoints = XcodeServerEndpoints(serverConfig: noAuthorizationConfig)
        let request = noAuthorizationEndpoints.createRequest(.GET, endpoint: .Integrations, params: ["bot": "bot_id"], query: nil, body: nil, doBasicAuth: true)
        XCTAssertEqual(expectedRequest, request!)
    }
    
    func testGETRequestCreation() {
        let expectedUrl = URL(string: "https://127.0.0.1:20343/api/bots/bot_id/integrations?format=json")
        let expectedRequest = NSMutableURLRequest(url: expectedUrl!)
        // HTTPMethod
        expectedRequest.httpMethod = "GET"
        // Authorization header: "test": "test"
        expectedRequest.setValue("Basic dGVzdDp0ZXN0", forHTTPHeaderField: "Authorization")
        
        let request = self.endpoints?.createRequest(.GET, endpoint: .Integrations, params: ["bot": "bot_id"], query: ["format": "json"], body: nil, doBasicAuth: true)
        XCTAssertEqual(expectedRequest, request!)
    }
    
    func testPOSTRequestCreation() {
        let expectedUrl = URL(string: "https://127.0.0.1:20343/api/auth/logout")
        let expectedRequest = NSMutableURLRequest(url: expectedUrl!)
        // HTTPMethod
        expectedRequest.httpMethod = "POST"
        // HTTPBody
        let expectedData = "{\n  \"bodyParam\" : \"bodyValue\"\n}".data(using: String.Encoding.utf8)
        expectedRequest.httpBody = expectedData!
        expectedRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let request = self.endpoints?.createRequest(.POST, endpoint: .Logout, params: nil, query: nil, body: ["bodyParam": "bodyValue"], doBasicAuth: false)
        XCTAssertEqual(expectedRequest, request!)
        XCTAssertEqual(expectedRequest.HTTPBody!, request!.HTTPBody!)
    }
    
    func testDELETERequestCreation() {
        let expectedUrl = URL(string: "https://127.0.0.1:20343/api/bots/bot_id/rev_id")
        let expectedRequest = NSMutableURLRequest(url: expectedUrl!)
        // HTTPMethod
        expectedRequest.httpMethod = "DELETE"
        
        let request = self.endpoints?.createRequest(.DELETE, endpoint: .Bots, params: ["bot": "bot_id", "rev": "rev_id"], query: nil, body: nil, doBasicAuth: false)
        XCTAssertEqual(expectedRequest, request!)
    }
    
    // MARK: endpointURL(.Bots)
    
    func testEndpointURLCreationForBotsPath() {
        let expectation = "/api/bots"
        let url = self.endpoints?.endpointURL(.Bots)
        XCTAssertEqual(url!, expectation, "endpointURL(.Bots) should return \(expectation)")
    }
    
    func testEndpointURLCreationForBotsBotPath() {
        let expectation = "/api/bots/bot_id"
        let params = [
            "bot": "bot_id"
        ]
        let url = self.endpoints?.endpointURL(.Bots, params: params)
        XCTAssertEqual(url!, expectation, "endpointURL(.Bots, \(params)) should return \(expectation)")
    }
    
    func testEndpointURLCreationForBotsBotRevPath() {
        let expectation = "/api/bots/bot_id/rev_id"
        let params = [
            "bot": "bot_id",
            "rev": "rev_id",
            "method": "DELETE"
        ]
        let url = self.endpoints?.endpointURL(.Bots, params: params)
        XCTAssertEqual(url!, expectation, "endpointURL(.Bots, \(params)) should return \(expectation)")
    }
    
    // MARK: endpointURL(.Integrations)
    
    func testEndpointURLCreationForIntegrationsPath() {
        let expectation = "/api/integrations"
        let url = self.endpoints?.endpointURL(.Integrations)
        XCTAssertEqual(url!, expectation, "endpointURL(.Integrations) should return \(expectation)")
    }
    
    func testEndpointURLCreationForIntegrationsIntegrationPath() {
        let expectation = "/api/integrations/integration_id"
        let params = [
            "integration": "integration_id"
        ]
        let url = self.endpoints?.endpointURL(.Integrations, params: params)
        XCTAssertEqual(url!, expectation, "endpointURL(.Integrations, \(params)) should return \(expectation)")
    }
    
    func testEndpointURLCreationForBotsBotIntegrationsPath() {
        let expectation = "/api/bots/bot_id/integrations"
        let params = [
            "bot": "bot_id"
        ]
        let url = self.endpoints?.endpointURL(.Integrations, params: params)
        XCTAssertEqual(url!, expectation, "endpointURL(.Integrations, \(params)) should return \(expectation)")
    }
    
    // MARK: endpointURL(.CancelIntegration)
    
    func testEndpointURLCreationForIntegrationsIntegrationCancelPath() {
        let expectation = "/api/integrations/integration_id/cancel"
        let params = [
            "integration": "integration_id"
        ]
        let url = self.endpoints?.endpointURL(.CancelIntegration, params: params)
        XCTAssertEqual(url!, expectation, "endpointURL(.CancelIntegration, \(params)) should return \(expectation)")
    }
    
    // MARK: endpointURL(.Devices)
    
    func testEndpointURLCreationForDevicesPath() {
        let expectation = "/api/devices"
        let url = self.endpoints?.endpointURL(.Devices)
        XCTAssertEqual(url!, expectation, "endpointURL(.Devices) should return \(expectation)")
    }
    
    // MARK: endpointURL(.UserCanCreateBots)
    
    func testEndpointURLCreationForAuthIsBotCreatorPath() {
        let expectation = "/api/auth/isBotCreator"
        let url = self.endpoints?.endpointURL(.UserCanCreateBots)
        XCTAssertEqual(url!, expectation, "endpointURL(.UserCanCreateBots) should return \(expectation)")
    }
    
    // MARK: endpointURL(.Login)
    
    func testEndpointURLCreationForAuthLoginPath() {
        let expectation = "/api/auth/login"
        let url = self.endpoints?.endpointURL(.Login)
        XCTAssertEqual(url!, expectation, "endpointURL(.Login) should return \(expectation)")
    }
    
    // MARK: endpointURL(.Logout)
    
    func testEndpointURLCreationForAuthLogoutPath() {
        let expectation = "/api/auth/logout"
        let url = self.endpoints?.endpointURL(.Logout)
        XCTAssertEqual(url!, expectation, "endpointURL(.Logout) should return \(expectation)")
    }
    
    // MARK: endpointURL(.Platforms)
    
    func testEndpointURLCreationForPlatformsPath() {
        let expectation = "/api/platforms"
        let url = self.endpoints?.endpointURL(.Platforms)
        XCTAssertEqual(url!, expectation, "endpointURL(.Platforms) should return \(expectation)")
    }
    
    // MARK: endpointURL(.SCM_Branches)
    
    func testEndpointURLCreationForScmBranchesPath() {
        let expectation = "/api/scm/branches"
        let url = self.endpoints?.endpointURL(.SCM_Branches)
        XCTAssertEqual(url!, expectation, "endpointURL(.SCM_Branches) should return \(expectation)")
    }
    
    // MARK: endpointURL(.Repositories)
    
    func testEndpointURLCreationForRepositoriesPath() {
        let expectation = "/api/repositories"
        let url = self.endpoints?.endpointURL(.Repositories)
        XCTAssertEqual(url!, expectation, "endpointURL(.Repositories) should return \(expectation)")
    }
    
    // MARK: endpointURL(.Commits)
    
    func testEndpointURLCreationForCommits() {
        let expected = "/api/integrations/integration_id/commits"
        let params = [
            "integration": "integration_id"
        ]
        let url = self.endpoints?.endpointURL(.Commits, params: params)
        XCTAssertEqual(url!, expected)
    }
    
    // MARK: endpointURL(.Issues)
    
    func testEndpointURLCreationForIssues() {
        let expected = "/api/integrations/integration_id/issues"
        let params = [
            "integration": "integration_id"
        ]
        let url = self.endpoints?.endpointURL(.Issues, params: params)
        XCTAssertEqual(url!, expected)
    }
    
    // MARK: endpoingURL(.LiveUpdates)
    
    func testEndpointURLCreationForLiveUpdates_Start() {
        let expected = "/xcode/internal/socket.io/1"
        let url = self.endpoints?.endpointURL(.LiveUpdates, params: nil)
        XCTAssertEqual(url!, expected)
    }
    
    func testEndpointURLCreationForLiveUpdates_Poll() {
        let expected = "/xcode/internal/socket.io/1/xhr-polling/sup3rS3cret"
        let params = [
            "poll_id": "sup3rS3cret"
        ]
        let url = self.endpoints?.endpointURL(.LiveUpdates, params: params)
        XCTAssertEqual(url!, expected)
    }
}
