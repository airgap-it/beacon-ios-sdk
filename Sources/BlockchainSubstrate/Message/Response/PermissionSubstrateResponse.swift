//
//  PermissionSubstrateResponse.swift
//  
//
//  Created by Julia Samol on 10.01.22.
//

import Foundation
import BeaconCore

/// Substrate specific contenet of the `BeaconResponse.permission` message.
public struct PermissionSubstrateResponse: PermissionBeaconResponseProtocol, Identifiable, Equatable, Codable {
    
    /// The value that identifies the request to which the message is responding.
    public let id: String
    
    /// The version of the message.
    public let version: String
    
    /// The destination data of this response.
    public let destination: Beacon.Connection.ID
    
    public let appMetadata: Substrate.AppMetadata
    
    public let scopes: [Substrate.Permission.Scope]
    
    public let accounts: [Substrate.Account]
    
    public init(
        from request: Substrate.Request.Permission,
        accounts: [Substrate.Account],
        scopes: [Substrate.Permission.Scope]? = nil
    ) {
        let scopes = scopes ?? request.scopes
        
        self.init(
            id: request.id,
            version: request.version,
            destination: request.origin,
            appMetadata: request.appMetadata,
            scopes: scopes,
            accounts: accounts
        )
    }
    
    public init(
        id: String,
        version: String,
        destination: Beacon.Connection.ID,
        appMetadata: Substrate.AppMetadata,
        scopes: [Substrate.Permission.Scope],
        accounts: [Substrate.Account]
    ) {
        self.id = id
        self.version = version
        self.destination = destination
        self.appMetadata = appMetadata
        self.scopes = scopes
        self.accounts = accounts
    }
}
