//
//  EmailConfiguration.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 13.06.2015.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation

public class EmailConfiguration : XcodeServerEntity {
    
    public let additionalRecipients: [String]
    public let emailCommitters: Bool
    public let includeCommitMessages: Bool
    public let includeIssueDetails: Bool
    
    public init?(additionalRecipients: [String], emailCommitters: Bool, includeCommitMessages: Bool, includeIssueDetails: Bool) {
        
        self.additionalRecipients = additionalRecipients
        self.emailCommitters = emailCommitters
        self.includeCommitMessages = includeCommitMessages
        self.includeIssueDetails = includeIssueDetails
        
        super.init()
    }
    
    public override func dictionarify() -> NSDictionary {
        
        let dict = NSMutableDictionary()
        
        dict["emailCommitters"] = self.emailCommitters
        dict["includeCommitMessages"] = self.includeCommitMessages
        dict["includeIssueDetails"] = self.includeIssueDetails
        dict["additionalRecipients"] = self.additionalRecipients
        
        return dict
    }
    
    public required init(json: NSDictionary) {
        
        self.emailCommitters = json.boolForKey("emailCommitters")
        self.includeCommitMessages = json.boolForKey("includeCommitMessages")
        self.includeIssueDetails = json.boolForKey("includeIssueDetails")
        self.additionalRecipients = json.arrayForKey("additionalRecipients")
        
        super.init(json: json)
    }
}