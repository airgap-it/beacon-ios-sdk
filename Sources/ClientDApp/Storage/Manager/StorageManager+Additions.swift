//
//  StorageManager+Additions.swift
//  
//
//  Created by Julia Samol on 11.08.22.
//

import Foundation
import BeaconCore

extension StorageManager {
    var dAppClientPlugin: DAppClientStoragePlugin? { plugins.first(where: { $0 is DAppClientStoragePlugin }) as? DAppClientStoragePlugin }
}

// MARK: ExtendedDAppClientStoragePlugin

extension StorageManager: ExtendedDAppClientStoragePlugin {
    
    private func extendedDAppClientStoragePlugin() throws -> ExtendedDAppClientStoragePlugin {
        guard let plugin = dAppClientPlugin else {
            throw Error.missingPlugin("DApp Client")
        }
        
        return plugin.extend()
    }
    
    public func getActiveAccount(completion: @escaping (Result<PairedAccount?, Swift.Error>) -> ()) {
        runCatching(completion: completion) {
            try extendedDAppClientStoragePlugin().getActiveAccount(completion: completion)
        }
    }
    
    public func setActiveAccount(_ account: PairedAccount?, completion: @escaping (Result<(), Swift.Error>) -> ()) {
        runCatching(completion: completion) {
            try extendedDAppClientStoragePlugin().setActiveAccount(account, completion: completion)
        }
    }
    
    public func removeActiveAccount(completion: @escaping (Result<(), Swift.Error>) -> ()) {
        runCatching(completion: completion) {
            try extendedDAppClientStoragePlugin().removeActiveAccount(completion: completion)
        }
    }
    
    public func getActivePeer(completion: @escaping (Result<String?, Swift.Error>) -> ()) {
        runCatching(completion: completion) {
            try extendedDAppClientStoragePlugin().getActivePeer(completion: completion)
        }
    }
    
    public func setActivePeer(_ peerID: String?, completion: @escaping (Result<(), Swift.Error>) -> ()) {
        runCatching(completion: completion) {
            try extendedDAppClientStoragePlugin().setActivePeer(peerID, completion: completion)
        }
    }
    
    public func removeActivePeer(completion: @escaping (Result<(), Swift.Error>) -> ()) {
        runCatching(completion: completion) {
            try extendedDAppClientStoragePlugin().removeActivePeer(completion: completion)
        }
    }
    
}
