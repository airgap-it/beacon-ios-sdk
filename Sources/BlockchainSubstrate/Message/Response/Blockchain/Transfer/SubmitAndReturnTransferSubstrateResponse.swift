//
//  SubmitAndReturnTransferSubstrateResponse.swift
//
//
//  Created by Julia Samol on 11.01.22.
//

import Foundation
import BeaconCore

public struct SubmitAndReturnTransferSubstrateResponse: BlockchainBeaconResponseProtocol, Identifiable, Equatable, Codable {
    /// The value that identifies the request to which the message is responding.
    public let id: String
    
    /// The version of the message.
    public let version: String
    
    /// The origination data of the request.
    public let requestOrigin: Beacon.Origin
    
    public let transactionHash: String
    
    public let signature: String
    
    public let payload: String?
    
    public init(from request: TransferSubstrateRequest, transactionHash: String, signature: String, payload: String? = nil) throws {
        guard request.mode == .submitAndReturn else {
            throw Error.invalidRequestMode
        }
        
        self.init(
            id: request.id,
            version: request.version,
            requestOrigin: request.origin,
            transactionHash: transactionHash,
            signature: signature,
            payload: payload
        )
    }
    
    public init(id: String, version: String, requestOrigin: Beacon.Origin, transactionHash: String, signature: String, payload: String? = nil) {
        self.id = id
        self.version = version
        self.requestOrigin = requestOrigin
        self.transactionHash = transactionHash
        self.signature = signature
        self.payload = payload
    }
    
    // MARK: Types
    
    enum Error: Swift.Error {
        case invalidRequestMode
    }
}
