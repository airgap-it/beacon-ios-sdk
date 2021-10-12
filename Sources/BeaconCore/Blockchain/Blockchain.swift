//
//  Blockchain.swift
//
//
//  Created by Julia Samol on 12.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

public protocol Blockchain {
    associatedtype Creator: BlockchainCreator where Creator.ConcreteBlockchain == Self
    
    associatedtype Request: BlockchainRequest
    associatedtype Response: BlockchainResponse
    associatedtype VersionedMessage: BlockchainVersionedMessage
    
    associatedtype Permission: PermissionProtocol & Equatable & Codable
    associatedtype ErrorType: ErrorTypeProtocol & Equatable & Codable
    
    static var identifier: String { get }
    
    var wallet: BlockchainWallet { get }
    var creator: Creator { get }
    var decoder: BlockchainDecoder { get }
}

// MARK: Any

public struct AnyBlockchain: Blockchain {
    public typealias Creator = AnyBlockchainCreator
    
    public typealias Request = AnyBlockchainRequest
    public typealias Response = AnyBlockchainResponse
    public typealias VersionedMessage = AnyBlockchainVersionedMessage
    
    public typealias Permission = AnyPermission
    public typealias ErrorType = AnyErrorType
    
    public static var identifier: String = "unknown"
    
    public let wallet: BlockchainWallet
    public let creator: Creator
    public let decoder: BlockchainDecoder
    
    private let base: Any
    
    fileprivate init<T: Blockchain>(_ blockchain: T) {
        self.base = blockchain
        
        self.wallet = blockchain.wallet
        self.creator = blockchain.creator.box()
        self.decoder = blockchain.decoder
    }
    
    public func unbox<T: Blockchain>() -> T? {
        base as? T
    }
}

// MARK: Extensions

extension Blockchain {
    public func box() -> AnyBlockchain {
        AnyBlockchain(self)
    }
}
