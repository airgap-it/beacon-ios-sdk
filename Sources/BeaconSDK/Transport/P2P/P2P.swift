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
        private let storage: StorageManager
        
        init(client: CommunicationClient, storage: StorageManager) {
            self.client = client
            self.storage = storage
        }
        
        override func connect(withNew peers: [Beacon.PeerInfo], completion: @escaping (Result<(), Swift.Error>) -> ()) {
            let p2pPeers: [Beacon.P2PPeerInfo] = peers.filterP2P()
            
            p2pPeers.awaitAll(
                async: {
                    self.client.sendPairingRequest(to: try HexString(from: $0.publicKey), on: $0.relayServer, version: $0.version, completion: $1)
                }
            ) { [weak self] result in
                guard result.isSuccess(otherwise: completion) else { return }
                
                guard let selfStrong = self else {
                    completion(.failure(Error.unknown))
                    return
                }
                
                selfStrong.listen(to: p2pPeers, completion: completion)
            }
        }
        
        override func disconnect(from peers: [Beacon.PeerInfo], completion: @escaping (Result<(), Swift.Error>) -> ()) {
            do {
                let p2pPeers = peers.filterP2P()
                try p2pPeers.forEach { peer in
                    client.removeListener(for: try HexString(from: peer.publicKey))
                }
                
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
        
        override func start(completion: @escaping (Result<(), Swift.Error>) -> ()) {
            client.start { [weak self] result in
                guard result.isSuccess(otherwise: completion) else { return }
                guard let selfStrong = self else {
                    completion(.failure(Error.unknown))
                    return
                }
                
                selfStrong.connectWithKnownPeers(completion: completion)
            }
        }
        
        override func send(_ message: ConnectionMessage, to recipient: String? = nil, completion: @escaping (Result<(), Swift.Error>) -> ()) {
            switch message {
            case let .serialized(serialized):
                switch serialized.origin.kind {
                case .p2p:
                    send(serialized.content, to: recipient, completion: completion)
                }
            default:
                /* ignore other messages */
                completion(.success(()))
            }
        }
        
        private func connectWithKnownPeers(completion: @escaping (Result<(), Swift.Error>) -> ()) {
            storage.getPeers { [weak self] result in
                guard let peers = result.get(ifFailure: completion) else { return }
                
                guard let selfStrong = self else {
                    completion(.failure(Error.unknown))
                    return
                }
                
                selfStrong.listen(to: peers.filterP2P(), completion: completion)
            }
        }
        
        private func listen(to peers: [Beacon.P2PPeerInfo], completion: @escaping (Result<(), Swift.Error>) -> ()) {
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
                self?.notify(with: result.map { ConnectionMessage.serialized(origin: Beacon.Origin.p2p(id: publicKey), content: $0) })
            }
        }
        
        private func send(_ message: String, to recipient: String?, completion: @escaping (Result<(), Swift.Error>) -> ()) {
            findRecipients(withPublicKey: recipient) { [weak self] result in
                guard let recipients = result.get(ifFailure: completion) else { return }
                
                var sent = 0
                
                do {
                    try recipients.forEach { recipient in
                        guard let selfStrong = self else {
                            completion(.failure(Error.unknown))
                            return
                        }
                        
                        selfStrong.client.send(message: message, to: try HexString(from: recipient.publicKey)) { result in
                            guard result.isSuccess(otherwise: completion) else { return }
                            
                            sent += 1
                            if sent == recipients.count {
                                completion(.success(()))
                            }
                        }
                    }
                } catch {
                    completion(.failure(error))
                }
            }
        }
        
        private func findRecipients(withPublicKey publicKey: String?, completion: @escaping (Result<[Beacon.P2PPeerInfo], Swift.Error>) -> ()) {
            storage.getPeers { result in
                guard let peers = result.get(ifFailure: completion) else { return }
                let p2pPeers = peers.filterP2P()
                
                if let publicKey = publicKey {
                    let recipients = p2pPeers.filter { $0.publicKey == publicKey }
                    guard !recipients.isEmpty else {
                        completion(.failure(Error.unknownRecipient))
                        return
                    }
                    
                    completion(.success(recipients))
                } else {
                    completion(.success(p2pPeers))
                }
            }
        }
        
        // MARK: Types
        
        enum Error: Swift.Error {
            case unknownRecipient
            case unknown
        }
    }
}

// MARK: Extensions

extension Array where Element == Beacon.PeerInfo {
    
    func filterP2P() -> [Beacon.P2PPeerInfo] {
        compactMap {
            switch $0 {
            case let .p2p(peer):
                return peer
            }
        }
    }
}
