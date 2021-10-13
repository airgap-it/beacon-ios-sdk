//
//  PermissionTezosRequest.swift
// 
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
import BeaconCore
    
/// Content of the `BeaconRequest.permission` message.
public struct PermissionTezosRequest: PermissionBeaconRequestProtocol, Equatable, Codable {
    
    /// The type of this request.
    public let type: String
    
    /// The value that identifies this request.
    public let id: String
    
    /// The unique name of the blockchain that specifies the request.
    public let blockchainIdentifier: String
    
    /// The value that identifies the sender of this request.
    public let senderID: String
    
    /// The metadata describing the dApp asking for permissions.
    public let appMetadata: Beacon.AppMetadata
    
    /// The network to which the permissions apply.
    public let network: Tezos.Network
    
    /// The list of permissions asked to be granted.
    public let scopes: [Tezos.Permission.Scope]
    
    /// The origination data of this request.
    public let origin: Beacon.Origin
    
    /// The version of the message.
    public let version: String
    
    init(
        type: String,
        id: String,
        blockchainIdentifier: String,
        senderID: String,
        appMetadata: Beacon.AppMetadata,
        network: Tezos.Network,
        scopes: [Tezos.Permission.Scope],
        origin: Beacon.Origin,
        version: String
    ) {
        self.type = type
        self.id = id
        self.blockchainIdentifier = blockchainIdentifier
        self.senderID = senderID
        self.appMetadata = appMetadata
        self.network = network
        self.scopes = scopes
        self.origin = origin
        self.version = version
    }
}
