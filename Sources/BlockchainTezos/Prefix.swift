//
//  Prefix.swift
//  
//
//  Created by Julia Samol on 10.03.22.
//

import Foundation

extension Tezos {
    
    enum Prefix: TezosPrefixProtocol {
        case address(Address)
        case publicKey(PublicKey)
        
        var value: String { common.value }
        var bytes: [UInt8] { common.bytes }
        var encodedCount: Int { common.encodedCount }
        
        private var common: TezosPrefixProtocol {
            switch self {
            case let .address(content):
                return content
            case let .publicKey(content):
                return content
            }
        }
        
        struct Metadata: TezosPrefixProtocol {
            let value: String
            let bytes: [UInt8]
            let encodedCount: Int
        }
    }
}

extension Tezos.Prefix {
    
    enum Address: TezosPrefixProtocol, CaseIterable {
        case ed25519
        case secp256K1
        case p256
        case contract
        
        private static let _ed25519: Metadata = .init(value: "tz1", bytes: [6, 161, 159], encodedCount: 36) /* tz1(36) */
        private static let _secp256K1: Metadata = .init(value: "tz2", bytes: [6, 161, 161], encodedCount: 36) /* tz2(36) */
        private static let _p256: Metadata = .init(value: "tz3", bytes: [6, 161, 164], encodedCount: 36) /* tz3(36) */
        private static let _contract: Metadata = .init(value: "KT1", bytes: [2, 90, 121], encodedCount: 36 ) /* KT1(36) */
        
        var value: String { rawValue.value }
        var bytes: [UInt8] { rawValue.bytes }
        var encodedCount: Int { rawValue.encodedCount }
        
        private var rawValue: Metadata {
            switch self {
            case .ed25519:
                return Self._ed25519
            case .secp256K1:
                return Self._secp256K1
            case .p256:
                return Self._p256
            case .contract:
                return Self._contract
            }
        }
    }
}

extension Tezos.Prefix {
    
    enum PublicKey: TezosPrefixProtocol, CaseIterable {
        case ed25519
        case secp256K1
        case p256
        
        private static let _ed25519: Metadata = .init(value: "edpk", bytes: [13, 15, 37, 217], encodedCount: 54) /* edpk(54) */
        private static let _secp256K1: Metadata = .init(value: "sppk", bytes: [3, 254, 226, 86], encodedCount: 55) /* sppk(55) */
        private static let _p256: Metadata = .init(value: "p2pk", bytes: [3, 178, 139, 127], encodedCount: 55) /* p2pk(55) */
        
        var value: String { rawValue.value }
        var bytes: [UInt8] { rawValue.bytes }
        var encodedCount: Int { rawValue.encodedCount }
        
        private var rawValue: Metadata {
            switch self {
            case .ed25519:
                return Self._ed25519
            case .secp256K1:
                return Self._secp256K1
            case .p256:
                return Self._p256
            }
        }
    }
}

// MARK: Protocol

protocol TezosPrefixProtocol {
    var value: String { get }
    var bytes: [UInt8] { get }
    var encodedCount: Int { get }
}
