//
//  Transaction.swift
//  TezosKit
//
//  Created by Mike Godenzi on 30.10.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Tezos.Operation {
    
    public struct Transaction: Codable, Equatable {
        public let kind: Kind
        public let source: String?
        public let fee: String?
        public let counter: String?
        public let gasLimit: String?
        public let storageLimit: String?
        public let amount: String
        public let destination: String
        public let parameters: Parameters?
        
        public init(
            source: String? = nil,
            fee: String? = nil,
            counter: String? = nil,
            gasLimit: String? = nil,
            storageLimit: String? = nil,
            amount: String,
            destination: String,
            parameters: Parameters? = nil
        ) {
            kind = .transaction
            self.source = source
            self.fee = fee
            self.counter = counter
            self.gasLimit = gasLimit
            self.storageLimit = storageLimit
            self.amount = amount
            self.destination = destination
            self.parameters = parameters
        }
        
        public enum CodingKeys: String, CodingKey {
            case kind
            case source
            case fee
            case counter
            case gasLimit = "gas_limit"
            case storageLimit = "storage_limit"
            case amount
            case destination
            case parameters
        }
    }
}
