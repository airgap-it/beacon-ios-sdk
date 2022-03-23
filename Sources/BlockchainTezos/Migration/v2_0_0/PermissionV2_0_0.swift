//
//  PermissionV2_0_0.swift
//  
//
//  Created by Julia Samol on 02.02.22.
//

import Foundation
import BeaconCore

extension Tezos {
    
    struct PermissionV2_0_0: LegacyPermissionProtocol {
        static let fromVersion: String = Migration.Tezos.From2_0_0.fromVersion
        static let blockchainIdentifier: String? = nil
        
        let accountID: String
        let senderID: String
        let connectedAt: Int64
        let address: String
        let publicKey: String
        let network: Network
        let appMetadata: AppMetadata
        let scopes: [Scope]
        
        // MARK: Scope
        
        enum Scope: String, Codable, Equatable {
            case sign
            case operationRequest = "operation_request"
            case threshold
        }
        
        // MARK: Types
        
        enum CodingKeys: String, CodingKey {
            case accountID = "accountIdentifier"
            case senderID
            case connectedAt
            case address
            case publicKey
            case network
            case appMetadata
            case scopes
        }
    }
}
