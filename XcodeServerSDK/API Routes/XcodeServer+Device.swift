//
//  XcodeServer+Device.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 01/07/15.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation
import BuildaUtils

// MARK: - XcodeSever API Routes for Devices management
extension XcodeServer {
    
    /**
    XCS API call for retrieving all registered devices on OS X Server.
    
    - parameter devices: Optional array of available devices.
    - parameter error:   Optional error indicating that something went wrong.
    */
    public final func getDevices(_ completion: @escaping (_ devices: [Device]?, _ error: Error?) -> ()) {
        
        self.sendRequestWithMethod(.GET, endpoint: .devices, params: nil, query: nil, body: nil) { (response, body, error) -> () in
            
            if error != nil {
                completion(nil, error)
                return
            }
            
            if let array = (body as? NSDictionary)?["results"] as? NSArray {
                let (result, error): ([Device]?, NSError?) = unthrow {
                    return try XcodeServerArray(array)
                }
                completion(result, error)
            } else {
                completion(nil, MyError.withInfo("Wrong body \(body)"))
            }
        }
    }
    
}
