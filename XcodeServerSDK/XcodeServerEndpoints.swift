//
//  XcodeServerEndpoints.swift
//  Buildasaur
//
//  Created by Honza Dvorsky on 14/12/2014.
//  Copyright (c) 2014 Honza Dvorsky. All rights reserved.
//

import Foundation
import BuildaUtils

open class XcodeServerEndpoints {
    
    enum Endpoint {
        case bots
        case cancelIntegration
        case commits
        case devices
        case hostname
        case integrations
        case issues
        case liveUpdates
        case login
        case logout
        case platforms
        case repositories
        case scm_Branches
        case userCanCreateBots
        case versions
        case toolchains
    }
    
    let serverConfig: XcodeServerConfig
    
    /**
    Designated initializer.
    
    - parameter serverConfig: Object of XcodeServerConfig class
    
    - returns: Initialized object of XcodeServer endpoints
    */
    public init(serverConfig: XcodeServerConfig) {
        self.serverConfig = serverConfig
    }
    
    func endpointURL(_ endpoint: Endpoint, params: [String: String]? = nil) -> String {
        
        let base = "/api"
        
        switch endpoint {
            
        case .bots:
            
            let bots = "\(base)/bots"
            if let bot = params?["bot"] {
                let bot = "\(bots)/\(bot)"
                if
                    let rev = params?["rev"],
                    let method = params?["method"] , method == "DELETE"
                {
                    let rev = "\(bot)/\(rev)"
                    return rev
                }
                return bot
            }
            return bots
            
        case .integrations:
            
            if let _ = params?["bot"] {
                //gets a list of integrations for this bot
                let bots = self.endpointURL(.bots, params: params)
                return "\(bots)/integrations"
            }
            
            let integrations = "\(base)/integrations"
            if let integration = params?["integration"] {
                
                let oneIntegration = "\(integrations)/\(integration)"
                return oneIntegration
            }
            return integrations
            
        case .cancelIntegration:
            
            let integration = self.endpointURL(.integrations, params: params)
            let cancel = "\(integration)/cancel"
            return cancel
            
        case .devices:
            
            let devices = "\(base)/devices"
            return devices
            
        case .userCanCreateBots:
            
            let users = "\(base)/auth/isBotCreator"
            return users
            
        case .login:
            
            let login = "\(base)/auth/login"
            return login
            
        case .logout:
            
            let logout = "\(base)/auth/logout"
            return logout
            
        case .platforms:
            
            let platforms = "\(base)/platforms"
            return platforms
            
        case .scm_Branches:
            
            let branches = "\(base)/scm/branches"
            return branches
            
        case .repositories:
            
            let repositories = "\(base)/repositories"
            return repositories
            
        case .commits:
            
            let integration = self.endpointURL(.integrations, params: params)
            let commits = "\(integration)/commits"
            return commits
            
        case .issues:
            
            let integration = self.endpointURL(.integrations, params: params)
            let issues = "\(integration)/issues"
            return issues
            
        case .liveUpdates:
            
            let base = "/xcode/internal/socket.io/1"
            if let pollId = params?["poll_id"] {
                return "\(base)/xhr-polling/\(pollId)"
            }
            return base
            
        case .hostname:
            
            let hostname = "\(base)/hostname"
            return hostname
        
        case .versions:
            let versions = "\(base)/versions"
            return versions
        
        case .toolchains:
            let toolchains = "\(base)/toolchains"
            return toolchains
        }
    }
    
    /**
    Builder method for URlrequests based on input parameters.
    
    - parameter method:      HTTP method used for request (GET, POST etc.)
    - parameter endpoint:    Endpoint object
    - parameter params:      URL params (default is nil)
    - parameter query:       Query parameters (default is nil)
    - parameter body:        Request's body (default is nil)
    - parameter doBasicAuth: Requirement of authorization (default is true)
    
    - returns: NSMutableRequest or nil if wrong URL was provided
    */
    func createRequest(
        _ method: HTTP.Method,
        endpoint: Endpoint,
        params: [String : String]? = nil,
        query: [String : String]? = nil,
        body: [String: Any]? = nil,
        doBasicAuth auth: Bool = true,
        portOverride: Int? = nil
    ) -> NSMutableURLRequest? {
        var allParams = [
            "method": method.rawValue
        ]
        
        //merge the two params
        if let params = params {
            for (key, value) in params {
                allParams[key] = value
            }
        }
        
        let port = portOverride ?? self.serverConfig.port
        let endpointURL = self.endpointURL(endpoint, params: allParams)
        let queryString = HTTP.stringForQuery(query)
        let wholePath = "\(self.serverConfig.host):\(port)\(endpointURL)\(queryString)"
        
        guard let url = URL(string: wholePath) else {
            return nil
        }
        
        let request = NSMutableURLRequest(url: url)
        
        request.httpMethod = method.rawValue
        
        if auth {
            //add authorization header
            let user = self.serverConfig.user ?? ""
            let password = self.serverConfig.password ?? ""
            let plainString = "\(user):\(password)" as NSString
            let plainData = plainString.data(using: String.Encoding.utf8.rawValue)
            let base64String = plainData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            request.setValue("Basic \(base64String!)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            do {
                let data = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
                request.httpBody = data
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                let error = error as NSError
                Log.error("Parsing error \(error.description)")
                return nil
            }
        }
        
        return request
    }
    
}
