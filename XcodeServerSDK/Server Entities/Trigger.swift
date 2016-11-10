//
//  Trigger.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 13.06.2015.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation
import BuildaUtils

public struct TriggerConfig: XcodeRead, XcodeWrite {
    
    public let id: RefType
    
    public enum Phase: Int {
        case prebuild = 1
        case postbuild
        
        public func toString() -> String {
            switch self {
            case .prebuild:
                return "Run Before the Build"
            case .postbuild:
                return "Run After the Build"
            }
        }
    }
    
    public enum Kind: Int {
        case runScript = 1
        case emailNotification
        
        public func toString() -> String {
            switch self {
            case .runScript:
                return "Run Script"
            case .emailNotification:
                return "Send Email"
            }
        }
    }
    
    public var phase: Phase
    public var kind: Kind
    public var scriptBody: String
    public var name: String
    public var conditions: TriggerConditions?
    public var emailConfiguration: EmailConfiguration?
    
    //creates a default trigger config
    public init() {
        self.phase = .prebuild
        self.kind = .runScript
        self.scriptBody = "cd *\n"
        self.name = ""
        self.conditions = nil
        self.emailConfiguration = nil
        self.id = Ref.new()
    }
    
    public init?(phase: Phase, kind: Kind, scriptBody: String?, name: String?,
        conditions: TriggerConditions?, emailConfiguration: EmailConfiguration?, id: RefType? = Ref.new()) {
            
            self.phase = phase
            self.kind = kind
            self.scriptBody = scriptBody ?? ""
            self.name = name ?? kind.toString()
            self.conditions = conditions
            self.emailConfiguration = emailConfiguration
            self.id = id ?? Ref.new()
            
            //post build triggers must have conditions
            if phase == Phase.postbuild {
                if conditions == nil {
                    return nil
                }
            }
            
            //email type must have a configuration
            if kind == Kind.emailNotification {
                if emailConfiguration == nil {
                    return nil
                }
            }
    }
    
    public init(json: NSDictionary) throws {
        
        let phase = Phase(rawValue: try json.intForKey("phase"))!
        self.phase = phase
        if let conditionsJSON = json.optionalDictionaryForKey("conditions") , phase == .postbuild {
            //also parse conditions
            self.conditions = try TriggerConditions(json: conditionsJSON)
        } else {
            self.conditions = nil
        }
        
        let kind = Kind(rawValue: try json.intForKey("type"))!
        self.kind = kind
        if let configurationJSON = json.optionalDictionaryForKey("emailConfiguration") , kind == .emailNotification {
            //also parse email config
            self.emailConfiguration = try EmailConfiguration(json: configurationJSON)
        } else {
            self.emailConfiguration = nil
        }
        
        self.name = try json.stringForKey("name")
        self.scriptBody = try json.stringForKey("scriptBody")
        
        self.id = json.optionalStringForKey("id") ?? Ref.new()
    }
    
    public func dictionarify() -> [String: Any] {
        
        var dict: [String: Any] = [:]
        
        dict["id"] = self.id
        dict["phase"] = self.phase.rawValue
        dict["type"] = self.kind.rawValue
        dict["scriptBody"] = self.scriptBody
        dict["name"] = self.name
        dict["conditions"] = conditions?.dictionarify()
        dict["emailConfiguration"] = emailConfiguration?.dictionarify()
        
        return dict
    }
}

open class Trigger : XcodeServerEntity {
    
    open let config: TriggerConfig
    
    public init(config: TriggerConfig) {
        self.config = config
        super.init()
    }
    
    required public init(json: NSDictionary) throws {
        
        self.config = try TriggerConfig(json: json)
        try super.init(json: json)
    }
    
    open override func dictionarify() -> [String: Any] {
        let dict = self.config.dictionarify()
        return dict
    }
}




