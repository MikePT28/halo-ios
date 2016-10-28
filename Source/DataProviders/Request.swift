//
//  HaloRequest.swift
//  HaloSDK
//
//  Created by Borja on 10/02/16.
//  Copyright © 2016 MOBGEN Technology. All rights reserved.
//

import Foundation

public enum AuthenticationMode: Int {
    case app, user
}

public protocol Requestable {
    var URLRequest: NSMutableURLRequest { get }
    var authenticationMode: Halo.AuthenticationMode { get }
    var offlinePolicy: Halo.OfflinePolicy { get }
    var numberOfRetries: Int? { get }
}

open class Request<T>: Requestable, CustomDebugStringConvertible {

    fileprivate var url: URL?
    fileprivate var include = false
    fileprivate var method: Halo.Method = .GET
    fileprivate var parameterEncoding: Halo.ParameterEncoding = .url
    fileprivate var headers: [String: String] = [:]
    fileprivate var params: [String: AnyObject] = [:]

    open fileprivate(set) var responseParser: ((AnyObject) -> T?)?
    open fileprivate(set) var authenticationMode: Halo.AuthenticationMode = .app
    open fileprivate(set) var offlinePolicy = Manager.core.defaultOfflinePolicy {
        didSet {
            switch offlinePolicy {
            case .none: self.dataProvider = DataProviderManager.online
            case .loadAndStoreLocalData: self.dataProvider = DataProviderManager.onlineOffline
            case .returnLocalDataDontLoad: self.dataProvider = DataProviderManager.offline
            }
        }
    }
    open fileprivate(set) var numberOfRetries: Int?
    
    fileprivate(set) var dataProvider: DataProvider = Manager.core.dataProvider

    open var URLRequest: NSMutableURLRequest {
        let req = NSMutableURLRequest(url: self.url!)

        req.httpMethod = self.method.rawValue

        var token: Token?

        switch self.authenticationMode {
        case .app:
            token = Router.appToken
        case .user:
            token = Router.userToken
        }

        if let tok = token {
            req.setValue("\(tok.tokenType!) \(tok.token!)", forHTTPHeaderField: "Authorization")
        }

        for (key, value) in self.headers {
            req.setValue(value, forHTTPHeaderField: key)
        }

        if self.include {
            self.params["include"] = true as AnyObject?
        }

        let (request, _) = self.parameterEncoding.encode(request: req, parameters: self.params)

        return request

    }

    open var debugDescription: String {
        return self.URLRequest.curlRequest + "\n"
    }

    public init(path: String, relativeToURL: URL? = Router.baseURL) {
        self.url = URL(string: path, relativeTo: relativeToURL)
    }

    public init(router: Router) {
        self.url = URL(string: router.path, relativeTo: Router.baseURL as URL?)
        self.method = router.method
        self.parameterEncoding = router.parameterEncoding
        self.headers = router.headers

        if let params = router.params {
            let _ = params.map({ self.params[$0.0] = $0.1 })
        }
    }

    open func responseParser(parser: @escaping (AnyObject) -> T?) -> Halo.Request<T> {
        self.responseParser = parser
        return self
    }

    open func offlinePolicy(policy: Halo.OfflinePolicy) -> Halo.Request<T> {
        self.offlinePolicy = policy
        return self
    }

    open func numberOfRetries(retries: Int) -> Halo.Request<T> {
        self.numberOfRetries = retries
        return self
    }
    
    open func method(method: Halo.Method) -> Halo.Request<T> {
        self.method = method
        return self
    }

    open func authenticationMode(mode: Halo.AuthenticationMode) -> Halo.Request<T> {
        self.authenticationMode = mode
        return self
    }

    open func parameterEncoding(encoding: Halo.ParameterEncoding) -> Halo.Request<T> {
        self.parameterEncoding = encoding
        return self
    }

    open func addHeader(field: String, value: String) -> Halo.Request<T> {
        self.headers[field] = value
        return self
    }

    open func addHeaders(headers: [String : String]) -> Halo.Request<T> {
        headers.forEach { (key, value) -> Void in
            let _ = self.addHeader(field: key, value: value)
        }
        return self
    }

    open func params(params: [String : AnyObject]) -> Halo.Request<T> {
        params.forEach { self.params[$0] = $1 }
        return self
    }

    open func includeAll() -> Halo.Request<T> {
        self.include = true
        return self
    }

    open func paginate(page: Int, limit: Int) -> Halo.Request<T> {
        self.params["page"] = page as AnyObject?
        self.params["limit"] = limit as AnyObject?
        return self
    }


    open func skipPagination() -> Halo.Request<T> {
        self.params["skip"] = "true" as AnyObject?
        return self
    }

    open func fields(fields: [String]) -> Halo.Request<T> {
        self.params["fields"] = fields as AnyObject?
        return self
    }

    open func tags(tags: [Halo.Tag]) -> Halo.Request<T> {
        tags.forEach { tag in
            let json = try! JSONSerialization.data(withJSONObject: tag.toDictionary(), options: [])
            self.params["filter[tags][]"] = String(data: json, encoding: String.Encoding.utf8) as AnyObject?
        }
        return self
    }

    open func hash() -> Int {

        let bodyHash = (URLRequest.httpBody as NSData?)?.hash ?? 0
        let urlHash = (URLRequest.url as NSURL?)?.hash ?? 0

        return bodyHash + urlHash
    }

    open func responseData(completionHandler handler: ((HTTPURLResponse?, Halo.Result<Data>) -> Void)? = nil) throws -> Halo.Request<T> {

        switch self.offlinePolicy {
        case .none:
            Manager.network.startRequest(request: self) { (resp, result) in
                handler?(resp, result)
            }
        default:
            throw HaloError.notImplementedOfflinePolicy
        }

        return self
    }

    open func response(completionHandler handler: ((HTTPURLResponse?, Halo.Result<AnyObject>) -> Void)? = nil) throws -> Halo.Request<T> {

        try self.responseData { (response, result) -> Void in
            switch result {
            case .success(let data, _):
                if let successHandler = handler {
                    let json = try! JSONSerialization.jsonObject(with: data, options: [])
                    successHandler(response, .success(json, false))
                }
            case .failure(let error):
                handler?(response, .failure(error))
            }
        }

        return self
    }

    open func responseObject(completionHandler handler: ((HTTPURLResponse?, Halo.Result<T?>) -> Void)? = nil) throws -> Halo.Request<T> {

        guard let parser = self.responseParser else {
            throw HaloError.notImplementedResponseParser
        }

        try self.response { (response, result) in
            switch result {
            case .success(let data, _):
                handler?(response, .success(parser(data), false))
            case .failure(let error):
                handler?(response, .failure(error))
            }
        }

        return self
    }

}
