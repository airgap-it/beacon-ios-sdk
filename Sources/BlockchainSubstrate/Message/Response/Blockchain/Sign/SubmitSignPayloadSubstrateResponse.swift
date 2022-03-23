//
//  SubmitSignPayloadSubstrateResponse.swift
//
//
//  Created by Julia Samol on 11.01.22.
//

import Foundation
import BeaconCore

public struct SubmitSignPayloadSubstrateResponse: BlockchainBeaconResponseProtocol, Identifiable, Equatable, Codable {
    /// The value that identifies the request to which the message is responding.
    public let id: String
    
    /// The version of the message.
    public let version: String
    
    /// The origination data of the request.
    public let requestOrigin: Beacon.Origin
    
    public let transactionHash: String
    
    public init(from request: SignPayloadSubstrateRequest, transactionHash: String) throws {
        guard request.mode == .submit else {
            throw Error.invalidRequestMode
        }
        
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
    
    // MARK: Types
    
    enum Error: Swift.Error {
        case invalidRequestMode
    }
}
