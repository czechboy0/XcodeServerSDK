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
    public final func getBotIntegrations(_ botId: String, query: [String: String], completion: @escaping (_ integrations: [Integration]?, _ error: Error?) -> ()) {
        
        let params = [
            "bot": botId
        ]
        
        self.sendRequestWithMethod(.GET, endpoint: .integrations, params: params, query: query, body: nil) { (response, body, error) -> () in
            
            if error != nil {
                completion(nil, error)
                return
            }
            
            if let body = (body as? NSDictionary)?["results"] as? NSArray {
                let (result, error): ([Integration]?, NSError?) = unthrow {
                    return try XcodeServerArray(body)
                }
                completion(result, error)
            } else {
                completion(nil, MyError.withInfo("Wrong body \(body)"))
            }
        }
    }
    
    /**
    XCS API call for firing integration for specified bot.
    
    - parameter botId:          ID of the bot.
    - parameter integration:    Optional object of integration returned if run was successful.
    - parameter error:          Optional error.
    */
    public final func postIntegration(_ botId: String, completion: @escaping (_ integration: Integration?, _ error: Error?) -> ()) {
        
        let params = [
            "bot": botId
        ]
        
        self.sendRequestWithMethod(.POST, endpoint: .integrations, params: params, query: nil, body: nil) { (response, body, error) -> () in
            
            if error != nil {
                completion(nil, error)
                return
            }
            
            if let body = body as? NSDictionary {
                let (result, error): (Integration?, NSError?) = unthrow {
                    return try Integration(json: body)
                }
                completion(result, error)
            } else {
                completion(nil, MyError.withInfo("Wrong body \(body)"))
            }
        }
    }
    
    // MARK: General integrations methods
    
    /**
    XCS API call for retrievieng all available integrations on server.
    
    - parameter integrations:   Optional array of integrations.
    - parameter error:          Optional error.
    */
    public final func getIntegrations(_ completion: @escaping (_ integrations: [Integration]?, _ error: Error?) -> ()) {
        
        self.sendRequestWithMethod(.GET, endpoint: .integrations, params: nil, query: nil, body: nil) {
            (response, body, error) -> () in
            
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            guard let integrationsBody = (body as? NSDictionary)?["results"] as? NSArray else {
                completion(nil, MyError.withInfo("Wrong body \(body)"))
                return
            }
            
            let (result, error): ([Integration]?, NSError?) = unthrow {
                return try XcodeServerArray(integrationsBody)
            }
            completion(result, error)
        }
    }
    
    /**
    XCS API call for retrievieng specified Integration.
    
    - parameter integrationId: ID of integration which is about to be retrieved.
    - parameter completion:
    - Optional retrieved integration.
    - Optional operation error.
    */
    public final func getIntegration(_ integrationId: String, completion: @escaping (_ integration: Integration?, _ error: Error?) -> ()) {
        
        let params = [
            "integration": integrationId
        ]
        
        self.sendRequestWithMethod(.GET, endpoint: .integrations, params: params, query: nil, body: nil) {
            (response, body, error) -> () in
            
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            guard let integrationBody = body as? NSDictionary else {
                completion(nil, MyError.withInfo("Wrong body \(body)"))
                return
            }
            
            let (result, error): (Integration?, NSError?) = unthrow {
                return try Integration(json: integrationBody)
            }
            completion(result, error)
        }
    }
    
    /**
    XCS API call for canceling specified integration.
    
    - parameter integrationId: ID of integration.
    - parameter success:       Integration cancelling success indicator.
    - parameter error:         Optional operation error.
    */
    public final func cancelIntegration(_ integrationId: String, completion: @escaping (_ success: Bool, _ error: Error?) -> ()) {
        
        let params = [
            "integration": integrationId
        ]
        
        self.sendRequestWithMethod(.POST, endpoint: .cancelIntegration, params: params, query: nil, body: nil) { (response, body, error) -> () in
            
            if error != nil {
                completion(false, error)
                return
            }
            
            completion(true, nil)
        }
    }
    
    /**
    XCS API call for fetching all commits for specific integration.
    
    - parameter integrationId: ID of integration.
    - parameter success:       Optional Integration Commits object with result.
    - parameter error:         Optional operation error.
    */
    public final func getIntegrationCommits(_ integrationId: String, completion: @escaping (_ integrationCommits: IntegrationCommits?, _ error: Error?) ->()) {
        
        let params = [
            "integration": integrationId
        ]
        
        self.sendRequestWithMethod(.GET, endpoint: .commits, params: params, query: nil, body: nil) { (response, body, error) -> () in
            
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            guard let integrationCommitsBody = (body as? NSDictionary)?["results"] as? NSArray else {
                completion(nil, MyError.withInfo("Wrong body \(body)"))
                return
            }
            
            let (result, error): (IntegrationCommits?, NSError?) = unthrow {
                return try IntegrationCommits(json: integrationCommitsBody[0] as! NSDictionary)
            }
            completion(result, error)
        }
        
    }
    
    /**
    XCS API call for fetching all commits for specific integration.
    
    - parameter integrationId: ID of integration.
    - parameter success:       Optional Integration Issues object with result.
    - parameter error:         Optional operation error.
    */
    public final func getIntegrationIssues(_ integrationId: String, completion: @escaping (_ integrationIssues: IntegrationIssues?, _ error: Error?) ->()) {
        
        let params = [
            "integration": integrationId
        ]
        
        self.sendRequestWithMethod(.GET, endpoint: .issues, params: params, query: nil, body: nil) { (response, body, error) -> () in
            
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            guard let integrationIssuesBody = body as? NSDictionary else {
                completion(nil, MyError.withInfo("Wrong body \(body)"))
                return
            }
            
            let (result, error): (IntegrationIssues?, NSError?) = unthrow {
                return try IntegrationIssues(json: integrationIssuesBody)
            }
            completion(result, error)
        }
        
    }
    
    // TODO: Methods about to be implemented...
    
    // public func reportQueueSizeAndEstimatedWaitingTime(integration: Integration, completion: ((queueSize: Int, estWait: Double), NSError?) -> ()) {
    
    //TODO: we need to call getIntegrations() -> filter pending and running Integrations -> get unique bots of these integrations -> query for the average integration time of each bot -> estimate, based on the pending/running integrations, how long it will take for the passed in integration to finish
    
}
