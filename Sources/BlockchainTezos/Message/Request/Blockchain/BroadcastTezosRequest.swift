//
//  BroadcastTezosRequest.swift
//
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
import BeaconCore
    
/// Body of the `BlockchainTezosRequest.broadcast` message.
public struct BroadcastTezosRequest: BlockchainBeaconRequestProtocol, Identifiable, Equatable, Codable {
    
    /// The value that identifies this request.
    public let id: String
    
    /// The version of the message.
    public let version: String
    
    /// The value that identifies the sender of this request.
    public let senderID: String
    
    /// The metadata describing the dApp asking for the broadcast. May be `nil` if the `senderID`is unknown.
    public let appMetadata: Tezos.AppMetadata?
    
    /// The origination data of this request.
    public let origin: Beacon.Connection.ID
    
    /// The destination data of this request.
    public let destination: Beacon.Connection.ID
    
    /// The account identifier of the account that is requested to handle this request. May be `nil`.
    public let accountID: String?
    
    /// The network on which the transaction should be broadcast.
    public let network: Tezos.Network
    
    /// The transaction to be broadcast.
    public let signedTransaction: String
    
    init(
        id: String,
        version: String,
        senderID: String,
        appMetadata: Tezos.AppMetadata?,
        origin: Beacon.Connection.ID,
        destination: Beacon.Connection.ID,
        accountID: String?,
        network: Tezos.Network,
        signedTransaction: String
    ) {
        self.id = id
        self.version = version
        self.senderID = senderID
        self.appMetadata = appMetadata
        self.origin = origin
        self.destination = destination
        self.accountID = accountID
        self.network = network
        self.signedTransaction = signedTransaction
    }
}
