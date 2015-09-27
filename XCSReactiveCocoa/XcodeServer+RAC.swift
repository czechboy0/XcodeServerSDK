//
//  XcodeServer+RAC.swift
//  XcodeServerSDK
//
//  Created by Honza Dvorsky on 11/09/2015.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation
import ReactiveCocoa

extension XcodeServer {
    
    //MARK: Auth
    
    public func login() -> SignalProducer<Bool, NSError> {
        return self.producerForCall { self.login($0) }
    }
    
    public func logout() -> SignalProducer<Bool, NSError> {
        return self.producerForCall { self.logout($0) }
    }
    
    public func getUserCanCreateBots() -> SignalProducer<Bool, NSError> {
        return self.producerForCall { self.getUserCanCreateBots($0) }
    }
    
    public func verifyXCSUserCanCreateBots() -> SignalProducer<Bool, NSError> {
        return self.producerForCall { self.verifyXCSUserCanCreateBots($0) }
    }
    
    //MARK: Bot
    
    public func createBot(botOrder: Bot) -> SignalProducer<CreateBotResponse, NoError> {
        return self.producerForCall { self.createBot(botOrder, completion: $0) }
    }
    
    public func getBots() -> SignalProducer<[Bot], NSError> {
        return self.producerForCall { self.getBots($0) }
    }
    
    public func getBot(botTinyId: String) -> SignalProducer<Bot, NSError> {
        return self.producerForCall { self.getBot(botTinyId, completion: $0) }
    }
    
    public func deleteBot(botId: String, revision: String) -> SignalProducer<Bool, NSError> {
        return self.producerForCall { self.deleteBot(botId, revision: revision, completion: $0) }
    }
    
    //MARK: Device
    
    public func getDevices() -> SignalProducer<[Device], NSError> {
        return self.producerForCall { self.getDevices($0) }
    }
    
    //MARK: Integration
    
    public func getBotIntegrations(botId: String, query: [String: String]) -> SignalProducer<[Integration], NSError> {
        return self.producerForCall { self.getBotIntegrations(botId, query: query, completion: $0) }
    }
    
    public func postIntegration(botId: String) -> SignalProducer<Integration, NSError> {
        return self.producerForCall { self.postIntegration(botId, completion: $0) }
    }
    
    public func getIntegrations() -> SignalProducer<[Integration], NSError> {
        return self.producerForCall { self.getIntegrations($0) }
    }
    
    public func getIntegration(integrationId: String) -> SignalProducer<Integration, NSError> {
        return self.producerForCall { self.getIntegration(integrationId, completion: $0) }
    }
    
    public func cancelIntegration(integrationId: String) -> SignalProducer<Bool, NSError> {
        return self.producerForCall { self.cancelIntegration(integrationId, completion: $0) }
    }
    
    public func getIntegrationCommits(integrationId: String) -> SignalProducer<IntegrationCommits, NSError> {
        return self.producerForCall { self.getIntegrationCommits(integrationId, completion: $0) }
    }

    //THE compiler seems to be breaking on this one - figure out why
//    public func getIntegrationIssues(integrationId: String) -> SignalProducer<IntegrationIssues, NSError> {
//        return self.producerForCall { self.getIntegrationIssues(integrationId, completion: $0) }
//    }

    //MARK: Platform
    
    public func getPlatforms() -> SignalProducer<[DevicePlatform], NSError> {
        return self.producerForCall { self.getPlatforms($0) }
    }
    
    //MARK: Repository
    
    public func getRepositories() -> SignalProducer<[Repository], NSError> {
        return self.producerForCall { self.getRepositories($0) }
    }
    
    public func createRepository(repository: Repository) -> SignalProducer<CreateRepositoryResponse, NoError> {
        return self.producerForCall { self.createRepository(repository, completion: $0) }
    }
    
    //MARK: SCM
    
    public func verifyGitCredentialsFromBlueprint(blueprint: SourceControlBlueprint) -> SignalProducer<SCMBranchesResponse, NoError> {
        return self.producerForCall { self.verifyGitCredentialsFromBlueprint(blueprint, completion: $0) }
    }
}

//Helpers
extension XcodeServer {
    
    //automatically convert a completion block parameters into a signal
    private func complete<T, E>(sink: Event<T, E> -> (), next: T?, error: E?) {
        if let error = error {
            sendError(sink, error)
        } else {
            precondition(next != nil)
            sendNext(sink, next!)
            sendCompleted(sink)
        }
    }
    
    //non-optional completion data T
    private func producerForCall<T, E>(call: ((T, E?) -> ()) -> ()) -> SignalProducer<T, E> {
        return SignalProducer { (sink, _) -> () in
            call { (t, e) -> () in
                self.complete(sink, next: t, error: e)
            }
        }
    }
    
    //non-optional completion data T, no error passed separately
    private func producerForCall<T>(call: (T -> ()) -> ()) -> SignalProducer<T, NoError> {
        return SignalProducer { (sink, _) -> () in
            call { (t) -> () in
                self.complete(sink, next: t, error: nil)
            }
        }
    }
    
    //optional completion data T?
    private func producerForCall<T, E>(call: ((T?, E?) -> ()) -> ()) -> SignalProducer<T, E> {
        return SignalProducer { (sink, _) -> () in
            call { (t, e) -> () in
                self.complete(sink, next: t, error: e)
            }
        }
    }
}
