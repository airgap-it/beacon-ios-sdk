//
//  PermissionV3TezosRequest.swift
//  
//
//  Created by Julia Samol on 05.01.22.
//

import Foundation
import BeaconCore

public struct PermissionV3TezosRequest: PermissionV3BeaconRequestContentDataProtocol {
    public let network: Tezos.Network
    public let appMetadata: Tezos.AppMetadata
    public let scopes: [Tezos.Permission.Scope]
    
    init(network: Tezos.Network, appMetadata: Tezos.AppMetadata, scopes: [Tezos.Permission.Scope]) {
        self.network = network
        self.appMetadata = appMetadata
        self.scopes = scopes
    }
    
    // MARK: BeaconMessage Compatibility
    
    public init(from permissionRequest: Tezos.Request.Permission) throws {
        self.init(network: permissionRequest.network, appMetadata: permissionRequest.appMetadata, scopes: permissionRequest.scopes)
    }
    
    public func toBeaconMessage(
        id: String,
        version: String,
        senderID: String,
        origin: Beacon.Origin,
        completion: @escaping (Result<BeaconMessage<Tezos>, Error>) -> ()
    ) {
        completion(.success(.request(
            .permission(
                .init(
                    id: id,
                    version: version,
                    senderID: senderID,
                    origin: origin,
                    appMetadata: appMetadata,
                    network: network,
                    scopes: scopes
                )
            )
        )))
    }
}
