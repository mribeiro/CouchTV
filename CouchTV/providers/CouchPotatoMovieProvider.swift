//
//  CouchPotatoMovieProvider.swift
//  CouchTV
//
//  Created by Antonio Ribeiro on 20/04/16.
//  Copyright © 2016 Antonio Ribeiro. All rights reserved.
//

import Foundation
import Alamofire
import Argo
import Curry

class CouchPotatoMovieProvider: MovieProvider {
    
    func getDiscovery(callback: @escaping ([DiscoveryCategory]?)->()) {
        
        guard PreferencesProviderManager.instance.isAppConfigured else {
            callback(nil)
            return
        }
        
        var suggestionsFetched = false
        var chartsFetched = false
        
        var suggestionsFromCP: DiscoveryCategory?
        var chartsFromCP: [DiscoveryCategory]?
        var array: [DiscoveryCategory]?
        
        let finalize = { () -> () in
            
            guard suggestionsFetched && chartsFetched else {
                return
            }
            
            array = array?.filter {
                return ($0.movies?.count) ?? 0 > 0
            }
            
            callback(array)
            
        }
        
        let fetchCharts = { () -> () in
            
            try! self.doRequest(request: HttpRouter.Charts.asURLRequest(),
                                whenSuccess: { json in
                                    
                                    if let _json = json {
                                        let charts: Decoded<ChartsWrapper> = ChartsWrapper.decode(_json)
                                        chartsFromCP = charts.value?.charts
                                        
                                        if let _charts = chartsFromCP {
                                            if array == nil {
                                                array = _charts
                                            } else {
                                                array?.append(contentsOf: _charts)
                                            }
                                            
                                        }
                                        
                                    }
                                    
            },
                                whenError: { errorDescription in
                                    
            },
                                whenComplete: {
                                    chartsFetched = true
                                    finalize()
            })
            
        }
        
        let fetchSuggestions = { () -> () in
            try! self.doRequest(request: HttpRouter.Suggestions.asURLRequest(),
                           whenSuccess: { json in
                            
                            if let _json = json {
                                let suggestions:Decoded<Suggestions> = Suggestions.decode(_json)
                                suggestionsFromCP = suggestions.value
                                suggestionsFromCP?.name = "Suggestions"
                                if let _suggestions = suggestionsFromCP {
                                    array = [_suggestions]
                                }
                            }
                            
            },
                           whenError: { errorDescription in
                            
            },
                           whenComplete: {
                            suggestionsFetched = true
                            fetchCharts()
                            
            })
        }
        
        fetchSuggestions()
        
    }
    
    func search(searchTerm: String, callback: @escaping (([Movie]?)->())) {
        
        guard PreferencesProviderManager.instance.isAppConfigured else {
            callback(nil)
            return
        }
        
        guard searchTerm.characters.count > 0 else {
            callback([Movie]())
            return
        }
        
        try! doRequest(request: HttpRouter.Search(searchTerm: searchTerm).asURLRequest(),
                  whenSuccess: { json in
                    
                    var movies: [Movie]?
                    
                    if let _json = json {
                        let searchWrapper: Decoded<MovieSearchWrapper> = MovieSearchWrapper.decode(_json)
                        movies = searchWrapper.value?.movies
                    }
                    
                    callback(movies)
                    
        },
                  whenError: { errorDescription in
                    callback(nil)
                    
        }, whenComplete: .none
        )
    }
    
    func fetchMovie(imdbId: String, callback: @escaping ((Bool)->())) {
        
        guard PreferencesProviderManager.instance.isAppConfigured else {
            callback(false)
            return
        }
        
        try! doRequest(request: HttpRouter.AddMovie(imdbId: imdbId).asURLRequest(),
                  whenSuccess: { json in
                    callback(true)
                    
        },
                  whenError: { errorDescription in
                    callback(false)
        }, whenComplete: .none)
        
    }
    
    func getKey(callback: ((String?)->())) {
        //one day this will have proper code!
        NSLog("Not implemented")
        callback("Not implemented")
    }
    
    internal func testConnection(callback: @escaping ((Bool)->())) {
        guard PreferencesProviderManager.instance.isAppConfigured else {
            callback(false)
            return
        }
        
        try! doRequest(request: HttpRouter.GetCPVersion.asURLRequest(),
                  
                  whenSuccess: { json in
                    callback(true)
                    
        },
                  whenError: { errorDescription in
                    callback(false)
                    
        }, whenComplete: .none)
    }
    
    
    private func doRequest(request: URLRequest, whenSuccess: @escaping (_ json: JSON?)->(), whenError: @escaping (_ description: String)->(), whenComplete: Optional<()->()>) {
        
        NSLog("requesting \(request)")
        Alamofire.request(request).responseJSON { response in
            
            let result = response.result
            
            switch result {
            case .failure(let error):
                NSLog("Request error: " + error.localizedDescription)
                whenError(error.localizedDescription)
                
            case .success(let value):
                let json = JSON(value)
                whenSuccess(json)
            }
            
            whenComplete?()
        }
    }
    
}
