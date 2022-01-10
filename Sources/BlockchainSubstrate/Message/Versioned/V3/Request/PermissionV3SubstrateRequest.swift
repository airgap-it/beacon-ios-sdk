//
//  PermissionV3SubstrateRequest.swift
//  
//
//  Created by Julia Samol on 10.01.22.
//

import Foundation
import BeaconCore

public struct PermissionV3SubstrateRequest: PermissionV3BeaconRequestContentDataProtocol, Equatable, Codable {
    public let appMetadata: Substrate.AppMetadata
    public let scopes: [Substrate.Permission.Scope]
    public let networks: [Substrate.Network]
    
    init(appMetadata: Substrate.AppMetadata, scopes: [Substrate.Permission.Scope], networks: [Substrate.Network]) {
        self.appMetadata = appMetadata
        self.scopes = scopes
        self.networks = networks
    }
    
    // MARK: BeaconMessage Compatibility
    
    public init<T: Blockchain>(from permissionRequest: T.Request.Permission, ofType type: T.Type) throws {
        guard let permissionRequest = permissionRequest as? PermissionSubstrateRequest else {
            throw Beacon.Error.unknownBeaconMessage
        }
        
        self.init(appMetadata: permissionRequest.appMetadata, scopes: permissionRequest.scopes, networks: permissionRequest.networks)
    }
    
    public func toBeaconMessage<T: Blockchain>(
        id: String,
        version: String,
        senderID: String,
        origin: Beacon.Origin,
        blockchainIdentifier: String,
        completion: @escaping (Result<BeaconMessage<T>, Error>) -> ()
    ) {
        runCatching(completion: completion) {
            let substrateMessage: BeaconMessage<Substrate> =
                .request(
                    .permission(
                        .init(
                            id: id,
                            version: version,
                            blockchainIdentifier: blockchainIdentifier,
                            senderID: senderID,
                            origin: origin,
                            appMetadata: appMetadata,
                            scopes: scopes,
                            networks: networks
                        )
                    )
                )
            
            guard let beaconMessage = substrateMessage as? BeaconMessage<T> else {
                throw Beacon.Error.unknownBeaconMessage
            }
            
            completion(.success(beaconMessage))
        }
    }
    
    // MARK: Equatable
    
    public func equals(_ other: PermissionV3BeaconRequestContentDataProtocol) -> Bool {
        guard let other = other as? PermissionV3SubstrateRequest else {
            return false
        }
        
        return self == other
    }
}
