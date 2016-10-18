//
//  Commit.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 21/07/15.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation

open class Commit: XcodeServerEntity {
    
    open let hash: String
    open let filePaths: [File]
    open let message: String?
    open let date: Date
    open let repositoryID: String
    open let contributor: Contributor
    
    // MARK: Initializers
    public required init(json: NSDictionary) throws {
        self.hash = try json.stringForKey("XCSCommitHash")
        self.filePaths = try json.arrayForKey("XCSCommitCommitChangeFilePaths").map { try File(json: $0) }
        self.message = json.optionalStringForKey("XCSCommitMessage")
        self.date = try json.dateForKey("XCSCommitTimestamp")
        self.repositoryID = try json.stringForKey("XCSBlueprintRepositoryID")
        self.contributor = try Contributor(json: try json.dictionaryForKey("XCSCommitContributor"))
        
        try super.init(json: json)
    }
    
}
