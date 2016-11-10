//
//  Device.swift
//  Buildasaur
//
//  Created by Honza Dvorsky on 15/03/2015.
//  Copyright (c) 2015 Honza Dvorsky. All rights reserved.
//

import Foundation
import BuildaUtils

open class Device : XcodeServerEntity {
    
    open let osVersion: String
    open let connected: Bool
    open let simulator: Bool
    open let modelCode: String? // Enum?
    open let deviceType: String? // Enum?
    open let modelName: String?
    open let deviceECID: String?
    open let modelUTI: String?
    open let activeProxiedDevice: Device?
    open let trusted: Bool
    open let name: String
    open let supported: Bool
    open let processor: String?
    open let identifier: String
    open let enabledForDevelopment: Bool
    open let serialNumber: String?
    open let platform: DevicePlatform.PlatformType
    open let architecture: String // Enum?
    open let isServer: Bool
    open let retina: Bool
    
    public required init(json: NSDictionary) throws {
        
        self.connected = try json.boolForKey("connected")
        self.osVersion = try json.stringForKey("osVersion")
        self.simulator = try json.boolForKey("simulator")
        self.modelCode = json.optionalStringForKey("modelCode")
        self.deviceType = json.optionalStringForKey("deviceType")
        self.modelName = json.optionalStringForKey("modelName")
        self.deviceECID = json.optionalStringForKey("deviceECID")
        self.modelUTI = json.optionalStringForKey("modelUTI")
        if let proxyDevice = json.optionalDictionaryForKey("activeProxiedDevice") {
            self.activeProxiedDevice = try Device(json: proxyDevice)
        } else {
            self.activeProxiedDevice = nil
        }
        self.trusted = json.optionalBoolForKey("trusted") ?? false
        self.name = try json.stringForKey("name")
        self.supported = try json.boolForKey("supported")
        self.processor = json.optionalStringForKey("processor")
        self.identifier = try json.stringForKey("identifier")
        self.enabledForDevelopment = try json.boolForKey("enabledForDevelopment")
        self.serialNumber = json.optionalStringForKey("serialNumber")
        self.platform = DevicePlatform.PlatformType(rawValue: try json.stringForKey("platformIdentifier")) ?? .Unknown
        self.architecture = try json.stringForKey("architecture")
        
        //for some reason which is not yet clear to me (probably old/new XcS versions), sometimes
        //the key is "server" and sometimes "isServer". this just picks up the present one.
        self.isServer = json.optionalBoolForKey("server") ?? json.optionalBoolForKey("isServer") ?? false
        self.retina = try json.boolForKey("retina")
        
        try super.init(json: json)
    }
    
    open override func dictionarify() -> [String: Any] {
        
        return [
            "device_id": self.id
        ]
    }
    
}
