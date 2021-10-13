//
//  BlockchainWallet.swift
//  
//
//  Created by Julia Samol on 01.10.21.
//

import Foundation

public protocol BlockchainWallet {
    func address(fromPublicKey publicKey: String) throws -> String
}
