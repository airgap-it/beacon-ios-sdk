//
//  Dictionary+Additions.swift
//
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

public extension Dictionary {
    
    mutating func get(_ key: Key, orSet setter: () throws -> Value) rethrows -> Value {
        if let value = self[key] {
            return value
        } else {
            let value = try setter()
            self[key] = value
            
            return value
        }
    }
    
    mutating func get(_ key: Key, orSetIfNotNil setter: () throws -> Value?) rethrows -> Value? {
        if let value = self[key] {
            return value
        } else {
            guard let value = try setter() else { return nil }
            self[key] = value
            
            return value
        }
    }
    
    mutating func getAndDispose(_ key: Key) -> Value? {
        guard let value = self[key] else { return nil }
        self.removeValue(forKey: key)
        
        return value
    }
    
    mutating func append<T>(forKey key: Key, element: T) where Value == Set<T> {
        self[key] = (self[key] ?? []).union([element])
    }
}
