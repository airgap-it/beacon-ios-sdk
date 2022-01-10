//
//  Decoder.swift
//  
//
//  Created by Julia Samol on 10.01.22.
//

import Foundation
import BeaconCore

extension Substrate {
    
    class Decoder: BlockchainDecoder {
        
        // MARK: VersionedMessage
        
        lazy var v1: BlockchainV1MessageDecoder = V1()
        lazy var v2: BlockchainV2MessageDecoder = V2()
        lazy var v3: BlockchainV3MessageDecoder = V3()
        
        private struct V1: BlockchainV1MessageDecoder {
            func message(from decoder: Swift.Decoder) throws -> V1BeaconMessageProtocol & Codable {
                throw Beacon.Error.messageVersionNotSupported(version: "1", blockchainIdentifier: Substrate.identifier)
            }
        }
        
        private struct V2: BlockchainV2MessageDecoder {
            func message(from decoder: Swift.Decoder) throws -> V2BeaconMessageProtocol & Codable {
                throw Beacon.Error.messageVersionNotSupported(version: "2", blockchainIdentifier: Substrate.identifier)
            }
        }
        
        private struct V3: BlockchainV3MessageDecoder {
            
            // MARK: Request
            
            func permissionRequestData(from decoder: Swift.Decoder) throws -> PermissionV3BeaconRequestContentDataProtocol & Codable {
                try PermissionV3SubstrateRequest(from: decoder)
            }
            
            func blockchainRequestData(from decoder: Swift.Decoder) throws -> BlockchainV3BeaconRequestContentDataProtocol & Codable {
                try BlockchainV3SubstrateRequest(from: decoder)
            }
            
            // MARK: Response
            
            func permissionResponseData(from decoder: Swift.Decoder) throws -> PermissionV3BeaconResponseContentDataProtocol & Codable {
                try PermissionV3SubstrateResponse(from: decoder)
            }
            
            func blockchainResponseData(from decoder: Swift.Decoder) throws -> BlockchainV3BeaconResponseContentDataProtocol & Codable {
                try BlockchainV3SubstrateResponse(from: decoder)
            }
        }
    }
}
