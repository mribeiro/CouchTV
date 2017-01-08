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
    /// Returns a URL request or throws if an `Error` was encountered.
    ///
    /// - throws: An `Error` if the underlying `URLRequest` is `nil`.
    ///
    /// - returns: A URL request.
    public func asURLRequest() throws -> URLRequest {
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
        let rootUrl: URL? = preferences.rootUrl
        NSLog("Url: \(rootUrl)")
        
        if let url = rootUrl {
            let urlRequest = URLRequest(url: url.appendingPathComponent(basePath + path))
            //return Alamofire.ParameterEncoding.encode(urlRequest, parameters: params).0
            return urlRequest
            
        } else {
            return MutableURLRequest() as URLRequest
        }
    }

    
    case Suggestions
    case Charts
    case AddMovie(imdbId: String)
    case GetCPVersion
    case Search(searchTerm: String)
    
    case GetApiKey // postponed
    
}
