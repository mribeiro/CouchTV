//
//  MovieProviderProtocol.swift
//  CouchTV
//
//  Created by Antonio Ribeiro on 12/04/16.
//  Copyright © 2016 Antonio Ribeiro. All rights reserved.
//

import Foundation

protocol MovieProvider {
    
    func testConnection(callback: @escaping ((Bool)->()))
    
    func search(searchTerm: String, callback: @escaping (([Movie]?)->()))
    
    func fetchMovie(imdbId: String, callback: @escaping ((Bool)->()))
    
    func getDiscovery(callback: @escaping ([DiscoveryCategory]?)->())
    
    func getWanted(callback: @escaping(([DiscoveryMovie]?)->()))
    
    func ignoreSuggestion(imdbId: String, callback: @escaping((Bool)->()))
    
    // out of scope, for now
    func getKey(username: String, password: String, callback: @escaping ((String?)->()))
    
}

class MovieProviderManager {
    static let instance: MovieProvider = CouchPotatoMovieProvider()
}
