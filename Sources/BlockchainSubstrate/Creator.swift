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
                        let address = try self.wallet.address(fromPublicKey: $0.publicKey, withPrefix: $0.addressPrefix)
                        let accountID = try self.identifierCreator.accountID(forAddress: address, on: $0.network)
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
        
        // MARK: Types
        
        enum Error: Swift.Error {
            case noMatchingAppMetadata
        }
    }
}
