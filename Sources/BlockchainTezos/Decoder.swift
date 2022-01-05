//
//  Decoder.swift
//  
//
//  Created by Julia Samol on 11.10.21.
//

import Foundation
import BeaconCore

extension Tezos {
    
    class Decoder: BlockchainDecoder {
    
        // MARK: VersionedMessage
        
         lazy var v1: BlockchainV1MessageDecoder = V1()
         lazy var v2: BlockchainV2MessageDecoder = V2()
         lazy var v3: BlockchainV3MessageDecoder = V3()
        
        private struct V1: BlockchainV1MessageDecoder {
            func message(from decoder: Swift.Decoder) throws -> V1BeaconMessageProtocol & Codable {
                try Tezos.VersionedMessage.V1(from: decoder)
            }
        }
        
        private struct V2: BlockchainV2MessageDecoder {
            func message(from decoder: Swift.Decoder) throws -> V2BeaconMessageProtocol & Codable {
                try Tezos.VersionedMessage.V2(from: decoder)
            }
        }
        
        private struct V3: BlockchainV3MessageDecoder {
            
            // MARK: Request
            
            func permissionRequestData(from decoder: Swift.Decoder) throws -> PermissionV3BeaconRequestContentDataProtocol & Codable {
                try PermissionV3TezosRequest(from: decoder)
            }
            
            func blockchainRequestData(from decoder: Swift.Decoder) throws -> BlockchainV3BeaconRequestContentDataProtocol & Codable {
                try BlockchainV3TezosRequest(from: decoder)
            }
            
            // MARK: Response
            
            func permissionResponseData(from decoder: Swift.Decoder) throws -> PermissionV3BeaconResponseContentDataProtocol & Codable {
                try PermissionV3TezosResponse(from: decoder)
            }
            
            func blockchainResponseData(from decoder: Swift.Decoder) throws -> BlockchainV3BeaconResponseContentDataProtocol & Codable {
                try BlockchainV3TezosResponse(from: decoder)
            }
        }
    }
}
