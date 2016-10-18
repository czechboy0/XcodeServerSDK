//
//  IntegrationIssues.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 12.08.2015.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation
import BuildaUtils

open class IntegrationIssues: XcodeServerEntity {
    
    open let buildServiceErrors: [IntegrationIssue]
    open let buildServiceWarnings: [IntegrationIssue]
    open let triggerErrors: [IntegrationIssue]
    open let errors: [IntegrationIssue]
    open let warnings: [IntegrationIssue]
    open let testFailures: [IntegrationIssue]
    open let analyzerWarnings: [IntegrationIssue]
    
    // MARK: Initialization
    
    public required init(json: NSDictionary) throws {
        self.buildServiceErrors = try json.arrayForKey("buildServiceErrors").map { try IntegrationIssue(json: $0) }
        self.buildServiceWarnings = try json.arrayForKey("buildServiceWarnings").map { try IntegrationIssue(json: $0) }
        self.triggerErrors = try json.arrayForKey("triggerErrors").map { try IntegrationIssue(json: $0) }
        
        // Nested issues
        self.errors = try json
            .dictionaryForKey("errors")
            .allValues
            .filter { guard let array = $0 as? NSArray else { return false }; return array.count > 0 }
            .flatMap {
                try ($0 as! NSArray).map { try IntegrationIssue(json: $0 as! NSDictionary) }
        }
        self.warnings = try json
            .dictionaryForKey("warnings")
            .allValues
            .filter { guard let array = $0 as? NSArray else { return false }; return array.count > 0 }
            .flatMap {
                try ($0 as! NSArray).map { try IntegrationIssue(json: $0 as! NSDictionary) }
        }
        self.testFailures = try json
            .dictionaryForKey("testFailures")
            .allValues
            .filter { guard let array = $0 as? NSArray else { return false }; return array.count > 0 }
            .flatMap {
                try ($0 as! NSArray).map { try IntegrationIssue(json: $0 as! NSDictionary) }
        }
        self.analyzerWarnings = try json
            .dictionaryForKey("analyzerWarnings")
            .allValues
            .filter { guard let array = $0 as? NSArray else { return false }; return array.count > 0 }
            .flatMap {
                try ($0 as! NSArray).map { try IntegrationIssue(json: $0 as! NSDictionary) }
        }
        
        try super.init(json: json)
    }
    
}

private extension NSDictionary {
    func integrationIssue(withKey key: String) throws -> [IntegrationIssue] {
        return try self
            .dictionaryForKey(key)
            .allValues
            .filter { guard let array = $0 as? NSArray else { return false }; return array.count > 0 }
            .flatMap {
                try ($0 as! NSArray).map { try IntegrationIssue(json: $0 as! NSDictionary) }
        }
    }
}
