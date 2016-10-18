//
//  EmailConfiguration.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 13.06.2015.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation

open class EmailConfiguration : XcodeServerEntity {
    
    open let additionalRecipients: [String]
    open let emailCommitters: Bool
    open let includeCommitMessages: Bool
    open let includeIssueDetails: Bool
    
    public init(additionalRecipients: [String], emailCommitters: Bool, includeCommitMessages: Bool, includeIssueDetails: Bool) {
        
        self.additionalRecipients = additionalRecipients
        self.emailCommitters = emailCommitters
        self.includeCommitMessages = includeCommitMessages
        self.includeIssueDetails = includeIssueDetails
        
        super.init()
    }
    
    open override func dictionarify() -> [String: Any] {
        
        var dict: [String: Any] = [:]
        
        dict["emailCommitters"] = self.emailCommitters
        dict["includeCommitMessages"] = self.includeCommitMessages
        dict["includeIssueDetails"] = self.includeIssueDetails
        dict["additionalRecipients"] = self.additionalRecipients
        
        return dict
    }
    
    public required init(json: NSDictionary) throws {
        
        self.emailCommitters = try json.boolForKey("emailCommitters")
        self.includeCommitMessages = try json.boolForKey("includeCommitMessages")
        self.includeIssueDetails = try json.boolForKey("includeIssueDetails")
        self.additionalRecipients = try json.arrayForKey("additionalRecipients")
        
        try super.init(json: json)
    }
}
