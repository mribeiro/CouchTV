//
//  Movie.swift
//  CouchTV
//
//  Created by Antonio Ribeiro on 12/04/16.
//  Copyright © 2016 Antonio Ribeiro. All rights reserved.
//

import Foundation
import Argo
import Curry


class Movie {
    
    var name: String
    var rating: [Float]?
    var postersUrls: [String]?
    var imdbId: String?
    var plot: String?
    var year: Int
    var length: Int?
    var tagline: String?
    var mpaa: String?
    var genres: [String]
    var postersOriginalUrls: [String]?
    var backdropsUrls: [String]?
    var backdropsOriginalUrls: [String]?
    var actorsWithPictures: [String: String]?
    var status: MovieStatus
    var libraryStatus: String?
    var wantedStatus: String?
    
    var mainPosterUrl: String? {
        
        if let urls = postersOriginalUrls where postersOriginalUrls?.count > 0 {
            return urls.first
        }
        
        if let urls = postersUrls where postersUrls?.count > 0 {
            return urls.first
        }
        
        return nil
        
    }
    
    init(name: String, rating: [Float]?, postersUrls: [String]?, imdbId: String?, plot: String?, year: Int, length: Int?, tagline: String?, mpaa: String?, genres: [String], postersOriginalUrls: [String]?, backdropsUrls: [String]?, backdropsOriginalUrls: [String]?, actors: [String: String]?, libraryStatus: String?, wantedStatus: String?) {
        self.name = name
        self.rating = rating
        self.postersUrls = postersUrls
        self.imdbId = imdbId
        self.plot = plot
        self.year = year
        self.length = length
        self.tagline = tagline
        self.mpaa = mpaa
        self.genres = genres
        self.postersOriginalUrls = postersOriginalUrls
        self.backdropsUrls = backdropsUrls
        self.backdropsOriginalUrls = backdropsOriginalUrls
        self.actorsWithPictures = actors
        self.libraryStatus = libraryStatus
        self.wantedStatus = wantedStatus
        
        self.status = MovieStatus.statusFromLibraryStatus(libraryStatus, andWantedStatus: wantedStatus)
    }
    
}

class SearchMovie: Movie, Decodable {
    
    static func decode(j: JSON) -> Decoded<SearchMovie> {
        
        let a = curry(SearchMovie.init)
            <^> j <| "original_title"
            <*> j <||? ["rating", "imdb"]
            <*> j <||? ["images", "poster"]
            <*> j <|? "imdb"
            <*> j <|? "plot"
            <*> j <| "year"
            <*> j <|? "runtime"
            
        let b = a
            <*> j <|? "tagline"
            <*> j <|? "mpaa"
            <*> j <|| "genres"
            <*> j <||? ["images", "poster_original"]
            <*> j <||? ["images", "backdrop"]
            <*> j <||? ["images", "backdrop_original"]
            <*> .optional(j <| ["images", "actors"] >>- { [String: String].decode($0) })
            <*> j <|? ["in_library", "status"] <|> pure(nil)
            <*> j <|? ["in_wanted", "status"] <|> pure(nil)
        
        
        if let error = b.error {
            NSLog("### ERROR DECODING SEARCH MOVIE --> \(error.description)")
        }
        
        return b
    }
}

class DiscoveryMovie: Movie, Decodable {
    
    static func decode(j: JSON) -> Decoded<DiscoveryMovie> {
        let a = curry(DiscoveryMovie.init)
            <^> j <| "title"
            <*> j <||? ["info", "rating", "imdb"]
            <*> j <||? ["info", "images", "poster"]
            <*> j <|? ["info", "imdb"]
            <*> j <|? ["info", "plot"]
            <*> j <| ["info", "year"]
            <*> j <|? ["info", "runtime"]
        
        let b = a
            <*> j <|? ["info", "tagline"]
            <*> j <|? ["info", "mpaa"]
            <*> j <|| ["info", "genres"]
            <*> j <||? ["info", "images", "poster_original"]
            <*> j <||? ["info", "images", "backdrop"]
            <*> j <||? ["info", "images", "backdrop_original"]
            <*> .optional(j <| ["info", "images", "actors"] >>- { [String: String].decode($0) })
            <*> j <|? "status" <|> pure(nil)
            <*> j <|? ["info", "in_wanted", "status"] <|> pure(nil)
        
        if let error = b.error {
            NSLog("### ERROR DECODING DISCOVERY MOVIE --> \(error.description)")
        }
        
        return b
    }
}

struct MovieSearchWrapper: Decodable {
    
    let movies: [SearchMovie]
    
    static func decode(json: JSON) -> Decoded<MovieSearchWrapper> {
        return curry(MovieSearchWrapper.init)
            <^> json <|| "movies"
    }
    
}

enum MovieStatus {
    
    case Waiting
    case Downloaded
    case NotDownloaded
    
    static func statusFromLibraryStatus(ls: String?, andWantedStatus ws: String?) -> MovieStatus {
        
        if ws != nil || ls == "active" {
            return .Waiting
        }
        
        if ls == "done" {
            return .Downloaded
        }
        
        return .NotDownloaded
    }
    
}