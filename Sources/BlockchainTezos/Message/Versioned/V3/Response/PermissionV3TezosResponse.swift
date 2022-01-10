//
//  PermissionV3TezosResponse.swift
//  
//
//  Created by Julia Samol on 05.01.22.
//

import Foundation
import BeaconCore

public struct PermissionV3TezosResponse: PermissionV3BeaconResponseContentDataProtocol, Equatable, Codable {
    public let publicKey: String
    public let network: Tezos.Network
    public let scopes: [Tezos.Permission.Scope]
    
    init(publicKey: String, network: Tezos.Network, scopes: [Tezos.Permission.Scope]) {
        self.publicKey = publicKey
        self.network = network
        self.scopes = scopes
    }
    
    // MARK: BeaconMessage Compatibility
    
    public init<T: Blockchain>(from permissionResponse: T.Response.Permission, ofType type: T.Type) throws {
        guard let permissionResponse = permissionResponse as? PermissionTezosResponse else {
            throw Beacon.Error.unknownBeaconMessage
        }
        
        self.init(publicKey: permissionResponse.publicKey, network: permissionResponse.network, scopes: permissionResponse.scopes)
    }
    
    public func toBeaconMessage<T: Blockchain>(
        id: String,
        version: String,
        senderID: String,
        origin: Beacon.Origin,
        blockchainIdentifier: String,
        accountIDs: [String],
        completion: @escaping (Result<BeaconMessage<T>, Error>) -> ()
    ) {
        runCatching(completion: completion) {
            let tezosMessage: BeaconMessage<Tezos> =
                .response(
                    .permission(
                        .init(
                            id: id,
                            version: version,
                            requestOrigin: origin,
                            blockchainIdentifier: blockchainIdentifier,
                            accountIDs: accountIDs,
                            publicKey: publicKey,
                            network: network,
                            scopes: scopes
                        )
                    )
                )
            
            guard let beaconMessage = tezosMessage as? BeaconMessage<T> else {
                throw Beacon.Error.unknownBeaconMessage
            }
            
            completion(.success(beaconMessage))
        }
    }
    
    // MARK: Equatable
    
    public func equals(_ other: PermissionV3BeaconResponseContentDataProtocol) -> Bool {
        guard let other = other as? PermissionV3TezosResponse else {
            return false
        }
        
        return self == other
    }
}
