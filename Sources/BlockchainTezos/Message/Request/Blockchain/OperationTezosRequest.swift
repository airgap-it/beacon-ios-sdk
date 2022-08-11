//
//  OperationTezosRequest.swift
//
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
import BeaconCore
    
/// Body of the `BlockchainTezosRequest.operation` message.
public struct OperationTezosRequest: BlockchainBeaconRequestProtocol, Identifiable, Equatable, Codable {
    
    /// The value that identifies this request.
    public let id: String
    
    /// The version of the message.
    public let version: String
    
    /// The value that identifies the sender of this request.
    public let senderID: String
    
    /// The origination data of this request.
    public let origin: Beacon.Connection.ID
    
    /// The destination data of this request.
    public let destination: Beacon.Connection.ID
    
    /// The account identifier of the account that is requested to handle this request. May be `nil`.
    public let accountID: String?
    
    /// The metadata describing the dApp asking for the broadcast. May be `nil` if the `senderID` is unknown.
    public let appMetadata: Tezos.AppMetadata?
    
    /// The network on which the operations should be broadcast.
    public let network: Tezos.Network
    
    /// Tezos operations which should be broadcast.
    public let operationDetails: [Tezos.Operation]
    
    /// The address of the Tezos account that is requested to broadcast the operations.
    public let sourceAddress: String
}
