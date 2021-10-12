//
//  Decoder.swift
//  
//
//  Created by Julia Samol on 11.10.21.
//

import Foundation
import BeaconCore

extension Tezos {
    
    struct Decoder: BlockchainDecoder {
        func v1(from decoder: Swift.Decoder) throws -> V1BeaconMessageProtocol & Codable {
            try Tezos.VersionedMessage.V1(from: decoder)
        }
        
        func v2(from decoder: Swift.Decoder) throws -> V2BeaconMessageProtocol & Codable {
            try Tezos.VersionedMessage.V2(from: decoder)
        }
    }
}
