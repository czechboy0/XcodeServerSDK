//
//  Contributor.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 21/07/15.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation

// MARK: Constants
let kContributorName = "XCSContributorName"
let kContributorDisplayName = "XCSContributorDisplayName"
let kContributorEmails = "XCSContributorEmails"

open class Contributor: XcodeServerEntity {
    
    open let name: String
    open let displayName: String
    open let emails: [String]
    
    public required init(json: NSDictionary) throws {
        self.name = try json.stringForKey(kContributorName)
        self.displayName = try json.stringForKey(kContributorDisplayName)
        self.emails = try json.arrayForKey(kContributorEmails)
        
        try super.init(json: json)
    }
    
    open override func dictionarify() -> [String: Any] {
        return [
            kContributorName: self.name,
            kContributorDisplayName: self.displayName,
            kContributorEmails: self.emails
        ]
    }
    
    open func description() -> String {
        return "\(displayName) [\(emails[0])]"
    }
    
}
