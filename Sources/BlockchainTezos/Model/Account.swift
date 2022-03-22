//
//  Account.swift
//  
//
//  Created by Julia Samol on 10.03.22.
//

import Foundation
import BeaconCore

extension Tezos {
    
    /// Tezos account data.
    public struct Account: Codable, Equatable {
        
        /// The value that identifies the account.
        public let accountID: String
        
        /// The network on which the account is valid.
        public let network: Network
        
        /// The public key that identifies the account.
        public let publicKey: String
        
        /// The account address.
        public let address: String
        
        public init(publicKey: String, address: String, network: Network) throws {
            let accountID = try dependencyRegistry().identifierCreator.accountID(forAddress: address, on: network)
            self.init(accountID: accountID, network: network, publicKey: publicKey, address: address)
        }
        
        public init(accountID: String, network: Network, publicKey: String, address: String) {
            self.accountID = accountID
            self.network = network
            self.publicKey = publicKey
            self.address = address
        }
        
        // MARK: Types
        
        enum CodingKeys: String, CodingKey {
            case accountID = "accountId"
            case network
            case publicKey
            case address
        }
    }
}
