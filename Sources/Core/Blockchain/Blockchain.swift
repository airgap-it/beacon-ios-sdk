//
//  Blockchain.swift
//
//
//  Created by Julia Samol on 12.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

public protocol Blockchain: ShadowBlockchain {
    associatedtype Creator: BlockchainCreator where Creator.BlockchainType == Self
    
    associatedtype Request: BlockchainRequest
    associatedtype Response: BlockchainResponse
    associatedtype VersionedMessage: BlockchainVersionedMessage where VersionedMessage.BlockchainType == Self
    
    associatedtype AppMetadata: AppMetadataProtocol
    associatedtype Permission: PermissionProtocol
    associatedtype ErrorType: ErrorTypeProtocol
    
    static var identifier: String { get }
    
    var creator: Creator { get }
}

// MARK: Shadow

public protocol ShadowBlockchain {
    static var identifier: String { get }
    
    var creator: Any { get }
    var storageExtension: BlockchainStorageExtension { get }
}

// MARK: Any

struct AnyBlockchain : Blockchain {
    typealias Creator = AnyBlockchainCreator
    
    typealias Request = AnyBlockchainRequest
    typealias Response = AnyBlockchainResponse
    typealias VersionedMessage = AnyBlockchainVersionedMessage
    
    typealias AppMetadata = AnyAppMetadata
    typealias Permission = AnyPermission
    typealias ErrorType = AnyErrorType
    
    static let identifier: String = "any"
    
    let creator: AnyBlockchainCreator
    let storageExtension: BlockchainStorageExtension
    
    init(creator: AnyBlockchainCreator, storageExtension: AnyBlockchainStorageExtensions) {
        self.creator = creator
        self.storageExtension = storageExtension
    }
}

// MARK: Extensions

extension Blockchain {
    public var creator: Any { self.creator }
}
