//
//  BroadcastAndReturnSignSubstrateResponse.swift
//
//
//  Created by Julia Samol on 11.01.22.
//

import Foundation
import BeaconCore

public struct BroadcastAndReturnSignSubstrateResponse: BlockchainBeaconResponseProtocol, Equatable, Codable {
    /// The value that identifies the request to which the message is responding.
    public let id: String
    
    /// The version of the message.
    public let version: String
    
    /// The origination data of the request.
    public let requestOrigin: Beacon.Origin
    
    /// The unique name of the blockchain that specifies the request.
    public let blockchainIdentifier: String
    
    public let transactionHash: String
    
    public let payload: String
    
    public init(from request: SignSubstrateRequest, transactionHash: String, payload: String) throws {
        guard request.mode == .broadcastAndReturn else {
            throw Error.invalidRequestMode
        }
        
        self.init(
            id: request.id,
            version: request.version,
            requestOrigin: request.origin,
            blockchainIdentifier: request.blockchainIdentifier,
            transactionHash: transactionHash,
            payload: payload
        )
    }
    
    public init(id: String, version: String, requestOrigin: Beacon.Origin, blockchainIdentifier: String, transactionHash: String, payload: String) {
        self.id = id
        self.version = version
        self.requestOrigin = requestOrigin
        self.blockchainIdentifier = blockchainIdentifier
        self.transactionHash = transactionHash
        self.payload = payload
    }
    
    // MARK: Types
    
    enum Error: Swift.Error {
        case invalidRequestMode
    }
}
