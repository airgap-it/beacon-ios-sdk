//
//  BlockchainCreator.swift
//  
//
//  Created by Julia Samol on 01.10.21.
//

import Foundation

public protocol BlockchainCreator {
    associatedtype ConcreteBlockchain: Blockchain
    
    func extractPermission(
        from request: ConcreteBlockchain.Request.Permission,
        and response: ConcreteBlockchain.Response.Permission,
        completion: @escaping (Result<ConcreteBlockchain.Permission, Swift.Error>) -> ()
    )
}

// MARK: Any

public struct AnyBlockchainCreator: BlockchainCreator {
    public typealias ConcreteBlockchain = AnyBlockchain
    
    private let base: Any
    
    fileprivate init<T: BlockchainCreator>(_ creator: T) {
        self.base = creator
    }
    
    public func extractPermission(
        from request: AnyPermissionBeaconRequest,
        and response: AnyPermissionBeaconResponse,
        completion: @escaping (Result<AnyPermission, Swift.Error>) -> ()
    ) {
        let permission = AnyPermission(
            accountIdentifier: response.publicKey,
            address: response.publicKey,
            senderID: request.origin.id,
            appMetadata: request.appMetadata,
            publicKey: response.publicKey,
            connectedAt: 0,
            threshold: response.threshold
        )
        
        completion(.success(permission))
    }
    
    public func unbox<T: BlockchainCreator>() -> T? {
        base as? T
    }
}

// MARK: Error

private enum Error: Swift.Error {
    case unknownRequest
    case unknownResponse
}

// MARK: Extensions

extension BlockchainCreator {
    public func box() -> AnyBlockchainCreator {
        AnyBlockchainCreator(self)
    }
}
