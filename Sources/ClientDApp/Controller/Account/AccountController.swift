//
//  AccountController.swift
//  
//
//  Created by Julia Samol on 11.08.22.
//

import Foundation
import BeaconCore

class AccountController: AccountControllerProtocol {
    private let store: Store
    private let blockchainRegistry: BlockchainRegistryProtocol
    
    init(store: Store, blockchainRegistry: BlockchainRegistryProtocol) {
        self.store = store
        self.blockchainRegistry = blockchainRegistry
    }
    
    func onPairingResponse(_ pairingResponse: BeaconPairingResponse, completion: @escaping (Result<(), Error>) -> ()) {
        store.intent(action: .onPeerPaired(peer: pairingResponse.toPeer()), completion: completion)
    }
    
    func onPermissionResponse<B>(_ response: B.Response.Permission, ofType type: B.Type, origin: Beacon.Origin, completion: @escaping (Result<(), Error>) -> ()) where B : Blockchain {
        runCatching(completion: completion) {
            guard let blockchain: B = blockchainRegistry.get() else {
                throw Beacon.Error.blockchainNotFound(type.identifier)
            }
        
            blockchain.creator.extractAccounts(from: response) { result in
                guard let accounts = result.get(ifFailure: completion) else { return }
                let accountID = accounts.first // TODO: other selection criteria?
                if let account = Account(accountID: accountID, peerID: response.origin) {
                    self.store.intent(action: .onNewActiveAccount(account: account), completion: completion)
                } else {
                    completion(.success(()))
                }
            }
        }
    }
    
    func getActivePeer(completion: @escaping (Result<Beacon.Peer?, Error>) -> ()) {
        store.state {
            guard let state = $0.get(ifFailure: completion) else { return }
            completion(.success(state.activePeer))
        }
    }
    
    func getActiveAccountID(completion: @escaping (Result<String?, Error>) -> ()) {
        store.state {
            guard let state = $0.get(ifFailure: completion) else { return }
            completion(.success(state.activeAccount?.accountID))
        }
    }
    
    func clearActiveAccountID(completion: @escaping (Result<(), Error>) -> ()) {
        store.intent(action: .resetActiveAccount, completion: completion)
    }
    
    func clearAll(completion: @escaping (Result<(), Error>) -> ()) {
        store.intent(action: .hardReset, completion: completion)
    }
}

// MARK: Protocol

public protocol AccountControllerProtocol {
    func onPairingResponse(_ pairingResponse: BeaconPairingResponse, completion: @escaping (Result<(), Error>) -> ())
    func onPermissionResponse<B: Blockchain>(_ response: B.Response.Permission, ofType type: B.Type, origin: Beacon.Origin, completion: @escaping (Result<(), Error>) -> ())
    
    func getActivePeer(completion: @escaping (Result<Beacon.Peer?, Error>) -> ())
    func getActiveAccountID(completion: @escaping (Result<String?, Error>) -> ())
    func clearActiveAccountID(completion: @escaping (Result<(), Error>) -> ())
    func clearAll(completion: @escaping (Result<(), Error>) -> ())
}
