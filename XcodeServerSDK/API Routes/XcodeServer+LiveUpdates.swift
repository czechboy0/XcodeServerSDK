//
//  XcodeServer+LiveUpdates.swift
//  XcodeServerSDK
//
//  Created by Honza Dvorsky on 25/09/2015.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation
import BuildaUtils

// MARK: - XcodeSever API Routes for Live Updates
extension XcodeServer {
    
    public typealias MessageHandler = (_ messages: [LiveUpdateMessage]) -> ()
    public typealias StopHandler = () -> ()
    public typealias ErrorHandler = (_ error: Error) -> ()
    
    fileprivate class LiveUpdateState {
        var task: URLSessionTask?
        var messageHandler: MessageHandler?
        var errorHandler: ErrorHandler?
        var pollId: String?
        var terminated: Bool = false
        
        func cancel() {
            self.task?.cancel()
            self.task = nil
            self.terminated = true
        }
        
        func error(_ error: Error) {
            self.cancel()
            self.errorHandler?(error)
        }
        
        deinit {
            self.cancel()
        }
    }
    
    /**
    *   Returns StopHandler - call it when you want to stop receiving updates.
    */
    public func startListeningForLiveUpdates(_ message: @escaping MessageHandler, error: ErrorHandler? = nil) -> StopHandler {
        
        let state = LiveUpdateState()
        state.errorHandler = error
        state.messageHandler = message
        self.startPolling(state)
        return {
            state.cancel()
        }
    }
    
    fileprivate func queryWithTimestamp() -> [String: String] {
        let timestamp = Int(Date().timeIntervalSince1970)*1000
        return [
            "t": "\(timestamp)"
        ]
    }
    
    fileprivate func sendRequest(_ state: LiveUpdateState, params: [String: String]?, completion: @escaping (_ message: String) -> ()) {
        
        let query = queryWithTimestamp()
        let task = self.sendRequestWithMethod(.GET, endpoint: .liveUpdates, params: params, query: query, body: nil, portOverride: 443) {
            (response, body, error) -> () in
            
            if let error = error {
                state.error(error)
                return
            }
            
            guard let message = body as? String else {
                let e = MyError.withInfo("Wrong body: \(body)")
                state.error(e)
                return
            }
            
            completion(message)
        }
        state.task = task
    }
    
    fileprivate func startPolling(_ state: LiveUpdateState) {
        
        self.sendRequest(state, params: nil) { [weak self] (message) -> () in
            self?.processInitialResponse(message, state: state)
        }
    }
    
    fileprivate func processInitialResponse(_ initial: String, state: LiveUpdateState) {
        if let pollId = initial.components(separatedBy: ":").first {
            state.pollId = pollId
            self.poll(state)
        } else {
            state.error(MyError.withInfo("Unexpected initial poll message: \(initial)"))
        }
    }
    
    fileprivate func poll(_ state: LiveUpdateState) {
        precondition(state.pollId != nil)
        let params = [
            "poll_id": state.pollId!
        ]
        
        self.sendRequest(state, params: params) { [weak self] (message) -> () in
            
            let packets = SocketIOHelper.parsePackets(message)
            
            do {
                try self?.handlePackets(packets, state: state)
            } catch {
                state.error(error)
            }
        }
    }
    
    fileprivate func handlePackets(_ packets: [SocketIOPacket], state: LiveUpdateState) throws {
        
        //check for errors
        if let lastPacket = packets.last , lastPacket.type == .error {
            let (_, advice) = lastPacket.parseError()
            if
                let advice = advice,
                case .reconnect = advice {
                    //reconnect!
                    self.startPolling(state)
                    return
            }
            print("Unrecognized socket.io error: \(lastPacket.stringPayload)")
        }
        
        //we good?
        let events = packets.filter { $0.type == .event }
        let validEvents = events.filter { $0.jsonPayload != nil }
        let messages = try validEvents.map { try LiveUpdateMessage(json: $0.jsonPayload!) }
        if messages.count > 0 {
            state.messageHandler?(messages)
        }
        if !state.terminated {
            self.poll(state)
        }
    }
}

