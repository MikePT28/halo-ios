//
//  HaloAppDelegate.swift
//  HaloSDK
//
//  Created by Borja on 01/10/15.
//  Copyright © 2015 MOBGEN Technology. All rights reserved.
//

import Foundation
import UIKit

/// Helper class intended to be used as superclass by any AppDelegate (Swift only)
public class HaloAppDelegate: UIResponder, UIApplicationDelegate {

    /**
    Just pass through the configuration of the push notifications to the manager.

    - parameter application: Application being configured
    - parameter deviceToken: Device token obtained in previous steps
    */
    public func application(application app: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        Manager.core.application(application: app, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }

    /**
     Just pass through the configuration of the push notifications to the manager.

     - parameter application: Application being configured
     - parameter error:       Error thrown during the process
     */
    public func application(application app: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        Manager.core.application(application: app, didFailToRegisterForRemoteNotificationsWithError: error)
    }

    public func applicationDidBecomeActive(application app: UIApplication) {
        Manager.core.applicationDidBecomeActive(application: app)
    }

    public func applicationDidEnterBackground(application app: UIApplication) {
        Manager.core.applicationDidEnterBackground(application: app)
    }

    public func application(application app: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        Manager.core.application(application: app, didReceiveRemoteNotification: userInfo)
    }

    /**
     Handle push notifications

     - parameter application:       Application receiving the push notification
     - parameter userInfo:          Dictionary containing all the information about the notification
     - parameter completionHandler: Handler to be executed once the fetch has finished
     */
    public func application(application app: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        Manager.core.application(application: app, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
    }

}
