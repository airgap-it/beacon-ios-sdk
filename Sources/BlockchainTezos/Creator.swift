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
        public typealias ConcreteBlockchain = Tezos
        
        private let wallet: Wallet
        private let storageManager: StorageManager
        private let identifierCreator: IdentifierCreatorProtocol
        private let time: TimeProtocol
        
        init(wallet: Wallet, storageManager: StorageManager, identifierCreator: IdentifierCreatorProtocol, time: TimeProtocol) {
            self.wallet = wallet
            self.storageManager = storageManager
            self.identifierCreator = identifierCreator
            self.time = time
        }
        
        public func extractPermission(
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
                    
                    let address = try self.wallet.address(fromPublicKey: response.publicKey)
                    let accountID = try self.identifierCreator.accountID(forAddress: address, on: response.network)
                    let senderID = try self.identifierCreator.senderID(from: try HexString(from: request.origin.id))

                    let permission = Tezos.Permission(
                        accountIdentifier: accountID,
                        senderID: senderID,
                        connectedAt: self.time.currentTimeMillis,
                        address: address,
                        publicKey: response.publicKey,
                        network: response.network,
                        appMetadata: appMetadata,
                        scopes: response.scopes
                    )
                    
                    completion(.success([permission]))
                }
            }
        }
        
        // MARK: Types
        
        enum Error: Swift.Error {
            case noMatchingAppMetadata
        }
    }
}
