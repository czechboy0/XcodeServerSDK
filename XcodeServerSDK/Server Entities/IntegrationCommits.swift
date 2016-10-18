//
//  IntegrationCommits.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 23/07/15.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation
import BuildaUtils

open class IntegrationCommits: XcodeServerEntity {
    
    open let integration: String
    open let botTinyID: String
    open let botID: String
    open let commits: [String: [Commit]]
    open let endedTimeDate: Date?
    
    public required init(json: NSDictionary) throws {
        self.integration = try json.stringForKey("integration")
        self.botTinyID = try json.stringForKey("botTinyID")
        self.botID = try json.stringForKey("botID")
        self.commits = try IntegrationCommits.populateCommits(try json.dictionaryForKey("commits"))
        self.endedTimeDate = IntegrationCommits.parseDate(try json.arrayForKey("endedTimeDate"))
        
        try super.init(json: json)
    }
    
    /**
    Method for populating commits property with data from JSON dictionary.
    
    - parameter json: JSON dictionary with blueprints and commits for each one.
    
    - returns: Dictionary of parsed Commit objects.
    */
    class func populateCommits(_ json: NSDictionary) throws -> [String: [Commit]] {
        var resultsDictionary: [String: [Commit]] = Dictionary()
        
        for (key, value) in json {
            guard let blueprintID = key as? String, let commitsArray = value as? [NSDictionary] else {
                Log.error("Couldn't parse key \(key) and value \(value)")
                continue
            }
            
            resultsDictionary[blueprintID] = try commitsArray.map { try Commit(json: $0) }
        }
        
        return resultsDictionary
    }
    
    /**
    Parser for data objects which comes in form of array.
    
    - parameter array: Array with date components.
    
    - returns: Optional parsed date to the format used by Xcode Server.
    */
    class func parseDate(_ array: NSArray) -> Date? {
        guard let dateArray = array as? [Int] else {
            Log.error("Couldn't parse XCS date array")
            return nil
        }
        
        do {
            let stringDate = try dateArray.dateString()
            
            guard let date = Date.dateFromXCSString(stringDate) else {
                Log.error("Formatter couldn't parse date")
                return nil
            }
            
            return date
        } catch DateParsingError.wrongNumberOfElements(let elements) {
            Log.error("Couldn't parse date as Array has \(elements) elements")
        } catch {
            Log.error("Something went wrong while parsing date")
        }
        
        return nil
    }
    
}
