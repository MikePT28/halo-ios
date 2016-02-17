//
//  NetworkManager+User.swift
//  HaloSDK
//
//  Created by Borja Santos-Díez on 26/08/15.
//  Copyright © 2015 MOBGEN Technology. All rights reserved.
//

import Foundation
import Alamofire

extension NetworkManager {

    func getUser(user: Halo.User, completionHandler handler: ((Halo.Result<Halo.User, NSError>) -> Void)? = nil) -> Void {
        
        if let id = user.id {

            let request = Halo.Request(router: Router.SegmentationGetUser(id))
            
            request.response { result in
                switch result {
                case .Success(let data as [String: AnyObject], let cached):
                    handler?(.Success(User.fromDictionary(data), cached))
                case .Failure(let error):
                    handler?(.Failure(error))
                default:
                    handler?(.Failure(NSError(domain: "com.mobgen.halo", code: -1, userInfo: nil)))
                }
            }
            
        } else {
            handler?(.Success(user, false))
        }
        
    }
    
    /**
    Create or update a user in the remote server, containing all the user details (devices, tags, etc)

    - parameter user:    User object containing all the information to be sent
    - parameter handler: Closure to be executed after the request has completed
    */
    func createUpdateUser(user: Halo.User, completionHandler handler: ((Halo.Result<Halo.User, NSError>) -> Void)? = nil) -> Void {

        /// Decide whether to create or update the user based on the presence of an id
        let request: Halo.Request
        
        if let id = user.id {
            request = Halo.Request(router: Router.SegmentationUpdateUser(id, user.toDictionary()))
        } else {
            request = Halo.Request(router: Router.SegmentationCreateUser(user.toDictionary()))
        }

        request.response { result in
            
            switch result {
            case .Success(let data as [String: AnyObject], let cached):
                handler?(.Success(User.fromDictionary(data), cached))
            case .Failure(let error):
                handler?(.Failure(error))
            default:
                handler?(.Failure(NSError(domain: "com.mobgen.halo", code: -1, userInfo: nil)))
            }
        }
    }
}
