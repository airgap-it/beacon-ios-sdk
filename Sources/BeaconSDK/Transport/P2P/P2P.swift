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
        private let storage: ExtendedStorage
        
        init(client: CommunicationClient, storage: ExtendedStorage) {
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
        
        // MARK: Types
        
        enum Error: Swift.Error {
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
