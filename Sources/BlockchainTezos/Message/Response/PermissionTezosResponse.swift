//
//  PermissionTezosResponse.swift
//
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
import BeaconCore
    
/// Tezos specific content of the `BeaconResponse.permission` message.
public struct PermissionTezosResponse: PermissionBeaconResponseProtocol, Identifiable, Equatable, Codable {
    
    /// The value that identifies the request to which the message is responding.
    public let id: String
    
    /// The version of the message.
    public let version: String
    
    /// The origination data of the request.
    public let requestOrigin: Beacon.Origin
    
    /// The account that is granting the permissions.
    public let account: Tezos.Account
    
    /// The list of granted permissions.
    public let scopes: [Tezos.Permission.Scope]
    
    public init(
        from request: Tezos.Request.Permission,
        account: Tezos.Account,
        scopes: [Tezos.Permission.Scope]? = nil
    ) {
        let scopes = scopes ?? request.scopes
        
        self.init(
            id: request.id,
            version: request.version,
            requestOrigin: request.origin,
            account: account,
            scopes: scopes
        )
    }
    
    public init(
        id: String,
        version: String,
        requestOrigin: Beacon.Origin,
        account: Tezos.Account,
        scopes: [Tezos.Permission.Scope]
    ) {
        self.id = id
        self.version = version
        self.requestOrigin = requestOrigin
        self.account = account
        self.scopes = scopes
    }
}
