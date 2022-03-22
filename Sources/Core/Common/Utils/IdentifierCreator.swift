//
//  IdentifierCreator.swift
//
//
//  Created by Julia Samol on 24.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
import Base58Swift

public class IdentifierCreator: IdentifierCreatorProtocol {
    private static let senderHashSize = 5
    
    private let crypto: Crypto
    
    public init(crypto: Crypto) {
        self.crypto = crypto
    }
    
    public func accountID<T: NetworkProtocol>(forAddress address: String, on network: T?) throws -> String {
        let input: String = {
            if let network = network {
                return "\(address)-\(network.identifier)"
            } else {
                return address
            }
        }()
        let hash = try crypto.hash(message: input, size: 10)
        return Base58.base58CheckEncode(hash)
    }
    
    public func senderID(from publicKey: HexString) throws -> String {
        let hash = try crypto.hash(message: publicKey, size: IdentifierCreator.senderHashSize)
        return Base58.base58CheckEncode(hash)
    }
}

// MARK: Protocol

public protocol IdentifierCreatorProtocol {
    func accountID<T: NetworkProtocol>(forAddress address: String, on network: T?) throws -> String
    func senderID(from publicKey: HexString) throws -> String
}
