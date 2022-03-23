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
        
        // MARK: Types
        
        enum Error: Swift.Error {
            case noMatchingAppMetadata
        }
    }
}
