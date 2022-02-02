//
//  BlockchainCreator.swift
//  
//
//  Created by Julia Samol on 01.10.21.
//

import Foundation

public protocol BlockchainCreator {
    associatedtype BlockchainType: Blockchain
    
    func extractPermission(
        from request: BlockchainType.Request.Permission,
        and response: BlockchainType.Response.Permission,
        completion: @escaping (Result<[BlockchainType.Permission], Swift.Error>) -> ()
    )
}

// MARK: Any

struct AnyBlockchainCreator: BlockchainCreator {
    typealias BlockchainType = AnyBlockchain
    
    private let identifierCreator: IdentifierCreatorProtocol
    private let time: TimeProtocol
    
    init(identifierCreator: IdentifierCreator, time: TimeProtocol) {
        self.identifierCreator = identifierCreator
        self.time = time
    }
    
    func extractPermission(
        from request: BlockchainType.Request.Permission,
        and response: BlockchainType.Response.Permission,
        completion: @escaping (Result<[BlockchainType.Permission], Error>) -> ()
    ) {
        runCatching(completion: completion) {
            let senderID = try identifierCreator.senderID(from: try HexString(from: request.origin.id))
            let connectedAt = time.currentTimeMillis
            let permissions = response.accountIDs.map {
                AnyPermission(
                    accountID: $0,
                    senderID: senderID,
                    connectedAt: connectedAt
                )
            }
            
            completion(.success(permissions))
        }
    }
}
