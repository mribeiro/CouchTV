//
//  MovieList.swift
//  CouchTV
//
//  Created by Antonio Ribeiro on 18/03/2017.
//  Copyright © 2017 Antonio Ribeiro. All rights reserved.
//

import Argo
import Curry
import Foundation
import Runes

struct MovieList:Decodable {
    
    var movies: [DiscoveryMovie]?
    
    static func decode(_ json: JSON) -> Decoded<MovieList> {
        return curry(MovieList.init)
            <^> json <||? "movies"
    }
    
}
