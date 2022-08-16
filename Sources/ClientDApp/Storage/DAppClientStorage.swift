//
//  DAppClientStorage.swift
//  
//
//  Created by Julia Samol on 11.08.22.
//

import Foundation
import BeaconCore

public protocol DAppClientStorage: DAppClientStoragePlugin, Storage {
    
}

extension DAppClientStorage {
    func extend() -> ExtendedDAppClientStorage {
        if let extended = self as? ExtendedDAppClientStorage {
            return extended
        } else {
            return DecoratedDAppClientStorage(storage: self)
        }
    }
}
