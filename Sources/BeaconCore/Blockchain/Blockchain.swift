//
//  Blockchain.swift
//
//
//  Created by Julia Samol on 12.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

public protocol ShadowBlockchain {
    static var identifier: String { get }
    
    var wallet: BlockchainWallet { get }
    var creator: Any { get }
    var decoder: BlockchainDecoder { get }
}

public protocol Blockchain: ShadowBlockchain {
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

// MARK: Extensions

extension Blockchain {
    public var creator: Any { self.creator }
}
