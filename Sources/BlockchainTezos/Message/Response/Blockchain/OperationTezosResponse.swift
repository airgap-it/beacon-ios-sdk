//
//  OperationTezosResponse.swift
//
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
import BeaconCore
    
/// Body of the `BlockchainTezosResponse.operation` message.
public struct OperationTezosResponse: BlockchainBeaconResponseProtocol, Identifiable, Equatable, Codable {
    
    /// The value that identifies the request to which the message is responding.
    public let id: String
    
    /// The version of the message.
    public let version: String
    
    /// The origination data of the request.
    public let destination: Beacon.Connection.ID
    
    /// The hash of the broadcast operations.
    public let transactionHash: String
    
    public init(from request: OperationTezosRequest, transactionHash: String) {
        self.init(id: request.id, version: request.version, destination: request.origin, transactionHash: transactionHash)
    }
    
    public init(id: String, version: String, destination: Beacon.Connection.ID, transactionHash: String) {
        self.id = id
        self.version = version
        self.destination = destination
        self.transactionHash = transactionHash
    }
}
