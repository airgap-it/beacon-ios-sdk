//
//  SignPayloadTezosResponse.swift
//
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
import BeaconCore
    
/// Body of the `BlockchainTezosResponse.signPayload` message.
public struct SignPayloadTezosResponse: BlockchainBeaconResponseProtocol, Identifiable, Equatable, Codable {
    
    /// The value that identifies the request to which the message is responding.
    public let id: String
    
    /// The version of the message.
    public let version: String
    
    /// The destination data of this response.
    public let destination: Beacon.Connection.ID
    
    /// The signature type.
    public let signingType: Tezos.SigningType
    
    /// The payload signature.
    public let signature: String
    
    public init(from request: SignPayloadTezosRequest, signingType: Tezos.SigningType? = nil, signature: String) {
        self.init(
            id: request.id,
            version: request.version,
            destination: request.origin,
            signingType: signingType ?? request.signingType,
            signature: signature
        )
    }
    
    public init(id: String, version: String, destination: Beacon.Connection.ID, signingType: Tezos.SigningType, signature: String) {
        self.id = id
        self.version = version
        self.destination = destination
        self.signingType = signingType
        self.signature = signature
    }
}
