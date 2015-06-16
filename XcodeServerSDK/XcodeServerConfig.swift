//
//  XcodeServerConfig.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 13.06.2015.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation

public enum AvailabilityCheckState {
    case Unchecked
    case Checking
    case Failed(NSError?)
    case Succeeded
}

public class XcodeServerConfig : JSONSerializable {
    
    public enum APIVersion: String {
        case Xcode6 = "Xcode 6"
        case Xcode7 = "Xcode 7"
    }
    
    public let host: String
    public let user: String?
    public let password: String?
    public let port: Int = 20343
    public let apiVersion: APIVersion
    public let version: Int = 3 //currently supported, each response has a header X-XCSAPIVersion: 3...
    
    public var availabilityState: AvailabilityCheckState
    
    public func jsonify() -> NSDictionary {
        
        let dict = NSMutableDictionary()
        dict["host"] = self.host
        dict["api_version"] = self.apiVersion.rawValue
        dict.optionallyAddValueForKey(self.user, key: "user")
        dict.optionallyAddValueForKey(self.password, key: "password")
        return dict
    }
    
    public init(var host: String, apiVersion: APIVersion, user: String?, password: String?) {
        
        // validate if host is a valid URL
        if let url = NSURL(string: host) {
            if url.scheme.isEmpty {
                // exted host with https scheme
                host.extend("https://")
            } else if url.scheme != "https" {
                Log.error("Xcode Server generally uses https, please double check your hostname")
            }
        }
        
        self.host = host
        self.user = user
        self.password = password
        self.apiVersion = apiVersion
        self.availabilityState = .Unchecked
    }
    
    public required init?(json: NSDictionary) {
        
        self.availabilityState = .Unchecked
        
        if
            let host = json.optionalStringForKey("host"),
            let apiVersionString = json.optionalStringForKey("api_version")
        {
            
            self.host = host
            self.user = json.optionalStringForKey("user")
            self.password = json.optionalStringForKey("password")
            self.apiVersion = APIVersion(rawValue: apiVersionString)!
            
        } else {
            self.host = ""
            self.user = nil
            self.password = nil
            self.apiVersion = APIVersion.Xcode6
            return nil
        }
    }
}