//
//  P2PMatrixStore.swift
//  
//
//  Created by Julia Samol on 26.08.21.
//

import Foundation
import BeaconCore

extension Transport.P2P.Matrix {
    
    class Store: StoreBox<Store.Associated> {
        
        init(
            app: Beacon.Application,
            communicator: Communicator,
            matrixClient: MatrixClient,
            matrixNodes: [String],
            storageManager: StorageManager,
            migration: Migration
        ) {
            super.init(
                store: .init(
                    app: app,
                    communicator: communicator,
                    matrixClient: matrixClient,
                    matrixNodes: matrixNodes,
                    storageManager: storageManager,
                    migration: migration
                )
            )
        }
        
        // MARK: Associated
        
        class Associated: StoreProtocol {
            typealias State = Store.State
            typealias Action = Store.Action
            
            private var state: State? = nil
            
            private let app: Beacon.Application
            private let communicator: Communicator
            private let matrixClient: MatrixClient
            private let matrixNodes: [String]
            private let storageManager: StorageManager
            private let migration: Migration
            
            init(
                app: Beacon.Application,
                communicator: Communicator,
                matrixClient: MatrixClient,
                matrixNodes: [String],
                storageManager: StorageManager,
                migration: Migration
            ) {
                self.app = app
                self.communicator = communicator
                self.matrixClient = matrixClient
                self.matrixNodes = matrixNodes
                self.storageManager = storageManager
                self.migration = migration
            }
            
            // MARK: Initialization
            
            private func createState(completion: @escaping (Result<State, Swift.Error>) -> ()) {
                findRelayServer { relayServerResult in
                    guard let relayServer = relayServerResult.get(ifFailure: completion) else { return }
                    let state = State(relayServer: relayServer, availableNodes: self.matrixNodes.count)

                    completion(.success(state))
                }
            }
            
            private func findRelayServer(completion: @escaping (Result<String, Swift.Error>) -> ()) {
                migration.migrateMatrixRelayServer(withNodes: matrixNodes) { migrationResult in
                    guard migrationResult.isSuccess(else: completion) else { return }
                    
                    self.storageManager.getMatrixRelayServer { relayServerResult in
                        guard let relayServer = relayServerResult.get(ifFailure: completion) else { return }
                        if let relayServer = relayServer {
                            completion(.success(relayServer))
                            return
                        }

                        let offset = self.app.publicKeyIndex(limitedBy: self.matrixNodes.count)
                        self.getUpRelayServer(fromNodes: self.matrixNodes.shifted(by: offset), completion: completion)
                    }
                }
            }
            
            private func getUpRelayServer(fromNodes matrixNodes: [String], completion: @escaping (Result<String, Swift.Error>) -> ()) {
                guard let next = matrixNodes.first else {
                    completion(.failure(Error.unreachableNodes))
                    return
                }
                
                matrixClient.isUp(next) { result in
                    guard let isUp = result.get(ifFailure: completion) else { return }
                    guard isUp else {
                        self.getUpRelayServer(fromNodes: Array(matrixNodes.dropFirst()), completion: completion)
                        return
                    }
                    
                    completion(.success(next))
                }
            }
            
            // MARK: State
            
            func state(completion: @escaping (Result<State, Swift.Error>) -> ()) {
                withState(completion)
            }
            
            func intent(action: Action, completion: @escaping (Result<(), Swift.Error>) -> ()) {
                switch action {
                case let .onChannelCreated(recipient, channelID):
                    onChannelCreated(to: recipient, onChannel: channelID, completion: completion)
                case let .onChannelEvent(sender, channelID):
                    onChannelEvent(from: sender, onChannel: channelID, completion: completion)
                case let .onChannelClosed(channelID):
                    onChannelClosed(channelID, completion: completion)
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
            
            private func onChannelCreated(to recipient: String, onChannel channelID: String, completion: @escaping (Result<(), Swift.Error>) -> ()) {
                onActiveChannelUpdate(user: recipient, channelID: channelID, completion: completion)
            }
            
            private func onChannelEvent(
                from sender: String,
                onChannel channelID: String,
                completion: @escaping (Result<(), Swift.Error>) -> ()
            ) {
                updatePeerRelayServer(forSender: sender) { updatePeerResult in
                    guard updatePeerResult.isSuccess(else: completion) else { return }
                    self.onActiveChannelUpdate(user: sender, channelID: channelID, completion: completion)
                }
            }
            
            private func onChannelClosed(_ channelID: String, completion: @escaping (Result<(), Swift.Error>) -> ()) {
                withState { stateResult in
                    guard let state = stateResult.get(ifFailure: completion) else { return }
                    
                    let activeChannels = state.activeChannels.filter { $0.value != channelID }
                    let inactiveChannels = state.inactiveChannels.union([channelID])
                    
                    self.storageManager.setMatrixChannels(activeChannels) { setChannelsResult in
                        guard setChannelsResult.isSuccess(else: completion) else { return }

                        if state.activeChannels != activeChannels || state.inactiveChannels != inactiveChannels {
                            self.state = .init(from: state, activeChannels: activeChannels, inactiveChannels: inactiveChannels)
                        }

                        completion(.success(()))
                    }
                }
            }
            
            private func resetHard(completion: @escaping (Result<(), Swift.Error>) -> ()) {
                storageManager.removeMatrixRelayServer { relayServerResult in
                    guard relayServerResult.isSuccess(else: completion) else { return }
                    self.storageManager.removeMatrixChannels { channelsResult in
                        guard channelsResult.isSuccess(else: completion) else { return }
                        self.state = nil
                        completion(.success(()))
                    }
                }
            }
            
            private func onActiveChannelUpdate(user: String, channelID: String, completion: @escaping (Result<(), Swift.Error>) -> ()) {
                withState { stateResult in
                    guard let state = stateResult.get(ifFailure: completion) else { return }
                    self.updateActiveChannels(forUser: user, withChannel: channelID, withState: state) { channelsResult in
                        guard let (activeChannels, inactiveChannels) = channelsResult.get(ifFailure: completion) else { return }
                    
                        if state.activeChannels != activeChannels || state.inactiveChannels != inactiveChannels {
                            self.state = .init(from: state, activeChannels: activeChannels, inactiveChannels: inactiveChannels)
                        }
                        
                        completion(.success(()))
                    }
                }
            }
            
            private func updateActiveChannels(
                forUser user: String,
                withChannel channelID: String,
                withState state: State,
                completion: @escaping (Result<([String: String], Set<String>), Swift.Error>) -> ()
            ) {
                let assignedChannel = state.activeChannels[user]
                if assignedChannel == channelID {
                    completion(.success((state.activeChannels, state.inactiveChannels.subtracting([channelID]))))
                    return
                }
                
                let activeChannels = state.activeChannels.merging([user: channelID], uniquingKeysWith: { old, new in new })
                let inactiveChannels = state.inactiveChannels.union([assignedChannel].compactMap { $0 }).subtracting([channelID])
                
                storageManager.setMatrixChannels(activeChannels) { result in
                    guard result.isSuccess(else: completion) else { return }
                    completion(.success((activeChannels, inactiveChannels)))
                }
            }
            
            private func updatePeerRelayServer(
                forSender sender: String,
                completion: @escaping (Result<(), Swift.Error>) -> ()
            ) {
                guard let senderIdentifier = try? Transport.P2P.Identifier(fromValue: sender) else {
                    completion(.success(()))
                    return
                }
                
                storageManager.findPeers(
                    where: {
                        do {
                            guard let peer = $0.asP2PPeer() else {
                                return false
                            }
                            
                            let peerIdentifier = try self.communicator.recipientIdentifier(
                                for: try HexString(from: peer.publicKey).asBytes(),
                                on: peer.relayServer
                            )
                            
                            let publicKeysMatch = peerIdentifier.publicKeyHash == senderIdentifier.publicKeyHash
                            let relayServersMatch = peerIdentifier.relayServer == senderIdentifier.relayServer
                            
                            return publicKeysMatch && !relayServersMatch
                        } catch {
                            return false
                        }
                    }
                ) { result in
                    guard let peerOrNil = result.get(ifFailure: completion) else { return }
                    guard let peer = peerOrNil?.asP2PPeer() else {
                        completion(.success(()))
                        return
                    }
                    
                    self.storageManager.add(
                        [.p2p(.init(from: peer, relayServer: senderIdentifier.relayServer))],
                        overwrite: true,
                        compareBy: { lhs, rhs in lhs.publicKey == rhs.publicKey },
                        completion: completion
                    )
                }
            }
            
            // MARK: Types
            
            enum Error: Swift.Error {
                case unreachableNodes
            }
        }
    }
}

// MARK: Extensions

private extension Beacon.Application {
    func publicKeyIndex(limitedBy boundary: Int) -> Int {
        keyPair.publicKey.reduce(0) { acc, byte in (acc + Int(byte)) % boundary }
    }
}

private extension Beacon.Peer {
    func asP2PPeer() -> Beacon.P2PPeer? {
        switch self {
        case let .p2p(peer):
            return peer
        }
    }
}
