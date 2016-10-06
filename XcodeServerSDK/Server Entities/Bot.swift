//
//  Bot.swift
//  Buildasaur
//
//  Created by Honza Dvorsky on 14/12/2014.
//  Copyright (c) 2014 Honza Dvorsky. All rights reserved.
//

import Foundation

open class Bot : XcodeServerEntity {
    
    open let name: String
    open let configuration: BotConfiguration
    open let integrationsCount: Int

    public required init(json: NSDictionary) throws {
        
        self.name = try json.stringForKey("name")
        self.configuration = try BotConfiguration(json: try json.dictionaryForKey("configuration"))
        self.integrationsCount = json.optionalIntForKey("integration_counter") ?? 0
        
        try super.init(json: json)
    }
    
    /**
    *  Creating bots on the server. Needs dictionary representation.
    */
    public init(name: String, configuration: BotConfiguration) {
        
        self.name = name
        self.configuration = configuration
        self.integrationsCount = 0
        
        super.init()
    }

    open override func dictionarify() -> [String: Any] {
        
        var dictionary: [String: Any] = [:]
        
        //name
        dictionary["name"] = self.name
        
        //configuration
        dictionary["configuration"] = self.configuration.dictionarify()
        
        //others
        dictionary["type"] = 1 //magic more
        dictionary["requiresUpgrade"] = false
        dictionary["group"] = [
            "name": UUID().uuidString
        ]
        
        return dictionary
    }
    

}

extension Bot : CustomStringConvertible {
    public var description : String {
        get {
            return "[Bot \(self.name)]"
        }
    }
}


