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
import Moya

class CouchPotatoMovieProvider: MovieProvider {

    
    private let couchPotatoService: MoyaProvider<CouchPotatoService>
    
    init () {
        self.couchPotatoService = MoyaProvider<CouchPotatoService>()
    }
    
    func getDiscovery(callback: @escaping ([DiscoveryCategory]?)->()) {
        
        guard PreferencesProviderManager.instance.isAppConfigured else {
            callback(nil)
            return
        }
        
        let finalize = { (allDiscoveries: [DiscoveryCategory]?) -> () in

            let filteredDiscoveries = allDiscoveries?.filter {
                return ($0.movies?.count) ?? 0 > 0
            }
            
            callback(filteredDiscoveries)
            
        }
        
        let fetchCharts = { (suggestions: [DiscoveryCategory]?) -> () in
            
            self.doMoyaRequest(CouchPotatoService.charts,
                                whenSuccess: { (json) -> ([DiscoveryCategory]?) in
                                    
                                    if let _json = json {
                                        let charts: Decoded<ChartsWrapper> = ChartsWrapper.decode(_json)
                                        let chartsFromCP = charts.value
                                        
                                        if let _charts = chartsFromCP?.charts {
                                            if suggestions == nil {
                                                return _charts
                                            } else {
                                                
                                                let chartsAsDiscoveryCategory: [DiscoveryCategory] = _charts.map({ (chart) -> DiscoveryCategory in
                                                    return chart
                                                })
                                                
                                                var allDiscoveries: [DiscoveryCategory]? = suggestions
                                                allDiscoveries!.append(contentsOf: chartsAsDiscoveryCategory)

                                                return allDiscoveries
                                            }
                                            
                                        }
                                        
                                    }
                                    
                                    return nil
                                    
            },
                                whenError: { errorDescription in
                                    
            },
                                whenComplete: { (success, error) in
                                    finalize(success)
            })
            
        }
        
        let fetchSuggestions = { () -> () in
            self.doMoyaRequest(CouchPotatoService.suggestions,
                           whenSuccess: { (json) -> ([DiscoveryCategory]?) in
                            
                            if let _json = json {
                                let suggestions:Decoded<Suggestions> = Suggestions.decode(_json)
                                let suggestionsFromCP = suggestions.value
                                suggestionsFromCP?.name = "Suggestions"
                                if let _suggestions = suggestionsFromCP {
                                    return [_suggestions]
                                }
                            }
                            
                            return nil
                            
            },
                           whenError: { errorDescription in
                            
            },
                           whenComplete: { (success, error) in
                            fetchCharts(success)
                            
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
        
        doMoyaRequest(CouchPotatoService.search(searchTerm: searchTerm),
                      whenSuccess: { (json) in
            
                        var movies: [Movie]?
                        
                        if let _json = json {
                            let searchWrapper: Decoded<MovieSearchWrapper> = MovieSearchWrapper.decode(_json)
                            movies = searchWrapper.value?.movies
                        }
                        
                        callback(movies)
            
        },
                      whenError: { (error) in
                        
                        callback(nil)
            
        },
                      whenComplete: .none
        )
        
    }
    
    func fetchMovie(imdbId: String, callback: @escaping ((Bool)->())) {
        
        guard PreferencesProviderManager.instance.isAppConfigured else {
            callback(false)
            return
        }
        
        doMoyaRequest(CouchPotatoService.addMovie(imdbId: imdbId),
                  whenSuccess: { json in
                    callback(true)
                    
        },
                  whenError: { errorDescription in
                    callback(false)
        }, whenComplete: .none)
        
    }
    
    func getKey(username: String, password: String, callback: @escaping ((String?)->())) {
        
        doMoyaRequest(CouchPotatoService.getKey(username: username, password: password),
                      whenSuccess: { (json) in
                        
                        var apiKey: String?
                        
                        if let _json = json {
                            let apiKeyDecoded = ApiKey.decode(_json)
                            apiKey = apiKeyDecoded.value?.apiKey
                        }
                        
                        callback(apiKey)
                        
        },
                      whenError: { (error) in
                        callback(nil)
                        
        },
                      whenComplete: .none)
    }
    
    func getWanted(callback: @escaping(([DiscoveryMovie]?)->())) {
        
        doMoyaRequest(CouchPotatoService.getMovies(status: "active"),
                      whenSuccess: { (json) in
                        var movieList: [DiscoveryMovie]?
                        
                        if let _json = json {
                            let movieListDecoded = MovieList.decode(_json)
                            movieList = movieListDecoded.value?.movies
                        }
                        
                        callback(movieList)
            
        },
                      whenError: { (error) in
                        callback(nil)
        },
                      whenComplete: .none)
        
    }
    
    func ignoreSuggestion(imdbId: String, callback: @escaping ((Bool) -> ())) {
        doMoyaRequest(CouchPotatoService.ignoreSuggestion(imdbId: imdbId), whenSuccess: { (json) in
            
            if let j = json {
                let result : Bool = BaseResponse.decode(j).value?.result ?? false
                callback(result)
            }
            
        }, whenError: { (error) in
            callback(false)
            
        }, whenComplete: .none)
    }
    
    
    internal func testConnection(callback: @escaping ((Bool)->())) {
        guard PreferencesProviderManager.instance.isAppConfigured else {
            callback(false)
            return
        }
        
        doMoyaRequest(.getCPVersion,
                      whenSuccess: { (json) in
                        callback(true)
                        
        },
                      whenError: { (error) in
                        callback(false)
                        
        },
                      whenComplete: .none
        )
        
    }
    
    private func doMoyaRequest<S, E>(_ target: CouchPotatoService,
                           whenSuccess: @escaping (_ json: JSON?)->(S?),
                           whenError: @escaping (_ error: Swift.Error)->(E?),
                           whenComplete: Optional<(S?, E?)->()>) {
        
        self.couchPotatoService.request(target) { (response) in
            
            var successResult: S?
            var errorResult: E?
            
            switch response {
            case .failure(let error):
                print("Request error: " + error.localizedDescription)
                errorResult = whenError(error)
                
            case .success(let value):
                
                if let json = try? value.mapJSON() {
                    successResult = whenSuccess(JSON(json))
                    
                } else {
                    //whenError(nil)
                }
            
            }
            
            whenComplete?(successResult, errorResult)
            
        }
        
    }
}
