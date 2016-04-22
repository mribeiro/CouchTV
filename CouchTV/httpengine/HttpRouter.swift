//
//  HttpRouter.swift
//  CouchTV
//
//  Created by Antonio Ribeiro on 19/04/16.
//  Copyright © 2016 Antonio Ribeiro. All rights reserved.
//

import Foundation
import Alamofire

enum HttpRouter: URLRequestConvertible {
    
    case Suggestions
    case Charts
    case AddMovie(imdbId: String)
    case GetCPVersion
    case Search(searchTerm: String)
    
    case GetApiKey // postponed
    
    var URLRequest: NSMutableURLRequest {
        let preferences = PreferencesProviderManager.instance
        
        let apiKey = preferences.apiKey
        NSLog("Api key: \(apiKey)")
        
        let basePath = "/api/" + (apiKey ?? "")
        NSLog("base path \(basePath)")
        var path: String
        var params: [String: String]?
        
        switch self {
            
        case .Suggestions:
            path = "/suggestion.view"
        case .Charts:
            path = "/charts.view"
        case .AddMovie(let imdbId):
            path = "/movie.add"
            params = [String: String]()
            params!["identifier"] = imdbId
            
        case .GetApiKey:
            
            // This required a bridging-header, yada yada yada...
            // I'll do it, eventually
            
            path = "/getkey"
            
        case .GetCPVersion:
            path = "/app.version"
            
        case .Search(let searchTerm):
            path = "/movie.search"
            params = [String: String]()
            params!["q"] = searchTerm
        
        }
        
        NSLog("getting root url")
        let rootUrl: NSURL? = preferences.rootUrl
        NSLog("Url: \(rootUrl)")
        
        if let url = rootUrl {
            let urlRequest = NSMutableURLRequest(URL: url.URLByAppendingPathComponent(basePath + path))
            return Alamofire.ParameterEncoding.URL.encode(urlRequest, parameters: params).0
            
        } else {
            return NSMutableURLRequest()
        }
        
    }
    
}