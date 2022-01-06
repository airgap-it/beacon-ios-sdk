//
//  Creator.swift
//  
//
//  Created by Julia Samol on 28.09.21.
//

import Foundation
import BeaconCore

extension Tezos {
    
    public struct Creator: BlockchainCreator {
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
            from request: ConcreteBlockchain.Request.Permission,
            and response: ConcreteBlockchain.Response.Permission,
            completion: @escaping (Result<ConcreteBlockchain.Permission, Swift.Error>) -> ()
        ) {
            do {
                let address = try wallet.address(fromPublicKey: response.publicKey)
                let accountIdentifier = try identifierCreator.accountIdentifier(forAddress: address, on: response.network)
                storageManager.findAppMetadata(where: { (appMetadata: AppMetadata) in request.senderID == appMetadata.senderID }) { result in
                    do {
                        guard let appMetadataOrNil = result.get(ifFailure: completion) else { return }
                        guard let appMetadata = appMetadataOrNil else {
                            throw Error.noMatchingAppMetadata
                        }

                        let permission = Tezos.Permission(
                            accountIdentifier: accountIdentifier,
                            address: address,
                            network: response.network,
                            scopes: response.scopes,
                            senderID: try self.identifierCreator.senderIdentifier(from: try HexString(from: request.origin.id)),
                            appMetadata: appMetadata,
                            publicKey: response.publicKey,
                            connectedAt: self.time.currentTimeMillis
                        )
                        
                        completion(.success(permission))
                    } catch {
                        completion(.failure(error))
                    }
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        // MARK: Types
        
        enum Error: Swift.Error {
            case noMatchingAppMetadata
        }
    }
}
