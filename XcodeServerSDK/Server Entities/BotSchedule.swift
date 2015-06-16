//
//  BotSchedule.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 13.06.2015.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation

public class BotSchedule : XcodeServerEntity {
    
    public enum Schedule : Int {
        
        case Periodical = 1
        case Commit
        case Manual
        
        public func toString() -> String {
            switch self {
            case .Periodical:
                return "Periodical"
            case .Commit:
                return "On Commit"
            case .Manual:
                return "Manual"
            }
        }
    }
    
    public enum Period : Int {
        case Hourly = 1
        case Daily
        case Weekly
    }
    
    public enum Day : Int {
        case Monday = 1
        case Tuesday
        case Wednesday
        case Thursday
        case Friday
        case Saturday
        case Sunday
    }
    
    public let schedule: Schedule!
    
    public let period: Period?
    
    public let day: Day!
    public let hours: Int!
    public let minutes: Int!
    
    public required init(json: NSDictionary) {
        
        let schedule = Schedule(rawValue: json.intForKey("scheduleType"))!
        self.schedule = schedule
        
        if schedule == .Periodical {
            
            let period = Period(rawValue: json.intForKey("periodicScheduleInterval"))!
            self.period = period
            
            let minutes = json.optionalIntForKey("minutesAfterHourToIntegrate")
            let hours = json.optionalIntForKey("hourOfIntegration")
            
            switch period {
            case .Hourly:
                self.minutes = minutes!
                self.hours = nil
                self.day = nil
            case .Daily:
                self.minutes = minutes!
                self.hours = hours!
                self.day = nil
            case .Weekly:
                self.minutes = minutes!
                self.hours = hours!
                self.day = Day(rawValue: json.intForKey("weeklyScheduleDay"))
            }
        } else {
            self.period = nil
            self.minutes = nil
            self.hours = nil
            self.day = nil
        }
        
        super.init(json: json)
    }
    
    private init(schedule: Schedule, period: Period?, day: Day?, hours: Int?, minutes: Int?) {
        
        self.schedule = schedule
        self.period = period
        self.day = day
        self.hours = hours
        self.minutes = minutes
        
        super.init()
    }
    
    public class func manualBotSchedule() -> BotSchedule {
        return BotSchedule(schedule: .Manual, period: nil, day: nil, hours: nil, minutes: nil)
    }
    
    public class func commitBotSchedule() -> BotSchedule {
        return BotSchedule(schedule: .Commit, period: nil, day: nil, hours: nil, minutes: nil)
    }
    
    public override func dictionarify() -> NSDictionary {
        
        let dictionary = NSMutableDictionary()
        
        dictionary["scheduleType"] = self.schedule.rawValue
        dictionary["periodicScheduleInterval"] = self.period?.rawValue ?? 0
        dictionary["weeklyScheduleDay"] = self.day?.rawValue ?? 0
        dictionary["hourOfIntegration"] = self.hours ?? 0
        dictionary["minutesAfterHourToIntegrate"] = self.minutes ?? 0
        
        return dictionary
    }
    
}