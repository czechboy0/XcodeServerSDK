//
//  XcodeServer+Integration.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 01.07.2015.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation
import BuildaUtils

// MARK: - XcodeSever API Routes for Integrations management
extension XcodeServer {
    
    // MARK: Bot releated integrations
    
    /**
    XCS API call for getting a list of filtered integrations for bot.
    Available queries:
    - **last**   - find last integration for bot
    - **from**   - find integration based on date range
    - **number** - find integration for bot by its number
    
    - parameter botId:          ID of bot.
    - parameter query:          Query which should be used to filter integrations.
    - parameter integrations:   Optional array of integrations returned from XCS.
    - parameter error:          Optional error.
    */
    public final func getBotIntegrations(botId: String, query: [String: String], completion: (integrations: [Integration]?, error: NSError?) -> ()) {
        
        let params = [
            "bot": botId
        ]
        
        self.sendRequestWithMethod(.GET, endpoint: .Integrations, params: params, query: query, body: nil) { (response, body, error) -> () in
            
            if error != nil {
                completion(integrations: nil, error: error)
                return
            }
            
            if let body = (body as? NSDictionary)?["results"] as? NSArray {
                let integrations: [Integration] = XcodeServerArray(body)
                completion(integrations: integrations, error: nil)
            } else {
                completion(integrations: nil, error: Error.withInfo("Wrong body \(body)"))
            }
        }
    }
    
    /**
    XCS API call for firing integration for specified bot.
    
    - parameter botId:          ID of the bot.
    - parameter integration:    Optional object of integration returned if run was successful.
    - parameter error:          Optional error.
    */
    public final func postIntegration(botId: String, completion: (integration: Integration?, error: NSError?) -> ()) {
        
        let params = [
            "bot": botId
        ]
        
        self.sendRequestWithMethod(.POST, endpoint: .Integrations, params: params, query: nil, body: nil) { (response, body, error) -> () in
            
            if error != nil {
                completion(integration: nil, error: error)
                return
            }
            
            if let body = body as? NSDictionary {
                let integration = Integration(json: body)
                completion(integration: integration, error: nil)
            } else {
                completion(integration: nil, error: Error.withInfo("Wrong body \(body)"))
            }
        }
    }
    
    // MARK: General integrations methods
    
    /**
    XCS API call for retrievieng all available integrations on server.
    
    - parameter integrations:   Optional array of integrations.
    - parameter error:          Optional error.
    */
    public final func getIntegrations(completion: (integrations: [Integration]?, error: NSError?) -> ()) {
        
        self.sendRequestWithMethod(.GET, endpoint: .Integrations, params: nil, query: nil, body: nil) {
            (response, body, error) -> () in
            
            guard error == nil else {
                completion(integrations: nil, error: error)
                return
            }
            
            guard let integrationsBody = (body as? NSDictionary)?["results"] as? NSArray else {
                completion(integrations: nil, error: Error.withInfo("Wrong body \(body)"))
                return
            }
            
            let integrations: [Integration] = XcodeServerArray(integrationsBody)
            completion(integrations: integrations, error: nil)
        }
    }
    
    /**
    XCS API call for retrievieng specified Integration.
    
    - parameter integrationId: ID of integration which is about to be retrieved.
    - parameter completion:
    - Optional retrieved integration.
    - Optional operation error.
    */
    public final func getIntegration(integrationId: String, completion: (integration: Integration?, error: NSError?) -> ()) {
        
        let params = [
            "integration": integrationId
        ]
        
        self.sendRequestWithMethod(.GET, endpoint: .Integrations, params: params, query: nil, body: nil) {
            (response, body, error) -> () in
            
            guard error == nil else {
                completion(integration: nil, error: error)
                return
            }
            
            guard let integrationBody = body as? NSDictionary else {
                completion(integration: nil, error: Error.withInfo("Wrong body \(body)"))
                return
            }
            
            let integration = Integration(json: integrationBody)
            completion(integration: integration, error: nil)
        }
    }
    
    /**
    XCS API call for canceling specified integration.
    
    - parameter integrationId: ID of integration.
    - parameter success:       Integration cancelling success indicator.
    - parameter error:         Optional operation error.
    */
    public final func cancelIntegration(integrationId: String, completion: (success: Bool, error: NSError?) -> ()) {
        
        let params = [
            "integration": integrationId
        ]
        
        self.sendRequestWithMethod(.POST, endpoint: .CancelIntegration, params: params, query: nil, body: nil) { (response, body, error) -> () in
            
            if error != nil {
                completion(success: false, error: error)
                return
            }
            
            completion(success: true, error: nil)
        }
    }
    
    /**
    XCS API call for fetching all commits for specific integration.
    
    - parameter integrationId: ID of integration.
    - parameter success:       Optional Integration Commits object with result.
    - parameter error:         Optional operation error.
    */
    public final func getIntegrationCommits(integrationId: String, completion: (integrationCommits: IntegrationCommits?, error: NSError?) ->()) {
        
        let params = [
            "integration": integrationId
        ]
        
        self.sendRequestWithMethod(.GET, endpoint: .Commits, params: params, query: nil, body: nil) { (response, body, error) -> () in
            
            guard error == nil else {
                completion(integrationCommits: nil, error: error)
                return
            }
            
            guard let integrationCommitsBody = (body as? NSDictionary)?["results"] as? NSArray else {
                completion(integrationCommits: nil, error: Error.withInfo("Wrong body \(body)"))
                return
            }
            
            let integrationCommits = IntegrationCommits(json: integrationCommitsBody[0] as! NSDictionary)
            completion(integrationCommits: integrationCommits, error: nil)
            
        }
        
    }
    
    /**
    XCS API call for fetching all commits for specific integration.
    
    - parameter integrationId: ID of integration.
    - parameter success:       Optional Integration Issues object with result.
    - parameter error:         Optional operation error.
    */
    public final func getIntegrationIssues(integrationId: String, completion: (integrationIssues: IntegrationIssues?, error: ErrorType?) -> ()) {
        
        let params = [
            "integration": integrationId
        ]
        
        self.sendRequestWithMethod(.GET, endpoint: .Issues, params: params, query: nil, body: nil) { (response, body, error) -> () in
            
            guard error == nil else {
                completion(integrationIssues: nil, error: error)
                return
            }
            
            guard let integrationIssuesBody = body as? NSDictionary else {
                completion(integrationIssues: nil, error: Error.withInfo("Wrong body \(body)"))
                return
            }
            
            let integrationIssues = IntegrationIssues(json: integrationIssuesBody)
            completion(integrationIssues: integrationIssues, error: nil)
            
        }
        
    }
    
    // TODO: Methods about to be implemented...
    
    // public func reportQueueSizeAndEstimatedWaitingTime(integration: Integration, completion: ((queueSize: Int, estWait: Double), NSError?) -> ()) {
    
    //TODO: we need to call getIntegrations() -> filter pending and running Integrations -> get unique bots of these integrations -> query for the average integration time of each bot -> estimate, based on the pending/running integrations, how long it will take for the passed in integration to finish
    
}