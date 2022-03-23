//
//  Substrate.swift
//  
//
//  Created by Julia Samol on 10.01.22.
//

import Foundation
import BeaconCore

/// Substrate implementation of the `Blockchain` protocol.
public class Substrate: Blockchain {
    public typealias Request = SubstrateRequest
    public typealias Response = SubstrateResponse
    public typealias VersionedMessage = VersionedSubstrateMessage
    
    public static let identifier: String = "substrate"

    /// A factory used to dynamically register the blockchain in Beacon.
    public static let factory: Substrate.Factory = .init()
    
    public let creator: Creator
    public let storageExtension: BlockchainStorageExtension
    
    init(creator: Creator, storageExtension: StorageExtension) {
        self.creator = creator
        self.storageExtension = storageExtension
    }
}
