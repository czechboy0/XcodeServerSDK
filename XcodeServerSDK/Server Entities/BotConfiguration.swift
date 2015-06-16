//
//  BotConfiguration.swift
//  Buildasaur
//
//  Created by Honza Dvorsky on 14/12/2014.
//  Copyright (c) 2014 Honza Dvorsky. All rights reserved.
//

import Foundation

public class BotConfiguration : XcodeServerEntity {
    
    public enum CleaningPolicy : Int {
        case Never = 0
        case Always
        case Once_a_Day
        case Once_a_Week
        
        public func toString() -> String {
            switch self {
            case .Never:
                return "Never"
            case .Always:
                return "Always"
            case .Once_a_Day:
                return "Once a day (first build)"
            case .Once_a_Week:
                return "Once a week (first build)"
            }
        }
    }
    
    public enum DeviceType : String {
        case Simulator = "com.apple.iphone-simulator"
        case Mac = "com.apple.mac"
        case iPhone = "com.apple.iphone" //also includes iPad and iPod Touch
    }
    
    public enum TestingDestinationIdentifier : Int {
        case iOS_AllDevicesAndSimulators = 0 //iOS default - for build only
        case iOS_AllDevices = 1
        case iOS_AllSimulators = 2
        case iOS_SelectedDevicesAndSimulators = 3
        case Mac = 7 //Mac default (probably, crashes when saving in Xcode) - for build only
        case AllCompatible = 8 //All Compatible default - for build only
        
        public func toString() -> String {
            switch self {
            case .iOS_AllDevicesAndSimulators:
                return "iOS: All Devices and Simulators"
            case .iOS_AllDevices:
                return "iOS: All Devices"
            case .iOS_AllSimulators:
                return "iOS: All Simulators"
            case .iOS_SelectedDevicesAndSimulators:
                return "iOS: Selected Devices and Simulators"
            case .Mac:
                return "Mac"
            case .AllCompatible:
                return "All Compatible (Mac + iOS)"
            }
        }
        
        public func allowedDeviceTypes() -> [DeviceType] {
            switch self {
            case .iOS_AllDevicesAndSimulators:
                return [.iPhone, .Simulator]
            case .iOS_AllDevices:
                return [.iPhone]
            case .iOS_AllSimulators:
                return [.Simulator]
            case .iOS_SelectedDevicesAndSimulators:
                return [.iPhone, .Simulator]
            case .Mac:
                return [.Mac]
            case .AllCompatible:
                return [.iPhone, .Simulator, .Mac]
            }
        }
    }
    
    public let builtFromClean: CleaningPolicy!
    public let analyze: Bool
    public let test: Bool
    public let archive: Bool
    public let schemeName: String
    public let schedule: BotSchedule
    public let triggers: [Trigger]
    public let testingDestinationType: TestingDestinationIdentifier?
    public let testingDeviceIDs: [String]
    public let sourceControlBlueprint: SourceControlBlueprint
    
    public required init(json: NSDictionary) {
        
        self.builtFromClean = CleaningPolicy(rawValue: json.intForKey("builtFromClean"))
        self.analyze = json.boolForKey("performsAnalyzeAction")
        self.archive = json.boolForKey("performsArchiveAction")
        self.test = json.boolForKey("performsTestAction")
        self.schemeName = json.stringForKey("schemeName")
        self.schedule = BotSchedule(json: json)
        self.triggers = XcodeServerArray(json.arrayForKey("triggers"))
        self.testingDestinationType = TestingDestinationIdentifier(rawValue: json.intForKey("testingDestinationType"))
        self.testingDeviceIDs = json.arrayForKey("testingDeviceIDs")
        self.sourceControlBlueprint = SourceControlBlueprint(json: json.dictionaryForKey("sourceControlBlueprint"))
        
        super.init(json: json)
    }
    
    public init(
        builtFromClean: CleaningPolicy,
        analyze: Bool,
        test: Bool,
        archive: Bool,
        schemeName: String,
        schedule: BotSchedule,
        triggers: [Trigger],
        testingDeviceIDs: [String],
        testingDestinationType: TestingDestinationIdentifier,
        sourceControlBlueprint: SourceControlBlueprint) {
            
            self.builtFromClean = builtFromClean
            self.analyze = analyze
            self.test = test
            self.archive = archive
            self.schemeName = schemeName
            self.schedule = schedule
            self.triggers = triggers
            self.testingDeviceIDs = testingDeviceIDs
            self.sourceControlBlueprint = sourceControlBlueprint
            self.testingDestinationType = testingDestinationType
            
            super.init()
    }
    
    public override func dictionarify() -> NSDictionary {
        
        let dictionary = NSMutableDictionary()
        
        //blueprint
        dictionary["sourceControlBlueprint"] = self.sourceControlBlueprint.dictionarify()
        
        //others
        dictionary["builtFromClean"] = self.builtFromClean.rawValue
        dictionary["performsTestAction"] = self.test
        dictionary["triggers"] = self.triggers.map { $0.dictionarify() }
        dictionary["performsAnalyzeAction"] = self.analyze
        dictionary["schemeName"] = self.schemeName
        dictionary["testingDeviceIDs"] = self.testingDeviceIDs
        dictionary["performsArchiveAction"] = self.archive
        dictionary["testingDestinationType"] = self.testingDestinationType?.rawValue //TODO: figure out if we need this
        
        let botScheduleDict = self.schedule.dictionarify() //needs to be merged into the main bot config dict
        dictionary.addEntriesFromDictionary(botScheduleDict as [NSObject : AnyObject])
        
        return dictionary
    }
}