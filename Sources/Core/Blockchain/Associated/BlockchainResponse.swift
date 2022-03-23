//
//  BlockchainResponse.swift
//  
//
//  Created by Julia Samol on 01.10.21.
//

import Foundation

public protocol BlockchainResponse {
    associatedtype Permission: PermissionBeaconResponseProtocol & Equatable
    associatedtype Blockchain: BlockchainBeaconResponseProtocol & Equatable
}

// MARK: Any

struct AnyBlockchainResponse: BlockchainResponse {
    struct Permission: PermissionBeaconResponseProtocol, Equatable {
        public var id: String
        public var version: String
        public var requestOrigin: Beacon.Origin
    }
    
    struct Blockchain: BlockchainBeaconResponseProtocol, Equatable {
        public var id: String
        public var version: String
        public var requestOrigin: Beacon.Origin
    }
}
