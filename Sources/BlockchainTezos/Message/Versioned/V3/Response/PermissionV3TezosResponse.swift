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
    
    public init(from permissionResponse: PermissionBeaconResponseProtocol) throws {
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
        accountID: String,
        using storageManager: StorageManager,
        completion: @escaping (Result<BeaconMessage<T>, Error>) -> ()
    ) {
        do {
            let tezosMessage: BeaconMessage<Tezos> =
                .response(
                    .permission(
                        .init(
                            id: id,
                            version: version,
                            requestOrigin: origin,
                            blockchainIdentifier: blockchainIdentifier,
                            accountID: accountID,
                            publicKey: publicKey,
                            network: network,
                            scopes: scopes,
                            threshold: nil
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
    
    public func equals(_ other: PermissionV3BeaconResponseContentDataProtocol) -> Bool {
        guard let other = other as? PermissionV3TezosResponse else {
            return false
        }
        
        return publicKey == other.publicKey && network == other.network && scopes == other.scopes
    }
    
    
}
