//
//  XcodeServer.swift
//  Buildasaur
//
//  Created by Honza Dvorsky on 14/12/2014.
//  Copyright (c) 2014 Honza Dvorsky. All rights reserved.
//

import Foundation
import BuildaUtils

// MARK: XcodeServer Class
open class XcodeServer : CIServer {
    
    open var config: XcodeServerConfig
    let endpoints: XcodeServerEndpoints
    
    open var availabilityState: AvailabilityCheckState = .unchecked
    
    public init(config: XcodeServerConfig, endpoints: XcodeServerEndpoints) {
        
        self.config = config
        self.endpoints = endpoints
        
        super.init()
        
        let sessionConfig = URLSessionConfiguration.default
        let delegate: URLSessionDelegate = self
        let queue = OperationQueue.main
        let session = Foundation.URLSession(configuration: sessionConfig, delegate: delegate, delegateQueue: queue)
        self.http.session = session
    }
}

// MARK: NSURLSession delegate implementation
extension XcodeServer : URLSessionDelegate {
    
    var credential: URLCredential? {
        
        if
            let user = self.config.user,
            let password = self.config.password {
                return URLCredential(user: user, password: password, persistence: URLCredential.Persistence.none)
        }
        return nil
    }
    
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        var disposition: Foundation.URLSession.AuthChallengeDisposition = .performDefaultHandling
        var credential: URLCredential?
        
        if challenge.previousFailureCount > 0 {
            disposition = .cancelAuthenticationChallenge
        } else {
            
            switch challenge.protectionSpace.authenticationMethod {
                
            case NSURLAuthenticationMethodServerTrust:
                credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            default:
                credential = self.credential ?? session.configuration.urlCredentialStorage?.defaultCredential(for: challenge.protectionSpace)
            }
            
            if credential != nil {
                disposition = .useCredential
            }
        }
        
        completionHandler(disposition, credential)
    }
}

// MARK: Header constants
let Headers_APIVersion = "X-XCSAPIVersion"
let VerifiedAPIVersions: Set<Int> = [6, 7, 9, 10] //will change with time, this codebase supports these versions

// MARK: XcodeServer API methods
public extension XcodeServer {
    
    fileprivate func verifyAPIVersion(_ response: HTTPURLResponse) -> NSError? {
        
        guard let headers = response.allHeaderFields as? [String: AnyObject] else {
            return MyError.withInfo("No headers provided in response")
        }
        
        let apiVersionString = (headers[Headers_APIVersion] as? String) ?? "-1"
        let apiVersion = Int(apiVersionString)
        
        if let apiVersion = apiVersion ,
            apiVersion > 0 && !VerifiedAPIVersions.contains(apiVersion) {
            var common = "Version mismatch: response from API version \(apiVersion), but we only verified versions \(VerifiedAPIVersions). "
            
            let maxVersion = VerifiedAPIVersions.sorted().last!
            if apiVersion > maxVersion {
                Log.info("You're using a newer Xcode Server than we've verified (\(apiVersion), last verified is \(maxVersion)). Please visit https://github.com/czechboy0/XcodeServerSDK to check whether there's a new version of the SDK for it. If not, please file an issue in the XcodeServerSDK repository. The requests are still going through, however we haven't verified this API version, so here be dragons.")
            } else {
                common += "You're using an old Xcode Server which we don't support any more. Please look for an older version of the SDK at https://github.com/czechboy0/XcodeServerSDK or consider upgrading your Xcode Server to the current version."
                return MyError.withInfo(common)
            }
        }
        
        //all good
        return nil
    }
    
    /**
    Internal usage generic method for sending HTTP requests.
    
    - parameter method:     HTTP method.
    - parameter endpoint:   API endpoint.
    - parameter params:     URL paramaters.
    - parameter query:      URL query.
    - parameter body:       post method request body.
    - parameter completion: Completion.
    */
    @discardableResult
    internal func sendRequestWithMethod(
        _ method: HTTP.Method,
        endpoint: XcodeServerEndpoints.Endpoint,
        params: [String: String]?,
        query: [String: String]?,
        body: [String: Any]?,
        portOverride: Int? = nil,
        completion: @escaping HTTP.Completion
    ) -> URLSessionTask?
    {
        if let request = self.endpoints.createRequest(method, endpoint: endpoint, params: params, query: query, body: body, portOverride: portOverride) {
            
            return self.http.sendRequest(request as URLRequest, completion: { (response, body, error) -> () in
                
                //TODO: fix hack, make completion always return optionals
                let resp = response as? HTTPURLResponse
                
                guard let r = resp else {
                    let e = error ?? MyError.withInfo("Nil response")
                    completion(nil, body, e)
                    return
                }
                
                if let versionError = self.verifyAPIVersion(r) {
                    completion(response, body, versionError)
                    return
                }
                
                if case (200...299) = r.statusCode {
                    //pass on
                    completion(response, body, error)
                } else {
                    //see if we haven't received a XCS failure in headers
                    if let xcsStatusMessage = r.allHeaderFields["X-XCSResponse-Status-Message"] as? String {
                        let e = MyError.withInfo(xcsStatusMessage)
                        completion(response, body, e)
                    } else {
                        completion(response, body, error)
                    }
                }
            })
            
        } else {
            completion(nil, nil, MyError.withInfo("Couldn't create Request"))
            return nil
        }
    }
    
}

