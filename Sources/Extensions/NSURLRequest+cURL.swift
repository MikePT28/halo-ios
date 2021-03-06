//
//  NSURLRequest+cURL.swift
//  HaloSDK
//
//  Created by Borja on 02/03/16.
//  Copyright © 2016 MOBGEN Technology. All rights reserved.
//

import Foundation

extension URLRequest {

    public var curlRequest: String {

        let curlString = NSMutableString(string: "curl -k -X \(self.httpMethod!) --dump-header -")

        self.allHTTPHeaderFields?.forEach({ (key, value) -> () in
            let headerKey = self.escapeString(key)
            let headerValue = self.escapeString(value)
            curlString.append(" -H \"\(headerKey): \(headerValue)\"")
        })

        if let bodyData = self.httpBody {
            if let bodyDataString = String(data: bodyData, encoding: String.Encoding.utf8) {
                curlString.append(" -d \"\(self.escapeString(bodyDataString))\"")
            }
        }

        if let url = self.url {
            curlString.append(" \"\(url.absoluteString)\"")
        }

        return curlString as String
    }


    fileprivate func escapeString(_ str: String) -> String {
        return str.replacingOccurrences(of: "\"", with: "\\\"")
    }
}
