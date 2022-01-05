//
//  BlockchainDecoder.swift
//  
//
//  Created by Julia Samol on 11.10.21.
//

import Foundation

public protocol BlockchainDecoder {
    
    // MARK: VersionedMessage
    
    var v1: BlockchainV1MessageDecoder { get }
    var v2: BlockchainV2MessageDecoder { get }
    var v3: BlockchainV3MessageDecoder { get }
}

public protocol BlockchainV1MessageDecoder {
    func message(from decoder: Decoder) throws -> V1BeaconMessageProtocol & Codable
}

public protocol BlockchainV2MessageDecoder {
    func message(from decoder: Decoder) throws -> V2BeaconMessageProtocol & Codable
}

public protocol BlockchainV3MessageDecoder {
    
    // MARK: Request
    
    func permissionRequestData(from decoder: Decoder) throws -> PermissionV3BeaconRequestContentDataProtocol & Codable
    func blockchainRequestData(from decoder: Decoder) throws -> BlockchainV3BeaconRequestContentDataProtocol & Codable
    
    // MARK: Response
    
    func permissionResponseData(from decoder: Decoder) throws -> PermissionV3BeaconResponseContentDataProtocol & Codable
    func blockchainResponseData(from decoder: Decoder) throws -> BlockchainV3BeaconResponseContentDataProtocol & Codable
}
