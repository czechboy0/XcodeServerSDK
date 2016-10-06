//
//  Repository.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 28.06.2015.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation

open class Repository: XcodeServerEntity {
    
    /**
    Enumeration describing HTTP access to the repository
    
    - None:      No users are not allowed to read or write
    - LoggedIn:  Logged in users are allowed to read and write
    */
    public enum HTTPAccessType: Int {
        
        case none = 0
        case loggedIn
        
        public func toString() -> String {
            switch self {
            case .none:
                return "No users are not allowed to read or write"
            case .loggedIn:
                return "Logged in users are allowed to read and write"
            }
        }
        
    }
    
    /**
    Enumeration describing HTTPS access to the repository
    
    - SelectedReadWrite:         Only selected users can read and/or write
    - LoggedInReadSelectedWrite: Only selected users can write but all logged in can read
    - LoggedInReadWrite:         All logged in users can read and write
    */
    public enum SSHAccessType: Int {
        
        case selectedReadWrite = 0
        case loggedInReadSelectedWrite
        case loggedInReadWrite
        
        public func toString() -> String {
            switch self {
            case .selectedReadWrite:
                return "Only selected users can read and/or write"
            case .loggedInReadSelectedWrite:
                return "Only selected users can write but all logged in can read"
            case .loggedInReadWrite:
                return "All logged in users can read and write"
            }
        }
        
    }
    
    open let name: String
    open var httpAccess: HTTPAccessType = HTTPAccessType.none
    // XCS's defualt if SelectedReadWrite but if you don't provide 
    // array of IDs, nobody will have access to the repository
    open var sshAccess: SSHAccessType = SSHAccessType.loggedInReadWrite
    open var writeAccessExternalIds: [String] = []
    open var readAccessExternalIds: [String] = []
    
    /**
    Designated initializer.
    
    - parameter name:                   Name of the repository.
    - parameter httpsAccess:            HTTPS access type for the users.
    - parameter sshAccess:              SSH access type for the users.
    - parameter writeAccessExternalIds: ID of users allowed to write to the repository.
    - parameter readAccessExternalIds:  ID of users allowed to read from the repository.
    
    - returns: Initialized repository struct.
    */
    public init(name: String, httpAccess: HTTPAccessType?, sshAccess: SSHAccessType?, writeAccessExternalIds: [String]?, readAccessExternalIds: [String]?) {
        self.name = name
        
        if let httpAccess = httpAccess {
            self.httpAccess = httpAccess
        }
        
        if let sshAccess = sshAccess {
            self.sshAccess = sshAccess
        }
        
        if let writeIDs = writeAccessExternalIds {
            self.writeAccessExternalIds = writeIDs
        }
        
        if let readIDs = readAccessExternalIds {
            self.readAccessExternalIds = readIDs
        }
        
        super.init()
    }
    
    /**
    Convenience initializer.
    This initializer will only allow you to provie name and will create a
    deault repository with values set to:
    - **HTTP Access** - No user is allowed to read/write to repository
    - **SSH Access** - Only selected users are allowed to read/write to repository
    - **Empty arrays** of write and rad external IDs
    
    - parameter name: Name of the repository.
    
    - returns: Initialized default repository wwith provided name
    */
    public convenience init(name: String) {
        self.init(name: name, httpAccess: nil, sshAccess: nil, writeAccessExternalIds: nil, readAccessExternalIds: nil)
    }
    
    /**
    Repository constructor from JSON object.
    
    - parameter json: JSON dictionary representing repository.
    
    - returns: Initialized repository struct.
    */
    public required init(json: NSDictionary) throws {
        self.name = try json.stringForKey("name")
        
        self.httpAccess = HTTPAccessType(rawValue: try json.intForKey("httpAccessType"))!
        self.sshAccess = SSHAccessType(rawValue: try json.intForKey("posixPermissions"))!
        
        self.writeAccessExternalIds = try json.arrayForKey("writeAccessExternalIDs")
        self.readAccessExternalIds = try json.arrayForKey("readAccessExternalIDs")
        
        try super.init(json: json)
    }
    
    /**
    Method for returning object in form of Dictionary.
    
    - returns: Dictionary representing JSON value of Repository object.
    */
    open override func dictionarify() -> [String: Any] {
        var dict: [String: Any] = [:]
        
        dict["name"] = self.name
        dict["httpAccessType"] = self.httpAccess.rawValue
        dict["posixPermissions"] = self.sshAccess.rawValue
        dict["writeAccessExternalIDs"] = self.writeAccessExternalIds
        dict["readAccessExternalIDs"] = self.readAccessExternalIds
        
        return dict
    }
    
}
