//
//  XcodeServerEntity.swift
//  Buildasaur
//
//  Created by Honza Dvorsky on 14/12/2014.
//  Copyright (c) 2014 Honza Dvorsky. All rights reserved.
//

import Foundation

public protocol XcodeRead {
    init(json: NSDictionary) throws
}

public protocol XcodeWrite {
    func dictionarify() -> [String: Any]
}

open class XcodeServerEntity : XcodeRead, XcodeWrite {
    
    open let id: String!
    open let rev: String!
    open let tinyID: String!
    open let docType: String!
    
    //when created from json, let's save the original data here.
    open let originalJSON: [String: Any]?
    
    //initializer which takes a dictionary and fills in values for recognized keys
    public required init(json: NSDictionary) throws {
        
        self.id = json.optionalStringForKey("_id")
        self.rev = json.optionalStringForKey("_rev")
        self.tinyID = json.optionalStringForKey("tinyID")
        self.docType = json.optionalStringForKey("doc_type")
        self.originalJSON = json.copy() as? [String: Any]
    }
    
    public init() {
        self.id = nil
        self.rev = nil
        self.tinyID = nil
        self.docType = nil
        self.originalJSON = nil
    }
    
    open func dictionarify() -> [String: Any] {
        assertionFailure("Must be overriden by subclasses that wish to dictionarify their data")
        return [:]
    }
    
    open class func optional<T: XcodeRead>(_ json: NSDictionary?) throws -> T? {
        if let json = json {
            return try T(json: json)
        }
        return nil
    }
}

//parse an array of dictionaries into an array of parsed entities
public func XcodeServerArray<T>(_ jsonArray: NSArray) throws -> [T] where T:XcodeRead {
    
    let array = jsonArray as! [NSDictionary]
    let parsed = try array.map { (json: NSDictionary) -> (T) in
        return try T(json: json)
    }
    return parsed
}

