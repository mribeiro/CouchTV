//
//  DiscoveryCategory.swift
//  CouchTV
//
//  Created by Antonio Ribeiro on 16/04/16.
//  Copyright © 2016 Antonio Ribeiro. All rights reserved.
//

import Argo
import Curry
import Foundation
import Runes

class DiscoveryCategory {
    
    var name: String?
    var movies: [DiscoveryMovie]?
    
    init(name: String?, movies: [DiscoveryMovie]?) {
        self.name = name
        self.movies = movies
    }
}

class Suggestions: DiscoveryCategory, Decodable {
    public static func decode(_ j: JSON) -> Decoded<Suggestions> {
        return curry(Suggestions.init)
            <^> j <|? "categoryName"
            <*> j <||? "movies"
    }
}

class Chart: DiscoveryCategory, Decodable {
    
    public static func decode(_ j: JSON) -> Decoded<Chart> {
        return curry(Chart.init)
            <^> j <|? "name"
            <*> j <||? "list"
    }
}

struct ChartsWrapper: Decodable {
    var charts: [Chart]

    static func decode(_ j: JSON) -> Decoded<ChartsWrapper> {
        return curry(ChartsWrapper.init)
            <^> j <|| "charts"
    }
    
}
