//
//  ApiKey.swift
//  CouchTV
//
//  Created by Antonio Ribeiro on 09/01/2017.
//  Copyright © 2017 Antonio Ribeiro. All rights reserved.
//

import Foundation
import Argo
import Runes
import Curry

struct ApiKey: Decodable {
    /**
     Decode an object from JSON.
     
     This is the main entry point for Argo. This function declares how the
     conforming type should be decoded from JSON. Since this is a failable
     operation, we need to return a `Decoded` type from this function.
     
     - parameter json: The `JSON` representation of this object
     
     - returns: A decoded instance of the `DecodedType`
     */
    public static func decode(_ json: JSON) -> Decoded<ApiKey> {
        return curry(ApiKey.init)
            <^> json <|? "api_key"
            <*> json <|  "success"
    }

    
    let apiKey: String?
    let success: Bool!
    
    init(withApiKey apiKey: String?, AndSuccess success:Bool) {
        self.apiKey = apiKey
        self.success = success
    }
    
    
    
    
    
}
