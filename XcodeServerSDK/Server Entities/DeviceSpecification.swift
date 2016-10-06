//
//  DeviceSpecification.swift
//  XcodeServerSDK
//
//  Created by Honza Dvorsky on 24/06/2015.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation

open class DevicePlatform : XcodeServerEntity {
    
    open let displayName: String
    open let version: String
    
    public enum PlatformType: String {
        case Unknown = "unknown"
        case iOS = "com.apple.platform.iphoneos"
        case iOS_Simulator = "com.apple.platform.iphonesimulator"
        case OSX = "com.apple.platform.macosx"
        case watchOS = "com.apple.platform.watchos"
        case watchOS_Simulator = "com.apple.platform.watchsimulator"
        case tvOS = "com.apple.platform.appletvos"
        case tvOS_Simulator = "com.apple.platform.appletvsimulator"
    }
    
    public enum SimulatorType: String {
        case iPhone = "com.apple.platform.iphonesimulator"
        case Watch = "com.apple.platform.watchsimulator"
        case TV = "com.apple.platform.appletvsimulator"
    }
    
    open let type: PlatformType
    open let simulatorType: SimulatorType?
    
    public required init(json: NSDictionary) throws {
        
        self.displayName = try json.stringForKey("displayName")
        self.version = try json.stringForKey("version")
        self.type = PlatformType(rawValue: json.optionalStringForKey("identifier") ?? "") ?? .Unknown
        self.simulatorType = SimulatorType(rawValue: json.optionalStringForKey("simulatorIdentifier") ?? "")
        
        try super.init(json: json)
    }
    
    //for just informing the intention - iOS or WatchOS or OS X - and we'll fetch the real ones and replace this placeholder with a fetched one.
    public init(type: PlatformType) {
        self.type = type
        self.displayName = ""
        self.version = ""
        self.simulatorType = nil
        
        super.init()
    }
    
    open class func OSX() -> DevicePlatform {
        return DevicePlatform(type: DevicePlatform.PlatformType.OSX)
    }
    
    open class func iOS() -> DevicePlatform {
        return DevicePlatform(type: DevicePlatform.PlatformType.iOS)
    }
    
    open class func watchOS() -> DevicePlatform {
        return DevicePlatform(type: DevicePlatform.PlatformType.watchOS)
    }
    
    open class func tvOS() -> DevicePlatform {
        return DevicePlatform(type: DevicePlatform.PlatformType.tvOS)
    }
    
    open override func dictionarify() -> [String: Any] {
        
        //in this case we want everything the way we parsed it.
        if let original = self.originalJSON {
            return original
        }
        
        var dictionary: [String: Any] = [:]
        
        dictionary["displayName"] = self.displayName
        dictionary["version"] = self.version
        dictionary["identifier"] = self.type.rawValue
        dictionary["simulatorIdentifier"] = simulatorType?.rawValue
        
        return dictionary
    }
}

open class DeviceFilter : XcodeServerEntity {
    
    open var platform: DevicePlatform
    
    public enum FilterType: Int {
        case allAvailableDevicesAndSimulators = 0
        case allDevices = 1
        case allSimulators = 2
        case selectedDevicesAndSimulators = 3
        
        public func toString() -> String {
            switch self {
            case .allAvailableDevicesAndSimulators:
                return "All Available Devices and Simulators"
            case .allDevices:
                return "All Devices"
            case .allSimulators:
                return "All Simulators"
            case .selectedDevicesAndSimulators:
                return "Selected Devices and Simulators"
            }
        }
        
        public static func availableFiltersForPlatform(_ platformType: DevicePlatform.PlatformType) -> [FilterType] {
            
            switch platformType {
            case .iOS, .tvOS:
                return [
                    .allAvailableDevicesAndSimulators,
                    .allDevices,
                    .allSimulators,
                    .selectedDevicesAndSimulators
                ]
            case .OSX, .watchOS:
                return [
                    .allAvailableDevicesAndSimulators
                ]
            default:
                return []
            }
        }
    }
    
    open let filterType: FilterType
    
    public enum ArchitectureType: Int {
        case unknown = -1
        case iOS_Like = 0 //also watchOS and tvOS
        case osx_Like = 1
        
        public static func architectureFromPlatformType(_ platformType: DevicePlatform.PlatformType) -> ArchitectureType {
            
            switch platformType {
            case .iOS, .iOS_Simulator, .watchOS, .watchOS_Simulator, .tvOS, .tvOS_Simulator, .Unknown:
                return .iOS_Like
            case .OSX:
                return .osx_Like
            }
        }
    }
    
    open let architectureType: ArchitectureType //TODO: ditto, find out more.
    
    public required init(json: NSDictionary) throws {
        
        self.platform = try DevicePlatform(json: try json.dictionaryForKey("platform"))
        self.filterType = FilterType(rawValue: try json.intForKey("filterType")) ?? .allAvailableDevicesAndSimulators
        self.architectureType = ArchitectureType(rawValue: json.optionalIntForKey("architectureType") ?? -1) ?? .unknown
        
        try super.init(json: json)
    }
    
    public init(platform: DevicePlatform, filterType: FilterType, architectureType: ArchitectureType) {
        self.platform = platform
        self.filterType = filterType
        self.architectureType = architectureType
        
        super.init()
    }
    
    open override func dictionarify() -> [String: Any] {
        
        return [
            "filterType": self.filterType.rawValue,
            "architectureType": self.architectureType.rawValue,
            "platform": self.platform.dictionarify()
        ]
    }
}

open class DeviceSpecification : XcodeServerEntity {
    
    open let deviceIdentifiers: [String]
    open let filters: [DeviceFilter]
    
    public required init(json: NSDictionary) throws {
        
        self.deviceIdentifiers = try json.arrayForKey("deviceIdentifiers")
        self.filters = try XcodeServerArray(try json.arrayForKey("filters"))
        
        try super.init(json: json)
    }
    
    public init(filters: [DeviceFilter], deviceIdentifiers: [String]) {
        self.deviceIdentifiers = deviceIdentifiers
        self.filters = filters
        
        super.init()
    }
    
    /**
    Initializes a new DeviceSpecification object with only a list of tested device ids.
    This is a convenience initializer for compatibility with old Xcode 6 bots that are still hanging around on old servers.
    */
    public init(testingDeviceIDs: [String]) {
        
        self.deviceIdentifiers = testingDeviceIDs
        self.filters = []
        
        super.init()
    }
    
    open override func dictionarify() -> [String: Any] {
        
        return [
            "deviceIdentifiers": self.deviceIdentifiers,
            "filters": self.filters.map({ $0.dictionarify() })
        ]
    }
    
    // MARK: Convenience methods
    
    open class func OSX() -> DeviceSpecification {
        let platform = DevicePlatform.OSX()
        let filter = DeviceFilter(platform: platform, filterType: .allAvailableDevicesAndSimulators, architectureType: .osx_Like)
        let spec = DeviceSpecification(filters: [filter], deviceIdentifiers: [])
        return spec
    }
    
    open class func iOS(_ filterType: DeviceFilter.FilterType, deviceIdentifiers: [String]) -> DeviceSpecification {
        let platform = DevicePlatform.iOS()
        let filter = DeviceFilter(platform: platform, filterType: filterType, architectureType: .iOS_Like)
        let spec = DeviceSpecification(filters: [filter], deviceIdentifiers: deviceIdentifiers)
        return spec
    }
    
    open class func watchOS() -> DeviceSpecification {
        let platform = DevicePlatform.watchOS()
        let filter = DeviceFilter(platform: platform, filterType: .allAvailableDevicesAndSimulators, architectureType: .iOS_Like)
        let spec = DeviceSpecification(filters: [filter], deviceIdentifiers: [])
        return spec
    }
    
    open class func tvOS() -> DeviceSpecification {
        let platform = DevicePlatform.tvOS()
        let filter = DeviceFilter(platform: platform, filterType: .allAvailableDevicesAndSimulators, architectureType: .iOS_Like)
        let spec = DeviceSpecification(filters: [filter], deviceIdentifiers: [])
        return spec
    }
}

