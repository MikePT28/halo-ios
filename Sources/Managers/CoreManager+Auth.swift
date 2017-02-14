//
//  CoreManager+Auth.swift
//  Halo
//
//  Created by Borja Santos-Díez on 19/12/16.
//  Copyright © 2016 MOBGEN Technology. All rights reserved.
//

import Foundation
import UIKit

extension CoreManager {
    
    func configureDevice(_ handler: ((Bool) -> Void)? = nil) {
        
        self.device = Halo.Device.loadDevice(env: self.environment)
        
        if let device = self.device, device.id != nil {
            // Update the user
            Manager.network.getDevice(device) { (_, result) -> Void in
                switch result {
                case .success(let device, _):
                    self.device = device
                    
                    if self.enableSystemTags {
                        self.setupDefaultSystemTags(handler)
                    } else {
                        handler?(true)
                    }
                case .failure(let error):
                    
                    self.logMessage("Error retrieving device from server (\(error.description))", level: .error)
                    
                    if self.enableSystemTags {
                        self.setupDefaultSystemTags(handler)
                    } else {
                        handler?(false)
                    }
                }
            }
            
        } else {
            self.device = Halo.Device()
            self.delegate?.managerWillSetupDevice(self.device!)
            
            if self.enableSystemTags {
                self.setupDefaultSystemTags(handler)
            } else {
                handler?(true)
            }
        }
    }
    
    fileprivate func setupDefaultSystemTags(_ handler: ((Bool) -> Void)? = nil) {
        
        if let device = self.device {
            
            device.addSystemTag(name: CoreConstants.tagPlatformNameKey, value: "ios")
            
            let version = ProcessInfo.processInfo.operatingSystemVersion
            var versionString = "\(version.majorVersion).\(version.minorVersion)"
            
            if (version.patchVersion > 0) {
                versionString = versionString + ".\(version.patchVersion)"
            }
            
            device.addSystemTag(name: CoreConstants.tagPlatformVersionKey, value: versionString)
            
            if let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") {
                device.addSystemTag(name: CoreConstants.tagApplicationNameKey, value: (appName as AnyObject).description)
            }
            
            if let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") {
                device.addSystemTag(name: CoreConstants.tagApplicationVersionKey, value: (appVersion as AnyObject).description)
            }
            
            device.addSystemTag(name: CoreConstants.tagDeviceManufacturerKey, value: "Apple")
            device.addSystemTag(name: CoreConstants.tagDeviceModelKey, value: UIDevice.current.modelName)
            device.addSystemTag(name: CoreConstants.tagDeviceTypeKey, value: UIDevice.current.deviceType)
            
            device.addSystemTag(name: CoreConstants.tagBLESupportKey, value: "true")
            
            //user.addTag(CoreConstants.tagNFCSupportKey, value: "false")
            
            let screen = UIScreen.main
            let bounds = screen.bounds
            let (width, height) = (bounds.width * screen.scale, round(bounds.height * screen.scale))
            
            device.addSystemTag(name: CoreConstants.tagDeviceScreenSizeKey, value: "\(Int(width))x\(Int(height))")
            
            switch self.environment {
            case .int, .stage, .qa:
                device.addSystemTag(name: CoreConstants.tagTestDeviceKey, value: "true")
            default:
                break
            }
            
            // Get APNs environment
            device.addSystemTag(name: "apns", value: MobileProvisionParser.applicationReleaseMode().rawValue.lowercased())
            
            handler?(true)
        } else {
            handler?(false)
        }
        
    }
    
    func registerDevice(_ handler: ((Bool) -> Void)? = nil) -> Void {
        
        if let device = self.device {
            self.device?.storeDevice(env: self.environment)
            
            self.addons.forEach { ($0 as? DeviceAddon)?.willRegisterAddon(haloCore: self) }
            
            Manager.network.createUpdateDevice(device, bypassReadiness: true) { [weak self] (_, result) -> Void in
                
                var success = false
                
                if let strongSelf = self {
                    
                    switch result {
                    case .success(let device, _):
                        strongSelf.device = device
                        strongSelf.device?.storeDevice(env: strongSelf.environment)
                        
                        if let u = device {
                            Manager.core.logMessage(u.description, level: .info)
                        }
                        
                        success = true
                    case .failure(let error):
                        Manager.core.logMessage("Error creating/updating device (\(error.description))", level: .error)
                    }
                    
                    strongSelf.addons.forEach { ($0 as? DeviceAddon)?.didRegisterDevice(haloCore: strongSelf) }
                    handler?(success)
                    
                }
            }
        } else {
            handler?(false)
        }
    }
    
    /**
     By calling this function, the current user handled by the Core Manager will be saved in the server.
     
     - parameter handler: Closure to be executed once the request has finished, providing a result.
     */
    public func saveDevice(_ handler: ((HTTPURLResponse?, Halo.Result<Halo.Device?>) -> Void)? = nil) -> Void {
        
        /**
         *  Make sure no 'saveUser' are executed concurrently. That could lead to some inconsistencies in the server (several users
         *  created for the same device).
         */
        lockQueue.sync {
            
            if let device = self.device {
                
                Manager.network.createUpdateDevice(device, bypassReadiness: true) { [weak self] (response, result) in
                    
                    if let strongSelf = self {
                        
                        switch result {
                        case .success(let device, _):
                            strongSelf.device = device
                            
                            if let u = device {
                                strongSelf.logMessage(u.description, level: .info)
                            }
                            
                        case .failure(let error):
                            strongSelf.logMessage("Error saving device (\(error.description))", level: .error)
                        }
                        
                        handler?(response, result)
                        
                    }
                    
                }
            }
        }
    }
    
    /**
     Authenticate against the server using the provided mode and the stored credentials. No authentication is needed under normal
     circumnstances. The system will take care of everything, but this could become handy if the authentication wants to be forced for
     some reason.
     
     - parameter mode:    Authentication mode to be used
     - parameter handler: Closure to be executed once the authentication has finished
     */
    public func authenticate(authMode mode: Halo.AuthenticationMode = .app, completionHandler handler: ((HTTPURLResponse?, Halo.Result<Halo.Token>) -> Void)? = nil) -> Void {
        Manager.network.authenticate(mode: mode) { (response, result) in
            handler?(response, result)
        }
    }
}
