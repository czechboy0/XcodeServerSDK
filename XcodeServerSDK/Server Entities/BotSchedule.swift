//
//  BotSchedule.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 13.06.2015.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation

open class BotSchedule : XcodeServerEntity {
    
    public enum Schedule : Int {
        
        case periodical = 1
        case commit
        case manual
        
        public func toString() -> String {
            switch self {
            case .periodical:
                return "Periodical"
            case .commit:
                return "On Commit"
            case .manual:
                return "Manual"
            }
        }
    }
    
    public enum Period : Int {
        case hourly = 1
        case daily
        case weekly
    }
    
    public enum Day : Int {
        case monday = 1
        case tuesday
        case wednesday
        case thursday
        case friday
        case saturday
        case sunday
    }
    
    open let schedule: Schedule!
    
    open let period: Period?
    
    open let day: Day!
    open let hours: Int!
    open let minutes: Int!
    
    public required init(json: NSDictionary) throws {
        
        let schedule = Schedule(rawValue: try json.intForKey("scheduleType"))!
        self.schedule = schedule
        
        if schedule == .periodical {
            
            let period = Period(rawValue: try json.intForKey("periodicScheduleInterval"))!
            self.period = period
            
            let minutes = json.optionalIntForKey("minutesAfterHourToIntegrate")
            let hours = json.optionalIntForKey("hourOfIntegration")
            
            switch period {
            case .hourly:
                self.minutes = minutes!
                self.hours = nil
                self.day = nil
            case .daily:
                self.minutes = minutes!
                self.hours = hours!
                self.day = nil
            case .weekly:
                self.minutes = minutes!
                self.hours = hours!
                self.day = Day(rawValue: try json.intForKey("weeklyScheduleDay"))
            }
        } else {
            self.period = nil
            self.minutes = nil
            self.hours = nil
            self.day = nil
        }
        
        try super.init(json: json)
    }
    
    fileprivate init(schedule: Schedule, period: Period?, day: Day?, hours: Int?, minutes: Int?) {
        
        self.schedule = schedule
        self.period = period
        self.day = day
        self.hours = hours
        self.minutes = minutes
        
        super.init()
    }
    
    open class func manualBotSchedule() -> BotSchedule {
        return BotSchedule(schedule: .manual, period: nil, day: nil, hours: nil, minutes: nil)
    }
    
    open class func commitBotSchedule() -> BotSchedule {
        return BotSchedule(schedule: .commit, period: nil, day: nil, hours: nil, minutes: nil)
    }
    
    open override func dictionarify() -> [String: Any] {
        
        var dictionary: [String: Any] = [:]
        
        dictionary["scheduleType"] = self.schedule.rawValue
        dictionary["periodicScheduleInterval"] = self.period?.rawValue ?? 0
        dictionary["weeklyScheduleDay"] = self.day?.rawValue ?? 0
        dictionary["hourOfIntegration"] = self.hours ?? 0
        dictionary["minutesAfterHourToIntegrate"] = self.minutes ?? 0
        
        return dictionary
    }
    
}
