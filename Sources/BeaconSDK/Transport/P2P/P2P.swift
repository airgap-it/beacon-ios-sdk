//
//  P2P.swift
//  BeaconSDK
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Transport {
    
    class P2P: Transport {
        
        private let client: CommunicationClient
        private let storageManager: StorageManager
        
        init(client: CommunicationClient, storageManager: StorageManager) {
            self.client = client
            self.storageManager = storageManager
            super.init(kind: .p2p)
        }
        
        override func connect(new peers: [Beacon.Peer], completion: @escaping (Result<[Beacon.Peer], Swift.Error>) -> ()) {
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
        
        override func disconnect(from peers: [Beacon.Peer], completion: @escaping (Result<[Beacon.Peer], Swift.Error>) -> ()) {
            do {
                let p2pPeers = peers.filterP2P()
                try p2pPeers.forEach { peer in
                    client.removeListener(for: try HexString(from: peer.publicKey))
                }
                
                completion(.success(p2pPeers.map { .p2p($0) }))
            } catch {
                completion(.failure(error))
            }
        }
        
        override func start(completion: @escaping (Result<(), Swift.Error>) -> ()) {
            client.start { [weak self] result in
                guard result.isSuccess(else: completion) else { return }
                guard let selfStrong = self else {
                    completion(.failure(Beacon.Error.unknown))
                    return
                }
                
                selfStrong.connectWithKnownPeers(completion: completion)
            }
        }
        
        override func send(_ message: ConnectionMessage, completion: @escaping (Result<(), Swift.Error>) -> ()) {
            storageManager.findPeers(where: { $0.common.publicKey == message.common.origin.id }) { result in
                guard let found = result.get(ifFailure: completion) else { return }
                guard let peer = found else {
                    completion(.failure(Error.unknownRecipient))
                    return
                }
                
                switch peer {
                case let .p2p(p2pPeer):
                    switch message {
                    case let .serialized(serialized):
                        switch serialized.origin.kind {
                        case .p2p:
                            self.send(serialized.content, to: p2pPeer, completion: completion)
                        }
                    default:
                        /* ignore other messages */
                        completion(.success(()))
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
                let publicKeys = try peers.map { try HexString(from: $0.publicKey) }
                publicKeys.forEach { self.listen(to: $0) }
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
        
        private func listen(to publicKey: HexString) {
            client.listen(to: publicKey) { [weak self] result in
                let message = result.map { ConnectionMessage.serialized(originatedFrom: .p2p(id: publicKey), withContent: $0) }
                self?.notify(with: message)
            }
        }
        
        private func send(_ message: String, to recipient: Beacon.P2PPeer, completion: @escaping (Result<(), Swift.Error>) -> ()) {
            self.client.send(message: message, to: recipient, completion: completion)
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
