//
//  Dictionary+Additions.swift
//  BeaconSDK
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Dictionary {
    
    mutating func get(_ key: Key, orSet setter: () throws -> Value) rethrows -> Value {
        if let value = self[key] {
            return value
        } else {
            let value = try setter()
            self[key] = value
            
            return value
        }
    }
    
    func get(_ key: Key, orDefault defaultValue: Value) -> Value {
        self[key] ?? defaultValue
    }
    
    mutating func append<T>(forKey key: Key, element: T) where Value == Set<T> {
        self[key] = (self[key] ?? []).union([element])
    }
}
