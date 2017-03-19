//
//  DummyMovieProvider.swift
//  CouchTV
//
//  Created by Antonio Ribeiro on 12/04/16.
//  Copyright © 2016 Antonio Ribeiro. All rights reserved.
//


import Foundation
import Argo

class DummyMovieProvider : MovieProvider {
    internal func getKey(username: String, password: String, callback: @escaping ((String?) -> ())) {
        callback("dummy key")
    }

    
    func fetchMovie(imdbId: String, callback: @escaping ((Bool) -> ())) {
        callback(true)
    }
    
    internal func getDiscovery(callback: @escaping ([DiscoveryCategory]?) -> ()) {
        var categories: [DiscoveryCategory] = [DiscoveryCategory]()
        
        if let json = loadFileByName(name: "suggestions_example", andExtension: "json") {
            
            var category: DiscoveryCategory?
            
            let j = JSON(json)
            let _disc = Suggestions.decode(j)
            category = _disc.value
            
            category?.name = "Suggestions"
            
            categories.append(category!)
        }
        
        if let json = loadFileByName(name: "charts_sample", andExtension: "json") {
            
            let j = JSON(json)
            let chartsWrapper = ChartsWrapper.decode(j).value
            
            
            chartsWrapper?.charts.forEach {
                if let movies = $0.movies, movies.count > 0 {
                    categories.append($0)
                }
            }
        }
        
        callback(categories)
    }
    
    
    func search(searchTerm: String, callback: @escaping (([Movie]?)->())) {
        NSLog("Searching in dummy for \(searchTerm)")
        
        var filteredMovies: [Movie]?
        
        if let json = loadFileByName(name: "search_sample", andExtension: "json") {
            
            let j = JSON(json)
            let movieSearchWrapper = MovieSearchWrapper.decode(j)
            
            let lowerCaseSearch = searchTerm.lowercased()
            filteredMovies = movieSearchWrapper.value?.movies.filter {
                $0.name.lowercased().contains(lowerCaseSearch)
            }
        }
        
        callback(filteredMovies)
    }
    
    func getWanted(callback: @escaping (([DiscoveryMovie]?) -> ())) {
        print("Getting wanted dummies")
        
        var movieList: MovieList?
        if let json = loadFileByName(name: "movie_list_wanted_sample", andExtension: "json") {
            
            let j = JSON(json)
            movieList = MovieList.decode(j).value
            callback(movieList?.movies)
            
            
        }
    }
    
    func testConnection(callback: @escaping ((Bool) -> ())) {
        callback(true)
    }
    
    private func loadFileByName(name: String, andExtension: String) -> AnyObject? {
        if let path = Bundle.main.path(forResource: name, ofType: andExtension) {
            if let jsonData = NSData(contentsOfFile: path) {
                return try! JSONSerialization.jsonObject(with: jsonData as Data, options: []) as AnyObject?
            }
        }
        
        return nil
    }
    
}
