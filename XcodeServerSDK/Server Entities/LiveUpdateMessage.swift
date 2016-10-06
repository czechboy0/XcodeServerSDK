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
        case BotCreated = "botCreated"
        case BotUpdated = "botUpdated"
        case BotRemoved = "botRemoved"
        
        //devices
        case DeviceCreated = "deviceCreated"
        case DeviceUpdated = "deviceUpdated"
        case DeviceRemoved = "deviceRemoved"
        
        //integrations
        case PendingIntegrations = "pendingIntegrations"
        case IntegrationCreated = "integrationCreated"
        case IntegrationStatus = "integrationStatus"
        case IntegrationCanceled = "cancelIntegration"
        case IntegrationRemoved = "integrationRemoved"
        case AdvisoryIntegrationStatus = "advisoryIntegrationStatus"
        
        //repositories
        case ListRepositories = "listRepositories"
        case CreateRepository = "createRepository"
        
        //boilerplate
        case Ping = "ping"
        case Pong = "pong"
        case ACLUpdated = "aclUpdated"
        case RequestPortalSync = "requestPortalSync"
        
        case Unknown = ""
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
        
        self.type = MessageType(rawValue: typeString) ?? .Unknown
        
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
