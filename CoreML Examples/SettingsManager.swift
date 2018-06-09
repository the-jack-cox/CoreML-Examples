//
//  SettingsManager.swift
//  MLCore Examples
//
//  Created by Jack Cox on 6/9/18.
//  Copyright © 2018 CapTech Consulting. All rights reserved.
//

import Foundation

fileprivate var _singleton:SettingsManager = SettingsManager()

class SettingsManager {
    
    static var sharedInstance:SettingsManager {
        get {
            return _singleton
        }
    }
    
    
    public var useGPUForImageClassification:Bool = false
    
    
    public var doCustomClassification:Bool = true
    public var doInceptionClassification:Bool = true
}
