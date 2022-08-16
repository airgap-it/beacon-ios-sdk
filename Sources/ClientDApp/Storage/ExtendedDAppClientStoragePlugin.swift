//
//  ExtendedDAppClientStoragePlugin.swift
//  
//
//  Created by Julia Samol on 11.08.22.
//

import Foundation

public protocol ExtendedDAppClientStoragePlugin: DAppClientStoragePlugin {
    
    // MARK: Account
    func removeActiveAccount(completion: @escaping (Result<(), Error>) -> ())
    
    // MARK: Peer
    
    func removeActivePeer(completion: @escaping (Result<(), Error>) -> ())
}

// MARK: Extensions

extension ExtendedDAppClientStoragePlugin {
    func extend() -> ExtendedDAppClientStoragePlugin {
        self
    }
}
