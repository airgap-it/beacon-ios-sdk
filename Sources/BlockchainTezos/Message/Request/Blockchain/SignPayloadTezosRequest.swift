//
//  SignPayloadTezosRequest.swift
//
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
import BeaconCore
    
/// Body of the `Beacon.Request.signPayload` message.
public struct SignPayloadTezosRequest: BlockchainBeaconRequestProtocol, Equatable, Codable {
    
    /// The type of this request.
    public let type: String
    
    /// The value that identifies this request.
    public let id: String
    
    /// The unique name of the blockchain that specifies the request.
    public let blockchainIdentifier: String
    
    /// The value that identifies the sender of this request.
    public let senderID: String
    
    /// The metadata describing the dApp asking for the signature. May be `nil` if the `senderID` is unknown.
    public let appMetadata: Beacon.AppMetadata?
    
    /// The requested type of signature. The client MUST fail if cannot provide the specified signature.
    public let signingType: Tezos.SigningType
    
    /// The payload to be signed.
    public let payload: String
    
    /// The address of the account with which the payload should be signed.
    public let sourceAddress: String
    
    /// The origination data of this request.
    public let origin: Beacon.Origin
    
    /// The version of the message.
    public let version: String
    
    init(
        type: String,
        id: String,
        blockchainIdentifier: String,
        senderID: String,
        appMetadata: Beacon.AppMetadata?,
        signingType: Tezos.SigningType,
        payload: String,
        sourceAddress: String,
        origin: Beacon.Origin,
        version: String
    ) {
        self.type = type
        self.id = id
        self.blockchainIdentifier = blockchainIdentifier
        self.senderID = senderID
        self.appMetadata = appMetadata
        self.signingType = signingType
        self.payload = payload
        self.sourceAddress = sourceAddress
        self.origin = origin
        self.version = version
    }
}
