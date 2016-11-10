//
//  BotConfiguration.swift
//  Buildasaur
//
//  Created by Honza Dvorsky on 14/12/2014.
//  Copyright (c) 2014 Honza Dvorsky. All rights reserved.
//

import Foundation

open class BotConfiguration : XcodeServerEntity {
    
    /**
    Enum with values describing when Bots history
    should be cleaned.
    
    - Never:       Never clean
    - Always:      Clean always project is opened
    - Once_a_Day:  Clean once a day on first build
    - Once_a_Week: Clean once a week on first build
    */
    public enum CleaningPolicy : Int {
        case never = 0
        case always
        case once_a_Day
        case once_a_Week
        
        /**
        Method for preinting in human readable Bots
        cleaning policy
        
        - returns: String with cleaning policy description
        */
        public func toString() -> String {
            switch self {
                case .never:
                    return "Never"
                case .always:
                    return "Always"
                case .once_a_Day:
                    return "Once a day (first build)"
                case .once_a_Week:
                    return "Once a week (first build)"
            }
        }
    }
    
    /**
    Enum which describes type of available devices.
    
    - Simulator: iOS simulator (can be any device running iOS)
    - Mac:       Mac with installed OS X
    - iPhone:    iOS device (includes iPhone, iPad and iPod Touch)
    */
    public enum DeviceType : String {
        case Simulator = "com.apple.iphone-simulator"
        case Mac = "com.apple.mac"
        case iPhone = "com.apple.iphone"
    }
    
    /**
    Legacy property of what devices should be tested on. Now moved to `DeviceSpecification`, but
    sending 0 or 7 still required. Sigh.
    */
    public enum TestingDestinationIdentifier : Int {
        case iOSAndWatch = 0
        case mac = 7
    }
    
    /**
    Enum which describes whether code coverage data should be collected during tests.
    
    - Disabled:             Turned off
    - Enabled:              Turned on, regardless of the preference in Scheme
    - UseSchemeSettings:    Respects the preference in Scheme
    */
    public enum CodeCoveragePreference: Int {
        case disabled = 0
        case enabled = 1
        case useSchemeSetting = 2
    }
    
    /**
    Enum describing build config preference. Xcode 7 API allows for overriding a config setup in the scheme for a specific one. UseSchemeSetting is the default.
    */
    public enum BuildConfiguration {
        case overrideWithSpecific(String)
        case useSchemeSetting
    }
    
    open let builtFromClean: CleaningPolicy
    open let codeCoveragePreference: CodeCoveragePreference
    open let buildConfiguration: BuildConfiguration
    open let analyze: Bool
    open let test: Bool
    open let archive: Bool
    open let exportsProductFromArchive: Bool
    open let schemeName: String
    open let schedule: BotSchedule
    open let triggers: [Trigger]
    open var testingDestinationType: TestingDestinationIdentifier {
        get {
            if let firstFilter = self.deviceSpecification.filters.first {
                if case .OSX = firstFilter.platform.type {
                    return .mac
                }
            }
            return .iOSAndWatch
        }
    }
    open let deviceSpecification: DeviceSpecification
    open let sourceControlBlueprint: SourceControlBlueprint
    
    public required init(json: NSDictionary) throws {
        
        self.builtFromClean = CleaningPolicy(rawValue: try json.intForKey("builtFromClean")) ?? .never
        self.codeCoveragePreference = CodeCoveragePreference(rawValue: json.optionalIntForKey("codeCoveragePreference") ?? 0) ?? .useSchemeSetting
        
        if let buildConfigOverride = json.optionalStringForKey("buildConfiguration") {
            self.buildConfiguration = BuildConfiguration.overrideWithSpecific(buildConfigOverride)
        } else {
            self.buildConfiguration = .useSchemeSetting
        }
        self.analyze = try json.boolForKey("performsAnalyzeAction")
        self.archive = try json.boolForKey("performsArchiveAction")
        self.exportsProductFromArchive = json.optionalBoolForKey("exportsProductFromArchive") ?? false
        self.test = try json.boolForKey("performsTestAction")
        self.schemeName = try json.stringForKey("schemeName")
        self.schedule = try BotSchedule(json: json)
        self.triggers = try XcodeServerArray(try json.arrayForKey("triggers"))
        self.sourceControlBlueprint = try SourceControlBlueprint(json: try json.dictionaryForKey("sourceControlBlueprint"))
        
        //old bots (xcode 6) only have testingDeviceIds, try to parse those into the new format of DeviceSpecification (xcode 7)
        if let deviceSpecJSON = json.optionalDictionaryForKey("deviceSpecification") {
            self.deviceSpecification = try DeviceSpecification(json: deviceSpecJSON)
        } else {
            if let testingDeviceIds = json.optionalArrayForKey("testingDeviceIDs") as? [String] {
                self.deviceSpecification = DeviceSpecification(testingDeviceIDs: testingDeviceIds)
            } else {
                self.deviceSpecification = DeviceSpecification(testingDeviceIDs: [])
            }
        }
        
        try super.init(json: json)
    }
    
    public init(
        builtFromClean: CleaningPolicy,
        codeCoveragePreference: CodeCoveragePreference = .useSchemeSetting,
        buildConfiguration: BuildConfiguration = .useSchemeSetting,
        analyze: Bool,
        test: Bool,
        archive: Bool,
        exportsProductFromArchive: Bool = true,
        schemeName: String,
        schedule: BotSchedule,
        triggers: [Trigger],
        deviceSpecification: DeviceSpecification,
        sourceControlBlueprint: SourceControlBlueprint) {
            
            self.builtFromClean = builtFromClean
            self.codeCoveragePreference = codeCoveragePreference
            self.buildConfiguration = buildConfiguration
            self.analyze = analyze
            self.test = test
            self.archive = archive
            self.exportsProductFromArchive = exportsProductFromArchive
            self.schemeName = schemeName
            self.schedule = schedule
            self.triggers = triggers
            self.deviceSpecification = deviceSpecification
            self.sourceControlBlueprint = sourceControlBlueprint
            
            super.init()
    }
    
    open override func dictionarify() -> [String: Any] {
        
        var dictionary: [String: Any] = [:]
        
        //blueprint
        dictionary["sourceControlBlueprint"] = self.sourceControlBlueprint.dictionarify()
        
        //others
        dictionary["builtFromClean"] = self.builtFromClean.rawValue
        dictionary["codeCoveragePreference"] = self.codeCoveragePreference.rawValue
        dictionary["performsTestAction"] = self.test
        dictionary["triggers"] = self.triggers.map { $0.dictionarify() }
        dictionary["performsAnalyzeAction"] = self.analyze
        dictionary["schemeName"] = self.schemeName
        dictionary["deviceSpecification"] = self.deviceSpecification.dictionarify()
        dictionary["performsArchiveAction"] = self.archive
        dictionary["exportsProductFromArchive"] = self.exportsProductFromArchive
        dictionary["testingDestinationType"] = self.testingDestinationType.rawValue //TODO: figure out if we still need this in Xcode 7
        
        if case .overrideWithSpecific(let buildConfig) = self.buildConfiguration {
            dictionary["buildConfiguration"] = buildConfig
        }
        
        let botScheduleDict = self.schedule.dictionarify() //needs to be merged into the main bot config dict
        dictionary.merge(with: botScheduleDict)
        
        return dictionary
    }
}

private extension Dictionary {
    
    mutating func merge(with dictionary: Dictionary) {
        dictionary.forEach { updateValue($1, forKey: $0) }
    }
    
    func merged(with dictionary: Dictionary) -> Dictionary {
        var dict = self
        dict.merge(with: dictionary)
        return dict
    }
}
