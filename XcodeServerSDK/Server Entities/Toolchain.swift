//
//  Toolchain.swift
//  XcodeServerSDK
//
//  Created by Laurent Gaches on 21/04/16.
//  Copyright © 2016 Laurent Gaches. All rights reserved.
//

import Foundation

open class Toolchain: XcodeServerEntity {
    
    open let displayName: String
    open let path: String
    open let signatureVerified: Bool
 
    public required init(json: NSDictionary) throws {
        
        self.displayName = try json.stringForKey("displayName")
        self.path = try json.stringForKey("path")
        self.signatureVerified = try json.boolForKey("signatureVerified")
        
        try super.init(json: json)
    }
}
