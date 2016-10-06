//
//  TestUtils.swift
//  XcodeServerSDK
//
//  Created by Honza Dvorsky on 17/06/15.
//  Copyright (c) 2015 Honza Dvorsky. All rights reserved.
//

import Foundation
import XCTest
import XcodeServerSDK
import DVR

struct StringError: Error {
    
    let description: String
    let _domain: String = ""
    let _code: Int = 0
    
    init(_ description: String) {
        self.description = description
    }
}

extension XCTestCase {
    
    func getRecordingXcodeServer(_ cassetteName: String) -> XcodeServer {
        
        let config = try! XcodeServerConfig(
            host: "https://127.0.0.1",
            user: "ICanCreateBots",
            password: "superSecr3t")
        return self.getRecordingXcodeServerWithConfig(config, cassetteName: cassetteName)
    }
    
    func getRecordingXcodeServerWithConfig(_ config: XcodeServerConfig, cassetteName: String) -> XcodeServer
    {
        let server = XcodeServerFactory.server(config)
        let backingSession = server.http.session
        
        let session = DVR.Session(cassetteName: cassetteName, testBundle: Bundle(forClass: self.classForCoder), backingSession: backingSession)
        server.http.session = session
        
        return server
    }
}

// MARK: Mock JSON helper methods
extension XCTestCase {
    
    func stringAtPath(_ path: String) -> String {
        return try! NSString(contentsOfFile: (path as NSString).expandingTildeInPath, encoding: String.Encoding.utf8.rawValue) as String
    }
    
    func loadJSONResponseFromCassetteWithName(_ name: String) -> NSDictionary {
        
        let dictionary = self.loadJSONWithName(name)
        
        let interactions = dictionary["interactions"] as! [NSDictionary]
        let response = interactions.first!["response"] as! NSDictionary
        
        //make sure it's json
        assert(response["body_format"] as! String == "json")
        
        //get the response data out
        let body = response["body"] as! NSDictionary
        return body
    }
    
    func loadJSONWithName(_ name: String) -> NSDictionary {
        
        let bundle = Bundle(for: BotParsingTests.classForCoder())
        do {
            
            if let url = bundle.url(forResource: name, withExtension: "json") {
                
                let data = try Data(contentsOf: url, options: NSData.ReadingOptions())                
                if let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? NSDictionary {
                    return json
                }
                
            } else {
                throw StringError("File with name \(name) not found in the bundle")
            }
            
        } catch {
            XCTFail("Error reading file with name \(name), error: \(error)")
        }
        return NSDictionary()
    }
    
    func botInCassetteWithName(_ name: String) throws -> Bot {
        let json = self.loadJSONResponseFromCassetteWithName(name)
        let bot = try Bot(json: json)
        return bot
    }
    
    func botInFileWithName(_ name: String) throws -> Bot {
        let json = self.loadJSONWithName(name)
        let bot = try Bot(json: json)
        return bot
    }
    
    func configurationFromBotWithName(_ name: String) throws -> BotConfiguration {
        let bot = try self.botInFileWithName(name)
        let configuration = bot.configuration
        return configuration
    }
}

// MARK: Exception assertions
// Based on: https://forums.developer.apple.com/thread/5824
extension XCTestCase {
    /**
    Replacement method for XCTAssertThrowsError which isn't currently supported.
    
    - parameter message: Message which should be displayed
    - parameter file:    File in which assertion happened
    - parameter line:    Line in which assertion happened
    - parameter block:   Block of code against which assertion should be matched
    */
    func XCTempAssertThrowsError(_ message: String = "", file: StaticString = #file, line: UInt = #line, _ block: () throws -> ()) {
        do {
            try block()
            
            let msg = (message == "") ? "Tested block did not throw error as expected." : message
            XCTFail(msg, file: file, line: line)
        } catch {}
    }
    
    /**
    Replacement method for XCTAssertThrowsSpecificError which isn't currently supported.
    
    - parameter kind:    ErrorType which is expected to be thrown from block
    - parameter message: Message which should be displayed
    - parameter file:    File in which assertion happened
    - parameter line:    Line in which assertion happened
    - parameter block:   Block of code against which assertion should be matched
    */
    func XCTempAssertThrowsSpecificError(_ kind: Error, _ message: String = "", file: StaticString = #file, line: UInt = #line, _ block: () throws -> ()) {
        do {
            try block()
            
            let msg = (message == "") ? "Tested block did not throw expected \(kind) error." : message
            XCTFail(msg, file: file, line: line)
        } catch let error as NSError {
            let expected = kind as NSError
            if ((error.domain != expected.domain) || (error.code != expected.code)) {
                let msg = (message == "") ? "Tested block threw \(error), not expected \(kind) error." : message
                XCTFail(msg, file: file, line: line)
            }
        }
    }
    
    /**
    Replacement method for XCTAssertNoThrowsError which isn't currently supported.
    
    - parameter message: Message which should be displayed
    - parameter file:    File in which assertion happened
    - parameter line:    Line in which assertion happened
    - parameter block:   Block of code against which assertion should be matched
    */
    func XCTempAssertNoThrowError(_ message: String = "", file: StaticString = #file, line: UInt = #line, _ block: () throws -> ()) {
        do {
            try block()
        } catch {
            let msg = (message == "") ? "Tested block threw unexpected error." : message
            XCTFail(msg, file: file, line: line)
        }
    }
    
    /**
    Replacement method for XCTAssertNoThrowsSpecificError which isn't currently supported.
    
    - parameter kind:    ErrorType which isn't expected to be thrown from block
    - parameter message: Message which should be displayed
    - parameter file:    File in which assertion happened
    - parameter line:    Line in which assertion happened
    - parameter block:   Block of code against which assertion should be matched
    */
    func XCTempAssertNoThrowSpecificError(_ kind: Error, _ message: String = "", file: StaticString = #file, line: UInt = #line, _ block: () throws -> ()) {
        do {
            try block()
        } catch let error as NSError {
            let unwanted = kind as NSError
            if ((error.domain == unwanted.domain) && (error.code == unwanted.code)) {
                let msg = (message == "") ? "Tested block threw unexpected \(kind) error." : message  
                XCTFail(msg, file: file, line: line)  
            }  
        }  
    }
}
