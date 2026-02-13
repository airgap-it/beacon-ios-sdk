//
//  ExtendedDAppClientStorage.swift
//  
//
//  Created by Julia Samol on 11.08.22.
//

import Foundation
import OctezConnectCore

public protocol ExtendedDAppClientStorage: DAppClientStorage, ExtendedDAppClientStoragePlugin, ExtendedStorage {
    
}

extension ExtendedDAppClientStorage {
    func extend() -> ExtendedDAppClientStorage {
        self
    }
}
