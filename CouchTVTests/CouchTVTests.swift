//
//  CouchTVTests.swift
//  CouchTVTests
//
//  Created by Antonio Ribeiro on 17/04/16.
//  Copyright © 2016 Antonio Ribeiro. All rights reserved.
//

import XCTest
import Alamofire
import Argo

class CouchTVTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func openAndReadFile(fileName: String, ofType: String, callback: (AnyObject)->()) {
        if let path = Bundle.main.path(forResource: fileName, ofType: ofType) {
            
            if let jsonData = NSData(contentsOfFile: path) {
                
                if let json = try? JSONSerialization.jsonObject(with: jsonData as Data, options: []) {
                    
                    callback(json as AnyObject)
                    
                } else {
                    XCTAssertThrowsError("Not possible to parse JSON from \(fileName).\(ofType)")
                }
            } else {
                XCTAssertThrowsError("No data from \(fileName).\(ofType)")
            }
        } else {
            XCTAssertThrowsError("Not possible to open \(fileName).\(ofType)")
        }
    }
    
    func testSearchParse() {
        
        openAndReadFile(fileName: "search_sample", ofType: "json") { json in
            let j = JSON(json)
            let searchWrapper = MovieSearchWrapper.decode(j).value
            
            XCTAssertNotNil(searchWrapper?.movies)
        }
    }
    
    func testChartsParse() {
        
        openAndReadFile(fileName: "charts_sample", ofType: "json") { json in
            var chartsWrapper: ChartsWrapper?
            
            let j = JSON(json)
            chartsWrapper = ChartsWrapper.decode(j).value
            print(chartsWrapper ?? "No charts wrapper gotten")
            
            if let charts = chartsWrapper?.charts {
                
                XCTAssertEqual(charts.count, 5)
                
                var discover = charts[0]
                XCTAssertEqual(discover.name, "IMDB - Top 250 Movies")
                XCTAssertEqual(discover.movies?.count, 0)
                
                discover = charts[1]
                XCTAssertEqual(discover.name, "IMDB - Top DVD rentals")
                XCTAssertEqual(discover.movies?.count, 6)
                
                let movie: Movie? = discover.movies?[0]
                XCTAssertNotNil(movie)
                XCTAssertEqual(movie?.name, "The Boss")
                XCTAssertEqual(movie?.imdbId, "tt2702724")
                //XCTAssertEqual(movie?.posterUrl.first, "https://image.tmdb.org/t/p/original/do3LVHQTIweDKX2vfH8RyeGvg8x.jpg")
                XCTAssertEqual(movie?.rating?.first, 5.1)
            }
        }
    }
    
    func testSuggestionParse() {
        
        openAndReadFile(fileName: "suggestions_example", ofType: "json") { json in
            var category: DiscoveryCategory?
            
            let j = JSON(json)
            let _disc = Suggestions.decode(j)
            category = _disc.value
            
            category?.name = "Suggestions"
            print(category ?? "No category received")
            
            XCTAssertNotNil(category?.movies)
            
            var movie = category?.movies?[0]
            XCTAssertEqual(category?.movies?.count, 6)
            XCTAssertEqual(movie?.name, "The Witch")
            XCTAssertEqual(movie?.imdbId, "tt4263482")
            XCTAssertEqual(movie?.rating?.first, 7.3)
            //XCTAssertEqual(movie?.posterUrl.first, "https://image.tmdb.org/t/p/original/jfGsfzq5JrMAKbAOV2TmhsOs3tf.jpg")
            
            movie = category?.movies?[1]
            XCTAssertEqual(movie?.name, "My Big Fat Greek Wedding 2")
            XCTAssertEqual(movie?.imdbId, "tt3760922")
            XCTAssertEqual(movie?.rating?.first, 6.3)
            //XCTAssertEqual(movie?.posterUrl.first, "https://image.tmdb.org/t/p/original/gN7Su6RP9zDXJigHGyGLnRaWqsb.jpg")
            
            movie = category?.movies?[2]
            XCTAssertEqual(movie?.name, "Miracles from Heaven")
            XCTAssertEqual(movie?.imdbId, "tt4257926")
            XCTAssertEqual(movie?.rating?.first, 6.5)
            //XCTAssertEqual(movie?.posterUrl.first, "https://image.tmdb.org/t/p/original/3sPIq0Uqe8SN5T0Pq7vUOFLb2Bk.jpg")
            
            movie = category?.movies?[3]
            XCTAssertEqual(movie?.name, "Whiskey Tango Foxtrot")
            XCTAssertEqual(movie?.imdbId, "tt3553442")
            XCTAssertEqual(movie?.rating?.first, 7)
            //XCTAssertEqual(movie?.posterUrl.first, "https://image.tmdb.org/t/p/original/22G22rdZsMDO7khe4Ue3G2uwOaw.jpg")
            
            movie = category?.movies?[4]
            XCTAssertEqual(movie?.name, "Concussion")
            XCTAssertEqual(movie?.imdbId, "tt3322364")
            XCTAssertEqual(movie?.rating?.first, 7.1)
            //XCTAssertEqual(movie?.posterUrl.first, "https://image.tmdb.org/t/p/original/vdK1f9kpY5QEwrAiXs9R7PlerNC.jpg")
            
            movie = category?.movies?[5]
            XCTAssertEqual(movie?.name, "Risen")
            XCTAssertEqual(movie?.imdbId, "tt3231054")
            XCTAssertEqual(movie?.rating?.first, 6.8)
            //XCTAssertEqual(movie?.posterUrl.first, "https://image.tmdb.org/t/p/original/cr8lQd94bxlhyDfimweUMnLZoxf.jpg")
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
