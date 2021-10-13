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
    
    public let wallet: BlockchainWallet
    public let creator: Creator
    public let decoder: BlockchainDecoder
    
    init(wallet: BlockchainWallet, creator: Creator, decoder: BlockchainDecoder) {
        self.wallet = wallet
        self.creator = creator
        self.decoder = decoder
    }
    
    // MARK: Types
    
    struct PrefixBytes {
        static let tz1: [UInt8] = [6, 161, 159]
        static let tz2: [UInt8] = [6, 161, 161]
        static let tz3: [UInt8] = [6, 161, 164]

        static let kt: [UInt8] = [2, 90, 121]

        static let edpk: [UInt8] = [13, 15, 37, 217]
        static let edsk: [UInt8] = [43, 246, 78, 7]
        static let edsig: [UInt8] = [9, 245, 205, 134, 18]
    }
    
    struct Prefix {
        static let tz1: String = "tz1"
        static let tz2: String = "tz2"
        static let tz3: String = "tz3"
        
        static let kt: String = "kt"
        
        static let edpk: String = "edpk"
        static let edsk: String = "edsk"
        static let edsig: String = "edsig"
    }
}
