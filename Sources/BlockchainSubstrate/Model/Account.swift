//
//  Account.swift
//  
//
//  Created by Julia Samol on 10.01.22.
//

import Foundation

extension Substrate {
    
    /// Substrate account data.
    public struct Account: Codable, Equatable {
        
        /// The network on which the account is valid.
        public let network: Network
        
        /// An address type prefix that identifies an address as belonging to a specific network.
        public let addressPrefix: Int
        
        /// The public key that identifies the account.
        public let publicKey: String
        
        public init(network: Network, addressPrefix: Int, publicKey: String) {
            self.network = network
            self.addressPrefix = addressPrefix
            self.publicKey = publicKey
        }
    }
}
