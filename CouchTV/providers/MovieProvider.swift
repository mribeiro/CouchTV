//
//  MovieProviderProtocol.swift
//  CouchTV
//
//  Created by Antonio Ribeiro on 12/04/16.
//  Copyright © 2016 Antonio Ribeiro. All rights reserved.
//

import Foundation

protocol MovieProvider {
    
    func testConnection(callback: (Bool->()))
    
    func search(searchTerm: String, callback: ([Movie]?->()))
    
    func fetchMovie(imdbId: String, callback: (Bool->()))
    
    func getDiscovery(callback: ([DiscoveryCategory]?)->())
    
    // out of scope, for now
    func getKey(callback: (String?->()))
    
}

class MovieProviderManager {
    static let instance: MovieProvider = CouchPotatoMovieProvider()
}