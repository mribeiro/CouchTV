//
//  CPConnectionTests.swift
//  CouchTV
//
//  Created by Antonio Ribeiro on 20/04/16.
//  Copyright © 2016 Antonio Ribeiro. All rights reserved.
//

import XCTest
import Alamofire
import Argo

class CPConnectionTests: XCTestCase {
    
    var preferences = PreferencesProviderManager.instance
    let provider = CouchPotatoMovieProvider()
    
    override func setUp() {
        super.setUp()
        preferences.rootUrl = NSURL(string: "http://192.168.1.200:5050/cp")
        preferences.apiKey = "d55fb3c8feae47048d7e6229be94dbeb"
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testConnectivity() {
        
        let asyncExpectation = expectationWithDescription("longRunningFunction")
        
        var bool: Bool = false
        
        provider.testConnection { _bool in
            bool = _bool
            asyncExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(30) { error in
            XCTAssertTrue(bool)
        }
    }
    
    func testSearch() {
        let asyncExpectation = expectationWithDescription("longRunningFunction")
        
        var movies: [Movie]?
        
        provider.search("the") { p in
            movies = p
            asyncExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(30) { error in
            XCTAssertNotNil(movies)
        }
    }
    
    func testAdd() {
        let imdbId = "tt0111161" //The Shawshank Redemption
        
        let asyncExpectation = expectationWithDescription("longRunningFunction")
        
        var bool = false
        
        provider.fetchMovie(imdbId) { _bool in
            bool = _bool
            asyncExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(30) { error in
            XCTAssertTrue(bool)
        }
        
    }
    
    func testDiscovery() {
        let asyncExpectation = expectationWithDescription("longRunningFunction")
        var categories: [DiscoveryCategory]?
        
        provider.getDiscovery { _categories in
            categories = _categories
            asyncExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(30) { error in
            XCTAssertNotNil(categories)
        }
        
    }
    
}
