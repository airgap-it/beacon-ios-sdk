//
//  BlockchainRequest.swift
//  
//
//  Created by Julia Samol on 01.10.21.
//

import Foundation

public protocol BlockchainRequest {
    associatedtype Permission: PermissionBeaconRequestProtocol & Equatable
    associatedtype Blockchain: BlockchainBeaconRequestProtocol & Equatable
}

// MARK: Any

struct AnyBlockchainRequest: BlockchainRequest {
    struct Permission: PermissionBeaconRequestProtocol, Equatable {
        public typealias AppMetadata = AnyAppMetadata
        
        public var id: String
        public var version: String
        public var senderID: String
        public var appMetadata: AppMetadata
        public var origin: Beacon.Connection.ID
        public var destination: Beacon.Connection.ID
    }
    
    struct Blockchain: BlockchainBeaconRequestProtocol, Equatable {
        public var id: String
        public var version: String
        public var senderID: String
        public var origin: Beacon.Connection.ID
        public var destination: Beacon.Connection.ID
        public var accountID: String?
    }
}
