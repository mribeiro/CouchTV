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
    
    func getDiscovery(callback: ([DiscoveryCategory]?)->()) {
        
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
                return $0.movies?.count > 0
            }
            
            callback(array)
            
        }
        
        let fetchCharts = { () -> () in
            
            self.doRequest(HttpRouter.Charts.URLRequest,
                           whenSuccess: { json in
                            
                            if let _json = json {
                                let charts: Decoded<ChartsWrapper> = ChartsWrapper.decode(_json)
                                chartsFromCP = charts.value?.charts
                                
                                if let _charts = chartsFromCP {
                                    if array == nil {
                                        array = _charts
                                    } else {
                                        array?.appendContentsOf(_charts)
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
            self.doRequest(HttpRouter.Suggestions.URLRequest,
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
    
    func search(searchTerm: String, callback: ([Movie]?->())) {
        
        guard PreferencesProviderManager.instance.isAppConfigured else {
            callback(nil)
            return
        }
        
        guard searchTerm.characters.count > 0 else {
            callback([Movie]())
            return
        }
        
        doRequest(HttpRouter.Search(searchTerm: searchTerm).URLRequest,
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
                    
            }, whenComplete: .None
        )
    }
    
    func fetchMovie(imdbId: String, callback: (Bool->())) {
        
        guard PreferencesProviderManager.instance.isAppConfigured else {
            callback(false)
            return
        }
        
        doRequest(HttpRouter.AddMovie(imdbId: imdbId).URLRequest,
                  whenSuccess: { json in
                    callback(true)
                    
            },
                  whenError: { errorDescription in
                    callback(false)
            }, whenComplete: .None)
        
    }
    
    func getKey(callback: (String?->())) {
        //one day this will have proper code!
        NSLog("Not implemented")
        callback("Not implemented")
    }
    
    func testConnection(callback: (Bool->())) {
        guard PreferencesProviderManager.instance.isAppConfigured else {
            callback(false)
            return
        }
        
        doRequest(HttpRouter.GetCPVersion.URLRequest,
                  
                  whenSuccess: { json in
                    callback(true)
                    
            },
                  whenError: { errorDescription in
                    callback(false)
                    
            }, whenComplete: .None)
    }
    
    
    private func doRequest(request: NSURLRequest, whenSuccess: (json: JSON?)->(), whenError: (description: String)->(), whenComplete: Optional<()->()>) {
        
        NSLog("requesting \(request)")
        Alamofire.request(request).responseJSON { response in
            
            let result = response.result
            
            switch result {
            case .Failure(let error):
                NSLog("Request error: " + error.description)
                whenError(description: error.description)
                
            case .Success(let value):
                let json = JSON(value)
                whenSuccess(json: json)
            }
            
            whenComplete?()
        }
    }
    
}