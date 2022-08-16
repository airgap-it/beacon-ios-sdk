//
//  PermissionSubstrateRequest.swift
//  
//
//  Created by Julia Samol on 10.01.22.
//

import Foundation
import BeaconCore

/// Substrate specific contenet of the `BeaconRequest.permission` message.
public struct PermissionSubstrateRequest: PermissionBeaconRequestProtocol, Identifiable, Equatable, Codable {
    public typealias AppMetadata = Substrate.AppMetadata
    
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
    
    /// The list of permissions asked to be granted.
    public let scopes: [Substrate.Permission.Scope]
    
    /// The list of networks ti which the permissions apply.
    public let networks: [Substrate.Network]
}
