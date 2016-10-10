//
//  XcodeServer+Bot.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 01.07.2015.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation
import BuildaUtils

// MARK: - XcodeSever API Routes for Bot management
extension XcodeServer {
    
    // MARK: Bot management
    
    /**
    Creates a new Bot from the passed in information. First validates Bot's Blueprint to make sure
    that the credentials are sufficient to access the repository and that the communication between
    the client and XCS will work fine. This might take a couple of seconds, depending on your proximity
    to your XCS.
    
    - parameter botOrder:   Bot object which is wished to be created.
    - parameter response:   Response from the XCS.
    */
    public final func createBot(_ botOrder: Bot, completion: @escaping (_ response: CreateBotResponse) -> ()) {
        
        //first validate Blueprint
        let blueprint = botOrder.configuration.sourceControlBlueprint
        self.verifyGitCredentialsFromBlueprint(blueprint) { (response) -> () in
            
            switch response {
            case .error(let error):
                completion(XcodeServer.CreateBotResponse.error(error: error))
                return
            case .sshFingerprintFailedToVerify(let fingerprint, _):
                blueprint.certificateFingerprint = fingerprint
                completion(XcodeServer.CreateBotResponse.blueprintNeedsFixing(fixedBlueprint: blueprint))
                return
            case .success(_, _): break
            }
            
            //blueprint verified, continue creating our new bot
            
            //next, we need to fetch all the available platforms and pull out the one intended for this bot. (TODO: this could probably be sped up by smart caching)
            self.getPlatforms({ (platforms, error) -> () in
                
                if let error = error {
                    completion(XcodeServer.CreateBotResponse.error(error: error))
                    return
                }
                
                do {
                    //we have platforms, find the one in the bot config and replace it
                    try self.replacePlaceholderPlatformInBot(botOrder, platforms: platforms!)
                } catch {
                    completion(.error(error: error))
                    return
                }
                
                //cool, let's do it.
                self.createBotNoValidation(botOrder, completion: completion)
            })
        }
    }

    /**
    XCS API call for getting all available bots.
    
    - parameter bots:       Optional array of available bots.
    - parameter error:      Optional error.
    */
    public final func getBots(_ completion: @escaping (_ bots: [Bot]?, _ error: Error?) -> ()) {
        
        self.sendRequestWithMethod(.get, endpoint: .bots, params: nil, query: nil, body: nil) { (response, body, error) -> () in
            
            if error != nil {
                completion(nil, error)
                return
            }
            
            if let body = (body as? NSDictionary)?["results"] as? NSArray {
                let (result, error): ([Bot]?, NSError?) = unthrow {
                    return try XcodeServerArray(body)
                }
                completion(result, error)
            } else {
                completion(nil, MyError.withInfo("Wrong data returned: \(body)"))
            }
        }
    }
    
    /**
    XCS API call for getting specific bot.
    
    - parameter botTinyId:  ID of bot about to be received.
    - parameter bot:        Optional Bot object.
    - parameter error:      Optional error.
    */
    public final func getBot(_ botTinyId: String, completion: @escaping (_ bot: Bot?, _ error: Error?) -> ()) {
        
        let params = [
            "bot": botTinyId
        ]
        
        self.sendRequestWithMethod(.get, endpoint: .bots, params: params, query: nil, body: nil) { (response, body, error) -> () in
            
            if error != nil {
                completion(nil, error)
                return
            }
            
            if let body = body as? NSDictionary {
                let (result, error): (Bot?, NSError?) = unthrow {
                    return try Bot(json: body)
                }
                completion(result, error)
            } else {
                completion(nil, MyError.withInfo("Wrong body \(body)"))
            }
        }
    }
    
    /**
    XCS API call for deleting bot on specified revision.
    
    - parameter botId:      Bot's ID.
    - parameter revision:   Revision which should be deleted.
    - parameter success:    Operation result indicator.
    - parameter error:      Optional error.
    */
    public final func deleteBot(_ botId: String, revision: String, completion: @escaping (_ success: Bool, _ error: Error?) -> ()) {
        
        let params = [
            "rev": revision,
            "bot": botId
        ]
        
        self.sendRequestWithMethod(.delete, endpoint: .bots, params: params, query: nil, body: nil) { (response, body, error) -> () in
            
            if error != nil {
                completion(false, error)
                return
            }
            
            if let response = response as? HTTPURLResponse {
                if response.statusCode == 204 {
                    completion(true, nil)
                } else {
                    completion(false, MyError.withInfo("Wrong status code: \(response.statusCode)"))
                }
            } else {
                completion(false, MyError.withInfo("Nil response"))
            }
        }
    }
    
    // MARK: Helpers
    
    /**
    Enum for handling Bot creation response.
    
    - Success:              Bot has been created successfully.
    - BlueprintNeedsFixing: Source Control needs fixing.
    - Error:                Couldn't create Bot.
    */
    public enum CreateBotResponse {
        case success(bot: Bot)
        case blueprintNeedsFixing(fixedBlueprint: SourceControlBlueprint)
        case error(error: Error)
    }
    
    enum PlaceholderError: Error {
        case platformMissing
        case deviceFilterMissing
    }
    
    fileprivate func replacePlaceholderPlatformInBot(_ bot: Bot, platforms: [DevicePlatform]) throws {
        
        if let filter = bot.configuration.deviceSpecification.filters.first {
            let intendedPlatform = filter.platform
            if let platform = platforms.findFirst({ $0.type == intendedPlatform.type }) {
                //replace
                filter.platform = platform
            } else {
                // Couldn't find intended platform in list of platforms
                throw PlaceholderError.platformMissing
            }
        } else {
            // Couldn't find device filter
            throw PlaceholderError.deviceFilterMissing
        }
    }
    
    fileprivate func createBotNoValidation(_ botOrder: Bot, completion: @escaping (_ response: CreateBotResponse) -> ()) {
        
        let body: [String: Any] = botOrder.dictionarify()
        
        self.sendRequestWithMethod(.post, endpoint: .bots, params: nil, query: nil, body: body) { (response, body, error) -> () in
            
            if let error = error {
                completion(XcodeServer.CreateBotResponse.error(error: error))
                return
            }
            
            guard let dictBody = body as? NSDictionary else {
                let e = MyError.withInfo("Wrong body \(body)")
                completion(XcodeServer.CreateBotResponse.error(error: e))
                return
            }
            
            let (result, error): (Bot?, NSError?) = unthrow {
                return try Bot(json: dictBody)
            }
            if let err = error {
                completion(XcodeServer.CreateBotResponse.error(error: err))
            } else {
                completion(XcodeServer.CreateBotResponse.success(bot: result!))
            }
        }
    }

}
