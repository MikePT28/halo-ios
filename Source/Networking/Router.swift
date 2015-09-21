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
    static var baseURL = NSURL(string: "https://halo-qa.mobgen.com")

    /// Token to be used for authentication purposes
    static var token:Token?

    case OAuth([String: AnyObject])
    case Modules
    case GeneralContentInstances([String: AnyObject])
    case SegmentationCreateUser([String: AnyObject])
    case SegmentationUpdateUser([String: AnyObject])

    /// Decide the HTTP method based on the specific request
    var method: Alamofire.Method {
        switch self {
        case .OAuth(_),
             .SegmentationCreateUser(_):
            return .POST
        case .SegmentationUpdateUser(_):
            return .PUT
        default:
            return .GET
        }
    }

    /// Decide the URL based on the specific request
    var path: String {
        switch self {
        case .OAuth(_):
            return "/api/oauth/token?_1"
        case .Modules:
            return "/api/authentication/module/"
        case .GeneralContentInstances(_):
            return "api/generalcontent/instance/"
        case .SegmentationCreateUser(_),
             .SegmentationUpdateUser(_):
            return "api/segmentation/appuser/"
        }
    }

    // MARK: URLRequestConvertible

    /// Get the right URL request with the right headers
    var URLRequest: NSMutableURLRequest {
        let url = NSURL(string: path, relativeToURL: Router.baseURL)
        let mutableURLRequest = NSMutableURLRequest(URL: url!)
        mutableURLRequest.HTTPMethod = method.rawValue

        if let token = Router.token {
            mutableURLRequest.setValue("\(token.tokenType!) \(token.token!)", forHTTPHeaderField: "Authorization")
        }

        /**
        *  My god.. really awful. Think of a better way of doing this!
        */
        switch self {
        case .OAuth(let params):
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: params).0
        case .GeneralContentInstances(let params):
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: params).0
        case .SegmentationCreateUser(let params):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: params).0
        case .SegmentationUpdateUser(let params):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: params).0
        default:
            return mutableURLRequest
        }
    }
}
