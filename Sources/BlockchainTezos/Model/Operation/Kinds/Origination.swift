//
//  Origination.swift
//  
//
//  Created by Mike Godenzi on 30.10.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Tezos.Operation {
    
    public struct Origination: Codable, Equatable {
        public let kind: Kind
        public let source: String?
        public let fee: String?
        public let counter: String?
        public let gasLimit: String?
        public let storageLimit: String?
        public let balance: String
        public let delegate: String?
        public let script: Script
        
        public init(
            source: String? = nil,
            fee: String? = nil,
            counter: String? = nil,
            gasLimit: String? = nil,
            storageLimit: String? = nil,
            balance: String,
            delegate: String? = nil,
            script: Script
        ) {
            kind = .origination
            self.source = source
            self.fee = fee
            self.counter = counter
            self.gasLimit = gasLimit
            self.storageLimit = storageLimit
            self.balance = balance
            self.delegate = delegate
            self.script = script
        }
        
        public enum CodingKeys: String, CodingKey {
            case kind
            case source
            case fee
            case counter
            case gasLimit = "gas_limit"
            case storageLimit = "storage_limit"
            case balance
            case delegate
            case script
        }
    }
}
