//
//  Creator.swift
//  
//
//  Created by Julia Samol on 10.01.22.
//

import Foundation
import BeaconCore

extension Substrate {
    
    public class Creator: BlockchainCreator {
        public typealias BlockchainType = Substrate
        
        private let storageManager: StorageManager
        private let identifierCreator: IdentifierCreatorProtocol
        private let time: TimeProtocol
        
        init(storageManager: StorageManager, identifierCreator: IdentifierCreatorProtocol, time: TimeProtocol) {
            self.storageManager = storageManager
            self.identifierCreator = identifierCreator
            self.time = time
        }
        
        public func extractIncomingPermission(
            from request: PermissionSubstrateRequest,
            and response: PermissionSubstrateResponse,
            withOrigin origin: Beacon.Connection.ID,
            completion: @escaping (Result<[Substrate.Permission], Swift.Error>) -> ()
        ) {
            runCatching(completion: completion) {
                let permissions: [Substrate.Permission] = try response.accounts.map {
                    let accountID = try self.identifierCreator.accountID(forAddress: $0.address, onNetworkWithIdentifier: $0.network?.identifier)
                    let senderID = try self.identifierCreator.senderID(from: try HexString(from: origin.id))
                    
                    return Substrate.Permission(
                        accountID: accountID,
                        senderID: senderID,
                        connectedAt: self.time.currentTimeMillis,
                        appMetadata: response.appMetadata,
                        scopes: response.scopes,
                        account: $0
                    )
                }
                
                completion(.success(permissions))
            }
        }
        
        public func extractOutgoingPermission(
            from request: PermissionSubstrateRequest,
            and response: PermissionSubstrateResponse,
            completion: @escaping (Result<[Substrate.Permission], Swift.Error>) -> ()
        ) {
            storageManager.findAppMetadata(where: { (AppMetadata: AppMetadata) in request.senderID == AppMetadata.senderID }) { result in
                guard let appMetadataOrNil = result.get(ifFailure: completion) else { return }
                runCatching(completion: completion) {
                    guard let appMetadata = appMetadataOrNil else {
                        throw Error.noMatchingAppMetadata
                    }
                    
                    let permissions: [Substrate.Permission] = try response.accounts.map {
                        let accountID = try self.identifierCreator.accountID(forAddress: $0.address, onNetworkWithIdentifier: $0.network?.identifier)
                        let senderID = try self.identifierCreator.senderID(from: try HexString(from: request.origin.id))
                        
                        return Substrate.Permission(
                            accountID: accountID,
                            senderID: senderID,
                            connectedAt: self.time.currentTimeMillis,
                            appMetadata: appMetadata,
                            scopes: response.scopes,
                            account: $0
                        )
                    }
                    
                    completion(.success(permissions))
                }
            }
        }
        
        public func extractAccounts(from response: PermissionSubstrateResponse, completion: @escaping (Result<[BeaconCore.Account], Swift.Error>) -> ()) {
            completeCatching(completion: completion) {
                try response.accounts.map {
                    .init(
                        accountID: try identifierCreator.accountID(forAddress: $0.address, onNetworkWithIdentifier: $0.network?.identifier),
                        address: $0.address
                    )
                }
            }
        }
        
        // MARK: Types
        
        enum Error: Swift.Error {
            case noMatchingAppMetadata
        }
    }
}
