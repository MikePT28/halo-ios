//
//  SyncQuery.swift
//  HaloSDK
//
//  Created by Borja Santos-Díez on 14/09/16.
//  Copyright © 2016 MOBGEN Technology. All rights reserved.
//

import Foundation

@objc(HaloSyncQuery)
public class SyncQuery: NSObject {

    struct Keys {
        static let ModuleName = "moduleName"
        static let Locale = "locale"
        static let FromSync = "fromSync"
        static let ToSync = "toSync"
    }

    var locale: Locale?
    var moduleName: String = ""
    var fromSync: NSDate?
    var toSync: NSDate?

    public var body: [String: AnyObject] {
        var dict = [String: AnyObject]()

        dict[Keys.ModuleName] = moduleName

        if let loc = locale {
            dict[Keys.Locale] = loc.description
        }

        if let from = fromSync {
            dict[Keys.FromSync] = from.timeIntervalSince1970 * 1000
        }

        if let to = toSync {
            dict[Keys.ToSync] = to.timeIntervalSince1970 * 1000
        } else {
            dict[Keys.ToSync] = NSDate().timeIntervalSince1970 * 1000
        }

        return dict
    }

    private override init() {
        super.init()
    }

    public init(moduleName: String) {
        self.moduleName = moduleName
        super.init()
    }

    public func locale(locale: Locale) -> SyncQuery {
        self.locale = locale
        return self
    }
}
