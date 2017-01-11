//
//  CouchPotatoService.swift
//  CouchTV
//
//  Created by Antonio Ribeiro on 08/01/2017.
//  Copyright © 2017 Antonio Ribeiro. All rights reserved.
//

import Foundation
import Moya
import CryptoSwift

enum CouchPotatoService: TargetType {
    
    private static let preferencesManager = PreferencesProviderManager.instance
    
    /// The method used for parameter encoding.
    public var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }

    
    /// Provides stub data for use in testing.
    public var sampleData: Data {
        return "{}".utf8Encoded
    }

    /// The type of HTTP task to be performed.
    public var task: Task {
        return .request
    }

    /// The method used for parameter encoding.

    /// The parameters to be incoded in the request.
    public var parameters: [String : Any]? {
        
        switch self {
        case .addMovie(let imdbId):
            return ["identifier": imdbId]
            
        case .search(let searchTerm):
            return ["q": searchTerm]
            
        case .getKey(let username, let password):
            return ["p": password.md5(), "u": username.md5()]
            
        default:
            return nil
        }
    }

    /// The HTTP method used in the request.
    public var method: Moya.Method {
        return .get
    }

    
    /// The target's base `URL`.
    public var baseURL: URL {
        switch self {
        case .getKey(_,_):
            return PreferencesProviderManager.instance.rootUrl!
            
        default:
            var url = PreferencesProviderManager.instance.rootUrl
            url?.appendPathComponent("api/\(PreferencesProviderManager.instance.apiKey ?? "" )")
            return url!
        }
    }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    public var path: String {
        switch self {
        case .suggestions:
            return "/suggestion.view"
            
        case .charts:
            return "/charts.view"
            
        case .addMovie( _):
            return "/movie.add"
            
        case .getCPVersion:
            return "/app.version"
            
        case .search( _):
            return "/movie.search"
            
        case .getKey(_, _):
            return "/getkey/"
            
        }
    }
    
    case suggestions
    case charts
    case addMovie(imdbId: String)
    case getCPVersion
    case search(searchTerm: String)
    case getKey(username: String, password: String)
    
}

// MARK: - Helpers
private extension String {
    var urlEscaped: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    var utf8Encoded: Data {
        return self.data(using: .utf8)!
    }
}
