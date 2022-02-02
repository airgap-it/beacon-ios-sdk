//
//  P2P.swift
//
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

public extension Transport {
    
    class P2P: Transport {
        init(client: P2PClient, storageManager: StorageManager) {
            let wrapped = Wrapped(client: client, storageManager: storageManager)
            super.init(kind: .p2p, wrapped: wrapped)
            
            wrapped.owner = self
        }
        
        // MARK: Wrapped
        
        class Wrapped: TransportProtocol {
            private let client: P2PClient
            private let storageManager: StorageManager
            
            weak var owner: P2P?
            
            init(client: P2PClient, storageManager: StorageManager) {
                self.client = client
                self.storageManager = storageManager
            }
            
            func start(completion: @escaping (Result<(), Swift.Error>) -> ()) {
                client.start { [weak self] result in
                    guard result.isSuccess(else: completion) else { return }
                    guard let selfStrong = self else {
                        completion(.failure(Beacon.Error.unknown))
                        return
                    }
                    
                    selfStrong.connectWithKnownPeers(completion: completion)
                }
            }
            
            func stop(completion: @escaping (Result<(), Swift.Error>) -> ()) {
                client.stop(completion: completion)
            }
            
            func pause(completion: @escaping (Result<(), Swift.Error>) -> ()) {
                client.pause(completion: completion)
            }
            
            func resume(completion: @escaping (Result<(), Swift.Error>) -> ()) {
                client.resume(completion: completion)
            }
            
            func connect(new peers: [Beacon.Peer], completion: @escaping (Result<[Beacon.Peer], Swift.Error>) -> ()) {
                let p2pPeers: [Beacon.P2PPeer] = peers.filterP2P()

                p2pPeers.forEachAsync(
                    body: {
                        self.client.sendPairingResponse(to: $0, completion: $1)
                    }
                ) { results in
                    guard results.allSatisfy({ $0.isSuccess }) else {
                        let (notPaired, errors) = results.enumerated()
                            .map { (index, result) in (Beacon.Peer.p2p(p2pPeers[index]), result.error) }
                            .filter { (_, error) in error != nil }
                            .unzip()
                        
                        completion(.failure(Beacon.Error.peersNotPaired(notPaired, causedBy: errors.compactMap { $0 })))
                        return
                    }

                    self.listen(to: p2pPeers) { result in
                        guard result.isSuccess(else: completion) else { return }
                        completion(.success(p2pPeers.map { .p2p($0) }))
                    }
                }
            }
            
            func disconnect(from peers: [Beacon.Peer], completion: @escaping (Result<[Beacon.Peer], Swift.Error>) -> ()) {
                do {
                    let p2pPeers = peers.filterP2P()
                    try p2pPeers.forEach { try client.removeListener(for: $0) }
                    
                    completion(.success(p2pPeers.map { .p2p($0) }))
                } catch {
                    completion(.failure(error))
                }
            }
            
            func send(_ message: SerializedConnectionMessage, completion: @escaping (Result<(), Swift.Error>) -> ()) {
                storageManager.findPeers(where: { $0.publicKey == message.origin.id }) { result in
                    guard let found = result.get(ifFailure: completion) else { return }
                    guard let peer = found else {
                        completion(.failure(Error.unknownRecipient))
                        return
                    }
                    
                    switch peer {
                    case let .p2p(p2pPeer):
                        switch message.origin.kind {
                        case .p2p:
                            self.send(message.content, to: p2pPeer, completion: completion)
                        }
                    }
                }
            }
            
            private func connectWithKnownPeers(completion: @escaping (Result<(), Swift.Error>) -> ()) {
                storageManager.getPeers { result in
                    guard let peers = result.get(ifFailure: completion) else { return }
                    
                    self.listen(to: peers.filterP2P(), completion: completion)
                }
            }
            
            private func listen(to peers: [Beacon.P2PPeer], completion: @escaping (Result<(), Swift.Error>) -> ()) {
                do {
                    try peers.forEach { try self.listen(to: $0) }
                    completion(.success(()))
                } catch {
                    completion(.failure(error))
                }
            }
            
            private func listen(to peer: Beacon.P2PPeer) throws {
                try client.listen(to: peer) { [weak self] result in
                    let message: Result<SerializedConnectionMessage, Swift.Error> = result.map {
                        SerializedConnectionMessage(origin: .p2p(id: peer.publicKey), content: $0)
                        
                    }
                    self?.owner?.notify(with: message)
                }
            }
            
            private func send(_ message: String, to recipient: Beacon.P2PPeer, completion: @escaping (Result<(), Swift.Error>) -> ()) {
                self.client.send(message: message, to: recipient, completion: completion)
            }
        }
        
        // MARK: Types
        
        enum Error: Swift.Error {
            case unknownRecipient
        }
    }
}

// MARK: Extensions

private extension Array where Element == Beacon.Peer {
    
    func filterP2P() -> [Beacon.P2PPeer] {
        compactMap {
            switch $0 {
            case let .p2p(peer):
                return peer
            }
        }
    }
}
