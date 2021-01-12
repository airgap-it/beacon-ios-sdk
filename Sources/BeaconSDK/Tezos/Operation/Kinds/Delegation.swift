//
//  Delegation.swift
//  TezosKit
//
//  Created by Mike Godenzi on 30.10.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Tezos.Operation {
    
    public struct Delegation: Codable, Equatable {
        public let kind: Kind
        public let source: String?
        public let fee: String?
        public let counter: String?
        public let gasLimit: String?
        public let storageLimit: String?
        public let delegate: String?
        
        public init(
            source: String? = nil,
            fee: String? = nil,
            counter: String? = nil,
            gasLimit: String? = nil,
            storageLimit: String? = nil,
            delegate: String? = nil
        ) {
            kind = .delegation
            self.source = source
            self.fee = fee
            self.counter = counter
            self.gasLimit = gasLimit
            self.storageLimit = storageLimit
            self.delegate = delegate
        }
        
        public enum CodingKeys: String, CodingKey {
            case kind
            case source
            case fee
            case counter
            case gasLimit = "gas_limit"
            case storageLimit = "storage_limit"
            case delegate
        }
    }
}
