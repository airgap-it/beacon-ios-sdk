//
//  AccountControllerStore.swift
//  
//
//  Created by Julia Samol on 11.08.22.
//

import Foundation
import BeaconCore

extension AccountController {
    
    class Store: StoreBox<Store.Associated> {
        
        init(storageManager: StorageManager) {
            super.init(store: .init(storageManager: storageManager))
        }
        
        // MARK: Associated
        
        class Associated: StoreProtocol {
            typealias State = Store.State
            typealias Action = Store.Action
            
            private var state: State? = nil
            
            private let storageManager: StorageManager
            
            init(storageManager: StorageManager) {
                self.storageManager = storageManager
            }
            
            // MARK: Initialization
            
            private func createState(completion: @escaping (Result<State, Swift.Error>) -> ()) {
                storageManager.getActiveAccount { accountResult in
                    guard let activeAccount = accountResult.get(ifFailure: completion) else { return }
                    self.storageManager.getActivePeer(orDefault: activeAccount?.peerID) { peerIDResult in
                        guard let activePeerID = peerIDResult.get(ifFailure: completion) else { return }
                        self.storageManager.findActivePeer(id: activePeerID) { peerResult in
                            guard let activePeer = peerResult.get(ifFailure: completion) else { return }
                            
                            completion(.success(.init(
                                activeAccount: activeAccount,
                                activePeer: activePeer
                            )))
                        }
                        
                    }
                }
            }
            
            // MARK: State
            
            func state(completion: @escaping (Result<State, Swift.Error>) -> ()) {
                withState(completion)
            }
            
            func intent(action: Action, completion: @escaping (Result<(), Swift.Error>) -> ()) {
                switch action {

                case let .onPeerPaired(peer):
                    onPeerPaired(peer, completion: completion)
                case let .onPeerRemoved(peer):
                    onPeerRemoved(peer, completion: completion)
                case .resetActivePeer:
                    resetActivePeer(completion: completion)
                case let .onNewActiveAccount(account):
                    onNewActiveAccount(account, completion: completion)
                case .resetActiveAccount:
                    resetActiveAccount(completion: completion)
                case .hardReset:
                    resetHard(completion: completion)
                }
            }
            
            private func withState(_ callback: @escaping (Result<State, Swift.Error>) -> ()) {
                guard let state = state else {
                    createState { result in
                        guard let state = result.get(ifFailure: callback) else { return }
                        self.state = state
                        callback(.success(state))
                    }
                    return
                }
                
                callback(.success(state))
            }
            
            // MARK: Action Handlers
            
            private func onPeerPaired(_ peer: Beacon.Peer, completion: @escaping (Result<(), Swift.Error>) -> ()) {
                withState {
                    guard let state = $0.get(ifFailure: completion) else { return }
                    
                    self.getAndUpdateActivePeer(activePeer: state.activePeer, newPeer: peer) { result in
                        guard let activePeer = result.get(ifFailure: completion) else { return }
                        self.state = .init(from: state, activePeer: activePeer)
                        completion(.success(()))
                    }
                }
            }
            
            private func onPeerRemoved(_ peer: Beacon.Peer, completion: @escaping (Result<(), Swift.Error>) -> ()) {
                withState {
                    guard let state = $0.get(ifFailure: completion) else { return }
                    
                    if peer.publicKey == state.activePeer?.publicKey {
                        self.resetHard(completion: completion)
                    } else {
                        completion(.success(()))
                    }
                }
            }
            
            private func resetActivePeer(completion: @escaping (Result<(), Swift.Error>) -> ()) {
                withState {
                    guard let state = $0.get(ifFailure: completion) else { return }
                    
                    self.storageManager.removeActivePeer { result in
                        guard result.isSuccess(else: completion) else { return }
                        self.state = .init(from: state, activePeer: nil)
                        completion(.success(()))
                    }
                }
            }
            
            private func onNewActiveAccount(_ account: PairedAccount, completion: @escaping (Result<(), Swift.Error>) -> ()) {
                withState {
                    guard let state = $0.get(ifFailure: completion) else { return }
                    
                    if account.peerID == state.activePeer?.publicKey {
                        self.storageManager.setActiveAccount(account) {
                            guard $0.isSuccess(else: completion) else { return }
                            
                            self.state = .init(from: state, activeAccount: account)
                            completion(.success(()))
                        }
                    } else {
                        self.storageManager.setActiveAccount(account) { setResult in
                            guard setResult.isSuccess(else: completion) else { return }
                            
                            self.storageManager.findActivePeer(id: account.peerID) { findResult in
                                guard let foundPeer = findResult.get(ifFailure: completion) else { return }
                                
                                self.getAndUpdateActivePeer(activePeer: state.activePeer, newPeer: foundPeer) { updateResult in
                                    guard let activePeer = updateResult.get(ifFailure: completion) else { return }
            
                                    self.state = .init(from: state, activeAccount: account, activePeer: activePeer)
                                    completion(.success(()))
                                }
                            }
                        }
                    }
                }
            }
            
            private func resetActiveAccount(completion: @escaping (Result<(), Swift.Error>) -> ()) {
                withState {
                    guard let state = $0.get(ifFailure: completion) else { return }
                    
                    self.storageManager.removeActiveAccount { result in
                        guard result.isSuccess(else: completion) else { return }
                        self.state = .init(from: state, activeAccount: nil)
                        completion(.success(()))
                    }
                }
            }
            
            private func resetHard(completion: @escaping (Result<(), Swift.Error>) -> ()) {
                storageManager.removeActiveAccount { removeAccountResult in
                    guard removeAccountResult.isSuccess(else: completion) else { return }
                    self.storageManager.removeActivePeer { removePeerResult in
                        guard removePeerResult.isSuccess(else: completion) else { return }
                        self.state = nil
                        completion(.success(()))
                    }
                }
            }
            
            private func getAndUpdateActivePeer(activePeer: Beacon.Peer?, newPeer: Beacon.Peer?, completion: @escaping (Result<Beacon.Peer?, Swift.Error>) -> ()) {
                guard activePeer?.publicKey != newPeer?.publicKey else {
                    completion(.success(activePeer))
                    return
                }
                
                storageManager.setActivePeer(newPeer?.publicKey) { setResult in
                    guard setResult.isSuccess(else: completion) else { return }
                    self.storageManager.findActivePeer(id: newPeer?.id) { findResult in
                        guard let newActivePeer = findResult.get(ifFailure: completion) else { return }
                        
                        if let newActivePeer = newActivePeer {
                            completion(.success(newActivePeer))
                        } else if let newPeer = newPeer {
                            self.storageManager.add([newPeer]) { addResult in
                                completion(.success(newPeer))
                            }
                        } else {
                            completion(.success(nil))
                        }
                    }
                }
            }
        }
    }
}

private extension StorageManager {
    
    func getActivePeer(orDefault defaultID: String?, completion: @escaping (Result<String?, Swift.Error>) -> ()) {
        getActivePeer { getResult in
            guard let activePeer = getResult.get(ifFailure: completion) else { return }
            guard let defaultID = defaultID else {
                completion(.success(activePeer))
                return
            }
            
            if activePeer == defaultID {
                completion(.success(activePeer))
            } else {
                self.setActivePeer(defaultID) { setResult in
                    guard setResult.isSuccess(else: completion) else { return }
                    completion(.success(defaultID))
                }
            }
        }
    }
    
    func findActivePeer(id: String?, completion: @escaping (Result<Beacon.Peer?, Swift.Error>) -> ()) {
        guard let id = id else {
            completion(.success(nil))
            return
        }
        
        findPeers(where: { $0.publicKey == id }, completion: completion)
    }
}
