//
//  BroadcastTezosResponse.swift
//
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
import BeaconCore
    
/// Body of the `BlockchainTezosResponse.broadcast` message.
public struct BroadcastTezosResponse: BlockchainBeaconResponseProtocol, Identifiable, Equatable, Codable {
    
    /// The value that identifies the request to which the message is responding.
    public let id: String
    
    /// The version of the message.
    public let version: String
    
    /// The origination data of the request.
    public let requestOrigin: Beacon.Origin
    
    /// The hash of the broadcast transaction.
    public let transactionHash: String
    
    public init(from request: BroadcastTezosRequest, transactionHash: String) {
        self.init(
            id: request.id,
            version: request.version,
            requestOrigin: request.origin,
            transactionHash: transactionHash
        )
    }
    
    public init(id: String, version: String, requestOrigin: Beacon.Origin, transactionHash: String) {
        self.id = id
        self.version = version
        self.requestOrigin = requestOrigin
        self.transactionHash = transactionHash
    }
}
