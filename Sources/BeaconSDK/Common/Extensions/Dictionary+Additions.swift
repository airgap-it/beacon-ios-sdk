//
//  Dictionary+Additions.swift
//  BeaconSDK
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Dictionary {
    
    mutating func getOrSet(_ key: Key, setter: () throws -> Value) rethrows -> Value {
        if let value = self[key] {
            return value
        } else {
            let value = try setter()
            self[key] = value
            
            return value
        }
    }
}
