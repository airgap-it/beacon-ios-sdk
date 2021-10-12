//
//  BroadcastTezosRequest.swift
//
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
import BeaconCore
    
/// Body of the `Beacon.Request.broadcast` message.
public struct BroadcastTezosRequest: BlockchainBeaconRequestProtocol, Equatable, Codable {
    
    /// The type of this request.
    public let type: String
    
    /// The value that identifies this request.
    public let id: String
    
    /// The unique name of the blockchain that specifies the request.
    public let blockchainIdentifier: String
    
    /// The value that identifies the sender of this request.
    public let senderID: String
    
    /// The metadata describing the dApp asking for the broadcast. May be `nil` if the `senderID`is unknown.
    public let appMetadata: Beacon.AppMetadata?
    
    /// The network on which the transaction should be broadcast.
    public let network: Tezos.Network
    
    /// The transaction to be broadcast.
    public let signedTransaction: String
    
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
        network: Tezos.Network,
        signedTransaction: String,
        origin: Beacon.Origin,
        version: String
    ) {
        self.type = type
        self.id = id
        self.blockchainIdentifier = blockchainIdentifier
        self.senderID = senderID
        self.appMetadata = appMetadata
        self.network = network
        self.signedTransaction = signedTransaction
        self.origin = origin
        self.version = version
    }
}
