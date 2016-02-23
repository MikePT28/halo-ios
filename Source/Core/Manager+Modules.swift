//
//  Manager+Modules.swift
//  HaloSDK
//
//  Created by Borja Santos-Díez on 11/11/15.
//  Copyright © 2015 MOBGEN Technology. All rights reserved.
//

import Foundation
import RealmSwift

extension Manager {
 
    /**
     Get a list of the existing modules for the provided client credentials
     
     - parameter offlinePolicy: Offline policy to be considered when retrieving data
     - parameter completionHandler:  Closure to be executed when the request has finished
     */
    public func getModules(offlinePolicy: OfflinePolicy? = Manager.sharedInstance.defaultOfflinePolicy, completionHandler handler: (Halo.Result<[Halo.Module], NSError>) -> Void) -> Void {
        
        switch offlinePolicy! {
        case .None:
            self.net.getModules().response(completionHandler: handler)
        case .LoadAndStoreLocalData, .ReturnLocalDataDontLoad:
            self.persist.getModules(fetchFromNetwork: (offlinePolicy == .LoadAndStoreLocalData), completionHandler: handler)
        }
    }
    
    /**
     Get a list of the existing modules for the provided client credentials
     
     - parameter offlinePolicy: Offline policy to be considered when retrieving data
     - parameter success:       Closure to be executed when the request has succeeded
     - parameter failure:       Closure to be executed when the request has failed
     */
    @objc(modulesWithOfflinePolicy:success:failure:)
    public func getModulesOfflinePolicyFromObjC(offlinePolicy: OfflinePolicy, success: ((userData: [Halo.Module], cached: Bool) -> Void)?, failure: ((error: NSError) -> Void)?) -> Void {
        
        self.privateGetModules(offlinePolicy, success: success, failure: failure)
        
    }
    
    /**
     Get a list of the existing modules for the provided client credentials
     
     - parameter success:  Closure to be executed when the request has succeeded
     - parameter failure:  Closure to be executed when the request has failed
     */
    @objc(modulesWithSuccess:failure:)
    public func getModulesFromObjC(success: ((userData: [Halo.Module], cached: Bool) -> Void)?, failure: ((error: NSError) -> Void)?) -> Void {
        
        self.privateGetModules(nil, success: success, failure: failure)
    
    }
    
    private func privateGetModules(offlinePolicy: OfflinePolicy?, success: ((userData: [Halo.Module], cached: Bool) -> Void)?, failure: ((error: NSError) -> Void)?) -> Void {
        
        self.getModules(offlinePolicy) { (result) -> Void in
            switch result {
            case .Success(let modules, let cached):
                success?(userData: modules, cached: cached)
            case .Failure(let error):
                failure?(error: error)
            }
        }
    }
}