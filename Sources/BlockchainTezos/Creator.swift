//
//  Creator.swift
//  
//
//  Created by Julia Samol on 28.09.21.
//

import Foundation
import BeaconCore

extension Tezos {
    
    public class Creator: BlockchainCreator {
        public typealias BlockchainType = Tezos
        
        private let storageManager: StorageManager
        private let identifierCreator: IdentifierCreatorProtocol
        private let time: TimeProtocol
        
        init(storageManager: StorageManager, identifierCreator: IdentifierCreatorProtocol, time: TimeProtocol) {
            self.storageManager = storageManager
            self.identifierCreator = identifierCreator
            self.time = time
        }
        
        public func extractIncomingPermission(
            from request: BlockchainType.Request.Permission,
            and response: BlockchainType.Response.Permission,
            withOrigin origin: Beacon.Connection.ID,
            completion: @escaping (Result<[BlockchainType.Permission], Swift.Error>) -> ()
        ) {
            storageManager.findPeers(where: { $0.publicKey == origin.id }) { result in
                guard let peerOrNil = result.get(ifFailure: completion) else { return }
                runCatching(completion: completion) {
                    guard let peer = peerOrNil else {
                        throw Error.noMatchingAppMetadata
                    }
                    
                    let senderID = try self.identifierCreator.senderID(from: try HexString(from: origin.id))
                    let appMetadata = AppMetadata(senderID: senderID, name: peer.name, icon: peer.icon)

                    let permission = Tezos.Permission(
                        accountID: response.account.accountID,
                        senderID: senderID,
                        connectedAt: self.time.currentTimeMillis,
                        address: response.account.address,
                        publicKey: response.account.publicKey,
                        network: response.account.network,
                        appMetadata: appMetadata,
                        scopes: response.scopes
                    )
                    
                    completion(.success([permission]))
                }
            }
        }
        
        public func extractOutgoingPermission(
            from request: PermissionTezosRequest,
            and response: PermissionTezosResponse,
            completion: @escaping (Result<[Tezos.Permission], Swift.Error>) -> ()
        ) {
            storageManager.findAppMetadata(where: { (appMetadata: AppMetadata) in request.senderID == appMetadata.senderID }) { result in
                guard let appMetadataOrNil = result.get(ifFailure: completion) else { return }
                runCatching(completion: completion) {
                    guard let appMetadata = appMetadataOrNil else {
                        throw Error.noMatchingAppMetadata
                    }
                    
                    let accountID = try self.identifierCreator.accountID(forAddress: response.account.address, onNetworkWithIdentifier: response.account.network.identifier)
                    let senderID = try self.identifierCreator.senderID(from: try HexString(from: request.origin.id))

                    let permission = Tezos.Permission(
                        accountID: accountID,
                        senderID: senderID,
                        connectedAt: self.time.currentTimeMillis,
                        address: response.account.address,
                        publicKey: response.account.publicKey,
                        network: response.account.network,
                        appMetadata: appMetadata,
                        scopes: response.scopes
                    )
                    
                    completion(.success([permission]))
                }
            }
        }
        
        public func extractAccounts(from response: PermissionTezosResponse, completion: @escaping (Result<[BeaconCore.Account], Swift.Error>) -> ()) {
            completion(.success([.init(accountID: response.account.accountID, address: response.account.address)]))
        }
        
        // MARK: Types
        
        enum Error: Swift.Error {
            case noMatchingAppMetadata
        }
    }
}
