//
//  LiveUpdateMessage.swift
//  XcodeServerSDK
//
//  Created by Honza Dvorsky on 26/09/2015.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation

open class LiveUpdateMessage: XcodeServerEntity {
    
    public enum MessageType: String {
        
        //bots
        case botCreated = "botCreated"
        case botUpdated = "botUpdated"
        case botRemoved = "botRemoved"
        
        //devices
        case deviceCreated = "deviceCreated"
        case deviceUpdated = "deviceUpdated"
        case deviceRemoved = "deviceRemoved"
        
        //integrations
        case pendingIntegrations = "pendingIntegrations"
        case integrationCreated = "integrationCreated"
        case integrationStatus = "integrationStatus"
        case integrationCanceled = "cancelIntegration"
        case integrationRemoved = "integrationRemoved"
        case advisoryIntegrationStatus = "advisoryIntegrationStatus"
        
        //repositories
        case listRepositories = "listRepositories"
        case createRepository = "createRepository"
        
        //boilerplate
        case ping = "ping"
        case pong = "pong"
        case aclUpdated = "aclUpdated"
        case requestPortalSync = "requestPortalSync"
        
        case unknown = ""
    }
    
    open let type: MessageType
    open let message: String?
    open let progress: Double?
    open let integrationId: String?
    open let botId: String?
    open let result: Integration.Result?
    open let currentStep: Integration.Step?
    
    required public init(json: NSDictionary) throws {
        
        let typeString = json.optionalStringForKey("name") ?? ""
        
        self.type = MessageType(rawValue: typeString) ?? .unknown
        
        let args = (json["args"] as? NSArray)?[0] as? NSDictionary
        
        self.message = args?["message"] as? String
        self.progress = args?["percentage"] as? Double
        self.integrationId = args?["_id"] as? String
        self.botId = args?["botId"] as? String
        
        if
            let resultString = args?["result"] as? String,
            let result = Integration.Result(rawValue: resultString) {
                self.result = result
        } else {
            self.result = nil
        }
        if
            let stepString = args?["currentStep"] as? String,
            let step = Integration.Step(rawValue: stepString) {
                self.currentStep = step
        } else {
            self.currentStep = nil
        }
        
        try super.init(json: json)
    }
    
}

extension LiveUpdateMessage: CustomStringConvertible {
    
    public var description: String {
        
        let empty = "" //fixed in Swift 2.1

        let nonNilComps = [
            self.message,
            "\(self.progress?.description ?? empty)",
            self.result?.rawValue,
            self.currentStep?.rawValue
        ]
            .filter { $0 != nil }
            .map { $0! }
            .filter { $0.characters.count > 0 }
            .map { "\"\($0)\"" }
        
        let str = nonNilComps.joined(separator: ", ")
        return "LiveUpdateMessage \"\(self.type)\", \(str)"
    }
}
