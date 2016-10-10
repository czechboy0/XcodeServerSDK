//
//  XcodeServer+Repository.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 30.06.2015.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation
import BuildaUtils

// MARK: - // MARK: - XcodeSever API Routes for Repositories management
extension XcodeServer {
    
    /**
    XCS API call for getting all repositories stored on Xcode Server.
    
    - parameter repositories: Optional array of repositories.
    - parameter error:        Optional error
    */
    public final func getRepositories(_ completion: @escaping (_ repositories: [Repository]?, _ error: Error?) -> ()) {
        
        self.sendRequestWithMethod(.get, endpoint: .repositories, params: nil, query: nil, body: nil) { (response, body, error) -> () in
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            guard let repositoriesBody = (body as? NSDictionary)?["results"] as? NSArray else {
                completion(nil, MyError.withInfo("Wrong body \(body)"))
                return
            }
            
            let (result, error): ([Repository]?, NSError?) = unthrow {
                return try XcodeServerArray(repositoriesBody)
            }
            completion(result, error)
        }
    }
    
    /**
    Enum with response from creation of repository.
    
    - RepositoryAlreadyExists: Repository with this name already exists on OS X Server.
    - NilResponse:             Self explanatory.
    - CorruptedJSON:           JSON you've used to create repository.
    - WrongStatusCode:         Something wrong with HHTP status.
    - Error:                   There was an error during netwotk activity.
    - Success:                 Repository was successfully created 🎉
    */
    public enum CreateRepositoryResponse {
        case repositoryAlreadyExists
        case nilResponse
        case corruptedJSON
        case wrongStatusCode(Int)
        case error(Error)
        case success(Repository)
    }
    
    /**
    XCS API call for creating new repository on configured Xcode Server.
    
    - parameter repository: Repository object.
    - parameter repository: Optional object of created repository.
    - parameter error:      Optional error.
    */
    public final func createRepository(_ repository: Repository, completion: @escaping (_ response: CreateRepositoryResponse) -> ()) {
        let body = repository.dictionarify()
        
        self.sendRequestWithMethod(.post, endpoint: .repositories, params: nil, query: nil, body: body) { (response, body, error) -> () in
            if let error = error {
                completion(XcodeServer.CreateRepositoryResponse.error(error))
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(XcodeServer.CreateRepositoryResponse.nilResponse)
                return
            }
            
            guard let repositoryBody = body as? NSDictionary, response.statusCode == 204 else {
                switch response.statusCode {
                case 200:
                    completion(XcodeServer.CreateRepositoryResponse.corruptedJSON)
                case 409:
                    completion(XcodeServer.CreateRepositoryResponse.repositoryAlreadyExists)
                default:
                    completion(XcodeServer.CreateRepositoryResponse.wrongStatusCode(response.statusCode))
                }
                
                return
            }
            
            let (result, error): (Repository?, NSError?) = unthrow {
                return try Repository(json: repositoryBody)
            }
            if let error = error {
                completion(.error(error))
            } else {
                completion(.success(result!))
            }
        }
    }
    
}
