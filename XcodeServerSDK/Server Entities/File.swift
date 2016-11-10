//
//  File.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 21/07/15.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation

open class File: XcodeServerEntity {
    
    open let status: FileStatus
    open let filePath: String
    
    public init(filePath: String, status: FileStatus) {
        self.filePath = filePath
        self.status = status
        
        super.init()
    }
    
    public required init(json: NSDictionary) throws {
        self.filePath = try json.stringForKey("filePath")
        self.status = FileStatus(rawValue: try json.intForKey("status")) ?? .other
        
        try super.init(json: json)
    }
    
    open override func dictionarify() -> [String: Any] {
        return [
            "status": self.status.rawValue,
            "filePath": self.filePath
        ]
    }
    
}

/**
*  Enum which describes file statuses.
*/
public enum FileStatus: Int {
    case added = 1
    case deleted = 2
    case modified = 4
    case moved = 8192
    case other
}
