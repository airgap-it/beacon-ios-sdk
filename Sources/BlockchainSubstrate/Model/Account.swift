//
//  Account.swift
//  
//
//  Created by Julia Samol on 10.01.22.
//

import Foundation
import BeaconCore

extension Substrate {
    
    /// Substrate account data.
    public struct Account: Codable, Hashable {
        
        /// The value that identifies the account.
        public let accountID: String
        
        /// The network on which the account is valid. Can be omitted.
        public let network: Network?
        
        /// The public key that identifies the account.
        public let publicKey: String
        
        /// The account address.
        public let address: String
        
        public init(publicKey: String, address: String, network: Network? = nil) throws {
            let accountID = try dependencyRegistry().identifierCreator.accountID(forAddress: address, onNetworkWithIdentifier: network?.identifier)
            self.init(accountID: accountID, network: network, publicKey: publicKey, address: address)
        }
        
        public init(accountID: String, network: Network?, publicKey: String, address: String) {
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
