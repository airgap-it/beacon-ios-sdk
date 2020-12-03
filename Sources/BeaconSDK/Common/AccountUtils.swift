//
//  AccountUtils.swift
//  BeaconSDK
//
//  Created by Julia Samol on 24.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
import Base58Swift

class AccountUtils: AccountUtilsProtocol {
    private let crypto: Crypto
    
    init(crypto: Crypto) {
        self.crypto = crypto
    }
    
    func getAccountIdentifier(forAddress address: String, on network: Beacon.Network) throws -> String {
        var data: [String] = [address, network.identifier]
        
        if let name = network.name {
            data.append("name:\(name)")
        }
        
        if let rpcURL = network.rpcURL {
            data.append("rpc:\(rpcURL)")
        }
        
        let hash = try crypto.hash(message: data.joined(separator: "-"), size: 10)
        
        return Base58.base58CheckEncode(hash)
    }
}

// MARK: Protocol

protocol AccountUtilsProtocol {
    func getAccountIdentifier(forAddress address: String, on network: Beacon.Network) throws -> String
}
