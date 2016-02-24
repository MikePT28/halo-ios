//
//  Router.swift
//  HaloSDK
//
//  Created by Borja Santos-Díez on 30/07/15.
//  Copyright © 2015 MOBGEN Technology. All rights reserved.
//

import Foundation
import Alamofire

/// Custom implementation of the URLRequestConvertible protocol to handle authentication nicely
enum Router: URLRequestConvertible {

    /// Common base url of all the API endpoints
    static var baseURL = NSURL(string: "https://halo.mobgen.com")

    /// Token to be used for authentication purposes
    static var token:Token?
    
    static var userAlias: String?

    case OAuth(Credentials, [String: AnyObject])
    case Modules
    case GeneralContentInstances([String: AnyObject])
    case GeneralContentInstance(String, [String: AnyObject])
    case SegmentationGetUser(String)
    case SegmentationCreateUser([String: AnyObject])
    case SegmentationUpdateUser(String, [String: AnyObject])
    case CustomRequest(Halo.Method, String, [String: AnyObject]?)

    /// Decide the HTTP method based on the specific request
    var method: Halo.Method {
        switch self {
        case .OAuth(_, _),
             .SegmentationCreateUser(_):
            return .POST
        case .SegmentationUpdateUser(_):
            return .PUT
        case .CustomRequest(let method, _, _):
            return method
        default:
            return .GET
        }
    }

    /// Decide the URL based on the specific request
    var path: String {
        switch self {
        case .OAuth(let cred, _):
            switch cred.type {
            case .App:
                return "/api/oauth/token?_1"
            case .User:
                return "/api/oauth/token?_2"
            }
        case .Modules:
            return "/api/authentication/module/"
        case .GeneralContentInstances(_):
            return "api/authentication/instance/"
        case .GeneralContentInstance(let id, _):
            return "api/generalcontent/instance/\(id)"
        case .SegmentationCreateUser(_):
            return "api/segmentation/appuser/"
        case .SegmentationGetUser(let id):
            return "api/segmentation/appuser/\(id)"
        case .SegmentationUpdateUser(let id, _):
            return "api/segmentation/appuser/\(id)?replaceTokens=true"
        case .CustomRequest(_, let url, _):
            return "api/\(url)"
        }
    }

    // MARK: URLRequestConvertible

    /// Get the right URL request with the right headers
    var URLRequest: NSMutableURLRequest {
        let url = NSURL(string: path, relativeToURL: Router.baseURL)
        let mutableURLRequest = NSMutableURLRequest(URL: url!)
        mutableURLRequest.HTTPMethod = method.toAlamofire().rawValue

        if let token = Router.token {
            mutableURLRequest.setValue("\(token.tokenType!) \(token.token!)", forHTTPHeaderField: "Authorization")
        }

        if let alias = Router.userAlias {
            mutableURLRequest.setValue(alias, forHTTPHeaderField: "X-AppUser-Alias")
        }
        
        /**
        *  My god.. really awful. Think of a better way of doing this!
        */
        switch self {
        case .OAuth(let cred, let params):
            
            if cred.type == .User {
                let string = "\(cred.username):\(cred.password)"
                if let data = string.dataUsingEncoding(NSUTF8StringEncoding) {
                    let base64string = data.base64EncodedStringWithOptions([])
                    mutableURLRequest.setValue("Basic \(base64string)", forHTTPHeaderField: "Authorization")
                    NSLog("Using Authorization header: Basic \(base64string)")
                }
            }
            
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: params).0
        case .GeneralContentInstance(_, let params):
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: params).0
        case .GeneralContentInstances(let params):
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: params).0
        case .SegmentationCreateUser(let params):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: params).0
        case .SegmentationUpdateUser(_, let params):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: params).0
        case .CustomRequest(let method, _, let params):
            switch method {
            case .POST, .PUT:
                return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: params).0
            default:
                return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: params).0
            }
        default:
            return mutableURLRequest
        }
    }
}
