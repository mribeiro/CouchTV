//
//  CPConnectionTests.swift
//  CouchTV
//
//  Created by Antonio Ribeiro on 20/04/16.
//  Copyright © 2016 Antonio Ribeiro. All rights reserved.
//

import XCTest
import Moya
import Foundation
import Alamofire
import Argo

class CPConnectionTests: XCTestCase {
    
    var preferences = PreferencesProviderManager.instance
    let provider = CouchPotatoMovieProvider()
    
    override func setUp() {
        super.setUp()
        preferences.rootUrl = URL(string: "http://192.168.1.200:5050/cp")
        preferences.apiKey = "d55fb3c8feae47048d7e6229be94dbeb"
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testConnectivityWithMoya() {
        
        let cp = MoyaProvider<CouchPotatoService>()
        cp.request(.getCPVersion) { result in
            switch result {
            case .success(let moyaResponse):
                XCTAssertEqual(moyaResponse.statusCode, 200)
                
            case .failure( _):
                print("")
            }
        }
        
    }
    
    func testGetKeyWithMoya() {
        
        let asyncExpectation = expectation(description: "longRunningFunction")
        
        self.provider.getKey(username: "", password: "") { (key) in
            XCTAssertEqual(key, "d55fb3c8feae47048d7e6229be94dbeb")
            asyncExpectation.fulfill()
        }
                
        waitForExpectations(timeout: 30)
        
    }
    
    func testConnectivity() {
        
        let asyncExpectation = expectation(description: "longRunningFunction")
        
        var bool: Bool = false
        
        provider.testConnection { _bool in
            bool = _bool
            asyncExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 30) { error in
            XCTAssertTrue(bool)
        }
    }
    
    func testSearch() {
        let asyncExpectation = expectation(description: "longRunningFunction")
        
        var movies: [Movie]?
        
        provider.search(searchTerm  : "the") { p in
            movies = p
            asyncExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 30) { error in
            XCTAssertNotNil(movies)
        }
    }
    
    func testAdd() {
        let imdbId = "tt0111161" //The Shawshank Redemption
        
        let asyncExpectation = expectation(description: "longRunningFunction")
        
        var bool = false
        
        provider.fetchMovie(imdbId: imdbId) { _bool in
            bool = _bool
            asyncExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 30) { error in
            XCTAssertTrue(bool)
        }
        
    }
    
    func testDiscovery() {
        let asyncExpectation = expectation(description: "longRunningFunction")
        
        provider.getDiscovery { _categories in
            XCTAssertNotNil(_categories)
            asyncExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 30) { error in
            XCTAssertTrue(error == nil, "Did not get categories in time")
        }
    }
    
}
