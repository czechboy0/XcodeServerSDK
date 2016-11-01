//
//  LiveUpdatesTests.swift
//  XcodeServerSDK
//
//  Created by Honza Dvorsky on 27/09/2015.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import XCTest
import Foundation
@testable import XcodeServerSDK
import Nimble

class LiveUpdatesTests: XCTestCase {
    
    func testParsing_ConnectPacket() {
        
        let message = "1::"
        let packets: [SocketIOPacket] = SocketIOHelper.parsePackets(message)
        expect(packets.count) == 1
        let packet = packets.first!
        expect(packet.type) == SocketIOPacket.PacketType.connect
        expect(packet.jsonPayload).to(beNil())
        expect(packet.stringPayload) == ""
    }
    
    func testParsing_ErrorPacket() {
        let message = "7:::1+0"
        let packets: [SocketIOPacket] = SocketIOHelper.parsePackets(message)
        expect(packets.count) == 1
        let packet = packets.first!
        expect(packet.type) == SocketIOPacket.PacketType.error
        let (reason, advice) = packet.parseError()
        expect(reason) == SocketIOPacket.ErrorReason.clientNotHandshaken
        expect(advice) == SocketIOPacket.ErrorAdvice.reconnect
    }
    
    func testParsing_SingleEventMessage() throws {
        
        let message = "5:::{\"name\":\"advisoryIntegrationStatus\",\"args\":[{\"message\":\"BuildaKit : Linking\",\"_id\":\"07a63fae4ff2d5a37eee830be556d143\",\"percentage\":0.7578125,\"botId\":\"07a63fae4ff2d5a37eee830be50c502a\"},null]}"
        let packets: [SocketIOPacket] = SocketIOHelper.parsePackets(message)
        expect(packets.count) == 1
        let packet = packets.first!
        expect(packet.jsonPayload).toNot(beNil())
        let msg = try LiveUpdateMessage(json: packet.jsonPayload!)
        expect(msg.type) == LiveUpdateMessage.MessageType.advisoryIntegrationStatus
        expect(msg.message) == "BuildaKit : Linking"
        expect(msg.integrationId) == "07a63fae4ff2d5a37eee830be556d143"
        expect(msg.progress) == 0.7578125
        expect(msg.botId) == "07a63fae4ff2d5a37eee830be50c502a"
    }
    
    func testParsing_MultipleEventMessages() throws {
        let message = "�205�5:::{\"name\":\"advisoryIntegrationStatus\",\"args\":[{\"message\":\"Buildasaur : Linking\",\"_id\":\"07a63fae4ff2d5a37eee830be556d143\",\"percentage\":0.8392857360839844,\"botId\":\"07a63fae4ff2d5a37eee830be50c502a\"},null]}�218�5:::{\"name\":\"advisoryIntegrationStatus\",\"args\":[{\"message\":\"Buildasaur : Copying 1 of 3 files\",\"_id\":\"07a63fae4ff2d5a37eee830be556d143\",\"percentage\":0.8571428680419921,\"botId\":\"07a63fae4ff2d5a37eee830be50c502a\"},null]}�218�5:::{\"name\":\"advisoryIntegrationStatus\",\"args\":[{\"message\":\"Buildasaur : Copying 2 of 3 files\",\"_id\":\"07a63fae4ff2d5a37eee830be556d143\",\"percentage\":0.8607142639160156,\"botId\":\"07a63fae4ff2d5a37eee830be50c502a\"},null]}�228�5:::{\"name\":\"advisoryIntegrationStatus\",\"args\":[{\"message\":\"BuildaUtils : Compiling Swift source files\",\"_id\":\"07a63fae4ff2d5a37eee830be556d143\",\"percentage\":0.05511363506317139,\"botId\":\"07a63fae4ff2d5a37eee830be50c502a\"},null]}"
        let packets: [SocketIOPacket] = SocketIOHelper.parsePackets(message)
        expect(packets.count) == 4
        for packet in packets {
            expect(packet.jsonPayload).toNot(beNil())
            let msg = try LiveUpdateMessage(json: packet.jsonPayload!)
            expect(msg.type) == LiveUpdateMessage.MessageType.advisoryIntegrationStatus
        }
    }
}
