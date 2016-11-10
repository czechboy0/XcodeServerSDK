//
//  BotParsingTests.swift
//  XcodeServerSDK
//
//  Created by Honza Dvorsky on 17/06/15.
//  Copyright (c) 2015 Honza Dvorsky. All rights reserved.
//

import Foundation
import XCTest
import XcodeServerSDK

class BotParsingTests: XCTestCase {
    
    //MARK: shared stuff
    
    func testParseOSXBot() {
        
        let exp = self.expectation(description: "Network")
        let server = self.getRecordingXcodeServer("osx_bot")
        
        server.getBot("963bc95f1c1a56f69f3392b4aa03302f") { (bots, error) in
            exp.fulfill()
        }
        
        self.waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testShared() throws {
        
        let bot = try self.botInCassetteWithName("osx_bot")
        
        XCTAssertEqual(bot.id, "963bc95f1c1a56f69f3392b4aa03302f")
        XCTAssertEqual(bot.rev, "10-117b73f201ea103229a2e8cd26a01845")
        XCTAssertEqual(bot.tinyID, "4807518")
    }
    
    //MARK: bot
    
    func testDeleteBot() {
        
        let exp = self.expectation(description: "Network")
        let server = self.getRecordingXcodeServer("bot_deletion")
        
        server.deleteBot("5f79bd4f6eb05c645336606cc790ccd7", revision: "5-4939a8253e8243107a0d4733490fd36e") { (success, error) in
            XCTAssertNil(error)
            XCTAssertTrue(success)
            exp.fulfill()
        }
        self.waitForExpectations(timeout: 10, handler: nil)
    }
    
//    func testBots() {
//        
//        let exp = self.expectationWithDescription("Network")
//        let config = try! XcodeServerConfig(host: "192.168.1.64")
//        let server = XcodeServerFactory.server(config)
//        server.getBots { (bots, error) -> () in
//            exp.fulfill()
//        }
//        self.waitForExpectationsWithTimeout(10, handler: nil)
//    }
//    func testBot() {
//        
//        let bot = self.botInFileWithName("bot_mac_xcode6")
//        
//        XCTAssertEqual(bot.name, "Builda Archiver")
//        XCTAssertEqual(bot.integrationsCount, 7)
//    }
//
//    //MARK: configuration
//    func testConfiguration() {
//        
//        let configuration = self.configurationFromBotWithName("bot_mac_xcode6")
//        
//        XCTAssertEqual(configuration.test, true)
//        XCTAssertEqual(configuration.analyze, true)
//        XCTAssertEqual(configuration.archive, true)
//        XCTAssertEqual(configuration.schemeName, "Buildasaur")
//    }
    
    //MARK: cleaning policy
//    func testCleanPolicy() {
//        //TODO: will be a whole set of tests, add all possible cases
//    }
//
//    //MARK: test schedule
//    func testSchedule() {
//        //TODO: will be a whole set of tests, add all possible cases
//    }
//    
//    //MARK: blueprint (good luck with this one)
//    func testBlueprint() {
//        //TODO: will be a whole set of tests, add all possible cases
//    }
//    
//    //MARK: destination type
//    func testDestinationType() {
//        //TODO: will be a whole set of tests, add all possible cases
//    }
//    
//    //MARK: triggers
//    func testTriggers() {
//        //TODO: will be a whole set of tests, add all possible cases
//    }
//    
//    //MARK: testing device ids (on both Xcode 6 and 7 formats!!!)
//    func testTestingDeviceIds() {
//        //TODO: will be a whole set of tests, add all possible cases
//    }
}





