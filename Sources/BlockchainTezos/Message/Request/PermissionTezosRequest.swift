//
//  PermissionTezosRequest.swift
// 
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
import BeaconCore
    
/// Tezos specific content of the `BeaconRequest.permission` message.
public struct PermissionTezosRequest: PermissionBeaconRequestProtocol, Identifiable, Equatable, Codable {
    public typealias AppMetadata = Tezos.AppMetadata
    
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
    
    /// The metadata describing the dApp asking for permissions.
    public let appMetadata: AppMetadata
    
    /// The network to which the permissions apply.
    public let network: Tezos.Network
    
    /// The list of permissions asked to be granted.
    public let scopes: [Tezos.Permission.Scope]
}
