//
//  BaseResponse.swift
//  CouchTV
//
//  Created by Antonio Ribeiro on 19/03/2017.
//  Copyright © 2017 Antonio Ribeiro. All rights reserved.
//

import Foundation
import Runes
import Argo
import Curry

struct BaseResponse: Decodable {
    
    var result: Bool?
    
    static func decode(_ json: JSON) -> Decoded<BaseResponse> {
        return curry(BaseResponse.init)
            <^> json <|? "result"
    }
    
}
