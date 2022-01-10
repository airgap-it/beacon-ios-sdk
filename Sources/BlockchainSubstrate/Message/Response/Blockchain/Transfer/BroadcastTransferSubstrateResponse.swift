//
//  BroadcastTransferSubstrateResponse.swift
//  
//
//  Created by Julia Samol on 11.01.22.
//

import Foundation
import BeaconCore

public struct BroadcastTransferSubstrateResponse: BlockchainBeaconResponseProtocol, Equatable, Codable {
    /// The value that identifies the request to which the message is responding.
    public let id: String
    
    /// The version of the message.
    public let version: String
    
    /// The origination data of the request.
    public let requestOrigin: Beacon.Origin
    
    /// The unique name of the blockchain that specifies the request.
    public let blockchainIdentifier: String
    
    public let transactionHash: String
    
    public init(from request: TransferSubstrateRequest, transactionHash: String) throws {
        guard request.mode == .broadcast else {
            throw Error.invalidRequestMode
        }
        
        self.init(
            id: request.id,
            version: request.version,
            requestOrigin: request.origin,
            blockchainIdentifier: request.blockchainIdentifier,
            transactionHash: transactionHash
        )
    }
    
    public init(id: String, version: String, requestOrigin: Beacon.Origin, blockchainIdentifier: String, transactionHash: String) {
        self.id = id
        self.version = version
        self.requestOrigin = requestOrigin
        self.blockchainIdentifier = blockchainIdentifier
        self.transactionHash = transactionHash
    }
    
    // MARK: Types
    
    enum Error: Swift.Error {
        case invalidRequestMode
    }
}
