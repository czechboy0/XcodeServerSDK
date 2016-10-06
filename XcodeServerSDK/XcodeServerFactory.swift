//
//  XcodeServerFactory.swift
//  Buildasaur
//
//  Created by Honza Dvorsky on 14/12/2014.
//  Copyright (c) 2014 Honza Dvorsky. All rights reserved.
//

import Foundation

open class XcodeServerFactory {
    
    open class func server(_ config: XcodeServerConfig) -> XcodeServer {
        
        let endpoints = XcodeServerEndpoints(serverConfig: config)
        let server = XcodeServer(config: config, endpoints: endpoints)
        
        return server
    }
}
