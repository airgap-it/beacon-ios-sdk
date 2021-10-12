//
//  SignPayloadTezosResponse.swift
//
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
import BeaconCore
    
/// Body of the `Beacon.Response.signPayload` message.
public struct SignPayloadTezosResponse: BlockchainBeaconResponseProtocol, Equatable, Codable {
    
    /// The value that identifies the request to which the message is responding.
    public let id: String
    
    /// The unique name of the blockchain that specifies the request.
    public let blockchainIdentifier: String
    
    /// The signature type.
    public let signingType: Tezos.SigningType
    
    /// The payload signature.
    public let signature: String
    
    /// The version of the message.
    public let version: String
    
    /// The origination data of the request.
    public let requestOrigin: Beacon.Origin
    
    public init(from request: SignPayloadTezosRequest, signature: String) {
        self.init(
            id: request.id,
            blockchainIdentifier: request.blockchainIdentifier,
            signingType: request.signingType,
            signature: signature,
            version: request.version,
            requestOrigin: request.origin
        )
    }
    
    public init(id: String, blockchainIdentifier: String, signingType: Tezos.SigningType, signature: String, version: String, requestOrigin: Beacon.Origin) {
        self.id = id
        self.blockchainIdentifier = blockchainIdentifier
        self.signingType = signingType
        self.signature = signature
        self.version = version
        self.requestOrigin = requestOrigin
    }
}
