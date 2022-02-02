//
//  PermissionV3SubstrateRequest.swift
//  
//
//  Created by Julia Samol on 10.01.22.
//

import Foundation
import BeaconCore

public struct PermissionV3SubstrateRequest: PermissionV3BeaconRequestContentDataProtocol {
    public let appMetadata: Substrate.AppMetadata
    public let scopes: [Substrate.Permission.Scope]
    public let networks: [Substrate.Network]
    
    init(appMetadata: Substrate.AppMetadata, scopes: [Substrate.Permission.Scope], networks: [Substrate.Network]) {
        self.appMetadata = appMetadata
        self.scopes = scopes
        self.networks = networks
    }
    
    // MARK: BeaconMessage Compatibility
    
    public init(from permissionRequest: Substrate.Request.Permission) throws {
        self.init(appMetadata: permissionRequest.appMetadata, scopes: permissionRequest.scopes, networks: permissionRequest.networks)
    }
    
    public func toBeaconMessage(
        id: String,
        version: String,
        senderID: String,
        origin: Beacon.Origin,
        completion: @escaping (Result<BeaconMessage<Substrate>, Error>) -> ()
    ) {
        completion(.success(.request(
            .permission(
                .init(
                    id: id,
                    version: version,
                    senderID: senderID,
                    origin: origin,
                    appMetadata: appMetadata,
                    scopes: scopes,
                    networks: networks
                )
            )
        )))
    }
}
