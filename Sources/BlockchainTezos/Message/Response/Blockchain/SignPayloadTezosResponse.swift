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
    
    /// The origination data of the request.
    public let requestOrigin: Beacon.Origin
    
    /// The signature type.
    public let signingType: Tezos.SigningType
    
    /// The payload signature.
    public let signature: String
    
    public init(from request: SignPayloadTezosRequest, signature: String) {
        self.init(
            id: request.id,
            version: request.version,
            requestOrigin: request.origin,
            signingType: request.signingType,
            signature: signature
        )
    }
    
    public init(id: String, version: String, requestOrigin: Beacon.Origin, signingType: Tezos.SigningType, signature: String) {
        self.id = id
        self.version = version
        self.requestOrigin = requestOrigin
        self.signingType = signingType
        self.signature = signature
    }
}
