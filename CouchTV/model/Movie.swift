//
//  Movie.swift
//  CouchTV
//
//  Created by Antonio Ribeiro on 12/04/16.
//  Copyright © 2016 Antonio Ribeiro. All rights reserved.
//

import Foundation
import Curry
import Argo
import Runes

class Movie: Decodable {
    
    public static func decode(_ json: JSON) -> Decoded<Movie> {
        let a = curry(DiscoveryMovie.init)
            <^> json <| "title"
            <*> json <||? ["info", "rating", "imdb"]
            <*> json <||? ["info", "images", "poster"]
            <*> json <|? ["info", "imdb"]
            <*> json <|? ["info", "plot"]
        
        let b = a
            <*> json <| ["info", "year"]
            <*> json <|? ["info", "runtime"]
            <*> json <|? ["info", "tagline"]
            <*> json <|? ["info", "mpaa"]
            <*> json <|| ["info", "genres"]
        
        
        let c = b
            <*> json <||? ["info", "images", "poster_original"]
            <*> json <||? ["info", "images", "backdrop"]
            <*> json <||? ["info", "images", "backdrop_original"]
            <*> .optional(json <| ["info", "images", "actors"] >>- { [String: String].decode($0) })
            <*> json <|? "status"
            <*> json <|? ["info", "in_wanted", "status"] <|> pure(nil)
        
        
        
        if let error = c.error {
            NSLog("### ERROR DECODING DISCOVERY MOVIE --> \(error.description)")
        }
        
        return c
    }

    let name: String
    let rating: [Float]?
    let postersUrls: [String]?
    let imdbId: String?
    let plot: String?
    let year: Int
    let length: Int?
    let tagline: String?
    let mpaa: String?
    let genres: [String]
    let postersOriginalUrls: [String]?
    let backdropsUrls: [String]?
    let backdropsOriginalUrls: [String]?
    let actorsWithPictures: [String: String]?
    let libraryStatus: String?
    let wantedStatus: String?

    var status: MovieStatus
    var mainPosterUrl: String? {

        if let urls = postersOriginalUrls, urls.count > 0 {
            return urls.first
        }

        if let urls = postersUrls, urls.count > 0 {
            return urls.first
        }

        return nil

    }

    init(name: String,
         rating: [Float]?,
         postersUrls: [String]?,
         imdbId: String?,
         plot: String?,
         year: Int,
         length: Int?,
         tagline: String?,
         mpaa: String?,
         genres: [String],
         postersOriginalUrls: [String]?,
         backdropsUrls: [String]?,
         backdropsOriginalUrls: [String]?,
         actors: [String: String]?,
         libraryStatus: String?,
         wantedStatus: String?) {
        
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

        self.status = MovieStatus.statusFromLibraryStatus(ls: libraryStatus, andWantedStatus: wantedStatus)
    }

}

class DiscoveryMovie: Movie, Decodable {
    
    public static func decode(_ json: JSON) -> Decoded<DiscoveryMovie> {
        let a = curry(DiscoveryMovie.init)
            <^> json <| "title"
            <*> json <||? ["info", "rating", "imdb"]
            <*> json <||? ["info", "images", "poster"]
            <*> json <|? ["info", "imdb"]
            <*> json <|? ["info", "plot"]
        
        let b = a
            <*> json <| ["info", "year"]
            <*> json <|? ["info", "runtime"]
            <*> json <|? ["info", "tagline"]
            <*> json <|? ["info", "mpaa"]
            <*> json <|| ["info", "genres"]
        
        
        let c = b
            <*> json <||? ["info", "images", "poster_original"]
            <*> json <||? ["info", "images", "backdrop"]
            <*> json <||? ["info", "images", "backdrop_original"]
            <*> .optional(json <| ["info", "images", "actors"] >>- { [String: String].decode($0) })
            <*> json <|? "status"
            <*> json <|? ["info", "in_wanted", "status"] <|> pure(nil)
        
        
        
        if let error = c.error {
            NSLog("### ERROR DECODING DISCOVERY MOVIE --> \(error.description)")
        }
        
        return c
    }

    
    
}

class SearchMovie: Movie, Decodable {

    public static func decode(_ j: JSON) -> Decoded<SearchMovie> {

        let a = curry(SearchMovie.init)
                <^> j <| "original_title"
                <*> j <||? ["rating", "imdb"]
                <*> j <||? ["images", "poster"]
                <*> j <|? "imdb"
                <*> j <|? "plot"

        let b = a
                <*> j <| "year"
                <*> j <|? "runtime"
                <*> j <|? "tagline"
                <*> j <|? "mpaa"
                <*> j <|| "genres"
                <*> j <||? ["images", "poster_original"]

        let c = b
                <*> j <||? ["images", "backdrop"]
                <*> j <||? ["images", "backdrop_original"]
                <*> .optional(j <| ["images", "actors"] >>- {
            [String: String].decode($0)
        })
                <*> j <|? ["in_library", "status"]
                <*> j <|? ["in_wanted", "status"]


        if let error = c.error {
            NSLog("### ERROR DECODING SEARCH MOVIE --> \(error.description)")
        }

        return c
    }
}

struct MovieSearchWrapper: Decodable {


    let movies: [SearchMovie]

    public static func decode(_ json: JSON) -> Decoded<MovieSearchWrapper> {
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
