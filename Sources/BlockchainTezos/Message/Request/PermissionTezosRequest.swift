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
    
    /// The value that identifies this request.
    public let id: String
    
    /// The version of the message.
    public let version: String
    
    /// The unique name of the blockchain that specifies the request.
    public let blockchainIdentifier: String
    
    /// The value that identifies the sender of this request.
    public let senderID: String
    
    /// The metadata describing the dApp asking for permissions.
    public let appMetadata: Beacon.AppMetadata
    
    /// The origination data of this request.
    public let origin: Beacon.Origin
    
    /// The network to which the permissions apply.
    public let network: Tezos.Network
    
    /// The list of permissions asked to be granted.
    public let scopes: [Tezos.Permission.Scope]
    
    init(
        id: String,
        version: String,
        blockchainIdentifier: String,
        senderID: String,
        appMetadata: Beacon.AppMetadata,
        origin: Beacon.Origin,
        network: Tezos.Network,
        scopes: [Tezos.Permission.Scope]
    ) {
        self.id = id
        self.version = version
        self.blockchainIdentifier = blockchainIdentifier
        self.senderID = senderID
        self.appMetadata = appMetadata
        self.origin = origin
        self.network = network
        self.scopes = scopes
    }
}
