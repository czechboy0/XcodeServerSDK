//
//  XcodeServer+Platform.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 01/07/15.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation
import BuildaUtils

// MARK: - XcodeSever API Routes for Platform management
extension XcodeServer {
    
    /**
    XCS API method for getting available testing platforms on OS X Server.
    
    - parameter platforms:  Optional array of platforms.
    - parameter error:      Optional error indicating some problems.
    */
    public final func getPlatforms(_ completion: @escaping (_ platforms: [DevicePlatform]?, _ error: Error?) -> ()) {
        
        self.sendRequestWithMethod(.GET, endpoint: .platforms, params: nil, query: nil, body: nil) { (response, body, error) -> () in
            
            if error != nil {
                completion(nil, error)
                return
            }
            
            if let array = (body as? NSDictionary)?["results"] as? NSArray {
                let (result, error): ([DevicePlatform]?, NSError?) = unthrow {
                    return try XcodeServerArray(array)
                }
                completion(result, error)
            } else {
                completion(nil, MyError.withInfo("Wrong body \(body)"))
            }
        }
    }
    
}
