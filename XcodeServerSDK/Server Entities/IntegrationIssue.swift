//
//  Issue.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 04.08.2015.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation

open class IntegrationIssue: XcodeServerEntity {
    
    public enum IssueType: String {
        case BuildServiceError = "buildServiceError"
        case BuildServiceWarning = "buildServiceWarning"
        case TriggerError = "triggerError"
        case Error = "error"
        case Warning = "warning"
        case TestFailure = "testFailure"
        case AnalyzerWarning = "analyzerWarning"
    }
    
    public enum IssueStatus: Int {
        case fresh = 0
        case unresolved
        case resolved
        case silenced
    }
    
    /// Payload is holding whole Dictionary of the Issue
    open let payload: NSDictionary
    
    open let message: String?
    open let type: IssueType
    open let issueType: String
    open let commits: [Commit]
    open let integrationID: String
    open let age: Int
    open let status: IssueStatus
    
    // MARK: Initialization
    public required init(json: NSDictionary) throws {
        self.payload = json.copy() as? NSDictionary ?? NSDictionary()
        
        self.message = json.optionalStringForKey("message")
        self.type = try IssueType(rawValue: json.stringForKey("type"))!
        self.issueType = try json.stringForKey("issueType")
        self.commits = try json.arrayForKey("commits").map { try Commit(json: $0) }
        self.integrationID = try json.stringForKey("integrationID")
        self.age = try json.intForKey("age")
        self.status = IssueStatus(rawValue: try json.intForKey("status"))!
        
        try super.init(json: json)
    }
    
}
