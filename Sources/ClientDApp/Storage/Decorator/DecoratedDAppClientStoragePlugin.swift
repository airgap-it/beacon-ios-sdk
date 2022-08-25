//
//  DecoratedDAppClientStoragePlugin.swift
//  
//
//  Created by Julia Samol on 11.08.22.
//

import Foundation
import BeaconCore

struct DecoratedDAppClientStoragePlugin: ExtendedDAppClientStoragePlugin {
    private let storagePlugin: DAppClientStoragePlugin
    
    init(storagePlugin: DAppClientStoragePlugin) {
        self.storagePlugin = storagePlugin
    }
    
    // MARK: Account
    
    func getActiveAccount(completion: @escaping (Result<PairedAccount?, Error>) -> ()) {
        storagePlugin.getActiveAccount(completion: completion)
    }
    
    func setActiveAccount(_ account: PairedAccount?, completion: @escaping (Result<(), Error>) -> ()) {
        storagePlugin.setActiveAccount(account, completion: completion)
    }
    
    func removeActiveAccount(completion: @escaping (Result<(), Error>) -> ()) {
        storagePlugin.setActiveAccount(nil, completion: completion)
    }
    
    // MARK: Peer
    
    func getActivePeer(completion: @escaping (Result<String?, Error>) -> ()) {
        storagePlugin.getActivePeer(completion: completion)
    }
    
    func setActivePeer(_ peerID: String?, completion: @escaping (Result<(), Error>) -> ()) {
        storagePlugin.setActivePeer(peerID, completion: completion)
    }
    
    func removeActivePeer(completion: @escaping (Result<(), Error>) -> ()) {
        storagePlugin.setActivePeer(nil, completion: completion)
    }
}
