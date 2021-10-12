//
//  OperationTezosResponse.swift
//
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
import BeaconCore
    
/// Body of the `Beacon.Response.operation` message.
public struct OperationTezosResponse: BlockchainBeaconResponseProtocol, Equatable, Codable {
    
    /// The value that identifies the request to which the message is responding.
    public let id: String
    
    /// The unique name of the blockchain that specifies the request.
    public let blockchainIdentifier: String
    
    /// The hash of the broadcast operations.
    public let transactionHash: String
    
    /// The version of the message.
    public let version: String
    
    /// The origination data of the request.
    public let requestOrigin: Beacon.Origin
    
    public init(from request: OperationTezosRequest, transactionHash: String) {
        self.init(id: request.id, blockchainIdentifier: request.blockchainIdentifier, transactionHash: transactionHash, version: request.version, requestOrigin: request.origin)
    }
    
    public init(id: String, blockchainIdentifier: String, transactionHash: String, version: String, requestOrigin: Beacon.Origin) {
        self.id = id
        self.blockchainIdentifier = blockchainIdentifier
        self.transactionHash = transactionHash
        self.version = version
        self.requestOrigin = requestOrigin
    }
}
