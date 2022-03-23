//
//  PermissionV3SubstrateResponse.swift
//  
//
//  Created by Julia Samol on 11.01.22.
//

import Foundation
import BeaconCore

public struct PermissionV3SubstrateResponse: PermissionV3BeaconResponseContentDataProtocol {
    public let appMetadata: Substrate.AppMetadata
    public let scopes: [Substrate.Permission.Scope]
    public let accounts: [Substrate.Account]
    
    init(appMetadata: Substrate.AppMetadata, scopes: [Substrate.Permission.Scope], accounts: [Substrate.Account]) {
        self.appMetadata = appMetadata
        self.scopes = scopes
        self.accounts = accounts
    }
    
    // MARK: BeaconMessage Compatibility
    
    public init(from permissionResponse: Substrate.Response.Permission) throws {
       self.init(appMetadata: permissionResponse.appMetadata, scopes: permissionResponse.scopes, accounts: permissionResponse.accounts)
    }
    
    public func toBeaconMessage(
        id: String,
        version: String,
        senderID: String,
        origin: Beacon.Origin,
        completion: @escaping (Result<BeaconMessage<Substrate>, Error>) -> ()
    ) {
        completion(.success(.response(
            .permission(
                .init(
                    id: id,
                    version: version,
                    requestOrigin: origin,
                    appMetadata: appMetadata,
                    scopes: scopes,
                    accounts: accounts
                )
            )
        )))
    }
}
