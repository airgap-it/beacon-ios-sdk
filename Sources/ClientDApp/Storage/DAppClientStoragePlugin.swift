//
//  DAppClientStoragePlugin.swift
//  
//
//  Created by Julia Samol on 11.08.22.
//

import Foundation
import BeaconCore

public protocol DAppClientStoragePlugin: StoragePlugin {
    
    // MARK: Account
    
    func getActiveAccount(completion: @escaping (Result<PairedAccount?, Error>) -> ())
    func setActiveAccount(_ account: PairedAccount?, completion: @escaping (Result<(), Error>) -> ())
    
    // MARK: Peer
    
    func getActivePeer(completion: @escaping (Result<String?, Error>) -> ())
    func setActivePeer(_ peerID: String?, completion: @escaping (Result<(), Error>) -> ())
}

// MARK: Extensions

extension DAppClientStoragePlugin {
    func extend() -> ExtendedDAppClientStoragePlugin {
        if let extended = self as? ExtendedDAppClientStoragePlugin {
            return extended
        } else {
            return DecoratedDAppClientStoragePlugin(storagePlugin: self)
        }
    }
}
