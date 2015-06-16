//
//  Trigger.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 13.06.2015.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation

public class Trigger : XcodeServerEntity {
    
    public enum Phase: Int {
        case Prebuild = 1
        case Postbuild
        
        public func toString() -> String {
            switch self {
            case .Prebuild:
                return "Run Before the Build"
            case .Postbuild:
                return "Run After the Build"
            }
        }
    }
    
    public enum Kind: Int {
        case RunScript = 1
        case EmailNotification
        
        public func toString() -> String {
            switch self {
            case .RunScript:
                return "Run Script"
            case .EmailNotification:
                return "Send Email"
            }
        }
    }
    
    public let phase: Phase
    public let kind: Kind
    public let scriptBody: String
    public let name: String
    public let conditions: TriggerConditions?
    public let emailConfiguration: EmailConfiguration?
    
    public let uniqueId: String //only for in memory manipulation, don't persist anywhere
    
    public init?(phase: Phase, kind: Kind, scriptBody: String?, name: String?,
        conditions: TriggerConditions?, emailConfiguration: EmailConfiguration?) {
            
            self.phase = phase
            self.kind = kind
            self.scriptBody = scriptBody ?? ""
            self.name = name ?? kind.toString()
            self.conditions = conditions
            self.emailConfiguration = emailConfiguration
            self.uniqueId = NSUUID().UUIDString
            
            super.init()
            
            //post build triggers must have conditions
            if phase == Phase.Postbuild {
                if conditions == nil {
                    return nil
                }
            }
            
            //email type must have a configuration
            if kind == Kind.EmailNotification {
                if emailConfiguration == nil {
                    return nil
                }
            }
    }
    
    public override func dictionarify() -> NSDictionary {
        
        let dict = NSMutableDictionary()
        
        dict["phase"] = self.phase.rawValue
        dict["type"] = self.kind.rawValue
        dict["scriptBody"] = self.scriptBody
        dict["name"] = self.name
        dict.optionallyAddValueForKey(self.conditions?.dictionarify(), key: "conditions")
        dict.optionallyAddValueForKey(self.emailConfiguration?.dictionarify(), key: "emailConfiguration")
        
        return dict
    }
    
    public required init(json: NSDictionary) {
        
        let phase = Phase(rawValue: json.intForKey("phase"))!
        self.phase = phase
        if let conditionsJSON = json.optionalDictionaryForKey("conditions") where phase == .Postbuild {
            //also parse conditions
            self.conditions = TriggerConditions(json: conditionsJSON)
        } else {
            self.conditions = nil
        }
        
        let kind = Kind(rawValue: json.intForKey("type"))!
        self.kind = kind
        if let configurationJSON = json.optionalDictionaryForKey("emailConfiguration") where kind == .EmailNotification {
            //also parse email config
            self.emailConfiguration = EmailConfiguration(json: configurationJSON)
        } else {
            self.emailConfiguration = nil
        }
        
        self.name = json.stringForKey("name")
        self.scriptBody = json.stringForKey("scriptBody")
        
        self.uniqueId = NSUUID().UUIDString
        
        super.init(json: json)
    }
}