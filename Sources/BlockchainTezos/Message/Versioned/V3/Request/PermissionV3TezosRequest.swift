//
//  PermissionV3TezosRequest.swift
//  
//
//  Created by Julia Samol on 05.01.22.
//

import Foundation
import BeaconCore

public struct PermissionV3TezosRequest: PermissionV3BeaconRequestContentDataProtocol, Equatable, Codable {
    public let network: Tezos.Network
    public let appMetadata: Tezos.AppMetadata
    public let scopes: [Tezos.Permission.Scope]
    
    init(network: Tezos.Network, appMetadata: Tezos.AppMetadata, scopes: [Tezos.Permission.Scope]) {
        self.network = network
        self.appMetadata = appMetadata
        self.scopes = scopes
    }
    
    // MARK: BeaconMessage Compatibility
    
    public init<T: Blockchain>(from permissionRequest: T.Request.Permission, ofType type: T.Type) throws {
        guard let permissionRequest = permissionRequest as? PermissionTezosRequest else {
            throw Beacon.Error.unknownBeaconMessage
        }
        
        self.init(network: permissionRequest.network, appMetadata: permissionRequest.appMetadata, scopes: permissionRequest.scopes)
    }
    
    public func toBeaconMessage<T: Blockchain>(
        id: String,
        version: String,
        senderID: String,
        origin: Beacon.Origin,
        blockchainIdentifier: String,
        completion: @escaping (Result<BeaconMessage<T>, Error>) -> ()
    ) {
        do {
            let tezosMessage: BeaconMessage<Tezos> =
                .request(
                    .permission(
                        .init(
                            id: id,
                            version: version,
                            blockchainIdentifier: blockchainIdentifier,
                            senderID: senderID,
                            appMetadata: appMetadata,
                            origin: origin,
                            network: network,
                            scopes: scopes
                        )
                    )
                )
            
            guard let beaconMessage = tezosMessage as? BeaconMessage<T> else {
                throw Beacon.Error.unknownBeaconMessage
            }
            
            completion(.success(beaconMessage))
        } catch {
            completion(.failure(error))
        }
    }
    
    // MARK: Equatable
    
    public func equals(_ other: PermissionV3BeaconRequestContentDataProtocol) -> Bool {
        guard let other = other as? PermissionV3TezosRequest else {
            return false
        }
        
        return network == other.network && appMetadata == other.appMetadata && scopes == other.scopes
    }
}
