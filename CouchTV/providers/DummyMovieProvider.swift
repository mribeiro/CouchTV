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
    
    func fetchMovie(imdbId: String, callback: (Bool -> ())) {
        callback(true)
    }
    
    func getDiscovery(callback: ([DiscoveryCategory]?)->()) {
        var categories: [DiscoveryCategory] = [DiscoveryCategory]()
        
        if let json = loadFileByName("suggestions_example", andExtension: "json") {
            
            var category: DiscoveryCategory?
            
            let j = JSON(json)
            let _disc = Suggestions.decode(j)
            category = _disc.value
            
            category?.name = "Suggestions"
            
            categories.append(category!)
        }
        
        if let json = loadFileByName("charts_sample", andExtension: "json") {
            
            let j = JSON(json)
            let chartsWrapper = ChartsWrapper.decode(j).value
            
            chartsWrapper?.charts.forEach {
                if $0.movies?.count > 0 {
                    categories.append($0)
                }
            }
        }
        
        callback(categories)
    }
    
    
    func search(searchTerm: String, callback: ([Movie]?->())) {
        NSLog("Searching in dummy for \(searchTerm)")
        
        var filteredMovies: [Movie]?
        
        if let json = loadFileByName("search_sample", andExtension: "json") {
            
            let j = JSON(json)
            let movieSearchWrapper = MovieSearchWrapper.decode(j)
            
            let lowerCaseSearch = searchTerm.lowercaseString
            filteredMovies = movieSearchWrapper.value?.movies.filter {
                $0.name.lowercaseString.containsString(lowerCaseSearch)
            }
        }
        
        callback(filteredMovies)
    }
    
    func getKey(callback: (String? -> ())) {
        callback("dummy key")
    }
    
    func testConnection(callback: (Bool -> ())) {
        callback(true)
    }
    
    private func loadFileByName(name: String, andExtension: String) -> AnyObject? {
        if let path = NSBundle.mainBundle().pathForResource(name, ofType: andExtension) {
            if let jsonData = NSData(contentsOfFile: path) {
                return try? NSJSONSerialization.JSONObjectWithData(jsonData, options: [])
            }
        }
        
        return nil
    }
    
}