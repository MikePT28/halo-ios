//
//  Result.swift
//  HaloSDK
//
//  Created by Borja on 09/02/16.
//  Copyright © 2016 MOBGEN Technology. All rights reserved.
//

import Foundation

public enum Result<Value, Error: ErrorType> {

    case Success(Value, Bool)
    case Failure(Error)

}

public enum Method: String {
    case OPTIONS, GET, HEAD, POST, PUT, PATCH, DELETE, TRACE, CONNECT
}

