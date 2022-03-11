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
    
    func extractPermission(
        from request: BlockchainType.Request.Permission,
        and response: BlockchainType.Response.Permission,
        completion: @escaping (Result<[BlockchainType.Permission], Error>) -> ()
    ) {
        runCatching(completion: completion) {
            let permissions = [AnyPermission]()
            completion(.success(permissions))
        }
    }
}
