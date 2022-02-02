//
//  PermissionV3TezosResponse.swift
//  
//
//  Created by Julia Samol on 05.01.22.
//

import Foundation
import BeaconCore

public struct PermissionV3TezosResponse: PermissionV3BeaconResponseContentDataProtocol {
    public let publicKey: String
    public let network: Tezos.Network
    public let scopes: [Tezos.Permission.Scope]
    
    init(publicKey: String, network: Tezos.Network, scopes: [Tezos.Permission.Scope]) {
        self.publicKey = publicKey
        self.network = network
        self.scopes = scopes
    }
    
    // MARK: BeaconMessage Compatibility
    
    public init(from permissionResponse: Tezos.Response.Permission) throws {
        self.init(publicKey: permissionResponse.publicKey, network: permissionResponse.network, scopes: permissionResponse.scopes)
    }
    
    public func toBeaconMessage(
        id: String,
        version: String,
        senderID: String,
        origin: Beacon.Origin,
        accountIDs: [String],
        completion: @escaping (Result<BeaconMessage<Tezos>, Error>) -> ()
    ) {
        completion(.success(.response(
            .permission(
                .init(
                    id: id,
                    version: version,
                    requestOrigin: origin,
                    accountIDs: accountIDs,
                    publicKey: publicKey,
                    network: network,
                    scopes: scopes
                )
            )
        )))
    }
}
