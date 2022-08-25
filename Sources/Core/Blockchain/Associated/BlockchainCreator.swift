//
//  BlockchainCreator.swift
//  
//
//  Created by Julia Samol on 01.10.21.
//

import Foundation

public protocol BlockchainCreator {
    associatedtype BlockchainType: Blockchain
    
    func extractIncomingPermission(
        from request: BlockchainType.Request.Permission,
        and response: BlockchainType.Response.Permission,
        withOrigin origin: Beacon.Connection.ID,
        completion: @escaping (Result<[BlockchainType.Permission], Swift.Error>) -> ()
    )
    
    func extractOutgoingPermission(
        from request: BlockchainType.Request.Permission,
        and response: BlockchainType.Response.Permission,
        completion: @escaping (Result<[BlockchainType.Permission], Swift.Error>) -> ()
    )
    
    func extractAccounts(
        from response: BlockchainType.Response.Permission,
        completion: @escaping (Result<[Account], Swift.Error>) -> ()
    )
}

// MARK: Any

struct AnyBlockchainCreator: BlockchainCreator {
    typealias BlockchainType = AnyBlockchain
    
    func extractIncomingPermission(
        from request: BlockchainType.Request.Permission,
        and response: BlockchainType.Response.Permission,
        withOrigin origin: Beacon.Connection.ID,
        completion: @escaping (Result<[BlockchainType.Permission], Swift.Error>) -> ()
    ) {
        runCatching(completion: completion) {
            let permissions = [AnyPermission]()
            completion(.success(permissions))
        }
    }
    
    func extractOutgoingPermission(
        from request: BlockchainType.Request.Permission,
        and response: BlockchainType.Response.Permission,
        completion: @escaping (Result<[BlockchainType.Permission], Swift.Error>) -> ()
    ) {
        runCatching(completion: completion) {
            let permissions = [AnyPermission]()
            completion(.success(permissions))
        }
    }
    
    func extractAccounts(
        from response: BlockchainType.Response.Permission,
        completion: @escaping (Result<[Account], Swift.Error>) -> ()
    ) {
        completion(.success([]))
    }
}
