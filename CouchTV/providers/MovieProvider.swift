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
    
    // out of scope, for now
    func getKey(callback: ((String?)->()))
    
}

class MovieProviderManager {
    static let instance: MovieProvider = CouchPotatoMovieProvider()
}
