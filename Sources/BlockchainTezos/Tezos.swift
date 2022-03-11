//
//  Tezos.swift
//
//
//  Created by Julia Samol on 12.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
import BeaconCore

/// Tezos implementation of the `Blockchain` protocol.
public class Tezos: Blockchain {
    public typealias Request = TezosRequest
    public typealias Response = TezosResponse
    public typealias VersionedMessage = VersionedTezosMessage
    
    /// A unique name which identifies this blockchain.
    public static let identifier: String = "tezos"
    
    /// A factory used to dynamically register this blockchain in Beacon.
    public static let factory: Tezos.Factory = .init()
    
    let wallet: Wallet
    
    public let creator: Creator
    public let storageExtension: BlockchainStorageExtension
    
    init(wallet: Wallet, creator: Creator, storageExtension: StorageExtension) {
        self.wallet = wallet
        self.creator = creator
        self.storageExtension = storageExtension
    }
}
