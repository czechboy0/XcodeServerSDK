//
//  BotConfigurationTests.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 24.06.2015.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import XCTest
import XcodeServerSDK

class BotConfigurationTests: XCTestCase {

    func testCleaningPolicyToString() {
        var policy: BotConfiguration.CleaningPolicy
        
        policy = .never
        XCTAssertEqual(policy.toString(), "Never")
        
        policy = .always
        XCTAssertEqual(policy.toString(), "Always")
        
        policy = .once_a_Day
        XCTAssertEqual(policy.toString(), "Once a day (first build)")
        
        policy = .once_a_Week
        XCTAssertEqual(policy.toString(), "Once a week (first build)")
    }
    
    func testDeviceFilterToString() {
        
        var filter: DeviceFilter.FilterType
        
        filter = .allAvailableDevicesAndSimulators
        XCTAssertEqual(filter.toString(), "All Available Devices and Simulators")
        
        filter = .allDevices
        XCTAssertEqual(filter.toString(), "All Devices")
        
        filter = .allSimulators
        XCTAssertEqual(filter.toString(), "All Simulators")
        
        filter = .selectedDevicesAndSimulators
        XCTAssertEqual(filter.toString(), "Selected Devices and Simulators")
    }
    
    func testAvailableFiltersForPlatform() {
        
        XCTAssertEqual(DeviceFilter.FilterType.availableFiltersForPlatform(.iOS), [
            .allAvailableDevicesAndSimulators,
            .allDevices,
            .allSimulators,
            .selectedDevicesAndSimulators
            ] as [DeviceFilter.FilterType])
        
        XCTAssertEqual(DeviceFilter.FilterType.availableFiltersForPlatform(.OSX), [
            .allAvailableDevicesAndSimulators
            ] as [DeviceFilter.FilterType])

        XCTAssertEqual(DeviceFilter.FilterType.availableFiltersForPlatform(.watchOS), [
            .allAvailableDevicesAndSimulators
            ] as [DeviceFilter.FilterType])
    }

}
