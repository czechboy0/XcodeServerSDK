//
//  XcodeServerEndpoints.swift
//  Buildasaur
//
//  Created by Honza Dvorsky on 14/12/2014.
//  Copyright (c) 2014 Honza Dvorsky. All rights reserved.
//

import Foundation

public class XcodeServerEndPoints {
    
    enum Endpoint {
        case Bots
        case Integrations
        case CancelIntegration
        case UserCanCreateBots
        case Devices
        case Login
        case Logout
    }
    
    let serverConfig: XcodeServerConfig
    
    public init(serverConfig: XcodeServerConfig) {
        
        self.serverConfig = serverConfig
    }
    
    private func endpointBase() -> String {
        
        switch self.serverConfig.apiVersion {
        case .Xcode6:
            return "/xcode/api"
        case .Xcode7:
            return "/api"
        }
    }
    
    private func endpointURL(endpoint: Endpoint, params: [String: String]? = nil) -> String {
        
        let base = self.endpointBase()
        
        switch endpoint {
            
        case .Bots:
            
            let bots = "\(base)/bots"
            if let bot = params?["bot"] {
                let bot = "\(bots)/\(bot)"
                if let rev = params?["rev"] {
                    let rev = "\(bot)/\(rev)"
                    return rev
                }
                return bot
            }
            return bots
            
        case .Integrations:
            
            if let _ = params?["bot"] {
                //gets a list of integrations for this bot
                let bots = self.endpointURL(.Bots, params: params)
                return "\(bots)/integrations"
            }
            
            let integrations = "\(base)/integrations"
            if let integration = params?["integration"] {
                
                let oneIntegration = "\(integrations)/\(integration)"
                return oneIntegration
            }
            return integrations
            
        case .CancelIntegration:
            
            let integration = self.endpointURL(.Integrations, params: params)
            let cancel = "\(integration)/cancel"
            return cancel
            
        case .Devices:
            
            let devices = "\(base)/devices"
            return devices
            
        case .UserCanCreateBots:
            
            let users = "\(base)/auth/isBotCreator"
            return users
            
        case .Login:
            
            let login = "\(base)/auth/login"
            return login
            
        case .Logout:
            
            let logout = "\(base)/auth/logout"
            return logout
            
        }
    }
    
    func createRequest(method: HTTP.Method, endpoint: Endpoint, params: [String : String]? = nil, query: [String : String]? = nil, body:NSDictionary? = nil, doBasicAuth: Bool = true) -> NSMutableURLRequest? {
        
        let endpointURL = self.endpointURL(endpoint, params: params)
        let queryString = HTTP.stringForQuery(query)
        let wholePath = "\(self.serverConfig.host):\(self.serverConfig.port)\(endpointURL)\(queryString)"
        
        if let url = NSURL(string: wholePath) {
            
            let request = NSMutableURLRequest(URL: url)
            
            request.HTTPMethod = method.rawValue
            
            if doBasicAuth {
                //add authorization header
                let user = self.serverConfig.user ?? ""
                let password = self.serverConfig.password ?? ""
                let plainString = "\(user):\(password)" as NSString
                let plainData = plainString.dataUsingEncoding(NSUTF8StringEncoding)
                let base64String = plainData?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
                request.setValue("Basic \(base64String!)", forHTTPHeaderField: "Authorization")
            }
            
            if let body = body {
                do {
                    let data = try NSJSONSerialization.dataWithJSONObject(body, options: .PrettyPrinted)
                    request.HTTPBody = data
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                } catch {
                    let error = error as NSError
                    Log.error("Parsing error \(error.description)")
                    return nil
                }
            }
            
            return request
        }
        return nil
    }
    
}
