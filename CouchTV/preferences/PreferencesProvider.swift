//
//  PreferencesProvider.swift
//  CouchTV
//
//  Created by Antonio Ribeiro on 19/04/16.
//  Copyright © 2016 Antonio Ribeiro. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

extension DefaultsKeys {
    static let rootUrl = DefaultsKey<NSURL?>("rooturl")
    static let apiKey = DefaultsKey<String?>("apikey")
}

protocol PreferencesProvider {
    
    var isAppConfigured: Bool { get }
    
    var rootUrl: NSURL? { get set }
    
    var apiKey: String? { get set }
    
    
}

class PreferencesProviderManager {
    
    static let instance: PreferencesProvider = RealPreferencesProvider()
    
}

class RealPreferencesProvider: PreferencesProvider {
 
    var isAppConfigured: Bool {
        return rootUrl != nil && apiKey != nil
    }
    
    var rootUrl: NSURL? {
        get {
            return Defaults[.rootUrl]
        }
        
        set {
            Defaults[.rootUrl] = newValue
        }
    }
    
    var apiKey: String? {
        get {
            let _apiKey = Defaults[.apiKey]
            if _apiKey?.characters.count == 0 {
                return nil
            }
            return _apiKey
        }
        
        set {
            Defaults[.apiKey] = newValue
        }
    }
    
}