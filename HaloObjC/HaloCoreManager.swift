//
//  HaloCoreManager.swift
//  HaloSDK
//
//  Created by Borja Santos-Díez on 10/03/16.
//  Copyright © 2016 MOBGEN Technology. All rights reserved.
//

import Halo

public class HaloCoreManager: NSObject {
    
    static let sharedInstance = HaloCoreManager()
    let core = Halo.Manager.core
    
    override private init() {}
    
    /// Delegate that will handle launching completion and other important steps in the flow
    public var delegate: ManagerDelegate? {
        get {
            return core.delegate
        }
        set {
            core.delegate = newValue
        }
    }
    
    public var pushDelegate: PushDelegate? {
        get {
            return core.pushDelegate
        }
        set {
            core.pushDelegate = newValue
        }
    }
    
    public var debug: Bool {
        get {
            return core.debug
        }
        set {
            core.debug = newValue
        }
    }
    
    public var defaultOfflinePolicy: OfflinePolicy {
        get {
            return core.defaultOfflinePolicy
        }
        set {
            core.defaultOfflinePolicy = newValue
        }
    }
    
    public var numberOfRetries: Int {
        get {
            return core.numberOfRetries
        }
        set {
            core.numberOfRetries = newValue
        }
    }
    
    public var authenticationMode: AuthenticationMode {
        get {
            return core.authenticationMode
        }
        set {
            core.authenticationMode = newValue
        }
    }
    
    public var credentials: Credentials? {
        get {
            return core.credentials
        }
    }
    
    public var appCredentials: Credentials? {
        get {
            return core.appCredentials
        }
        set {
            core.appCredentials = newValue
        }
    }
    
    public var userCredentials: Credentials? {
        get {
            return core.userCredentials
        }
        set {
            core.userCredentials = newValue
        }
    }
    
    /// Variable to decide whether to enable push notifications or not
    public var enablePush: Bool {
        get {
            return core.enablePush
        }
        set {
            core.enablePush = newValue
        }
    }
    
    /// Variable to decide whether to enable system tags or not
    public var enableSystemTags: Bool {
        get {
            return core.enableSystemTags
        }
        set {
            core.enableSystemTags = newValue
        }
    }
    
    /// Instance holding all the user-related information
    public var user: User? {
        get {
            return core.user
        }
        set {
            core.user = newValue
        }
    }
    
    @objc(startup:)
    public func startup(completionHandler handler: (Bool) -> Void) -> Void {
        core.startup(completionHandler: handler)
    }
    
    /**
     Pass through the push notifications setup. To be called within the method in the app delegate.
     
     - parameter application: Application being configured
     - parameter deviceToken: Token obtained for the current device
     */
    public func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        core.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
    
    /**
     Pass through the push notifications setup. To be called within the method in the app delegate.
     
     - parameter application: Application being configured
     - parameter error:       Error thrown during the process
     */
    public func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        core.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
    }
    
    public func applicationDidBecomeActive(application: UIApplication) {
        core.applicationDidBecomeActive(application)
    }
    
    public func applicationDidEnterBackground(application: UIApplication) {
        core.applicationDidEnterBackground(application)
    }
    
    public func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        core.application(application, didReceiveRemoteNotification: userInfo)
    }
    
    public func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        core.application(application, didReceiveLocalNotification: notification)
    }
    
    @objc
    public func modules(offlinePolicy: OfflinePolicy) -> HaloRequest {
        return HaloRequest(request: core.getModules(offlinePolicy))
    }
}