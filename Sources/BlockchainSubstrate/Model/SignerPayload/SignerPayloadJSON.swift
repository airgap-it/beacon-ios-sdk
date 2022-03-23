//
//  SignerPayloadJSON.swift
//  
//
//  Created by Julia Samol on 10.03.22.
//

import Foundation

extension Substrate.SignerPayload {
    
    public struct JSON: SignerPayloadProtocol {
        public let type: `Type` = .json
        public let blockHash: String
        public let blockNumber: String
        public let era: String
        public let genesisHash: String
        public let method: String
        public let nonce: String
        public let specVersion: String
        public let tip: String
        public let transactionVersion: String
        public let signedExtensions: [String]
        public let version: Int64
        
        // MARK: Codable
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: Self.CodingKeys.self)
            let type = try container.decode(`Type`.self, forKey: .type)
            guard type == .json else {
                throw Error.invalidType
            }
            
            self.blockHash = try container.decode(String.self, forKey: .blockHash)
            self.blockNumber = try container.decode(String.self, forKey: .blockNumber)
            self.era = try container.decode(String.self, forKey: .era)
            self.genesisHash = try container.decode(String.self, forKey: .genesisHash)
            self.method = try container.decode(String.self, forKey: .method)
            self.nonce = try container.decode(String.self, forKey: .nonce)
            self.specVersion = try container.decode(String.self, forKey: .specVersion)
            self.tip = try container.decode(String.self, forKey: .tip)
            self.transactionVersion = try container.decode(String.self, forKey: .transactionVersion)
            self.signedExtensions = try container.decode([String].self, forKey: .signedExtensions)
            self.version = try container.decode(Int64.self, forKey: .version)
        }
    }
}
