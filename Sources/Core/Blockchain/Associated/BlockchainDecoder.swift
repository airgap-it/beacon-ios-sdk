//
//  BlockchainDecoder.swift
//  
//
//  Created by Julia Samol on 11.10.21.
//

import Foundation

public protocol BlockchainDecoder {
    
    // MARK: VersionedMessage
    
    func v1(from decoder: Decoder) throws -> V1BeaconMessageProtocol & Codable
    func v2(from decoder: Decoder) throws -> V2BeaconMessageProtocol & Codable
}
