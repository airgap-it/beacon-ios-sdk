//
//  SignPayloadTezosRequest.swift
//
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
import BeaconCore
    
/// Body of the `BlockchainTezosRequest.signPayload` message.
public struct SignPayloadTezosRequest: BlockchainBeaconRequestProtocol, Identifiable, Equatable, Codable {
    
    /// The value that identifies this request.
    public let id: String
    
    /// The version of the message.
    public let version: String
    
    /// The value that identifies the sender of this request.
    public let senderID: String
    
    /// The metadata describing the dApp asking for the signature. May be `nil` if the `senderID` is unknown.
    public let appMetadata: Tezos.AppMetadata?
    
    /// The origination data of this request.
    public let origin: Beacon.Origin
    
    /// THe account identifier of the account that is requested to handle this request. May be `nil`.
    public let accountID: String?
    
    /// The requested type of signature. The client MUST fail if cannot provide the specified signature.
    public let signingType: Tezos.SigningType
    
    /// The payload to be signed.
    public let payload: String
    
    /// The address of the account with which the payload should be signed.
    public let sourceAddress: String
    
    init(
        id: String,
        version: String,
        senderID: String,
        appMetadata: Tezos.AppMetadata?,
        origin: Beacon.Origin,
        accountID: String?,
        signingType: Tezos.SigningType,
        payload: String,
        sourceAddress: String
    ) {
        self.id = id
        self.version = version
        self.senderID = senderID
        self.appMetadata = appMetadata
        self.origin = origin
        self.accountID = accountID
        self.signingType = signingType
        self.payload = payload
        self.sourceAddress = sourceAddress
    }
}
