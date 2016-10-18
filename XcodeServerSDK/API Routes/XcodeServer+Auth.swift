//
//  XcodeServer+Auth.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 30.06.2015.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation
import BuildaUtils

// MARK: - XcodeSever API Routes for Authorization
extension XcodeServer {
    
    // MARK: Sign in/Sign out
    
    /**
    XCS API call for user sign in.
    
    - parameter success:    Indicates whether sign in was successful.
    - parameter error:      Error indicating failure of sign in.
    */
    public final func login(_ completion: @escaping Completion) {
        
        self.sendRequestWithMethod(.post, endpoint: .login, params: nil, query: nil, body: nil) {
            (response, body, error) -> () in
            
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
                return
            }
            completion(false, MyError.withInfo("Nil response"))
        }
    }
    
    /**
    XCS API call for user sign out.
    
    - parameter success:    Indicates whether sign out was successful.
    - parameter error:      Error indicating failure of sign out.
    */
    public typealias Completion = (Bool, Error?) -> Void
    public final func logout(_ completion: @escaping Completion) {
        
        self.sendRequestWithMethod(.post, endpoint: .logout, params: nil, query: nil, body: nil) {
            (response, body, error) -> () in
            
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
                return
            }
            completion(false, MyError.withInfo("Nil response"))
        }
    }
    
    // MARK: User access verification
    
    /**
    XCS API call to verify if logged in user can create bots.
    
    - parameter canCreateBots:  Indicator of bot creation accessibility.
    - parameter error:          Optional error.
    */
    public final func getUserCanCreateBots(_ completion: @escaping (_ canCreateBots: Bool, _ error: Error?) -> ()) {
        
        self.sendRequestWithMethod(.get, endpoint: .userCanCreateBots, params: nil, query: nil, body: nil) { (response, body, error) -> () in
            
            if let error = error {
                completion(false, error)
                return
            }
            
            if let body = body as? NSDictionary {
                if let canCreateBots = body["result"] as? Bool , canCreateBots == true {
                    completion(true, nil)
                } else {
                    completion(false, MyError.withInfo("Specified user cannot create bots"))
                }
            } else {
                completion(false, MyError.withInfo("Wrong body \(body)"))
            }
        }
    }
    
    /**
    Checks whether the current user has the rights to create bots and perform other similar "write" actions.
    Xcode Server offers two tiers of users, ones for reading only ("viewers") and others for management.
    Here we check the current user can manage XCS, which is useful for projects like Buildasaur.
    
    - parameter success:    Indicates if user can create bots.
    - parameter error:      Error if something went wrong.
    */
    public final func verifyXCSUserCanCreateBots(_ completion: @escaping (_ success: Bool, _ error: Error?) -> ()) {
        
        //the way we check availability is first by logging out (does nothing if not logged in) and then
        //calling getUserCanCreateBots, which, if necessary, automatically authenticates with Basic auth before resolving to true or false in JSON.
        
        self.logout { (success, error) -> () in
            
            if let error = error {
                completion(false, error)
                return
            }
            
            self.getUserCanCreateBots { (canCreateBots, error) -> () in
                
                if let error = error {
                    completion(false, error)
                    return
                }
                
                completion(canCreateBots, nil)
            }
        }
    }
    
}
