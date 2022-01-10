//
//  PermissionSubstrateResponse.swift
//  
//
//  Created by Julia Samol on 10.01.22.
//

import Foundation
import BeaconCore

/// Substrate specific contenet of the `BeaconResponse.permission` message.
public struct PermissionSubstrateResponse: PermissionBeaconResponseProtocol, Equatable, Codable {
    
    /// The value that identifies the request to which the message is responding.
    public let id: String
    
    /// The version of the message.
    public let version: String
    
    /// The origination data of the request.
    public let requestOrigin: Beacon.Origin
    
    /// The unique name of the blockchain that specifies the request.
    public let blockchainIdentifier: String
    
    /// The account identifiers of the accounts that are granting the permissions.
    public let accountIDs: [String]
    
    public let appMetadata: Substrate.AppMetadata
    
    public let scopes: [Substrate.Permission.Scope]
    
    public let accounts: [Substrate.Account]
    
    public init(
        from request: Substrate.Request.Permission,
        accounts: [Substrate.Account],
        scopes: [Substrate.Permission.Scope]? = nil
    ) throws {
        let scopes = scopes ?? request.scopes
        
        let accountIds: [String] = try accounts.map {
            let address = try dependencyRegistry().extend().substrateWallet.address(fromPublicKey: $0.publicKey, withPrefix: $0.addressPrefix)
            return try dependencyRegistry().identifierCreator.accountID(forAddress: address, on: $0.network)
        }
        
        self.init(
            id: request.id,
            version: request.version,
            requestOrigin: request.origin,
            blockchainIdentifier: request.blockchainIdentifier,
            accountIDs: accountIds,
            appMetadata: request.appMetadata,
            scopes: scopes,
            accounts: accounts
        )
    }
    
    public init(
        id: String,
        version: String,
        requestOrigin: Beacon.Origin,
        blockchainIdentifier: String,
        accountIDs: [String],
        appMetadata: Substrate.AppMetadata,
        scopes: [Substrate.Permission.Scope],
        accounts: [Substrate.Account]
    ) {
        self.id = id
        self.version = version
        self.requestOrigin = requestOrigin
        self.blockchainIdentifier = blockchainIdentifier
        self.accountIDs = accountIDs
        self.appMetadata = appMetadata
        self.scopes = scopes
        self.accounts = accounts
    }
}
